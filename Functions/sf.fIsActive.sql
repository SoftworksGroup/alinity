SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION sf.fIsActive
(
	@Effective datetime -- first datetime in range to check 
 ,@Expiry		 datetime -- last datetime in range to check
)
returns bit
as
/*********************************************************************************************************************************
ScalarF	: Is Active Now 
Notice	: Copyright © 2014 Softworks Group Inc.
Summary	: Returns a bit indicating if the current date time (adjusted for client timezone) is within the date range provided
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund					| Jul 2012		|	Initial version
				: Tim Edlund					| Dec 2012		| Updated to accept datetime rather than date
 				: Tim Edlund          | Mar 2019		|	Updated logic to check @Expiry time only when @Effective time is passed in as null

Comments
--------
This function is used to determine if records with term date-times (typically "Effective" and "Expiry" ) are active at
the current time. If either @Effective or @Expiry are passed as null, the check is still performed against the other value
using the current time in the comparison.

This function "sf.fIsActiveAt" provides alternative syntax to the sf.fIsActive function and allows the date to use for comparison
to be passed once, rather than calculating the current date-time on each call. This function provides much faster performance 
than on larger record sets where the comparison time is constant across all records.

If @Expiry is NULL and the current time is on or after @Effective then 1 is returned.

if @Effective is null, then 0 (false) is returned

MAINTENANCE NOTE: the comparison logic used here is the same as in sf.fIsActiveAt.  Any changes to that logic must also be 
made in the other function.

Example
-------

	select
		 sf.fNow()																														CurrentClientTime
		,aug.EffectiveTime
		,aug.ExpiryTime
		,sf.fIsActive(aug.EffectiveTime, aug.ExpiryTime) IsActive
	from
		sf.ApplicationUserGrant aug
	where
		aug.ApplicationUserGrantSID = 1000001

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@isActive bit			 = cast(0 as bit) -- return value
	 ,@now			datetime = sf.fNow();			-- current time adjusted for user timezone

	if @now >= isnull(@Effective,@now) and isnull(@Expiry, @now) >= @now
	begin
		set @isActive = cast(1 as bit);
	end

	return (@isActive);

end;
GO
