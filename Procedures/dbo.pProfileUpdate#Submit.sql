SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pProfileUpdate#Submit
	@ProfileUpdateSID	 int	-- key of the profile update to approve
 ,@FormResponseDraft xml	-- form content being approved
 ,@FormVersionSID		 int	-- version of the form to obtain definition for
as

/*********************************************************************************************************************************
Procedure : Profile Update Submit (form responses)
Notice    : Copyright © 2012 Softworks Group Inc.
Summary   : Saves form responses marked to "PostOnSubmit" to the database tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Cory Ng							| Jan 2018		|	Initial version
 				: Tim Edlund          | Nov 2018		|	Updated to avoid processing approval if parent form exists and not approved
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure extracts values from the XML document of form responses and writes those values to the database tables.  The 
procedure expects to be called from pProfileUpdate#Update.  The procedure will also support being called from a process which
submits multiple forms as a batch.

Unlike the #Approve version of the procedure, this procedure limits updates performed to those where the attribute in the form 
XML "PostOnSubmit" is enabled (="true").  If the calling program has not yet changed the status of the record to SUBMITTED, 
this procedure sets that status (supports batch calling). 

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Submit a profile update form in new status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@profileUpdateSID	 int
 ,@formResponseDraft xml
 ,@formVersionSID		 int;

select top (1)
	@profileUpdateSID	 = rr.ProfileUpdateSID
 ,@formResponseDraft = rr.FormResponseDraft
 ,@formVersionSID		 = rr.FormVersionSID
from
	dbo.vProfileUpdate rr
where
	rr.FormStatusSCD = 'NEW'
order by
	newid()

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pProfileUpdate#Submit
		@ProfileUpdateSID = @profileUpdateSID
	 ,@FormResponseDraft = @formResponseDraft
	 ,@FormVersionSID = @formVersionSID;

	select
		x.ProfileUpdateSID
	 ,x.FormStatusSCD
	from
		dbo.vProfileUpdate x
	where
		x.ProfileUpdateSID = @profileUpdateSID
	and
		x.FormStatusSCD = 'SUBMITTED'

	if @@trancount > 0 rollback;	-- rollback transaction to avoid permanent data change
end;

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pProfileUpdate#Submit'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							 int						 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						 nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm						 varchar(50)											-- tracks if any required parameters are not provided
	 ,@OFF									 bit						 = cast(0 as bit) -- constant for bit comparisons
	 ,@formStatusSID				 int															-- key of SUBMITTED status record (in sf.FormStatus)
	 ,@currentFormStatusSCD	 varchar(25)											-- current status of the record
	 ,@parentRowGUID				 uniqueidentifier									-- track whether form is a sub-form (GUID of parent)
	 ,@parentFormSID				 int															-- key of the parent form (if any)
	 ,@parentFormStatusSCD	 varchar(25)											-- status of the parent record (controls approval action)
	 ,@formDefinition				 xml															-- xml of the form definition for the profile update
	 ,@isAutoApprovalEnabled bit;															-- indicates if profile update should be auto approved

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @FormVersionSID		is null set @blankParm = '@FormVersionSID';
		if @FormResponseDraft is null set @blankParm = '@FormResponseDraft';
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
			@currentFormStatusSCD	 = cs.FormStatusSCD
		 ,@formDefinition				 = fv.FormDefinition
		 ,@isAutoApprovalEnabled = cs.IsAutoApprovalEnabled
		 ,@parentRowGUID				 = pu.ParentRowGUID
		from
			dbo.ProfileUpdate																										pu
		cross apply dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) cs
		join
			sf.FormVersion fv on cs.FormVersionSID = fv.FormVersionSID
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

		-- if the form status is not already set to submitted, 
		-- update its status now

		if @currentFormStatusSCD <> 'SUBMITTED'
		begin

			select
				@formStatusSID = fs.FormStatusSID
			from
				sf.FormStatus fs
			where
				fs.FormStatusSCD = 'SUBMITTED';

			if @formStatusSID is null
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'sf.FormStatus'
				 ,@Arg2 = 'SUBMITTED';

				raiserror(@errorText, 18, 1);
			end;

			exec dbo.pProfileUpdateStatus#Insert
				@ProfileUpdateSID = @ProfileUpdateSID
			 ,@FormStatusSID = @formStatusSID;
		end;

		-- before posting the submitted form to the main
		-- tables, check if it will be auto-approved so
		-- that posting is only performed once

		if @isAutoApprovalEnabled = @OFF
		begin

			exec sf.pForm#Post -- auto approval not enabled so process post-on-submit columns
				@FormRecordSID = @ProfileUpdateSID
			 ,@FormActionCode = 'SUBMIT'
			 ,@FormSchemaName = 'dbo'
			 ,@FormTableName = 'ProfileUpdate'
			 ,@FormDefinition = @formDefinition
			 ,@Response = @FormResponseDraft;

		end;
		else
		begin

			-- avoid processing an approval if a parent form exists and
			-- the parent form is not already approved

			if @parentRowGUID is null
			begin
				set @parentFormStatusSCD = 'APPROVED';
			end;
			else	-- each possible parent form type must be evaluated (terminates when 1 is found)
			begin	

				select
					@parentFormSID = frm.RegistrantRenewalSID		-- renewal
				from
					dbo.RegistrantRenewal frm
				where
					frm.RowGUID = @parentRowGUID;

				if @parentFormSID is not null
				begin

					select
						@parentFormStatusSCD = cs.FormStatusSCD
					from
						dbo.fRegistrantRenewal#CurrentStatus(@parentFormSID, -1) cs;

				end;

				if @parentFormSID is null
				begin

					select
						@parentFormSID = frm.RegistrantAppSID -- application
					from
						dbo.RegistrantApp frm
					where
						frm.RowGUID = @parentRowGUID;

					if @parentFormSID is not null
					begin

						select
							@parentFormStatusSCD = cs.FormStatusSCD
						from
							dbo.fRegistrantApp#CurrentStatus(@parentFormSID, -1) cs;

					end;
				end;

				if @parentFormSID is null
				begin

					select
						@parentFormSID = frm.ReinstatementSID	-- reinstatement
					from
						dbo.Reinstatement frm
					where
						frm.RowGUID = @parentRowGUID;

					if @parentFormSID is not null
					begin

						select
							@parentFormStatusSCD = cs.FormStatusSCD
						from
							dbo.fReinstatement#CurrentStatus(@parentFormSID, -1) cs;

					end;
				end;

				if @parentFormSID is null
				begin

					select
						@parentFormSID = frm.RegistrantAuditSID -- audit
					from
						dbo.RegistrantAudit frm
					where
						frm.RowGUID = @parentRowGUID;

					if @parentFormSID is not null
					begin

						select
							@parentFormStatusSCD = cs.FormStatusSCD
						from
							dbo.fRegistrantAudit#CurrentStatus(@parentFormSID, -1) cs;

					end;
				end;

			end;

			if @parentFormStatusSCD = 'APPROVED'
			begin

				exec dbo.pProfileUpdate#Approve -- otherwise auto-approval is enabled so process profile update
					@ProfileUpdateSID = @ProfileUpdateSID
				 ,@FormResponseDraft = @FormResponseDraft
				 ,@FormVersionSID = @FormVersionSID
				 ,@FormDefinition = @formDefinition;

			end;

		end;

		commit;
	end try
	begin catch
		if @@trancount > 0 rollback;

		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
