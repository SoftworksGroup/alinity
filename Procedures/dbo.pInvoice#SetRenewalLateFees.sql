SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pInvoice#SetRenewalLateFees
	@RegistrationYear smallint = null				-- renewal year to set late fees for (defaults to next registration year)
 ,@JobRunSID				int = null						-- sf.JobRun record to update on asynchronous calls
 ,@MinimumDue				decimal(11, 2) = 1.00 -- minimum amount due before late fees will be applied
 ,@AddLateFees			bit = 1								-- indicates whether adding missing late fees should occur
 ,@RemoveLateFees		bit = 0								-- indicates whether removing pre-existing late fees should occur
 ,@TotalRecordCount int = null output			-- count of invoices updated with late fees
 ,@TotalErrorCount	int = null output			-- count of errors encountered
 ,@ReturnSelect			bit = 0								-- when 1 output values are returned as a dataset
 ,@DebugLevel				tinyint = 0						-- values > 0 cause work table contents and other values to print to console (back-end testing only)
as
/*********************************************************************************************************************************
Sproc    : Invoice - Set Renewal Late Fees
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure updates existing unpaid invoices to add or remove renewal late fees
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Tim Edlund				| Sep 2017 	 | Initial version
				 : Tim Edlund				| Mar 2018	 | Added support for late fee exclusion year and Catalog Item model components
				 : Tim Edlund				| Nov 2018	 | Updated to support asynchronous calling
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
Late fees are added automatically when invoices are created according to the late-fee-start-time in effect on the schedule at
the time the invoices is generated.  If invoices is generated before the late fee kicks in, but that invoice is not paid until
after the late fee takes effect, the late fee may need to be added to the already created invoice.  

This procedure adds missing late fees to renewal invoices which are unpaid, and which do not have late fees applied either because
they were generated before the late fee start time, or, the late fees were not configured until after the invoices were generated.

The procedure can also be used to remove late fees where the late fee start time is changed (moved later). This usage is intended
primarily to support testing scenarios.

This procedure is typically scheduled as a batch job to run at midnight on the day the late fee comes into effect.  The procedure
can also be run manually from the utilities menu.

The add/remove actions can be individually controlled using the 2 parameter bits provided.  The procedure supports a minimum 
unpaid amount to use in modifying the invoices.  By default this is $1.  If an invoice is unpaid by less than the minimum amount
no action is taken.

If an invoice is partially paid it is INCLUDED in the list for adding missing late fees and still subject to selection if the 
amount that remains unpaid is >= @MinimumDue.

The procedure cannot assign late fees unless a Catalog Item has been configured for them. The procedure runs a check to ensure
at least one late fee is configured for the given registration year.  Note that if no late fees are added or removed no error
results as the procedure may be run multiple times and it is possible all actions have already been performed.

Exclusions
----------
An individual may receive an exclusion from late fees for a year using the LateFeeExclusionYear column in the dbo.Registrant 
table.

Limitations
-----------
The "remove" action of the procedure cannot delete invoice items where the configuration of the practice register fee has removed
that item.  Since there is no fee with the IsLateFee designator to compare to, the item cannot be deleted if removed from the
configuration.  Manual deletion is required with assistance from the help desk deleting based on invoice item description or the
RowGUID of the item removed from the late fee configuration.

Example
-------
<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Execute the procedure sychronously with default settings and a return data set.">
    <SQLScript>
      <![CDATA[
exec dbo.pInvoice#SetRenewalLateFees
	@ReturnSelect = 1
 --,@DebugLevel = 2;	-- NOTE: this debug level blocks any actual updates - use 0 or 1 to apply changes
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:02:00"/>
    </Assertions>
  </Test>  
  <Test Name = "ASync" Description="Executes the procedure with an asynchronous call">    
		<SQLScript>
      <![CDATA[
	exec sf.pJob#Call @JobSCD = 'dbo.pInvoice#SetRenewalLateFees';

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
			jr.JobSCD = 'dbo.pInvoice#SetRenewalLateFees'
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
			jr.JobSCD = 'dbo.pInvoice#SetRenewalLateFees'
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
	 @ObjectName = 'dbo.pInvoice#SetRenewalLateFees'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						 int					 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					 nvarchar(4000)													-- message text for business rule errors
	 ,@ON									 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@OFF								 bit					 = cast(0 as bit)					-- constant for bit comparison = 0
	 ,@procName						 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@invoiceSID					 int																		-- next invoice to process
	 ,@catalogItemSID			 int																		-- key of next late fee item to add/remove
	 ,@invoiceItemSID			 int																		-- key of next invoice line item to delete
	 ,@requiredAction			 varchar(10)														-- action to process add/remove late fee
	 ,@isCancelled				 bit					 = cast(0 as bit)					-- checks for cancellation request on async job calls  
	 ,@currentProcessLabel nvarchar(35)														-- label for stage of work
	 ,@lateFeeStartTime		 datetime																-- time the late fee applies for the registration year
	 ,@resultMessage			 nvarchar(4000)													-- summary of job result
	 ,@i									 int																		-- loop iteration counter
	 ,@maxrow							 int					 = 0											-- loop limit
	 ,@now								 datetime			 = sf.fNow();							-- current time in user timezone

	declare @work table
	(
		ID						 int				 not null identity(1, 1)
	 ,InvoiceSID		 int				 not null
	 ,CatalogItemSID int				 not null
	 ,InvoiceItemSID int				 null
	 ,RequiredAction varchar(10) not null
	 ,RegistrantSID	 int				 not null
	 ,RegistrantNo	 varchar(50) not null
	);

	-- ensure output parameters are set for all code paths

	set @TotalRecordCount = 0;
	set @TotalErrorCount = 0;

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @AddLateFees					is null set @AddLateFees = @ON;
		if @RemoveLateFees			is null set @RemoveLateFees = @OFF;
		if @MinimumDue					is null set @MinimumDue = 1.00;
		if @RegistrationYear		is null set @RegistrationYear = dbo.fRegistrationYear#Current() + 1
-- SQL Prompt formatting on

		if @DebugLevel is null set @DebugLevel = 0;

		if @@trancount > 0 and @DebugLevel = 0
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

			set @ReturnSelect = 0;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@CurrentProcessLabel = N'Retrieving configuration ...';

		end;

		if @AddLateFees = @ON and @RemoveLateFees = @ON
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'AddAndRemoveNotSupported'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'You cannot both ADD and REMOVE late fees in the same operation.  Choose one action and execute again to complete the other action.';

			raiserror(@errorText, 16, 1);

		end;

		if @AddLateFees = @ON
		begin

			select
				@lateFeeStartTime = rsy.RenewalLateFeeStartTime
			from
				dbo.RegistrationScheduleYear rsy
			where
				rsy.RegistrationYear = @RegistrationYear;

			if (@lateFeeStartTime is null or @lateFeeStartTime > @now)
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'LateFeeNotStarted'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The late fee has not started (scheduled to begin %1). No action taken.'
				 ,@Arg1 = @lateFeeStartTime;

				if @JobRunSID is not null
				begin
					set @resultMessage = N'The Renewal Late Fee job was completed successfully. ' + @errorText;
					set @maxrow = -1; -- set MaxRow to abort remaining processing
				end;
				else
				begin -- if running in foreground raise as user error
					raiserror(@errorText, 16, 1);
				end;
			end;
		end;

		if @maxrow <> -1 -- remaining logic is avoided if late fee is not yet in effect
		begin

			-- ensure 1 or more late fees are configured

			if not exists
			(
				select
					1
				from
					dbo.PracticeRegisterSection			prs
				join
					dbo.PracticeRegister						pr on prs.PracticeRegisterSID							 = pr.PracticeRegisterSID
				join
					dbo.RegistrationScheduleYear		rsy on pr.RegistrationScheduleSID					 = rsy.RegistrationScheduleSID and rsy.RegistrationYear = @RegistrationYear
				join
					dbo.PracticeRegisterCatalogItem prci on pr.PracticeRegisterSID						 = prci.PracticeRegisterSID -- include fees for this register
																									and prs.PracticeRegisterSectionSID = isnull(prci.PracticeRegisterSectionSID, prs.PracticeRegisterSectionSID) -- match section or section is not specified
				join
					dbo.CatalogItem									ci on prci.CatalogItemSID									 = ci.CatalogItemSID and ci.IsLateFee = @ON	 -- and only late fees
			)
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NoLateFeesConfigured'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'No late fees are configured in the catalog for the %1 registration year.'
				 ,@Arg1 = @RegistrationYear;

				raiserror(@errorText, 17, 1);
			end;

			-- populate a work table with unpaid renewal invoice keys 
			-- along with applicable late fee items and an action code

			insert
				@work
			(
				InvoiceSID
			 ,CatalogItemSID
			 ,InvoiceItemSID
			 ,RegistrantSID
			 ,RegistrantNo
			 ,RequiredAction
			)
			select
				rr.InvoiceSID
			 ,prci.CatalogItemSID
			 ,ii.InvoiceItemSID
			 ,rl.RegistrantSID
			 ,r.RegistrantNo
			 ,(case
					 when isnull(r.LateFeeExclusionYear, 0) = rr.RegistrationYear then 'NONE'
					 when ii.InvoiceItemSID is not null then 'DELETE'
					 when cs.FormStatusSCD <> 'APPROVED' then 'NONE' -- if invoice was setup in advance and form is not approved; don't add late fee
					 when rsy.RenewalLateFeeStartTime <= @now and ii.InvoiceItemSID is null then 'INSERT'
					 else 'NONE'
				 end
				)
			from
				dbo.RegistrantRenewal												rr
			join
				dbo.Registration														rl on rr.RegistrationSID = rl.RegistrationSID
			join
				dbo.Registrant															r on rl.RegistrantSID = r.RegistrantSID
			join
				dbo.PracticeRegisterSection									prs on rr.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			join
				dbo.PracticeRegister												pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
			join
				dbo.RegistrationScheduleYear								rsy on pr.RegistrationScheduleSID = rsy.RegistrationScheduleSID and rr.RegistrationYear = rsy.RegistrationYear
			join
				dbo.PracticeRegisterCatalogItem							prci on pr.PracticeRegisterSID = prci.PracticeRegisterSID -- include fees for this register
																														and prs.PracticeRegisterSectionSID = isnull(prci.PracticeRegisterSectionSID, prs.PracticeRegisterSectionSID) -- match section or section is not specified
			join
				dbo.CatalogItem															ci on prci.CatalogItemSID = ci.CatalogItemSID and ci.IsLateFee = @ON -- and only late fees
			cross apply dbo.fInvoice#Total(rr.InvoiceSID) it
			cross apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) cs
			left outer join
				dbo.InvoiceItem ii on rr.InvoiceSID = ii.InvoiceSID and prci.CatalogItemSID = ii.CatalogItemSID -- look for the late fee item already invoiced (even if $0)
			where
				rr.RegistrationYear = @RegistrationYear and it.TotalDue >= @MinimumDue;

			set @maxrow = @@rowcount;

			if @DebugLevel > 0
			begin

				select
					w.RegistrantNo
				 ,w.RegistrantSID
				 ,rr.RegistrationYear
				 ,rr.LastStatusChangeTime
				 ,rr.FormStatusSCD
				 ,w.InvoiceSID
				 ,i.TotalPaid
				 ,i.TotalDue
				 ,i.IsDeferred
				 ,i.IsPAPSubscriber
				 ,(case when isnull(r.LateFeeExclusionYear, 0) = rr.RegistrationYear then cast(1 as bit)else cast(0 as bit)end) IsLateFeeExcluded
				 ,w.CatalogItemSID
				 ,cast(isnull(w.InvoiceItemSID, 0) as bit)																																			IsLateFeeAssigned
				 ,w.RequiredAction
				from
					@work									 w
				join
					dbo.vRegistrantRenewal rr on w.InvoiceSID		 = rr.InvoiceSID
				join
					dbo.Registrant				 r on rr.RegistrantSID = r.RegistrantSID
				join
					dbo.vInvoice					 i on w.InvoiceSID		 = i.InvoiceSID
				order by
					w.RegistrantNo;

			end;

			set @i = 0;

			while @i < @maxrow and @isCancelled = @OFF
			begin

				select
					@i = min(w.ID)
				from
					@work w
				where
					w.ID								 > @i
					and w.RequiredAction <> 'NONE'
					and
					((w.RequiredAction	 = 'INSERT' and @AddLateFees = @ON) or (w.RequiredAction = 'DELETE' and @RemoveLateFees = @ON));

				if @@rowcount = 0 or @i is null
				begin
					set @i = @maxrow;
				end;
				else
				begin

					select
						@invoiceSID			= w.InvoiceSID
					 ,@catalogItemSID = w.CatalogItemSID
					 ,@invoiceItemSID = w.InvoiceItemSID
					 ,@requiredAction = w.RequiredAction
					from
						@work w
					where
						w.ID = @i;

					set @currentProcessLabel = N'Processing: ' + ltrim(@invoiceSID) + N' ...';

					-- if an async call update the processing label

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

						exec sf.pJobRun#Update
							@JobRunSID = @JobRunSID
						 ,@CurrentProcessLabel = @currentProcessLabel
						 ,@IsCancelled = @isCancelled;

					end;

					if @isCancelled = @OFF
					begin

						if @DebugLevel > 1 -- show process label if debugging
						begin
							print @currentProcessLabel;
						end;

						if @DebugLevel < 2 -- if debug level is set to 2 or higher, avoid making the updates
						begin

							begin try

								begin transaction;

								if @requiredAction = 'INSERT'
								begin

									exec dbo.pInvoiceItem#Insert
										@InvoiceSID = @invoiceSID
									 ,@CatalogItemSID = @catalogItemSID;

								end;
								else if @requiredAction = 'DELETE'
								begin

									exec dbo.pInvoiceItem#Delete
										@InvoiceItemSID = @invoiceItemSID;

								end;

								set @TotalRecordCount += 1;

								commit;

							end try
							begin catch

								set @TotalErrorCount += 1;
								set @TotalRecordCount += 1;

								if @@trancount > 0 rollback; -- rollback the last transaction to allow the error to be logged

								if isnull(@JobRunSID, 0) = 0 and @DebugLevel > 0
								begin
									if @DebugLevel = 1 print @currentProcessLabel;
									print (error_message());
								end;

								-- if the procedure is running asynchronously record the
								-- error, else re-throw it to end processing

								if isnull(@JobRunSID, 0) > 0
								begin

									insert
										sf.JobRunError (JobRunSID, MessageText, DataSource, RecordKey)
									select
										@JobRunSID
									 ,N'* ERROR: ' + error_message()
									 ,'EmailMessage'
									 ,isnull(ltrim(@invoiceSID), 'NULL');

								end;

								if isnull(@JobRunSID, 0) = 0 -- exit unless running async
								begin
									exec @errorNo = sf.pErrorRethrow;
								end;

							end catch;

						end;
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
					@MessageSCD = 'NoLateFeesApplied'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'No invoices found missing late fees. (This is not an error).';

			end;
			else if @maxrow <> -1
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'JobCompletedSucessfully'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'The %1 job was completed successfully.'
				 ,@Arg1 = 'Renewal Late Fees';

			end;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @TotalRecordCount
			 ,@RecordsProcessed = @TotalRecordCount
			 ,@TotalErrors = @TotalErrorCount
			 ,@ResultMessage = @resultMessage;

		end;

		if @DebugLevel >= 2
		begin
			select
				'** NO UPDATES MADE DUE TO DEBUG LEVEL (Set to 1 or 0 to apply updates) **' DebugMessage;
		end;
		else if @ReturnSelect = @ON
		begin
			select @TotalRecordCount AdjustedInvoiceCount , @TotalErrorCount TotalErrorCount;
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
