SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fJob#NextRunDate]
(
	 @NextRunDate					date
	,@EndDate							date
	,@IsRunSunday					bit
	,@IsRunMonday					bit
	,@isRunTuesday				bit
	,@IsRunWednesday			bit
	,@isRunThursday				bit
	,@IsRunFriday					bit
	,@IsRunSaturday				bit
) returns date
as
/*********************************************************************************************************************************
ScalarF	: Job Next Run Date
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Determines the next date (part) on the schedule that the job can run based on schedule parameters
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Jul		2013	|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used in calculating the next scheduled time for a job.  The function requires the on/off (bit) values for each
day-of-week from the scheduled be passed in along with a starting point for the next run date.  The starting point for the next
run date should be set to the later of when the job last ran, or the start date defined on the schedule.

The function checks to ensure the day-of-week of the @NextRunDate parameter is set to a day enabled in the schedule. If the day
is not enabled, the procedure increments the date by one day and checks again.

The function also requires the @EndDate value to determine if the scheduled date is moving out past the supported the end of 
the schedule (as defined by @EndDate).  For example, if the scheduled ends on June 30th but no enabled day of week if found until
July 1st, then the function returns NULL - indicating to the caller no scheduled date is available.

Example
-------

select top (1)
	 j.JobSID
	,j.JobLabel
	,jx.*
from 
	sf.Job j
outer apply
	sf.fJob#Ext(j.JobSID) jx

------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
		 @ON										bit									= cast(1 as bit)
		,@OFF										bit									= cast(0 as bit)
		,@dow										nvarchar(3)

	-- if no days-of-week are enabled - return NULL (invalid parameters)

	if		@IsRunSunday			= @OFF
		and @IsRunMonday			= @OFF
		and @isRunTuesday			= @OFF
		and @IsRunWednesday		= @OFF
		and @isRunThursday		= @OFF
		and @IsRunFriday			= @OFF
		and @IsRunSaturday		= @OFF
	begin
		set @NextRunDate = null
	end
	else
	begin

		-- check if DOW is enabled in schedule; if not, increment to next day

		set @dow = left(datename(dw, @NextRunDate), 3)

		while @NextRunDate is not null
			and
			(			(@dow = 'Sun' and @IsRunSunday			= @OFF)
				or	(@dow = 'Mon' and @IsRunMonday			= @OFF)
				or	(@dow = 'Tue' and @isRunTuesday			= @OFF)
				or	(@dow = 'Wed' and @IsRunWednesday		= @OFF)
				or	(@dow = 'Thu' and @isRunThursday		= @OFF)
				or	(@dow = 'Fri' and @IsRunFriday			= @OFF)
				or	(@dow = 'Sat' and @IsRunSaturday		= @OFF)
			)
		begin
			set @NextRunDate	= dateadd(day, 1, @NextRunDate)
			set @dow					= left(datename(dw, @NextRunDate), 3)

			-- if the new date is beyond the scheduled time, set the 
			-- date to NULL to terminate the loop (function returns NULL)

			if @NextRunDate > @EndDate set @NextRunDate = null
		end

	end

	return(@NextRunDate)

end
GO
