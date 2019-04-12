SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTaskTrigger#Execute]
	 @JobRunSID									int	= null																	-- reference to sf.JobRun for async call updates
	,@TaskTriggerSIDImmediate		int = null																	-- to force 1 trigger to be called immediately		
as
/*********************************************************************************************************************************
Procedure	: Task Trigger Generation
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Reads the job schedule and calls jobs that are due to run then resets the schedule to be read at next check interval
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Jul	2013		|	Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is a component of the task system.  The procedure generates task records (sf.Task) according to query criteria
and other details defined in Task Trigger definitions (sf.TaskTrigger).  The procedure is designed to be called at regular
intervals during business hours to create new tasks as conditions in the database demand it.  The automated calling of the
procedure is accomplished through the Job and Job-Schedule system.

For example, a built-in Task Trigger with most configuration is "Unused accounts".  A query is defined in the sf.Query table
to identify application user profiles where no login has occurred in X days.  "X" is a configuration parameter defined in 
sf.ConfigParam.  This procedure runs the query to find records that meet the criteria and then generates task records for each 
of them.  Logic within this procedure avoids creating duplicate tasks.  If a task has already been created for the record, and
that task is in an open status, then the record is skipped for task creation.

The Task Trigger columns "TaskTitle" and "TaskDescription" may contain column name symbols which are replaced with values from the
associated entity view as the tasks are created.  See also sf.pFormatString#Entity.

Example:
--------

exec sf.pJobSchedule#Stop																									-- stop job schedule to prevent conflicts when testing

exec sf.pTaskTrigger#Execute

select * from sf.vTask order by CreateTime desc														-- review tasks created

exec sf.pJobSchedule#Start																								-- restart job schedule when test is complete

--------------------------------
-- call the job asynchronously 
--------------------------------

declare
	 @CRLF								nchar(2) = char(13) + char(10)										-- constant for formatting job syntax script
	,@jobSID							int																								-- key of the sf.Job#Simulate record in sf.Job		
	,@jobSCD							varchar(128)																			-- code for the job to insert
	,@callSyntaxTemplate	nvarchar(max)																			-- syntax for the job with replacement tokens
	,@parameters					xml																								-- buffer to record parameters for the call syntax
	,@conversationHandle	uniqueidentifier																	-- ID assigned to each job conversation

set @jobSCD = 'sf.pTaskTrigger#Execute'																		-- add the job syntax if not already established 

select
	@jobSID = j.JobSID
from
	sf.Job j
where
	j.JobSCD = @jobSCD

if @jobSID is null
begin

	set @callSyntaxTemplate = 
		'exec ' + @jobSCD
		+ @CRLF + '   @JobRunSID            = {JobRunSID}'

	exec sf.pJob#Insert
		 @JobSID							= @jobSID		output
		,@JobSCD							= @jobSCD
		,@JobLabel						= N'Task creation'
		,@JobDescription			= N'Checks the set of task triggers for creation of new tasks. Schedule this process to run frequently - typically every 15 minutes. Each task trigger is also assigned a schedule which this procedure checks to see if the trigger is due to be run.'
		,@CallSyntaxTemplate	= @callSyntaxTemplate

end

exec sf.pJob#Call
	 @JobSCD							= @jobSCD
	,@Parameters					= @parameters

waitfor delay '00:00:03'																									-- wait for job to start

select top 3																															-- use this select to monitor the job
	*
from
	sf.vJobRun jr
order by
	jr.UpdateTime desc


------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
    ,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
    ,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
		,@progressTrace										nvarchar(max)												-- content for tracing progress to point of error
		,@readTime												datetimeoffset(7)										-- time at start of procedure 
		,@taskTriggerSID									int	= -1														-- next task trigger SID to process
		,@querySID												int																	-- ID of query that gets source rows for the tasks
		,@applicationEntitySCD						varchar(50)													-- identifies table that is source of rows for tasks
		,@rowStamp												timestamp														-- row stamp of next trigger - to avoid overwrites
		,@openTaskLimit										int																	-- controls maximum number of concurrent open tasks
		,@openTaskCount										int																	-- counts number of tasks already open
		,@newTaskCount										int																	-- counts max number of tasks that can be created
		,@createdTaskCount								int																	-- counts task actually created (for each type)
		,@i																int																	-- loop index - tasks
		,@maxRow													int																	-- loop limiter - task of one type to insert
		,@j																int																	-- loop index - subscribers
		,@maxSub													int																	-- loop limiter - subscribers for each alert task
		,@taskTitle												nvarchar(65)												-- title of task to format with replacements
		,@taskDescription									varbinary(max)											-- notes for task to format with replacements
		,@taskDescriptionString						nvarchar(max)												-- buffer to manipulate task notes as a text string
		,@rowGUID													uniqueidentifier										-- GUID to use to lookup entity record for replacements
		,@taskQueueSID										int																	-- the queue the task is to be assigned to
		,@isAlert													bit																	-- if the task is an alert (distribute to subscribers)
		,@applicationUserSID							int																	-- next application user to assign task or alert to
		,@string													nvarchar(max)												-- buffer for calls to string replacement procedure
		,@CRLF														nchar(2)	= char(13) + char(10)			-- carriage return line feed for formatting text blocks
		,@TAB															nchar(1)	= char(9)									-- tab character for formatting text blocks
		,@taskTriggerLabel								nvarchar(35)												-- label of the trigger being processed
		,@isRegeneratedIfClosed						bit																	-- tracks if duplicate tasks are allowed when closed
		,@termLabel												nvarchar(35)												-- buffer for configurable label text
		,@isCancelled											bit		= 0														-- checks for cancellation request on async job calls  
		,@recordsProcessed								int		= 0														-- running total of entities processed   		
		,@resultMessage										nvarchar(4000)											-- summary of job result
		,@traceLog												nvarchar(max)												-- text block for detailed results of job

	declare
		@work															table
		(
			 ID															int								identity(1,1)
			,RowGUID												uniqueidentifier	not null
			,IsDuplicate										bit								not null default cast(0 as bit)
		)

	declare
		@task															table
		(
			 ID															int								identity(1,1)
			,TaskTitle											nvarchar(65)			not null
			,TaskQueueSID										int								not null
			,TargetRowGUID									uniqueidentifier	null
			,TaskDescription								varbinary(max)		not null
			,IsAlert												bit								not null
			,PriorityLevel									tinyint						not null
			,ApplicationUserSID							int								null
			,DueDate												date							not null
			,NextFollowUpDate								date							null
			,ApplicationPageSID							int								null							-- TODO: Tim June 2015- structure was changed to include ApplicationPageSID rather than controller action and URI
			,ApplicationController					varchar(75)				null							-- Retesting of this procedure was not completed.  Controller, Action and URI to be dropped?  Analysis Required
			,ApplicationAction							varchar(75)				null
			,ApplicationPageURI							varchar(150)			null
			,TaskTriggerSID									int								null
		)

	declare
		@subscriber												table
		(
			 ID															int								identity(1,1)
			,ApplicationUserSID							int								not null
		)

	begin try

		-- if a specific trigger is passed, ensure it is valid

		if @TaskTriggerSIDImmediate is not null
		begin
			
			if not exists (select 1 from sf.TaskTrigger x where x.TaskTriggerSID = @TaskTriggerSIDImmediate)
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.TaskTrigger'
					,@Arg2        = @TaskTriggerSIDImmediate
				
				raiserror(@errorText, 18, 1)

			end			

		end

		if @JobRunSID is not null																							-- if call is async, update the job run record
		begin

			set @traceLog	= sf.fPadR(N'T A S K   C R E A T I O N   S U M M A R Y', 40)										-- format header for trace log
													+ @TAB + '   Open' + @TAB + '  Limit' + @TAB + 'Created'
													+ @CRLF + sf.fPadR('---------------------------------------', 40)

		end

		set @progressTrace = N'JobRunSID = ' + isnull(ltrim(@JobRunSID), 'None')

		while @taskTriggerSID is not null and @isCancelled = @OFF							-- @taskTriggerSID initialized to -1 in declare above
		begin

			if @JobRunSID is not null
			begin

				exec sf.pTermLabel#Get															
					 @TermLabelSCD	= 'SELECTING.TASK.TRIGGER'
					,@TermLabel			= @termLabel output
					,@DefaultLabel	= N'Selecting task trigger ...'
					,@UsageNotes    = N'A label reporting processing status when task triggers are being selected for processing.'

				exec sf.pJobRun#Update
					 @JobRunSID						= @JobRunSID
					,@CurrentProcessLabel = @termLabel

			end

			set @taskTriggerSID		= null
			set @readTime					= sysdatetimeoffset()
			set @newTaskCount			= 0
			set @createdTaskCount = 0

			-- if an explicit trigger was passed and is in a running 
			-- status, set its end time to allow a restart

			if exists(select 1 from sf.TaskTrigger x where x.TaskTriggerSID = @TaskTriggerSIDImmediate and x.LastStartTime is not null and x.LastEndTime is null)
			begin

				exec sf.pTaskTrigger#Update
					 @TaskTriggerSID = @TaskTriggerSIDImmediate
					,@LastEndTime		 = @readTime

			end

			-- get the next trigger until no more are due to be processed; multiple calls to this 
			-- procedure run concurrently so avoid triggers that are running (already being processed)

			select top (1)
				 @taskTriggerSID				= tt.TaskTriggerSID
				,@querySID							= tt.QuerySID
				,@applicationEntitySCD	= ae.ApplicationEntitySCD
				,@rowStamp							= tt.RowStamp
				,@openTaskLimit					= tt.OpenTaskLimit
				,@taskTriggerLabel			= tt.TaskTriggerLabel
				,@isRegeneratedIfClosed = tt.IsRegeneratedIfClosed
			from
				sf.vTaskTrigger				tt
			join
				sf.Query							q		on tt.QuerySID = q.QuerySID
			join
				sf.ApplicationPage		ap	on q.ApplicationPageSID = ap.ApplicationPageSID
			join
				sf.ApplicationEntity	ae	on ap.ApplicationEntitySID = ae.ApplicationEntitySID
			where
				tt.IsRunning = @OFF
			and
			(
				(@TaskTriggerSIDImmediate is null and tt.NextScheduledTimeServerTZ <= @readTime)
			or
				tt.TaskTriggerSID = @TaskTriggerSIDImmediate
			)
			order by
				tt.NextScheduledTimeServerTZ

			if @taskTriggerSID is not null
			begin

				set @progressTrace += @CRLF + N'TaskTriggerSID = ' + isnull(ltrim(@taskTriggerSID), 'NULL')

				-- mark this task trigger as running to prevent other instances of the sproc
				-- from processing it at the same time

				exec sf.pTaskTrigger#Update
					 @TaskTriggerSID = @taskTriggerSID
					,@LastStartTime	 = @readTime
					,@LastEndTime		 = null																					-- LastEndTime is actually changed by logic within this sproc
					,@RowStamp			 = @rowStamp																		-- to check for overwrites

				set @recordsProcessed += 1
				if isnull(@openTaskLimit,0) = 0 set @openTaskLimit = 100					-- if no limit provided for task type, set to default value

				if @JobRunSID is not null
				begin

					exec sf.pJobRun#Update
						 @JobRunSID						= @JobRunSID
						,@CurrentProcessLabel = @taskTriggerLabel
						,@RecordsProcessed		= @recordsProcessed

					set @progressTrace += @CRLF + N'TaskTrigger start update OK' 

				end

				-- remove records from the work table that were processed in the
				-- last query; NOTE: this does not reset identity!

				delete @subscriber						
				delete @work

				set @progressTrace += @CRLF + N'Variable reset OK' 

				-- execute the query to return row GUID values for records
				-- that meet the criteria for task creation

				insert
					@work
				(
					RowGUID
				)
				exec sf.pQuery#Execute 
					 @QuerySID				= @querySID	
					,@ReturnRowGUIDs	= @ON

				set @progressTrace += @CRLF + N'Query execute OK' 

				-- mark duplicates where records already have tasks created for them
				-- for this task trigger; duplicates allowed if closed and regenerating ON

				update
					w
				set
					w.IsDuplicate = @ON
				from
					@work		w
				join
					sf.Task t					on w.RowGUID = t.TargetRowGUID
				join
					sf.TaskStatus ts	on t.TaskStatusSID = ts.TaskStatusSID
				where
					isnull(t.TaskTriggerSID, -1) = @taskTriggerSID									-- find existing tasks for this trigger
				and
					(
						ts.IsClosedStatus =	@OFF																			-- task found - its a duplicate if the task exists and its open		
					or
						@isRegeneratedIfClosed = @OFF																	-- if task found for row, whether open or closed, its a 
					)																																-- duplicate if regeneration is OFF	

				set @progressTrace += @CRLF + N'Duplicate update OK' 

				select @newTaskCount = count(1) from @work w where w.IsDuplicate = @OFF											-- count number of new tasks

				select
					@openTaskCount = count(1)																																	-- count tasks already open	
				from
					sf.Task t
				join
					sf.TaskStatus ts on t.TaskStatusSID = ts.TaskStatusSID
				where
					isnull(t.TaskTriggerSID, -1) = @taskTriggerSID
				and
					ts.IsClosedStatus = @OFF 

				-- if additional tasks exceed open task limit, reduce the new task count

				if @newTaskCount + @openTaskCount > @openTaskLimit 
				begin
					set @newTaskCount = (@openTaskLimit - @openTaskCount)
				end

				set @progressTrace += @CRLF + N'Task counts OK' 

				if isnull(@newTaskCount,0) > 0
				begin

					delete @task

					insert
						@task
					(
						 TaskTitle					
						,TaskQueueSID				
						,TargetRowGUID			
						,TaskDescription					
						,IsAlert						
						,PriorityLevel			
						,ApplicationUserSID	
						,DueDate						
						,NextFollowUpDate		
						,ApplicationController
						,ApplicationAction
						,ApplicationPageURI	
						,TaskTriggerSID			
					)
					select top (@newTaskCount)
						 tt.TaskTitleTemplate
						,tt.TaskQueueSID				
						,w.RowGUID
						,cast(tt.TaskDescriptionTemplate as varbinary(max))
						,tt.IsAlert
						,tt.PriorityLevel
						,tt.ApplicationUserSID
						,dateadd(day, tt.TargetCompletionDays, sf.fToday())
						,null
						,cast(ap.ApplicationRoute as varchar(75))
						,tt.ApplicationAction
						,ap.ApplicationPageURI
						,tt.TaskTriggerSID	
					from
						@work								w
					cross join
						sf.TaskTrigger			tt
					join
						sf.Query						q		on tt.QuerySID = q.QuerySID
					join
						sf.ApplicationPage	ap on q.ApplicationPageSID = ap.ApplicationPageSID
					where
						w.IsDuplicate = @OFF
					and
						tt.TaskTriggerSID = @taskTriggerSID

					-- identity on memory table is not reset so must be max ID
					-- based on query

					select
						 @maxRow = max(t.ID) 
						,@i			= 0
					from 
						@task t

					set @progressTrace += @CRLF + N'Task insert to memory (max ID = ' + isnull(ltrim(@maxRow), 'NULL') + ') OK' 

					while @i < @maxRow
					begin

						select 
							@i = min(t.ID)																							-- identity was not reset, so must query for next ID
						from
							@task t
						where
							t.ID > @i

						select
							 @taskTitle						= t.TaskTitle
							,@taskDescription			= t.TaskDescription
							,@rowGUID							= t.TargetRowGUID
							,@taskQueueSID				= t.TaskQueueSID
							,@isAlert							= t.IsAlert
							,@applicationUserSID	= t.ApplicationUserSID
						from
							@task t
						where
							t.ID = @i

						set @progressTrace += @CRLF + N'Task (ID = ' + isnull(ltrim(@i), 'NULL') + ') retrieved OK' 

						-- check for and process replacements in title and task notes

						if @taskTitle like N'%{%}%'
						begin

							set @string = @taskTitle

							exec sf.pFormatString#Entity 
								 @String								= @string								output
								,@ApplicationEntitySCD	= @applicationEntitySCD
								,@RowGUID								= @rowGUID

							set @taskTitle = cast(@string as nvarchar(65))

						end

						set @taskDescriptionString = cast(@taskDescription as nvarchar(max))

						if @taskDescriptionString like N'%{%}%'
						begin

							exec sf.pFormatString#Entity 
								 @String								= @taskDescriptionString						output
								,@ApplicationEntitySCD	= @applicationEntitySCD
								,@RowGUID								= @rowGUID

							set @taskDescription = cast(@taskDescriptionString as varbinary(max))

						end

						set @progressTrace += @CRLF + N'Task (ID = ' + isnull(ltrim(@i),'NULL') + ') replacements OK' 

						if @isAlert = @ON
						begin
							
							insert
								@subscriber
							(
								ApplicationUserSID
							)
							select
								tqs.ApplicationUserSID
							from
								sf.vTaskQueueSubscriber tqs
							where
								tqs.TaskQueueSID = @taskQueueSID
							and
								tqs.IsActive = @ON																				-- ensure subscription is active!
							order by
								tqs.UpdateTime

							set @progressTrace += @CRLF + N'Alerted subscribers insert for (ID = ' + isnull(ltrim(@i), 'NULL') + ') OK' 

						end
						else if @applicationUserSID is not null
						begin

							insert
								@subscriber
							(
								ApplicationUserSID
							)
							select
								@applicationUserSID

							set @progressTrace += @CRLF + N'Task subscriber (ID = ' + isnull(ltrim(@applicationUserSID), 'NULL') + ') insert OK' 

						end

						select
							 @maxSub = isnull(max(s.ID), 0)
						from 
							@subscriber s

						set @j = 0

						-- the loop condition handles alerts, where rows are created for each subscriber,
						-- and tasks where only 1 record is created 

						while (@isAlert = @ON and @j < @maxSub) or (@isAlert = @OFF and @j = 0)
						begin

							set @applicationUserSID = null

							select 
								@j = min(s.ID)																						-- identity was not reset, so must query for next ID
							from
								@subscriber s
							where
								s.ID > @j

							select
								@applicationUserSID = s.ApplicationUserSID
							from
								@subscriber s
							where
								s.ID = @j

							insert
								sf.vTask
							(
							 TaskTitle					
							,TaskQueueSID				
							,TargetRowGUID			
							,TaskDescription					
							,IsAlert						
							,PriorityLevel			
							,ApplicationUserSID	
							,DueDate						
							,NextFollowUpDate		
							,ApplicationPageSID
							,TaskTriggerSID		
							)
							select
								 @taskTitle			
								,t.TaskQueueSID				
								,t.TargetRowGUID			
								,@taskDescription					
								,t.IsAlert						
								,t.PriorityLevel			
								,@applicationUserSID
								,t.DueDate						
								,t.NextFollowUpDate		
								,t.ApplicationPageSID
								,t.TaskTriggerSID			
							from
								@task t
							where
								t.ID = @i		
							
							set @createdTaskCount += 1	
							set @progressTrace += @CRLF + N'sf.Task (total = ' + isnull(ltrim(@createdTaskCount), 'NULL') + ') inserted OK' 				

						end

					end

				end

				-- mark the end time to mark the trigger complete

				set @readTime = sysdatetimeoffset()

				exec sf.pTaskTrigger#Update
					 @TaskTriggerSID = @taskTriggerSID
					,@LastEndTime		 = @readTime

				set @progressTrace += @CRLF + N'TaskTrigger end update OK' 

				-- update the record count and the result message with 
				-- counts for the task trigger just processed

				if @JobRunSID is not null
				begin

					set @recordsProcessed	+= 1
				
					set @traceLog += @CRLF + sf.fPadR(@taskTriggerLabel,40) 
												+  @TAB + sf.fPadL(ltrim(@openTaskCount), 7) + @TAB + sf.fPadL(ltrim(@openTaskLimit), 7) + @TAB + sf.fPadL(ltrim(@createdTaskCount), 7)
		
					if exists
					(
						select
							1
						from
							sf.JobRun jr
						where
							jr.CancellationRequestTime is not null
						and
							jr.JobRunSID = @JobRunSID
					)
					begin
						set @isCancelled = @ON
					end

					exec sf.pJobRun#Update
						 @JobRunSID						= @JobRunSID
						,@RecordsProcessed		= @recordsProcessed
						,@CurrentProcessLabel = @termLabel														-- reset label for selecting next trigger
						,@IsCancelled					= @isCancelled

					set @progressTrace += @CRLF + N'Job cancel check OK' 

				end

			end

			if @TaskTriggerSIDImmediate is not null set @taskTriggerSID = null	-- terminate loop if a trigger was called immediately

		end

		-- update job with final totals for actually records processed
		-- and errors encountered

		if @JobRunSID is not null and @isCancelled = @OFF
		begin

			if @recordsProcessed = 0 
			begin

				exec sf.pMessage#Get
					 @MessageSCD  	= 'NoTaskTriggersScheduled'
					,@MessageText 	= @resultMessage output
					,@DefaultText 	= N'No task triggers were scheduled to be processed at this time.  (This is not an error.)'

				set @traceLog			 = N'(No task triggers to process.)'
			end
			else
			begin

				exec sf.pMessage#Get
					 @MessageSCD  	= 'JobCompletedSucessfully'
					,@MessageText 	= @resultMessage output
					,@DefaultText 	= N'The %1 job was completed successfully.'
					,@Arg1					= 'task creation'

			end

			exec sf.pJobRun#Update								
				 @JobRunSID						= @JobRunSID
				,@TotalRecords				= @recordsProcessed
				,@RecordsProcessed		= @recordsProcessed
				,@TotalErrors					= 0
				,@TraceLog						= @traceLog																	-- post detailed summary report to trace log
				,@ResultMessage				= @resultMessage

			set @progressTrace += @CRLF + N'Job final update OK' 

		end

	end try

	begin catch

		-- errors occurring here will be logged by the job executor
		-- that calls this

		if @@trancount > 0 rollback

		-- if a failure occurs, ensure the trigger is not marked as still being running

		if exists(select 1 from sf.vTaskTrigger tt where tt.TaskTriggerSID = @taskTriggerSID and  tt.IsRunning = @ON)
		begin

				set @readTime = sysdatetimeoffset()

				exec sf.pTaskTrigger#Update
					 @TaskTriggerSID = @taskTriggerSID
					,@LastEndTime		 = @readTime

		end

		if @JobRunSID is not null
		begin

		set @traceLog  += @CRLF + @CRLF + 'PROGRESS TRACE' + @CRLF + '--------------' 
									 + @CRLF + error_message() + ' at procedure "' + error_procedure() + '" line# ' + ltrim(error_line())

			exec sf.pTermLabel#Get															
				 @TermLabelSCD	= 'JOB.FAILED'
				,@TermLabel			= @termLabel output
				,@DefaultLabel	= N'*** JOB FAILED'
				,@UsageNotes    = N'A label reporting failure of jobs (normally accompanied by error report text from the database).'

			set @errorText = @termLabel + isnull(N' AT : ' + @taskTriggerLabel + @CRLF, N'')
			set @errorText += @CRLF + error_message() + ' at procedure "' + error_procedure() + '" line# ' + ltrim(error_line())

			exec sf.pJobRun#Update
				 @JobRunSID			= @JobRunSID
				,@ResultMessage = @errorText
				,@TraceLog			= @traceLog																				-- post interim result message to trace log for debugging
				,@IsFailed			= @ON

		end
		else
		begin
			print @progressTrace
		end

		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw

	end catch

	return(@errorNo)

end
GO
