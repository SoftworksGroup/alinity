SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fJobRun#Ext]
(
	@JobRunSID									int
)
returns @jobRun#Ext	table
(
	 JobStatusSCD											varchar(35)			null								-- current status of the JobRun as a system code
	,JobStatusLabel										nvarchar(35)		null								-- current status of the JobRun as a label (configurable)
	,RecordsPerMinute									int							null								-- number of records job processes per minute
	,RecordsRemaining									int							null								-- number of records that still require processing
	,EstimatedMinutesRemaining				int							null								-- estimated number of minutes to completion of the job
	,EstimatedEndTime									datetime				null								-- estimated time (in client timezone) job will complete
	,DurationMinutes									int							null default 0			-- number of minutes job has taken to run
)
as
/*********************************************************************************************************************************
TableF	: Job Run - Extended Columns
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns a table of calculated columns for the Job Run extended view (vJobRun#Ext)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | Jun	2013			|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This function is called by the dbo.vJobRun#Ext view to return a series of calculated columns.  This function is not intended for 
other purposes and has been designed to emphasize performance over flexibility for other uses.  By using a table function,
many lookups required for the calculated values can be executed once rather than many times if separate functions are used.

Calculations which also provide data back to the #Ext view, but which use completely independent values are NOT included in this
function.

Record Counts
-------------
Most values returned by this function are dependent on the job run record storing TotalRecords and, in some cases, RecordsProcessed
values. If these values are null/0, most calculations cannot be provided. The sproc the job is based on is responsible for 
setting the total records to be processed and to update that value as the job is progressing.  This is only appropriate for jobs
taking longer than a few minutes to complete.

Example
-------

select top (1)
	 jr.JobRunSID
	,jr.JobLabel
	,jrx.*
from 
	sf.JobRun jr
outer apply
	sf.fJobRun#Ext(jr.JobRunSID) jrx

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @ON                              bit = cast(1 as bit)								-- a constant to reduce repetitive cast syntax in bit comparisons
		,@jobStatusSCD										varchar(35)													-- current status of the JobRun as a system code
		,@jobStatusLabel									nvarchar(35)												-- current status of the JobRun as a label (configurable)
		,@recordsPerMinute								int																	-- number of records job processes per minute
		,@recordsRemaining								int																	-- number of records that still require processing
		,@estimatedMinutesRemaining				int																	-- estimated number of minutes to completion of the job
		,@estimatedEndTime								datetime														-- estimated time (in client timezone) job will complete
		,@durationMinutes									int																	-- number of minutes job has taken to run
		,@startTime												datetimeoffset(7)										-- values from job run record used in calculations:
		,@endTime													datetimeoffset(7)
		,@totalRecords										int
		,@recordsProcessed								int
		,@isCancelled											bit
		,@isFailed												bit
		,@isFailureCleared								bit
		,@cancellationRequestTime					datetimeoffset(7)
		,@updateTime											datetimeoffset(7)

	-- select values for calculations

	select
		 @startTime								= jr.StartTime
		,@endTime									= jr.EndTime
		,@totalRecords						= jr.TotalRecords
		,@recordsProcessed				= jr.RecordsProcessed
		,@isCancelled							= jr.IsCancelled
		,@isFailed								= jr.IsFailed
		,@isFailureCleared				= jr.IsFailureCleared
		,@cancellationRequestTime = jr.CancellationRequestTime
		,@updateTime							= jr.UpdateTime
	from
		sf.JobRun jr
	where
		jr.JobRunSID = @JobRunSID

	-- set status values and include default labels and usage notes to update
	-- the sf.TermLabel configuration table if these values are missing from it

	if @isFailed = @ON and @isFailureCleared = @ON
	begin
		set @jobStatusSCD		= 'JOBSTATUS.FAILEDCLEARED'
	end
	else if @isFailed = @ON 
	begin
		set @jobStatusSCD		= 'JOBSTATUS.FAILED'
	end
	else if @isCancelled = @ON
	begin
		set @jobStatusSCD		= 'JOBSTATUS.CANCELLED'
	end
	else if @cancellationRequestTime is not null
	begin
		set @jobStatusSCD = 'JOBSTATUS.CANCELLATIONPENDING'
	end
	else if @endTime is not null
	begin
		set @jobStatusSCD		= 'JOBSTATUS.COMPLETE'
	end
	else
	begin
		set @jobStatusSCD		= 'JOBSTATUS.INPROCESS'
	end

	select
		@jobStatusLabel = isnull(tl.TermLabel, tl.DefaultLabel)								-- override text on the label term is supported											
	from
		sf.TermLabel tl
	where
		tl.TermLabelSCD = @jobStatusSCD
	
	if @jobStatusLabel is null set @jobStatusLabel = cast(replace(@jobStatusSCD, 'JOBSTATUS.','') as nvarchar(35))	-- if not defined - show the code
	set @jobStatusSCD		= cast(replace(@jobStatusSCD, 'JOBSTATUS.','') as varchar(35))															-- remove prefix from system code

	-- calculate the runtime duration in minutes

	if @endTime is not null																									-- if job is complete, use the completion date
	begin
		set @durationMinutes = datediff(minute,@startTime, @endTime)
	end
	else
	begin
		set @durationMinutes = datediff(minute, @startTime, @updateTime)			-- if job is running, use the time to the last update (not current time!)
	end

	-- calculate the run rate in records per minute

	set	@recordsPerMinute = 
	(
		case
			when isnull(@recordsProcessed, @totalRecords) > 0 and @endTime is not null and @durationMinutes > 1		-- record total is stored, job is complete and > 1 minute of runtime
				then isnull(@recordsProcessed, @totalRecords) / @durationMinutes
			when isnull(@recordsProcessed, @totalRecords) > 0 and @endTime is not null														-- as above, but <= 1 minute runtime - show total records
				then isnull(@recordsProcessed, @totalRecords)
			when @recordsProcessed > 0 and @durationMinutes > 1																										-- job is running with a record count for more than 1 minute
				then @recordsProcessed / @durationMinutes
      else null																																															-- otherwise insufficient information to provide the run rate
     end
	)

	set @recordsRemaining = 
	(
		case 
			when @endTime is not null then 0
			when @totalRecords > 0 and isnull(@recordsProcessed,0) > 0	then @totalRecords	- @recordsProcessed
			else null
    end
	)

	if @recordsRemaining < 0 set @recordsRemaining = null										-- if value is negative, there is error in the counting logic so set back to null

	if @endTime is not null
	begin
		set @estimatedMinutesRemaining = null
	end
	else if isnull(@recordsPerMinute,0) > 0 and @recordsRemaining is not null
	begin
		set @estimatedMinutesRemaining = round(@recordsRemaining / @recordsPerMinute,0)
	end

	if @estimatedMinutesRemaining is not null
	begin
		set @estimatedEndTime = sf.fDTOffsetToClientDateTime(dateadd(minute, @estimatedMinutesRemaining, sysdatetimeoffset()))
	end

	-- update the return table with values calculated

	insert 
		@jobRun#Ext
	(
		 JobStatusSCD
		,JobStatusLabel
		,RecordsPerMinute					
		,RecordsRemaining					
		,EstimatedMinutesRemaining
		,EstimatedEndTime					
		,DurationMinutes					
	)
	select
		 @jobStatusSCD
		,@jobStatusLabel
		,@recordsPerMinute
		,@recordsRemaining					
		,@estimatedMinutesRemaining
		,@estimatedEndTime					
		,isnull(@durationMinutes,0)
		
	return

end
GO
