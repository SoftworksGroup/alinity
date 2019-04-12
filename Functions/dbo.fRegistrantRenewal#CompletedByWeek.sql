SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantRenewal#CompletedByWeek
(
	@RenewalYear smallint -- the renewal year to include in the analysis
)
returns table
/*********************************************************************************************************************************
Function: Registrant Renewal - Completed By Week
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns reporting/statistical data on renewals which have been completed over time
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Nov 2017			|	Initial Version 
				: Tim Edlund	| Jan 2018			| Updated to exclude registrations which expired in the target year before renewal opened
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function supports reporting routines on the renewal process.  It returns one row for each register and week-ending date
where renewals were completed (new registration generated). The query uses the same components as the Renewal Management dashboard 
screen.

Example
-------
<TestHarness>
  <Test Name = "RandomSelect" IsDefault ="true" Description="Executes the function to return records at random.">
    <SQLScript>
      <![CDATA[
declare
	@registrationYear  smallint
	
select top (100)
	@registrationyear	 = max(rl.RegistrationYear)
from
	dbo.Registration rl
order by
	newid()

select
	@RegistrationYear RenewalYear
 ,x.PracticeRegisterLabel
 ,x.RenewedWeekEndingDate
 ,x.FormCount
from
	dbo.fRegistrantRenewal#CompletedByWeek(@registrationYear) x
order by
	x.PracticeRegisterLabel
 ,x.RenewedWeekEndingDate;

if @@rowcount = 0 raiserror( N'* ERROR: no data found for test case', 18, 1)
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrantRenewal#CompletedByWeek'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		x.PracticeRegisterLabel
	 ,x.RenewedWeekEndingDate
	 ,count(1) FormCount
	from	(
					select
						rrs.PracticeRegisterLabel
					 ,cast(dateadd(dd, 7 - datepart(dw, rrs.LastStatusChangeTime), rrs.LastStatusChangeTime) as date) RenewedWeekEndingDate
					from
						dbo.fRegistration#Renewal(@RenewalYear - 1)								rl
					cross apply dbo.fRegistrantRenewal#Search2(rl.RegistrationSID) rrs
					where
						rrs.RenewedRegistrationNo is not null and rrs.LastStatusChangeTime is not null
				) x
	group by
		x.PracticeRegisterLabel
	 ,x.RenewedWeekEndingDate
);
GO
