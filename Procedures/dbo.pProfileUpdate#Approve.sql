SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pProfileUpdate#Approve
	@ProfileUpdateSID	 int	-- key of the profile update to approve
 ,@FormResponseDraft xml	-- form content being approved
 ,@FormVersionSID		 int	-- version of the form to obtain definition for
 ,@FormDefinition		 xml	-- definition of the form to pass to the #Post procedure for parsing
as
/*********************************************************************************************************************************
Procedure : Profile Update Approve (form responses)
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Saves forms responses to the database tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Dec	2017			|	Initial version
				: Tim Edlund	| Nov 2018			| Added call to save HTML of form to PersonDoc with context

Comments	
--------
This procedure extracts values from the XML document of form responses and writes those values to the database tables.  

The procedure expects to be called from pProfileUpdate#Update or from the #Approve process of a parent form
(e.g. pRegistrantRenewal#Approve).  If the calling program has not yet changed the status of the record to APPROVED, this 
procedure sets that status.  Note that once a form is in an APPROVED state, it can no longer be edited.  

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Approve a Profile Update form in submitted status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@ProfileUpdateSID		int

select top 1
	@ProfileUpdateSID = pu.ProfileUpdateSID
from
	dbo.vProfileUpdate pu
where
	pu.FormStatusSCD = 'SUBMITTED'
order by
	newid()

exec dbo.pProfileUpdate#Approve
	 @ProfileUpdateSID = @ProfileUpdateSID

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pProfileUpdate#Approve'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
begin

	set nocount on;

	declare
		@errorNo							int = 0					-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)	-- message text (for business rule errors)
	 ,@blankParm						varchar(50)			-- tracks if any required parameters are not provided
	 ,@formStatusSID				int							-- key of APPROVED status record (in sf.FormStatus)
	 ,@personSID						int							-- key of person to attach document to
	 ,@docTitle							nvarchar(100)		-- title for profile-update document (person doc)
	 ,@confirmationDraft		nvarchar(max)		-- HTML version of approved document
	 ,@registrationYear			smallint				-- year of the form
	 ,@currentFormStatusSCD varchar(25);		-- current status of the record

	begin try

		-- check parameters
-- SQL Prompt formatting off
		if @FormVersionSID		is null set @blankParm = '@FormVersionSID';
		if @FormResponseDraft	is null set @blankParm = '@FormResponseDraft';
		if @ProfileUpdateSID	is null set @blankParm = '@ProfileUpdateSID';
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
			@currentFormStatusSCD = cs.FormStatusSCD
		 ,@personSID						= pu.PersonSID
		 ,@confirmationDraft		= pu.ConfirmationDraft
		 ,@registrationYear			= pu.RegistrationYear
		from
			dbo.ProfileUpdate																										pu
		outer apply dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) cs
		where
			pu.ProfileUpdateSID = @ProfileUpdateSID;

		if @@rowcount = 0
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.ProfileUpdate'
			 ,@Arg2 = @ProfileUpdateSID;

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

			exec dbo.pProfileUpdateStatus#Insert
				@ProfileUpdateSID = @ProfileUpdateSID
			 ,@FormStatusSID = @formStatusSID;

		end;

		-- save the HTML version of the form to a document
		-- record (with context) for PDF creation by the
		-- background service

		set @docTitle = dbo.fRegistrationYear#Label(@registrationYear);

		select
			@docTitle = @docTitle + N' ' + pdt.PersonDocTypeLabel
		from
			dbo.PersonDocType pdt
		where
			pdt.PersonDocTypeSCD = 'PROFILE.UPD';

		exec dbo.pForm#Approve$SetPersonDoc
			@PersonSID = @personSID
		 ,@ConfirmationDraft = @confirmationDraft
		 ,@PersonDocTypeSCD = 'PROFILE.UPD'
		 ,@ApplicationEntitySCD = 'dbo.ProfileUpdate'
		 ,@FormRecordSID = @ProfileUpdateSID
		 ,@Title = @docTitle;

		-- write form content configured for posting
		-- back into the main database tables

		exec sf.pForm#Post
			@FormRecordSID = @ProfileUpdateSID
		 ,@FormActionCode = 'APPROVE'
		 ,@FormSchemaName = 'dbo'
		 ,@FormTableName = 'ProfileUpdate'
		 ,@FormDefinition = @FormDefinition
		 ,@Response = @FormResponseDraft;

		commit;
	end try
	begin catch
		if @@trancount > 0 rollback;

		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
