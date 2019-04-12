SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pSubForms#Approve
	@ParentRowGUID		uniqueidentifier	-- unique identifier of the parent form (e.g. of the Renewal or Application form)
 ,@RegistrationYear smallint = null		-- registration year of the form to be approved (distinguishes if multiple forms for GUID)
as
/*********************************************************************************************************************************
Procedure	: Sub Forms - Approve
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: This procedure checks for the existence of sub-forms related to the parent GUID passed and set them approved
----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Dec 2017		|	Initial version
					: Tim Edlund	| Jun 2018		| Avoid approving learning plan forms where cycle of the LP has not yet ended
					: Cory Ng			| Sep 2018		| Set learning plan status to "returned" if its not the last year of the cycle
					: Taylor N		| Oct 2018		| Only insert the approved status if the form is not already in a final status
 
Comments
--------
This procedure is called from #Approve procedures of parent forms like Renewal, Application and Reinstatement.  It checks 
for the existence of sub-forms (Learning Plan, Profile Update) which are related to the parent form through the row GUID on the
parent form. If the sub-form is found and it is not already in an APPROVED status then its #Approve procedure is called.

Example
-------
<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Approve a renewal form with a learning sub-form at random">
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
	cs.FormStatusSCD = 'SUBMITTED'
order by
	newid();

if @parentRowGUID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction; -- rollback data to avoid using up test scenario records

	exec dbo.pSubForms#Approve
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
	 @ObjectName			= 'dbo.pSubForms#Approve'
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
	 ,@formResponseDraft				 xml						-- form content being approved
	 ,@formVersionSID						 int						-- version of the form to obtain definition for
	 ,@currentFormStatusIsFinal	 bit						-- whether the current status is final
	 ,@cycleEndRegistrationYear	 smallint				-- registration year when current LP form's cycle ends
	 ,@formDefinition						 xml						-- xml of the form definition for the renewal
	 ,@ON                        bit = cast(1 as bit)			-- constant for bit comparison and assignments
	 ,@OFF                       bit = cast(0 as bit);		-- constant for bit comparison and assignments

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
		 ,@currentFormStatusIsFinal	 = cs.IsFinal
		 ,@formDefinition						 = fv.FormDefinition
		 ,@cycleEndRegistrationYear	 = rlpx.CycleEndRegistrationYear
		from
			dbo.RegistrantLearningPlan																												 rlp
		join
			sf.FormVersion																																		 fv on rlp.FormVersionSID = fv.FormVersionSID
		join
			sf.Form																																						 f on fv.FormSID = f.FormSID
		cross apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
		cross apply dbo.fRegistrantLearningPlan#Ext(rlp.RegistrantLearningPlanSID) rlpx
		where
			rlp.ParentRowGUID = @ParentRowGUID and (@RegistrationYear between rlp.RegistrationYear and rlpx.CycleEndRegistrationYear);

		if @registrantLearningPlanSID is not null and @currentFormStatusIsFinal = @OFF
		begin

			-- don't approve the form unless the continuing education
			-- cycle is now complete

			if @cycleEndRegistrationYear <= dbo.fRegistrationYear#Current()
			begin

				-- note that form will still submit if NEW, RETURNED, as well as
				-- SUBMITTED since renewal form set may not run SUBMIT action
				-- between sub-forms (configuration option)

				exec dbo.pRegistrantLearningPlan#Approve
					@RegistrantLearningPlanSID = @registrantLearningPlanSID
				 ,@FormResponseDraft = @formResponseDraft
				 ,@FormVersionSID = @formVersionSID
				 ,@FormDefinition = @formDefinition;

			end
			else
			begin
				
				exec dbo.pRegistrantLearningPlan#Update
					 @RegistrantLearningPlanSID = @registrantLearningPlanSID
					,@NewFormStatusSCD = 'RETURNED'

			end

		end;

		-- check for a profile update

		select
			@profileUpdateSID					 = pu.ProfileUpdateSID
		 ,@formResponseDraft				 = pu.FormResponseDraft
		 ,@formVersionSID						 = pu.FormVersionSID
		 ,@currentFormStatusIsFinal	 = cs.IsFinal
		 ,@formDefinition						 = fv.FormDefinition
		from
			dbo.ProfileUpdate																										pu
		join
			sf.FormVersion																											fv on pu.FormVersionSID = fv.FormVersionSID
		join
			sf.Form																															f on fv.FormSID = f.FormSID
		cross apply dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) cs
		where
			pu.ParentRowGUID = @ParentRowGUID;

		if @profileUpdateSID is not null and @currentFormStatusIsFinal = @OFF
		begin

			exec dbo.pProfileUpdate#Approve
				@ProfileUpdateSID = @profileUpdateSID
			 ,@FormResponseDraft = @formResponseDraft
			 ,@FormVersionSID = @formVersionSID
			 ,@FormDefinition = @formDefinition;

		end;

		commit;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
