SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantLearningPlan#Approve
	@RegistrantLearningPlanSID int	-- key of the learning plan to approve
 ,@FormResponseDraft				 xml	-- form content being approved
 ,@FormVersionSID						 int	-- version of the form to obtain definition for
 ,@FormDefinition						 xml	-- definition of the form to pass to the #Post procedure for parsing
as
/*********************************************************************************************************************************
Procedure : Registrant Learning Plan Approve (form responses)
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Saves forms responses to the database tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Dec 2017		|	Initial version
				: Tim Edlund					| Nov 2018		| Added call to save HTML of form to PersonDoc with context

Comments	
--------
This procedure extracts values from the XML document of form responses and writes those values to the database tables.  

The procedure expects to be called from pRegistrantLearningPlan#Update or from the #Approve process of a parent form
(e.g. pRegistrantRenewal#Approve).  If the calling program has not yet changed the status of the record to APPROVED, this 
procedure sets that status.  Note that once a form is in an APPROVED state, it can no longer be edited.  

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Approve a Learning Plan form in submitted status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@RegistrantLearningPlanSID		int

select top 1
	@RegistrantLearningPlanSID = rlp.RegistrantLearningPlanSID
from
	dbo.vRegistrantLearningPlan rlp
where
	rlp.RegistrantLearningPlanStatusSCD = 'SUBMITTED'
order by
	newid()

exec dbo.pRegistrantLearningPlan#Approve
	 @RegistrantLearningPlanSID = @RegistrantLearningPlanSID

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pRegistrantLearningPlan#Approve'
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
	 ,@confirmationDraft		nvarchar(max)		-- HTML version of approved document
	 ,@docTitle							nvarchar(100)		-- title for profile-update document (person doc)
	 ,@registrationYear			smallint				-- year the plan is filed for
	 ,@currentFormStatusSCD varchar(25);		-- current status of the record

	begin try

		-- check parameters
-- SQL Prompt formatting off
		if @FormVersionSID						is null set @blankParm = '@FormVersionSID';
		if @FormResponseDraft					is null set @blankParm = '@FormResponseDraft';
		if @RegistrantLearningPlanSID	is null set @blankParm = '@RegistrantLearningPlanSID';
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
		 ,@personSID						= r.PersonSID
		 ,@confirmationDraft		= rlp.ConfirmationDraft
		 ,@registrationYear			= rlp.RegistrationYear
		from
			dbo.RegistrantLearningPlan																												 rlp
		join
			dbo.Registrant																																		 r on rlp.RegistrantSID = r.RegistrantSID
		outer apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
		where
			rlp.RegistrantLearningPlanSID = @RegistrantLearningPlanSID;

		if @@rowcount = 0
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.RegistrantLearningPlan'
			 ,@Arg2 = @RegistrantLearningPlanSID;

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

			exec dbo.pRegistrantLearningPlanStatus#Insert
				@RegistrantLearningPlanSID = @RegistrantLearningPlanSID
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
			pdt.PersonDocTypeSCD = 'LEARNINGPLAN';

		exec dbo.pForm#Approve$SetPersonDoc
			@PersonSID = @personSID
		 ,@ConfirmationDraft = @confirmationDraft
		 ,@PersonDocTypeSCD = 'LEARNINGPLAN'
		 ,@ApplicationEntitySCD = 'dbo.RegistrantLearningPlan'
		 ,@FormRecordSID = @RegistrantLearningPlanSID
		 ,@Title = @docTitle;

		-- write form content configured for posting
		-- back into the main database tables

		exec sf.pForm#Post
			@FormRecordSID = @RegistrantLearningPlanSID
		 ,@FormActionCode = 'APPROVE'
		 ,@FormSchemaName = 'dbo'
		 ,@FormTableName = 'RegistrantLearningPlan'
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
