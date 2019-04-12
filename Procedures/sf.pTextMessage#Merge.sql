SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pTextMessage#Merge]
	@TextMessageSID						int																					-- text message key to queue
	,@JobRunSID									int							= null											-- Job run used for logging, etc... (optional)
	,@TotalRowCount             int             = null output								-- count of rows (optional)
	,@TotalProcessedCount       int             = null output								-- count of rows processed (optional)
as
/*********************************************************************************************************************************
Procedure : Text Message - Merge
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Saves text message content for each recipient with merge field replacements (if any)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Cory Ng			| Jun		2016	| Initial Version

Comments	
--------
This procedure is part of the text queuing process invoked when the user "sends" the message.  The project stores the Subject and 
Body content from the Text Message parent record, into the individual Subject and Body columns of child Person Text Message 
records. This operation supports replacement of merge fields (e.g. [@Lastname]) with values retrieved from data sources for that 
recipient.  

Whether or not the text content, subject and body, in the parent text message contain merge fields a recipient-specific copy of 
the text message is still saved. This approach supports: a) editing of individual message post-merge if offered by the 
application and b) inclusion of "un-subscribe" links that are customized for the recipient text address/profile.

Example:
--------

TODO: Cory Jun 2016
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo													int = 0																												-- 0 no error, <50000 SQL error, else business rule
		,@errorText												nvarchar(4000)																								-- message text (for business rule errors)
		,@blankParm												varchar(50)																										-- tracks if any required parameters are not provided 
		,@ON															bit									= cast(1 as bit)													-- used on bit comparisons to avoid multiple casts
		,@OFF															bit									= cast(0 as bit)													-- used on bit comparisons to avoid multiple casts 
		,@maxRow	                        int																														-- loop limit - rows to process
		,@i                               int																														-- loop index
		,@j                               int																														-- string parser index position
		,@isQueued												bit																														-- tracks whether text has already been queued
		,@updateUser											nvarchar(75)																									-- user who is sending the text
		,@personTextMessageSID						int																														-- record key to lookup for field replacements 
		,@personTextMessageRowGUID				uniqueidentifier																							-- reference key to text used in page links
		,@mobilePhone											varchar(25)																										-- mobile number to send text to
		,@applicationEntitySCD						varchar(50)																										-- schema.tablename for primary data source (if any)
		,@mergeKey												int																														-- record key to lookup in primary data source (if any)
		,@subjectTemplate									nvarchar(65)																									-- text subject template (as text)
		,@bodyTemplate										nvarchar(1600)																								-- text body template (as text)
		,@subjectText											nvarchar(65)																									-- merged subject text to store in next message (as text)
		,@bodyText												nvarchar(1600)																								-- merged body text to store in next message (as text)
		,@termLabel												nvarchar(35)																									-- buffer for configurable label text
		,@isCancelled											bit		= 0																											-- checks for cancellation request on async job calls  
		,@currentProcessLabel							nvarchar(35)																									-- label for stage of work
		,@resultMessage										nvarchar(4000)																								-- summary of job result

	declare
		@recipient												table																													-- recipients for the text message with eligibility info
		(
			 ID															int									identity(1,1)
			,PersonTextMessageSID						int									not null
			,PersonTextMessageRowGUID				uniqueidentifier		not null
			,MobilePhone										varchar(25)				not null
			,ApplicationEntitySCD						varchar(50)					null
			,MergeKey												int									null
		)

	set @TotalRowCount = null
	set @TotalProcessedCount = null

	begin try

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

		-- in order to prevent editing and changes
		-- while process proceeds, set merged time

		if isnull(@updateUser, 'x') = N'SystemUser' set @updateUser = left(sf.fConfigParam#Value('SystemUser'),75)										-- override for "SystemUser"
		if isnull(@updateUser, 'x') <> N'SystemUser' set @updateUser = sf.fApplicationUserSession#UserName()													-- application user - or DB user if no application session set

		update
			sf.TextMessage																											-- note: avoid EF #Update for performance!
		set
			 MergedTime		= sysdatetimeoffset()
			,UpdateTime		= sysdatetimeoffset()
			,UpdateUser		= @updateUser
		where
			TextMessageSID = @TextMessageSID

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RecordNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1        = 'Text Message'
				,@Arg2        = @TextMessageSID
        
			raiserror(@errorText, 18, 1)
  
		end

		-- get content for the merge

		select
			 @bodyTemplate		= tm.Body
			,@isQueued				= cast(case when tm.QueuedTime is not null then 1 else 0 end as bit)
		from
			sf.TextMessage tm
		where
			tm.TextMessageSID = @TextMessageSID

		if @isQueued = @ON
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'AlreadyQueuedNoMerge'
				,@MessageText = @errorText output
				,@DefaultText = N'Content for this text message cannot be updated because it has already been queued for sending.'
        
			raiserror(@errorText, 18, 1)

		end

		-- load work table with recipients to process

		insert
			@recipient
		(
			 PersonTextMessageSID
			,PersonTextMessageRowGUID
			,MobilePhone
			,ApplicationEntitySCD
			,MergeKey
		)
		select 
			 pem.PersonTextMessageSID
			,pem.RowGUID
			,p.MobilePhone
			,ae.ApplicationEntitySCD
			,pem.MergeKey
		from
			sf.PersonTextMessage pem
		join
			sf.TextMessage				em	on pem.TextMessageSID = em.TextMessageSID
		join
			sf.Person							p		on pem.PersonSID = p.PersonSID
		left outer join
			sf.ApplicationEntity	ae	on em.ApplicationEntitySID = ae.ApplicationEntitySID
		where
			pem.TextMessageSID = @TextMessageSID
		and
			pem.SentTime is null																								-- checked to allow re-start of failed process
		order by
			pem.PersonTextMessageSID

		set @maxRow = @@rowcount
		set @i			= 0

		while @i < @maxRow and @isCancelled = @OFF
		begin

			set @i += 1

			select
				 @personTextMessageSID			= r.PersonTextMessageSID
				,@personTextMessageRowGUID	= r.PersonTextMessageRowGUID
				,@mobilePhone								= r.MobilePhone
				,@applicationEntitySCD			= r.ApplicationEntitySCD
				,@mergeKey									=	r.MergeKey
			from
				@recipient r
			where
				r.ID = @i

			set @bodyText	= @bodyTemplate															

			if @applicationEntitySCD is not null and @mergeKey is not null			-- replace merge fields for primary source if identified
			begin

				if @bodyText like N'%[@%]%'																				-- avoid call if no merge fields
				begin					

					exec sf.pTextTemplate#Merge
						 @TextTemplate							= @bodyText			output
						,@ApplicationEntitySCD			= @applicationEntitySCD
						,@RecordSID									= @mergeKey

				end

			end

			if @bodyText like N'%[@%]%'																					-- replace merge fields for text message entity source
			begin

				exec sf.pTextTemplate#Merge
					 @TextTemplate							= @bodyText			output
					,@ApplicationEntitySCD			= 'sf.PersonTextMessage'
					,@RecordSID									= @personTextMessageSID
					,@PersonTextMessageRowGUID	= @personTextMessageRowGUID					-- link references may exist so pass GUID on this call

			end

			-- store the populated subject and body into
			-- the message record 

			update
				sf.PersonTextMessage																							-- note: avoid EF #Update for performance!
			set
				 Body					= @bodyText
				,MobilePhone	= @mobilePhone
				,UpdateTime		= sysdatetimeoffset()
				,UpdateUser		= @updateUser
				,ChangeAudit	= sf.fChangeAudit#Comment(N'Queued for sending', ChangeAudit)
			where
				PersonTextMessageSID = @personTextMessageSID
		
			if @JobRunSID is not null
			begin

				-- check if a cancellation request occurred
				-- where job is running in async mode

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

				if @isCancelled = @ON or @i % 5 = 0
				begin

					set @currentProcessLabel	= cast (left(@mobilePhone, 35) as nvarchar(35))									-- PersonTextMessage record being processed

					exec sf.pJobRun#Update
						@JobRunSID						= @JobRunSID
						,@RecordsProcessed		= @i
						,@TotalRecords				= @maxRow
						,@CurrentProcessLabel = @currentProcessLabel
						,@IsCancelled					= @isCancelled

				end

			end

		end

		set @TotalProcessedCount = @i
		set @TotalRowCount = @maxRow

	end try

	begin catch

		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw

	end catch

	return (@errorNo)

end
GO
