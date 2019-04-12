SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantAudit#Ext (@RegistrantAuditSID int) -- key of record to check
returns @registrantAudit#Ext table
(
	IsViewEnabled						bit								not null	-- indicates whether either the (logged in) user or administrator can view the audit
 ,IsEditEnabled						bit								not null	-- indicates whether the (logged in) user can edit/correct the form
 ,IsSaveBtnDisplayed			bit								not null	-- indicates whether save button is displayed (configuration through sf.FormVersion + BR's)
 ,IsApproveEnabled				bit								not null	-- indicates whether the approve button should be made available to the user
 ,IsRejectEnabled					bit								not null	-- indicates whether the reject button should be made available to the user
 ,IsUnlockEnabled					bit								not null	-- indicates administrator can unlock form for editing even when in certain final statuses
 ,IsWithdrawalEnabled			bit								not null	-- indicates the audit form can be withdrawn by administrators or SA's
 ,IsInProgress						bit								not null	-- indicates if the form is now closed/finalized or still in progress (open)	 
 ,IsReviewRequired				bit								not null	-- indicates if admin review of the form is required
 ,FormStatusSID						int								not null	-- key of current/latest application status 
 ,FormStatusSCD						varchar(25)				not null	-- current/latest application status		
 ,FormStatusLabel					nvarchar(35)			not null	-- user-friendly name for the audit status		
 ,LastStatusChangeUser		nvarchar(75)			not null	-- username who made the last status change
 ,LastStatusChangeTime		datetimeoffset(7) not null	-- date and time the last status change was made
 ,FormOwnerSID						int								not null	-- key of the related sf.FormOwner record
 ,FormOwnerSCD						varchar(25)				not null	-- person/group expected to perform next action to progress the form
 ,FormOwnerLabel					nvarchar(35)			not null	-- user-friendly name of person/group expected to perform next action to progress the form
 ,IsPDFDisplayed					bit								not null	-- indicates if PDF form version should be displayed rather than the HTML (form is complete)
 ,PersonDocSID						int								null			-- key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
 ,PersonMailingAddressSID int								null			-- key of person's current mailing address - if any
 ,StreetAddress1					nvarchar(75)			null			-- current address values for the registrant:
 ,StreetAddress2					nvarchar(75)			null
 ,StreetAddress3					nvarchar(75)			null
 ,CityName								nvarchar(30)			null
 ,StateProvinceName				nvarchar(30)			null
 ,PostalCode							nvarchar(10)			null
 ,CountryName							nvarchar(50)			null
 ,CitySID									int								null
 ,PersonSID								int								not null	-- sf.Person key of the registrant
 ,RegistrationYearLabel		varchar(9)				not null	-- string show 2 years if the registration year provided is not based on a calendar year
 ,RegistrantAuditLabel		nvarchar(80)			not null	-- a summary label for the audit based on the register label and application status
 -- Components unique to review process:
 ,IsSendForReviewEnabled	bit								not null	-- indicates whether the button to send the form for external review is enabled
 ,IsReviewInProgress			bit								not null	-- indicates if all review forms are now closed/finalized or still in progress (open)	 
 ,IsReviewFormConfigured	bit								not null	-- indicates if a review form is configured for the associated practice register
 ,RecommendationLabel			nvarchar(20)			null			-- recommendation term to display summarizing reviews on the audit
)
as
/*********************************************************************************************************************************
TableF	: Registrant Audit Extended Columns
Notice	: Copyright © 2017 Softworks Group Inc.
Summary	: Returns a table of calculated columns for the RegistrantAudit extended view (vRegistrantAudit#Ext)
--------------------------------------------------------------------------------------------------------------------------------
History	: Author	  					| Month Year	| Change Summary
				: -------------------	+ ----------- + ----------------------------------------------------------------------------------
				: Tim Edlund					| Apr 2017		|	Initial version
				:	Tim Edlund					| Jun 2017		| Updated to support multiple review forms (status "INREVIEW")
				: Tim Edlund					| Oct 2017		| Added support for AWAITINGDOCS status
				: Tim Edlund					| Jan	2018		| Added mailing address values
				: Tim Edlund					| Feb 2018		| Added IsPDFDisplayed + PersonDocSID to indicate when PDF is displayed instead of HTML
				: Tim Edlund					| Jun 2018		| FK in RegistrantAudit changed from RegistrantSID to RegistrationSID + standards updates
				: Tim Edlund					| Oct 2018		| Minor updates to work with revised #CurrentStatus function and removed unused columns
				: Tim Edlund					| Dec 2018		| Revised function to conform with latest standard 
				: Tim Edlund					| Jan 2019		| Added is-save-btn-displayed bit to data set for consistency with other form types

Comments	
--------

This function is called by the dbo.vRegistrantAudit#Ext view to return a series of calculated values. By using a table function,
many lookups required for the calculated values can be executed once rather than many times if separate functions are used.

This function expects to be selected for a single primary key value.  The function is not designed for inclusion in SELECTs 
scanning large portions of the table.  Performance in that context may not be acceptable and to resolve that, selected components 
of logic may need to be isolated into smaller functions that can be called separately.

FormStatusSCD is obtained from a supporting view which retrieves the latest status change record for the form.

Example
-------

<TestHarness>
	<Test Name = "Simple" Description="Returns the extended columns for an instance of the entity at random.">
	<SQLScript>
	<![CDATA[

		select top 10
				rax.*				
		from 
			dbo.RegistrantAudit frm
		cross apply
			dbo.fRegistrantAudit#Ext(frm.RegistrantAuditSID) rax
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
	 @ObjectName = 'dbo.fRegistrantAudit#Ext'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@ON											 bit							= cast(1 as bit)											-- constant to eliminate repetitive casting syntax
	 ,@OFF										 bit							= cast(0 as bit)											-- constant to eliminate repetitive casting syntax
	 ,@isAdminLoggedIn				 bit							= cast(0 as bit)											-- indicates if current user is an administrator			
	 ,@isRegistrantLoggedIn		 bit							= cast(0 as bit)											-- indicates if the form registrant is the current user	
	 ,@isViewEnabled					 bit							= cast(0 as bit)											-- indicates whether either the (logged in) user or administrator can view the audit
	 ,@isEditEnabled					 bit							= cast(0 as bit)											-- indicates whether the (logged in) user can edit/correct the form
	 ,@IsSaveBtnDisplayed			 bit							= cast(0 as bit)											-- indicates whether save button is displayed (configuration through sf.FormVersion + BR's)
	 ,@isApproveEnabled				 bit							= cast(0 as bit)											-- indicates whether the approve button should be made available to the user
	 ,@isRejectEnabled				 bit							= cast(0 as bit)											-- indicates whether the reject button should be made available to the user
	 ,@isUnlockEnabled				 bit							= cast(0 as bit)											-- indicates administrator can unlock form for editing even when in certain final statuses
	 ,@isWithdrawalEnabled		 bit							= cast(0 as bit)											-- indicates the audit form can be withdrawn by administrators or SA's
	 ,@isInProgress						 bit							= cast(0 as bit)											-- indicates if the form is now closed/finalized or still in progress (open)		  
	 ,@isReviewRequired				 bit							= cast(0 as bit)											-- indicates if admin review of the form is required
	 ,@formStatusSID					 int																										-- key of current/latest application status 
	 ,@formStatusSCD					 varchar(25)																						-- current/latest application status		
	 ,@formStatusLabel				 nvarchar(35)																						-- user-friendly name for the audit status		
	 ,@lastStatusChangeUser		 nvarchar(75)																						-- username who made the last status change
	 ,@lastStatusChangeTime		 datetimeoffset(7)																			-- date and time the last status change was made
	 ,@formOwnerSID						 int																										-- key of the related sf.FormOwner record
	 ,@formOwnerSCD						 varchar(25)																						-- person/group expected to perform next action to progress the main form
	 ,@formOwnerLabel					 nvarchar(35)																						-- user-friendly name of person/group expected to perform next action to progress the main form
	 ,@isPDFDisplayed					 bit							= cast(0 as bit)											-- indicates if PDF form version should be displayed rather than the HTML (form is complete)
	 ,@personDocSID						 int																										-- key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
	 ,@applicationUserSID			 int							= sf.fApplicationUserSessionUserSID() -- key of currently logged in user - to enable read/write on application
	 ,@applicationEntitySID		 int																										-- key of the application entity; required to check for generated PDF
	 ,@personMailingAddressSID int																										-- key of the registrant's current mailing address (required for updates through the form)
	 ,@streetAddress1					 nvarchar(75)																						-- current address values for the registrant:
	 ,@streetAddress2					 nvarchar(75)
	 ,@streetAddress3					 nvarchar(75)
	 ,@cityName								 nvarchar(30)
	 ,@stateProvinceName			 nvarchar(30)
	 ,@postalCode							 nvarchar(10)
	 ,@countryName						 nvarchar(50)
	 ,@citySID								 int
	 ,@personSID							 int																										-- key of person profile
	 ,@registrationYearLabel	 varchar(9)																							-- string show 2 years if the registration year provided is not based on a calendar year
	 ,@registrantAuditLabel		 nvarchar(80)																						-- a summary label for the audit based on the register label and application status
	 ,@isReviewerLoggedIn			 bit							= cast(0 as bit)											-- indicates if the form reviewer is the current user	
	 ,@isSendForReviewEnabled	 bit							= cast(0 as bit)											-- indicates whether the button to send the form for external review is enabled (creates Review forms)
	 ,@isReviewInProgress			 bit							= cast(0 as bit)											-- indicates if all review forms are now closed/finalized or still in progress (open)	 
	 ,@isReviewFormConfigured	 bit							= cast(0 as bit)											-- indicates if a review form is configured for the associated practice register
	 ,@recommendationLabel		 nvarchar(20);																					-- recommendation term to display summarizing reviews on the audit

	set @isAdminLoggedIn = sf.fIsGrantedToUserSID('ADMIN.AUDIT', @applicationUserSID);
	set @isReviewerLoggedIn = sf.fIsGrantedToUserSID('EXTERNAL.AUDIT', @applicationUserSID);

	-- retrieve the current status of the audit and set
	-- identity values for determining read/write status

	select
		@formStatusSID					= cs.FormStatusSID
	 ,@formStatusSCD					= cs.FormStatusSCD
	 ,@formStatusLabel				= cs.FormStatusLabel
	 ,@isInProgress						= cs.IsInProgress
	 ,@isReviewRequired				= cs.IsReviewRequired
	 ,@formOwnerSID						= cs.FormOwnerSID
	 ,@formOwnerSCD						= cs.FormOwnerSCD
	 ,@formOwnerLabel					= cs.FormOwnerLabel
	 ,@lastStatusChangeUser		= cs.LastStatusChangeUser
	 ,@lastStatusChangeTime		= cs.LastStatusChangeTime
	 ,@IsSaveBtnDisplayed			= fv.IsSaveDisplayed
	 ,@isRegistrantLoggedIn		= (case when au.ApplicationUserSID = @applicationUserSID then @ON else @OFF end)
	 ,@personSID							= r.PersonSID
	 ,@isReviewFormConfigured = cast(case when cs.RecommendationLabel is not null then 1 else 0 end as bit)
	 ,@recommendationLabel		= cs.RecommendationLabel
	 ,@registrantAuditLabel		= at.AuditTypeLabel + N' - ' + (case when cs.IsInProgress = cast(1 as bit) then 'In Progress' else cs.FormStatusLabel end)
	 ,@registrationYearLabel	= (case
																 when year(rsy.YearStartTime) = year(rsy.YearEndTime) then ltrim(rsy.RegistrationYear)
																 else ltrim(year(rsy.YearStartTime)) + '/' + ltrim(year(rsy.YearEndTime))
															 end
															)
	from
		dbo.RegistrantAudit																											 frm
	join
		dbo.Registrant																													 r on frm.RegistrantSID = r.RegistrantSID
	join
		sf.ApplicationUser																											 au on r.PersonSID = au.PersonSID -- determine the user ID of the registrant
	join
		dbo.RegistrationScheduleYear																						 rsy on frm.RegistrationYear = rsy.RegistrationYear
	join
		dbo.AuditType																														 at on frm.AuditTypeSID = at.AuditTypeSID
	join
		sf.FormVersion																													 fv on frm.FormVersionSID = fv.FormVersionSID
	outer apply dbo.fRegistrantAudit#CurrentStatus(frm.RegistrantAuditSID, -1) cs -- the function determines the current status of the form
	where
		frm.RegistrantAuditSID = @RegistrantAuditSID;

	set @registrantAuditLabel += N' (' + @registrationYearLabel + N')';
	set @isViewEnabled = (case when @isAdminLoggedIn = @ON or @isRegistrantLoggedIn = @ON or @isReviewerLoggedIn = @ON then @ON else @OFF end);

	-- a separate SELECT is implemented to retrieve the current mailing address 
	-- if no current address; values will be null

	select
		@personMailingAddressSID = pma.PersonMailingAddressSID
	 ,@streetAddress1					 = pma.StreetAddress1
	 ,@streetAddress2					 = pma.StreetAddress2
	 ,@streetAddress3					 = pma.StreetAddress3
	 ,@cityName								 = pma.CityName
	 ,@stateProvinceName			 = pma.StateProvinceName
	 ,@postalCode							 = pma.PostalCode
	 ,@countryName						 = pma.CountryName
	 ,@citySID								 = pma.CitySID
	from
		dbo.fPersonMailingAddress#Current(@personSID) pma;

	-- if a reviewer is logged in check if the form has been assigned to them,
	-- otherwise read and edit permissions are blocked

	if @isAdminLoggedIn = @OFF and @isReviewerLoggedIn = @ON
	begin
		select
			@isReviewerLoggedIn = cast(count(1) as bit) -- turn bit off if not assigned to this reviewer
		from
			dbo.RegistrantAuditReview rar
		join
			sf.ApplicationUser				au on rar.PersonSID = au.PersonSID and au.ApplicationUserSID = @applicationUserSID
		where
			rar.RegistrantAuditSID = @RegistrantAuditSID;
	end;

	-- set bit values controlling editing and unlock; if form is APPROVED then all
	-- actions are blocked since form details already written to DB records

	if @formStatusSCD <> 'APPROVED'
	begin
		if @formStatusSCD = 'REJECTED'
		begin
			set @isUnlockEnabled = @isAdminLoggedIn; -- form can be unlocked by admins when in this status
		end;
		else if @formStatusSCD = 'WITHDRAWN'
		begin
			set @isUnlockEnabled = @isAdminLoggedIn; -- form can be unlocked by admins when in this status
		end;
		else if @formStatusSCD = 'CORRECTED'
		begin
			set @isEditEnabled = @isAdminLoggedIn; -- admins can continue editing after saving a correction
			set @isApproveEnabled = @isAdminLoggedIn;
			set @isRejectEnabled = @isAdminLoggedIn;
		end;
		else if @formStatusSCD = 'UNLOCKED'
		begin
			set @isEditEnabled = @isAdminLoggedIn; -- admins can edit, return or assign a new final status
			set @isApproveEnabled = @isAdminLoggedIn;
			set @isRejectEnabled = @isAdminLoggedIn;
		end;
		else if @formStatusSCD in ('NEW', 'RETURNED', 'AWAITINGDOCS') -- when NEW, RETURNED or AWAITING documents end user can edit it (admin must unlock first)
		begin
			set @isEditEnabled = @isRegistrantLoggedIn;
			set @isUnlockEnabled = @isAdminLoggedIn; -- only enable if current user is the registrant on the form																												
			set @isApproveEnabled = @isAdminLoggedIn; -- edge case: admin may return form and not receive an update
			set @isRejectEnabled = @isAdminLoggedIn; -- but still decides to approve or reject the form
		end;
		else
		begin
			set @isEditEnabled = @isAdminLoggedIn; -- otherwise only Admin's can edit
			set @isApproveEnabled = @isAdminLoggedIn;
			set @isRejectEnabled = @isAdminLoggedIn;
		end;

		-- if review form is open, disable edit for admins and 
		-- enable unlock since the reviewer may be editing

		if @isRegistrantLoggedIn = @ON and @isReviewInProgress = @ON -- if review is underway, Admins can unlock but not edit directly
		begin
			set @isEditEnabled = @OFF;
			set @isUnlockEnabled = @ON;
		end;

		-- sending for review is enabled for administrators only, and whenever
		-- edit is enabled (since multiple reviews are supported; it is not 
		-- based on review records already existing)

		if @isAdminLoggedIn = @ON and @isEditEnabled = @ON
		begin
			set @isSendForReviewEnabled = @ON;
		end;

		-- withdrawal is enabled for administrators unless
		-- form is already in a final status

		if @formStatusSCD = 'WITHDRAWN'
		begin
			set @isWithdrawalEnabled = @OFF;
		end;
		else if @isAdminLoggedIn = @ON
		begin
			set @isWithdrawalEnabled = @ON;
		end;

	end;

	-- where the save button is set to display in the form configuration, it is still
	-- turned off if editing is disabled or the registrant is not logged in

	if @IsSaveBtnDisplayed = @ON
	begin

		if @isEditEnabled = @OFF or @isRegistrantLoggedIn = @OFF
		begin
			set @IsSaveBtnDisplayed = @OFF;
		end;

	end;
	
	-- if form is in final status and paid, check if
	-- PDF version should be shown instead of the HTML version

	if @isInProgress = @OFF
	begin

		select
			@applicationEntitySID = ae.ApplicationEntitySID
		from
			sf.ApplicationEntity ae
		where
			ae.ApplicationEntitySCD = 'dbo.RegistrantAudit';

		select
			@personDocSID = pdc.PersonDocSID
		from
			dbo.PersonDocContext pdc
		where
			pdc.EntitySID = @RegistrantAuditSID and pdc.IsPrimary = @ON and pdc.ApplicationEntitySID = @applicationEntitySID;

		set @isPDFDisplayed = cast(isnull(@personDocSID, 0) as bit);
	end;

	-- set view/edit settings according to status and who is logged in
	-- form can be viewed by the owner (the user is logged in) or admins

	insert
		@registrantAudit#Ext
	(
		IsViewEnabled
	 ,IsEditEnabled
	 ,IsSaveBtnDisplayed
	 ,IsApproveEnabled
	 ,IsRejectEnabled
	 ,IsUnlockEnabled
	 ,IsWithdrawalEnabled
	 ,IsInProgress
	 ,IsReviewRequired
	 ,FormStatusSID
	 ,FormStatusSCD
	 ,FormStatusLabel
	 ,LastStatusChangeUser
	 ,LastStatusChangeTime
	 ,FormOwnerSID
	 ,FormOwnerSCD
	 ,FormOwnerLabel
	 ,IsPDFDisplayed
	 ,PersonDocSID
	 ,PersonMailingAddressSID
	 ,StreetAddress1
	 ,StreetAddress2
	 ,StreetAddress3
	 ,CityName
	 ,StateProvinceName
	 ,PostalCode
	 ,CountryName
	 ,CitySID
	 ,PersonSID
	 ,RegistrationYearLabel
	 ,RegistrantAuditLabel
	 ,IsSendForReviewEnabled
	 ,IsReviewInProgress
	 ,IsReviewFormConfigured
	 ,RecommendationLabel
	)
	select
		@isViewEnabled
	 ,@isEditEnabled
	 ,@IsSaveBtnDisplayed
	 ,@isApproveEnabled
	 ,@isRejectEnabled
	 ,@isUnlockEnabled
	 ,@isWithdrawalEnabled
	 ,@isInProgress
	 ,@isReviewRequired
	 ,@formStatusSID
	 ,@formStatusSCD
	 ,@formStatusLabel
	 ,@lastStatusChangeUser
	 ,@lastStatusChangeTime
	 ,@formOwnerSID
	 ,@formOwnerSCD
	 ,@formOwnerLabel
	 ,@isPDFDisplayed
	 ,@personDocSID
	 ,@personMailingAddressSID
	 ,@streetAddress1
	 ,@streetAddress2
	 ,@streetAddress3
	 ,@cityName
	 ,@stateProvinceName
	 ,@postalCode
	 ,@countryName
	 ,@citySID
	 ,@personSID
	 ,@registrationYearLabel
	 ,@registrantAuditLabel
	 ,@isSendForReviewEnabled
	 ,@isReviewInProgress
	 ,@isReviewFormConfigured
	 ,@recommendationLabel;

	return;
end;
GO
