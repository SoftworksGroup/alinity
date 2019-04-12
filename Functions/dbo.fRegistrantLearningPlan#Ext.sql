SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantLearningPlan#Ext (@RegistrantLearningPlanSID int) -- key of record to check
returns @registrantLearningPlan#Ext table
(
	IsViewEnabled											bit								not null	-- indicates whether either the (logged in) user or administrator can view the learning plan
 ,IsEditEnabled											bit								not null	-- indicates whether the (logged in) user can edit/correct the form
 ,IsSaveBtnDisplayed								bit								not null	-- indicates whether save button is displayed (configuration through sf.FormVersion + BR's)
 ,IsApproveEnabled									bit								not null	-- indicates whether the approve button should be made available to the user
 ,IsRejectEnabled										bit								not null	-- indicates whether the reject button should be made available to the user
 ,IsUnlockEnabled										bit								not null	-- indicates administrator can unlock form for editing even when in certain final statuses
 ,IsWithdrawalEnabled								bit								not null	-- indicates the learning plan form can be withdrawn by administrators or SA's
 ,IsInProgress											bit								not null	-- indicates if the form is now closed/finalized or still in progress (open)	 
 ,RegistrantLearningPlanStatusSID		int								not null	-- key of current/latest learning plan status 
 ,RegistrantLearningPlanStatusSCD		varchar(25)				not null	-- current/latest learning plan status		
 ,RegistrantLearningPlanStatusLabel nvarchar(35)			not null	-- user-friendly name for the learning plan status		
 ,LastStatusChangeUser							nvarchar(75)			not null	-- username who made the last status change
 ,LastStatusChangeTime							datetimeoffset(7) not null	-- date and time the last status change was made
 ,FormOwnerSCD											varchar(25)				not null	-- person/group expected to perform next action to progress the form
 ,FormOwnerLabel										nvarchar(35)			not null	-- user-friendly name of person/group expected to perform next action to progress the form
 ,FormOwnerSID											int								not null	-- key of the form owner expected to perform the next action to progress the form
 ,IsPDFDisplayed										bit								not null	-- indicates if PDF form version should be displayed rather than the HTML (form is complete)
 ,PersonDocSID											int								null			-- key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
 ,RegistrantLearningPlanLabel				nvarchar(80)			null			-- a summary label for the learning plan based on the register label and learning plan status
 ,RegistrationYearLabel							nvarchar(9)				null			-- label for starting registration year of plan using yyyy/yyyy format where non-calendar year
 ,CycleEndRegistrationYear					smallint					null			-- ending year for the CE cycle this plan reports on
 ,CycleRegistrationYearLabel				nvarchar(21)			null			-- label showing the display starting and display ending years of the CE cycle
)
as
/*********************************************************************************************************************************
TableF	: Registrant Learning Plan Extended Columns
Notice	: Copyright © 2017 Softworks Group Inc.
Summary	: Returns a table of calculated columns for the RegistrantLearningPlan extended view (vRegistrantLearningPlan#Ext)
History	: Author(s)  					| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund					| Dec 2017		|	Initial version
				: Tim Edlund					| Feb 2018		| Added IsPDFDisplayed + PersonDocSID to control when PDF is displayed instead of HTML
				: Tim Edlund					| Jun 2018		| Added support for CE cycle length and labels
				: Tim Edlund					| Sep 2018		| Updated logic to control editing when parent form (renewal) has been submitted
				: Tim Edlund					| Oct 2018		| Enabled unlock on approved plans where registrant is logged in within period
				: Tim Edlund					| Jan 2019		| Save enabled-bit changed to save-displayed and based on form version configuration

Comments	
--------
This function is called by the dbo.vRegistrantLearningPlan#Ext view to return a series of calculated values. By using a table 
function, many lookups required for the calculated values can be executed once rather than many times if separate functions are 
used.

This function expects to be selected for a single primary key value.  The function is not designed for inclusion in SELECTs 
scanning large portions of the table.  Performance in that context may not be acceptable and to resolve that, selected components 
of logic may need to be isolated into smaller functions that can be called separately.

RegistrantLearningPlanStatusSCD is obtained from a supporting view which retrieves the latest status change record for the form.

Unlike other form types, the registrant is able to edit their Learning Plan when in a SUBMITTED status.  They can continue to 
edit their Learning Plan until it is approved (or goes into another final status).  Approval of learning plans occurs when 
renewals are approved.

Example
-------
<TestHarness>
	<Test Name = "Simple" Description="Returns the extended columns for an instance of the entity at random.">
	<SQLScript>
	<![CDATA[

	begin tran
	
	  select 
	    rlpx.*    
	  from 
		(	select top 10 
				x.RegistrantLearningPlanSID
			from
				dbo.RegistrantLearningPlan x
			order by newid()
		) rlp
	  cross apply
	   dbo.fRegistrantLearningPlan#Ext(rlp.RegistrantLearningPlanSID) rlpx
	
	
	if @@rowcount = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
	if @@trancount > 0 rollback

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrantLearningPlan#Ext'	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@ON																 bit							= cast(1 as bit)											-- constant to eliminate repetitive casting syntax
	 ,@OFF															 bit							= cast(0 as bit)											-- constant to eliminate repetitive casting syntax
	 ,@isAdminLoggedIn									 bit							= cast(0 as bit)											-- indicates if current user is an administrator			
	 ,@isRegistrantLoggedIn							 bit							= cast(0 as bit)											-- indicates if the form registrant is the current user	
	 ,@isEditEnabled										 bit							= cast(0 as bit)											-- indicates whether the (logged in) user can edit/correct the form
	 ,@IsSaveBtnDisplayed								 bit							= cast(0 as bit)											-- indicates whether save button is displayed (configuration through sf.FormVersion + BR's)
	 ,@isApproveEnabled									 bit							= cast(0 as bit)											-- indicates whether the approve button should be made available to the user
	 ,@isRejectEnabled									 bit							= cast(0 as bit)											-- indicates whether the reject button should be made available to the user
	 ,@isUnlockEnabled									 bit							= cast(0 as bit)											-- indicates administrator can unlock form for editing even when in certain final statuses
	 ,@isWithdrawalEnabled							 bit							= cast(0 as bit)											-- indicates the learning plan form can be withdrawn by administrators or SA's
	 ,@isInProgress											 bit							= cast(0 as bit)											-- indicates if the form is now closed/finalized or still in progress (open)	 
	 ,@registrantSID										 int																										-- key of registrant learning plan is created for	 
	 ,@registrantLearningPlanStatusSID	 int																										-- key of current/latest learning plan status 
	 ,@registrantLearningPlanStatusSCD	 varchar(25)																						-- current/latest learning plan status		
	 ,@registrantLearningPlanStatusLabel nvarchar(35)																						-- user-friendly name for the learning plan status		
	 ,@lastStatusChangeUser							 nvarchar(75)																						-- username who made the last status change
	 ,@lastStatusChangeTime							 datetimeoffset(7)																			-- date and time the last status change was made
	 ,@formOwnerSCD											 varchar(25)																						-- person/group expected to perform next action to progress the main form
	 ,@formOwnerLabel										 nvarchar(35)																						-- user-friendly name of person/group expected to perform next action to progress the main form
	 ,@formOwnerSID											 int																										-- key of the form owner expected to perform the next action to progress the form
	 ,@isPDFDisplayed										 bit							= cast(0 as bit)											-- indicates if PDF form version should be displayed rather than the HTML (form is complete)
	 ,@personDocSID											 int																										-- key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
	 ,@applicationUserSID								 int							= sf.fApplicationUserSessionUserSID() -- key of currently logged in user - to enable read/write on learning plan
	 ,@parentRowGUID										 uniqueidentifier																				-- the parent form's row 
	 ,@applicationEntitySID							 int																										-- key of the learning plan entity; required to check for generated PDF
	 ,@registrantLearningPlanLabel			 nvarchar(80)																						-- a summary label for the learning plan based on the register label and learning plan status
	 ,@isReviewRequired									 bit																										-- indicates if learning plan forms require admin review (only admin can edit on submission)
	 ,@registrationYear									 smallint																								-- starting registration year of CE cycle
	 ,@registrationYearLabel						 nvarchar(9)																						-- label for starting registration year of plan using yyyy/yyyy format where non-calendar year
	 ,@parentFormStatusSCD							 varchar(25)																						-- current status of parent form (Renewal)
	 ,@cycleEndRegistrationYear					 smallint																								-- ending year for the CE cycle this plan reports on
	 ,@cycleRegistrationYearLabel				 nvarchar(21)																						-- label showing the display starting and display ending years of the CE cycle
	 ,@now															 datetime					= sf.fNow()														-- current time in user time zone
	 ,@isCollectionActive								 bit																										-- indicates if the CE collection period is currently open
	 ,@isCCPUnlockAfterApproveEnabled		 bit;

	set @isAdminLoggedIn = sf.fIsGrantedToUserSID('ADMIN.COMPETENCE', @applicationUserSID); -- grant is called "COMPETENCE" and provides access beyond learning plans only
	set @isReviewRequired = isnull(convert(bit, sf.fConfigParam#Value('LearningPlanRequireReview')), @OFF);
	set @isCCPUnlockAfterApproveEnabled = isnull(convert(bit, sf.fConfigParam#Value('CCPUnlockAfterApprove')), @OFF);

	-- retrieve the current status of the learning plan and set
	-- identity values for determining read/write status
	select
		@registrantLearningPlanStatusSID	 = rlpcs.RegistrantLearningPlanStatusSID
	 ,@registrantLearningPlanStatusSCD	 = rlpcs.FormStatusSCD
	 ,@registrantLearningPlanStatusLabel = rlpcs.FormStatusLabel
	 ,@IsSaveBtnDisplayed								 = fv.IsSaveDisplayed
	 ,@isInProgress											 = rlpcs.IsInProgress
	 ,@formOwnerSCD											 = rlpcs.FormOwnerSCD
	 ,@formOwnerLabel										 = rlpcs.FormOwnerLabel
	 ,@formOwnerSID											 = rlpcs.FormOwnerSID
	 ,@lastStatusChangeUser							 = rlpcs.CreateUser
	 ,@lastStatusChangeTime							 = rlpcs.CreateTime
	 ,@isRegistrantLoggedIn							 = (case when au.ApplicationUserSID = @applicationUserSID then @ON else @OFF end)
	 ,@registrantSID										 = rlp.RegistrantSID
	 ,@parentRowGUID										 = rlp.ParentRowGUID
	 ,@registrantLearningPlanLabel			 =
			dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRANT') + N' - '
			+ case when rlpcs.IsInProgress = cast(1 as bit) then ' In Progress' else rlpcs.FormStatusLabel end
	from
		dbo.RegistrantLearningPlan																												 rlp
	join
		dbo.Registrant																																		 r on rlp.RegistrantSID = r.RegistrantSID
	join
		sf.Person																																					 p on r.PersonSID = p.PersonSID
	join
		sf.FormVersion																																		 fv on rlp.FormVersionSID = fv.FormVersionSID
	join
		sf.Form																																						 f on fv.FormSID = f.FormSID
	join
		sf.ApplicationUser																																 au on p.PersonSID = au.PersonSID -- determine the user ID of the registrant
	left outer join
		dbo.Reason																																				 rsn on rlp.ReasonSID = rsn.ReasonSID
	outer apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) rlpcs	-- function determines the current status of the form
	where
		rlp.RegistrantLearningPlanSID = @RegistrantLearningPlanSID;

	-- lookup cycle information for the current learning plan and registrant

	select
		@cycleEndRegistrationYear = (rlp.RegistrationYear + lm.CycleLengthYears - 1)
	 ,@registrationYear					= rlp.RegistrationYear
	from
		dbo.RegistrantLearningPlan rlp
	join
		dbo.LearningModel					 lm on rlp.LearningModelSID = lm.LearningModelSID	 -- learning model has the cycle duration (add to start year)
	where
		rlp.RegistrantLearningPlanSID = @RegistrantLearningPlanSID;

	-- create a label for the registration year

	select
		@registrationYearLabel = (case
																when year(rsy.YearStartTime) = year(rsy.YearEndTime) then ltrim(rsy.RegistrationYear)
																else ltrim(year(rsy.YearStartTime)) + '/' + ltrim(year(rsy.YearEndTime))
															end
														 )
	 ,@isCollectionActive		 = (case when @now between rsy.CECollectionStartTime and rsy.CECollectionEndTime then @ON else @OFF end)
	from
		dbo.RegistrationSchedule		 rs
	join
		dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID = rsy.RegistrationScheduleSID and rsy.RegistrationYear = @registrationYear
	where
		rs.IsDefault = cast(1 as bit);

	if @cycleEndRegistrationYear > @registrationYear -- if cycle is more than 1 year in length
	begin

		select
			@cycleRegistrationYearLabel = ltrim(year(srsy.YearStartTime)) + N' - ' + ltrim(year(ersy.YearEndTime))
		 ,@isCollectionActive					= (case when @now between srsy.CECollectionStartTime and ersy.CECollectionEndTime then @ON else @OFF end)
		from
			dbo.RegistrationSchedule		 rs
		join
			dbo.RegistrationScheduleYear srsy on rs.RegistrationScheduleSID = srsy.RegistrationScheduleSID and srsy.RegistrationYear = @registrationYear
		join
			dbo.RegistrationScheduleYear ersy on rs.RegistrationScheduleSID = ersy.RegistrationScheduleSID and ersy.RegistrationYear = @cycleEndRegistrationYear
		where
			rs.IsDefault = cast(1 as bit);

	end;
	else
	begin
		set @cycleRegistrationYearLabel = @registrationYearLabel;
	end;

	-- set bit values controlling editing and unlock; if form is APPROVED then all
	-- actions are blocked since form details already written to DB records

	if @registrantLearningPlanStatusSCD = 'APPROVED'
		 and @isCollectionActive = @ON
		 and
		 (
			 @isAdminLoggedIn = @ON or (@isRegistrantLoggedIn = @ON and @isCCPUnlockAfterApproveEnabled = @ON)
		 )
	begin
		set @isUnlockEnabled = @ON;
	end;
	else if @registrantLearningPlanStatusSCD = 'REJECTED'
	begin
		set @isUnlockEnabled = @isAdminLoggedIn; -- form can be unlocked by admins when in this status
	end;
	else if @registrantLearningPlanStatusSCD = 'WITHDRAWN'
	begin

		-- unless this learning plans is the most recent, unlocking 
		-- a withdrawn record is not allowed 

		if @isAdminLoggedIn = @ON
		begin

			if @RegistrantLearningPlanSID =
			(
				select top (1)
					rlp.RegistrantLearningPlanSID
				from
					dbo.RegistrantLearningPlan rlp
				where
					rlp.RegistrantSID = @registrantSID
				order by
					rlp.RegistrationYear desc
			)
			begin
				set @isUnlockEnabled = @ON;
			end;

		end;
	end;
	else if @registrantLearningPlanStatusSCD = 'CORRECTED'
	begin

		set @isEditEnabled = @isAdminLoggedIn; -- admins can continue editing after saving a correction
		set @isApproveEnabled = @isAdminLoggedIn;
		set @isRejectEnabled = @isAdminLoggedIn;

	end;
	else if @registrantLearningPlanStatusSCD = 'UNLOCKED'
	begin

		set @isEditEnabled = @isAdminLoggedIn; -- admins can edit, return or assign a new final status
		set @isApproveEnabled = @isAdminLoggedIn;
		set @isRejectEnabled = @isAdminLoggedIn;

	end;
	else if @registrantLearningPlanStatusSCD in ('NEW', 'RETURNED', 'AWAITINGDOCS') -- normal statuses that allow registrant editing
	begin

		set @isEditEnabled = @isRegistrantLoggedIn;
		set @isUnlockEnabled = @isAdminLoggedIn;
		set @isApproveEnabled = @isAdminLoggedIn; -- edge case: admin may return form and not receive an update
		set @isRejectEnabled = @isAdminLoggedIn; -- but still decides to approve or reject the form

	end;
	else if @registrantLearningPlanStatusSCD = 'SUBMITTED' and @isReviewRequired = @OFF -- if review is required, user cannot edit after SUBMIT
	begin

		if @parentRowGUID is not null -- edit for registrant also blocked if parent form (renewal) is submitted until after APPROVAL
		begin

			select
				@parentFormStatusSCD = cs.FormStatusSCD
			from
				dbo.RegistrantRenewal																												rr
			outer apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) cs
			where
				rr.RowGUID = @parentRowGUID;

			if @parentFormStatusSCD is not null and @parentFormStatusSCD not in ('NEW', 'RETURNED', 'APPROVED')
			begin
				set @isEditEnabled = @OFF; -- the parent renewal is submitted or a later status so form cannot be edited
			end;
			else
			begin
				set @isEditEnabled = @isRegistrantLoggedIn; -- submitted form not editable by ADMIN unless unlocked
			end;

			set @isUnlockEnabled = @isAdminLoggedIn;
			set @isApproveEnabled = @isAdminLoggedIn;
			set @isRejectEnabled = @isAdminLoggedIn;

		end;
		else
		begin

			set @isEditEnabled = @isRegistrantLoggedIn;
			set @isUnlockEnabled = @isAdminLoggedIn;
			set @isApproveEnabled = @isAdminLoggedIn;
			set @isRejectEnabled = @isAdminLoggedIn;

		end;
	end;
	else
	begin

		set @isEditEnabled = @isAdminLoggedIn; -- otherwise only Admin's can edit
		set @isApproveEnabled = @isAdminLoggedIn;
		set @isRejectEnabled = @isAdminLoggedIn;

	end;

	-- withdrawal is enabled for administrators but note that
	-- this should only be invoked if the registrant is not licensed
	-- for the year the form is being withdrawn for (re-adding the
	-- form for the same registrant + year violates a UK)

	set @isWithdrawalEnabled = @isAdminLoggedIn;

	-- where the save button is set to display in the form configuration, it is still
	-- turned off if editing is disabled or the registrant is not logged in, or if 
	-- the parent form is APPROVED (user must use "Submit" to save)

	if @IsSaveBtnDisplayed = @ON
	begin

		if @isEditEnabled = @OFF or @isRegistrantLoggedIn = @OFF or @parentFormStatusSCD = 'APPROVED'
		begin
			set @IsSaveBtnDisplayed = @OFF;
		end;

	end;

	-- if form is in final status and cannot be unlocked
	-- then check if PDF version should be shown instead 
	-- of the HTML version

	if @isInProgress = @OFF and @isUnlockEnabled = @OFF
	begin

		select
			@applicationEntitySID = ae.ApplicationEntitySID
		from
			sf.ApplicationEntity ae
		where
			ae.ApplicationEntitySCD = 'dbo.RegistrantLearningPlan';

		select
			@personDocSID = pdc.PersonDocSID
		from
			dbo.PersonDocContext pdc
		where
			pdc.EntitySID = @RegistrantLearningPlanSID and pdc.IsPrimary = @ON and pdc.ApplicationEntitySID = @applicationEntitySID;

		set @isPDFDisplayed = cast(isnull(@personDocSID, 0) as bit);
	end;

	-- set view/edit settings according to status and who is logged in
	-- form can be viewed by the owner (the user is logged in) or admins

	insert
		@registrantLearningPlan#Ext
	(
		IsViewEnabled
	 ,IsEditEnabled
	 ,IsSaveBtnDisplayed
	 ,IsApproveEnabled
	 ,IsRejectEnabled
	 ,IsUnlockEnabled
	 ,IsWithdrawalEnabled
	 ,IsInProgress
	 ,RegistrantLearningPlanStatusSID
	 ,RegistrantLearningPlanStatusSCD
	 ,RegistrantLearningPlanStatusLabel
	 ,LastStatusChangeUser
	 ,LastStatusChangeTime
	 ,FormOwnerSCD
	 ,FormOwnerLabel
	 ,FormOwnerSID
	 ,IsPDFDisplayed
	 ,PersonDocSID
	 ,RegistrantLearningPlanLabel
	 ,RegistrationYearLabel
	 ,CycleEndRegistrationYear
	 ,CycleRegistrationYearLabel
	)
	select	(case when @isAdminLoggedIn = @ON or @isRegistrantLoggedIn = @ON then @ON else @OFF end)	-- check security for view access; either an Admin or Registrant
	 ,@isEditEnabled
	 ,@IsSaveBtnDisplayed
	 ,@isApproveEnabled
	 ,@isRejectEnabled
	 ,@isUnlockEnabled
	 ,@isWithdrawalEnabled
	 ,@isInProgress
	 ,@registrantLearningPlanStatusSID
	 ,@registrantLearningPlanStatusSCD
	 ,@registrantLearningPlanStatusLabel
	 ,@lastStatusChangeUser
	 ,@lastStatusChangeTime
	 ,@formOwnerSCD
	 ,@formOwnerLabel
	 ,@formOwnerSID
	 ,@isPDFDisplayed
	 ,@personDocSID
	 ,@registrantLearningPlanLabel
	 ,@registrationYearLabel
	 ,@cycleEndRegistrationYear
	 ,@cycleRegistrationYearLabel;

	return;
end;
GO
