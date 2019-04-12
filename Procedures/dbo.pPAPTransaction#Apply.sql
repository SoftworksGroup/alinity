SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPAPTransaction#Apply
	@PAPSubscriptionSID int = null	-- optional - can be used to restrict payment applications to a single PAP subscriber
 ,@JobRunSID					int = null	-- sf.JobRun record to update on asynchronous calls
 ,@ReturnDataSet			bit = 0			-- when 1 a single record data set is returned summarizing results of process
 ,@DebugLevel					int = 0			-- when 1 or higher debug output is written to console
as
/*********************************************************************************************************************************
Sproc    : PAP (pre-authorized payment) Payment Application Process
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure applies payments creates invoice-payment records for a batch of pre-authorized payments
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2017		|	Initial version
				: Tim Edlund					| Mar 2018		| Updated to restrict to renewal invoices (other invoices cannot be paid through PAP!)
				: Tim Edlund					| Nov 2018		| Updated to support asynchronous calls (@JobSID introduced)

Comments	
--------
This procedure is called from the PAP transaction management screen on the user interface. The procedure searches for payments 
created from PAP transactions which are fully or partially unapplied.  The procedure then searches for renewal invoices which are 
not paid for those individuals and applies the payment to them. Only renewal invoices are paid by this procedure!

When applying payments for all PAP subscribers, no parameters are required. To restrict the application of payments to a 
single subscriber, pass the key of that subscription. 

The @ReturnDataSet parameter provides a result for display in the UI.  Pass as 1 (ON) and a 1 record data set is returned 
providing a message that summarizes the process.

The process is restricted to pay for renewal invoices.  The registrant makes PAP payments throughout the year and then
once the final PAP payment has been received, the process is run to pay the renewal invoice - and thereby completing the
renewal process and generating the registration for the new year.  The process can be run multiple times - each time 
picking up new renewal invoices that may have been generated since the last time the process was run. The procedure is
also called directly through the renewal #Approve procedure so that the new registration record is generated immediately
upon completion of the renewal payment.  This makes the permit immediately available for printing from the member portal.

The posting of the applied payments to the GL is handled through the EF sproc: dbo.pInvoicePayment#Insert which is called
by this procedure.

The procedure does not create dbo.Payment records.  Those records must already exist when this process is called.  The
creation of payments is carried out by a separate procedure: dbo.pPAPBatch#Process.

Example
-------
<TestHarness>
  <Test Name = "Sync" IsDefault ="true" Description="Executes the procedure with a synchronous call (no job) for 1 subscriber (Updates are rolled back after test).">
    <SQLScript>
      <![CDATA[

declare @papSubscriptionSID int;

select
	@papSubscriptionSID = papt.PAPSubscriptionSID
from
	dbo.PAPTransaction												 papt
join
	dbo.Payment																 p on papt.PaymentSID = p.PaymentSID
cross apply dbo.fPayment#Total(p.PaymentSID) ptot
where
	ptot.TotalUnapplied > 0.00;

if @@rowcount = 0 or @papSubscriptionSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pPAPTransaction#Apply
		@PAPSubscriptionSID = @papSubscriptionSID
	 ,@ReturnDataSet = 1
	 ,@DebugLevel = 1;

	if @@trancount > 0 -- rollback the updates from the test
	begin
		rollback;
	end;

end;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:05:00"/>
    </Assertions>
  </Test>
  <Test Name = "ASync" Description="Executes the procedure with an asynchronous call">    
		<SQLScript>
      <![CDATA[
	exec sf.pJob#Call @JobSCD = 'dbo.pPAPTransaction#Apply';

	waitfor delay '00:00:03';

	select
		jr.JobSCD
	 ,jr.CurrentProcessLabel
	 ,jr.JobStatusSCD
	 ,jr.EstimatedMinutesRemaining
	 ,jr.TotalRecords
	 ,jr.RecordsProcessed
	 ,jr.TotalErrors
	 ,jr.RecordsRemaining
	 ,jr.EstimatedMinutesRemaining
	 ,jr.RecordsPerMinute
	 ,jr.DurationMinutes
	 ,jr.ResultMessage
	 ,jr.TraceLog
	from
		sf.vJobRun jr
	where
		jr.JobRunSID =
	(
		select top (1)
			jr.JobRunSID
		from
			sf.vJobRun jr
		where
			jr.JobSCD = 'dbo.pPAPTransaction#Apply'
		order by
			jr.JobRunSID desc
	);

	select
		jre.DataSource
	 ,jre.MessageText
	from
		sf.JobRunError jre
	where
		jre.JobRunSID =
	(
		select top (1)
			jr.JobRunSID
		from
			sf.vJobRun jr
		where
			jr.JobSCD = 'dbo.pPAPTransaction#Apply'
		order by
			jr.JobRunSID desc
	)
	order by
		jre.JobRunErrorSID;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:10:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pPAPTransaction#Apply'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						 int					 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					 nvarchar(4000)													-- message text for business rule errors
	 ,@procName						 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@ON									 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@OFF								 bit					 = cast(0 as bit)					-- constant for bit comparison = 0
	 ,@i									 int																		-- loop iteration counter
	 ,@maxrow							 int																		-- loop limit
	 ,@paymentSID					 int																		-- key of next payment record to process
	 ,@personSID					 int																		-- key of person to search invoices for
	 ,@invoiceSID					 int																		-- next invoice to apply payment to
	 ,@glPostingDate			 date					 = sf.fToday()						-- date GL transactions will be posted on
	 ,@remainingToApply		 decimal(11, 2)													-- total amount of the payment yet to be applied
	 ,@amountApplied			 decimal(11, 2)													-- amount to apply to next invoice
	 ,@countApplied				 int					 = 0											-- counter of payments applied in the process
	 ,@recordsProcessed		 int																		-- count of records processed
	 ,@resultMessage			 nvarchar(4000)													-- summary of job result
	 ,@isCancelled				 bit					 = cast(0 as bit)					-- checks for cancellation request on async job calls 
	 ,@currentProcessLabel nvarchar(35);													-- label for stage of work

	declare @work table (ID int identity(1, 1), PaymentSID int not null);

	begin try

		if @DebugLevel is null set @DebugLevel = 0;

		if @@trancount > 0 and @DebugLevel = 0 and @JobRunSID is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'TransactionPending'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A transaction was started prior to calling this procedure. Procedure "%1" does not allow nested transactions.'
			 ,@Arg1 = @procName;

			raiserror(@errorText, 18, 1);

		end;

		if @JobRunSID is not null -- if call is async, update the job run record
		begin

			set @ReturnDataSet = 0;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@CurrentProcessLabel = N'Retrieving configuration ...';

		end;

-- SQL Prompt formatting off
		if @ReturnDataSet is null set @ReturnDataSet = @OFF
-- SQL Prompt formatting on

		-- load work table with unapplied payments created based
		-- on PAP transactions

		insert
			@work (PaymentSID)
		select
			papt.PaymentSID
		from
			dbo.PAPTransaction												 papt
		join
			dbo.Payment																 p on papt.PaymentSID = p.PaymentSID
		cross apply dbo.fPayment#Total(p.PaymentSID) ptot
		where
			papt.PAPSubscriptionSID = isnull(@PAPSubscriptionSID, papt.PAPSubscriptionSID) -- parameter can be used to filter subscribers to include
			and ptot.TotalUnapplied > 0.00;

		set @maxrow = @@rowcount;
		set @i = 0;

		-- process each unapplied payment

		while @i < @maxrow and @isCancelled = @OFF
		begin

			set @i += 1;

			select
				@paymentSID				= w.PaymentSID				-- get next payment to process
			 ,@personSID				= p.PersonSID					-- owner of the payment (determines invoices to search for)
			 ,@remainingToApply = ptot.TotalUnapplied -- remaining amount to apply
			from
				@work																			 w
			join
				dbo.Payment																 p on w.PaymentSID = p.PaymentSID
			cross apply dbo.fPayment#Total(p.PaymentSID) ptot
			where
				w.ID = @i;

			set @currentProcessLabel = N'Processing: ' + ltrim(@paymentSID) + N' ...';

			-- if an async call, update the processing label

			if @JobRunSID is not null and (@i = 1 or @i % 50 = 0)
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

				set @recordsProcessed = @i - 1;

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@TotalRecords = @maxrow
				 ,@RecordsProcessed = @recordsProcessed
				 ,@TotalErrors = 0
				 ,@CurrentProcessLabel = @currentProcessLabel
				 ,@IsCancelled = @isCancelled;

			end;

			if @isCancelled = @OFF
			begin

				if @DebugLevel > 1 -- show process label if debugging
				begin
					print @currentProcessLabel;
				end;

				-- now look for invoices for this person which are unpaid

				set @invoiceSID = -1;

				while @invoiceSID is not null and @remainingToApply > 0.00
				begin

					select top (1)
						@invoiceSID		 = i.InvoiceSID
					 ,@amountApplied = (case when itot.TotalDue <= @remainingToApply then itot.TotalDue else @remainingToApply end)
					from
						dbo.Invoice																 i
					cross apply dbo.fInvoice#Total(i.InvoiceSID) itot
					join
						dbo.RegistrantRenewal rr on i.InvoiceSID = rr.InvoiceSID	-- renewal invoices only!
					where
						i.PersonSID = @personSID and itot.TotalDue > 0 and i.InvoiceSID > @invoiceSID
					order by
						i.InvoiceSID;

					if @@rowcount = 0
					begin
						set @invoiceSID = null; -- no more to process - exit and go to next payment
					end;
					else
					begin

						exec dbo.pInvoicePayment#Insert -- insert the applied payment
							@InvoiceSID = @invoiceSID
						 ,@PaymentSID = @paymentSID
						 ,@AmountApplied = @amountApplied
						 ,@GLPostingDate = @glPostingDate;

						set @countApplied += 1; -- increment counter for output message
						set @remainingToApply -= @amountApplied; -- reduce the amount yet to be applied

					end;
				end;
			end;
		end;

		-- update job with final totals for actually records processed
		-- and errors encountered

		if @JobRunSID is not null and @isCancelled = @OFF
		begin

			if @maxrow = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NoRecordsToProcess'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'Warning: No records were found to process. Configuration updates may be required.';

			end;
			else
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'JobCompletedSucessfully'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'The %1 job was completed successfully.'
				 ,@Arg1 = 'Apply Pre-Authorized Payments';

			end;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @maxrow
			 ,@RecordsProcessed = @i
			 ,@TotalErrors = 0
			 ,@ResultMessage = @resultMessage;

		end;

		if @ReturnDataSet = @ON
		begin
			select @countApplied RecordCount ;
		end;

	end try
	begin catch

		if isnull(@JobRunSID, 0) = 0 and @DebugLevel > 0
		begin
			if @DebugLevel = 1 print @currentProcessLabel;
			print (error_message());
		end;

		-- if the procedure is running asynchronously record the
		-- error, else re-throw it to end processing

		if isnull(@JobRunSID, 0) > 0
		begin

			set @resultMessage = N'JOB FAILED: ' + error_message();

			insert
				sf.JobRunError (JobRunSID, MessageText, DataSource, RecordKey)
			select
				@JobRunSID
			 ,N'* ERROR: ' + error_message()
			 ,'Payment'
			 ,isnull(ltrim(@paymentSID), 'NULL');

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @maxrow
			 ,@RecordsProcessed = @i
			 ,@TotalErrors = 1
			 ,@IsFailed = @ON
			 ,@ResultMessage = @resultMessage;

		end;

		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
