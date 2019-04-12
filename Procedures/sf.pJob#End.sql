SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJob#End]
as
/*********************************************************************************************************************************
Procedure	: Job End 
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Ends the conversation on the Job Request Queue (the initiating queue)
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Jun	2013		|	Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is a component of the framework's job management system.  The procedure is called after a job has been processed
and an "end conversation" statement has been issued by the processing queue (in sf.pJob#Receive). Both sides of a conversation
need to issue end commands to complete it. This procedure responds to the "end" message by sending its own end message.  This
procedure is also responsible logging errors messages that may have occurred on the queue.  Error messages are sent to both sides
of conversations so they must only be logged here (not in pJob#Receive).

If the message type received is anything other than an "end" or "error", the message type is unexpected and a new error is logged
on the queue. In all cases the procedure ends the conversation.

Example:
--------

-- called automatically by configuration of the sf.JobReceiveQ

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
		,@conversationHandle							uniqueidentifier										-- service broker dialog the job is to be executed on	
		,@messageType											nvarchar(500)												-- type of message received
		,@messageBody											nvarchar(4000)											-- job call syntax
		,@errorProc 											nvarchar(128)												-- procedure error was generated from
		,@errorSeverity 									int																	-- severity: 16 user, 17 configuration, 18 program 
		,@errorState 											int																	-- between 0 and 127 (MS has not documented these!)
		,@errorLine 											int																	-- line number in the calling procedure

	begin try

		waitfor(
			receive top (1)
				 @conversationHandle = conversation_handle
				,@messageType					= message_type_name
				,@messageBody					= message_body
			from sf.JobRequestQ
		), timeout 50

		if @conversationHandle is not null 
		begin

			if	@messageType = 'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'									-- normal case, end of conversation received
			begin
				end conversation @conversationHandle
			end
			else if @messageType = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'									-- error received - log it
			begin

				exec sf.pErrorRethrow$Log
					 @ErrorNo										= 50000
					,@ErrorProc									= 'sf.pJob#End'
					,@ErrorLine									= 0
					,@ErrorSeverity							= 0
					,@ErrorState								= 0
					,@MessageSCD  							= 'ErrorOnJobRequestQ'
					,@MessageText 							= @messageBody

				end conversation @conversationHandle																												-- conversation is still ended

			end
			else
			begin

				-- if the message is not recognized, log it but don't roll back

				exec sf.pMessage#Get
					 @MessageSCD  	= 'UnexpectedMessageType'
					,@MessageText 	= @errorText output
					,@DefaultText 	= N'The message type "%1" was not expected on the "%2" queue.'
					,@Arg1					= @messageType
					,@Arg2					= 'JobProcessQ'

				begin try
					raiserror(@errorText, 18, 1)
				end try

				begin catch

					set @errorNo 				= isnull(error_number(), 0)									-- retrieve error event values
					set @errorState 		= error_state()
					set @errorSeverity 	= error_severity()
					set @errorProc 			= error_procedure()
					set @errorLine 			= error_line()
					set @errorText			= error_message()

					exec sf.pErrorRethrow$Log																				-- log the error to sf.UnexpectedError
						 @ErrorNo										= @errorNo
						,@ErrorProc									= @errorProc
						,@ErrorLine									= @errorLine
						,@ErrorSeverity							= @errorSeverity
						,@ErrorState								= @errorState
						,@MessageSCD  							= 'UnexpectedMessageType'
						,@MessageText 							= @errorText

					end conversation @conversationHandle														-- end the conversation with error
						with error	= @errorNo
						description = 'Unexpected Message Type (see log)'

				end catch

			end

		end
		
	end try

	begin catch
		
		-- if queue cannot be read -  raise an error

		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
