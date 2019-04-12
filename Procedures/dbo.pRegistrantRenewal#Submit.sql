SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantRenewal#Submit
	@RegistrantRenewalSID int -- key of the renewal to approve
 ,@FormResponseDraft		xml -- form content being approved
 ,@FormVersionSID				int -- version of the form to obtain definition for
as
/*********************************************************************************************************************************
Procedure : Registrant Renewal Submit (form responses)
Notice    : Copyright © 2012 Softworks Group Inc.
Summary   : Saves form responses marked to "PostOnSubmit" to the database tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Sep	2017			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure extracts values from the XML document of form responses and writes those values to the database tables.  The 
procedure expects to be called from pRegistrantRenewal#Update.  The procedure will also support being called from a process which
submits multiple forms as a batch.

Unlike the #Approve version of the procedure, this procedure limits updates performed to those where the attribute in the form XML 
"PostOnSubmit" is enabled (="true").  If the calling program has not yet changed the status of the record to SUBMITTED, this procedure 
sets that status (supports batch calling). 

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Submit a registrant application form in new status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@registrantRenewalSID	int
 ,@formResponseDraft		xml
 ,@formVersionSID				int;

select top (1)
	@registrantRenewalSID	= rr.RegistrantRenewalSID
 ,@formResponseDraft		= rr.FormResponseDraft
 ,@formVersionSID				= rr.FormVersionSID
from
	dbo.vRegistrantRenewal rr
where
	rr.FormStatusSCD = 'NEW'
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pRegistrantRenewal#Submit
		@RegistrantRenewalSID = @registrantRenewalSID
	 ,@FormResponseDraft = @formResponseDraft
	 ,@FormVersionSID = @formVersionSID;

	select
		x.RegistrantRenewalSID
	 ,x.FormStatusSCD
	from
		dbo.vRegistrantRenewal x
	where
		x.RegistrantRenewalSID = @registrantRenewalSID
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
	 @ObjectName			= 'dbo.pRegistrantRenewal#Submit'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int							= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm						varchar(50)												-- tracks if any required parameters are not provided
	 ,@OFF									bit							= cast(0 as bit)	-- constant for bit comparisons
	 ,@formStatusSID				int																-- key of SUBMITTED status record (in sf.FormStatus)
	 ,@rowGUID							uniqueidentifier									-- linking value to sub-forms of the parent forms
	 ,@registrationYear			smallint													-- the year of registration targetted by the form
	 ,@currentFormStatusSCD varchar(25)												-- current status of the record
	 ,@formDefinition				xml;															-- xml of the form definition for the renewal

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
			@currentFormStatusSCD = rrcs.FormStatusSCD
		 ,@registrationYear			= reg.RegistrationYear
		 ,@formDefinition				= fv.FormDefinition
		 ,@rowGUID							= rr.RowGUID
		from
			dbo.RegistrantRenewal																																	 rr
		join
			dbo.Registration																																			 reg on rr.RegistrationSID = reg.RegistrationSID
		join
			dbo.PracticeRegisterSection																														 prs on rr.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
		join
			sf.FormVersion																																				 fv on rr.FormVersionSID = fv.FormVersionSID
		outer apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) rrcs
		where
			rr.RegistrantRenewalSID = @RegistrantRenewalSID;

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

		begin transaction;

		-- Tim Edlund | Sep 2018
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

			exec dbo.pRegistrantRenewalStatus#Insert
				@RegistrantRenewalSID = @RegistrantRenewalSID
			 ,@FormStatusSID = @formStatusSID;

		end;

		-- Tim Edlund | Oct 2018
		-- before posting the submitted form or any of its sub-forms
		-- to the main tables, check if it will be auto-approved so
		-- that posting is only performed once

		if dbo.fRegistrantRenewal#IsAutoApprovalPending(@RegistrantRenewalSID) = @OFF
		begin

			exec dbo.pSubForms#Submit  -- auto approval not enabled so process post-on-submit for sub and main
				@ParentRowGUID = @rowGUID
			 ,@RegistrationYear = @registrationYear;

			exec sf.pForm#Post 
				@FormRecordSID = @RegistrantRenewalSID
			 ,@FormActionCode = 'SUBMIT'
			 ,@FormSchemaName = 'dbo'
			 ,@FormTableName = 'RegistrantRenewal'
			 ,@FormDefinition = @formDefinition
			 ,@Response = @FormResponseDraft;

		end;
		else
		begin

			exec dbo.pRegistrantRenewal#Approve -- otherwise auto-approval is enabled so process approval
				@RegistrantRenewalSID = @RegistrantRenewalSID
			 ,@FormResponseDraft = @FormResponseDraft
			 ,@FormVersionSID = @FormVersionSID;

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
