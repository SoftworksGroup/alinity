SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrant#LatestRegistration2] (@registrantSID int) -- key of registrant to return latest Registration for
returns @LatestRegistration table
(
	RegistrantSID								 int								-- key of registrant who Registration are assigned to
 ,RegistrationSID							 int								-- key of registration returned
 ,RegistrantRenewalSID				 int								-- key of renewal associated with the registration if any
 ,RegistrationNo							 nvarchar(50)				-- system assigned registration number based on registrantNo.year.sequence
 ,PracticeRegisterSID					 int								-- key of the practice register the registration is under
 ,PracticeRegisterSectionSID	 int								-- key of the section of register the registration is under
 ,EffectiveTime								 datetime						-- date and time registration became effective
 ,ExpiryTime									 datetime						-- date and time the registration expires/expired
 ,PracticeRegisterName				 nvarchar(65)				-- name of the practice register registration is under
 ,PracticeRegisterLabel				 nvarchar(35)				-- label of the practice register registration is under	
 ,IsActivePractice						 bit								-- indicates whether type of registration is active practice
 ,PracticeRegisterSectionLabel nvarchar(35)				-- label of the section of register the registration is under		
 ,IsSectionDisplayedOnLicense	 bit								-- indicates whether the section is displayed on registration
 ,LicenseRegistrationYear			 smallint						-- registration year the registration is/was in effect
 ,RenewalRegistrationYear			 smallint						-- registration year the next renewal is available for (null if not available)
 ,RenewalStatusSCD						 varchar(25)				-- status code of the registration's renewal - if any
 ,RenewalStatusLabel					 nvarchar(35)				-- status label of the registration's renewal - if any
 ,RenewalUpdateTime						 datetimeoffset(7)	-- date and time renewal of the registration was last updated 
 ,RenewalIsEditEnabled				 bit								-- whether edit is enabled on the renewal form associated with registration
 ,RenewalIsDeleteEnabled			 bit								-- whether delete is enabled on renewal form associated with registration
 ,RenewalIsUnPaid							 bit								-- whether invoice associated with the Registration renewal is unpaid
 ,RenewalTotalDue							 decimal(11, 2)			-- amount due on invoice associated with the registration - if any
 ,RenewalIsRegisterChange			 bit								-- whether the latest renewal reflected a register change
 ,IsCurrentUserVerifier				 bit								-- whether the latest logged in user is a verifier (has early access to renewal)
 ,RegistrationLabel						 nvarchar(80)				-- a label to use to display the registration/registration
 ,IsRenewalEnabled						 bit								-- whether renewal is enabled for this registration
 ,IsReinstatementEnabled			 bit								-- whether reinstatement is enabled for this registration
 ,RegisterRank								 smallint						-- rank order of the registration based on register rank
)
/*********************************************************************************************************************************
Function  : Registrant - Get Latest License
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This function returns a data set of Latest Registration for a registrant along with renewal status
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- | ------------|---------------------------------------------------------------------------------------
				 : Tim Edlund				| Sep 2017 		| Initial version.
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This function is used in display of registrant records to show the currently active registration, or the registration that was 
previously active if the registrant no longer has an active registration.  

Note that if a registrant has a current registration, it is always returned even if a renewed registration for a later period exists.
In that sense, the registration returned is not "latest" but more accurately the "latest registration that was or is active".  If no
active registration exists, then the registration that was most recently active is returned.  A future dated or pending registration is
never returned by the function.

Maintenance Note
----------------
The structure returned by this function and that returned by dbo.fRegistrant#CurrentRegistrations must be kept the same since 
the #Latest function calls the #Current one expecting the same structure.  This function also uses the same content
selection as the #CurrentRegistrations function - only the WHERE clause is different.

Call Syntax
-----------
declare @registrantSID int;

-- select for someone with a renewal record

select top 1
	@registrantSID = r.RegistrantSID
from
	dbo.RegistrantRenewal x
join
	dbo.Registration rl on x.RegistrationSID = rl.RegistrationSID
join
	dbo.Registrant				r on rl.RegistrantSID				 = r.RegistrantSID
where
	x.RegistrationYear = dbo.fRegistrationYear#Current() + 1
order by
	newid();

select
	*
from
	dbo.fRegistrant#LatestRegistration(@registrantSID) x;

------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
		@ON										 bit			= cast(1 as bit)													-- constant for bit comparisons = 1
	 ,@OFF									 bit			= cast(0 as bit)													-- constant for bit comparison = 0
	 ,@isCurrentUserVerifier bit			= sf.fIsGranted('EXTERNAL.VERIFICATION')	-- indicates if the current user is a renewal verifier
	 ,@now									 datetime = sf.fNow();															-- Latest time in user timezone

	-- first attempt to find the latest active
	-- registration for the registrant

	insert
		@LatestRegistration
	(
		RegistrantSID
	 ,RegistrationSID
	 ,RegistrantRenewalSID
	 ,RegistrationNo
	 ,PracticeRegisterSID
	 ,PracticeRegisterSectionSID
	 ,EffectiveTime
	 ,ExpiryTime
	 ,PracticeRegisterName
	 ,PracticeRegisterLabel
	 ,IsActivePractice
	 ,PracticeRegisterSectionLabel
	 ,IsSectionDisplayedOnLicense
	 ,LicenseRegistrationYear
	 ,RenewalRegistrationYear
	 ,RenewalStatusSCD
	 ,RenewalStatusLabel
	 ,RenewalUpdateTime
	 ,RenewalIsEditEnabled
	 ,RenewalIsDeleteEnabled
	 ,RenewalIsUnPaid
	 ,RenewalTotalDue
	 ,RenewalIsRegisterChange
	 ,IsCurrentUserVerifier
	 ,RegistrationLabel
	 ,IsRenewalEnabled
	 ,IsReinstatementEnabled
	 ,RegisterRank
	)
	select top (1)
		rcl.RegistrantSID
	 ,rcl.RegistrationSID
	 ,rcl.RegistrantRenewalSID
	 ,rcl.RegistrationNo
	 ,rcl.PracticeRegisterSID
	 ,rcl.PracticeRegisterSectionSID
	 ,rcl.EffectiveTime
	 ,rcl.ExpiryTime
	 ,rcl.PracticeRegisterName
	 ,rcl.PracticeRegisterLabel
	 ,rcl.IsActivePractice
	 ,rcl.PracticeRegisterSectionLabel
	 ,rcl.IsSectionDisplayedOnLicense
	 ,rcl.LicenseRegistrationYear
	 ,rcl.RenewalRegistrationYear
	 ,rcl.RenewalStatusSCD
	 ,rcl.RenewalStatusLabel
	 ,rcl.RenewalUpdateTime
	 ,rcl.RenewalIsEditEnabled
	 ,rcl.RenewalIsDeleteEnabled
	 ,rcl.RenewalIsUnPaid
	 ,rcl.RenewalTotalDue
	 ,rcl.RenewalIsRegisterChange
	 ,rcl.IsCurrentUserVerifier
	 ,rcl.RegistrationLabel
	 ,rcl.IsRenewalEnabled
	 ,rcl.IsReinstatementEnabled
	 ,rcl.RegisterRank
	from
		dbo.fRegistrant#CurrentRegistrations(@registrantSID) rcl
	order by
		rcl.EffectiveTime desc;

	-- if no active registrations exist, then look for
	-- latest effective registration (now expired)

	if @@rowcount = 0
	begin

		insert
			@LatestRegistration
		(
			RegistrantSID
		 ,RegistrationSID
		 ,RegistrantRenewalSID
		 ,RegistrationNo
		 ,PracticeRegisterSID
		 ,PracticeRegisterSectionSID
		 ,EffectiveTime
		 ,ExpiryTime
		 ,PracticeRegisterName
		 ,PracticeRegisterLabel
		 ,IsActivePractice
		 ,PracticeRegisterSectionLabel
		 ,IsSectionDisplayedOnLicense
		 ,LicenseRegistrationYear
		 ,RenewalRegistrationYear
		 ,RenewalStatusSCD
		 ,RenewalStatusLabel
		 ,RenewalUpdateTime
		 ,RenewalIsEditEnabled
		 ,RenewalIsDeleteEnabled
		 ,RenewalIsUnPaid
		 ,RenewalTotalDue
		 ,RenewalIsRegisterChange
		 ,IsCurrentUserVerifier
		 ,RegistrationLabel
		 ,IsRenewalEnabled
		 ,IsReinstatementEnabled
		 ,RegisterRank
		)
		select top (1)
			rl.RegistrantSID
		 ,rl.RegistrationSID
		 ,rr.RegistrantRenewalSID			-- ** Maintenance Note:  if modifying this SELECT also change fRegistrant#CurrentRegistrations function !!
		 ,rl.RegistrationNo
		 ,prs.PracticeRegisterSID
		 ,rl.PracticeRegisterSectionSID
		 ,rl.EffectiveTime
		 ,rl.ExpiryTime
		 ,pr.PracticeRegisterName
		 ,pr.PracticeRegisterLabel
		 ,pr.IsActivePractice
		 ,prs.PracticeRegisterSectionLabel
		 ,prs.IsDisplayedOnLicense																																													IsSectionDisplayedOnLicense
		 ,rl.RegistrationYear																																																LicenseRegistrationYear
		 ,rr.RegistrationYear																																																RenewalRegistrationYear
		 ,rr.FormStatusSCD																																											RenewalStatusSCD
		 ,rr.FormStatusLabel																																										RenewalStatusLabel
		 ,rr.UpdateTime																																																			RenewalUpdateTime
		 ,isnull(rr.IsEditEnabled, cast(0 as bit))																																					RenewalIsEditEnabled
		 ,dbo.fRegistrantRenewal#IsDeleteEnabled(rr.RegistrantRenewalSID)																										RenewalIsDeleteEnabled
		 ,isnull(rr.IsUnPaid, @OFF)																																													RenewalIsUnPaid
		 ,rr.TotalDue																																																				RenewalTotalDue
		 ,isnull(rr.IsRegisterChange, @OFF)																																									RenewalIsRegisterChange
		 ,@isCurrentUserVerifier																																														IsCurrentUserVerifier
		 ,ltrim(rl.RegistrationYear) + N' ' + pr.PracticeRegisterLabel
			+ (case when prs.IsDisplayedOnLicense = cast(1 as bit) then ' - ' + prs.PracticeRegisterSectionLabel else '' end) RegistrationLabel
		 ,case
				when rr.RegistrantRenewalSID is not null then @OFF					 -- registration already has a renewal record
				when pr.IsRenewalEnabled = @OFF then @OFF										 -- register does not allow renewal
				else cast(isnull(rsy.RegistrationScheduleYearSID, 0) as bit) -- otherwise check schedule for open renewal
			end																																																								IsRenewalEnabled
		 ,cast(0 as	 bit)																																																		IsReinstatementEnabled	-- TODO: Tim Sep 2017 Not yet implemented
		 ,pr.RegisterRank
		from
			dbo.Registration						 rl
		join
			dbo.PracticeRegisterSection	 prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
		join
			dbo.PracticeRegister				 pr on prs.PracticeRegisterSID				= pr.PracticeRegisterSID
		left outer join
		(
			select
				rr.RegistrantRenewalSID
			 ,rr.RegistrationSID
			 ,rr.RegistrationYear
			 ,rrx.FormStatusSCD
			 ,rrx.FormStatusLabel
			 ,rr.UpdateTime
			 ,rrx.IsEditEnabled
			 ,rrx.IsUnPaid
			 ,rrx.TotalDue
			 ,rrx.IsRegisterChange
			from
				dbo.RegistrantRenewal																					rr
			cross apply dbo.fRegistrantRenewal#Ext(rr.RegistrantRenewalSID) rrx
			where
				isnull(rrx.FormStatusSCD, 'NEW') <> 'WITHDRAWN'	-- user may withdraw initial renewal and create second one (ignore withdrawn renewals)
		)															 rr on rl.RegistrationSID							= rr.RegistrationSID
		left outer join
			dbo.RegistrationScheduleYear rsy on pr.RegistrationScheduleSID		= rsy.RegistrationScheduleSID
																					and rsy.RegistrationYear			= rl.RegistrationYear + 1
																					and (@now
																					between (case when @isCurrentUserVerifier = @ON then rsy.RenewalVerificationOpenTime else rsy.RenewalGeneralOpenTime end) and rsy.RenewalEndTime
																							)
		where
			rl.RegistrantSID = @registrantSID
		order by
			rl.EffectiveTime desc;

	end;

	return;
end;
GO
