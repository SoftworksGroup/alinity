SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pJobSchedule#Read
as
/*********************************************************************************************************************************
Procedure	: Job Schedule Read
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Reads the job schedule and calls jobs that are due to run then resets the schedule to be read at next check interval
----------------------------------------------------------------------------------------------------------------------------------
History		: Author							| Month Year	| Change Summary
					: ------------------- + ----------- + ----------------------------------------------------------------------------------
 					: Tim Edlund          | Jul 2013		|	Initial version
					: Tim Edlund					| Aug 2018		| Updated to call JobHistory#Purge when schedule is empty

Comments	
--------
This procedure is a component of the framework's job management system.  The procedure reads the job schedule (sf.JobSchedule) and
calls jobs asynchronously through pJob#Call (which uses JobRequestQ and JobProcessQ).  The procedure is designed to be the 
activation procedure for the JobScheduleQ.

Job scheduling does not use SQL Agent. Rather, the SQL Service Broker queue technology is used.  A single queue is used,  
"JobScheduleQ", which manages a single conversation that, except in the case of errors, is never ended.  The only message expected
is a dialog timer which contains no content about the job.  All job syntax and schedule information required is stored in sf.Job 
and sf.JobSchedule.  The message is only used as a timing method to call this procedure at set intervals.  When a message is read 
the schedule of jobs is checked and procedures are called for the jobs due to be run at that time.  The conversation is reset for 
the next interval through a "begin conversation timer" command.  The interval to use is obtained through the "schedule check 
interval" configuration parameter established in the sf.ConfigParam table (defaults to checking every 15 minutes if not specified).  

In order to kick off the scheduler another procedure sf.pJobSchedule#Start is called to send the original message. That procedure
may be started through the UI but should be called through a database start-up trigger to make sure the schedule is available when 
the database starts.  (See sf.pJob#Start for syntax).

Example:
--------

--exec sf.pJobSchedule#Stop																								-- if required, stop schedule to change this sproc!
--delete from sf.JobScheduleEvent

exec sf.pJobSchedule#Start																								-- ensure schedule Q is started

select																																		-- check schedule events
	 jse.JobScheduleEventSID
	,jse.EventName
	,jse.EventDescription
	,jse.UpdateTime
from
	sf.JobScheduleEvent jse
order by
	 jse.UpdateTime desc
	,jse.JobScheduleEventSID desc

select																																		-- s/b 1 conversation running for the Q
	Conversation_Handle ConversationHandle
	,far_service				ServiceName
	,dialog_timer				DialogTimer																					-- time of event is in UTC format (GMT 0)
	,sysdatetime()			CurrentTime
from 
	sys.conversation_endpoints
where
	far_service = 'JobSchedule'

------------------------------
-- to test schedule with a job
------------------------------

declare
	 @CRLF								nchar(2) = char(13) + char(10)										-- constant for formatting job syntax script
	,@jobSID							int																								-- key of the sf.Job#Simulate record in sf.Job		
	,@callSyntaxTemplate	nvarchar(max)																			-- syntax for the job with replacement tokens
	,@jobScheduleLabel		nvarchar(35)
	,@jobScheduleSID			int

-- add a schedule

set @jobScheduleLabel = N'Weekdays 15 minutes: 9am to 9pm'

select
	@jobScheduleSID = JobScheduleSID
from
	sf.JobSchedule where JobScheduleLabel = @jobScheduleLabel			

if @jobScheduleSID is null
begin

	exec sf.pJobSchedule#Insert
		 @JobScheduleSID				= @jobScheduleSID		output
		,@JobScheduleLabel			= @jobScheduleLabel
		,@IsRunMonday						= 1
		,@IsRunTuesday					= 1
		,@IsRunWednesday				= 1
		,@IsRunThursday					= 1
		,@IsRunFriday						= 1
		,@RepeatIntervalMinutes = 15																					-- set shorter if schedule check frequency is shorter
		,@StartTime							= '09:00'
		,@EndTime								= '21:00'

end

-- add the job simulation job record if not already established

select
	@jobSID = j.JobSID
from
	sf.Job j
where
	j.JobSCD = 'sf.pJob#Simulate'

if @jobSID is null
begin

	set @callSyntaxTemplate = 
		'exec sf.pJob#Simulate' 
		+ @CRLF + '   @JobRunSID         = {JobRunSID}'
		+ @CRLF + '  ,@RecordsToSimulate = {p1}'
		+ @CRLF	+ '  ,@UpdateInterval    = {p2}'

	exec sf.pJob#Insert
		 @JobSID							= @jobSID		output
		,@JobSCD							= 'sf.pJob#Simulate'
		,@JobLabel						= N'Job Activity Simulator (Test)'
		,@CallSyntaxTemplate	= @callSyntaxTemplate
		,@IsParallelEnabled   = 1

end

exec sf.pJob#Update
	 @JobSID					= @jobSID
	,@JobScheduleSID	= @jobScheduleSID

-- use queries above and sf.vJobRun (below) to examine results

select 
	 jr.JobSCD
	,jr.ResultMessage
	,jr.IsFailed
	,jr.StartTime
	,jr.CurrentProcessLabel
	,jr.TotalRecords
	,jr.RecordsProcessed
	,jr.RecordsRemaining
	,jr.CancellationRequestTime
	,jr.EndTime
	,jr.CallSyntax
	,jr.ConversationHandle	 
from 
	sf.vJobRun jr
where
	jr.JobSCD = 'sf.pJob#Simulate'
order by 
	UpdateTime desc
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int = 0						-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)		-- message text (for business rule errors)    
	 ,@conversationHandle		uniqueidentifier	-- service broker dialog the job is to be executed on	
	 ,@messageType					nvarchar(500)			-- type of message received
	 ,@now									datetimeoffset(7) -- current time at server (for checking for #Purge call)
	 ,@i										int								-- loop index counter
	 ,@maxRow								int								-- loop limit
	 ,@jobSCD								varchar(132)			-- next job to call
	 ,@readTime							datetimeoffset(7) -- time at start of procedure 
	 ,@messageSCD						varchar(128)			-- message code for logging errors
	 ,@jobScheduleEventSID	int								-- key value of logging event record
	 ,@scheduleReadInterval int								-- minutes between schedule checks (for reset of timer)
	 ,@eventName						nvarchar(35)			-- buffer to get config specific version of term for event
	 ,@eventDescription			nvarchar(35)			-- buffer to get config specific version of term for event
	 ,@jobList							nvarchar(max)			-- list of procedures started
	 ,@errorProc						nvarchar(128)			-- procedure error was generated from
	 ,@errorSeverity				int								-- severity: 16 user, 17 configuration, 18 program 
	 ,@errorState						int								-- between 0 and 127 (MS has not documented these!)
	 ,@errorLine						int;							-- line number in the calling procedure

	declare @work table (ID int identity(1, 1), JobSCD varchar(132) not null);

	begin try

		-- read the message from the queue

		; receive top (1)
				@conversationHandle = conversation_handle
			 ,@messageType = message_type_name
			from sf.JobScheduleQ

		if @@rowcount > 0
		begin

			-- first log the event that the schedule is being read

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'SCHEDULE.READ'
			 ,@TermLabel = @eventName output
			 ,@DefaultLabel = N'Schedule Read'
			 ,@UsageNotes = N'Indicates the schedule was checked for new jobs.';

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'SCHEDULE.NO.JOBS.STARTING' -- assume no jobs are due to be started
			 ,@TermLabel = @eventDescription output
			 ,@DefaultLabel = N'No jobs scheduled to start.'
			 ,@UsageNotes = N'Indicates that no jobs were due to be started according to the schedule.';

			exec sf.pJobScheduleEvent#Insert
				@JobScheduleEventSID = @jobScheduleEventSID output
			 ,@EventName = @eventName
			 ,@EventDescription = @eventDescription;

			-- ensure we are getting the (only) expected message type

			if @messageType <> 'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer'
			begin

				-- if the message is not recognized, log it but don't roll back to 
				-- avoid invoking "poison message" logic that would stop the queue

				exec sf.pMessage#Get
					@MessageSCD = 'UnexpectedMessageType'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The message type "%1" was not expected on the "%2" queue.'
				 ,@Arg1 = @messageType
				 ,@Arg2 = 'JobProcessQ';

				begin try
					raiserror(@errorText, 18, 1);
				end try

				begin catch

					end conversation @conversationHandle; -- send end of conversation since this message type is invalid!

					-- log the error to the schedule event table if a record was
					-- added; otherwise log in sf.UnexpectedError

					if @jobScheduleEventSID is not null
					begin

						exec sf.pJobScheduleEvent#Update
							@JobScheduleEventSID = @jobScheduleEventSID
						 ,@EventName = 'ERROR'
						 ,@EventDescription = @errorText;

					end;
					else
					begin

						set @errorNo = isnull(error_number(), 0); -- retrieve error event values
						set @errorState = error_state();
						set @errorSeverity = error_severity();
						set @errorProc = error_procedure();
						set @errorLine = error_line();
						set @errorText = error_message();

						exec sf.pErrorRethrow$Log -- log the error to sf.UnexpectedError
							@ErrorNo = @errorNo
						 ,@ErrorProc = @errorProc
						 ,@ErrorLine = @errorLine
						 ,@ErrorSeverity = @errorSeverity
						 ,@ErrorState = @errorState
						 ,@MessageSCD = 'UnexpectedMessageType'
						 ,@MessageText = @errorText;

					end;

				end catch;

			end;
			else
			begin

				-- otherwise do the work of starting up jobs that are ready to run 
				-- according to the schedule

				set @readTime = sysdatetimeoffset();

				insert -- load the work table
					@work (JobSCD)
				select
					j.JobSCD
				from
					sf.vJob j
				where
					j.NextScheduledTimeServerTZ <= @readTime
				order by
					j.JobScheduleSequence;

				-- call each job asynchronously using pJob#Call
				-- which places the call syntax into the JobRequestQ

				set @maxRow = @@rowcount;
				set @i = 0;

				while @i < @maxRow
				begin

					set @i += 1;

					select @jobSCD = w .JobSCD from @work w where w.ID = @i;

					exec sf.pJob#Call -- note that parameters other than "JobRunSID" are not supported 
						@JobSCD = @jobSCD;	-- for scheduled jobs; except for parameters with defaults 

					set @jobList = isnull(@jobList + ', ', '') + @jobSCD; -- compile job list to update event

				end;

				if @jobList is not null -- update the event with the job list if jobs were found
				begin

					exec sf.pTermLabel#Get
						@TermLabelSCD = 'SCHEDULE.JOBS.FOUND'
					 ,@TermLabel = @eventDescription output
					 ,@DefaultLabel = N'Job(s) called:'
					 ,@UsageNotes = N'Prefix for list of jobs called by scheduler.';

					set @jobList = @eventDescription + N' ' + @jobList;

					exec sf.pJobScheduleEvent#Update
						@JobScheduleEventSID = @jobScheduleEventSID
					 ,@EventDescription = @jobList;

				end;

				-- if a conversation was found and the message type was a dialog timer
				-- the conversation is not ended - reset the timer to resume 

				set @scheduleReadInterval = cast(isnull(sf.fConfigParam#Value('ScheduleReadInterval'), '15') as int) * 60; -- retrieve check interval from config (minutes)
				begin conversation timer (@conversationHandle)
				timeout = @scheduleReadInterval; -- and convert to seconds

			end;

		end;
		else
		begin

			if exists (select 1 from sf .JobRun jr where datediff(month, jr.EndTime, @now) > 1)
			begin
				exec sf.pJobHistory#Purge; -- job queue is empty so call #Purge to remove old records
			end;
		end;

	end try
	begin catch

		-- any other errors occurring in the procedure must be logged as no UI
		-- attends the schedule reader

		set @messageSCD = 'SQL' + convert(varchar(10), error_number()); -- MessageCode format is: SQL[errorNo]
		set @errorNo = error_number();
		set @errorNo = isnull(error_number(), 0); -- retrieve error event values
		set @errorState = error_state();
		set @errorSeverity = error_severity();
		set @errorProc = error_procedure();
		set @errorLine = error_line();
		set @errorText = error_message();

		-- log the error to the schedule event table if a record was
		-- added; otherwise log in sf.UnexpectedError

		if @jobScheduleEventSID is not null
		begin

			exec sf.pJobScheduleEvent#Update
				@JobScheduleEventSID = @jobScheduleEventSID
			 ,@EventName = 'ERROR'
			 ,@EventDescription = @errorText;

		end;
		else
		begin

			set @errorNo = isnull(error_number(), 0); -- retrieve error event values
			set @errorState = error_state();
			set @errorSeverity = error_severity();
			set @errorProc = error_procedure();
			set @errorLine = error_line();
			set @errorText = error_message();

			exec sf.pErrorRethrow$Log -- log the error to sf.UnexpectedError
				@ErrorNo = @errorNo
			 ,@ErrorProc = @errorProc
			 ,@ErrorLine = @errorLine
			 ,@ErrorSeverity = @errorSeverity
			 ,@ErrorState = @errorState
			 ,@MessageSCD = @messageSCD
			 ,@MessageText = @errorText;

		end;

	end catch;

	return (@errorNo);

end;
GO
