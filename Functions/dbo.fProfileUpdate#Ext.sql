SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fProfileUpdate#Ext (@ProfileUpdateSID int) -- key of record to return data set for
returns @profileUpdate#Ext table
(
	ProfileUpdateLabel	 nvarchar(80)			 not null -- a summary label for the profile update based on the member name and profile update status
 ,IsViewEnabled				 bit							 not null -- indicates whether either the (logged in) user or administrator can view the profile update
 ,IsEditEnabled				 bit							 not null -- indicates whether the (logged in) user can edit/correct the form
 ,IsSaveBtnDisplayed	 bit							 not null -- indicates whether save button is displayed (configuration through sf.FormVersion + BR's)
 ,IsApproveEnabled		 bit							 not null -- indicates whether the approve button should be made available to the user
 ,IsRejectEnabled			 bit							 not null -- indicates whether the reject button should be made available to the user
 ,IsUnlockEnabled			 bit							 not null -- indicates administrator can unlock form for editing even when in certain final statuses
 ,IsWithdrawalEnabled	 bit							 not null -- indicates the profile update form can be withdrawn by administrators or SA's
 ,IsInProgress				 bit							 not null -- indicates if the form is now closed/finalized or still in progress (open)	 
 ,IsReviewRequired		 bit							 not null -- indicates if admin review of the form is required
 ,FormStatusSID				 int							 not null -- key of current/latest profile update status 
 ,FormStatusSCD				 varchar(25)			 not null -- current/latest profile update status		
 ,FormStatusLabel			 nvarchar(35)			 not null -- user-friendly name for the profile update status		
 ,FormOwnerSID				 int							 not null -- key of the related sf.FormOwner record
 ,FormOwnerSCD				 varchar(25)			 not null -- person/group expected to perform next action to progress the form
 ,FormOwnerLabel			 nvarchar(35)			 not null -- user-friendly name of person/group expected to perform next action to progress the form
 ,LastStatusChangeUser nvarchar(75)			 not null -- username who made the last status change
 ,LastStatusChangeTime datetimeoffset(7) not null -- date and time the last status change was made
 ,IsPDFDisplayed			 bit							 not null -- indicates if PDF form version should be displayed rather than the HTML (form is complete)
 ,PersonDocSID				 int							 null			-- key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
)
as
/*********************************************************************************************************************************
TableF		: Profile Update - Extended Columns
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a table of calculated columns for the ProfileUpdate extended view (vProfileUpdate#Ext)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version
				: Tim Edlund					| Jan 2019		| Save enabled-bit changed to save-displayed and based on form version configuration

Comments	
--------
This function is called by the dbo.vProfileUpdate#Ext view to return a series of calculated values controlling options available
on the user interface and to report status of the form. By using a table function, many lookups required for the calculated values 
can be executed once rather than many times if separate functions are used.

Maintenance Notes
----------------- 
This function expects to be selected for a single primary key or small record sets.  The function is not designed for inclusion in 
SELECTs scanning large portions of the table.  Performance in that context may not be acceptable.
 
The data set returned by this function is consistent with data sets returned by other "f<TableName>#Ext" functions supporting
member form types.  Do not modify this function in such as way that the resulting data set will be unique.  If changes to the data 
set are required, apply them consistently through all functions of this type. Note that a variance in the data set for forms that 
do/don't include a related invoices is expected in the function.

Example
-------
<TestHarness>
	<Test Name = "Random" Description="Returns the extended columns for an instance of the entity selected at random.">
	<SQLScript>
	<![CDATA[
declare @profileUpdateSID int;

select top (1)
	@profileUpdateSID = pu.ProfileUpdateSID
from
	dbo.ProfileUpdate pu
order by
	newid();

if @@rowcount = 0 or @profileUpdateSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select x.* from	dbo.fProfileUpdate#Ext(@profileUpdateSID) x;
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
	 @ObjectName = 'dbo.fProfileUpdate#Ext'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@ON										bit							 = cast(1 as bit)												-- constant to eliminate repetitive casting syntax
	 ,@OFF									bit							 = cast(0 as bit)												-- constant to eliminate repetitive casting syntax
	 ,@isAdminLoggedIn			bit							 = cast(0 as bit)												-- indicates if current user is an administrator			
	 ,@isRegistrantLoggedIn bit							 = cast(0 as bit)												-- indicates if the form registrant is the current user	
	 ,@applicationUserSID		int							 = sf.fApplicationUserSessionUserSID()	-- key of currently logged in user - to enable read/write on profile update
	 ,@applicationEntitySID int																											-- key of the profile update entity; required to check for generated PDF
	 ,@parentRowGUID				uniqueidentifier																				-- the parent form's row 
	 ,@profileUpdateLabel		nvarchar(80)																						-- a summary label for the profile update based on the register label and profile update status
	 ,@isViewEnabled				bit							 = cast(0 as bit)												-- indicates whether either the (logged in) user or administrator can view the profile update
	 ,@isEditEnabled				bit							 = cast(0 as bit)												-- indicates whether the (logged in) user can edit/correct the form
	 ,@isSaveBtnDisplayed		bit							 = cast(0 as bit)												-- indicates whether save button is displayed (configuration through sf.FormVersion + BR's)
	 ,@isApproveEnabled			bit							 = cast(0 as bit)												-- indicates whether the approve button should be made available to the user
	 ,@isRejectEnabled			bit							 = cast(0 as bit)												-- indicates whether the reject button should be made available to the user
	 ,@isUnlockEnabled			bit							 = cast(0 as bit)												-- indicates administrator can unlock form for editing even when in certain final statuses
	 ,@isWithdrawalEnabled	bit							 = cast(0 as bit)												-- indicates the profile update form can be withdrawn by administrators or SA's
	 ,@isInProgress					bit							 = cast(0 as bit)												-- indicates if the form is now closed/finalized or still in progress (open)	 
	 ,@isReviewRequired			bit							 = cast(0 as bit)												-- indicates if admin review of the form is required
	 ,@formStatusSID				int																											-- key of current/latest profile update status 
	 ,@formStatusSCD				varchar(25)																							-- current/latest profile update status		
	 ,@formStatusLabel			nvarchar(35)																						-- user-friendly name for the profile update status		
	 ,@formOwnerSID					int																											-- key of the related sf.FormOwner record
	 ,@formOwnerSCD					varchar(25)																							-- person/group expected to perform next action to progress the form
	 ,@formOwnerLabel				nvarchar(35)																						-- user-friendly name of person/group expected to perform next action to progress the form
	 ,@lastStatusChangeUser nvarchar(75)																						-- username who made the last status change
	 ,@lastStatusChangeTime datetimeoffset(7)																				-- date and time the last status change was made
	 ,@parentFormStatusSCD	varchar(25)																							-- current status of parent form (Renewal)
	 ,@isPDFDisplayed				bit							 = cast(0 as bit)												-- indicates if PDF form version should be displayed rather than the HTML (form is complete)
	 ,@personDocSID					int;																										-- key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)

	-- retrieve the current status of the profile update and set
	-- identity values for determining read/write status

	select
		@formStatusSID				= cs.FormStatusSID
	 ,@formStatusSCD				= cs.FormStatusSCD
	 ,@formStatusLabel			= cs.FormStatusLabel
	 ,@isSaveBtnDisplayed		= fv.IsSaveDisplayed
	 ,@isInProgress					= cs.IsInProgress
	 ,@formOwnerSID					= cs.FormOwnerSID
	 ,@formOwnerSCD					= cs.FormOwnerSCD
	 ,@formOwnerLabel				= cs.FormOwnerLabel
	 ,@lastStatusChangeUser = cs.LastStatusChangeUser
	 ,@lastStatusChangeTime = cs.LastStatusChangeTime
	 ,@isReviewRequired			= cs.IsReviewRequired
	 ,@isRegistrantLoggedIn = (case when au.ApplicationUserSID = @applicationUserSID then @ON else @OFF end)
	 ,@parentRowGUID				= pu.ParentRowGUID
	 ,@profileUpdateLabel		=
			dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRANT') + N' - '
			+ case when cs.IsInProgress = cast(1 as bit) then ' In Progress' else cs.FormStatusLabel end
	from
		dbo.ProfileUpdate																										pu
	join
		sf.Person																														p on pu.PersonSID = p.PersonSID
	left outer join
		dbo.Registrant																											r on pu.PersonSID = r.PersonSID
	join
		sf.ApplicationUser																									au on pu.PersonSID = au.PersonSID -- determine the user ID of the registrant
	join
		sf.FormVersion																											fv on pu.FormVersionSID = fv.FormVersionSID
	outer apply dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) cs	-- function determines the current status of the form
	where
		pu.ProfileUpdateSID = @ProfileUpdateSID;

	set @isAdminLoggedIn = sf.fIsGrantedToUserSID('ADMIN.BASE', @applicationUserSID);
	set @isViewEnabled = (case when @isAdminLoggedIn = @ON or @isRegistrantLoggedIn = @ON then @ON else @OFF end);

	-- set bit values controlling editing and unlock; if form is APPROVED then all
	-- actions are blocked since form details already written to DB records

	if @formStatusSCD <> 'APPROVED'
	begin

		if @formStatusSCD = 'REJECTED'
		begin
			set @isUnlockEnabled = @isAdminLoggedIn; -- form can be unlocked by administrators when in this status
		end;
		else if @formStatusSCD = 'WITHDRAWN'
		begin
			set @isUnlockEnabled = @isAdminLoggedIn; -- form can be unlocked by admins when in this status
		end;
		else if @formStatusSCD = 'CORRECTED'
		begin

			set @isEditEnabled = @isAdminLoggedIn; -- administrators can continue editing after saving a correction
			set @isApproveEnabled = @isAdminLoggedIn;
			set @isRejectEnabled = @isAdminLoggedIn;

		end;
		else if @formStatusSCD = 'UNLOCKED'
		begin

			set @isEditEnabled = @isAdminLoggedIn; -- administrators can edit, return or assign a new final status
			set @isApproveEnabled = @isAdminLoggedIn;
			set @isRejectEnabled = @isAdminLoggedIn;

		end;
		else if @formStatusSCD in ('NEW', 'RETURNED', 'AWAITINGDOCS') -- normal statuses that allow registrant editing
		begin
			set @isEditEnabled = @isRegistrantLoggedIn;
			set @isUnlockEnabled = @isAdminLoggedIn;
			set @isApproveEnabled = @isAdminLoggedIn;
			set @isRejectEnabled = @isAdminLoggedIn;
		end;
		else if @formStatusSCD = 'SUBMITTED' and @parentRowGUID is not null -- editing of submitted forms is allowed if parent is still "NEW"
		begin

			select
				@parentFormStatusSCD = coalesce(rrcs.FormStatusSCD, recs.FormStatusSCD)
			from
				dbo.ProfileUpdate pu
			left outer join
				dbo.RegistrantRenewal rr on pu.ParentRowGUID = rr.RowGUID
			outer apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) rrcs
			left outer join
				dbo.Reinstatement re on pu.ParentRowGUID = re.RowGUID
			outer apply dbo.fReinstatement#CurrentStatus(re.ReinstatementSID, -1) recs
			where
				pu.ProfileUpdateSID = @ProfileUpdateSID;

			if @parentFormStatusSCD is not null and @parentFormStatusSCD not in ('NEW', 'RETURNED')
			begin
				set @isEditEnabled = @OFF; -- the parent renewal is submitted so registrant cannot edit child forms
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

			set @isEditEnabled = @isAdminLoggedIn; -- otherwise only administrators can edit
			set @isApproveEnabled = @isAdminLoggedIn;
			set @isRejectEnabled = @isAdminLoggedIn;

		end;
	end;

	-- where the save button is set to display in the form configuration, it is still
	-- turned off if editing is disabled or the registrant is not logged in, or if 
	-- the parent form is APPROVED (user must use "Submit" to save)

	if @isSaveBtnDisplayed = @ON
	begin

		if @isEditEnabled = @OFF or @isRegistrantLoggedIn = @OFF or @parentFormStatusSCD = 'APPROVED'
		begin
			set @isSaveBtnDisplayed = @OFF;
		end;

	end;

	-- withdrawal is enabled for administrators 

	set @isWithdrawalEnabled = @isAdminLoggedIn;

	-- if form is in final status, check if PDF version
	-- should be shown instead of the HTML version

	if @isInProgress = @OFF
	begin

		select
			@applicationEntitySID = ae.ApplicationEntitySID
		from
			sf.ApplicationEntity ae
		where
			ae.ApplicationEntitySCD = 'dbo.ProfileUpdate';

		select
			@personDocSID = pdc.PersonDocSID
		from
			dbo.PersonDocContext pdc
		where
			pdc.EntitySID = @ProfileUpdateSID and pdc.IsPrimary = @ON and pdc.ApplicationEntitySID = @applicationEntitySID;

		set @isPDFDisplayed = cast(isnull(@personDocSID, 0) as bit);
	end;

	-- set view/edit settings according to status and who is logged in
	-- form can be viewed by the owner (the user is logged in) or administrators

	insert
		@profileUpdate#Ext
	(
		ProfileUpdateLabel
	 ,IsViewEnabled
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
	 ,FormOwnerSID
	 ,FormOwnerSCD
	 ,FormOwnerLabel
	 ,LastStatusChangeUser
	 ,LastStatusChangeTime
	 ,IsPDFDisplayed
	 ,PersonDocSID
	)
	select
		@profileUpdateLabel
	 ,@isViewEnabled
	 ,@isEditEnabled
	 ,@isSaveBtnDisplayed
	 ,@isApproveEnabled
	 ,@isRejectEnabled
	 ,@isUnlockEnabled
	 ,@isWithdrawalEnabled
	 ,@isInProgress
	 ,@isReviewRequired
	 ,@formStatusSID
	 ,@formStatusSCD
	 ,@formStatusLabel
	 ,@formOwnerSID
	 ,@formOwnerSCD
	 ,@formOwnerLabel
	 ,@lastStatusChangeUser
	 ,@lastStatusChangeTime
	 ,@isPDFDisplayed
	 ,@personDocSID;

	return;
end;
GO
