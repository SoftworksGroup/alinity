SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistration#Latest](@RegistrationYear smallint, @IsRenewalEnabled bit) -- registration year to return registrations for (not renewal year)
returns table
/*********************************************************************************************************************************
Function: Registration - Latest
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns the latest registration for a registrant in a given registration year (the registration that renews)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Oct 2017			|	Initial Version 
					Tim Edlund	| Nov 2017			| Refined to exclude if latest registration is on a non-renewing register (where parm passed)
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function supports searching routines where the last effective registration in a given registration year must be returned.  The
function is called in Renewal search to determine the registrations that must be renewed.  In that context the second parameter should
be passed as ON to only include registrations on registers which renew. The second parameter should be passed as NULL to obtain the
latest registration for all registers. Passing the second parameter as OFF only includes registrations on registers that don't all renewal.

The details for one registration (dbo.Registration) is returned for each Registrant (SID) including the main columns from the
practice register and section.  

If a registrant does not have a registration in the given year then no record is returned for them.

Example
--------------
 
<TestHarness>
  <Test Name = "CurrentYear" IsDefault ="true" Description="Executes the function to return renewal registration data for a random year.">
    <SQLScript>
      <![CDATA[

					declare
							@registrantSID							int
						,	@currentRegistrationYear		int
						, @practiceRegisterSectionSID	int
						,	@regEffective								datetime2
						,	@regExpiry									datetime2
					

			begin tran

			select top 1
				@registrantSID = r.RegistrantSID
			from
				dbo.Registrant r
			order by 
			newid()

			
			select
				@currentRegistrationYear = 	dbo.fRegistrationYear#Current()

			select
				@practiceRegisterSectionSID = prs.PracticeRegisterSectionSID
			from
				dbo.PracticeRegister pr
			join
				dbo.PracticeRegisterSection prs on pr.PracticeRegisterSID = prs.PracticeRegisterSID
			where
				pr.PracticeRegisterLabel = 'Active'
			and
				prs.IsActive = cast( 1 as bit)
			
				
			select
					@regEffective		= rsy.YearStartTime
				,	@regExpiry			= rsy.YearEndTime
			from
				dbo.RegistrationSchedule rs
			join
				dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID = rsy.RegistrationScheduleSID
			where
				rs.IsDefault = cast(1 as bit)
			and
				rsy.RegistrationYear = @currentRegistrationYear

			delete from dbo.Registration
			where
				RegistrantSID = @registrantSID

			insert into
				dbo.Registration
			(
					RegistrantSID
				,	PracticeRegisterSectionSID
				,	RegistrationYear
				,	LicenseNO
				,	EffectiveTime
				,	ExpiryTime
			)
			select
					@registrantSID
				,	@practiceRegisterSectionSID
				,	@currentRegistrationYear
				,	'***TEST***'
				, @regEffective
				,	@regExpiry
			
			select
				x.*
			from
				dbo.Registrant r
			outer apply
				dbo.fRegistration#Latest(@currentRegistrationYear, 1) x
			where
				r.RegistrantSID = @registrantSID
			
			
			if @@rowcount = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1) 
			if @@TRANCOUNT > 0 rollback


			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.fRegistration#Latest'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
as
return ( 
select
	rl.RegistrationSID
 ,rl.RegistrantSID
 ,rl.PracticeRegisterSectionSID
 ,rl.RegistrationNo
 ,rl.RegistrationYear
 ,rl.EffectiveTime
 ,rl.ExpiryTime
 ,rl.RegistrationXID
 ,rl.LegacyKey
 ,rl.IsDeleted
 ,rl.CreateUser
 ,rl.CreateTime
 ,rl.UpdateUser
 ,rl.UpdateTime
 ,rlMx.PracticeRegisterSID
 ,rlMx.PracticeRegisterSectionLabel
 ,rlMx.IsDisplayedOnLicense
 ,rlMx.PracticeRegisterTypeSID
 ,rlMx.RegistrationScheduleSID
 ,rlMx.PracticeRegisterName
 ,rlMx.PracticeRegisterLabel
 ,rlMx.IsActivePractice
 ,rlMx.IsPublicRegistryEnabled
 ,rlMx.IsRenewalEnabled
 ,rlMx.RegisterRank
from
	dbo.Registration							rl
cross apply
( select top(1)
		rlMx.RegistrationSID
	 ,prs.PracticeRegisterSID
	 ,prs.PracticeRegisterSectionLabel
	 ,prs.IsDisplayedOnLicense
	 ,pr.PracticeRegisterTypeSID
	 ,pr.RegistrationScheduleSID
	 ,pr.PracticeRegisterName
	 ,pr.PracticeRegisterLabel
	 ,pr.IsActivePractice
	 ,pr.IsPublicRegistryEnabled
	 ,pr.IsRenewalEnabled
	 ,pr.RegisterRank
	from
		dbo.Registration				rlMx
	join
		dbo.PracticeRegisterSection prs on rlMx.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister				pr on prs.PracticeRegisterSID					 = pr.PracticeRegisterSID 
	where
		rlMx.RegistrantSID = rl.RegistrantSID and rlMx.RegistrationYear = @RegistrationYear -- get latest for registration year - even if on a non-renewing register
	order by
		rlMx.EffectiveTime desc
	 ,rlMx.RegistrationSID desc) rlMx
where
	rl.RegistrationYear = @RegistrationYear
and 
	rl.RegistrationSID = rlmx.RegistrationSID
and
	rlMx.IsRenewalEnabled = isnull(@IsRenewalEnabled, rlMx.IsRenewalEnabled) -- now filter out if non-renewing!
)
GO
