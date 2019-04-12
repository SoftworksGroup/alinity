SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTextMessage#Queue]
	 @TextMessageSID										int																	-- text message key to queue
	,@JobRunSID													int  = null
as
/*********************************************************************************************************************************
Procedure : Text Message - Queue
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Finalizes recipient eligibility and text message preparation (including replacement of merge fields) for sending
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Cory Ng			| Jun		2016	| Initial Version

Comments	
--------
This procedure is called when the user executes the "send" option on an text message.  The text content and recipient list
must already be saved in (sf) Text Message and Person Text Message respectively.

This procedure checks the eligibility of each recipient and deletes the Person Text Message if they are not eligible. The
same eligibility subroutine is called that is provided to show eligibility to the user on the UI.  

The procedure is also responsible for recording the text address mail will be sent to for each recipient. Freezing this value at 
the moment the text is queued preserves audit information since text addresses may be updated afterward and the record of 
addresses used on previous notes may not be available otherwise. (This action is carried out in the #Merge routine to minimize
updates to the record).

The final task carried out by the procedure is to store the Subject and Body content from the Text Message parent record, into 
the individual Subject and Body columns of child Person Text Message records. This operation supports replacement of merge fields
(e.g. [@Lastname]) with values retrieved from data sources for that recipient.  Note that whether or not the text content 
(subject and body values) in the parent text message contain merge fields, a recipient-specific copy of the text message is 
still saved. This approach supports: a) editing of individual message post-merge if offered by the application and b) inclusion of 
"un-subscribe" links that are customized for the recipient text address/profile.

Note regarding calling this sproc as a job
The job sf.TextMessage#Queue must be setup before this will run as a job.  There is a check in the TextMessage#Update and
TextMessage#Insert sprocs for this job.

Example:
--------

TODO: Tim April 2015
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo													int = 0																												-- 0 no error, <50000 SQL error, else business rule
		,@errorText												nvarchar(4000)																								-- message text (for business rule errors)
		,@blankParm												varchar(50)																										-- tracks if any required parameters are not provided 
		,@ON															bit									= cast(1 as bit)													-- used on bit comparisons to avoid multiple casts
		,@OFF															bit									= cast(0 as bit)													-- used on bit comparisons to avoid multiple casts   
		,@CRLF														nchar(2)	= char(13) + char(10)																-- carriage return line feed for formatting text blocks
		,@updateUser											nvarchar(75)																									-- user who is sending the text
		,@maxRow	                        int																														-- loop limit - rows to process
		,@i                               int																														-- loop index
		,@isInvite												bit									= cast(0 as bit)													-- indicates if the message is an invitiation
		,@termLabel												nvarchar(35)																									-- buffer for configurable label text
		,@totalRecords										int		= 0																											-- total records expected to process
		,@recordsProcessed								int		= 0																											-- total records processed
		,@isCancelled											bit		= 0																											-- checks for cancellation request on async job calls  
		,@currentProcessLabel							nvarchar(35)																									-- label for stage of work
		,@resultMessage										nvarchar(4000)																								-- summary of job result
		,@taskQueueSID										int																														-- task creation
		,@taskNotes												nvarchar(max)																									-- task creation
		,@taskStatusSID										int																														-- task creation
		,@dueDate													date								= sf.fToday()															-- task creation
		,@taskTitle												nvarchar(300)																									-- task creation

	declare
		@recipient												table																													-- recipients for the text message with eligibility info
		(
			 ID															int									identity(1,1)
			,PersonTextMessageSID					int									not null
			,PersonSID											int									not null
			,TextAddress										varchar(150)
			,DisplayName										nvarchar(65)
			,HomePhone											varchar(25)
			,MobilePhone										varchar(25)
			,BirthDate											date
			,IsTextAddress									bit									not null
			,IsOptedOut											bit									not null
			,IsApplicationUser							bit									not null
			,IsEligible											bit									not null
		)

	begin try

		if @JobRunSID is not null																							-- if call is async, update the job run record
		begin

			exec sf.pTermLabel#Get															
				 @TermLabelSCD	= 'JOBSTATUS.INPROCESS'
				,@TermLabel			= @termLabel output
				,@DefaultLabel	= N'In Process'
				,@UsageNotes    = N'Indicates the job is currently running, or appears to be running because no completion time or failure was provided.'

			exec sf.pJobRun#Update
				 @JobRunSID						= @JobRunSID
				,@CurrentProcessLabel = @termLabel

		end

		-- check parameters

    if @TextMessageSID is null
    begin

      exec sf.pMessage#Get
         @MessageSCD  	= 'BlankParameter'
        ,@MessageText 	= @errorText output
        ,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
        ,@Arg1          = '@TextMessageSID'

      raiserror(@errorText, 18, 1)

    end

		if not exists( select	1	from sf.TextMessage em where	em.TextMessageSID = @TextMessageSID)
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RecordNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1        = 'Text Message'
				,@Arg2        = @TextMessageSID
        
			raiserror(@errorText, 18, 1)
  
		end

		if isnull(@updateUser, 'x') = N'SystemUser' set @updateUser = left(sf.fConfigParam#Value('SystemUser'),75)										-- override for "SystemUser"
		if isnull(@updateUser, 'x') <> N'SystemUser' set @updateUser = sf.fApplicationUserSession#UserName()													-- application user - or DB user if no application session set

		-- call a subroutine to store the Subject and Body
		-- content for each recipient and to set the text address

		exec sf.pTextMessage#Merge
			 @TextMessageSID			= @TextMessageSID
			,@JobRunSID						= @JobRunSID
			,@TotalRowCount				= @totalRecords			output
			,@TotalProcessedCount = @recordsProcessed	output		

		-- finally, update the queued time on the parent row and 
		-- update audit information 

		if @JobRunSID is not null
		begin

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

			if @isCancelled = @OFF
			begin

				update
					sf.TextMessage																									-- avoid EF sproc call (which would be recursive)						
				set
					 QueuedTime		= sysdatetimeoffset()
					,UpdateTime		= sysdatetimeoffset()
					,UpdateUser		= @updateUser
				where
					TextMessageSID = @TextMessageSID

				exec sf.pMessage#Get
					@MessageSCD  	= 'JobCompletedSucessfully'
					,@MessageText 	= @resultMessage output
					,@DefaultText 	= N'The %1 job was completed successfully.'
					,@Arg1					= 'queue text message'

				exec sf.pJobRun#Update								
					 @JobRunSID						= @JobRunSID
					,@TotalRecords				= @totalRecords
					,@RecordsProcessed		= @recordsProcessed
					,@ResultMessage				= @resultMessage

			end
			else
			begin

				update																														-- job cancelled, set merged time back to null
					sf.TextMessage
				set
					MergedTime		= null
					,UpdateTime		= sysdatetimeoffset()
					,UpdateUser		= @updateUser 
				where
					TextMessageSID = @TextMessageSID

			end

		end
		else
		begin

		update
				sf.TextMessage																										-- avoid EF sproc call (which would be recursive)						
		set
			 QueuedTime		= sysdatetimeoffset()
			,UpdateTime		= sysdatetimeoffset()
			,UpdateUser		= @updateUser
		where
			TextMessageSID = @TextMessageSID

		end

	end try

	begin catch

		if @JobRunSID is not null
		begin

			if @@trancount > 0 rollback																					-- roll back any pending trx so that update can succeed

			update																															-- job failed, set merged time back to null
				sf.TextMessage
			set
				MergedTime		= null
				,UpdateTime		= sysdatetimeoffset()
				,UpdateUser		= @updateUser 
			where
				TextMessageSID = @TextMessageSID

			exec sf.pTermLabel#Get															
				 @TermLabelSCD	= 'JOB.FAILED'
				,@TermLabel			= @termLabel output
				,@DefaultLabel	= N'*** JOB FAILED'
				,@UsageNotes    = N'A label reporting failure of jobs (normally accompanied by error report text from the database).'

			set @errorText = @termLabel + @CRLF + error_message()

			exec sf.pJobRun#Update
				 @JobRunSID						= @JobRunSID
				,@ResultMessage				= @errorText
				,@IsFailed						= @ON

		end

		exec @errorNo  = sf.pErrorRethrow

	end catch

	return (@errorNo)

end
GO
