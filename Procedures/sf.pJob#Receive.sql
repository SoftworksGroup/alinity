SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJob#Receive]
as
/*********************************************************************************************************************************
Procedure	: Job Receive
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Reads next job from the JobProcessQ and calls the pJob#Execute procedure
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Jun	2013		|	Initial version 
					: Tim Edlund	| Oct 2013		| Removed encapsulating transaction to simplify poison-messaging handling and to avoid
																				runtime errors that were occurring in transaction count mismatches
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is a component of the framework's job management system.  The procedure is called after a job has been setup for
asynchronous execution by sending the job's syntax into the "JobProcessQ" queue.  That message is read from the queue here and
an sf.JobRun record is inserted to track the job.  This procedure then passes the job's call syntax retrieved from the queue
to the pJob#Execute procedure for dynamic execution.

Note that the call syntax may include the symbol "{JobRunSID}" which is replaced with the actual job run SID by pJob#Execute so
that the job procedure can update total records, records processed, and messaging on the sf.JobRun record as it proceeds. The job
can mark itself complete by setting the ResultMessage and/or the IsFailed bit.  If the job does not mark itself complete, a 
default completion message is provided by the sf.pJob#Execute procedure. 

As of this version of the procedure - only the following message types are recognized:
	"JobRequest" - request to call a stored procedure asynchronously

If other message types are received, an error is raised.

Error Handling
--------------
If the procedure encounters an error on the attempts to create the job run record or when calling the execution procedure, an 
error is raised.  An error is also raised when an unrecognized message type is encountered.  These errors are raised to the 
calling UI but the message is stripped from the job queue and committed (no transaction) to avoid invoking "poison message" 
logic. If the error were raised and a rollback occurred, then the message would go back on the queue and the error would be 
be encountered repeatedly. The job would never complete and all future jobs in the queue would be blocked since the built-in 
poison-message feature de-activates the queue after 5 successive rollbacks. 

Internal errors reported on the conversation are reported to both services in the conversation. Those types of errors should
only be logged in one location, however, and that is designated in this design as pJob#End. 

Example:
--------

-- called automatically by configuration of the sf.JobProcessQ

------------------------------------------------------------------------------------------------------------------------------- */
																																																																		
begin  

	set nocount on

	declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
		,@conversationHandle							uniqueidentifier										-- service broker dialog the job is to be executed on	
		,@messageType											nvarchar(500)												-- type of message received
		,@messageBody											xml																	-- message retrieved from the queue
		,@jobSID													int																	-- PK value of the job being called (sf.Job)
		,@callSyntax											nvarchar(max)												-- job call syntax
		,@jobRunSID												int																	-- key of new job run record
		,@processLabel										nvarchar(35)												-- initial state label to display on job 
		,@errorProc 											nvarchar(128)												-- procedure error was generated from
		,@errorSeverity 									int																	-- severity: 16 user, 17 configuration, 18 program 
		,@errorState 											int																	-- between 0 and 127 (MS has not documented these!)
		,@errorLine 											int																	-- line number in the calling procedure
		
	begin try

		waitfor(
			receive top (1)
				 @conversationHandle	= conversation_handle
				,@messageType					= message_type_name
				,@messageBody					= message_body 
			from 
				sf.JobProcessQ
		), timeout 5000																												-- no transaction!  delete from queue immediately processed	after read

		if @conversationHandle is not null
		begin

			if	@messageType = 'JobRequest'
			begin

				select 
					 @jobSID			= Context.ID.value('@JobSID[1]','int') 
					,@callSyntax	= Context.ID.value('@CallSyntax[1]','nvarchar(max)') 
				from 
					@messageBody.nodes('Job') as Context(ID)

				-- ensure the job key provided is valid

				if not exists (select 1 from sf.Job x where x.JobSID = @JobSID)
				begin

					exec sf.pMessage#Get
						 @MessageSCD  = 'RecordNotFound'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
						,@Arg1        = 'sf.Job'
						,@Arg2        = @JobSID
				
					raiserror(@errorText, 18, 1)																		-- if no job; message is poison and is already removed

				end			
			
				-- create a record for logging the job and then obtain the new job run key value

				exec sf.pJobRun#Insert
					 @JobRunSID						= @jobRunSID	output
					,@JobSID							= @jobSID
					,@ConversationHandle	= @ConversationHandle
					,@CallSyntax					= @CallSyntax
					,@CurrentProcessLabel	= @processLabel
 
				-- job is successfully recorded for received message; any rollback occurring within
				-- the job won't roll back the job record so a trace is available of the job that started

				exec sf.pJob#Execute																							-- call procedure to execute the job
					 @CallSyntax		= @callSyntax
					,@JobRunSID			= @jobRunSID

			end
			else
			begin

				-- if the message is not recognized, log it; this message is poison
				-- but was removed from queue so processing continues

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

				end catch

			end

			end conversation @conversationHandle																-- send end of conversation message to the requesting service

		end
		
	end try

	begin catch
		
		-- if job can't be called - raise an error

		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
