SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPAPBatch#Process
	@JobRunSID		 int = null -- job run id used for logging
 ,@PAPBatchSID	 int				-- key of batch to process
 ,@ReturnDataSet bit = 0		-- when 1 a single record data set is returned summarizing results of processing
as
/*********************************************************************************************************************************
Sproc    : PAP (pre-authorized payment) Batch Process
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure creates payment records for a batch of pre-authorized payments
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  		| Month Year	| Change Summary
					: ------------- + ----------- + ----------------------------------------------------------------------------------------
					: Tim Edlund		| Nov 2017 		| Initial version
					: Taylor Napier	| Mar 2018		| Excluded processed transactions to allow retry after batch failure
					: Tim Edlund		| Apr 2018		| Added support for asynchronous calling
					: Tim Edlund		| Jan 2019		| Added application of payments to a pre-existing Renewal invoices
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure is called from the PAP batch screen on the user interface.  A key of a pre-authorized payment batch must be 
passed in.  The procedure validates the configuration required to create payments and then processes each record in the
PAP batch - creating a payment (dbo.Payment) record for it.  The new payment records are handled as a single transaction and, 
if successful, the procedure also sets the Processed-Time on the parent payment batch row.  If the batch had not been previously 
locked, the Locked Time column is also set.

The posting of payment to the GL is handled through the EF sproc: dbo.pPayment#Insert.

The procedure does not apply the payment to any invoices that may exist for the registrant. The application of payments
is handled by a separate procedure: dbo.pPAPBatch#Apply

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the procedure to process a batch selected at random.">
    <SQLScript>
      <![CDATA[
declare @papBatchSID int;

select top (1) -- select batch to process at random
	@papBatchSID = pb.PAPBatchSID
from
	dbo.vPAPBatch pb
where
	pb.ProcessedTime is null and year(pb.CreateTime) = sf.fTodayYear() and pb.TotalWithdrawalAmount > 0.00
order by
	newid();

if @@rowcount = 0 or @papBatchSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pPAPBatch#Process
		@PAPBatchSID = @papBatchSID
	 ,@ReturnDataSet = 1;

	select -- review results
		pt.PAPTransactionSID
	 ,pt.PAPBatchSID
	 ,pt.AccountNo
	 ,pt.InstitutionNo
	 ,pt.TransitNo
	 ,pt.WithdrawalAmount
	 ,pt.IsRejected
	 ,pt.PaymentSID
	 ,pt.LockedTime
	 ,pt.ProcessedTime
	 ,pt.GLAccountCode
	 ,pt.GLPostingDate
	 ,pt.DepositDate
	 ,pt.AmountPaid
	 ,pt.Reference
	from
		dbo.vPAPTransaction pt
	where
		pt.PAPBatchSID = @papBatchSID;

end;
  ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="ExecutionTime" Value="00:10:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pPAPBatch#Process'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						 int							= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					 nvarchar(4000)											-- message text for business rule errors
	 ,@blankParm					 varchar(50)												-- tracks name of any required parameter not passed
	 ,@ON									 bit							= cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@OFF								 bit							= cast(0 as bit)	-- constant for bit comparison = 0
	 ,@i									 int																-- loop iteration counter
	 ,@maxrow							 int																-- loop limit
	 ,@paymentSID					 int																-- key of new payment (posted back into PAP Transaction)
	 ,@papTransactionSID	 int																-- key of next PAP transaction to process
	 ,@lockedTime					 datetimeoffset(7)									-- time batch was locked from further editing
	 ,@processedTime			 datetimeoffset(7)									-- used in check on whether batch is already processed
	 ,@batchID						 varchar(12)												-- id of the batch being processed
	 ,@personSID					 int																-- values for payments to be added:
	 ,@paymentTypeSID			 int
	 ,@paymentStatusSID		 int
	 ,@glAccountCode			 varchar(50)
	 ,@glPostingDate			 date							= sf.fToday()
	 ,@depositDate				 date
	 ,@amountPaid					 decimal(11, 2)
	 ,@reference					 varchar(25)
	 ,@invoiceSID					 int																-- key of renewal invoice to apply payment to (if any)
	 ,@recordsProcessed		 int																-- count of records processed in the job
	 ,@termLabel					 nvarchar(35)												-- buffer for configurable label text
	 ,@isCancelled				 bit							= cast(0 as bit)	-- checks for cancellation request on async job calls  
	 ,@currentProcessLabel nvarchar(35)												-- label for stage of work
	 ,@resultMessage			 nvarchar(4000);										-- summary of job result

	declare @work table
	(
		ID								int identity(1, 1)
	 ,PAPTransactionSID int not null
	);

	begin try

		-- check parameter

		if isnull(@JobRunSID, 0) > 0 set @ReturnDataSet = 0;

		if @JobRunSID is not null -- if call is async, update the job run record
		begin

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'JOBSTATUS.INPROCESS'
			 ,@TermLabel = @termLabel output
			 ,@DefaultLabel = N'In Process'
			 ,@UsageNotes = N'Indicates the job is currently running, or appears to be running because no completion time or failure was provided.';

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@CurrentProcessLabel = @termLabel;

		end;

-- SQL Prompt formatting off
		if @ReturnDataSet is null set @ReturnDataSet = @OFF
		if @PAPBatchSID is null	set @blankParm = '@PAPBatchSID';
-- SQL Prompt formatting on

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		select
			@lockedTime		 = pb.LockedTime
		 ,@processedTime = pb.ProcessedTime
		 ,@batchID			 = pb.BatchID
		from
			dbo.PAPBatch pb
		where
			pb.PAPBatchSID = @PAPBatchSID;

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.PAPBatch'
			 ,@Arg2 = @PAPBatchSID;

			raiserror(@errorText, 18, 1);
		end;

		if @processedTime is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'AlreadyProcessed'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 has already been processed (%2).'
			 ,@Arg1 = 'pre-authorized payment batch'
			 ,@Arg2 = @PAPBatchSID;

			raiserror(@errorText, 18, 1);
		end;

		select
			@paymentTypeSID = pt.PaymentTypeSID
		 ,@depositDate		= dateadd(day, pt.DepositDateLagDays, @glPostingDate)
		from
			dbo.PaymentType pt
		where
			pt.PaymentTypeSCD = 'PAP';

		if @paymentTypeSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotConfigured'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
			 ,@Arg1 = 'PAP payment type';

			raiserror(@errorText, 17, 1);
		end;

		select
			@paymentStatusSID = ps.PaymentStatusSID
		from
			dbo.PaymentStatus ps
		where
			ps.PaymentStatusSCD = 'APPROVED';

		if @paymentStatusSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotConfigured'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
			 ,@Arg1 = 'APPROVED payment status';

			raiserror(@errorText, 17, 1);
		end;

		select
			@glAccountCode = gla.GLAccountCode
		from
			dbo.GLAccount gla
		where
			gla.IsPAPAccount = @ON;

		if @glAccountCode is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotConfigured'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
			 ,@Arg1 = 'PAP bank account';

			raiserror(@errorText, 17, 1);
		end;

		-- load work table with the batch
		-- transactions to process

		insert
			@work (PAPTransactionSID)
		select
			pt.PAPTransactionSID
		from
			dbo.PAPTransaction pt
		where
			pt.PAPBatchSID = @PAPBatchSID and pt.IsRejected = @OFF and pt.PaymentSID is null and pt.WithdrawalAmount <> 0.00; -- avoid rejected and $0 payment records

		set @maxrow = @@rowcount;
		set @i = 0;
		set @processedTime = sysdatetimeoffset();

		begin transaction; -- handle all payments in the batch as a single transaction

		while @i < @maxrow and @isCancelled = @OFF
		begin

			set @i += 1;

			-- retrieve values to insert into new payment record

			select
				@papTransactionSID = w.PAPTransactionSID
			 ,@personSID				 = ps.PersonSID
			 ,@amountPaid				 = pt.WithdrawalAmount
			 ,@reference				 = 'PAP.' + @batchID + '.' + ltrim(pt.PAPTransactionSID)
			from
				@work								w
			join
				dbo.PAPTransaction	pt on w.PAPTransactionSID		= pt.PAPTransactionSID
			join
				dbo.PAPSubscription ps on pt.PAPSubscriptionSID = ps.PAPSubscriptionSID
			where
				w.ID = @i;

			if @JobRunSID is not null
			begin

				-- check if a cancellation request occurred
				-- where job is running in async mode

				if exists
				(
					select
						1
					from
						sf.JobRun jr
					where
						jr.CancellationRequestTime is not null and jr.JobRunSID = @JobRunSID
				)
				begin
					set @isCancelled = @ON;
				end;

				set @currentProcessLabel = cast('Processing trx#' + ltrim(@papTransactionSID) as nvarchar(35));
				set @recordsProcessed = @i - 1;

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@CurrentProcessLabel = @currentProcessLabel
				 ,@RecordsProcessed = @recordsProcessed
				 ,@TotalRecords = @maxrow
				 ,@IsCancelled = @isCancelled;

			end;

			-- if an unpaid renewal invoice exists for the person
			-- the PAP payment is being made for, pass that to the
			-- #insert to have the payment automatically applied

			set @invoiceSID = null

			select
				@invoiceSID = x.InvoiceSID
			from
			(
				select
					max(i.InvoiceSID) InvoiceSID -- in case more than one renewal invoice, take latest
				from
					dbo.Invoice						i
				join
					dbo.RegistrantRenewal rnw on i.InvoiceSID = rnw.InvoiceSID -- only renewal invoices considered
				where
					i.PersonSID = @personSID
			) x
			outer apply dbo.fInvoice#Total(x.InvoiceSID) it
			where
				it.TotalDue > 0.00 -- an amount must be owing on it			

			-- insert the payment and write the new
			-- payment key back into the PAP transaction

			exec dbo.pPayment#Insert
				@PaymentSID = @paymentSID output
			 ,@PersonSID = @personSID
			 ,@PaymentTypeSID = @paymentTypeSID
			 ,@PaymentStatusSID = @paymentStatusSID
			 ,@GLAccountCode = @glAccountCode
			 ,@GLPostingDate = @glPostingDate
			 ,@DepositDate = @depositDate
			 ,@AmountPaid = @amountPaid
			 ,@Reference = @reference
			 ,@InvoiceSID = @invoiceSID;

			exec dbo.pPAPTransaction#Update
				@PAPTransactionSID = @papTransactionSID
			 ,@PaymentSID = @paymentSID;

		end;

		if @isCancelled = @ON
		begin
			rollback; -- undo pending transactions on cancellation
		end;
		else
		begin

			commit; -- not-cancelled, no errors 

			-- update the batch header with the processed time
			-- and the lock time if not already set

			if @lockedTime is null
			begin
				set @lockedTime = @processedTime;
			end;

			exec dbo.pPAPBatch#Update
				@PAPBatchSID = @PAPBatchSID
			 ,@LockedTime = @lockedTime
			 ,@ProcessedTime = @processedTime;

		end;

		if @JobRunSID is not null and @isCancelled = @OFF
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'JobCompletedSucessfully'
			 ,@MessageText = @resultMessage output
			 ,@DefaultText = N'The %1 job was completed successfully.'
			 ,@Arg1 = 'PAP Batch Processing';

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @maxrow
			 ,@TotalErrors = 0
			 ,@RecordsProcessed = @maxrow
			 ,@ResultMessage = @resultMessage;

		end;

		if @ReturnDataSet = @ON
		begin
			select @i	 RecordCount; -- return data set with total processed where requested
		end;

	end try
	begin catch

		if @JobRunSID is not null
		begin

			if @@trancount > 0 rollback; -- roll back any pending trx so that update can succeed

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'JOB.FAILED'
			 ,@TermLabel = @termLabel output
			 ,@DefaultLabel = N'*** JOB FAILED'
			 ,@UsageNotes = N'A label reporting failure of jobs (normally accompanied by error report text from the database).';

			set @errorText = @termLabel + char(13) + char(10) + error_message();

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@ResultMessage = @errorText
			 ,@IsFailed = @ON;

		end;

		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
