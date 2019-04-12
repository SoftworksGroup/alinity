SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fLearningRequirement#CurrentMinimum
(
	@LearningRequirementSID int				-- item to return current requirement for
 ,@EffectiveTime					datetime	-- effective date of associated license (required for prorating)
)
returns table
/*********************************************************************************************************************************
Function	: Learning Requirement - Current Requirement
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the current requirement (units) in effect for the learning requirement and effective date specified
----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Jul 2018		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function determines the minimum unit requirements in effect for a specific learning requirement. Requirements are stored in 
the Learning Requirement table but may also included pro-rated versions of the requirement level which are stored in the Learning 
Requirement Proration table.  Proration is used where the total number of learning units (e.g. 12 hours) required for the year 
(cycle) is reduced for members who receive registration later in the year. For example, if 12 hours are required for a full year, 
then 9 hours may be required starting the 1st day of the 4th month.  Since pro-rating is optional, the function returns the full
requirement from the parent (dbo.LearningRequirement) table if no pro-rating records are entered.

The effective time passed in should be the date the license becomes effective.  For renewed members the license is effective on
the first day of the registration year. When an effective time is provided, the function checks whether a prorated requirement 
exists for the month and day contained in the date passed in. While a date-time data type is used for the parameter, proration 
is always based on the date and month in the registration year only (converted to a MMDD string).  Proration can be set as an 
explicit amount in the table or may be defined as a percentage of the full requirement.

Example
-------
<TestHarness>
	<Test Name="Random" Description="Calls function for record selected at random">
		<SQLScript>
			<![CDATA[

declare @learningRequirementSID int;

select top (1)
	@learningRequirementSID = lr.LearningRequirementSID
from
	dbo.LearningRequirement					 lr
order by
	newid();

if @@rowcount = 0 or @learningRequirementSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		x.LearningRequirementSID
		,x.LearningRequirementProrationSID
	 ,x.RequiredUnits
	 ,x.IsProrated
	 ,lr.LearningRequirementLabel
	 ,lr.StartingRegistrationYear
	 ,lr.Minimum MinimumForFullCycle
	from
		dbo.LearningRequirement lr
	cross apply
		dbo.fLearningRequirement#CurrentMinimum(lr.LearningRequirementSID, null) x
	left outer join
		dbo.LearningRequirementProration lrp on x.LearningRequirementProrationSID = lrp.LearningRequirementProrationSID
	where
		lr.LearningRequirementSID = @learningRequirementSID

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
  @ObjectName = 'dbo.fLearningRequirement#CurrentMinimum'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

as
return
(
	select
		lr.LearningRequirementSID
	 ,lrp.LearningRequirementProrationSID
	 ,(case
			 when lrp.LearningRequirementMinimum <> 0.0 then lrp.LearningRequirementMinimum
			 else cast(isnull((lrp.PercentageOfFullMinimum / 100.000), 1.00) * lr.Minimum as decimal(4, 1))
		 end
		)																								 RequiredUnits
	 ,cast(lrp.LearningRequirementProrationSID as bit) IsProrated
	from
		dbo.LearningRequirement					 lr
	left outer join
	(
		select
			lr.LearningRequirementSID
		 ,max(lrp.LearningRequirementProrationSID) LearningRequirementProrationSID
		from
			dbo.LearningRequirement					 lr
		join
			dbo.LearningRequirementProration lrp on lr.LearningRequirementSID = lrp.LearningRequirementSID
		left outer join
		(
			select
				month(rsy.YearStartTime) YearStartMonth
			from
				dbo.RegistrationScheduleYear rsy
			where
				rsy.RegistrationYear = dbo.fRegistrationYear(@EffectiveTime) -- get starting month of the fiscal year of the effective time (can be NULL)
		)																x on 1													= 1
		where
			lr.LearningRequirementSID = @LearningRequirementSID 
		and 
			dbo.fRegistrationYear#FiscalMonthDay(lrp.StartMonthDay, x.YearStartMonth) -- compare the specified start date for the price as a fiscal year "month day" value
										<= dbo.fRegistrationYear#FiscalMonthDay(right(convert(varchar(8), @EffectiveTime, 112), 4), x.YearStartMonth) -- to the effective time
		group by
			lr.LearningRequirementSID
	)																	 z on lr.LearningRequirementSID						= z.LearningRequirementSID
	left outer join
		dbo.LearningRequirementProration lrp on z.LearningRequirementProrationSID = lrp.LearningRequirementProrationSID
	where
		lr.LearningRequirementSID = @LearningRequirementSID
);
GO
