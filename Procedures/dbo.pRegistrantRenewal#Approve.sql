SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantRenewal#Approve
	@RegistrantRenewalSID int					-- key of the renewal to approve
 ,@FormResponseDraft		xml					-- form content being approved
 ,@FormVersionSID				int					-- version of the form to obtain definition for
 ,@ReasonSID						int = null	-- optional reason why the form was approved
as
/*********************************************************************************************************************************
Procedure : Registrant Renewal Approve (form responses)
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Saves forms responses to the database tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ----------- + ------------ + -------------------------------------------------------------------------------------------
				: Tim Edlund	| Aug	2017			|	Initial version
				: Tim Edlund	| Dec 2017			| Updated to support approval of sub-forms.  Reformatting to current standard.
				: Tim Edlund	| Apr 2018			| Added support for @ReasonSID to pass through to the Registration record
				: Tim Edlund	| Nov 2018			| Added call to save HTML of form to PersonDoc with context

Comments	
--------
This procedure extracts values from the XML document of form responses and writes those values to the database tables. The 
procedure is also responsible for calling the invoice generation process to invoice the renewal after approval.  

The procedure expects to be called from pRegistrantRenewal#Update or a front end batch approval process.  If the calling program 
has not yet changed the status of the record to APPROVED, this procedure sets that status.  Note that once a form is in an 
APPROVED state, it can no longer be edited.  

@ReasonSID
----------
The @ReasonSID parameter is optional and may be passed by the caller to fill-in the ReasonSID on the resulting dbo.Registration
record. The value is normally provided by the @ReasonSIDOnApprove column on the base entity. The value is intended to provide 
explanation as to why the new registration was approved/required if not following a typical process.  For example, it may 
provide the reason why a requirement normally required, was by-passed in the case of this particular registrant.

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Approve a Renewal form in submitted status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@RegistrantRenewalSID		int

select top 1
	@RegistrantRenewalSID = rnw.RegistrantRenewalSID
from
	dbo.vRegistrantRenewal rnw
where
	rnw.FormStatusSCD = 'SUBMITTED'
order by
	newid()

exec dbo.pRegistrantRenewal#Approve
	 @RegistrantRenewalSID = @RegistrantRenewalSID

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pRegistrantRenewal#Approve'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
begin

	set nocount on;

	declare
		@errorNo										int = 0						-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText									nvarchar(4000)		-- message text (for business rule errors)
	 ,@blankParm									varchar(50)				-- tracks if any required parameters are not provided
	 ,@formStatusSID							int								-- key of APPROVED status record (in sf.FormStatus)
	 ,@currentFormStatusSCD				varchar(25)				-- current status of the record
	 ,@rowGUID										uniqueidentifier	-- linking value to sub-forms of the parent renewal
	 ,@registrationYear						smallint					-- the year of the registration being renewed (not the renewal year!)
	 ,@personSID									int								-- key of person to attach document to
	 ,@confirmationDraft					nvarchar(max)			-- HTML version of approved document
	 ,@docTitle										nvarchar(100)			-- title for document
	 ,@practiceRegisterSectionSID int								-- section of approved registration
	 ,@formDefinition							xml;							-- xml of the form definition for the renewal

	begin try

		-- check parameters
-- SQL Prompt formatting off
		if @FormVersionSID				is null set @blankParm = '@FormVersionSID';
		if @FormResponseDraft			is null set @blankParm = '@FormResponseDraft';
		if @RegistrantRenewalSID	is null set @blankParm = '@RegistrantRenewalSID';
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
			@currentFormStatusSCD				= rrcs.FormStatusSCD
		 ,@formDefinition							= fv.FormDefinition
		 ,@rowGUID										= rnw.RowGUID
		 ,@registrationYear						= reg.RegistrationYear
		 ,@personSID									= r.PersonSID
		 ,@confirmationDraft					= rnw.ConfirmationDraft
		 ,@practiceRegisterSectionSID = rnw.PracticeRegisterSectionSID
		from
			dbo.RegistrantRenewal																												 rnw
		join
			dbo.Registration																														 reg on rnw.RegistrationSID = reg.RegistrationSID
		join
			dbo.PracticeRegisterSection																									 prs on rnw.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
		join
			sf.FormVersion																															 fv on rnw.FormVersionSID = fv.FormVersionSID
		join
			dbo.Registrant																															 r on reg.RegistrantSID = r.RegistrantSID
		outer apply dbo.fRegistrantRenewal#CurrentStatus(rnw.RegistrantRenewalSID, -1) rrcs
		where
			rnw.RegistrantRenewalSID = @RegistrantRenewalSID;

		if @@rowcount = 0
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.RegistrantRenewal'
			 ,@Arg2 = @RegistrantRenewalSID;

			raiserror(@errorText, 18, 1);
		end;

		-- ensure the form is based on the latest 
		-- registration (to avoid overwriting a later change)

		if exists
		(
			select
				1
			from
				dbo.RegistrantRenewal rnw
			join
				dbo.Registration			reg on rnw.RegistrationSID	= reg.RegistrationSID
			join
				dbo.Registration			regNew on reg.RegistrantSID = regNew.RegistrantSID and regNew.EffectiveTime > reg.EffectiveTime
			where
				rnw.RegistrantRenewalSID = @RegistrantRenewalSID
		)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RegistrationOutOfDate'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 cannot be approved because a new registration was approved since this %1 was created. Withdraw this %1 and create a new one based on the current registration.'
			 ,@Arg1 = 'renewal';

			raiserror(@errorText, 16, 1);

		end;

		begin transaction;

		-- if the form status is not already set to approved, update
		-- its status now

		if @currentFormStatusSCD <> 'APPROVED'
		begin

			select
				@formStatusSID = fs.FormStatusSID
			from
				sf.FormStatus fs
			where
				fs.FormStatusSCD = 'APPROVED';

			if @formStatusSID is null
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'sf.FormStatus'
				 ,@Arg2 = 'APPROVED';

				raiserror(@errorText, 18, 1);
			end;

			exec dbo.pRegistrantRenewalStatus#Insert
				@RegistrantRenewalSID = @RegistrantRenewalSID
			 ,@FormStatusSID = @formStatusSID;

		end;

		-- save the HTML version of the form to a document
		-- record (with context) for PDF creation by the
		-- background service

		set @docTitle = dbo.fRegistrationYear#Label(@registrationYear + 1) + N' ' + dbo.fPracticeRegisterSection#Label(@practiceRegisterSectionSID);

		select
			@docTitle = @docTitle + N' ' + pdt.PersonDocTypeLabel
		from
			dbo.PersonDocType pdt
		where
			pdt.PersonDocTypeSCD = 'RENEWAL';

		exec dbo.pForm#Approve$SetPersonDoc
			 @PersonSID = @personSID
			,@ConfirmationDraft = @confirmationDraft
			,@PersonDocTypeSCD = 'RENEWAL'
			,@ApplicationEntitySCD = 'dbo.RegistrantRenewal'
			,@FormRecordSID = @RegistrantRenewalSID
			,@Title = @docTitle

		-- write form content configured for posting
		-- back into the main database tables

		exec sf.pForm#Post
			@FormRecordSID = @RegistrantRenewalSID
		 ,@FormActionCode = 'APPROVE'
		 ,@FormSchemaName = 'dbo'
		 ,@FormTableName = 'RegistrantRenewal'
		 ,@FormDefinition = @formDefinition
		 ,@Response = @FormResponseDraft;

		-- approve any sub-forms associated with this renewal

		exec dbo.pSubForms#Approve
			@ParentRowGUID = @rowGUID
		 ,@RegistrationYear = @registrationYear;

		-- invoices for are generated upon approval; if no fee are involved
		-- or the generated invoice has been prepaid, then the subroutine 
		-- will also insert the new registration

		exec dbo.pInvoice#SetOnFormChange
			@FormTypeCode = 'RENEWAL'
		 ,@RegistrationRecordSID = @RegistrantRenewalSID
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
