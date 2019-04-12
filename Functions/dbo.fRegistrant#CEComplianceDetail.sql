SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrant#CEComplianceDetail
(
	@RegistrantSID		int -- key of registrant to return learning plan details for or -1 for all registrants
 ,@RegistrationYear int -- registration year to use as criteria  - MANDATORY must be passed
)
returns table
/*********************************************************************************************************************************
Function: Registrant - Continuing Education Compliance Detail
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns activity totals and compliance for each registrant learning plan requirement
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This function provides totals of credits completed and granted for Learning Requirements associated with a particular registration
and learning plan.  The function determines the totals based on a given year's Registrant Learning plans. 

One record is returned for each Registrant and Requirement regardless of whether a learning plan or any activity has been reported.
The function returns records for a single registrant passed in, or for all registrants when -1 is passed for the @RegistrantSID.  
The @RegistrationYear parameter is mandatory.  To call it for the current year pass: dbo.fRegistrationYear#Current().

If a registrant has reported more than the maximum number of credits allowed for a given requirement, then only the maximum is 
included in the "granted" column returned. The function also returns at bit = 1 if the "minimum" number of credits stipulated in the 
requirement has been achieved.  The Registrant may need to satisfy multiple requirements to be compliant with the overall learning 
objective established for the register so multiple records returned need to be evaluated.  The #CECompliance function performs this 
evaluation based on results returned from this function.

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
	dbo.fRegistrant#CEComplianceDetail(-1, @currentYear) x
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
		dbo.fRegistrant#CEComplianceDetail(@registrantSID, @currentYear) x
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
	 @ObjectName = 'dbo.fRegistrant#CEComplianceDetail'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		z.RegistrantSID
	 ,z.RegistrantLabel
	 ,z.RegistrationLabel
	 ,z.PracticeRegisterLabel
	 ,z.LearningRequirementLabel
	 ,cast(isnull(z.TotalCompetenceTypes, 0) as bit) IsRestrictedToCompetenceTypes
	 ,isnull(z.TotalUnitsComplete, 0.00)						 TotalUnitsComplete
	 ,isnull(z.TotalUnitsInComplete, 0.00)					 TotalUnitsInComplete
	 ,z.Minimum
	 ,z.Maximum
	 ,z.MaximumCarryOver
	 ,isnull(z.TotalUnitsGranted, 0.00)							 TotalUnitsGranted
	 ,isnull(z.IsRequirementMet, cast(0 as bit))		 IsRequirementMet
	 ,isnull( (case
							 when (z.TotalUnitsComplete - z.Maximum) > z.MaximumCarryOver then z.MaximumCarryOver
							 when (z.TotalUnitsComplete - z.Maximum) <= 0.00 then 0.00
							 else (z.TotalUnitsComplete - z.Maximum)
						 end
						)
					 ,0.00
					)																				 TotalUnitsCarriedOver
	 ,z.PracticeRegisterSID
	 ,z.LearningRequirementSID
	from
	(
		select
			reg.RegistrantSID
		 ,reg.RegistrantLabel
		 ,reg.RegistrationLabel
		 ,reg.PracticeRegisterLabel
		 ,lr.LearningRequirementLabel
		 ,lrct.TotalCompetenceTypes
		 ,(case when isnull(lrct.TotalCompetenceTypes, 0) = 0 then y.TotalUnitsComplete else x.TotalUnitsComplete end)		 TotalUnitsComplete
		 ,(case when isnull(lrct.TotalCompetenceTypes, 0) = 0 then y.TotalUnitsIncomplete else x.TotalUnitsInComplete end) TotalUnitsInComplete
		 ,(case when isnull(lrct.TotalCompetenceTypes, 0) = 0 then y.TotalUnitsGranted else x.TotalUnitsGranted end)			 TotalUnitsGranted
		 ,(case
				 when isnull(lrct.TotalCompetenceTypes, 0) = 0 then (case when y.TotalUnitsGranted > lr.Minimum then cast(1 as bit)else cast(0 as bit)end)
				 else x.IsRequirementMet
			 end
			)																																																								 IsRequirementMet
		 ,lr.Minimum
		 ,lr.Maximum
		 ,lr.MaximumCarryOver
		 ,reg.PracticeRegisterSID
		 ,lr.LearningRequirementSID
		from
			dbo.fRegistrant#LatestRegistration(@RegistrantSID, @RegistrationYear) reg
		join
			dbo.LearningRequirement																								lr on reg.PracticeRegisterSID			= lr.PracticeRegisterSID
		left outer join
		(
			select
				lrct.LearningRequirementSID
			 ,count(1) TotalCompetenceTypes
			from
				dbo.LearningRequirementCompetenceType lrct
			group by
				lrct.LearningRequirementSID
		)																																				lrct on lr.LearningRequirementSID = lrct.LearningRequirementSID
		left outer join
		(
			select
				ceR.RegistrantSID
			 ,ceR.LearningRequirementSID
			 ,ceR.TotalUnitsComplete
			 ,ceR.TotalUnitsInComplete
			 ,ceR.TotalUnitsGranted
			 ,ceR.TotalUnitsCarriedOver
			 ,ceR.IsRequirementMet
			from
				dbo.fRegistrant#CEUnitsByCompetenceRequirement(@RegistrantSID, @RegistrationYear) ceR
		)																																				x on reg.RegistrantSID						= x.RegistrantSID and lr.LearningRequirementSID = x.LearningRequirementSID
		left outer join
		(
			select
				ceO.RegistrantSID
			 ,sum(ceO.TotalUnitsComplete)		TotalUnitsComplete
			 ,sum(ceO.TotalUnitsInComplete) TotalUnitsIncomplete
			 ,sum(ceO.TotalUnitsGranted)		TotalUnitsGranted
			from
				dbo.fRegistrant#CEUnitsByCompetenceRequirement(@RegistrantSID, @RegistrationYear) ceO
			group by
				ceO.RegistrantSID
		)																																				y on reg.RegistrantSID						= y.RegistrantSID
		where
			reg.IsLearningPlanEnabled = cast(1 as bit)	-- only include Registers where learning plans are enabled
	) z
);



--declare
--	@RegistrantSID		int			 = 1002014
-- ,@RegistrationYear smallint = 2018;
GO
