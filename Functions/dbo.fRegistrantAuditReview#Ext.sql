SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrantAuditReview#Ext]
(
	 @RegistrantAuditReviewSID			int																	-- key of record to check
)
returns  @registrantAuditReview#Ext table
(
	 IsViewEnabled										bit								not null				-- indicates whether either the (logged in) user or administrator can view the audit review
	,IsEditEnabled										bit								not null				-- indicates whether the (logged in) user can edit/correct the form
	,IsSaveBtnDisplayed								bit								not null				-- indicates whether save button is displayed (configuration through sf.FormVersion + BR's)
	,IsUnlockEnabled									bit								not null				-- indicates administrator can unlock form for editing (applies when form is WITHDRAWN)
	,IsInProgress											bit								not null				-- indicates if the form is now finalized (recommendation is set) or in progress (open)	 
	,RegistrantAuditReviewStatusSID		int																-- key of current/latest audit review status 
	,RegistrantAuditReviewStatusSCD		varchar(25)												-- current/latest audit review status		
	,RegistrantAuditReviewStatusLabel	nvarchar(35)											-- user-friendly name for the audit review status		
	,LastStatusChangeUser							nvarchar(75)											-- username who made the last status change
	,LastStatusChangeTime							datetimeoffset(7)									-- date and time the last status change was made
	,FormOwnerSCD											varchar(25)												-- person/group expected to perform next action to progress the form
	,FormOwnerLabel										nvarchar(35)											-- user-friendly name of person/group expected to perform next action to progress the form
	,FormOwnerSID											int																-- key of the form owner expected to perform the next action to progress the form
	,PersonDocSID											int																-- key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
	,RegistrantLabel									nvarchar(75)											-- label - typically name and reg# - of the registrant being audited (overrides support masking)
	,RegistrantPersonSID							int																-- key of the registrant being audited in the person (sf) table
)
as
/*********************************************************************************************************************************
TableF	: Registrant Audit Extended Columns
Notice	: Copyright © 2017 Softworks Group Inc.
Summary	: Returns a table of calculated columns for the RegistrantAuditReview extended view (vRegistrantAuditReview#Ext)
History	: Author(s)  					| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund					| Apr 2017		|	Initial version
				:	Tim Edlund					| Jun 2017		| Revised to work with Recommendation setting in place of Approve/Reject
				: Tim Edlund					| Jan 2019		| Added is-save-btn-displayed bit to data set for consistency with other form types

Comments	
--------
This function is called by the dbo.vRegistrantAuditReview#Ext view to return a series of calculated values. By using a table 
function, many lookups required for the calculated values can be executed once rather than many times if separate functions are 
used.

This function expects to be selected for a single primary key value.  The function is not designed for inclusion in SELECTs 
scanning large portions of the table.  Performance in that context may not be acceptable and to resolve that, selected components 
of logic may need to be isolated into smaller functions that can be called separately.

RegistrantAuditReviewStatusSCD is obtained from a supporting view which retrieves the latest status change record for the form.

Example
-------

<TestHarness>
	<Test Name = "Simple" Description="Returns the extended columns for an instance of the entity at random.">
	<SQLScript>
	<![CDATA[

		select top 10
				rax.*				
		from 
			dbo.RegistrantAuditReview ra
		cross apply
			dbo.fRegistrantAuditReview#Ext(ra.RegistrantAuditReviewSID) rax
		order by
			newid()

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrantAuditReview#Ext'
	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @ON																bit							= cast(1 as bit)	-- constant to eliminate repetitive casting syntax
		,@OFF																bit							= cast(0 as bit)	-- constant to eliminate repetitive casting syntax
		,@isAdminLoggedIn										bit							= cast(0 as bit)	-- indicates if current user is an administrator			
		,@isReviewerLoggedIn								bit							= cast(0 as bit)	-- indicates if the form reviewer is the current user	
		,@isViewEnabled											bit							= cast(0 as bit)	-- indicates whether either the (logged in) user or administrator can view the audit
		,@isEditEnabled											bit							= cast(0 as bit)	-- indicates whether the (logged in) user can edit/correct the form
		,@IsSaveBtnDisplayed								bit							= cast(0 as bit)	-- indicates whether save button is displayed (configuration through sf.FormVersion + BR's)
		,@isUnlockEnabled										bit							= cast(0 as bit)	-- indicates administrator can unlock form for editing even when in certain final statuses
		,@isInProgress											bit							= cast(0 as bit)	-- indicates if the form is now closed/finalized or still in progress (open)	
		,@registrantAuditSID								int																-- key of parent audit form
		,@registrantAuditReviewStatusSID		int																-- key of current/latest audit review status 
		,@registrantAuditReviewStatusSCD		varchar(25)												-- current/latest audit review status		
		,@registrantAuditReviewStatusLabel  nvarchar(35)                      -- user-friendly name for the audit review status		
		,@lastStatusChangeUser							nvarchar(75)                      -- username who made the last status change
		,@lastStatusChangeTime							datetimeoffset(7)                 -- date and time the last status change was made
		,@formOwnerSCD											varchar(25)												-- person/group expected to perform next action to progress the main form
		,@formOwnerLabel										nvarchar(35)											-- user-friendly name of person/group expected to perform next action to progress the main form
		,@formOwnerSID											int																-- key of the form owner expected to perform the next action to progress the form
		,@personDocSID											int																-- key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
		,@applicationUserSID								int	= sf.fApplicationUserSessionUserSID()	-- key of currently logged in user - to enable read/write on audit
		,@registrantLabel										nvarchar(75)											-- label - typically name and reg# - of the registrant being audited (overrides support masking)
		,@registrantPersonSID								int																-- key of the registrant being audited in the person (sf) table
		,@applicationEntitySID							int																-- key of the audit entity; required to check for generated PDF

	-- retrieve the current status of the audit review and set
	-- identity values for determining read/write status

	select
		 @registrantAuditReviewStatusSID		= racs.RegistrantAuditReviewStatusSID
		,@registrantAuditReviewStatusSCD		= racs.FormStatusSCD
		,@registrantAuditReviewStatusLabel	= racs.FormStatusLabel
		,@formOwnerSCD											= racs.FormOwnerSCD
		,@formOwnerLabel										= racs.FormOwnerLabel
		,@formOwnerSID											= racs.FormOwnerSID
		,@lastStatusChangeUser							= racs.CreateUser
		,@lastStatusChangeTime							= racs.CreateTime
		,@IsSaveBtnDisplayed								= fv.IsSaveDisplayed
		,@isAdminLoggedIn										= sf.fIsGrantedToUserSID('ADMIN.AUDIT', @applicationUserSID)
		,@isReviewerLoggedIn								= sf.fIsGrantedToUserSID('EXTERNAL.AUDIT', @applicationUserSID)
		,@registrantAuditSID								= rar.RegistrantAuditSID
		,@registrantLabel										= dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'AUDIT.REVIEW')
		,@registrantPersonSID								= p.PersonSID
		,@isInProgress											= (case 
																							when racs.FormStatusSCD = 'WITHDRAWN' then @OFF
																							when rar.RecommendationSID is null		then @ON
																							when racs.FormStatusSCD = 'SUBMITTED' then @OFF 
																							else @ON 
																					end) -- in progress until recommendation is set and submitted, and NOT withdrawn
	from
		dbo.RegistrantAuditReview			rar
	join
		sf.FormVersion								fv		on rar.FormVersionSID = fv.FormVersionSID
	join
		sf.Form												f			on fv.FormSID = f.FormSID
	join
		dbo.RegistrantAudit						ra		on rar.RegistrantAuditSID = ra.RegistrantAuditSID
	join
		dbo.Registrant								r			on ra.RegistrantSID = r.RegistrantSID
	join
		sf.Person											p			on r.PersonSID = p.PersonSID																															-- join to registrant's label for presentation on form
	outer apply 
		dbo.fRegistrantAuditReview#CurrentStatus(rar.RegistrantAuditReviewSID, f.FormTypeSID)	racs																		-- the function determines the current status of the form
	where
		rar.RegistrantAuditReviewSID = @RegistrantAuditReviewSID

	-- if an admin or reviewer is logged in, they will have rights to 
	-- edit only if they are the assigned reviewer

	if @isAdminLoggedIn = @ON or @isReviewerLoggedIn = @ON
	begin
		
		select 
			@isReviewerLoggedIn = cast(count(1)  as bit)												-- turn bit off if not assigned to this specific reviewer
		from 
			dbo.RegistrantAuditReview rar 
		join
			sf.ApplicationUser				au		on rar.PersonSID = au.PersonSID and au.ApplicationUserSID = @applicationUserSID
		where 
			rar.RegistrantAuditReviewSID = @RegistrantAuditReviewSID 

	end

	-- admin can unlock withdrawn forms but only the assigned
	-- reviewer is allowed to edit; editing is turned off 
	-- if parent form is finalized

	if not exists
	(
		select
			1
		from
			dbo.RegistrantAuditStatus ras
		join
			(
			select
				 max(ras.RegistrantAuditStatusSID)    CurrentRegistrantAuditStatusSID                         -- isolate latest status record
			from
				dbo.RegistrantAuditStatus ras
			where
				ras.RegistrantAuditSID = @RegistrantAuditSID
			) x	on ras.RegistrantAuditStatusSID = x.CurrentRegistrantAuditStatusSID                         -- join to filter to latest status records only
		join	
			sf.FormStatus           fs  on ras.FormStatusSID = fs.FormStatusSID										          -- join to the master status record
		where
			fs.IsFinal = @ON																																								-- if parent form is in a final status; changes are disabled
	)
	begin

		if @registrantAuditReviewStatusSCD = 'WITHDRAWN'  
		begin
			set @isUnlockEnabled = @isAdminLoggedIn                                                         -- form can be unlocked by admins when in this status
		end
		else
		begin
			set @isEditEnabled = @isReviewerLoggedIn                                                        -- otherwise only the assigned reviewer can edit
		end

	end

	-- where the save button is set to display in the form configuration, it is still
	-- turned off if editing is disabled or the reviewer is not logged in

	if @IsSaveBtnDisplayed = @ON 
	begin

		if @isEditEnabled = @OFF or @isReviewerLoggedIn = @OFF
		begin
			set @IsSaveBtnDisplayed = @isEditEnabled
		end

	end;

	-- if form is in final status get PDF doc

	if @isInProgress = @OFF
	begin

		select
			@applicationEntitySID = ae.ApplicationEntitySID
		from
			sf.ApplicationEntity ae
		where
			ae.ApplicationEntitySCD = 'dbo.RegistrantAuditReview';

		select
			@personDocSID = pdc.PersonDocSID
		from
			dbo.PersonDocContext pdc
		where
			pdc.EntitySID = @RegistrantAuditSID and pdc.IsPrimary = @ON and pdc.ApplicationEntitySID = @applicationEntitySID;

	end;
					
	-- set view/edit settings according to status and who is logged in
	-- form can be viewed by the owner (the user is logged in) or admins

	insert 
		@registrantAuditReview#Ext
		(
			 IsViewEnabled							  
			,IsEditEnabled
			,IsSaveBtnDisplayed
			,IsUnlockEnabled		          
			,IsInProgress		
			,RegistrantAuditReviewStatusSID				
			,RegistrantAuditReviewStatusSCD				
			,RegistrantAuditReviewStatusLabel			
			,LastStatusChangeUser			
			,LastStatusChangeTime					
			,FormOwnerSCD									
			,FormOwnerLabel				
			,FormOwnerSID
			,PersonDocSID
			,RegistrantLabel
			,RegistrantPersonSID
		)
		select 
			 (case when @isAdminLoggedIn = @ON or @isReviewerLoggedIn = @ON then @ON else @OFF end)				-- check security for view access; either an Admin or the Reviewer
			,@isEditEnabled
			,@IsSaveBtnDisplayed      
			,@isUnlockEnabled		        
			,@isInProgress							
			,@registrantAuditReviewStatusSID				
			,@registrantAuditReviewStatusSCD				
			,@registrantAuditReviewStatusLabel			
			,@lastStatusChangeUser			
			,@lastStatusChangeTime							
			,@formOwnerSCD									
			,@formOwnerLabel	
			,@formOwnerSID
			,@personDocSID
			,@registrantLabel
			,@registrantPersonSID

	return

end
GO
