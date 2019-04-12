SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrationChange#Ext (@RegistrationChangeSID int) -- key of record to check
returns @registrationChange#Ext table
(
	IsViewEnabled									 bit							 not null -- indicates whether either the (logged in) user or administrator can view the registration change
 ,IsEditEnabled									 bit							 not null -- indicates whether the (logged in) user can edit/correct the form
 ,IsApproveEnabled							 bit							 not null -- indicates whether the approve button should be made available to the user
 ,IsRejectEnabled								 bit							 not null -- indicates whether the reject button should be made available to the user
 ,IsUnlockEnabled								 bit							 not null -- indicates administrator can unlock form for editing even when in certain final statuses
 ,IsWithdrawalEnabled						 bit							 not null -- indicates the registration change form can be withdrawn by administrators or SA's
 ,IsInProgress									 bit							 not null -- indicates if the form is now closed/finalized or still in progress (open)	 
 ,FormStatusSID									 int							 not null -- key of current/latest registration change status 
 ,FormStatusSCD									 varchar(25)			 not null -- current/latest registration change status		
 ,FormStatusLabel								 nvarchar(35)			 not null -- user-friendly name for the registration change status		
 ,LastStatusChangeUser					 nvarchar(75)			 not null -- username who made the last status change
 ,LastStatusChangeTime					 datetimeoffset(7) not null -- date and time the last status change was made
 ,FormOwnerSID									 int							 not null -- key of the related sf.FormOwner record
 ,FormOwnerSCD									 varchar(25)			 not null -- person/group expected to perform next action to progress the form
 ,FormOwnerLabel								 nvarchar(35)			 not null -- user-friendly name of person/group expected to perform next action to progress the form
 ,IsPDFDisplayed								 bit							 not null -- indicates if PDF form version should be displayed rather than the HTML (form is complete)
 ,PersonDocSID									 int							 null			-- key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
 ,TotalDue											 decimal(11, 2)		 null			-- amount owing on invoice associated with the registration change (blank if no invoice created)
 ,IsUnPaid											 bit							 not null -- indicates if the invoice associated with the registration change is unpaid
 ,PersonMailingAddressSID				 int							 null			-- key of registrant's current mailing address - if any
 ,StreetAddress1								 nvarchar(75)			 null			-- current address values for the registrant:
 ,StreetAddress2								 nvarchar(75)			 null
 ,StreetAddress3								 nvarchar(75)			 null
 ,CityName											 nvarchar(30)			 null
 ,StateProvinceName							 nvarchar(30)			 null
 ,PostalCode										 nvarchar(10)			 null
 ,CountryName										 nvarchar(50)			 null
 ,CitySID												 int							 null
 ,PersonSID											 int							 not null -- key of person associated with the registration change
 ,RegistrationYearLabel					 varchar(9)				 not null -- string show 2 years if the registration year provided is not based on a calendar year
 ,PracticeRegisterLabel					 nvarchar(35)			 not null -- label (short name) of the register this registration change is being made to
 ,PracticeRegisterName					 nvarchar(65)			 not null -- name of the register this registration change is being made to
 ,RegistrationChangeLabel				 nvarchar(100)		 not null -- a summary label for the registration change based on the register label and registration change status
-- Components unique to registration change process:
 ,IsRegisterChange							 bit							 not null -- indicates if this registration change involves a change in register from the originating registration
 ,HasOpenAudit									 bit							 not null -- indicates if the registrant has an open audit - normally blocks registration change
)
as
/*********************************************************************************************************************************
TableF		: Registrant Application Extended Columns
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns a table of calculated columns for the Registration Change extended view (vRegistrationChange#Ext)
History		: Author(s)  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund  | Apr 2018		|	Initial version
					: Tim Edlund	| Oct 2018		| Minor updates to work with revised #CurrentStatus function and to remove unused columns

Comments	
--------

This function is called by the dbo.vRegistrationChange#Ext view to return a series of calculated values. By using a table function,
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
		frm.RegistrationChangeSID
	from
		dbo.RegistrationChange frm
	order by
		newid()
)																																 x
cross apply dbo.fRegistrationChange#Ext(x.RegistrationChangeSID) rrx;

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
	@ObjectName = 'dbo.fRegistrationChange#Ext'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin
	declare
		@ON															bit							 = cast(1 as bit)												-- constant to eliminate repetitive casting syntax
	 ,@OFF														bit							 = cast(0 as bit)												-- constant to eliminate repetitive casting syntax
	 ,@isAdminLoggedIn								bit							 = cast(0 as bit)												-- indicates if current user is an administrator			
	 ,@isViewEnabled									bit							 = cast(0 as bit)												-- indicates whether either the (logged in) user or administrator can view the registration change
	 ,@isEditEnabled									bit							 = cast(0 as bit)												-- indicates whether the (logged in) user can edit/correct the form
	 ,@isApproveEnabled								bit							 = cast(0 as bit)												-- indicates whether the approve button should be made available to the user
	 ,@isRejectEnabled								bit							 = cast(0 as bit)												-- indicates whether the reject button should be made available to the user
	 ,@isUnlockEnabled								bit							 = cast(0 as bit)												-- indicates administrator can unlock form for editing even when in certain final statuses
	 ,@isWithdrawalEnabled						bit							 = cast(0 as bit)												-- indicates the registration change form can be withdrawn by administrators or SA's
	 ,@isInProgress										bit							 = cast(0 as bit)												-- indicates if the form is now closed/finalized or still in progress (open)		  
	 ,@formStatusSID									int																											-- key of current/latest registration change status 
	 ,@formStatusSCD									varchar(25)																							-- current/latest registration change status		
	 ,@formStatusLabel								nvarchar(35)																						-- user-friendly name for the registration change status		
	 ,@lastStatusChangeUser						nvarchar(75)																						-- username who made the last status change
	 ,@lastStatusChangeTime						datetimeoffset(7)																				-- date and time the last status change was made
	 ,@formOwnerSID										int																											-- key of the related sf.FormOwner record
	 ,@formOwnerSCD										varchar(25)																							-- person/group expected to perform next action to progress the main form
	 ,@formOwnerLabel									nvarchar(35)																						-- user-friendly name of person/group expected to perform next action to progress the main form
	 ,@isPDFDisplayed									bit							 = cast(0 as bit)												-- indicates if PDF form version should be displayed rather than the HTML (form is complete)
	 ,@personDocSID										int																											-- key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
	 ,@applicationUserSID							int							 = sf.fApplicationUserSessionUserSID()	-- key of currently logged in user - to enable read/write on registration change
	 ,@hasOpenAudit										bit																											-- indicates if the registrant has an open audit - normally blocks registration change
	 ,@totalDue												decimal(11, 2)																					-- amount owing on invoice associated with the registration change (blank if no invoice created)
	 ,@totalPaid											decimal(11, 2)																					-- amount paid on the registration change invoice (blank if no invoice created)
	 ,@isUnPaid												bit							 = cast(0 as bit)												-- indicates if the invoice associated with the registration change is unpaid
	 ,@personMailingAddressSID				int																											-- key of the registrant's current mailing address (required for updates through the form)
	 ,@applicationEntitySID						int																											-- key of the registration change entity; required to check for generated PDF
	 ,@streetAddress1									nvarchar(75)																						-- current address values for the registrant:
	 ,@streetAddress2									nvarchar(75)
	 ,@streetAddress3									nvarchar(75)
	 ,@cityName												nvarchar(30)
	 ,@stateProvinceName							nvarchar(30)
	 ,@postalCode											nvarchar(10)
	 ,@countryName										nvarchar(50)
	 ,@citySID												int
	 ,@personSID											int																											-- key of person profile
	 ,@registrationYearLabel					varchar(9)																							-- string show 2 years if the registration year provided is not based on a calendar year
	 ,@practiceRegisterLabel					nvarchar(35)																						-- label (short name) of the register this registration change is being made to
	 ,@practiceRegisterName						nvarchar(65)																						-- name of the register this registration change is being made to
	 ,@registrationChangeLabel				nvarchar(100)																						-- a summary label for the registration change based on the register label and registration change status
	 ,@isRegisterChange								bit							 = cast(0 as bit)												-- indicates if this registration change involves a change in register from the originating registration
	 ,@effectiveTime									datetime;																								-- date and time the new registration becomes/was active

	set @isAdminLoggedIn = sf.fIsGrantedToUserSID('ADMIN.RENEWAL', @applicationUserSID);

	-- retrieve the current status of the registration change and set
	-- identity values for determining read/write status

	select
		@formStatusSID									= cs.FormStatusSID
	 ,@formStatusSCD									= cs.FormStatusSCD
	 ,@formStatusLabel								= cs.FormStatusLabel
	 ,@isInProgress										= cs.IsInProgress
	 ,@formOwnerSID										= cs.FormOwnerSID
	 ,@formOwnerSCD										= cs.FormOwnerSCD
	 ,@formOwnerLabel									= cs.FormOwnerLabel
	 ,@lastStatusChangeUser						= cs.LastStatusChangeUser
	 ,@lastStatusChangeTime						= cs.LastStatusChangeTime
	 ,@totalDue												= cs.TotalDue
	 ,@isUnPaid												= cs.IsUnPaid
	 ,@totalPaid											= cs.TotalPaid
	 ,@isRegisterChange								= (case when pr.PracticeRegisterSID <> prFr.PracticeRegisterSID then @ON else @OFF end)
	 ,@personSID											= r.PersonSID
	 ,@hasOpenAudit										= dbo.fRegistrant#HasOpenAudit(r.RegistrantSID)
	 ,@practiceRegisterLabel					= pr.PracticeRegisterLabel
	 ,@practiceRegisterName						= pr.PracticeRegisterName
	 ,@effectiveTime									= rlNext.EffectiveTime
	 ,@registrationYearLabel					= (case
																				 when year(rsy.YearStartTime) = year(rsy.YearEndTime) then ltrim(rsy.RegistrationYear)
																				 else ltrim(year(rsy.YearStartTime)) + '/' + ltrim(year(rsy.YearEndTime))
																			 end
																			)
	 ,@registrationChangeLabel				=
			pr.PracticeRegisterLabel + (case when pr.PracticeRegisterSID <> prFr.PracticeRegisterSID then N'*' else N'' end) -- include asterisk if register change
			+ N' - ' + (case when cs.IsInProgress = cast(1 as bit) then 'In Progress' else cs.FormStatusLabel end)
	from
		dbo.RegistrationChange																												 frm
	join
		dbo.PracticeRegisterSection																										 prs on frm.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister																													 pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
	join
		dbo.Registration																															 reg on frm.RegistrationSID = reg.RegistrationSID
	join
		dbo.PracticeRegisterSection																										 prsFr on reg.PracticeRegisterSectionSID = prsFr.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister																													 prFr on prsFr.PracticeRegisterSID = prFr.PracticeRegisterSID
	join
		dbo.Registrant																																 r on reg.RegistrantSID = r.RegistrantSID
	join
		dbo.RegistrationScheduleYear																									 rsy on frm.RegistrationYear = rsy.RegistrationYear
	left outer join
		dbo.Registration																															 rlNext on frm.RowGUID = rlNext.FormGUID
	outer apply dbo.fRegistrationChange#CurrentStatus(frm.RegistrationChangeSID, -1) cs -- function determines the current status of the form
	where
		frm.RegistrationChangeSID = @RegistrationChangeSID;

	set @registrationChangeLabel += N' (' + @registrationYearLabel + N')';
	set @isViewEnabled = @isAdminLoggedIn

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

			set @isEditEnabled = @isAdminLoggedIn;
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

	-- editing is disabled for non-admins

	if @isEditEnabled = @ON and @isAdminLoggedIn = @OFF
	begin
		set @isEditEnabled = @OFF;
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
			ae.ApplicationEntitySCD = 'dbo.RegistrationChange';

		select
			@personDocSID = pdc.PersonDocSID
		from
			dbo.PersonDocContext pdc
		where
			pdc.EntitySID = @RegistrationChangeSID and pdc.IsPrimary = @ON and pdc.ApplicationEntitySID = @applicationEntitySID;

		set @isPDFDisplayed = cast(isnull(@personDocSID, 0) as bit);
	end;

	-- set view/edit settings according to status and who is logged in
	-- form can be viewed by the owner (the user is logged in) or admins

	insert
		@registrationChange#Ext
	(
		IsViewEnabled
	 ,IsEditEnabled
	 ,IsApproveEnabled
	 ,IsRejectEnabled
	 ,IsUnlockEnabled
	 ,IsWithdrawalEnabled
	 ,IsInProgress
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
	 ,RegistrationChangeLabel
	 ,IsRegisterChange
	 ,HasOpenAudit
	)
	select
		@isViewEnabled
	 ,@isEditEnabled
	 ,@isApproveEnabled
	 ,@isRejectEnabled
	 ,@isUnlockEnabled
	 ,@isWithdrawalEnabled
	 ,@isInProgress
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
	 ,@registrationChangeLabel
	 ,@isRegisterChange
	 ,@hasOpenAudit;

	return;
end;
GO
