SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pReinstatement#Update$Status
	@ReinstatementSID	 int					-- key of the Reinstatement form record to process the status change for
 ,@NewFormStatusSCD	 varchar(25)	-- new status value (see sf.FormStatus for master list)
 ,@FormResponseDraft xml					-- the form content from the UI (not yet saved)
 ,@FormOwnerSID			 int					-- current owner of the form (defines who can edit)
 ,@InvoiceSID				 int					-- invoice - if any - associated with the form (controls WITHDRAWAL action)
as
/*********************************************************************************************************************************
Sproc    : Reinstatement Update Status
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure saves and processes changes in status on the Reinstatement form
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version
					: Cory Ng			| Nov 2018		| If unlocked or returned, set all other forms in the form set to the same status

Comments	
--------
This procedure is called from #Update to save and process changes in status passed through the @NewForStatusSCD parameter. No
action is performed if the new status parameter is null.

When status is changed a history record is recorded along with a version of the form content if it has changed from the
most recent version, or, if no prior version of the content has been saved.  The procedure is also responsible for calling
the #Submit and #Approve subroutines which are responsible for posting form content to the main tables and other actions when
the SUBMIT or APPROVE status is applied.  Finally, the procedure will call the #Withdraw subroutine when that status is applied
but only if no invoice for the form exists.  Otherwise the user must Cancel the associated insert before attempting to 
withdraw the form.

The logic is separated out of the #Update procedure to simplify maintenance and testing due to its complexity.

Example:
--------
<TestHarness>
  <Test Name = "Approve" IsDefault ="true" Description="Executes the procedure to approve a submitted Reinstatement form at random.">
    <SQLScript>
      <![CDATA[
declare
	@reinstatementSID	 int
 ,@formResponseDraft xml
 ,@formOwnerSID			 int
 ,@invoiceSID				 int;

select top (1)
	@reinstatementSID	 = r.ReinstatementSID
 ,@formResponseDraft = r.FormResponseDraft
 ,@formOwnerSID			 = rcs.FormOwnerSID
 ,@invoiceSID				 = r.InvoiceSID
from
	dbo.Reinstatement																							 r
cross apply dbo.fReinstatement#CurrentStatus(r.ReinstatementSID, -1) rcs
where
	rcs.FormStatusSCD = 'SUBMITTED'
order by
	newid();

if @reinstatementSID is null
begin
	raiserror(N'* ERROR: no sample data found to run test', 18, 1);
end;
else
begin

	begin transaction;

	exec dbo.[pReinstatement#Update$Status]
		@ReinstatementSID = @reinstatementSID
	 ,@NewFormStatusSCD = 'APPROVED'
	 ,@FormResponseDraft = @formResponseDraft
	 ,@FormOwnerSID = @formOwnerSID
	 ,@InvoiceSID = @invoiceSID;

	select
		rcs.FormStatusSCD
	from
		dbo.fReinstatement#CurrentStatus(@reinstatementSID, -1) rcs
   where
    rcs.FormStatusSCD = 'APPROVED';

	rollback;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pReinstatement#Update$Status'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo			 int = 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		 nvarchar(4000)					-- message text (for business rule errors)
	 ,@formStatusSID int										-- key of the form-status-code passed in (if any)
	 ,@responseSID	 int										-- key of the last response saved for the form (if any)
	 ,@formDefinition xml										-- definition of the form to use in posting
	 ,@draftCheckSum int										-- calculated checksum of the draft form content
	 ,@priorCheckSum int										-- calculated checksum of the previous form content
	 ,@ON            bit = cast(1 as bit)		-- constant for bit comparison and assignments

	begin try

		-- where a form status has been passed in, lookup its key
		-- and ensure the new status is saved to the status history table

		if @NewFormStatusSCD is not null -- if just saving in place (save and continue) pass this as NULL!
		begin

			declare
				@rowGUID		uniqueidentifier

			select
				@rowGUID = rr.RowGUID
			from
				dbo.Reinstatement rr
			cross apply
				dbo.fReinstatement#CurrentStatus(rr.ReinstatementSID, -1) cs
			where
				rr.ReinstatementSID = @ReinstatementSID
			and
				cs.FormStatusSCD <> @NewFormStatusSCD

			if @rowGUID is not null
			begin

				select
					@formStatusSID = fs.FormStatusSID
				from
					sf.FormStatus fs
				where
					fs.FormStatusSCD = @NewFormStatusSCD;

				if @formStatusSID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'RecordNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					 ,@Arg1 = 'sf.FormStatus'
					 ,@Arg2 = @NewFormStatusSCD;

					raiserror(@errorText, 18, 1);

				end;

				exec dbo.pReinstatementStatus#Insert
					@ReinstatementSID = @ReinstatementSID
				 ,@FormStatusSID = @formStatusSID;

				if @NewFormStatusSCD = 'RETURNED' or @NewFormStatusSCD = 'UNLOCKED'
				begin

						exec dbo.pFormSet#SetStatus	
							 @ParentRowGUID = @rowGUID
							,@FormStatusSCD = @NewFormStatusSCD
							,@IsParentSet		= @ON

				end

			end

			-- when a status change is saved, the version of the form must also 
			-- be saved in response history if content has changed (or if not saved previously)

			select
				@responseSID = max(rar.ReinstatementResponseSID)
			from
				dbo.ReinstatementResponse rar
			where
				rar.ReinstatementSID = @ReinstatementSID;

			if @responseSID is not null -- calculated the checksum for the previous form content and current draft
			begin

				select
					@priorCheckSum = checksum(cast(rar.FormResponse as nvarchar(max)))
				from
					dbo.ReinstatementResponse rar
				where
					rar.ReinstatementResponseSID = @responseSID;

				set @draftCheckSum = checksum(cast(@FormResponseDraft as nvarchar(max)));

			end;

			if @responseSID is null or @priorCheckSum <> @draftCheckSum -- if no saved version of form found, OR if current value is changed from latest copy
			begin

				exec dbo.pReinstatementResponse#Insert
					@ReinstatementSID = @ReinstatementSID
				 ,@FormOwnerSID = @FormOwnerSID
				 ,@FormResponse = @FormResponseDraft;

			end;

			-- post values to the main profile as required for
			-- the SUBMIT and APPROVE form actions

			if @NewFormStatusSCD = 'SUBMITTED'
			begin

				exec dbo.pReinstatement#Submit
					@ReinstatementSID = @ReinstatementSID
				 ,@FormResponseDraft = @FormResponseDraft;

			end;
			else if @NewFormStatusSCD = 'APPROVED'
			begin

				exec dbo.pReinstatement#Approve
					@ReinstatementSID = @ReinstatementSID
				 ,@FormResponseDraft = @FormResponseDraft;

			end;
			else if @NewFormStatusSCD in ('CORRECTED','RETURNED') and exists -- if edited by admin and form was previously submitted, call the form post action
					 (
						select
							1
						from
							dbo.ReinstatementStatus x
						join
							sf.FormStatus										 fs on x.FormStatusSID = fs.FormStatusSID
						where
							x.ReinstatementSID = @ReinstatementSID and fs.FormStatusSCD = 'SUBMITTED'
					 )
			begin

				select
					@formDefinition = fv.FormDefinition
				from
					dbo.Reinstatement rlp
				join
					sf.FormVersion						 fv on rlp.FormVersionSID = fv.FormVersionSID
				where
					rlp.ReinstatementSID = @ReinstatementSID;

				exec sf.pForm#Post
					@FormRecordSID = @ReinstatementSID
				 ,@FormActionCode = 'SUBMIT'
				 ,@FormSchemaName = 'dbo'
				 ,@FormTableName = 'Reinstatement'
				 ,@FormDefinition = @formDefinition
				 ,@Response = @FormResponseDraft;

			end;
			else if @NewFormStatusSCD = 'WITHDRAWN' and @InvoiceSID is not null
			begin

				exec dbo.pReinstatement#Withdraw
					@ReinstatementSID = @ReinstatementSID;

			end;
		end;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
