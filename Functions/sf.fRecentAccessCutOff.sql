SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fRecentAccessCutOff]
(
)
returns datetimeoffset
as
/*********************************************************************************************************************************
ScalarF		: Recent Access Cut-off
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns the "oldest" datetime (offset) still considered recent according to the "RecentAccessHours" parameter
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Nov 2012		|	Initial version
					: Tim Edlund	| Mar 2015		| Updated to include adjustments for weekends.

Comments	
--------
This function is used to simplify syntax required to select records that are within or outside of the "Recent Access" period.
This period is defined through a configuration parameter (stored in sf.ConfigParam) called "RecentAccessHours". If the parameter
is not defined then 24 hours is the default.  A second configuration parameter "ExcludeWeekendsForRecent" instructs the
function to move the date calculated for recently access back where the interval includes weekend dates.  Note that this is only
done where the threshold is less than 120 hours (5 days) as otherwise the adjustment would not always involve another weekend.

Example
-------

select
	 au.UserName
	,au.CreateTime
from
	sf.ApplicationUser au
where
	au.UpdateTime >= sf.fRecentAccessCutOff()																-- for recently accessed rows use >= return value

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @ON															bit							= cast(1 as bit)		-- constant to repeated prevent type conversions
		,@OFF															bit							= cast(0 as bit)		-- constant to repeated prevent type conversions
		,@recentAccessCutOff							datetimeoffset											-- oldest time to qualify for recently accessed
		,@recentAccessHours								smallint		                        -- configuration value for recently accessed 
		,@excludeWeekends									bit																	-- whether Sat/Sun excluded for calculation of "recently accessed"
		,@weekendDays											int																	-- count of number of weekend days between now and threshold
		,@now															datetimeoffset											-- current time at server

	set @recentAccessHours		= isnull(convert(smallint, sf.fConfigParam#Value('RecentAccessHours')), 24)  
	set @now									= sysdatetimeoffset()
	set @excludeWeekends			= cast(isnull(sf.fConfigParam#Value('ExcludeWeekendsForRecent'), '1')		as bit)							
	set @recentAccessCutOff		= dateadd(hour, (-1 * @recentAccessHours), @now) 

	if @excludeWeekends = @ON	and @recentAccessHours < 120
	begin

		set @weekendDays	 = 
				(datediff(day, -2, @now)/7	-datediff(day, -1, @recentAccessCutOff)/7)											-- count Saturdays between dates
			+ (datediff(day, -1, @now)/7	-datediff(day,  0, @recentAccessCutoff)/7)											-- count Sundays

		if @weekendDays > 0 set @recentAccessCutOff = dateadd(hour, (@weekendDays * -24), @recentAccessCutOff)	-- adjust for weekends

		if datename(dw,@recentAccessCutOff) = N'Saturday'																								-- if ends as Saturday, remove one more day
		begin
			set @recentAccessCutOff = dateadd(hour, (@weekendDays * -24), @recentAccessCutOff)
		end

	end

	return(@recentAccessCutoff)

end
GO
