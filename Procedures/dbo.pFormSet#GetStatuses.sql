SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pFormSet#GetStatuses
	@FormSID			 int							-- key of parent form type (e.g. renewal form, application form, etc.)
 ,@ParentRowGUID uniqueidentifier -- GUID identifying the instance of the form (e.g. the member renewal)
as
/*********************************************************************************************************************************
Sproc    : Form Set - Get Statuses
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure returns status information on a set of forms for presentation in the UI
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Dec 2017 		| Initial version
					: Cory Ng			| Mar 2018		| Check if open profile update already exists then assign that to avoid multiple open forms
					: Tim Edlund	| Jun 2018		| FK in RegistrantApp changed from RegistrantSID to RegistrationSID + cycle duration checked
					: Cory Ng			| Jul 2018		| Fixed bug where second learning plan wasn't added for multi-year cycles
					: Tim Edlund	| Aug 2018		| Applied bits from Learning Model and Practice Register to control adding form for new year
					: Tim Edlund	| Sep 2018		| Updated logic for determining current step to use last validate time
					: Cory Ng			| Nov 2018		| Updated logic for determining current step to treat RETURNED as NEW to force members to
																				review the full form set when returned for updates
					: Cory Ng			| Dec 2018		| Updated so @isNextCEFormAutoAdded only controls adding a new form to the DB, if form 
																				already exists it won't exclude it from the form set based on the bit
 
Comments
--------
This procedure is called from the UI to support scenarios where a set of forms is used to complete a process. A form set is 
defined by a parent form and one or more sub-forms.  Parent forms include Renewal, Application, Reinstatement.  Sub-forms include
Profile Updates and Learning Plans.  The sub-forms are associated with their parent forms based on storing the RowGUID value from
the parent form record in the in the ParentRowGUID column of the sub-form record. 

If a sub-form has not yet been created for the ParentRowGUID passed in, then a record for it is created.

The procedure returns a data set summarizing status of each form including identifying which form is the current-step in the
process.  The current step is identified as the first form in the form-set sequence that has not been submitted.  If all forms
have been submitted then the first form in the sequence is identified as the current step.

Two (2) Learning Plan Forms
---------------------------
Learning plans are expected to be associated with a parent Renewal form.  As many as 2 learning plan forms may be inserted; one 
for the year of renewal and one for the following year. Note that if the cycle length for continuing education requirements
is greater than 1 year, then only 1 learning plan form (record) may be required.  For example, if a learning plan exists
that was started in 2019 and the current year is 2020, and the cycle length is 3 years - then the same plan must be used for
entering 2021 activities and no additional record requires inserting.  When the 2021 renewal is completed however, an additional
learning plan form will be inserted in order to accept 2022 activities. 

Note also that learning plans may be created independently of renewal and so if a learning plan already exists for the given 
registrant and year required, it is connected with the parent renewal form (via the GUID) rather than inserting an additional 
record. The connected learning plans are set back to a NEW status if not already in that status and if its not in a final status. 
This forces the registrant to review the learning plan forms again at the time of renewal. 

A Transaction is Applied
------------------------
If the Parent Row GUID Is invalid, and, a sub-form appears before the main form in the form-set sequence, then the child form
will be inserted.  The invalid GUID is identified in a later iteration of the loop.  To ensure no invalid forms are stored
the procedure runs in a transaction to that any invalid inserts are rolled back.

Call Syntax
-----------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			declare
	      @formSID			 int
       ,@parentRowGUID uniqueidentifier;

      select top (1)
	      @formSID			 = fv.FormSID
       ,@parentRowGUID = rr.RowGUID
      from
	      dbo.RegistrantRenewal rr
      join
	      sf.FormVersion				fv on rr.FormVersionSID = fv.FormVersionSID
      order by
	      newid();

      exec dbo.pFormSet#GetStatuses
	      @FormSID = @formSID
       ,@ParentRowGUID = @parentRowGUID

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pFormSet#GetStatuses'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo								int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText							nvarchar(4000)										-- message text for business rule errors
	 ,@blankParm							varchar(50)												-- tracks name of any required parameter not passed
	 ,@ON											bit							 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF										bit							 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@nextFormTypeSCD				varchar(25)												-- type of next form/sub-form to process
	 ,@personSID							int																-- key of person to create sub-form for (for Profile Update)
	 ,@registrantSID					int																-- key of the registrant to process sub-forms for
	 ,@registrationYear				smallint													-- membership year the sub-form applies to 
	 ,@recordSID							int																-- key of form record
	 ,@i											int																-- loop iteration counter
	 ,@nextYear								smallint													-- loop iteration counter for learning plans
	 ,@maxrow									int																-- loop limit
	 ,@formStatusSCD					varchar(25)												-- status of the pre-existing form
	 ,@maxLastValidateTime		datetimeoffset(7)									-- last sub-form validation time
	 ,@isCycleStartedYear1		bit																-- indicates if a learning plan is required in first year of active practice
	 ,@isNextCEFormAutoAdded	bit																-- indicates whether a new learning plan is automatically for the current year when previous completes
	 ,@isLearningPlanRequired bit																-- stores calculation of whether learning plan is required for the given year
	 ,@isFinal								bit; 															-- indicates if the pre-existing form is in a final status

	declare @work table
	(
		ID										int								not null identity(1, 1)
	 ,FormSID								int								not null
	 ,FormTypeSCD						varchar(25)				not null
	 ,FormLabel							nvarchar(35)			not null
	 ,FormSequence					int								not null
	 ,IsCurrentStep					bit								not null default cast(0 as bit)
	 ,RegistrantFormSID			int								null
	 ,RegistrationYear			smallint					null	-- not set for profile updates
	 ,RegistrationYearLabel varchar(25)				null
	 ,FormVersionSID				int								null
	 ,FormStatusSCD					varchar(25)				null
	 ,FormStatusLabel				nvarchar(35)			null
	 ,InvoiceSID						int								null
	 ,IsPaid								bit								not null default cast(0 as bit)
	 ,IsEditEnabled					bit								not null default cast(0 as bit)
	 ,LastValidateTime			datetimeoffset(7) null
	 ,LastStatusChangeTime	datetimeoffset(7) null
	 ,LastStatusChangeUser	nvarchar(75)			null
	);

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @FormSID	is null set @blankParm = '@FormSID'
		if @ParentRowGUID				is null set @blankParm = '@ParentRowGUID';
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

		-- check if the form passed in is part of a form-set; if it is 
		-- its sub-forms are loaded into a work table for processing

		insert
			@work (FormSID, FormTypeSCD, FormLabel, FormSequence, FormVersionSID)
		select
			fsf.FormSID
		 ,fsf.FormTypeSCD
		 ,fsf.FormLabel
		 ,fsf.FormSequence
		 ,fsf.FormVersionSID
		from
			sf.fForm#SubForms(@FormSID) fsf
		order by
			case when fsf.FormSequence = 100 then -1 else fsf.FormSequence end; -- ensures the main form is first before the sub forms

		set @maxrow = @@rowcount;
		set @i = 0;

		begin transaction;

		while @i < @maxrow
		begin
			set @i += 1;

			select
				@nextFormTypeSCD = w.FormTypeSCD
			from
				@work				w
			join
				sf.FormType ft on w.FormTypeSCD = ft.FormTypeSCD
			where
				w.ID = @i;

			if @nextFormTypeSCD like 'RENEWAL%'
			begin

				-- validate the GUID passed and retrieve values required
				-- for sub-form record inserts

				select
					@personSID						 = r.PersonSID
				 ,@registrantSID				 = r.RegistrantSID
				 ,@registrationYear			 = rr.RegistrationYear
				 ,@isNextCEFormAutoAdded = pr.IsNextCEFormAutoAdded -- configuration value for adding learning plan form for next (renewal) year
				 ,@isCycleStartedYear1	 = lm.IsCycleStartedYear1		-- configuration value for adding learning plans in first year of active practice
				from
					dbo.RegistrantRenewal				rr
				join
					dbo.Registration						rl on rr.RegistrationSID						 = rl.RegistrationSID
				join
					dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				join
					dbo.PracticeRegister				pr on prs.PracticeRegisterSID				 = pr.PracticeRegisterSID
				join
					dbo.Registrant							r on rl.RegistrantSID								 = r.RegistrantSID
				left outer join
					dbo.LearningModel						lm on pr.LearningModelSID						 = lm.LearningModelSID -- join through register to get to learning model
				where
					rr.RowGUID = @ParentRowGUID;

				if @registrantSID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'RecordNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					 ,@Arg1 = 'dbo.RegistrantRenewal'
					 ,@Arg2 = @ParentRowGUID;

					raiserror(@errorText, 18, 1);
				end;

				update
					w
				set
					w.RegistrantFormSID = rr.RegistrantRenewalSID
				 ,w.RegistrationYear = rr.RegistrationYear
				 ,w.RegistrationYearLabel = rsy.RegistrationYearLabel
				 ,w.FormVersionSID = isnull(rr.FormVersionSID, w.FormVersionSID)	-- show latest form version if no form record exists
				 ,w.FormStatusSCD = cs.FormStatusSCD
				 ,w.FormStatusLabel = sf.fAltLanguage#Field(fs.RowGUID, 'FormStatusLabel', fs.FormStatusLabel, null)
				 ,w.InvoiceSID = rr.InvoiceSID
				 ,w.IsPaid = (case when rr.InvoiceSID is null then @OFF when isnull(x.IsUnPaid, @ON) = @ON then @OFF else @ON end)
				 ,w.IsEditEnabled = isnull(x.IsEditEnabled, @OFF)
				 ,w.LastValidateTime = rr.LastValidateTime
				 ,w.LastStatusChangeTime = x.LastStatusChangeTime
				 ,w.LastStatusChangeUser = x.LastStatusChangeUser
				from
					@work																																		 w
				join
					dbo.RegistrantRenewal																										 rr on rr.RowGUID = @ParentRowGUID
				join
					dbo.vRegistrationScheduleYear																						 rsy on rr.RegistrationYear = rsy.RegistrationYear
				cross apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) cs
				cross apply dbo.fRegistrantRenewal#Ext(rr.RegistrantRenewalSID) x
				join
					sf.FormStatus fs on cs.FormStatusSID = fs.FormStatusSID
				where
					w.ID = @i;

			end;
			else if @nextFormTypeSCD like 'APPLICATION%'
			begin

				-- validate the GUID passed and retrieve values required
				-- for sub-form record inserts

				select
					@personSID				= r.PersonSID
				 ,@registrantSID		= r.RegistrantSID
				 ,@registrationYear = ra.RegistrationYear
				from
					dbo.RegistrantApp ra
				join
					dbo.Registration	reg on ra.RegistrationSID = reg.RegistrationSID
				join
					dbo.Registrant		r on reg.RegistrantSID		= r.RegistrantSID
				where
					ra.RowGUID = @ParentRowGUID;

				if @registrantSID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'RecordNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					 ,@Arg1 = 'dbo.RegistrantApp'
					 ,@Arg2 = @ParentRowGUID;

					raiserror(@errorText, 18, 1);
				end;

				update
					w
				set
					w.RegistrantFormSID = ra.RegistrantAppSID
				 ,w.RegistrationYear = ra.RegistrationYear
				 ,w.RegistrationYearLabel = rsy.RegistrationYearLabel
				 ,w.FormVersionSID = isnull(ra.FormVersionSID, w.FormVersionSID)	-- show latest form version if no form record exists
				 ,w.FormStatusSCD = cs.FormStatusSCD
				 ,w.FormStatusLabel = sf.fAltLanguage#Field(fs.RowGUID, 'FormStatusLabel', fs.FormStatusLabel, null)
				 ,w.InvoiceSID = ra.InvoiceSID
				 ,w.IsPaid = (case when ra.InvoiceSID is null then @OFF when isnull(x.IsUnPaid, @ON) = @ON then @OFF else @ON end)
				 ,w.IsEditEnabled = isnull(x.IsEditEnabled, @OFF)
				 ,w.LastValidateTime = ra.LastValidateTime
				 ,w.LastStatusChangeTime = x.LastStatusChangeTime
				 ,w.LastStatusChangeUser = x.LastStatusChangeUser
				from
					@work																																w
				join
					dbo.RegistrantApp																										ra on ra.RowGUID = @ParentRowGUID
				join
					dbo.vRegistrationScheduleYear																				rsy on ra.RegistrationYear = rsy.RegistrationYear
				outer apply dbo.fRegistrantApp#CurrentStatus(ra.RegistrantAppSID, -1) cs
				outer apply dbo.fRegistrantApp#Ext(ra.RegistrantAppSID) x
				join
					sf.FormStatus fs on cs.FormStatusSID = fs.FormStatusSID
				where
					w.ID = @i;

			end;
			else if @nextFormTypeSCD like 'REINSTATEMENT%'
			begin

				-- validate the GUID passed and retrieve values required
				-- for sub-form record inserts

				select
					@personSID				= r.PersonSID
				 ,@registrantSID		= r.RegistrantSID
				 ,@registrationYear = rin.RegistrationYear
				 ,@isNextCEFormAutoAdded = pr.IsNextCEFormAutoAdded -- configuration value for adding learning plan form for next (renewal) year
				 ,@isCycleStartedYear1	 = lm.IsCycleStartedYear1		-- configuration value for adding learning plans in first year of active practice
				from
					dbo.Reinstatement rin
				join
					dbo.Registration	rl on rin.RegistrationSID = rl.RegistrationSID
				join
					dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				join
					dbo.PracticeRegister				pr on prs.PracticeRegisterSID				 = pr.PracticeRegisterSID
				join
					dbo.Registrant		r on rl.RegistrantSID			= r.RegistrantSID
				left outer join
					dbo.LearningModel						lm on pr.LearningModelSID						 = lm.LearningModelSID -- join through register to get to learning model
				where
					rin.RowGUID = @ParentRowGUID;

				if @registrantSID is null
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'RecordNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					 ,@Arg1 = 'dbo.Reinstatement'
					 ,@Arg2 = @ParentRowGUID;

					raiserror(@errorText, 18, 1);
				end;

				update
					w
				set
					w.RegistrantFormSID = rin.ReinstatementSID
				 ,w.RegistrationYear = rin.RegistrationYear
				 ,w.RegistrationYearLabel = rsy.RegistrationYearLabel
				 ,w.FormVersionSID = isnull(rin.FormVersionSID, w.FormVersionSID) -- show latest form version if no form record exists
				 ,w.FormStatusSCD = cs.FormStatusSCD
				 ,w.FormStatusLabel = sf.fAltLanguage#Field(fs.RowGUID, 'FormStatusLabel', fs.FormStatusLabel, null)
				 ,w.InvoiceSID = rin.InvoiceSID
				 ,w.IsPaid = (case when rin.InvoiceSID is null then @OFF when isnull(x.IsUnPaid, @ON) = @ON then @OFF else @ON end)
				 ,w.IsEditEnabled = isnull(x.IsEditEnabled, @OFF)
				 ,w.LastValidateTime = rin.LastValidateTime
				 ,w.LastStatusChangeTime = x.LastStatusChangeTime
				 ,w.LastStatusChangeUser = x.LastStatusChangeUser
				from
					@work																														 w
				join
					dbo.Reinstatement																								 rin on rin.RowGUID = @ParentRowGUID
				join
					dbo.vRegistrationScheduleYear																		 rsy on rin.RegistrationYear = rsy.RegistrationYear
				cross apply dbo.fReinstatement#CurrentStatus(rin.ReinstatementSID, -1) cs
				cross apply dbo.fReinstatement#Ext(rin.ReinstatementSID) x
				join
					sf.FormStatus fs on cs.FormStatusSID = fs.FormStatusSID
				where
					w.ID = @i;

			end;
			else if @nextFormTypeSCD like '%AUDIT%'
			begin

				update
					w
				set
					w.RegistrantFormSID = ra.RegistrantAuditSID
				 ,w.RegistrationYear = ra.RegistrationYear
				 ,w.RegistrationYearLabel = rsy.RegistrationYearLabel
				 ,w.FormVersionSID = isnull(ra.FormVersionSID, w.FormVersionSID)	-- show latest form version if no form record exists
				 ,w.FormStatusSCD = cs.FormStatusSCD
				 ,w.FormStatusLabel = sf.fAltLanguage#Field(fs.RowGUID, 'FormStatusLabel', fs.FormStatusLabel, null)
				 ,w.InvoiceSID = null
				 ,w.IsPaid = @OFF																									-- audits are never invoiced so value is always 0
				 ,w.IsEditEnabled = isnull(x.IsEditEnabled, @OFF)
				 ,w.LastValidateTime = ra.LastValidateTime
				 ,w.LastStatusChangeTime = x.LastStatusChangeTime
				 ,w.LastStatusChangeUser = x.LastStatusChangeUser
				from
					@work																																 w
				join
					dbo.RegistrantAudit																									 ra on ra.RowGUID = @ParentRowGUID
				join
					dbo.vRegistrationScheduleYear																				 rsy on ra.RegistrationYear = rsy.RegistrationYear
				cross apply dbo.fRegistrantAudit#CurrentStatus(ra.RegistrantAuditSID, -1) cs
				cross apply dbo.fRegistrantAudit#Ext(ra.RegistrantAuditSID) x
				join
					sf.FormStatus fs on cs.FormStatusSID = fs.FormStatusSID
				where
					w.ID = @i;

			end;
			else if @nextFormTypeSCD like 'LEARNINGPLAN%'
			begin

				-- learning plan forms are required for both the registration year
				-- of the renewal and the following year

				if @registrationYear is not null -- will be null in the case where a learning plan is the ParentGUID passed (otherwise sub-form of renewal)
				begin
					
					set @nextYear = @registrationYear - 2; -- the registration year is the renewal year; forms for the previous year (and possibly the next year) are required					

					while @nextYear < @registrationYear
					begin

						set @nextYear += 1; -- starting point is the year prior to renewal (the current registration year)

						-- if a learning plan is not required in the first year of active practice,
						-- check the previous year; if they were not practicing no plan is added

						if @isCycleStartedYear1 = @OFF
						begin

							select
								@isLearningPlanRequired = isnull(rlr.IsActivePractice, @OFF)
							from
								dbo.fRegistrant#LatestRegistration(@registrantSID, @nextYear - 1) rlr;

						end;
						else -- otherwise a learning plan is added (requirements may be provided for new members) 
						begin
							set @isLearningPlanRequired = @ON;
						end;

						if @isLearningPlanRequired = @ON
						begin

							set @recordSID = null;

							select
								@recordSID = rlp.RegistrantLearningPlanSID
							from
								dbo.RegistrantLearningPlan																							 rlp
							cross apply dbo.fRegistrantLearningPlan#Ext(rlp.RegistrantLearningPlanSID) x
							where
								rlp.ParentRowGUID = @ParentRowGUID and (@nextYear between rlp.RegistrationYear and x.CycleEndRegistrationYear); -- check for plan with cycle covering the target year

							if @recordSID is null
							begin

								-- learning plans can be created independently of the parent
								-- form and then "attached" during renewal/application - so check
								-- for a form for the target year before inserting (no parent GUID)

								set @recordSID = null;

								select
									@recordSID		 = rlp.RegistrantLearningPlanSID
								 ,@formStatusSCD = cs.FormStatusSCD
								 ,@isFinal			 = cs.IsFinal
								from
									dbo.RegistrantLearningPlan																												 rlp
								cross apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
								cross apply dbo.fRegistrantLearningPlan#Ext(rlp.RegistrantLearningPlanSID) x
								where
									rlp.RegistrantSID = @registrantSID and (@nextYear between rlp.RegistrationYear and x.CycleEndRegistrationYear);

								if @recordSID is not null
								begin

									exec dbo.pRegistrantLearningPlan#Update
										@RegistrantLearningPlanSID = @recordSID
									 ,@ParentRowGUID = @ParentRowGUID;

									if @formStatusSCD <> 'NEW' and @isFinal = @OFF
									begin

										exec dbo.pRegistrantLearningPlanStatus#Insert
											@RegistrantLearningPlanSID = @recordSID
										 ,@FormStatusSCD = 'NEW';

										update
											dbo.RegistrantLearningPlan
										set
											LastValidateTime = null
										where
											RegistrantLearningPlanSID = @recordSID;  -- remove validation time as part of resetting form to NEW

									end;

								end;
								else if @nextYear < @registrationYear or @isNextCEFormAutoAdded = @ON
								begin

									exec dbo.pRegistrantLearningPlan#Insert
										@RegistrantLearningPlanSID = @recordSID output
									 ,@RegistrantSID = @registrantSID
									 ,@RegistrationYear = @nextYear
									 ,@ParentRowGUID = @ParentRowGUID;

								end;

							end;

							-- update the work table with the key of the registrant 
							-- learning plan to support the UPDATE below

							update
								@work
							set
								RegistrantFormSID = @recordSID
							where
								ID = @i and RegistrantFormSID is null;	-- look for the record not yet updated (null key)

							if @nextYear = @registrationYear and @recordSID is not null
							begin

								-- a second @work row is inserted for the second learning
								-- plan just added/update 

								insert
									@work
								(
									FormSID
								 ,FormTypeSCD
								 ,FormLabel
								 ,FormSequence
								 ,FormVersionSID
								 ,RegistrantFormSID
								)
								select
									w.FormSID
								 ,w.FormTypeSCD
								 ,w.FormLabel
								 ,w.FormSequence
								 ,w.FormVersionSID
								 ,@recordSID
								from
									@work w
								left outer join
									@work xw on w.FormTypeSCD = xw.FormTypeSCD and xw.RegistrantFormSID = @recordSID
								where
									w.ID = @i and xw.RegistrantFormSID is null;

							end;

						end;

					end;

				end;

				-- now update both rows for status using the form-type as 
				-- the selection criteria

				update
					w
				set
					w.RegistrationYear = rlp.RegistrationYear
				 ,w.RegistrationYearLabel = x.CycleRegistrationYearLabel
				 ,w.FormVersionSID = isnull(rlp.FormVersionSID, w.FormVersionSID) -- show latest form version if no form record exists
				 ,w.FormStatusSCD = cs.FormStatusSCD
				 ,w.FormStatusLabel = sf.fAltLanguage#Field(fs.RowGUID, 'FormStatusLabel', fs.FormStatusLabel, null)
				 ,w.InvoiceSID = null
				 ,w.IsPaid = @OFF																									-- learning plans are never invoiced so value is always 0
				 ,w.IsEditEnabled = isnull(x.IsEditEnabled, @OFF)
				 ,w.LastValidateTime = rlp.LastValidateTime
				 ,w.LastStatusChangeTime = x.LastStatusChangeTime
				 ,w.LastStatusChangeUser = x.LastStatusChangeUser
				from
					@work																																							 w
				join
					dbo.RegistrantLearningPlan																												 rlp on w.RegistrantFormSID = rlp.RegistrantLearningPlanSID
				cross apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
				cross apply dbo.fRegistrantLearningPlan#Ext(rlp.RegistrantLearningPlanSID) x
				join
					sf.FormStatus fs on cs.FormStatusSID = fs.FormStatusSID
				where
					w.FormTypeSCD = @nextFormTypeSCD;

			end;
			else if @nextFormTypeSCD like 'PROFILE.UPDATE%'
			begin

				set @recordSID = null;

				select
					@recordSID = pu.ProfileUpdateSID
				from
					dbo.ProfileUpdate pu
				where
					pu.ParentRowGUID = @ParentRowGUID;

				if @recordSID is null
				begin

					-- profile updates can be created independently of the parent
					-- form and to avoid multiple profile updates open at the same 
					-- time - check for a open form before inserting (no parent GUID)

					set @recordSID = null;

					select
						@recordSID		 = pu.ProfileUpdateSID
					 ,@formStatusSCD = cs.FormStatusSCD
					from
						dbo.ProfileUpdate																										pu
					cross apply dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) cs
					where
						pu.PersonSID = @personSID and cs.IsFinal = @OFF;

					if @recordSID is not null
					begin

						exec dbo.pProfileUpdate#Update
							@ProfileUpdateSID = @recordSID
						 ,@ParentRowGUID = @ParentRowGUID;

						if @formStatusSCD <> 'NEW'
						begin

							exec dbo.pProfileUpdateStatus#Insert
								@ProfileUpdateSID = @recordSID
							 ,@FormStatusSCD = 'NEW';

							update
								dbo.ProfileUpdate
							set
								LastValidateTime = null
							where
								ProfileUpdateSID = @recordSID; -- remove validation time as part of resetting form to NEW

						end;

					end;
					else
					begin

						exec dbo.pProfileUpdate#Insert
							@PersonSID = @personSID
						 ,@ParentRowGUID = @ParentRowGUID;

					end;

				end;

				update
					w
				set
					w.RegistrantFormSID = pu.ProfileUpdateSID
				 ,w.FormVersionSID = isnull(pu.FormVersionSID, w.FormVersionSID)	-- show latest form version if no form record exists
				 ,w.FormStatusSCD = cs.FormStatusSCD
				 ,w.FormStatusLabel = sf.fAltLanguage#Field(fs.RowGUID, 'FormStatusLabel', fs.FormStatusLabel, null)
				 ,w.InvoiceSID = null
				 ,w.IsPaid = @OFF																									-- profile updates are never invoiced so value is always 0
				 ,w.IsEditEnabled = isnull(x.IsEditEnabled, @OFF)
				 ,w.LastValidateTime = pu.LastValidateTime
				 ,w.LastStatusChangeTime = x.LastStatusChangeTime
				 ,w.LastStatusChangeUser = x.LastStatusChangeUser
				from
					@work																																w
				join
					dbo.ProfileUpdate																										pu on pu.ParentRowGUID = @ParentRowGUID
				cross apply dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) cs
				cross apply dbo.fProfileUpdate#Ext(pu.ProfileUpdateSID) x
				join
					sf.FormStatus fs on cs.FormStatusSID = fs.FormStatusSID
				where
					w.ID = @i;

			end;
			else
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NotRecognized'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The option %1 record was not recognized in this context.'
				 ,@Arg1 = @nextFormTypeSCD;

				raiserror(@errorText, 18, 1);

			end;

		end;

		-- where a form is not required, no key has been set for
		-- it and it must be removed from the UI (work table)

		delete @work where RegistrantFormSID is null;

		commit;

		-- set the current step to the next NEW (not submitted) status form in 
		-- the series following the one last validated; if none of the forms 
		-- meet the criteria then the last form is the current step

		select @maxLastValidateTime	 = max(w.LastValidateTime) from @work w;

		if @maxLastValidateTime is null
		begin
			set @i = -1; -- if no forms are validated set to -1 to avoid filtering below
		end;
		else
		begin

			select
				@i = w.FormSequence
			from
				@work w
			where
				w.LastValidateTime = @maxLastValidateTime;

		end;

		select top (1)
			@i = w.ID
		from
			@work w
		left join
		(
			select
				 x.FormStatusSCD
				,row_number() over (order by x.FormSequence desc) RowNo
			from
				@work x
		) ms on ms.RowNo = 1
		where
			w.FormStatusSCD	 in ('NEW', 'RETURNED') -- find next new form
			and
			isnull(ms.FormStatusSCD, '') <> 'APPROVED' --skip logic when the renewal has already been approved
			and
			(
				w.FormSequence > @i or (w.FormSequence = @i and w.LastValidateTime is null)
			) -- form is later in sequence than the one last validated (or same sequence and not validated)
		order by
			w.FormSequence
		 ,w.ID;

		if @@rowcount = 0 or isnull(@i, -1) = -1
		begin
			select top (1) @i	= w.ID from @work w order by	 w.FormSequence desc, w.ID;
		end;

		update @work set IsCurrentStep = @ON where ID	 = @i;

		-- return form status dataset

		select
			w.FormSequence
		 ,w.FormSID
		 ,w.FormTypeSCD
		 ,w.FormLabel
		 ,w.IsCurrentStep
		 ,w.RegistrantFormSID
		 ,w.RegistrationYear
		 ,w.RegistrationYearLabel
		 ,w.FormVersionSID
		 ,w.FormStatusSCD
		 ,w.FormStatusLabel
		 ,w.InvoiceSID
		 ,w.IsPaid
		 ,w.IsEditEnabled
		 ,w.LastStatusChangeTime
		 ,w.LastStatusChangeUser
		from
			@work w
		order by
			w.FormSequence
		 ,w.ID;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
