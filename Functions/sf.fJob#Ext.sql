SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fJob#Ext]
(
	@JobSID									int
)
returns @jobRun#Ext	table
(
	 LastJobStatusSCD									varchar(35)				null								-- status code of the last run for the job
	,LastJobStatusLabel								nvarchar(35)			null								-- status label for the last run of the job
	,LastStartTime										datetime					null								-- time the job last started (client TZ)
	,LastEndTime											datetime					null								-- time the job last ended (client TZ)	
	,NextScheduledTime								datetime					null								-- time job is scheduled to run next in client TZ
	,NextScheduledTimeServerTZ				datetimeoffset(7)	null								-- time job is scheduled to run next in server timezone
	,MinDuration											int								null								-- minimum duration for last 10 runs of job
	,MaxDuration											int								null								-- maximum duration for last 10 runs of job
	,AvgDuration											int								null								-- average duration for last 10 runs of job
  ,LastRunRecords                   int               null                -- number of records from last job run
  ,LastRunProcessed                 int               null                -- number of processed records from last job run
  ,LastRunErrors                    int               null                -- number of record errors from last job run
)
as
/*********************************************************************************************************************************
TableF	: Job - Extended Columns
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns a table of calculated columns for the Job extended view (vJob#Ext)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | Jul	2013			|	Initial Version
        : Russ Poirier| Feb 2017      | Added three new columns (LastRunRecords, LastRunProcessed, LastRunErrors)
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is called by the dbo.vJob#Ext view to return a series of calculated columns.  This function is not intended for 
other purposes and has been designed to emphasize performance over flexibility for other uses.  By using a table function,
many lookups required for the calculated values can be executed once rather than many times if separate functions are used.

Calculations which also provide data back to the #Ext view, but which use completely independent values are NOT included in this
function.

Next Scheduled Time
-------------------
The next scheduled time is returned for jobs where a scheduled is assigned.  There are 2 principle types of job schedules:
a) Daily - run once per day or b) Hourly - run multiple times per day at given intervals of 1 hour or more.  The resulting
value is returned both in the user TZ (as a datetime) and at the server time as a date time offset data type.  Details of the
algorithm used are documented in-line in the code below.

The next scheduled time is returned for jobs where a scheduled is assigned.  There are 2 principle types of job schedules:
a) Daily - run once per day or 
b) Hourly - run multiple times per day at given intervals - e.g. every hour or 15 minutes.  The resulting value is returned both 
in the user TZ (as a datetime) and at the server time as a date time offset data type.  

Because scheduled jobs can only be executed as frequently as the schedule is checked, the time calculated to next run the job 
is compared with the time when the job schedule will next run (from sys.conversation_endpoints). If the job is scheduled to run 
BEFORE the next time the schedule is checked, the next schedule check time is used instead.

Details of the algorithm used are also documented in-line in the code below.

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
		 @ON                              bit = cast(1 as bit)								-- a constant to reduce repetitive cast syntax in bit comparisons
		,@OFF                             bit = cast(0 as bit)								-- a constant to reduce repetitive cast syntax in bit comparisons
		,@CRLF														nchar(2) = char(13) + char(10)			-- constant for carriage return line feed pairs
		,@lastJobRunSID										int																	-- record of last run for the job - if any
		,@lastJobStatusSCD								varchar(35)													-- status code of the last run for the job
		,@lastJobStatusLabel							nvarchar(35)												-- status label for the last run of the job
		,@lastStartTime										datetime														-- when the job last started running in client TZ		
		,@lastEndTime											datetime														-- when the job last ended running	
		,@minDuration											int																	-- minimum duration for last 10 runs of job
		,@maxDuration											int																	-- maximum duration for last 10 runs of job
		,@avgDuration											int																	-- average duration for last 10 runs of job
		,@isScheduled											bit																	-- tracks whether job has an enabled schedule assigned
		,@nextScheduledTime								datetime														-- date and time job is scheduled to run next - in client TZ
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
		,@startDate												date																-- 4 values define an operating window for jobs to run within:
		,@endDate													date																-- jobs running more than once per day repeat within the window
		,@startTime												time(0)
		,@endTime													time(0)
		,@nextScheduleCheckTime						datetime														-- the date and time when schedule will be checked next
    ,@lastRunRecords                  int																	-- count of rows processed the last time process ran
    ,@lastRunProcessed                int																	-- count of rows successfully processed in last run
    ,@lastRunErrors                   int																	-- count of rows which had errors in last run

	-- determine the last run for the job then retrieve
	-- values for it from the entity view

	select
		@lastJobRunSID = max(jr.JobRunSID)
	from
		sf.JobRun jr
	where
		jr.JobSID = @JobSID

	select
		 @lastJobStatusSCD		= jrx.JobStatusSCD
		,@lastJobStatusLabel	= jrx.JobStatusLabel
		,@lastStartTime				= sf.fDTOffsetToClientDateTime(jr.StartTime)
		,@lastEndTime					= sf.fDTOffsetToClientDateTime(jr.EndTime)
    ,@lastRunRecords      = jr.TotalRecords
    ,@lastRunProcessed    = jr.RecordsProcessed
    ,@lastRunErrors       = jr.TotalErrors
	from
		sf.JobRun jr
	cross apply
		sf.fJobRun#Ext(jr.JobRunSID)	jrx
	where
		jr.JobRunSID = @lastJobRunSID

	-- calculate duration values (used in warnings)

	select top (1)
		 @minDuration = min(jrx.DurationMinutes)
		,@maxDuration = max(jrx.DurationMinutes)
		,@avgDuration = avg(jrx.DurationMinutes)
	from
		sf.JobRun jr
	cross apply
		sf.fJobRun#Ext(jr.JobRunSID)	jrx
	join
	(
		select top (1)
			x.JobRunSID
		from
			sf.JobRun x
		where
			x.JobSID = @JobSID
		and
			x.IsFailed = @OFF																										-- avoid failed jobs for stats calculations
		order by
			x.JobRunSID desc
	) z on jr.JobRunSID = z.JobRunSID

	-- retrieve job schedule configuration (if assigned)

	select																																	-- read control values from the job and schedule
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
	from
		sf.Job j
	join
		sf.JobSchedule js on j.JobScheduleSID = js.JobScheduleSID
	where
		j.JobSID = @JobSID
	and
		j.IsActive = @ON																											-- if job is not active, it won't be scheduled!
	and
		js.IsEnabled = @ON																										-- if schedule is not active, job is not scheduled!

	if @isScheduled is null set @isScheduled = @OFF

	-- calculate the next scheduled time for the job (if scheduled)

	if @isScheduled = @ON
	begin

		-- initiate the next run date to the date the job was last run; if never run, 
		-- or it was run before the schedule start, use the schedule start date

		if @lastStartTime is null or cast(@lastStartTime as date) < @startDate
		begin
			set @nextRunDate = @startDate
		end
		else
		begin
			set @nextRunDate = cast(@lastStartTime as date)
		end

		-- if the job was started manually, it may have occurred on a day-of-week not
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

			-- if this time is before the job last ran, increment the time value by
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

			if @nextRunDate is null 
			begin
				set @nextScheduledTime = null
			end
			else if (@lastEndTime is not null or @lastStartTime is null)
			begin

				-- get the time the schedule will be checked next - provided the
				-- job is not already running

				select 
					 @nextScheduleCheckTime = cast(switchoffset(cast(ce.dialog_timer as datetimeoffset(7)), cast(sf.fConfigParam#Value('ClientTimeZoneOffset') as varchar(6))) as datetime)
				from 
					sys.conversation_endpoints ce
				where
					far_service = 'JobSchedule'
				and
					state = 'SO'

				-- if the schedule time is earlier than when the job schedule 
				-- will be checked next, replace with the next schedule check time

				if datediff(minute, @nextScheduledTime, @nextScheduleCheckTime) > 1 set @nextScheduledTime = @nextScheduleCheckTime

			end

		end

	end

	-- update the return table with values calculated

	insert 
		@jobRun#Ext
	(
		 LastJobStatusSCD					
		,LastJobStatusLabel				
		,LastStartTime						
		,LastEndTime							
		,NextScheduledTime				
		,NextScheduledTimeServerTZ
		,MinDuration							
		,MaxDuration							
		,AvgDuration
    ,LastRunRecords
    ,LastRunProcessed
    ,LastRunErrors				
	)
	select
		 @lastJobStatusSCD					
		,@lastJobStatusLabel				
		,@lastStartTime						
		,@lastEndTime							
		,@nextScheduledTime				
		,sf.fClientDateTimeToDTOffset(@nextScheduledTime)
		,@minDuration							
		,@maxDuration							
		,@avgDuration
    ,@lastRunRecords
    ,@lastRunProcessed
    ,@lastRunErrors							

	return

end
GO
