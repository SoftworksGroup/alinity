SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrant#ActiveRegistration]
(
	@RegistrantSID int			-- key of registrant to return registrations for (NULL for all registrants)
 ,@ActiveTime		 datetime -- date and time at which to check for an active registration (Required)
)
returns table
/*********************************************************************************************************************************
Function : Registrant - Active Registrations
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Returns a data set for the active registration for a registrant (or all registrants) at a given point in time
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- + ----------- + --------------------------------------------------------------------------------------
				 : Tim Edlund				| Jan 2018		| Initial version
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This function returns the active registration for a Registrant at a given point in time.  A registrant may have only 1 active 
registration at the same time in the current version of Alinity. The @ActiveTime parameter must be passed by the caller.  It 
should be set to sf.fNow() to pass the current time in the user time zone.  The value is not defaulted to sf.fNow() within this 
function to improve performance. The @RegistrantSID can be passed as null to return ALL active registrations in the system at the 
@ActiveTime passed in. 

Alternate Calling Syntax
------------------------
There are alternate calling syntaxes provided that also call this function:

dbo.fRegistration#Active(@ActiveTime)						
	- calls dbo.fRegistrant#ActiveRegistration(null, @ActiveTime)
	- returns ALL active registrations

dbo.fRegistrant#ActiveRegistrationCurrent(@RegistrantSID) 
	- calls dbo.fRegistrant#ActiveRegistration(@RegistrantSID, sf.fNow())
	- returns active registrations for a registrant at the current time

Maintenance Note
----------------
When the column list of this function changes, then dbo.fRegistration#Active and fRegistrant#ActiveRegistrationCurrent must
also be updated!

Call Syntax/Test Harness
------------------------
<TestHarness>
  <Test Name = "OneRegistrant" IsDefault ="true" Description="Executes the function to return registration data for a 
	single registrant.">
    <SQLScript>
      <![CDATA[
declare
	@registrantSID int
 ,@now					 datetime = sf.fNow();

select top (1)
	@registrantSID = reg.RegistrantSID
from
	dbo.Registration reg 
 where
  reg.ExpiryTime > @now
order by
	newid();

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
	dbo.fRegistrant#ActiveRegistration(@registrantSID, @now) x;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
  <Test Name = "AllActive" IsDefault ="false" Description="Executes the function to return all currently active registrations.">
    <SQLScript>
      <![CDATA[
declare
  @now					 datetime = sf.fNow();

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
	dbo.fRegistrant#ActiveRegistration(null, @now) x;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:04"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrant#ActiveRegistration'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		reg.RegistrantSID
	 ,p.PersonSID
	 ,reg.RegistrationSID
	 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRANT')												RegistrantLabel --# display label for the registrant
	 ,reg.RegistrationNo	
	 ,prs.PracticeRegisterSID
	 ,reg.PracticeRegisterSectionSID
	 ,reg.EffectiveTime
	 ,reg.ExpiryTime
	 ,pr.PracticeRegisterName
	 ,pr.PracticeRegisterLabel
	 ,pr.IsActivePractice
	 ,prs.PracticeRegisterSectionLabel
	 ,prs.IsDisplayedOnLicense																																													IsSectionDisplayedOnRegistration
	 ,reg.RegistrationYear
	 ,ltrim(reg.RegistrationYear) + N' ' + pr.PracticeRegisterLabel
		+ (case when prs.IsDisplayedOnLicense = cast(1 as bit) then ' - ' + prs.PracticeRegisterSectionLabel else '' end) RegistrationLabel
	 ,pr.IsRenewalEnabled
	 ,pr.RegisterRank
	 ,p.FirstName
	 ,p.MiddleNames
	 ,p.LastName
	 ,p.BirthDate
	from
		dbo.Registration				reg
	join
		dbo.Registrant							r on reg.RegistrantSID								 = r.RegistrantSID
	join
		sf.Person										p on r.PersonSID										 = p.PersonSID
	join
		dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister				pr on prs.PracticeRegisterSID				 = pr.PracticeRegisterSID
	where
		(
			@RegistrantSID is null or reg.RegistrantSID											 = @RegistrantSID
		) and sf.fIsActiveAt(reg.EffectiveTime, reg.ExpiryTime, @ActiveTime) = cast(1 as bit)
);
GO
