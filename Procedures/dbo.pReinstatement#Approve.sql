SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pReinstatement#Approve
	@ReinstatementSID	 int				-- key of the reinstatement to approve
 ,@FormResponseDraft xml				-- form content being approved
 ,@ReasonSID				 int = null -- optional reason why the form was approved
as
/*********************************************************************************************************************************
Procedure : Registrant Change Approve (form responses)
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Saves form responses to the database tables, generates an invoice where required, and saves new registration if paid
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2018		|	Initial version
				: Tim Edlund					| Nov 2018		| Added call to save HTML of form to PersonDoc with context
				: Cory Ng							| Dec 2018		| Pass the previous year to the sub form approve procedure so it can select the
																						| correct learning plan to approve

Comments	
--------
This procedure is called when the "APPROVE" action is called from the UI (by an administrator) or when auto-approval is enabled
when the form is submitted (called from #Submit). The procedure validates parameters and retrieves the form definition that will 
be required to post the content of the form to database tables through sf.pForm#Post.  

The procedure is most often called from pReinstatement#Update or a front end batch approval process.  If the calling 
program has not yet changed the status of the record to APPROVED, this procedure sets that status (this supports batch
calling).

The procedure is also responsible for calling the invoice generation process to charge the member where the change requires
payment.  If charges do not result, a $0 invoice must still be configured in setup.  If no amount is owing for the change, 
or an amount was owing but could be paid off through existing unapplied payments, then new registration record is also created 
as part of the transaction initiated by this procedure.  Generation of the new registration record completes the approval 
process.

If an amount is owing for the change, the new registration record is not applied until the member pays it which is handled 
through the payment action.  

Subroutines are called to handle the various stages of the process.

Note that once a form is in an APPROVED state, it can no longer be edited. 

@ReasonSID
----------
The @ReasonSID parameter is optional and may be passed by the caller to fill-in the ReasonSID on the resulting dbo.Registration
record. The value is normally provided by the @ReasonSIDOnApprove column on the base entity. The value is intended to provide 
explanation as to why the new registration was approved/required if not following a typical process.  For example, it may 
provide the reason why a requirement normally required, was by-passed in the case of this particular registrant.

Example
-------
<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Approve a change form in submitted status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@ReinstatementSID		int

select top 1
	@ReinstatementSID = rc.ReinstatementSID
from
	dbo.vReinstatement rc
where
	rc.ReinstatementStatusSCD = 'SUBMITTED'
order by
	newid()

exec dbo.pReinstatement#Approve
	 @ReinstatementSID = @ReinstatementSID

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pReinstatement#Approve'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
begin

	set nocount on;

	declare
		@errorNo										int = 0						-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText									nvarchar(4000)		-- message text (for business rule errors)
	 ,@blankParm									varchar(50)				-- tracks if any required parameters are not provided
	 ,@currentFormStatusSCD				varchar(25)				-- current status of the record
	 ,@rowGUID										uniqueidentifier	-- linking value to sub-forms of the parent change
	 ,@registrationYear						smallint					-- the year of the last active-practice type registration 
	 ,@reinstatementRegYear				smallint					-- the year of the reinstatement 
	 ,@personSID									int								-- key of person to attach document to
	 ,@confirmationDraft					nvarchar(max)			-- HTML version of approved document
	 ,@docTitle										nvarchar(100)			-- title for document
	 ,@practiceRegisterSectionSID int								-- section of approved registration
	 ,@formDefinition							xml;							-- xml of the form definition for the change

	begin try

-- SQL Prompt formatting off
		if @FormResponseDraft			is null set @blankParm = '@FormResponseDraft';
		if @ReinstatementSID	is null set @blankParm = '@ReinstatementSID';
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

		-- retrieve values required for posting
		-- and to check status and the key value

		select
			@currentFormStatusSCD				= cs.FormStatusSCD
		 ,@formDefinition							= fv.FormDefinition
		 ,@rowGUID										= rin.RowGUID
		 ,@registrationYear						= (rin.RegistrationYear - 1)	-- if a learning plan exists for the year prior to the reinstatement; approve it
		 ,@reinstatementRegYear				= rin.RegistrationYear
		 ,@personSID									= r.PersonSID
		 ,@confirmationDraft					= rin.ConfirmationDraft
		 ,@practiceRegisterSectionSID = rin.PracticeRegisterSectionSID
		from
			dbo.Reinstatement																										 rin
		join
			dbo.Registration																										 reg on rin.RegistrationSID = reg.RegistrationSID
		join
			sf.FormVersion																											 fv on rin.FormVersionSID = fv.FormVersionSID
		join
			sf.Form																															 f on fv.FormSID = f.FormSID
		join
			dbo.Registrant																											 r on reg.RegistrantSID = r.RegistrantSID
		outer apply dbo.fReinstatement#CurrentStatus(rin.ReinstatementSID, -1) cs
		where
			rin.ReinstatementSID = @ReinstatementSID;

		if @@rowcount = 0
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.Reinstatement'
			 ,@Arg2 = @ReinstatementSID;

			raiserror(@errorText, 18, 1);
		end;

		-- ensure the form is based on the latest 
		-- license (to avoid overwriting a later change)

		if exists
		(
			select
				1
			from
				dbo.Reinstatement rin
			join
				dbo.Registration	reg on rin.RegistrationSID	= reg.RegistrationSID
			join
				dbo.Registration	regNew on reg.RegistrantSID = regNew.RegistrantSID and regNew.EffectiveTime > reg.EffectiveTime
			where
				rin.ReinstatementSID = @ReinstatementSID
		)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RegistrationOutOfDate'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 cannot be approved because a new registration was approved since this %1 was created. Withdraw this %1 and create a new one based on the current registration.'
			 ,@Arg1 = 'reinstatement';

			raiserror(@errorText, 16, 1);

		end;

		begin transaction;

		-- if the form status is not already set to submitted, 
		-- update its status now

		if @currentFormStatusSCD <> 'APPROVED'
		begin

			exec dbo.pReinstatementStatus#Insert
				@ReinstatementSID = @ReinstatementSID
			 ,@FormStatusSCD = 'APPROVED';

		end;

		-- save the HTML version of the form to a document
		-- record (with context) for PDF creation by the
		-- background service

		set @docTitle = dbo.fRegistrationYear#Label(@reinstatementRegYear) + N' ' + dbo.fPracticeRegisterSection#Label(@practiceRegisterSectionSID);

		select
			@docTitle = @docTitle + N' ' + pdt.PersonDocTypeLabel
		from
			dbo.PersonDocType pdt
		where
			pdt.PersonDocTypeSCD = 'REINSTATEMENT';

		exec dbo.pForm#Approve$SetPersonDoc
			@PersonSID = @personSID
		 ,@ConfirmationDraft = @confirmationDraft
		 ,@PersonDocTypeSCD = 'REINSTATEMENT'
		 ,@ApplicationEntitySCD = 'dbo.Reinstatement'
		 ,@FormRecordSID = @ReinstatementSID
		 ,@Title = @docTitle;

		-- write form content configured for posting
		-- back into the main database tables

		exec sf.pForm#Post
			@FormRecordSID = @ReinstatementSID
		 ,@FormActionCode = 'APPROVE'
		 ,@FormSchemaName = 'dbo'
		 ,@FormTableName = 'Reinstatement'
		 ,@FormDefinition = @formDefinition
		 ,@Response = @FormResponseDraft;

		-- Approve any sub-forms associated with this change.
		-- Pass the registration year as the previous year 
		-- as learning plans tied to a reinstatement are 
		-- always a year back

		exec dbo.pSubForms#Approve
			@ParentRowGUID = @rowGUID
		 ,@RegistrationYear = @registrationYear;

		-- invoices for are generated upon approval; if no fee are involved
		-- or the generated invoice has been prepaid, then the subroutine 
		-- will also insert the new registration

		exec dbo.pInvoice#SetOnFormChange
			@FormTypeCode = 'REINSTATEMENT'
		 ,@RegistrationRecordSID = @ReinstatementSID
		 ,@ReasonSID = @ReasonSID;

		commit;
	end try
	begin catch
		if @@trancount > 0 rollback;

		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
