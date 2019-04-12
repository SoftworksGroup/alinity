SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrant#LatestRegistration
(
	@RegistrantSID		int -- key of registrant to return registrations for (-1 for all registrants)
 ,@RegistrationYear int -- registration year to use as criteria for "latest" - null for current registration year
)
returns table
/*********************************************************************************************************************************
Function : Registrant - Latest Active Registration
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns last registration in effective for 1 registrant (or all registrants) at the current time or a registration year
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- + ----------- + --------------------------------------------------------------------------------------
				 : Tim Edlund				| Apr 2018		| Initial version
				 : Tim Edlund				| Sep 2018		| Column list expanded to support export views
 
Comments
--------
This function returns the latest active registration for a member, or all members. To return the data set for all members, pass 
-1.  The @RegistrationYear is an optional parameter. Leave it blank to return the latest registration in effect for the member.  
Provide a year to return the registration which was in effect (or will be in effect) at the end of that registration year. The 
registration returned may or may not be "Active Practice" so if only currently practicing members need to be isolated the 
Is-Active-Practice on the associated register must be evaluated.

Note that leaving the year blank will not return a future dated registration that has not become effective yet such as a new 
registration created during the renewal period. Passing the year is useful where examination of a specific registration year, 
or even a future year, is required.  

To always get the last registration that exists for a person (including future dated) use the 
dbo.fRegistrant#LastRegistration function.

Normalization 
-------------
A maximum of 1 registration row is returned for each registrant and a registrant will be included if they ever had a
registration record - even if cancelled.

Example
-------
<TestHarness>
  <Test Name = "OneRegistrant" IsDefault ="true" Description="Executes the function to return latest registration data for a 
	single registrant at random.">
    <SQLScript>
      <![CDATA[
declare
	@registrantSID int

select top (1)
	@registrantSID = reg.RegistrantSID
from
	dbo.Registration reg 
order by
	newid();

select
	x.*
from
	dbo.fRegistrant#LatestRegistration(@registrantSID, null) x;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
  <Test Name = "AllActive" IsDefault ="false" Description="Executes the function to return all latest registrations.">
    <SQLScript>
      <![CDATA[

select
	x.RegistrantSID
 ,x.RegistrationSID
 ,x.RegistrantLabel
 ,x.RegistrationNo
 ,x.PracticeRegisterSID
 ,x.PracticeRegisterSectionSID
 ,x.EffectiveTime
 ,x.ExpiryTime
 ,x.PracticeRegisterName
 ,x.PracticeRegisterLabel
from
	dbo.fRegistrant#LatestRegistration(-1, null) x;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
  <Test Name = "AllForAYear" IsDefault ="false" Description="Executes the function to return all latest registrations for a year at random.">
    <SQLScript>
      <![CDATA[

declare @registrationYear smallint;

select top (1)
	@registrationYear = reg.RegistrationYear
from
	dbo.Registration				 reg
join
	dbo.RegistrationScheduleYear rsy on reg.RegistrationYear = rsy.RegistrationYear
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	print @registrationYear;

	select
		x.RegistrantSID
	 ,x.RegistrationSID
	 ,x.RegistrantLabel
	 ,x.RegistrationNo
	 ,x.PracticeRegisterSID
	 ,x.PracticeRegisterSectionSID
	 ,x.EffectiveTime
	 ,x.ExpiryTime
	 ,x.PracticeRegisterName
	 ,x.PracticeRegisterLabel
	from
		dbo.fRegistrant#LatestRegistration(-1, @registrationYear) x;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrant#LatestRegistration'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		reg.RegistrantSID
	 ,p.PersonSID
	 ,reg.RegistrationSID
	 ,r.RegistrantNo
	 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRANT') RegistrantLabel --# display label for the registrant
	 ,p.FirstName
	 ,p.MiddleNames
	 ,p.LastName
	 ,p.CommonName
	 ,p.BirthDate
	 ,p.DeathDate
	 ,pea.PersonEmailAddressSID
	 ,pea.EmailAddress
	 ,p.HomePhone
	 ,p.MobilePhone
	 ,r.IsOnPublicRegistry
	 ,r.RenewalExtensionExpiryTime
	 ,reg.RegistrationYear
	 ,dbo.fRegistration#Label(reg.RegistrationSID)																								RegistrationLabel
	 ,reg.RegistrationNo
	 ,prs.PracticeRegisterSID
	 ,reg.PracticeRegisterSectionSID
	 ,reg.EffectiveTime
	 ,reg.ExpiryTime
	 ,reg.CardPrintedTime
	 ,reg.ReasonSID
	 ,rsn.ReasonGroupSID
	 ,rsn.ReasonName
	 ,pr.PracticeRegisterName
	 ,pr.PracticeRegisterLabel
	 ,pr.IsActivePractice
	 ,pr.IsLearningPlanEnabled
	 ,pr.LearningModelSID
	 ,prs.PracticeRegisterSectionLabel
	 ,prs.IsDisplayedOnLicense																																		IsSectionDisplayedOnRegistration
	 ,pr.IsRenewalEnabled
	 ,pr.RegisterRank
	 ,p.LegacyKey PersonLegacyKey
	 ,(case
			 when pr.IsActivePractice = cast(1 as bit) then sf.fIsActive(reg.EffectiveTime, reg.ExpiryTime)
			 else cast(0 as bit)
		 end
		)																																														RegistrantIsCurrentlyActive
	from
		dbo.fRegistrant#LatestRegistration$SID(@RegistrantSID, @RegistrationYear) rlMX
	join
		dbo.Registration																													reg on rlMX.RegistrationSID						= reg.RegistrationSID
	join
		dbo.Registrant																														r on reg.RegistrantSID								= r.RegistrantSID
	join
		sf.Person																																	p on r.PersonSID											= p.PersonSID
	join
		dbo.PracticeRegisterSection																								prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister																											pr on prs.PracticeRegisterSID					= pr.PracticeRegisterSID
	left outer join
		dbo.Reason																																rsn on reg.ReasonSID									= rsn.ReasonSID
	left outer join
		sf.PersonEmailAddress																											pea on p.PersonSID										= pea.PersonSID and pea.IsPrimary = cast(1 as bit) and pea.IsActive = cast(1 as bit)
);
GO
