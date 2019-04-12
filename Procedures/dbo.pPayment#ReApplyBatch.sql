SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPayment#ReApplyBatch
	@JobRunSID	int = null	-- job run id used for logging
 ,@DebugLevel int = 0			-- when 1 debug output is sent to console
as

/*********************************************************************************************************************************
Sproc    : Payment - Reapply (to invoices) Batch
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure runs the payment #Reapply process on all payments where applied amount does not agree with paid amount
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Nov 2017		|	Initial version
					: Tim Edlund	| May 2018		| Corrected error where @i not updated when not called asynchronously

Comments	
--------
This procedure is called to clean-up payment records where the amount paid has gone out of sync with the total amount of the
payment.  The procedure processes all payment records requiring updates.  The update is applied through the subroutine:
dbo.pPayment#Reapply. Because payment amounts may be changing, the procedure all calls the GL Repost procedure on each affected
payment.

The criteria for selecting payments to process is documented in the code below.

The @DebugLevel parameter can be passed when called from development tools to list the payments to be processed to the console.

LIMITATIONS
-----------
The procedure makes the call for payment GL reposting after each #ReApply process succeeds. The GL reposting step could be 
completed more quickly if an XML document of all payments were processed at the end, however, if the process fails the list of 
payments that require GL reposting would be lost.  For this reason, the process should be called directly from SSMS by the 
help desk or launched as back-end process to avoid timing out.

Example
-------
<TestHarness>
  <Test Name = "Basic" IsDefault ="true" Description="Executes the procedure synchronously to repost all payments where applied amount does not agree with paid amount.">
    <SQLScript>
      <![CDATA[
exec dbo.pPayment#ReApplyBatch
  ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:10:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pPayment#ReApplyBatch'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
begin

	set nocount on;

	declare
		@errorNo						 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					 nvarchar(4000)									-- message text for business rule errors
	 ,@ON									 bit					 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF								 bit					 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@i									 int														-- loop iteration counter
	 ,@maxrow							 int														-- loop limit
	 ,@payments						 xml														-- document to provide payment key in for GL reposting
	 ,@paymentSID					 int														-- next payment to process
	 ,@recordsProcessed		 int														-- count of records processed in the job
	 ,@termLabel					 nvarchar(35)										-- buffer for configurable label text
	 ,@isCancelled				 bit					 = cast(0 as bit) -- checks for cancellation request on async job calls  
	 ,@currentProcessLabel nvarchar(35)										-- label for stage of work
	 ,@resultMessage			 nvarchar(4000);								-- summary of job result

	declare @work table
	(
		ID							 int						identity(1, 1)
	 ,PaymentSID			 int						not null
	 ,RegistrantLabel	 nvarchar(75)		not null
	 ,AmountPaid			 decimal(11, 2) not null
	 ,TotalApplied		 decimal(11, 2) not null
	 ,PaymentStatusSCD varchar(25)		not null
	);

	begin try

		if isnull(@JobRunSID, 0) > 0 set @DebugLevel = 0;

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

		-- load work table with payments where repost is required:
		-- amount paid does not agree with amount applied, or,
		-- amount applied > 0 on cancelled/declined payment
		-- AND, at least one application of the payment exists

		insert
			@work
		(
			PaymentSID
		 ,RegistrantLabel
		 ,AmountPaid
		 ,TotalApplied
		 ,PaymentStatusSCD
		)
		select
			p.PaymentSID
		 ,p.RegistrantLabel
		 ,p.AmountPaid
		 ,p.TotalApplied
		 ,p.PaymentStatusSCD
		from
			dbo.vPayment p
		where
			(
				(
					p.TotalApplied						<> p.AmountPaid -- not paid
					and p.PaymentStatusSCD		<> 'CANCELLED' -- not cancelled
					and p.PaymentStatusSCD		<> 'DECLINED' -- not declined
				) or
					(
						p.TotalApplied					> 0.00 -- partially paid
						and
						(
							p.PaymentStatusSCD		= 'CANCELLED' -- is cancelled
							or p.PaymentStatusSCD = 'DECLINED' -- is declined
						)
					)
			) and exists
		(
			select
				1
			from
				dbo.InvoicePayment ip
			where
				ip.PaymentSID = p.PaymentSID and ip.CancelledTime is null -- AND at least 1 application of the payment exists that is not cancelled
		)
		order by
			p.PaymentSID;

		set @maxrow = @@rowcount;
		set @i = 0;

		if @DebugLevel > 0 -- if debug output is requested, list records to be modified
		begin

			select
				w.RegistrantLabel
			 ,w.PaymentSID
			 ,w.AmountPaid
			 ,w.TotalApplied
			 ,w.PaymentStatusSCD
			from
				@work w
			order by
				w.ID;

		end;

		-- process all payments in the work table

		while @i < @maxrow and @isCancelled = @OFF
		begin

			set @i += 1;
			select @paymentSID = w .PaymentSID from @work w where w.ID = @i;

			-- if an async call, update the processing label but not the 
			-- record count prior to calling the verification

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

				set @currentProcessLabel = cast('Processing payment #' + ltrim(@paymentSID) as nvarchar(35));
				set @recordsProcessed = @i - 1;

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@CurrentProcessLabel = @currentProcessLabel
				 ,@RecordsProcessed = @recordsProcessed
				 ,@TotalRecords = @maxrow
				 ,@IsCancelled = @isCancelled;

			end;

			exec dbo.pPayment#ReApply -- call subroutine to reapply the payment
				@PaymentSID = @paymentSID;

			set @payments = N'<Payments><Payment SID="' + ltrim(@paymentSID) + '" /></Payments>';

			exec dbo.pGLTransaction#Repost
				@Payments = @payments;

		end;

		if @JobRunSID is not null and @isCancelled = @OFF
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'JobCompletedSucessfully'
			 ,@MessageText = @resultMessage output
			 ,@DefaultText = N'The %1 job was completed successfully.'
			 ,@Arg1 = 'Re-Apply Payment Batch';

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
