SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantAudit#Approve
	@RegistrantAuditSID int -- key of the audit to approve
 ,@FormResponseDraft	xml -- form content being approved
 ,@FormVersionSID			int -- version of the form to obtain definition for
as
/*********************************************************************************************************************************
Procedure : Registrant Audit Approve (form responses)
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Saves forms responses to the database tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Jul 2017		|	Initial version
				: Tim Edlund					| Nov 2018		| Added call to save HTML of form to PersonDoc with context

Comments	
--------
This procedure extracts values from the XML document of form responses and writes those values to the database tables.  The 
procedure expects to be called from pRegistrantAudit#Update or pRegistrantAudit#ApproveBatch.  If the calling program has not
yet changed the status of the record to APPROVED, this procedure sets that status.  Note that once a form is in an APPROVED 
(or FAILED) state, it can no longer be edited.  

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Approve an audit form in admin review status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@registrantAuditSID		int

select top 1
	@registrantAuditSID = ra.RegistrantAuditSID
from
	dbo.vRegistrantAudit ra
where
	ra.RegistrantAuditStatusSCD = 'SUBMITTED'
order by
	newid()

exec dbo.pRegistrantAudit#Approve
	 @RegistrantAuditSID = @registrantAuditSID

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pRegistrantAudit#Approve'
	,@DefaultTestOnly = 1
	

-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int = 0						-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)		-- message text (for business rule errors)
	 ,@blankParm						varchar(50)				-- tracks if any required parameters are not provided
	 ,@rowGUID							uniqueidentifier	-- linking value to sub-forms of the parent audit
	 ,@formStatusSID				int								-- key of APPROVED status record (in sf.FormStatus)
	 ,@currentFormStatusSCD varchar(25)				-- current status of the record
	 ,@personSID						int								-- key of person to attach document to
	 ,@registrationYear			smallint					-- registration year of the form
	 ,@confirmationDraft		nvarchar(max)			-- HTML version of approved document
	 ,@docTitle							nvarchar(100)			-- title for document
	 ,@auditTypeLabel				nvarchar(35)			-- type of audit for doc title
	 ,@formDefinition				xml;							-- xml of the form definition for the application

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @FormVersionSID			is null	set @blankParm = '@FormVersionSID';
		if @FormResponseDraft		is null	set @blankParm = '@FormResponseDraft';
		if @RegistrantAuditSID	is null set @blankParm = '@RegistrantAppSID';
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
			@rowGUID							= ra.RowGUID
		 ,@currentFormStatusSCD = racs.FormStatusSCD
		 ,@formDefinition				= fv.FormDefinition
		 ,@registrationYear			= ra.RegistrationYear
		 ,@personSID						= r.PersonSID
		 ,@confirmationDraft		= ra.ConfirmationDraft
		 ,@auditTypeLabel				= at.AuditTypeLabel
		from
			dbo.RegistrantAudit																																 ra
		join
			dbo.Registrant																																		 r on ra.RegistrantSID = r.RegistrantSID
		join
			sf.FormVersion																																		 fv on ra.FormVersionSID = fv.FormVersionSID
		join
			dbo.AuditType																																			 at on ra.AuditTypeSID = at.AuditTypeSID
		outer apply dbo.fRegistrantAudit#CurrentStatus(ra.RegistrantAuditSID, -1) racs
		where
			ra.RegistrantAuditSID = @RegistrantAuditSID;

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.RegistrantAudit'
			 ,@Arg2 = @RegistrantAuditSID;

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

			exec dbo.pRegistrantAuditStatus#Insert
				@RegistrantAuditSID = @RegistrantAuditSID
			 ,@FormStatusSID = @formStatusSID;

		end;

		-- save the HTML version of the form to a document
		-- record (with context) for PDF creation by the
		-- background service

		set @docTitle = dbo.fRegistrationYear#Label(@registrationYear) + N' ' + @auditTypeLabel;

		select
			@docTitle = @docTitle + N' ' + pdt.PersonDocTypeLabel
		from
			dbo.PersonDocType pdt
		where
			pdt.PersonDocTypeSCD = 'AUDIT';

		exec dbo.pForm#Approve$SetPersonDoc
			@PersonSID = @personSID
		 ,@ConfirmationDraft = @confirmationDraft
		 ,@PersonDocTypeSCD = 'AUDIT'
		 ,@ApplicationEntitySCD = 'dbo.RegistrantAudit'
		 ,@FormRecordSID = @RegistrantAuditSID
		 ,@Title = @docTitle;

		-- finally write form content configured for posting
		-- back into the main database tables

		exec sf.pForm#Post
			@FormRecordSID = @RegistrantAuditSID
		 ,@FormActionCode = 'APPROVE'
		 ,@FormSchemaName = 'dbo'
		 ,@FormTableName = 'RegistrantAudit'
		 ,@FormDefinition = @formDefinition
		 ,@Response = @FormResponseDraft;

		-- approve any sub-forms associated with this application

		exec dbo.pSubForms#Approve
			@ParentRowGUID = @rowGUID;

		commit;

	end try
	begin catch

		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw

	end catch;

	return (@errorNo);

end;
GO
