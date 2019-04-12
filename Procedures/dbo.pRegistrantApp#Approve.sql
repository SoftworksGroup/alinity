SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantApp#Approve
	@RegistrantAppSID	 int				-- key of the application to approve
 ,@FormResponseDraft xml				-- form content being approved
 ,@FormVersionSID		 int				-- version of the form to obtain definition for
 ,@ReasonSID				 int = null -- optional reason why the form was approved
as
/*********************************************************************************************************************************
Procedure : Registrant Application Approve (form responses)
Notice    : Copyright © 2012 Softworks Group Inc.
Summary   : Saves forms responses to the database tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2017		|	Initial version
				: Tim Edlund					| Oct 2017		|	Added support for invoicing on approval.
				: Tim Edlund					| Dec 2017		| Added support for sub-form approvals
				: Tim Edlund					| Apr 2018		| Added support for @ReasonSID to pass through to the Registration record
				: Tim Edlund					| Nov 2018		| Added call to save HTML of form to PersonDoc with context
				: Russell Poirier			|	Mar 2019		| Resolved issue with initial select for variables joining incorrectly

Comments	
--------
This procedure extracts values from the XML document of form responses and writes those values to the database tables. The 
procedure is also responsible for calling the invoice generation process to invoice the application after approval.  

The procedure expects to be called from pRegistrantApp#Update or a front end batch approval process.  If the calling program 
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
	<Test Name="Simple" IsDefault="true" Description="Approve an application form in admin review status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@RegistrantAppSID		int

select top 1
	@RegistrantAppSID = ra.RegistrantAppSID
from
	dbo.vRegistrantApp ra
where
	ra.FormStatusSCD = 'SUBMITTED'
order by
	newid()

exec dbo.pRegistrantApp#Approve
	 @RegistrantAppSID = @RegistrantAppSID

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pRegistrantApp#Approve'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo										int = 0						-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText									nvarchar(4000)		-- message text (for business rule errors)
	 ,@blankParm									varchar(50)				-- tracks if any required parameters are not provided
	 ,@rowGUID										uniqueidentifier	-- linking value to sub-forms of the parent application
	 ,@formStatusSID							int								-- key of APPROVED status record (in sf.FormStatus)
	 ,@currentFormStatusSCD				varchar(25)				-- current status of the record
	 ,@personSID									int								-- key of person to attach document to
	 ,@registrationYear						smallint					-- year of the application
	 ,@confirmationDraft					nvarchar(max)			-- HTML version of approved document
	 ,@docTitle										nvarchar(100)			-- title for document
	 ,@practiceRegisterSectionSID int								-- section of approved registration
	 ,@formDefinition							xml;							-- xml of the form definition for the application

	begin try


-- SQL Prompt formatting off
		if @FormVersionSID		is null set @blankParm = '@FormVersionSID';
		if @FormResponseDraft is null	set @blankParm = '@FormResponseDraft';
		if @RegistrantAppSID	is null	set @blankParm = '@RegistrantAppSID';
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
			@rowGUID										= ra.RowGUID
		 ,@currentFormStatusSCD				= rrcs.FormStatusSCD
		 ,@formDefinition							= fv.FormDefinition
		 ,@confirmationDraft					= ra.ConfirmationDraft
		 ,@registrationYear						= ra.RegistrationYear
		 ,@personSID									= r.PersonSID
		 ,@practiceRegisterSectionSID = ra.PracticeRegisterSectionSID
		from
			dbo.RegistrantApp																										ra
    join
			sf.FormVersion																											fv on ra.FormVersionSID = fv.FormVersionSID
		join
			dbo.Registration																										reg on ra.RegistrationSID = reg.RegistrationSID
    join
      dbo.Registrant                                                      r on  reg.RegistrantSID = r.RegistrantSID
		outer apply dbo.fRegistrantApp#CurrentStatus(ra.RegistrantAppSID, -1) rrcs
		where
			ra.RegistrantAppSID = @RegistrantAppSID;

		if @@rowcount = 0
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.RegistrantApp'
			 ,@Arg2 = @RegistrantAppSID;

			raiserror(@errorText, 18, 1);
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

			exec dbo.pRegistrantAppStatus#Insert
				@RegistrantAppSID = @RegistrantAppSID
			 ,@FormStatusSID = @formStatusSID;

		end;

		-- save the HTML version of the form to a document
		-- record (with context) for PDF creation by the
		-- background service

		set @docTitle = dbo.fRegistrationYear#Label(@registrationYear) + N' ' + dbo.fPracticeRegisterSection#Label(@practiceRegisterSectionSID);

		select
			@docTitle = @docTitle + N' ' + pdt.PersonDocTypeLabel
		from
			dbo.PersonDocType pdt
		where
			pdt.PersonDocTypeSCD = 'APP';

		exec dbo.pForm#Approve$SetPersonDoc
			@PersonSID = @personSID
		 ,@ConfirmationDraft = @confirmationDraft
		 ,@PersonDocTypeSCD = 'APP'
		 ,@ApplicationEntitySCD = 'dbo.RegistrantApp'
		 ,@FormRecordSID = @RegistrantAppSID
		 ,@Title = @docTitle;

		-- write form content configured for posting
		-- back into the main database tables

		exec sf.pForm#Post
			@FormRecordSID = @RegistrantAppSID
		 ,@FormActionCode = 'APPROVE'
		 ,@FormSchemaName = 'dbo'
		 ,@FormTableName = 'RegistrantApp'
		 ,@FormDefinition = @formDefinition
		 ,@Response = @FormResponseDraft;

		-- approve any sub-forms associated with this application

		exec dbo.pSubForms#Approve
			@ParentRowGUID = @rowGUID;

		-- invoices may be generated upon approval; if no fees are involved
		-- or the generated invoice has been prepaid, then the subroutine 
		-- will also insert the new registration

		exec dbo.pInvoice#SetOnFormChange
			@FormTypeCode = 'APPLICATION'
		 ,@RegistrationRecordSID = @RegistrantAppSID
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
