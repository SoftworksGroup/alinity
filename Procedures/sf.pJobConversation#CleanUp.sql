SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJobConversation#CleanUp]
	@ConversationCount										int	= null	output								-- optional - returns count of conversations cleaned up
as
/*********************************************************************************************************************************
Procedure	: Job Clean-Up
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Utility procedure to close orphaned conversations and on service broker queues
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Jul	2013		|	Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This procedure is used to clean-up orphaned conversations on service request queues.  Conversations on queues are normally closed
by program code, however, in the event of certain types of failures, messages to end the dialog may not be communicated and an
orphan conversation results.  This procedure searches for those orphaned conversations and ends using the "with cleanup" syntax.

The procedure avoids closing conversations associated with jobs that are currently running by joining to the sf.JobRun table on
the conversation handle.

Example:
--------

declare
	@conversationCount	int

exec sf.pJob#Cleanup
	@ConversationCount = @conversationCount output

print @conversationCount

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
		,@i																int																	-- loop index
		,@maxRow													int																	-- loop limit
		,@conversationHandle							uniqueidentifier										-- next conversation id to close

	declare	
		@work															table																-- list of conversations that appear to be orphans	
	(
		 ID																int									identity(1,1)
		,ConversationHandle								uniqueidentifier		not null
	)
		
	set @ConversationCount = 0																							-- initialize output parameter

	begin try

		insert
			@work
		(
			ConversationHandle
		)
		select
			ce.conversation_handle
		from 
			sys.conversation_endpoints  ce
		left outer join
			sf.vJobRun									jr on ce.conversation_handle = jr.ConversationHandle and jr.JobStatusSCD = 'INPROCESS'
		where
			ce.state <> 'SO'																										-- avoid ending the scheduling monitor job!
		and
			jr.JobRunSID is null

		set @maxRow = @@rowcount
		set @i			= 0

		while @i < @maxRow
		begin

			set @i += 1

			select
				@conversationHandle = w.ConversationHandle
			from
				@work w
			where
				w.ID = @i

			end conversation @conversationHandle with cleanup

			set @ConversationCount += 1																					-- count conversations ended

		end

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
