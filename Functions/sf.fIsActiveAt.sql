SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION sf.fIsActiveAt
(
	@Effective	datetime	-- first datetime in range to check 
 ,@Expiry			datetime	-- last datetime in range to check
 ,@AtDateTime datetime	-- date and time to use for comparison
)
returns bit
as
/*********************************************************************************************************************************
ScalarF	: Is Active At 
Notice	: Copyright © 2017 Softworks Group Inc.
Summary	: Returns a bit indicating if the time passed is between the given effective and expiry dates provided
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  					| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund					| Jan 2018		|	Initial version
 				: Tim Edlund          | Mar 2019		|	Updated logic to check @Expiry time only when @Effective time is passed in as null

Comments	
--------
This function is used to determine if records with term date-times (typically "Effective" and "Expiry" ) are active at
the date-time provided. Be sure all 3 parameters provide date-times for the same time zone or results will be incorrect!

If either @Effective or @Expiry are passed as null, the check is still performed against the other value using the @AtDateTime in
the comparison.

This function provides alternative syntax to the sf.fIsActive function which automatically uses the current date-time in the user 
timezone for the comparison. This function provides much faster performance that sf.fIsActive where the same time must be used for
the comparison against larger record sets.  Passing sf.fNow() into this function ensures it is only calculated once for the full
record set, and thereby reduces processing time for the query.

If @Expiry is NULL and the current time is on or after @Effective then 1 is returned.

if @Effective is null, then 0 (false) is returned

MAINTENANCE NOTE: the comparison logic used here is the same as in sf.fIsActive.  Any changes to that logic must also be 
made in the other function.

Example/Test Harness
--------------------
<TestHarness>
  <Test Name = "Grants" IsDefault ="true" Description="Selects the function to determine whether a series of grants are active or not.">
    <SQLScript>
      <![CDATA[
declare
	@now datetime = sf.fNow()

select
		@now																														CurrentTime
	,aug.EffectiveTime
	,aug.ExpiryTime
	,sf.fIsActiveAt(aug.EffectiveTime, aug.ExpiryTime, @now) IsActiveAt
from
	sf.ApplicationUserGrant aug
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fIsActiveAt'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare @isActive bit = cast(0 as bit); -- return value

	if @AtDateTime is null set @AtDateTime = sf.fNow(); -- default to current datetime in user time zone if not passed

	if @AtDateTime >= isnull(@Effective, @AtDateTime) and isnull(@Expiry, @AtDateTime) >= @AtDateTime
	begin
		set @isActive = cast(1 as bit);
	end;

	return (@isActive);

end;
GO
