SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrant#CEUnitsByCompetenceRequirement
(
	@RegistrantSID		int -- key of registrant to return learning plan details for or -1 for all registrants
 ,@RegistrationYear int -- registration year to use as criteria  - MANDATORY must be passed
)
returns table
/*********************************************************************************************************************************
Function: Registrant - Continuing Education Units By Competence Requirement
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns activity totals and compliance for each registrant learning plan requirement restricted to a competence type
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This function provides totals of credits completed and granted for Learning Requirements which are restricted to one or more
competence types. The function determines the totals based on a given year's Registrant Learning plans. 

One record is returned for each Requirement for which activity is reported on Registrant's learning plan.  The function
returns records for a single registrant passed in, or for all registrants when -1 is passed for the @RegistrantSID.  The 
@RegistrationYear parameter is mandatory.  To call it for the current year pass: dbo.fRegistrationYear#Current().

Note that some Learning Requirements are not restricted to activities within a certain Competence Type. In this scenario
activities in any Competence type are accepted for meeting that the requirement. This function only returns records for 
requirements which are restricted to a competence type.  Use the function dbo.fRegistrant#CEComplianceDetail to see
totals and a compliance indicator for all requirements associated with the registration and learning plan. (That 
function calls this function to derive its totals).

If a registrant has reported more than the maximum number of credits allowed for a given requirement, then only the 
maximum is included in the "granted" column returned. The function also returns at bit = 1 if the "minimum" number of
credits stipulated in the requirement has been achieved.  The Registrant may need to satisfy multiple requirements
to be compliant with the overall learning objective established for the register so multiple records returned need
to be evaluated.  The #CEComplianceDetail/Summary functions perform this evaluation based on results returned from this function.

Example
-------
<TestHarness>
  <Test Name = "All" IsDefault ="true" Description="Returns all records for the current registration year">
    <SQLScript>
      <![CDATA[
declare @currentYear smallint = dbo.fRegistrationYear#Current();

select
	x.*
from
	dbo.fRegistrant#CEUnitsByCompetenceRequirement(-1, @currentYear) x
order by
	x.RegistrantSID
	,x.LearningRequirementSID

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
  <Test Name = "Random" Description="Returns 1 record for registrant selected at random for current registration year">
    <SQLScript>
      <![CDATA[
declare
	@registrantSID int
 ,@currentYear	 smallint = dbo.fRegistrationYear#Current();

select top (1)
	@registrantSID = reg.RegistrantSID
from
	dbo.fRegistrant#LatestRegistration(-1, @currentYear) reg
join
	dbo.RegistrantLearningPlan													 rlp on rlp.RegistrantSID							= reg.RegistrantSID
join
	dbo.LearningModel																		 lm on rlp.LearningModelSID						= lm.LearningModelSID
join
	dbo.LearningPlanActivity														 lpa on rlp.RegistrantLearningPlanSID = lpa.RegistrantLearningPlanSID
where
	reg.IsLearningPlanEnabled = 1 and rlp.RegistrationYear = (@currentYear - lm.CycleLengthYears + 1)
order by
	newid();

if @@rowcount = 0 or @registrantSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		x.*
	from
		dbo.fRegistrant#CEUnitsByCompetenceRequirement(@registrantSID, @currentYear) x
	order by
		x.RegistrantSID
	 ,x.LearningRequirementSID;

	print @registrantSID;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value = "1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrant#CEUnitsByCompetenceRequirement'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		x.RegistrantSID
	 ,x.RegistrantLearningPlanSID
	 ,x.LearningRequirementSID
	 ,lr.LearningRequirementLabel
	 ,lr.Minimum
	 ,lr.Maximum
	 ,lr.MaximumCarryOver
	 ,x.TotalUnitsComplete
	 ,x.TotalUnitsInComplete
	 ,(case when x.TotalUnitsComplete > lr.Maximum then lr.Maximum else x.TotalUnitsComplete end) TotalUnitsGranted
	 ,(case
			 when (x.TotalUnitsComplete - lr.Maximum) > lr.MaximumCarryOver then lr.MaximumCarryOver
			 when (x.TotalUnitsComplete - lr.Maximum) <= 0.00 then 0.00
			 else (x.TotalUnitsComplete - lr.Maximum)
		 end
		)																																														TotalUnitsCarriedOver
	 ,cast(case when x.TotalUnitsComplete >= lr.Minimum then 1 else 0 end as bit)									IsRequirementMet
	from
	(
		select
			rlp.RegistrantSID
		 ,rlp.RegistrantLearningPlanSID
		 ,lrct.LearningRequirementSID
		 ,sum(case when lct.IsComplete = cast(1 as bit) then lpa.UnitValue else 0 end) TotalUnitsComplete
		 ,sum(case when lct.IsComplete = cast(0 as bit) then lpa.UnitValue else 0 end) TotalUnitsInComplete
		from
			dbo.RegistrantLearningPlan						rlp
		join
			dbo.LearningPlanActivity							lpa on rlp.RegistrantLearningPlanSID = lpa.RegistrantLearningPlanSID
		join
			dbo.LearningClaimType									lct on lpa.LearningClaimTypeSID			 = lct.LearningClaimTypeSID
		join
			dbo.CompetenceTypeActivity						cta on lpa.CompetenceTypeActivitySID = cta.CompetenceTypeActivitySID
		join
			dbo.LearningModel											lm on rlp.LearningModelSID					 = lm.LearningModelSID
		join
			dbo.LearningRequirementCompetenceType lrct on cta.CompetenceTypeSID				 = lrct.CompetenceTypeSID
		where
			(rlp.RegistrantSID = @RegistrantSID or @RegistrantSID = -1) and rlp.RegistrationYear = (@RegistrationYear - lm.CycleLengthYears + 1)
		group by
			rlp.RegistrantSID
		 ,rlp.RegistrantLearningPlanSID
		 ,lrct.LearningRequirementSID
	)													x
	join
		dbo.LearningRequirement lr on x.LearningRequirementSID = lr.LearningRequirementSID
);
GO
