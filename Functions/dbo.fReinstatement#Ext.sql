SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fReinstatement#Ext (@ReinstatementSID int) -- key of record to check
returns @reinstatement#Ext table
(
	IsViewEnabled						bit								not null	-- indicates whether either the (logged in) user or administrator can view the reinstatement
 ,IsEditEnabled						bit								not null	-- indicates whether the (logged in) user can edit/correct the form
 ,IsSaveBtnDisplayed			bit								not null	-- indicates whether save button is displayed (configuration through sf.FormVersion + BR's)
 ,IsApproveEnabled				bit								not null	-- indicates whether the approve button should be made available to the user
 ,IsRejectEnabled					bit								not null	-- indicates whether the reject button should be made available to the user
 ,IsUnlockEnabled					bit								not null	-- indicates administrator can unlock form for editing even when in certain final statuses
 ,IsWithdrawalEnabled			bit								not null	-- indicates the reinstatement form can be withdrawn by administrators or SA's
 ,IsInProgress						bit								not null	-- indicates if the form is now closed/finalized or still in progress (open)	 
 ,IsReviewRequired				bit								not null	-- indicates if admin review of the form is required
 ,FormStatusSID						int								not null	-- key of current/latest reinstatement status 
 ,FormStatusSCD						varchar(25)				not null	-- current/latest reinstatement status		
 ,FormStatusLabel					nvarchar(35)			not null	-- user-friendly name for the reinstatement status		
 ,LastStatusChangeUser		nvarchar(75)			not null	-- username who made the last status change
 ,LastStatusChangeTime		datetimeoffset(7) not null	-- date and time the last status change was made
 ,FormOwnerSID						int								not null	-- key of the related sf.FormOwner record
 ,FormOwnerSCD						varchar(25)				not null	-- person/group expected to perform next action to progress the form
 ,FormOwnerLabel					nvarchar(35)			not null	-- user-friendly name of person/group expected to perform next action to progress the form
 ,IsPDFDisplayed					bit								not null	-- indicates if PDF form version should be displayed rather than the HTML (form is complete)
 ,PersonDocSID						int								null			-- key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
 ,TotalDue								decimal(11, 2)		null			-- amount owing on invoice associated with the reinstatement (blank if no invoice created)
 ,IsUnPaid								bit								not null	-- indicates if the invoice associated with the reinstatement is unpaid
 ,PersonMailingAddressSID int								null			-- key of registrant's current mailing address - if any
 ,StreetAddress1					nvarchar(75)			null			-- current address values for the registrant:
 ,StreetAddress2					nvarchar(75)			null
 ,StreetAddress3					nvarchar(75)			null
 ,CityName								nvarchar(30)			null
 ,StateProvinceName				nvarchar(30)			null
 ,PostalCode							nvarchar(10)			null
 ,CountryName							nvarchar(50)			null
 ,CitySID									int								null
 ,PersonSID								int								not null	-- key of person associated with the reinstatement
 ,RegistrationYearLabel		varchar(9)				not null	-- string show 2 years if the registration year provided is not based on a calendar year
 ,PracticeRegisterLabel		nvarchar(35)			not null	-- label (short name) of the register this reinstatement is being made to
 ,PracticeRegisterName		nvarchar(65)			not null	-- name of the register this reinstatement is being made to
 ,ReinstatementLabel			nvarchar(80)			not null	-- a summary label for the reinstatement based on the register label and reinstatement status
-- Components unique to reinstatement process:
 ,IsRegisterChange				bit								not null	-- indicates if this reinstatement involves a change in register from the originating registration
 ,HasOpenAudit						bit								not null	-- indicates if the registrant has an open audit - normally blocks reinstatement
 ,IsReinstatementOpen			bit								not null	-- indicates if the reinstatement period is still open for saving (+30 min grace period included)
)
as
/*********************************************************************************************************************************
TableF	: Reinstatement Extended Columns
Notice	: Copyright © 2017 Softworks Group Inc.
Summary	: Returns a table of calculated columns for the Reinstatement extended view (vReinstatement#Ext)
History	: Author(s)  					| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund					| Aug 2017		|	Initial version
				: Tim Edlund					| Oct 2017		| Added support for AWAITINGDOCS status
				: Tim Edlund					| Jan	2018		| Added mailing address values
				: Tim Edlund					| Feb 2018		| Added IsPDFDisplayed + PersonDocSID to indicate when PDF is displayed instead of HTML
				: Tim Edlund					| Oct 2018		| Minor updates to work with revised #CurrentStatus function and removed unused columns
				: Tim Edlund					| Jan 2019		| Save enabled-bit changed to save-displayed and based on form version configuration
				
Comments	
--------

This function is called by the dbo.vReinstatement#Ext view to return a series of calculated values. By using a table function,
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
select
	rrx.*
from
(
	select top (10)
		frm.ReinstatementSID
	from
		dbo.Reinstatement frm
	order by
		newid()
)																																 x
cross apply dbo.fReinstatement#Ext(x.ReinstatementSID) rrx;

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fReinstatement#Ext'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@ON											 bit							= cast(1 as bit)											-- constant to eliminate repetitive casting syntax
	 ,@OFF										 bit							= cast(0 as bit)											-- constant to eliminate repetitive casting syntax
	 ,@isAdminLoggedIn				 bit							= cast(0 as bit)											-- indicates if current user is an administrator			
	 ,@isRegistrantLoggedIn		 bit							= cast(0 as bit)											-- indicates if the form registrant is the current user	
	 ,@isViewEnabled					 bit							= cast(0 as bit)											-- indicates whether either the (logged in) user or administrator can view the reinstatement
	 ,@isEditEnabled					 bit							= cast(0 as bit)											-- indicates whether the (logged in) user can edit/correct the form
	 ,@IsSaveBtnDisplayed			 bit							= cast(0 as bit)											-- indicates whether save button is displayed (configuration through sf.FormVersion + BR's)
	 ,@isApproveEnabled				 bit							= cast(0 as bit)											-- indicates whether the approve button should be made available to the user
	 ,@isRejectEnabled				 bit							= cast(0 as bit)											-- indicates whether the reject button should be made available to the user
	 ,@isUnlockEnabled				 bit							= cast(0 as bit)											-- indicates administrator can unlock form for editing even when in certain final statuses
	 ,@isWithdrawalEnabled		 bit							= cast(0 as bit)											-- indicates the reinstatement form can be withdrawn by administrators or SA's
	 ,@isInProgress						 bit							= cast(0 as bit)											-- indicates if the form is now closed/finalized or still in progress (open)		  
	 ,@isReviewRequired				 bit							= cast(0 as bit)											-- indicates if admin review of the form is required
	 ,@formStatusSID					 int																										-- key of current/latest reinstatement status 
	 ,@formStatusSCD					 varchar(25)																						-- current/latest reinstatement status		
	 ,@formStatusLabel				 nvarchar(35)																						-- user-friendly name for the reinstatement status		
	 ,@lastStatusChangeUser		 nvarchar(75)																						-- username who made the last status change
	 ,@lastStatusChangeTime		 datetimeoffset(7)																			-- date and time the last status change was made
	 ,@formOwnerSID						 int																										-- key of the related sf.FormOwner record
	 ,@formOwnerSCD						 varchar(25)																						-- person/group expected to perform next action to progress the main form
	 ,@formOwnerLabel					 nvarchar(35)																						-- user-friendly name of person/group expected to perform next action to progress the main form
	 ,@isPDFDisplayed					 bit							= cast(0 as bit)											-- indicates if PDF form version should be displayed rather than the HTML (form is complete)
	 ,@personDocSID						 int																										-- key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
	 ,@applicationUserSID			 int							= sf.fApplicationUserSessionUserSID() -- key of currently logged in user - to enable read/write on reinstatement
	 ,@hasOpenAudit						 bit																										-- indicates if the registrant has an open audit - normally blocks reinstatement
	 ,@totalDue								 decimal(11, 2)																					-- amount owing on invoice associated with the reinstatement (blank if no invoice created)
	 ,@totalPaid							 decimal(11, 2)																					-- amount paid on the reinstatement invoice (blank if no invoice created)
	 ,@isUnPaid								 bit							= cast(0 as bit)											-- indicates if the invoice associated with the reinstatement is unpaid
	 ,@personMailingAddressSID int																										-- key of the registrant's current mailing address (required for updates through the form)
	 ,@applicationEntitySID		 int																										-- key of the reinstatement entity; required to check for generated PDF
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
	 ,@practiceRegisterLabel	 nvarchar(35)																						-- label (short name) of the register this reinstatement is being made to
	 ,@practiceRegisterName		 nvarchar(65)																						-- name of the register this reinstatement is being made to
	 ,@reinstatementLabel			 nvarchar(80)																						-- a summary label for the reinstatement based on the register label and reinstatement status

	 ,@isRegisterChange				 bit							= cast(0 as bit)											-- indicates if this reinstatement involves a change in register from the originating registration
	 ,@reinstatementEndTime		 datetime																								-- time when reinstatement period has ended	(or when the registrants reinstatement is extended till)
	 ,@effectiveTime					 datetime																								-- date and time the renewed registration becomes/was active
	 ,@isReinstatementOpen		 bit							= cast(0 as bit);											-- indicates if the reinstatement period is still open for saving (+30 min grace period included)


	set @isAdminLoggedIn = sf.fIsGrantedToUserSID('ADMIN.RENEWAL', @applicationUserSID);

	-- retrieve the current status of the reinstatement and set
	-- identity values for determining read/write status

	select
		@formStatusSID				 = cs.FormStatusSID
	 ,@formStatusSCD				 = cs.FormStatusSCD
	 ,@formStatusLabel			 = cs.FormStatusLabel
	 ,@isInProgress					 = cs.IsInProgress
	 ,@isReviewRequired			 = cs.IsReviewRequired
	 ,@formOwnerSID					 = cs.FormOwnerSID
	 ,@formOwnerSCD					 = cs.FormOwnerSCD
	 ,@formOwnerLabel				 = cs.FormOwnerLabel
	 ,@lastStatusChangeUser	 = cs.LastStatusChangeUser
	 ,@lastStatusChangeTime	 = cs.LastStatusChangeTime
	 ,@totalDue							 = cs.TotalDue
	 ,@isUnPaid							 = cs.IsUnPaid
	 ,@totalPaid						 = cs.TotalPaid
	 ,@IsSaveBtnDisplayed		 = fv.IsSaveDisplayed
	 ,@isRegistrantLoggedIn	 = (case when au.ApplicationUserSID = @applicationUserSID then @ON else @OFF end)
	 ,@isRegisterChange			 = (case when pr.PracticeRegisterSID <> prFr.PracticeRegisterSID then @ON else @OFF end)
	 ,@personSID						 = r.PersonSID
	 ,@hasOpenAudit					 = dbo.fRegistrant#HasOpenAudit(r.RegistrantSID)
	 ,@practiceRegisterLabel = pr.PracticeRegisterLabel
	 ,@practiceRegisterName	 = pr.PracticeRegisterName
	 ,@effectiveTime				 = rlNext.EffectiveTime
	 ,@reinstatementEndTime	 = rsy.ReinstatementEndTime
	 ,@registrationYearLabel = (case
																when year(rsy.YearStartTime) = year(rsy.YearEndTime) then ltrim(rsy.RegistrationYear)
																else ltrim(year(rsy.YearStartTime)) + '/' + ltrim(year(rsy.YearEndTime))
															end
														 )
	 ,@reinstatementLabel		 =
			pr.PracticeRegisterLabel + (case when pr.PracticeRegisterSID <> prFr.PracticeRegisterSID then N'*' else N'' end) -- include asterisk if register change
			+ N' - ' + (case when cs.IsInProgress = cast(1 as bit) then 'In Progress' else cs.FormStatusLabel end)
	from
		dbo.Reinstatement																										 frm
	join
		dbo.PracticeRegisterSection																					 prs on frm.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister																								 pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
	join
		dbo.Registration																										 reg on frm.RegistrationSID = reg.RegistrationSID
	join
		dbo.PracticeRegisterSection																					 prsFr on reg.PracticeRegisterSectionSID = prsFr.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister																								 prFr on prsFr.PracticeRegisterSID = prFr.PracticeRegisterSID
	join
		dbo.Registrant																											 r on reg.RegistrantSID = r.RegistrantSID
	join
		sf.ApplicationUser																									 au on r.PersonSID = au.PersonSID -- determine the user ID of the member
	join
		dbo.RegistrationScheduleYear																				 rsy on frm.RegistrationYear = rsy.RegistrationYear
	join
		sf.FormVersion																											 fv on frm.FormVersionSID = fv.FormVersionSID
	left outer join
		dbo.Registration																										 rlNext on frm.RowGUID = rlNext.FormGUID
	outer apply dbo.fReinstatement#CurrentStatus(frm.ReinstatementSID, -1) cs -- function determines the current status of the form
	where
		frm.ReinstatementSID = @ReinstatementSID;

	set @reinstatementLabel += N' (' + @registrationYearLabel + N')';
	set @isViewEnabled = (case when @isAdminLoggedIn = @ON or @isRegistrantLoggedIn = @ON then @ON else @OFF end);

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

	-- the UI will allow the form to be submitted up to 30 minutes
	-- after the expiry of the renewal period based on this bit

	if sf.fNow() < dateadd(minute, 30, @reinstatementEndTime)
	begin
		set @isReinstatementOpen = @ON;
	end;

	-- withdrawal is enabled for administrators until the registration goes into
	-- effect; if invoice is paid only SA's can withdraw the form

	if @formStatusSCD = 'WITHDRAWN'
	begin
		set @isWithdrawalEnabled = @OFF;
	end;
	else if (@effectiveTime is null or @effectiveTime > sf.fNow()) and @isAdminLoggedIn = @ON
	begin

		if isnull(@totalPaid, 0.00) = 0.00
		begin
			set @isWithdrawalEnabled = @ON;
		end;
		else
		begin
			set @isWithdrawalEnabled = sf.fIsSysAdmin();
		end;

	end;

	-- if form is in final status and paid, check if
	-- PDF version should be shown instead of the HTML version

	if @isInProgress = @OFF and @isUnPaid = @OFF
	begin

		select
			@applicationEntitySID = ae.ApplicationEntitySID
		from
			sf.ApplicationEntity ae
		where
			ae.ApplicationEntitySCD = 'dbo.Reinstatement';

		select
			@personDocSID = pdc.PersonDocSID
		from
			dbo.PersonDocContext pdc
		where
			pdc.EntitySID = @ReinstatementSID and pdc.IsPrimary = @ON and pdc.ApplicationEntitySID = @applicationEntitySID;

		set @isPDFDisplayed = cast(isnull(@personDocSID, 0) as bit);
	end;

	-- set view/edit settings according to status and who is logged in
	-- form can be viewed by the owner (the user is logged in) or admins

	insert
		@reinstatement#Ext
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
	 ,TotalDue
	 ,IsUnPaid
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
	 ,PracticeRegisterLabel
	 ,PracticeRegisterName
	 ,ReinstatementLabel
	 ,IsRegisterChange
	 ,HasOpenAudit
	 ,IsReinstatementOpen
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
	 ,@totalDue
	 ,@isUnPaid
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
	 ,@practiceRegisterLabel
	 ,@practiceRegisterName
	 ,@reinstatementLabel
	 ,@isRegisterChange
	 ,@hasOpenAudit
	 ,@isReinstatementOpen;

	return;
end;
GO
