SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrant#ActiveRegistrationCurrent]
(
	@RegistrantSID int			-- key of registrant to return current registrations for (NULL for all registrants)
)
returns table
/*********************************************************************************************************************************
Function : Registrant - Active Registration Current
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Returns the active registration for the given Registrant (or all) at the current time
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- + ----------- + --------------------------------------------------------------------------------------
				 : Tim Edlund				| Jan 2018		| Initial version
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This function returns the currently active registration for one registrant or all registrants if @RegistrantSID is passed as null.
A registrant may have only 1 active registration at the same time in the current version of Alinity.  The current time in the 
client time zone is used for determining whether a registration is active.

The function calls dbo.fRegistrant#ActiveRegistration to return the required records. This function provides alternate calling
syntax only. (Calls dbo.fRegistrant#ActiveRegistration(@RegistrantSID, null)  See that function for additional details.

Maintenance Note
----------------
When the column list of the dbo.fRegistrant#Registration changes, this function requires updating!

Example
-------
<TestHarness>
  <Test Name = "OneRegistrant" IsDefault ="true" Description="Executes the function to return registration data for a 
	single registrant.">
    <SQLScript>
      <![CDATA[
declare
		@registrantSID	int
	,	@now						datetime

set @now = sf.fNow()

select top (1)
	@registrantSID = rl.RegistrantSID
from
	dbo.Registration rl 
 where
  rl.ExpiryTime > @now
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
	dbo.fRegistrant#ActiveRegistrationCurrent(@registrantSID) x;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrant#ActiveRegistrationCurrent'
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
		dbo.fRegistrant#ActiveRegistration(@RegistrantSID, sf.fNow()) x
);
GO
