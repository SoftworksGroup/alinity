SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistration#Renewal (@RegistrationYear smallint) -- registration year (NOT RENEWAL YEAR) to return registrations for
returns table
/*********************************************************************************************************************************
Function: Registration - Renewal
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns the registrations eligible to renew that are active in the given registration year
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Jan 2018			|	Initial Version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function supports searching routines on renewals.  It calls the registration-latest function to return the last registration
that was active in a given registration year.  This function applies one additional WHERE clause to exclude the registration if it
expired in that year BEFORE renewal was made open.  These individuals are not eligible to renew and must re-instate.

Be sure that the registration year of the registrations to return is being passed in and not the renewal year.  The function
adds 1 year to the Registration Year provided to select the appropriate schedule and renewal open date. 

Example
--------------

<TestHarness>
  <Test Name = "RandomYear" IsDefault ="true" Description="Executes the function to return renewal registration data for a random year.">
    <SQLScript>
      <![CDATA[

		declare
			@registrationYear  smallint
			
		select top 1
			@registrationyear	 = max(rl.RegistrationYear)
		from
			dbo.Registration rl
		
		
		select
			x.RegistrationSID
		 ,x.RegistrantSID
		 ,x.PracticeRegisterSectionSID
		 ,x.RegistrationNo
		 ,x.RegistrationYear
		 ,x.EffectiveTime
		 ,x.ExpiryTime
		from
			dbo.fRegistration#Renewal(@registrationYear - 1) x
		
		
		
		if @@rowcount = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1) 

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.fRegistration#Renewal'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		rll.RegistrationSID
	 ,rll.RegistrantSID
	 ,rll.PracticeRegisterSectionSID
	 ,rll.RegistrationNo
	 ,rll.RegistrationYear
	 ,rll.EffectiveTime
	 ,rll.ExpiryTime
	 ,rll.RegistrationXID
	 ,rll.LegacyKey
	 ,rll.IsDeleted
	 ,rll.CreateUser
	 ,rll.CreateTime
	 ,rll.UpdateUser
	 ,rll.UpdateTime
	 ,rll.PracticeRegisterSID
	 ,rll.PracticeRegisterSectionLabel
	 ,rll.IsDisplayedOnLicense
	 ,rll.PracticeRegisterTypeSID
	 ,rll.RegistrationScheduleSID
	 ,rll.PracticeRegisterName
	 ,rll.PracticeRegisterLabel
	 ,rll.IsActivePractice
	 ,rll.IsPublicRegistryEnabled
	 ,rll.IsRenewalEnabled
	 ,rll.RegisterRank
	from
		dbo.fRegistration#Latest(@RegistrationYear, cast(1 as bit)) rll
	join
		dbo.RegistrationScheduleYear																		 rsy on rsy.RegistrationYear = (@RegistrationYear + 1)
	where
		rll.ExpiryTime > rsy.RenewalGeneralOpenTime -- exclude if the registration expired in the given RENEWAL year before renewal opened!
);
GO
