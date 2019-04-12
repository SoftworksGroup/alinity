SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistration#GapCheck (@RegistrationSID int)
returns table
as
/*********************************************************************************************************************************
Function : Registration - Gap Check
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns single row of data analyzing interval in hours between from previous and next registrations on the time-line
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version

Comments	
--------
This function is used primarily validate new registrations. It may also be applied in reporting scenarios. Alinity requires that, 
for new (non-converted) registrations, a continuous time-line of registration status be maintained for each member. The time-line
is established through the EffectiveTime and ExpiryTime values recorded on each Registration record.  This function takes a 
specific registration key to select and uses the lag and lead functions to examine the gap (in hours) between it and the
previous and next registrations.  A gap is considered to have occurred when more than a 1 hour difference is detected. (The 
normal difference is exactly 1 hour due to the rounding-up nature of the datediff function used).  If the registration key 
passed is the first or last registration in the time-line of registrations then null values are returned where no previous/next
record exists (a single row is always returned).

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Selects gap analysis for a registration at random.">
    <SQLScript>
      <![CDATA[
declare @registrationSID int;

select top (1)
	@registrationSID = rl.RegistrationSID
from
	dbo.Registration rl
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select * from		dbo.fRegistration#GapCheck(@registrationSID);
end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistration#GapCheck'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
return
(
	select
		z.PreviousExpiryTime
	 ,z.EffectiveTime
	 ,z.PreviousGapInHours
	 ,z.ExpiryTime
	 ,z.NextEffectiveTime
	 ,z.NextGapInHours
	 ,(case when z.PreviousGapInHours > 1 then 1 else 0 end) IsGapToPreviousRegistration
	 ,(case when z.NextGapInHours > 1 then 1 else 0 end)		 IsGapToNextRegistration
	from	(
					select
						x.PreviousExpiryTime
					 ,x.EffectiveTime
					 ,x.ExpiryTime
					 ,x.NextEffectiveTime
					 ,datediff(hour, x.PreviousExpiryTime, x.EffectiveTime) PreviousGapInHours
					 ,datediff(hour, x.ExpiryTime, x.NextEffectiveTime)			NextGapInHours
					from	(
									select
										lag(rl.ExpiryTime) over (partition by rl.RegistrantSID order by rl.EffectiveTime)			PreviousExpiryTime
									 ,rl.EffectiveTime
									 ,rl.ExpiryTime
									 ,lead(rl.EffectiveTime) over (partition by rl.RegistrantSID order by rl.EffectiveTime) NextEffectiveTime
									from
										dbo.Registration rl
									where
										rl.RegistrationSID = @RegistrationSID
								) x
				) z
);
GO
