SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantLearningPlan#RequirementsStatus
(
	@RegistrantLearningPlanSID int	-- key of registrant learning plan to assess requirements for
)
returns table
/*********************************************************************************************************************************
Function	: Registrant Learning Plan - Requirements Status
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a table summarizing compliance with learning requirements for a registrants learning plan 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version 
				: Tim Edlund					| Oct 2018		| Added columns to calculate available carry over

Comments	
--------
This function is used in the user interface and reporting to indicate whether the member is in compliance with the requirements
for the learning plan.  One or more requirement types can be established that members must meet each cycle (typically a year)
for their learning plans. This function totals the units of learning completed and planned as categorized for each requirement
and indicates whether the requirement has been met.

If the learning plan is for the next registration year, then no registration record may exist yet for that year. This occurs
because the configuration may allow entry into the next year's Learning Plan during the renewal form completion.  The registration
record for that new year will not yet be generated.  In that scenario the function uses the start of the next registration year
to determine what the minimum requirements will be.  Otherwise, it uses the date their latest registration became effective.
This date is important where pro-rating of requirements is in effect.

Limitation
----------
As of the current version, supporting pro-rating on multi-year learning cycles is NOT supported.  An extension to the model will
be required to enable the configuration to indicate in which year of the cycle the month-day specified for the requirement is
to take effect.

Example
-------
<TestHarness>
	<Test Name="Random" Description="Calls function for record selected at random">
		<SQLScript>
			<![CDATA[


declare @registrantLearningPlanSID int;

select top (1)
	@registrantLearningPlanSID = rlp.RegistrantLearningPlanSID
from
	dbo.RegistrantLearningPlan rlp
order by
	newid();

if @@rowcount = 0 or @registrantLearningPlanSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		x.*
	from
		dbo.RegistrantLearningPlan																															rlp
	cross apply dbo.fRegistrantLearningPlan#RequirementsStatus(rlp.RegistrantLearningPlanSID) x
	where
		rlp.RegistrantLearningPlanSID = @registrantLearningPlanSID;

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'fRegistrantLearningPlan#RequirementsStatus'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		x.LearningRequirementSID
	 ,lr.LearningRequirementLabel
	 ,req.RequiredUnits
	 ,x.TotalPlannedUnits
	 ,x.TotalCompletedUnits
	 ,(case when x.TotalCompletedUnits > req.RequiredUnits then 1 else 0 end) IsRequirementMet
	 ,cast(case
					 when x.TotalCompletedUnits > req.RequiredUnits then 100.00
					 when x.TotalCompletedUnits = 0 or isnull(req.RequiredUnits, 0) = 0 then 0.00
					 else (x.TotalCompletedUnits * 1.000) / (req.RequiredUnits * 1.000)
				 end as decimal(6, 2))																							PercentageMet
	 ,cast(case
					 when x.TotalCompletedUnits <= req.RequiredUnits then 0.0
					 when x.TotalCompletedUnits - req.RequiredUnits > lr.MaximumCarryOver then lr.MaximumCarryOver
					 else x.TotalCompletedUnits - req.RequiredUnits
				 end as decimal(5, 2))																							AvailableCarryOverUnits
	 ,lr.MaximumCarryOver
	 ,lr.RowGUID
	from
		dbo.LearningRequirement																																			lr
	left join
	(
		select
			lr.LearningRequirementSID
		 ,sum(case when lct.IsValidForRenewal = cast(0 as bit) then lpa.UnitValue else 0 end) TotalPlannedUnits
		 ,sum(case when lct.IsValidForRenewal = cast(1 as bit) then lpa.UnitValue else 0 end) TotalCompletedUnits
		from
			dbo.LearningRequirement								lr
		join
			dbo.LearningRequirementCompetenceType lrct on lr.LearningRequirementSID				 = lrct.LearningRequirementSID
		join
			dbo.CompetenceTypeActivity						cta on lrct.CompetenceTypeSID						 = cta.CompetenceTypeSID
		left outer join
			dbo.LearningPlanActivity							lpa on cta.CompetenceTypeActivitySID		 = lpa.CompetenceTypeActivitySID
																									 and lpa.RegistrantLearningPlanSID = @RegistrantLearningPlanSID
		left outer join
			dbo.LearningClaimType									lct on lpa.LearningClaimTypeSID					 = lct.LearningClaimTypeSID and lct.IsWithdrawn = cast(0 as bit)
		group by
			lr.LearningRequirementSID
	)																																															x on lr.LearningRequirementSID = x.LearningRequirementSID
	join
		dbo.RegistrantLearningPlan																																	rlp on rlp.RegistrantLearningPlanSID = @RegistrantLearningPlanSID
	outer apply dbo.[fRegistrant#LatestRegistration$SID](rlp.RegistrantSID, rlp.RegistrationYear) z
	left outer join
		dbo.Registration																																																					 reg on z.RegistrationSID = reg.RegistrationSID
	left outer join
		dbo.RegistrationScheduleYear																																															 rsy on rsy.RegistrationYear = rlp.RegistrationYear -- get start of next year in case learning plan is for next year (latest reg is current year)
	outer apply dbo.fLearningRequirement#CurrentMinimum(lr.LearningRequirementSID, isnull(reg.EffectiveTime, rsy.YearStartTime)) req
);
GO
