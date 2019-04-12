SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrantRenewal#TimeToSubmitByAge]
(
	@RenewalYear				 smallint -- the renewal year to include in the analysis
 ,@PracticeRegisterSID int			-- the register to analyze results for
)
returns table
/*********************************************************************************************************************************
Function: Registrant Renewal - Time to Submit (form) by Age
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns reporting/statistical data on the amount of time individuals require to submit their renewal forms by age range
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Nov 2017			|	Initial Version 
				: Tim Edlund	| Jan 2018			| Updated to exclude registrations which expired in the target year before renewal opened
				: Tim Edlund	| Jul 2018			| Updated to apply dbo.AgeRange table rather than hard-coded view
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function supports reporting routines on the renewal process.  It returns one row for each time band (in minutes) and age range
(registrant age in years) measuring the duration for renewal form completion.  The analysis measures the gap in time between the 
form creation time and the time the first "SUBMIT" status was recorded.  Where an individual saves their form and submits on 
another day, the form is put into a "multiple-day" category. The query uses the same general components as the Renewal Management 
dashboard screen.

Limitation
----------
End users cannot adjust the time or age ranges.  They are fixed as a derived table within this procedure.

Example
-------
<TestHarness>
  <Test Name = "RandomSelect" IsDefault ="true" Description="Executes the function to return records at random.">
    <SQLScript>
      <![CDATA[
declare
	@renewalYear					 smallint 
 ,@practiceRegisterSID	 int
 ,@practiceRegisterLabel nvarchar(35);
	
select top (100)
	@renewalYear	 = max(rl.RegistrationYear)
from
	dbo.Registration rl
order by
	newid()

select top (1)
	@practiceRegisterSID	 = pr.PracticeRegisterSID
 ,@practiceRegisterLabel = pr.PracticeRegisterLabel
from
	dbo.PracticeRegister pr
where
	pr.IsRenewalEnabled = 1 and pr.IsActivePractice = 1 and pr.IsActive = 1
order by
	pr.PracticeRegisterSID;

select
	x.AgeRange
 ,x.TimeBand
 ,x.FormCount
 ,@practiceRegisterLabel PracticeRegisterLabel
 ,x.AgeRangeDisplayOrder
 ,x.TimeBandDisplayOrder
from
	dbo.fRegistrantRenewal#TimeToSubmitByAge(@renewalYear, @practiceRegisterSID) x
order by
	x.AgeRangeDisplayOrder
 ,x.TimeBandDisplayOrder;

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
	 @ObjectName = 'dbo.fRegistrantRenewal#TimeToSubmitByAge'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return select
				 z.DisplayOrder AgeRangeDisplayOrder
				,z.AgeRangeLabel AgeRange
				,z.TimeBand
				,z.TimeBandDisplayOrder
				,count(1) FormCount
			 from
				(
					select
						case
							when tb.StartDuration is null and rr.FormCompletionMinutes < 15 then '< 15 Minutes'
							when tb.StartDuration is null and rr.FormCompletionMinutes > 90 then 'Multiple sessions'
							else ltrim(tb.StartDuration) + '-' + ltrim(tb.EndDuration) + ' Minutes'
						end TimeBand
					 ,case
							when tb.StartDuration is null and rr.FormCompletionMinutes < 15 then 1
							when tb.StartDuration is null and rr.FormCompletionMinutes > 90 then 9
							else tb.DisplayOrder
						end TimeBandDisplayOrder
					 ,ar.AgeRangeLabel
					 ,ar.DisplayOrder
					from
					(
						select
							rr.RegistrantRenewalSID
						 ,datediff(minute, rr.CreateTime, rrs.CreateTime) FormCompletionMinutes
						 ,sf.fAgeInYears(p.BirthDate, rrs.CreateTime)			RegistrantAge
						from
							dbo.fRegistration#Renewal(@RenewalYear - 1) rl
						join
							dbo.RegistrantRenewal												rr on rl.RegistrationSID			 = rr.RegistrationSID
						join
							dbo.Registrant															r on rl.RegistrantSID					 = r.RegistrantSID
						join
							sf.Person																		p on r.PersonSID							 = p.PersonSID
						join
						(
							select
								rrs.RegistrantRenewalSID
							 ,min(rrs.CreateTime) CreateTime
							from
								dbo.RegistrantRenewalStatus rrs
							join
								sf.FormStatus								fs on rrs.FormStatusSID = fs.FormStatusSID and fs.FormStatusSCD = 'SUBMITTED'
							group by
								rrs.RegistrantRenewalSID
						)																							rrs on rr.RegistrantRenewalSID = rrs.RegistrantRenewalSID
						where
							rl.PracticeRegisterSID = @PracticeRegisterSID
					)													rr
					left outer join
						dbo.vCompletionTimeBand tb on rr.FormCompletionMinutes between tb.StartDuration and tb.EndDuration
					left outer join
						dbo.vAgeRange						ar on rr.RegistrantAge between ar.StartAge and ar.EndAge and ar.AgeRangeTypeCode = 'S!CLIENTAGE'
				) z
			 group by
				 z.DisplayOrder
				,z.AgeRangeLabel
				,z.TimeBand
				,z.TimeBandDisplayOrder;

GO
