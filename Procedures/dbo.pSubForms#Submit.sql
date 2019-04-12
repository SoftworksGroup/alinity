SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pSubForms#Submit
	@ParentRowGUID		uniqueidentifier	-- unique identifier of the parent form (e.g. of the Renewal or Application form)
 ,@RegistrationYear smallint = null		-- registration year of the form to be submitted (distinguishes if multiple forms for GUID)
as

/*********************************************************************************************************************************
Procedure	: Sub Forms - Submit
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Checks for existence of sub-forms related to the parent GUID passed and set them to SUBMITTED status
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This procedure is called from #Submit procedures of parent forms like Renewal, Application and Reinstatement.  It checks 
for the existence of sub-forms (Learning Plan, Profile Update) which are related to the parent form through the row GUID on the
parent form. If the sub-form is found and it is not already in an SUBMITTED status then its #Submit procedure is called.

Example
-------
<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Submit a renewal form with a learning sub-form at random">
		<SQLScript>
			<![CDATA[
declare
	@parentRowGUID		uniqueidentifier
 ,@registrationYear smallint;

select top (1)
	@parentRowGUID		= rr.RowGUID
 ,@registrationYear = rlp.RegistrationYear
from
	dbo.RegistrantRenewal																										 rr
join
	dbo.RegistrantLearningPlan																							 rlp on rr.RowGUID = rlp.ParentRowGUID
cross apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) cs
where
	cs.FormStatusSCD = 'NEW'
order by
	newid();

if @parentRowGUID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction; -- rollback data to avoid using up test scenario records

	exec dbo.pSubForms#Submit
		@ParentRowGUID = @parentRowGUID
	 ,@RegistrationYear = @registrationYear;

	select
		cs.FormStatusSCD
	 ,rlp.RegistrantLearningPlanSID
	 ,rlp.ParentRowGUID
	 ,'dbo.RegistrantRenewal' ParentRowSource
	from
		dbo.RegistrantLearningPlan																												 rlp
	cross apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
	where
		rlp.ParentRowGUID = @parentRowGUID;

	if @@trancount > 0 rollback;
end;
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pSubForms#Submit'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo									 int = 0				-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText								 nvarchar(4000) -- message text for business rule errors
	 ,@blankParm								 varchar(50)		-- tracks name of any required parameter not passed
	 ,@registrantLearningPlanSID int						-- key of learning plan found (if any)
	 ,@profileUpdateSID					 int						-- key of profile update found (if any)
	 ,@formResponseDraft				 xml						-- form content being submitted
	 ,@formVersionSID						 int						-- version of the form to obtain definition for
	 ,@currentFormStatusSCD			 varchar(25);		-- current status of the record

	begin try

-- SQL Prompt formatting off
		if @ParentRowGUID			is null set @blankParm = '@ParentRowGUID';
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

		-- default registration year to the current year if not passed

		if @RegistrationYear is null
		begin
			set @RegistrationYear = dbo.fRegistrationYear#Current();
		end;

		begin transaction;

		-- first check for a learning plan for the registrant and registration year

		select
			@registrantLearningPlanSID = rlp.RegistrantLearningPlanSID
		 ,@formResponseDraft				 = rlp.FormResponseDraft
		 ,@formVersionSID						 = rlp.FormVersionSID
		 ,@currentFormStatusSCD			 = cs.FormStatusSCD
		from
			dbo.RegistrantLearningPlan																												 rlp
		cross apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
		cross apply dbo.fRegistrantLearningPlan#Ext(rlp.RegistrantLearningPlanSID) rlpx
		where
			rlp.ParentRowGUID = @ParentRowGUID and (@RegistrationYear between rlp.RegistrationYear and rlpx.CycleEndRegistrationYear);

		if @registrantLearningPlanSID is not null -- if no form found assume this form type was not in the set (not an error)
			 and @currentFormStatusSCD in ('WITHDRAWN', 'REJECTED', 'AWAITINGDOCS')
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'FormNotComplete'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 form is not complete (status is %2). Please complete and submit the form or contact Administration for assistance.'
			 ,@Arg1 = 'continuing competence/education'
			 ,@Arg2 = @currentFormStatusSCD;

			raiserror(@errorText, 16, 1);
		end;

		if @registrantLearningPlanSID is not null and @currentFormStatusSCD not in ('SUBMITTED', 'APPROVED')
		begin

			exec dbo.pRegistrantLearningPlan#Update
				@RegistrantLearningPlanSID = @registrantLearningPlanSID
			 ,@FormResponseDraft = @formResponseDraft
			 ,@FormVersionSID = @formVersionSID
			 ,@NewFormStatusSCD = 'SUBMITTED';

		end;

		-- check for a profile update

		select
			@profileUpdateSID			= pu.ProfileUpdateSID
		 ,@formResponseDraft		= pu.FormResponseDraft
		 ,@formVersionSID				= pu.FormVersionSID
		 ,@currentFormStatusSCD = cs.FormStatusSCD
		from
			dbo.ProfileUpdate																										pu
		cross apply dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) cs
		where
			pu.ParentRowGUID = @ParentRowGUID;

		if @profileUpdateSID is not null -- if no form found assume this form type was not in the set (not an error)
			 and @currentFormStatusSCD in ('WITHDRAWN', 'REJECTED', 'AWAITINGDOCS')
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'FormNotComplete'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 form is not complete (status is %2). Please complete and submit the form or contact Administration for assistance.'
			 ,@Arg1 = 'profile update'
			 ,@Arg2 = @currentFormStatusSCD;

			raiserror(@errorText, 16, 1);
		end;

		if @profileUpdateSID is not null and @currentFormStatusSCD not in ('SUBMITTED', 'APPROVED')
		begin

			exec dbo.pProfileUpdate#Update
				@ProfileUpdateSID = @profileUpdateSID
			 ,@FormResponseDraft = @formResponseDraft
			 ,@FormVersionSID = @formVersionSID
			 ,@NewFormStatusSCD = 'SUBMITTED';

		end;

		commit;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
