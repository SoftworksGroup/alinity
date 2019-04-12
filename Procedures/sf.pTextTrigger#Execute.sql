SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTextTrigger#Execute]
	 @JobRunSID									int	= null																	-- reference to sf.JobRun for async call updates
	,@TextTriggerSIDImmediate	int = null																	-- to force 1 trigger to be called immediately		
as
/*********************************************************************************************************************************
Procedure	: Text Trigger Generation
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Reads the job schedule and calls jobs that are due to run then resets the schedule to be read at next check interval
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Cory Ng			| Jun	2016		|	Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is a component of the text system.  The procedure generates text records (sf.PersonTextMessage) according to 
query criteria and other details defined in Text Trigger definitions (sf.TextTrigger). The procedure is designed to be called 
at regular intervals during business hours to create new texts as conditions in the database demand it.  The automated calling 
of the procedure is accomplished through the Job and Job-Schedule system.

For example, a built-in Text Trigger with most configuration is "Password must be changed".  A query is defined in the sf.Query 
table to identify application user profiles who have not changed their password in over X months. This procedure runs the query 
to find records that meet the criteria and then generates text message records for each of them.  Logic within this procedure 
avoids creating duplicate texts.  If a text has already been created for the record then the record is skipped for text creation.

The Text Trigger column "Body" may contain column name symbols which are replaced with values from the
associated entity. This logic is done at when the text message is queued.

Example:
--------

exec sf.pJobSchedule#Stop																									-- stop job schedule to prevent conflicts when testing

exec sf.pTextTrigger#Execute

select * from sf.vPersonTextMessage order by CreateTime desc							-- review texts created

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

set @jobSCD = 'sf.pTextTrigger#Execute'																		-- add the job syntax if not already established 

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
		,@JobLabel						= N'Text creation'
		,@JobDescription			= N'Checks the set of text triggers for creation of new texts. Schedule this process to run frequently - typically every 15 minutes. Each text trigger is also assigned a schedule which this procedure checks to see if the trigger is due to be run.'
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
		,@textTriggerSID									int	= -1														-- next text trigger SID to process
		,@querySID												int																	-- ID of query that gets source rows for the texts
		,@applicationEntitySCD						varchar(50)													-- identifies table that is source of rows for texts
		,@applicationEntitySID						int																	-- identifies table that is source of rows for texts
		,@rowStamp												timestamp														-- row stamp of next trigger - to avoid overwrites
		,@createdTextCount								int																	-- counts text actually created (for each type)
		,@newTextCount										int																	-- number of texts to be created
		,@i																int																	-- loop index - texts
		,@maxRow													int																	-- loop limiter - text of one type to insert
		,@body														nvarchar(1600)											-- body of text with replacements
		,@recordSID												int																	-- SID to use to lookup entity record for replacements
		,@messageSubscriptionSID					int																	-- the subscription the text is to be assigned to
		,@linkExpiryHours									int																	-- indicates when the text link expires
		,@isApplicationUserRequired				bit																	-- indicates if a application user is required
		,@priorityLevel										tinyint															-- priority level of the text
		,@string													nvarchar(max)												-- buffer for calls to string replacement procedure
		,@CRLF														nchar(2)	= char(13) + char(10)			-- carriage return line feed for formatting text blocks
		,@TAB															nchar(1)	= char(9)									-- tab character for formatting text blocks
		,@textTriggerLabel								nvarchar(35)												-- label of the trigger being processed
		,@termLabel												nvarchar(35)												-- buffer for configurable label text
		,@isCancelled											bit		= 0														-- checks for cancellation request on async job calls  
		,@recordsProcessed								int		= 0														-- running total of entities processed   		
		,@resultMessage										nvarchar(4000)											-- summary of job result
		,@traceLog												nvarchar(max)												-- text block for detailed results of job
		,@isDuplicate											bit																	-- indicates if the text is a duplicate
		,@personSID												int																	-- person to send the text to
		,@textMessageSID									int																	-- the text message identifier
		,@mobilePhone											varchar(25)													-- mobile phone number of the target person
		,@minDaysToRepeat									int																	-- number of days before a regen is allowed on "duplicates"
		,@senderPhone											varchar(25)													-- phone number sending the text message
		,@senderDisplayName								nvarchar(75)												-- display name of the phone number sending the text message

	declare
		@work															table
		(
			 ID															int								identity(1,1)
			,RecordSID											int								not null
			,PersonSID											int								not null
			,IsDuplicate										bit								not null default cast(0 as bit)
		)

	begin try

		-- if a specific trigger is passed, ensure it is valid

		if @TextTriggerSIDImmediate is not null
		begin
			
			if not exists (select 1 from sf.TextTrigger x where x.TextTriggerSID = @TextTriggerSIDImmediate)
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'sf.TextTrigger'
					,@Arg2        = @TextTriggerSIDImmediate
				
				raiserror(@errorText, 18, 1)

			end			

		end
		
		if @JobRunSID is not null																							-- if call is async, update the job run record
		begin

			set @traceLog	= sf.fPadR(N'T E X T   C R E A T I O N   S U M M A R Y', 45)								-- format header for trace log
													+ @TAB + 'Created'
													+ @CRLF + sf.fPadR('-----------------------------------------------------', 53)

		end

		set @progressTrace = N'JobRunSID = ' + isnull(ltrim(@JobRunSID), 'None')

		while @textTriggerSID is not null and @isCancelled = @OFF							-- @textTriggerSID initialized to -1 in declare above
		begin

			if @JobRunSID is not null
			begin

				exec sf.pTermLabel#Get															
					 @TermLabelSCD	= 'SELECTING.TEXT.TRIGGER'
					,@TermLabel			= @termLabel output
					,@DefaultLabel	= N'Selecting text trigger ...'
					,@UsageNotes    = N'A label reporting processing status when text triggers are being selected for processing.'

				exec sf.pJobRun#Update
					 @JobRunSID						= @JobRunSID
					,@CurrentProcessLabel = @termLabel

			end

			set @textTriggerSID		= null
			set @readTime					= sysdatetimeoffset()
			set @createdTextCount = 0

			-- if an explicit trigger was passed and is in a running 
			-- status, set its end time to allow a restart

			if exists(select 1 from sf.TextTrigger x where x.TextTriggerSID = @TextTriggerSIDImmediate and x.LastStartTime is not null and x.LastEndTime is null)
			begin

				exec sf.pTextTrigger#Update
					 @TextTriggerSID = @TextTriggerSIDImmediate
					,@LastEndTime		 = @readTime

			end

			-- get the next trigger until no more are due to be processed; multiple calls to this 
			-- procedure run concurrently so avoid triggers that are running (already being processed)
			
			select top (1)
				 @textTriggerSID						= tt.TextTriggerSID
				,@minDaysToRepeat						= tt.MinDaysToRepeat
				,@querySID									= tt.QuerySID
				,@applicationEntitySCD			= ae.ApplicationEntitySCD
				,@applicationEntitySID			= ae.ApplicationEntitySID
				,@rowStamp									= tt.RowStamp
				,@textTriggerLabel					= tt.TextTriggerLabel
				,@priorityLevel							= t.PriorityLevel
				,@body											= t.Body
				,@isApplicationUserRequired	= t.IsApplicationUserRequired
				,@linkExpiryHours						= t.LinkExpiryHours
			from
				sf.vTextTrigger				tt
			join
				sf.Query							q		on tt.QuerySID = q.QuerySID
			join
				sf.TextTemplate				t on tt.TextTemplateSID = t.TextTemplateSID
			left outer join
				sf.ApplicationEntity	ae	on t.ApplicationEntitySID = ae.ApplicationEntitySID
			where
				tt.IsRunning = @OFF
			and
				tt.IsActive = @ON
			and
			(
				(@TextTriggerSIDImmediate is null and tt.NextScheduledTimeServerTZ <= @readTime)
			or
				tt.TextTriggerSID = @TextTriggerSIDImmediate
			)
			order by
				tt.NextScheduledTimeServerTZ
				
			if @textTriggerSID is not null
			begin

				set @progressTrace += @CRLF + N'TextTriggerSID = ' + isnull(ltrim(@textTriggerSID), 'NULL')

				-- mark this text trigger as running to prevent other instances of the sproc
				-- from processing it at the same time

				exec sf.pTextTrigger#Update
					 @textTriggerSID = @textTriggerSID
					,@LastStartTime		= @readTime
					,@LastEndTime			= null																				-- LastEndTime is actually changed by logic within this sproc
					,@RowStamp				= @rowStamp																		-- to check for overwrites

				set @recordsProcessed += 1

				if @JobRunSID is not null
				begin

					exec sf.pJobRun#Update
						 @JobRunSID						= @JobRunSID
						,@CurrentProcessLabel = @textTriggerLabel
						,@RecordsProcessed		= @recordsProcessed

					set @progressTrace += @CRLF + N'TextTrigger start update OK' 

				end

				-- remove records from the work table that were processed in the
				-- last query; NOTE: this does not reset identity!

				delete @work

				set @progressTrace += @CRLF + N'Variable reset OK' 

				-- execute the query to return SID values for records
				-- that meet the criteria for text creation along
				-- with the person SID to send the text to

				insert
					@work
				(
					 RecordSID
					,PersonSID
				)
				exec sf.pQuery#Execute 
					 @QuerySID				= @querySID	

				set @progressTrace += @CRLF + N'Query execute OK' 

				-- mark duplicates where records already have texts created for them
				-- for this text trigger;

				update
					w
				set
					w.IsDuplicate = @ON
				from
					@work		w
				join
					sf.PersonTextMessage pem		on w.RecordSID = pem.MergeKey and w.PersonSID = pem.PersonSID and pem.TextTriggerSID = @textTriggerSID
				where
					@minDaysToRepeat <> -1
				and
					sf.fDTOffsetToClientDateTime(dateadd(dd, @minDaysToRepeat, pem.CreateTime)) >= sf.fNow()	

				set @progressTrace += @CRLF + N'Duplicate update OK' 

				-- identity on memory table is not reset so must be max ID
				-- based on query

				select
					 @maxRow = max(w.ID) 
					,@i			= 0
				from 
					@work w

				set @progressTrace += @CRLF + N'Text insert to memory (max ID = ' + isnull(ltrim(@maxRow), 'NULL') + ') OK' 

				while @i < @maxRow
				begin
				
					set @recordSID = null
					set @personSID = null
					set @mobilePhone = null

					select 
						@i = min(w.ID)																							-- identity was not reset, so must query for next ID
					from
						@work w
					where
						w.ID > @i

					select
						 @recordSID						= w.RecordSID
						,@personSID						= w.PersonSID
						,@isDuplicate					= w.IsDuplicate
						,@mobilePhone					= p.MobilePhone
					from
						@work w
					left outer join
						sf.Person		p on w.PersonSID = p.PersonSID
					where
						w.ID = @i
						
					if @personSID is null
					begin
						set @progressTrace += @CRLF + N'Person (ID = ' + isnull(ltrim(@i), 'NULL') + ') not specified' 
					end
					else if @mobilePhone is null
					begin
						set @progressTrace += @CRLF + N'Person (SID = ' + isnull(ltrim(@personSID), 'NULL') + ') no mobile phone number' 
					end
					else
					begin
						set @progressTrace += @CRLF + N'Text (ID = ' + isnull(ltrim(@i), 'NULL') + ') retrieved OK' 
					end
					
					if @isDuplicate = @OFF and @personSID is not null and @mobilePhone is not null
					begin

						set @progressTrace += @CRLF + N'Text (ID = ' + isnull(ltrim(@i),'NULL') + ') replacements OK' 
						
						select
							 @senderPhone				= ts.SenderPhone
							,@senderDisplayName = ts.SenderDisplayName
						from
							sf.TextSender ts
						where
							ts.IsDefault = @ON

						exec sf.pTextMessage#Insert
							 @TextMessageSID						= @textMessageSID output
							,@PriorityLevel							= @priorityLevel
							,@Body											= @body
							,@IsApplicationUserRequired	= @isApplicationUserRequired
							,@LinkExpiryHours						= @linkExpiryHours
							,@ApplicationEntitySID			= @applicationEntitySID
							,@SenderPhone								= @senderPhone
							,@SenderDisplayName					= @senderDisplayName

						exec sf.pPersonTextMessage#Insert
							 @PersonSID				= @personSID
							,@TextMessageSID	= @textMessageSID
							,@MobilePhone			= @mobilePhone
							,@MergeKey				= @recordSID
							,@TextTriggerSID	= @textTriggerSID
							
						exec sf.pTextMessage#Queue
							 @TextMessageSID = @textMessageSID

						set @createdTextCount += 1

					end
							
				end

				-- mark the end time to mark the trigger complete

				set @readTime = sysdatetimeoffset()

				exec sf.pTextTrigger#Update
					 @textTriggerSID = @textTriggerSID
					,@LastEndTime		 = @readTime

				set @progressTrace += @CRLF + N'TextTrigger end update OK' 

				-- update the record count and the result message with 
				-- counts for the text trigger just processed

				if @JobRunSID is not null
				begin

					set @recordsProcessed	+= 1
				
					set @traceLog += @CRLF + sf.fPadR(@textTriggerLabel,40) + sf.fPadL(ltrim(@createdTextCount), 7)
		
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

			if @TextTriggerSIDImmediate is not null set @textTriggerSID = null	-- terminate loop if a trigger was called immediately

		end

		-- update job with final totals for actually records processed
		-- and errors encountered

		if @JobRunSID is not null and @isCancelled = @OFF
		begin

			if @recordsProcessed = 0 
			begin

				exec sf.pMessage#Get
					 @MessageSCD  	= 'NoTextTriggersScheduled'
					,@MessageText 	= @resultMessage output
					,@DefaultText 	= N'No text triggers were scheduled to be processed at this time.  (This is not an error.)'

				set @traceLog			 = N'(No text triggers to process.)'
			end
			else
			begin

				exec sf.pMessage#Get
					 @MessageSCD  	= 'JobCompletedSucessfully'
					,@MessageText 	= @resultMessage output
					,@DefaultText 	= N'The %1 job was completed successfully.'
					,@Arg1					= 'text creation'

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

		if exists(select 1 from sf.vTextTrigger et where et.TextTriggerSID = @textTriggerSID and  et.IsRunning = @ON)
		begin

				set @readTime = sysdatetimeoffset()

				exec sf.pTextTrigger#Update
					 @textTriggerSID = @textTriggerSID
					,@LastEndTime			= @readTime

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

			set @errorText = @termLabel + isnull(N' AT : ' + @textTriggerLabel + @CRLF, N'')
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
