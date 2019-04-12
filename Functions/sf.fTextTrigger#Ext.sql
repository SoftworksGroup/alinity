SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fTextTrigger#Ext]
(
	@TextTriggerSID									int
)
returns @textTrigger#Ext	table
(
	 LastDurationMinutes							int								null								-- runtime in minutes for last execution of the trigger
	,IsRunning												bit								not null						-- indicates if trigger is currently running
	,LastStartTimeClientTZ						datetime					null								-- time the trigger last started (client TZ)
	,LastEndTimeClientTZ							datetime					null								-- time the trigger last ended (client TZ)	
	,NextScheduledTime								datetime					null								-- time trigger is scheduled to run next in client TZ
	,NextScheduledTimeServerTZ				datetimeoffset(7)	null								-- time trigger is scheduled to run next in server timezone
)
as
/*********************************************************************************************************************************
TableF	: Text Trigger - Extended Columns
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns a table of calculated columns for the Text Trigger extended view (vTextTrigger#Ext)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | Jun	2016			|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is called by the dbo.vTextTrigger#Ext view to return a series of calculated columns.  This function is not intended 
for other purposes and has been designed to emphasize performance over flexibility for other uses.  By using a table function,
many lookups required for the calculated values can be executed once rather than many times if separate functions are used.

Calculations which also provide data back to the #Ext view, but which use completely independent values are NOT included in this
function.

Next Scheduled Time
-------------------
The next scheduled time is returned for triggers where a scheduled is assigned.  There are 2 principle types of trigger schedules:
a) Daily - run once per day or 
b) Hourly - run multiple times per day at given intervals - e.g. every hour or 15 minutes.  The resulting value is returned both 
in the user TZ (as a datetime) and at the server time as a date time offset data type.  

Because text triggers can only be executed by the text trigger job, the time calculated to next run the trigger is compared with 
the time when the text trigger job will next run.  If the trigger is scheduled to run BEFORE the next time the text-trigger-job
will run, the text-trigger-job's scheduled time is used instead.

Details of the algorithm used are also documented in-line in the code below.

Example
-------

select top (1)
	 tt.TextTriggerSID
	,tt.JobLabel
	,jx.*
from 
	sf.TextTrigger j
outer apply
	sf.fJob#Ext(tt.TextTriggerSID) jx

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @ON                              bit = cast(1 as bit)								-- a constant to reduce repetitive cast syntax in bit comparisons
		,@OFF                             bit = cast(0 as bit)								-- a constant to reduce repetitive cast syntax in bit comparisons
		,@lastDurationMinutes							int																	-- runtime in minutes for last execution of the trigger
		,@isRunning												bit																	-- indicates if trigger is currently running
		,@isScheduled											bit																	-- tracks whether trigger has an enabled schedule assigned
		,@lastStartTime										datetime														-- when the trigger last started running in client TZ		
		,@lastEndTime											datetime														-- when the trigger last ended running	
		,@nextScheduledTime								datetime														-- date and time trigger is scheduled to run next - in client TZ
		,@nextRunDate											date																-- date portion of next scheduled time			
		,@nextRunTime											time(0)															-- time portion of next scheduled time
		,@repeatIntervalMinutes						int																	-- scheduled configuration values:
		,@isRunSunday											bit
		,@isRunMonday											bit
		,@isRunTuesday										bit
		,@isRunWednesday									bit
		,@isRunThursday										bit
		,@isRunFriday											bit
		,@isRunSaturday										bit
		,@startDate												date																-- 4 values define an operating window for trigger to run within:
		,@endDate													date																-- triggers running more than once per day repeat within the window
		,@startTime												time(0)
		,@endTime													time(0)
		,@nextJobRunTime									datetime														-- the date and time when schedule will be checked next

	-- retrieve trigger schedule configuration and runtime information

	select																																	-- read control values from the trigger and schedule
		 @repeatIntervalMinutes = js.RepeatIntervalMinutes
		,@isRunSunday						= js.IsRunSunday
		,@isRunMonday						= js.IsRunMonday		
		,@isRunTuesday					= js.IsRunTuesday	
		,@isRunWednesday				= js.IsRunWednesday
		,@isRunThursday					= js.IsRunThursday	
		,@isRunFriday						= js.IsRunFriday		
		,@isRunSaturday					= js.IsRunSaturday	
		,@startDate							= js.StartDate																-- dates and times in the schedule are entered	
		,@endDate								= js.EndDate																	-- in the user's timezone!
		,@startTime							= js.StartTime																																										
		,@endTime								= js.EndTime
		,@isScheduled						= js.IsEnabled
		,@lastStartTime					= sf.fDTOffsetToClientDateTime(tt.LastStartTime)
		,@lastEndTime						= sf.fDTOffsetToClientDateTime(tt.LastEndTime)
		,@lastDurationMinutes = 
			(
				case
					when tt.LastStartTime is not null and tt.LastEndTime is not null	then datediff(minute,tt.LastStartTime, tt.LastEndTime)	
					else null
				end
			)
		,@isRunning = 
			(
				case
					when tt.LastStartTime is not null and tt.LastEndTime is null	then @ON
					else @OFF
				end
			)
	from
		sf.TextTrigger tt
	join
		sf.JobSchedule	js on tt.JobScheduleSID = js.JobScheduleSID
	where
		tt.TextTriggerSID = @TextTriggerSID
	and
		js.IsEnabled = @ON																										-- if schedule is not active, trigger is not scheduled!

	if @isScheduled is null set @isScheduled = @OFF

	-- calculate the next scheduled time for the trigger (if scheduled)

	if @isScheduled = @ON
	begin

		-- initiate the next run date to the date the trigger was last run; if never run, 
		-- or it was run before the schedule start, use the schedule start date

		if @lastStartTime is null or cast(@lastStartTime as date) < @startDate
		begin
			set @nextRunDate = @startDate
		end
		else
		begin
			set @nextRunDate = cast(@lastStartTime as date)
		end

		-- if the trigger was started manually, it may have occurred on a day-of-week not
		-- enabled in the schedule so increment it until a supported day is hit

		set @nextRunDate = sf.fJob#NextRunDate
			(  
				 @nextRunDate
				,@endDate
				,@isRunSunday		
				,@isRunMonday		
				,@isRunTuesday	
				,@isRunWednesday
				,@isRunThursday	
				,@isRunFriday		
				,@isRunSaturday	
			)

		-- the function called above sets the return date to null if incrementing the date
		-- to a supported day of week goes beyond the End Date defined for the schedule

		if @nextRunDate is not null																																																	
		begin

			-- add the start time prescribed in the schedule to the next run date

			set @nextScheduledTime	= sf.fDatePlusTimeToDT(@nextRunDate, @startTime)

			-- if this time is before the trigger last ran, increment the time value by
			-- the "repeat interval; for jobs that run daily the increment is 1440 minutes

			if isnull(@repeatIntervalMinutes,0) = 0 set @repeatIntervalMinutes = 1440

			while @nextRunDate is not null and @nextScheduledTime <= @lastStartTime
			begin

				set @nextScheduledTime = dateadd(minute, @repeatIntervalMinutes, @nextScheduledTime)

				-- if the new time is outside the processing window (end time) defined in the schedule, then 
				-- reset to the next day at the original start time and continue 

				if cast(@nextScheduledTime as time(0)) > @endTime
				begin
					set @nextRunDate = dateadd(day, 1, @nextRunDate)

					set @nextRunDate = sf.fJob#NextRunDate
						(  
							 @nextRunDate
							,@endDate
							,@isRunSunday		
							,@isRunMonday		
							,@isRunTuesday	
							,@isRunWednesday
							,@isRunThursday	
							,@isRunFriday		
							,@isRunSaturday	
						)

					set @nextScheduledTime	= sf.fDatePlusTimeToDT(@nextRunDate, @startTime)
				end

			end

			if @nextRunDate is null set @nextScheduledTime = null

		end

		-- get the time the trigger job will run next - as long as the 
		-- job is not currently running

		select 
			 @nextJobRunTime = jx.NextScheduledTime
		from 
			sf.Job j 
		cross apply
			sf.fJob#Ext(j.JobSID) jx
		where
			j.JobSCD = 'sf.pTextTrigger#Execute'																-- Indicates this job is used to execute scheduled text triggers		 
		and
			(jx.LastEndTime is not null or jx.LastStartTime is null)

		-- if the scheduled time is earlier than when the trigger job 
		-- will be run next, replace with the time with the next job time

		if @nextJobRunTime is not null and datediff(minute, @nextScheduledTime, @nextJobRunTime) > 1
		begin
			set @nextScheduledTime = @nextJobRunTime
		end

	end

	-- update the return table with values calculated

	insert 
		@textTrigger#Ext
	 (
		 LastDurationMinutes
		,IsRunning
		,LastStartTimeClientTZ
		,LastEndTimeClientTZ
		,NextScheduledTime				
		,NextScheduledTimeServerTZ
	)
	select
		 @lastDurationMinutes
		,isnull(@isRunning, @OFF)
		,@lastStartTime
		,@lastEndTime
		,@nextScheduledTime				
		,sf.fClientDateTimeToDTOffset(@nextScheduledTime)

	return

end
GO
