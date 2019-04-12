SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJobSchedule#Start]
	 @ConversationHandle		uniqueidentifier = null		output								-- handle identifying job conversation (for debugging)
as
/*********************************************************************************************************************************
Procedure	: Job Schedule Start
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Establishes the initial conversation in the job schedule queue
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Jul	2013		|	Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This function is a component of the framework's job management system.  To understand the job and scheduling sub-system a working
knowledge of the SQL Server Service Broker technology is required.  

The procedure is called to start the Job Schedule.  The job schedule may be stopped periodically by system administrators to
delay processing of jobs due to system maintenance or to alleviate performance problems during peak processing times.  This 
procedure re-enables the schedule.  If the job schedule system is already enabled, an error is raised.

The procedure checks the database for the configuration conditions required to make the job and schedule sub-system operational.
This includes ensuring the Service Broker has been enabled on the database.  If SSB is not enabled, an error is raised.

The procedure also checks for the existence of the queues required in the framework and that they are enabled and active.  If any 
queues are missing from the database, an error is raised.  If a queue exists but is not enabled or activated, an attempt is made
to alter the queue to bring it online.  If successful, no error is raised.

Finally the procedure checks for the existence of a conversation on the JobSchedule queue.  Only 1 conversation is required by
the scheduler. 

Job scheduling does not use SQL Agent. Rather, the SQL Service Broker queue technology is used.  A single scheduled queue 
"JobScheduleQ" is established with a single conversation that, except in the case of errors, is never ended.  This procedure 
establishes the conversation.  The message is read by sf.pJobSchedule#Read which also resets the conversation to the next interval 
through a "begin conversation timer" command.  

This procedure should be called through a database start-up trigger to ensure the schedule is available when the database
is restarted. The procedure can also be started from the UI if the schedule is stopped.  Use sf.JobSchedule#IsStarted() to check
whether the schedule is already running.

Example:
--------

declare
	@conversationHandle		uniqueidentifier

select 
	 Conversation_Handle ConversationHandle
	,far_service				 ServiceName
	,dialog_timer				 DialogTimer
	,sysdatetime()			 CurrentTime
from 
	sys.conversation_endpoints
where
	far_service = 'JobSchedule'

exec sf.pJobSchedule#Start
	@ConversationHandle	= @conversationHandle output

select @conversationHandle ConversationHandle

select 
	 Conversation_Handle ConversationHandle
	,far_service				 ServiceName
	,dialog_timer				 DialogTimer
	,sysdatetime()			 CurrentTime
from 
	sys.conversation_endpoints
where
	far_service = 'JobSchedule'

waitfor delay '00:00:03'
select * from sf.JobScheduleEvent order by UpdateTime desc

--exec sf.pJobSchedule#Stop

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
    ,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
    ,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
		,@termLabel1											nvarchar(35)												-- buffer to get config specific version of term for event
		,@termLabel2											nvarchar(35)												-- buffer to get config specific version of term for event
		,@audit														nvarchar(100)												-- time and user who started the schedule
		,@i									int																								-- index for iterating through required queue names
		,@queueName					nvarchar(128)																			-- next queue name to check
		
	set @ConversationHandle = null																					-- initialize output parameter

	begin try

		if sf.fJobSchedule#IsStarted() = @ON
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'AlreadyStarted'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" service is already started.'
				,@Arg1        = N'Job Schedule'
				
			raiserror(@errorText, 18, 1)

		end

		if not exists
		(
			select
				1
			from
				sys.databases sdb 
			where 
				sdb.name = db_name()
			and
				sdb.is_broker_enabled = 1
		)
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'ServiceNotEnabled'
				,@MessageText = @errorText output
				,@DefaultText = N'The "%1" service is not enabled in the database.'
				,@Arg2        = N'Service Broker'
				
			raiserror(@errorText, 17, 1)

		end		

		-- check each required queue and activate it if not already enabled and activated

		set @i = 0

		while @i < 3
		begin

			set @i += 1

			if @i = 1 set @queueName = 'JobRequestQ'
			if @i = 2 set @queueName = 'JobProcessQ'
			if @i = 3 set @queueName = 'JobScheduleQ'
	
			if not exists
			(
				select 
					1 
				from 
					sys.service_queues sq
				where
					sq.name = @queueName
				and
					sq.is_receive_enabled = 1
				and
					sq.is_enqueue_enabled = 1
				and
					sq.is_activation_enabled = 1
			)
			begin

				if not exists																													-- ensure queue exists
				(
					select 
						1
					from
						sys.service_queues sq
					where
						sq.name = @queueName
				)
				begin

					exec sf.pMessage#Get
						 @MessageSCD  = 'RecordNotFound'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
						,@Arg1        = 'Service Broker Queue'
						,@Arg2        = @queueName
				
					raiserror(@errorText, 18, 1)

				end			

				if @i = 1
				begin

					alter queue sf.JobRequestQ
						 with status	= on 
						,retention		= off
						,activation (status= on)

				end
				else if @i = 2
				begin

					alter queue sf.JobProcessQ
						 with status	= on 
						,retention		= off
						,activation (status= on)

				end
				else if @i = 3
				begin

					alter queue sf.JobScheduleQ
						 with status	= on 
						,retention		= off
						,activation (status= on)

				end

			end

		end
		
		-- only start the schedule conversation if one is not already open

		if not exists
			(
				select
					1
				from
					sys.conversation_endpoints ce
				where
					ce.far_service = 'JobSchedule'
				and
					ce.[state] <> 'ER'
				and
					ce.[state] <> 'CD'
				and
					ce.[state] <> 'DO'
			)
		begin

			-- send the message

			begin dialog 
				conversation @ConversationHandle
				from service JobSchedule																					-- send a message from the JobRequest to JobProcess
				to service	'JobSchedule'
				on contract JobContract
				with encryption = off;

			begin conversation timer (@ConversationHandle)
			timeout = 30;																												-- causes a "dialog timer" message to be sent

		end

		-- log the event

		exec sf.pTermLabel#Get															
				@TermLabelSCD	= 'SCHEDULE.STARTED'
			,@TermLabel			= @termLabel1 output
			,@DefaultLabel	= N'Schedule Started'
			,@UsageNotes    = N'Indicates the schedule is being started.'

		exec sf.pTermLabel#Get															
			 @TermLabelSCD	= 'BY'
			,@TermLabel			= @termLabel2 output
			,@DefaultLabel	= N'By'
			,@UsageNotes    = N'Usually applied in reference to a person performing an action - e.g. Action by Jane Smith'


		set @audit = cast(@termLabel2 + ' ' + sf.fApplicationUserSession#UserName() as nvarchar(100))

		exec sf.pJobScheduleEvent#Insert
			 @EventName					= @termLabel1
			,@EventDescription	= @audit

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
