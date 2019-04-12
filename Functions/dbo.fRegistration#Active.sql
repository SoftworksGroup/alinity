SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistration#Active
(
	@ActiveTime datetime -- date and time at which to calculate active registrations
)
returns table
/*********************************************************************************************************************************
Function : Registration - Active
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Returns ALL active registrations at a given point in time
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- + ----------- + --------------------------------------------------------------------------------------
				 : Tim Edlund				| Jan 2018		| Initial version
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This function returns the active registration for ALL Registrants at a given point in time.  A registrant may have only 1 active 
registration at the same time in the current version of Alinity.

The function calls dbo.fRegistrant#ActiveRegistration to return the required records. This function provides alternate calling
syntax only. (Calls dbo.fRegistrant#ActiveRegistration(null, @ActiveTime)  See that function for documentation details.

Maintenance Note
----------------
When the column list of the dbo.fRegistrant#ActiveRegistration changes, this function requires updating!

Example
-------
<TestHarness>
  <Test Name = "OneRegistrant" IsDefault ="true" Description="Executes the function to return all currently active 
	registrations.">
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
	dbo.fRegistration#Active(@now) x;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:04"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistration#Active'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		x.RegistrantSID
	 ,x.PersonSID
	 ,x.RegistrationSID
	 ,x.RegistrantLabel
	 ,x.RegistrationNo
	 ,x.PracticeRegisterSID
	 ,x.PracticeRegisterSectionSID
	 ,x.EffectiveTime
	 ,x.ExpiryTime
	 ,x.PracticeRegisterName
	 ,x.PracticeRegisterLabel
	 ,x.IsActivePractice
	 ,x.PracticeRegisterSectionLabel
	 ,x.IsSectionDisplayedOnRegistration
	 ,x.RegistrationYear
	 ,x.RegistrationLabel
	 ,x.IsRenewalEnabled
	 ,x.RegisterRank
	 ,x.FirstName
	 ,x.MiddleNames
	 ,x.LastName
	 ,x.BirthDate
	from
		dbo.fRegistrant#ActiveRegistration(null, @ActiveTime) x
);
GO
