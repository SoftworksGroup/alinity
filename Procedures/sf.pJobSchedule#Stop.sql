SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJobSchedule#Stop]
as
/*********************************************************************************************************************************
Procedure	: Job Schedule Stop
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Stops the job scheduler from running
----------------------------------------------------------------------------------------------------------------------------------
History		: Author							| Month Year	| Change Summary
					: ------------------- + ----------- + ----------------------------------------------------------------------------------
 					: Tim Edlund          | Jul 2013		|	Initial version

Comments
--------
This procedure is a component of the framework's job management system.  The procedure looks for any active conversations on
the JobScheduleQ and ends them. The procedure is a utility to allow administrators to stop the schedule for maintenance or in 
the case where scheduled jobs are causing other problems in the application.  The scheduled can be re-activated by calling
sf.pJobSchedule#Start.

Note that only a single conversation is expected on the JobScheduleQ, however, if multiple conversations were established, all
of them are ended by this procedure. 

Example:
--------

select 
	Conversation_Handle ConversationHandle
	,far_service				ServiceName
	,dialog_timer				DialogTimer
	,sysdatetime()			CurrentTime
from 
	sys.conversation_endpoints
where
	far_service = 'JobSchedule'

exec sf.pJobSchedule#Stop

select 
	Conversation_Handle ConversationHandle
	,far_service				ServiceName
	,dialog_timer				DialogTimer
	,sysdatetime()			CurrentTime
from 
	sys.conversation_endpoints
where
	far_service = 'JobSchedule'

select * from sf.JobScheduleEvent order by CreateTime desc

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int							= 0		-- 0 no error, <50000 SQL error, else business rule
	 ,@conversationHandle uniqueidentifier			-- next conversation handle to process
	 ,@termLabel1					nvarchar(35)					-- buffer to get config specific version of term for event
	 ,@termLabel2					nvarchar(35)					-- buffer to get config specific version of term for event
	 ,@audit							nvarchar(100)					-- time and user who started the schedule
	 ,@i									int							= 0;	-- counts conversations ended

	begin try

		set @conversationHandle = newid();

		while @conversationHandle is not null
		begin

			set @conversationHandle = null;

			select
				@conversationHandle = ce.conversation_handle
			from
				sys.conversation_endpoints ce
			where
				ce.far_service = 'JobSchedule' and ce.state <> 'ER' and ce.state <> 'CD' and ce.state <> 'DO';

			if @conversationHandle is not null
			begin
				end conversation @conversationHandle;
				set @i += 1;
			end;

		end;

		-- log the event

		exec sf.pTermLabel#Get
			@TermLabelSCD = 'BY'
		 ,@TermLabel = @termLabel2 output
		 ,@DefaultLabel = N'by'
		 ,@UsageNotes = N'Usually applied in reference to a person performing an action - e.g. Action by Jane Smith';

		if @i > 0
		begin

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'SCHEDULE.STOPPED'
			 ,@TermLabel = @termLabel1 output
			 ,@DefaultLabel = N'Schedule stopped'
			 ,@UsageNotes = N'Indicates the schedule was stopped by a user action.';

		end;
		else
		begin

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'SCHEDULE.NOT.RUNNING'
			 ,@TermLabel = @termLabel1 output
			 ,@DefaultLabel = N'Schedule not running'
			 ,@UsageNotes = N'Indicates an attempt was made to stop the schedule but it was not found to be running.';

		end;

		set @audit = cast(@termLabel2 + ' ' + sf.fApplicationUserSession#UserName() as nvarchar(100));

		exec sf.pJobScheduleEvent#Insert
			@EventName = @termLabel1
		 ,@EventDescription = @audit;

		-- whenever the schedule is stopped, also run the utility to end
		-- any orphaned conversations

		exec sf.pJobConversation#CleanUp;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
