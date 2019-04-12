SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrantAppReview#Ext]
(
	@RegistrantAppReviewSID int -- key of record to check
)
returns @registrantAppReview#Ext table
(
	IsViewEnabled									 bit							 not null -- indicates whether either the (logged in) user or administrator can view the application review
 ,IsEditEnabled									 bit							 not null -- indicates whether the (logged in) user can edit/correct the form
 ,IsSaveBtnDisplayed								bit								not null				-- indicates whether save button is displayed (configuration through sf.FormVersion + BR's)
 ,IsUnlockEnabled								 bit							 not null -- indicates administrator can unlock form for editing (applies when form is WITHDRAWN)
 ,IsInProgress									 bit							 not null -- indicates if the form is now finalized (recommendation is set) or in progress (open)	 
 ,RegistrantAppReviewStatusSID	 int							 null			-- key of current/latest application review status 
 ,RegistrantAppReviewStatusSCD	 varchar(25)			 null			-- current/latest application review status		
 ,RegistrantAppReviewStatusLabel nvarchar(35)			 null			-- user-friendly name for the application review status		
 ,LastStatusChangeUser					 nvarchar(75)			 null			-- username who made the last status change
 ,LastStatusChangeTime					 datetimeoffset(7) null			-- date and time the last status change was made
 ,FormOwnerSCD									 varchar(25)			 not null -- person/group expected to perform next action to progress the form
 ,FormOwnerLabel								 nvarchar(35)			 not null -- user-friendly name of person/group expected to perform next action to progress the form
 ,FormOwnerSID									 int							 not null -- key of the form owner expected to perform the next action to progress the form
 ,RegistrantLabel								 nvarchar(75)			 not null -- label - typically name and reg# - of the applicant being reviewed (overrides support masking)
 ,RegistrantPersonSID						 int							 not null -- key of person (sf) record for the applicant
)
as
/*********************************************************************************************************************************
TableF	: Registrant App Extended Columns
Notice	: Copyright © 2017 Softworks Group Inc.
Summary	: Returns a table of calculated columns for the RegistrantAppReview extended view (vRegistrantAppReview#Ext)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author	  					| Month Year	| Change Summary
				: -------------------	+ ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund					| Jun 2018		|	Initial version
				: Tim Edlund					| Apr 2017		|	Initial version
				:	Tim Edlund					| Jun 2017		| Revised to work with Recommendation setting in place of Approve/Reject
				: Tim Edlund					| Jun 2018		| FK in RegistrantApp changed from RegistrantSID to RegistrationSID
				: Russ Poirier				| Sep 2018		| Modified logic to set IsEditEnabled bit once review has been submitted
				: Tim Edlund					| Jan 2019		| Added is-save-btn-displayed bit to data set for consistency with other form types

Comments	
--------

This function is called by the dbo.vRegistrantAppReview#Ext view to return a series of calculated values. By using a table 
function, many lookups required for the calculated values can be executed once rather than many times if separate functions are 
used.

This function expects to be selected for a single primary key value.  The function is not designed for inclusion in SELECTs 
scanning large portions of the table.  Performance in that context may not be acceptable and to resolve that, selected components 
of logic may need to be isolated into smaller functions that can be called separately.

RegistrantAppReviewStatusSCD is obtained from a supporting view which retrieves the latest status change record for the form.

Example
-------

<TestHarness>
	<Test Name = "Simple" Description="Returns the extended columns for an instance of the entity at random.">
	<SQLScript>
	<![CDATA[
		begin tran
		
			declare
						@RegistrationYear							int
					,	@FormStatusSID								int
					,	@FormVersionSID								int
					,	@PersonSID										int
					, @ReasonSID										int
					,	@ReviewerSID									int
					,	@RecommendationSID						int
					, @PracticeRegisterSectionSID		int
					,	@RegistrantSID								int
					,	@RegistrantAppSID							int
			
			set @RegistrationYear = year(sf.fnow())
			
			select top 1
				@FormStatusSID = fs.FormStatusSID 
			from
				sf.FormStatus fs
			
			select top 1
				@formVersionSID = fv.FormVersionSID
			from 
				sf.FormVersion fv
			
			select top 1
				@PersonSID = p.PersonSID
			from
				sf.Person p
			
			select top 1
				@ReviewerSID = p.PersonSID
			from
				sf.Person p
			where
				p.personsid <> @PersonSID
			
			select top 1
				@ReasonSID = r.ReasonSID
			from
				dbo.Reason r
			
			select top 1
				@RecommendationSID = r.RecommendationSID
			from
				dbo.Recommendation r
			
			select
				@PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			from
				dbo.PracticeRegister pr
			join
				dbo.PracticeRegisterSection prs on pr.PracticeRegisterSID = prs.PracticeRegisterSID
			where
				prs.IsDefault = 1
			and
				pr.IsDefault = 1
			
			insert into dbo.Registrant
			(
					PersonSID
				,	RegistrantNo
			)
			select
					@PersonSID
				, left(newid(), 50)
			
			set @RegistrantSID = scope_identity()
			
			insert into dbo.RegistrantApp
			(
					RegistrantSID
				,	PracticeRegisterSectionSID
				,	RegistrationYear
				,	FormVersionSID
			)
			select
					@RegistrantSID
				,	@PracticeRegisterSectionSID
				,	@RegistrationYear
				, @FormVersionSID
			
			set @RegistrantAppSID = scope_identity()
			
			insert into dbo.RegistrantAppReview
			(
					RegistrantAppSID
				,	FormVersionSID
				, PersonSID
				,	ReasonSID
				,	RecommendationSID
			)
			select
					@RegistrantAppSID
				,	@FormVersionSID
				, @ReviewerSID
				, @ReasonSID
				,	@RecommendationSID
			
				select top 10
						rax.*				
				from 
					(
						select top 10
							x.RegistrantAppReviewSID 
						from 
							dbo.RegistrantAppReview x
						order by
							newid()
					) ra
				cross apply
					dbo.fRegistrantAppReview#Ext(ra.RegistrantAppReviewSID) rax
		
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
	@ObjectName = 'dbo.fRegistrantAppReview#Ext'
	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@ON															bit							 = cast(1 as bit)												-- constant to eliminate repetitive casting syntax
	 ,@OFF														bit							 = cast(0 as bit)												-- constant to eliminate repetitive casting syntax
	 ,@isAdminLoggedIn								bit							 = cast(0 as bit)												-- indicates if current user is an administrator			
	 ,@isReviewerLoggedIn							bit							 = cast(0 as bit)												-- indicates if the form reviewer is the current user	
	 ,@isEditEnabled									bit							 = cast(0 as bit)												-- indicates whether the (logged in) user can edit/correct the form
	 ,@IsSaveBtnDisplayed								bit						 = cast(0 as bit)												-- indicates whether save button is displayed (configuration through sf.FormVersion + BR's)
	 ,@isUnlockEnabled								bit							 = cast(0 as bit)												-- indicates administrator can unlock form for editing even when in certain final statuses
	 ,@isInProgress										bit							 = cast(0 as bit)												-- indicates if the form is now closed/finalized or still in progress (open)	
	 ,@registrantAppSID								int																											-- key of parent application form
	 ,@registrantAppReviewStatusSID		int																											-- key of current/latest application review status 
	 ,@registrantAppReviewStatusSCD		varchar(25)																							-- current/latest application review status		
	 ,@registrantAppReviewStatusLabel nvarchar(35)																						-- user-friendly name for the application review status		
	 ,@lastStatusChangeUser						nvarchar(75)																						-- username who made the last status change
	 ,@lastStatusChangeTime						datetimeoffset(7)																				-- date and time the last status change was made
	 ,@formOwnerSCD										varchar(25)																							-- person/group expected to perform next action to progress the main form
	 ,@formOwnerLabel									nvarchar(35)																						-- user-friendly name of person/group expected to perform next action to progress the main form
	 ,@formOwnerSID										int																											-- key of the form owner expected to perform the next action to progress the form
	 ,@applicationUserSID							int							 = sf.fApplicationUserSessionUserSID()	-- key of currently logged in user - to enable read/write on audit
	 ,@registrantLabel								nvarchar(75)																						-- label - typically name and reg# - of the applicant being reviewed (overrides support masking)
	 ,@registrantPersonSID						int;																										-- key of person (sf) record for the applicant

	set @isAdminLoggedIn = sf.fIsGrantedToUserSID('ADMIN.APPLICATION', @applicationUserSID);
	set @isReviewerLoggedIn = sf.fIsGrantedToUserSID('EXTERNAL.APPLICATION', @applicationUserSID);

	-- retrieve the current status of the application review and set
	-- identity values for determining read/write status

	select
		@registrantAppReviewStatusSID		= cs.RegistrantAppReviewStatusSID
	 ,@registrantAppReviewStatusSCD		= cs.FormStatusSCD
	 ,@registrantAppReviewStatusLabel = cs.FormStatusLabel
	 ,@formOwnerSCD										= cs.FormOwnerSCD
	 ,@formOwnerLabel									= cs.FormOwnerLabel
	 ,@formOwnerSID										= cs.FormOwnerSID
	 ,@lastStatusChangeUser						= cs.LastStatusChangeUser
	 ,@lastStatusChangeTime						= cs.LastStatusChangeTime
	 ,@registrantAppSID								= appRvw.RegistrantAppSID
	 ,@IsSaveBtnDisplayed							= fv.IsSaveDisplayed
	 ,@registrantLabel								= dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'APPLICATION.REVIEW')
	 ,@registrantPersonSID						= p.PersonSID
	 ,@isInProgress										= (case
																				 when cs.FormStatusSCD = 'WITHDRAWN' then @OFF
																				 when appRvw.RecommendationSID is null then @ON
																				 when cs.FormStatusSCD = 'SUBMITTED' then @OFF
																				 else @ON
																			 end
																			) -- in progress until recommendation is set and submitted, and NOT withdrawn
	from
		dbo.RegistrantAppReview																																			appRvw
	join
		sf.FormVersion																																							fv on appRvw.FormVersionSID = fv.FormVersionSID
	join
		sf.Form																																											f on fv.FormSID = f.FormSID
	join
		dbo.RegistrantApp																																						ra on appRvw.RegistrantAppSID = ra.RegistrantAppSID
	join
		dbo.Registration																																						reg on ra.RegistrationSID = reg.RegistrationSID
	join
		dbo.Registrant																																							r on reg.RegistrantSID = r.RegistrantSID
	join
		sf.Person																																										p on r.PersonSID = p.PersonSID -- join to applicant's label for presentation on form
	outer apply dbo.fRegistrantAppReview#CurrentStatus(appRvw.RegistrantAppReviewSID, -1) cs	-- the function determines the current status of the form
	where
		appRvw.RegistrantAppReviewSID = @RegistrantAppReviewSID;

	-- if an administrator or reviewer is logged in, they will have rights to 
	-- edit only if they are the assigned reviewer

	if @isAdminLoggedIn = @ON or @isReviewerLoggedIn = @ON
	begin

		select
			@isReviewerLoggedIn = cast(count(1) as bit) -- turn bit off if not assigned to this specific reviewer
		from
			dbo.RegistrantAppReview appRvw
		join
			sf.ApplicationUser			au on appRvw.PersonSID = au.PersonSID and au.ApplicationUserSID = @applicationUserSID
		where
			appRvw.RegistrantAppReviewSID = @RegistrantAppReviewSID;

	end;

	-- administrators can unlock withdrawn forms but only the assigned
	-- reviewer is allowed to edit; editing is turned off 
	-- if parent form is finalized

	if not exists
	(
		select
			1
		from
			dbo.RegistrantAppStatus ras
		join
		(
			select
				max(ras.RegistrantAppStatusSID) CurrentRegistrantAppStatusSID -- isolate latest status record
			from
				dbo.RegistrantAppStatus ras
			where
				ras.RegistrantAppSID = @registrantAppSID
		)													x on ras.RegistrantAppStatusSID = x.CurrentRegistrantAppStatusSID -- join to filter to latest status records only
		join
			sf.FormStatus						fs on ras.FormStatusSID					= fs.FormStatusSID	-- join to the master status record
		where
			fs.IsFinal = @ON	-- if parent form is in a final status; changes are disabled
	)
	begin

		if @registrantAppReviewStatusSCD = 'WITHDRAWN'
		begin
			set @isUnlockEnabled = @isAdminLoggedIn; -- form can be unlocked by administrators when in this status
		end;
		else
		begin

			if @isInProgress = @OFF
			begin
				set @isEditEnabled = @OFF;
			end;
			else
			begin
				set @isEditEnabled = @isReviewerLoggedIn; -- otherwise only the assigned reviewer can edit
			end;

		end;

	end;

	-- where the save button is set to display in the form configuration, it is still
	-- turned off if editing is disabled or the reviewer is not logged in

	if @IsSaveBtnDisplayed = @ON 
	begin

		if @isEditEnabled = @OFF or @isReviewerLoggedIn = @OFF
		begin
			set @IsSaveBtnDisplayed = @isEditEnabled
		end

	end;


	-- set view/edit settings according to status and who is logged in
	-- form can be viewed by the owner (the user is logged in) or administrators

	insert
		@registrantAppReview#Ext
	(
		IsViewEnabled
	 ,IsEditEnabled
	 ,IsSaveBtnDisplayed
	 ,IsUnlockEnabled
	 ,IsInProgress
	 ,RegistrantAppReviewStatusSID
	 ,RegistrantAppReviewStatusSCD
	 ,RegistrantAppReviewStatusLabel
	 ,LastStatusChangeUser
	 ,LastStatusChangeTime
	 ,FormOwnerSCD
	 ,FormOwnerLabel
	 ,FormOwnerSID
	 ,RegistrantLabel
	 ,RegistrantPersonSID
	)
	select	(case when @isAdminLoggedIn = @ON or @isReviewerLoggedIn = @ON then @ON else @OFF end)	-- check security for view access; either an Admin or the Reviewer
	 ,@isEditEnabled
	 ,@IsSaveBtnDisplayed
	 ,@isUnlockEnabled
	 ,@isInProgress
	 ,@registrantAppReviewStatusSID
	 ,@registrantAppReviewStatusSCD
	 ,@registrantAppReviewStatusLabel
	 ,@lastStatusChangeUser
	 ,@lastStatusChangeTime
	 ,@formOwnerSCD
	 ,@formOwnerLabel
	 ,@formOwnerSID
	 ,@registrantLabel
	 ,@registrantPersonSID;

	return;

end;
GO
