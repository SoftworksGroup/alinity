SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pGLTransaction#Repost
	@StartDate	date = null --  the payment creation date from which to start reposting - (required!)
 ,@Payments		xml = null	-- list of payment SID values to repost (see format in Comments below)
 ,@JobRunSID	int = null	-- job run id used for logging
 ,@DebugLevel int = 0			-- when > 0 debug statements to trace logic are sent to the console
as
/*********************************************************************************************************************************
Sproc    : GL Transaction - Repost
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure deletes and replaces GL Transactions for the start date forward
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- | ------------|---------------------------------------------------------------------------------------
				 : Tim Edlund				| Sep 2017 		| Initial version.
				 : Tim Edlund				| Jan 2018		| Updated documentation to clarify changed handling of cancelled payments.
				 : Tim Edlund				| Nov 2018		| Added support to assign new bank account number if old number was removed.
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This is a utility procedure for correcting errors or omissions in creation of GL Transaction records.  The payments to repost are
identified either by providing a starting date or a list of PaymentSID values (payment keys).  The keys must be passed in the XML 
parameter using the following format:

<Payments>
		<Payment SID="1003170" />
		<Payment SID="1000011" />
		<Payment SID="1000123" />
</Payments> 

When a start date is provided it is used to select payments created on or after that date.  The starting date is expected to be in 
the client timezone and is compared to the CreateTime (adjusted for CTZ).  

The procedure begins by DELETING existing GL Transactions for the selected payment records.  GL Posting transactions 
(dbo.GLTransaction) are then recreated for those payments. Any transactions previously not-posted or posted in error due 
to technical failures or design errors on the selected payments are created.

NOTE: Running this procedure may change results of GL exports previously sent to external GL's. Previously entered/exported 
transactions in the external GL must be reviewed and updated as required. Use "GL Reports" provided in the application.

Selection of the GL Posting Date
--------------------------------
The GL Posting date is established automatically by the procedure. The date is set differently depending on the type of payment.

a) For Credit/Debit card payments the GL Posting Date is based on the last verified time. The "Verified" time is provided by the 
card processor when payment is successful. This value is reset by through this routine to the most recent response time on the 
dbo.PaymentProcessorResponse table. The date/time value is parsed from the XML where provided by the card processor but is 
otherwise set to the CreateTime on that record.  The GL Posting Date derived is written to the GLPostingDate column in the
dbo.Payment record.  Note that if the verified time is not correct for a transaction, the user can correct it by editing
the payment record in the Payment Management screen.  These edits must be completed before running this utility.

b) For manual forms of payment (e.g. checks, cash, money orders, etc.) the GL Posting Date is obtained from the dbo.Payment
record. The system automatically set this value to the create time (converted to CTZ).  It can be edited through the Payment 
Management screen directly if it is not correct.

The actual date value is obtained from the view "dbo.vPayment#DateReconciliation".  See also the view documentation for details.

Posting for Cancelled Payments
------------------------------
If a payment was entered, posted but is later cancelled, this procedure will NOT create transactions for it.  IF the original
and reversing entries resulting from the initial postings where transferred manually to an external GL, these transactions
will NOT to continue to exist as a result of this procedure.

Error Checking
--------------
Before the utility will repost an on-line payment record, it first checks that there is agreement between the paid status
and amount paid on the dbo.Payment record and the paid status and charge amount on the last response from the card 
processor. If an error is detected, the reposting process stops - saving what it has done to that point - but requiring
the user to resolve the error through manual editing (typically Cancelling and re-entering) before continuing.

Example
-------

<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Execute procedure sychronously for a recent (last 100 records) 
	start date selected at random.">
    <SQLScript>
      <![CDATA[
declare @startDate date 

select top (1)
	@startDate = x.GLPostingDate
from
(
	select top (100)
		gt.GLPostingDate
	from
		dbo.GLTransaction gt
	order by
		gt.GLPostingDate desc
) x
order by
	newid()
  
if @@rowcount = 0 or @startDate is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pGLTransaction#Repost
		@StartDate = @startDate
	 ,@DebugLevel = 1;

end;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>

  <Test Name = "CheckDates" Description="Execute procedure for a FULL repost starting after the lockout period, and, showing
	 date reconciliation view after the call (no debug)">
    <SQLScript>
      <![CDATA[
declare @startDate date 

set @startDate = cast(isnull(sf.fConfigParam#Value('AcctgTrxLockedDate'), '20000101') as date);
  
if @startDate is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	set @startDate = dateadd(day, 1, @startDate) -- start at beginning of open period

  exec dbo.pGLTransaction#Repost
	  @StartDate = @startDate	

  select
	  pdr.PaymentTypeLabel
   ,pdr.DepositAccount
   ,pdr.RegistrantLabel
   ,pdr.PaymentID
   ,pdr.TransactionID
   ,pdr.EnteredDate
   ,pdr.GLPostingDate
   ,pdr.DefaultGLPostingDate
   ,pdr.LatestVerifiedTime
   ,pdr.IsPaid
   ,pdr.LatestIsPaid
   ,pdr.AmountPaid
   ,pdr.LatestChargeTotal
   ,ltrim((case when pdr.PaidStatusComment <> 'ok' then pdr.PaidStatusComment else '' end)
	  + (case when pdr.GLPostingDateComment <> 'ok' then char(13) + char(10) + pdr.GLPostingDateComment else '' end)
	  + (case when pdr.DepositDateComment <> 'ok' then char(13) + char(10) + pdr.DepositDateComment else '' end)
	  + (case when pdr.VerifiedTimeComment <> 'ok' then char(13) + char(10) + pdr.VerifiedTimeComment else '' end)) Comments
  from
	  dbo.vPayment#DateReconciliation pdr

end;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>  
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pGLTransaction#Repost'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						 int							 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					 nvarchar(4000)																							-- message text for business rule errors
	 ,@ON									 bit							 = cast(1 as bit)													-- constant for bit comparisons = 1
	 ,@OFF								 bit							 = cast(0 as bit)													-- constant for bit comparison = 0
	 ,@updateUser					 nvarchar(75)			 = sf.fApplicationUserSession#UserName()	-- user running the procedure
	 ,@startTime					 datetimeoffset(7) = sysdatetimeoffset()										-- track start time of this procedure
	 ,@acctgTrxLockedDate	 date																												-- configuration setting controlling how far back re-post can start
	 ,@paymentSID					 int																												-- key of next payment to process
	 ,@postingDate				 date																												-- next posting date
	 ,@i									 int																												-- loop iteration counter
	 ,@maxrow							 int																												-- loop limit
	 ,@termLabel					 nvarchar(35)																								-- buffer for configurable label text
	 ,@isCancelled				 bit							 = cast(0 as bit)													-- checks for cancellation request on async job calls  
	 ,@currentProcessLabel nvarchar(35)																								-- label for stage of work
	 ,@resultMessage			 nvarchar(4000);																						-- summary of job result

	declare @work table
	(
		ID						int	 not null identity(1, 1)
	 ,PaymentSID		int	 not null
	 ,GLPostingDate date null
	);

	begin try

		if isnull(@JobRunSID, 0) > 0 set @DebugLevel = 0;

		if @JobRunSID is not null -- if call is async, update the job run record
		begin

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'JOBSTATUS.INPROCESS'
			 ,@TermLabel = @termLabel output
			 ,@DefaultLabel = N'In Process'
			 ,@UsageNotes = N'Indicates the job is currently running, or appears to be running because no completion time or failure was reported.';

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@CurrentProcessLabel = @termLabel;

		end;

		if @StartDate is null and @Payments is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@StartDate/@Payments';

			raiserror(@errorText, 18, 1);

		end;

		-- ensure start date does not hit locked period

		set @acctgTrxLockedDate = cast(isnull(sf.fConfigParam#Value('AcctgTrxLockedDate'), '20000101') as date);

		if @StartDate <= @acctgTrxLockedDate
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'PeriodIsLocked'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 date provided "%2" is invalid because the accounting period is locked. The locked period ends: %3.'
			 ,@Arg1 = 'start'
			 ,@Arg2 = @StartDate
			 ,@Arg3 = @acctgTrxLockedDate;

			raiserror(@errorText, 18, 1);

		end;

		-- ensure unapplied account exists 

		if not exists (select 1 from dbo .GLAccount ga where ga.IsUnappliedPaymentAccount = @ON)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'InvalidGLConfiguration'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The GL Account configuration is incomplete: the "%1" is missing.'
			 ,@Arg1 = 'Unapplied Payment Account';

			raiserror(@errorText, 17, 1);

		end;

		if @Payments is not null
		begin

			insert
				@work -- parse XML key values into table for processing
			(PaymentSID)
			select
				Payment.p.value('@SID', 'int')
			from
				@Payments.nodes('//Payment') Payment(p);

		end;
		else if @StartDate is not null
		begin

			insert
				@work (PaymentSID)
			select
				p.PaymentSID
			from
				dbo.Payment p
			where
				sf.fDTOffsetToClientDate(p.CreateTime) >= @StartDate and p.CreateTime < @startTime; -- avoid deleting transactions added since this sproc started

		end;

		set @maxrow = @@rowcount;

		-- update the verified times and posting dates for online payments
		-- where they don't agree with latest time from processor

		update
			p
		set
			p.VerifiedTime = pdr.LatestVerifiedTime
		 ,p.GLPostingDate = pdr.DefaultGLPostingDate											-- see the PDR view for details on default date calculations
		 ,p.DepositDate = pdr.DefaultDepositDate
		 ,p.GLAccountCode = isnull(ga.GLAccountCode, gaDef.GLAccountCode) -- re-assign to current code if old code was removed
		 ,p.UpdateUser = @updateUser
		 ,p.UpdateTime = sysdatetimeoffset()
		from
			dbo.Payment											p
		join
			@work														w on p.PaymentSID				 = w.PaymentSID
		join
			dbo.vPayment#DateReconciliation pdr on p.PaymentSID			 = pdr.PaymentID -- the view only includes Paid transactions!
		join
			dbo.PaymentType									pt on p.PaymentTypeSID	 = pt.PaymentTypeSID
		join
			dbo.GLAccount										gaDef on pt.GLAccountSID = gaDef.GLAccountSID -- use a new bank account if pre-existing account is not found
		left outer join
			dbo.GLAccount										ga on p.GLAccountCode		 = ga.GLAccountCode	 -- check if account is valid
		where
			sf.fIsDifferent(p.VerifiedTime, pdr.LatestVerifiedTime)				= @ON
			or sf.fIsDifferent(p.DepositDate, pdr.DefaultDepositDate)			= @ON
			or sf.fIsDifferent(p.GLPostingDate, pdr.DefaultGLPostingDate) = @ON
			or ga.GLAccountCode is null;

		set @i = @@rowcount;

		if @DebugLevel > 0
		begin
			print 'ok - ' + ltrim(@i) + ' date/time reset';
		end;

		-- update the GL Posting date in the work table

		update
			w
		set
			w.GLPostingDate = (case when ps.IsPaid = @OFF then null else p.GLPostingDate end)
		from
			@work							w
		join
			dbo.Payment				p on w.PaymentSID				 = p.PaymentSID
		join
			dbo.PaymentStatus ps on p.PaymentStatusSID = ps.PaymentStatusSID
		where
			sf.fIsDifferent(w.GLPostingDate, p.GLPostingDate) = @ON;

		if @DebugLevel > 1
		begin
			select w .ID, w.PaymentSID, w.GLPostingDate from @work w ;
		end;

		-- delete the previous GL transactions for the selected payments

		delete
		gt
		from
			dbo.GLTransaction gt
		join
			@work							w on gt.PaymentSID = w.PaymentSID
		where
			gt.PaymentSID = w.PaymentSID; -- redundant where clause added to avoid warning from SQL Prompt

		set @i = @@rowcount;

		if @DebugLevel > 0
		begin
			print 'ok - ' + ltrim(@i) + ' GL Transactions deleted';
		end;

		if @DebugLevel > 0
		begin
			select w .ID, w.PaymentSID, w.GLPostingDate from @work w ;
		end;

		-- now reprocess the GL transactions for these
		-- payments; all will be NEW so process as if inserted

		set @i = 0;

		while @i < @maxrow
		begin

			set @i += 1;

			select
				@paymentSID	 = w.PaymentSID
			 ,@postingDate = w.GLPostingDate
			from
				@work w
			where
				w.ID = @i;

			-- check if a cancellation request occurred
			-- where job is running in async mode

			if @JobRunSID is not null and (@i = 1 or @i % 100 = 0) -- update on first record then every 100
			begin

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

				set @currentProcessLabel = cast('Processing payment #' + ltrim(@paymentSID) as nvarchar(35));

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@CurrentProcessLabel = @currentProcessLabel
				 ,@RecordsProcessed = @i
				 ,@TotalRecords = @maxrow
				 ,@IsCancelled = @isCancelled;

			end;

			if @postingDate is not null -- if the posting date is null it is in a non-paid status and can be skipped
			begin

				-- post the payment header; routine calls
				-- #PostInvoicePayment to post the details

				exec dbo.pGLTransaction#PostPayment
					@PaymentSID = @paymentSID
				 ,@ActionCode = 'INSERT'
				 ,@PostingDate = @postingDate;

			end;

		end;

		if @DebugLevel > 0
		begin

			select
				gt.GLTransactionSID
			 ,gt.PaymentSID
			 ,gt.InvoicePaymentSID
			 ,gt.DebitGLAccountCode
			 ,gt.FullDebitAccountLabel
			 ,gt.CreditGLAccountCode
			 ,gt.FullCreditAccountLabel
			 ,gt.IsReversing
			 ,gt.IsReversed
			 ,gt.Amount
			 ,gt.GLPostingDate
			 ,gt.PaymentCheckSum
			 ,gt.InvoicePaymentCheckSum
			 ,gt.ReversedGLTransactionSID
			 ,gt.AmountPaid
			 ,gt.AmountApplied
			 ,gt.CreateTime
			from
				dbo.vGLTransaction gt
			join
				@work							 w on gt.PaymentSID = w.PaymentSID
			order by
				gt.GLTransactionSID;

		end;

		if @JobRunSID is not null and @isCancelled = @OFF
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'JobCompletedSucessfully'
			 ,@MessageText = @resultMessage output
			 ,@DefaultText = N'The %1 job was completed successfully.'
			 ,@Arg1 = 'GL Repost';

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @maxrow
			 ,@TotalErrors = 0
			 ,@RecordsProcessed = @maxrow
			 ,@ResultMessage = @resultMessage;

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
