SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fEmailMessage#Ext] (@EmailMessageSID int)
returns @emailMessage#Ext table
(
	MessageStatusSCD	 varchar(10)			 null			-- system status code of the message (e.g. SENT) 
 ,MessageStatusLabel nvarchar(35)			 null			-- label for the email message status to present on UI
 ,RecipientCount		 int							 null			-- count of recipients of the message
 ,NotReceivedCount	 int							 null			-- count of recipients marked as non-received
 ,IsQueued					 bit							 not null -- indicates if message is queued (queued time not null)
 ,IsSent						 bit							 not null -- indicates if message is sent to ALL recipients
 ,IsArchived				 bit							 not null -- indicates if message is archived (time not null)
 ,IsPurged					 bit							 not null -- indicates if email document is purged (time not null)
 ,IsCancelled				 bit							 not null -- indicates if the message was stopped from being sent (cancelled time filled in)
 ,IsCancelEnabled		 bit							 not null -- indicates whether the cancellation function can be used (only after queuing)
 ,SentTime					 datetimeoffset(7) null			-- date and time message was sent for first recipient
 ,SentTimeLast			 datetimeoffset(7) null			-- date and time message was sent for last recipient
 ,QueuingTime				 datetimeoffset(7) null			-- date and time message job was started to queue message
 ,SentCount					 int							 null			-- count of recipients message was sent for
 ,NotSentCount			 int							 null			-- count of recipients message is not sent for
 ,IsEditEnabled			 bit							 not null -- indicates if content or recipients of email can be changed
 ,IsLinkEmbedded		 bit							 not null -- tracks whether email contains a confirmation page URL
)
as
/*********************************************************************************************************************************
TableF	: EmailMessage - Extended Columns
Notice  : Copyright © 2015 Softworks Group Inc.
Summary	: Returns a table of calculated columns for the EmailMessage extended view (vEmailMessage#Ext)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  					| Month Year		| Change Summary
				: --------------------+---------------+-----------------------------------------------------------------------------------
				: Tim Edlund					| Apr	2015			|	Initial Version
				: Richard K						| Aug 2015			| Added column QueuingTime to return, used to determine if job already running
 				: Tim Edlund          | Oct 2018			|	Updated to include IsPurged bit based on time value
				: Taylor Napier				| Apr 2019			| Updated to allow cancelling messages that are still in the process of merging

Comments	
--------
This function is called by the dbo.vEmailMessage#Ext view to return a series of calculated columns.  This function is not intended 
for other purposes and has been designed to emphasize performance over flexibility for other uses.  By using a table function,
many lookups required for the calculated values can be executed once rather than many times if separate functions are used.

Calculations which also provide data back to the #Ext view, but which use completely independent values are NOT included in this
function.

Example
-------

select top (1)
	 em.EmailMessageSID
	,em.Subject
	,emx.*
from 
	sf.EmailMessage em
outer apply
	sf.fEmailMessage#Ext(em.EmailMessageSID) emx

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@ON									bit = cast(1 as bit)	-- a constant to reduce repetitive cast syntax in bit comparisons
	 ,@OFF								bit = cast(0 as bit)	-- a constant to reduce repetitive cast syntax in bit comparisons
	 ,@messageStatusSCD		varchar(10)						-- system status code of the message (e.g. SENT) 
	 ,@messageStatusLabel nvarchar(35)					-- label for the email message status to present on UI
	 ,@recipientCount			int										-- count of recipients of the message
	 ,@notReceivedCount		int										-- count of recipients marked as non-received
	 ,@isGenerateOnly			bit										-- indicates if the message should be saved but not emailed out
	 ,@isQueued						bit										-- indicates if message is queued (queued time not null)
	 ,@isSent							bit										-- indicates if message is sent (sent time not null)
	 ,@isArchived					bit										-- indicates if message is archived (time not null)
	 ,@isPurged						bit										-- indicates if email document is purged (time not null)
	 ,@isCancelled				bit										-- indicates if the message was stopped from being sent (cancelled time filled in)
	 ,@isCancelEnabled		bit										-- indicates whether the cancellation function can be used (only after queuing)
	 ,@sentTime						datetimeoffset(7)			-- date and time message was sent for first recipient
	 ,@sentTimeLast				datetimeoffset(7)			-- date and time message was sent for last recipient
	 ,@sentCount					int										-- count of recipients message was sent for
	 ,@notSentCount				int										-- count of recipients message is not sent for
	 ,@cancelledCount			int										-- count of recipient messages in cancelled status
	 ,@queuedTime					datetimeoffset(7)			-- status times from record					
	 ,@queuingTime				datetimeoffset(7)
	 ,@mergedTime					datetimeoffset(7)
	 ,@archivedTime				datetimeoffset(7)
	 ,@isEditEnabled			bit										-- indicates if content or recipients of email can be changed
	 ,@isLinkEmbedded			bit										-- tracks whether email contains a confirmation page URL

	-- get counts from related recipients

	select
		@sentTime					= min(pem.SentTime)
	 ,@sentTimeLast			= max(pem.SentTime)
	 ,@recipientCount		= count(1)
	 ,@notReceivedCount = sum(case when pem.NotReceivedNoticeTime is not null then 1 else 0 end)
	 ,@sentCount				= sum(case when pem.SentTime is not null then 1 else 0 end)
	 ,@notSentCount			= sum(case when pem.SentTime is not null then 0 else 1 end)
	 ,@cancelledCount		= sum(case when pem.CancelledTime is not null then 1 else 0 end)
	from
		sf.PersonEmailMessage pem
	where
		pem.EmailMessageSID = @EmailMessageSID;

	-- determine status

	select
		@queuedTime			 = em.QueuedTime
	 ,@mergedTime			 = em.MergedTime
	 ,@archivedTime		 = em.ArchivedTime
	 ,@isQueued				 = (case when em.QueuedTime is null then @OFF else @ON end)
	 ,@isArchived			 = (case when em.ArchivedTime is null then @OFF else @ON end)
	 ,@isPurged				 = (case when em.PurgedTime is null then @OFF else @ON end)
	 ,@isCancelled		 = (case when em.CancelledTime is null then @OFF else @ON end)
	 ,@isLinkEmbedded	 = (case when em.MessageLinkSID is null then @OFF else @ON end)
	 ,@isGenerateOnly	 = em.IsGenerateOnly
	from
		sf.EmailMessage em
	where
		em.EmailMessageSID = @EmailMessageSID;

	-- if the queued time is not set, check if there is a job running
	-- to queue this message.  If there is we return the time the job
	-- started

	if @queuedTime is null
	begin

		select
			@queuingTime = jr.CreateTime
		from
			sf.Job		j
		join
			sf.JobRun jr on j.JobSID = jr.JobSID
		where
			j.JobSCD = 'sf.pEmailMessage#Queue' and jr.CallSyntax like '%@EmailMessageSID%=%' + cast(@EmailMessageSID as nvarchar(max)) and jr.EndTime is null;

	end;

	select
		@messageStatusSCD		= ems.MessageStatusSCD
	 ,@messageStatusLabel = ems.MessageStatusLabel
	from
		sf.MessageStatus ems
	where
		ems.MessageStatusSCD = (case
															when @cancelledCount = @recipientCount then 'CANCELLED'
															when @isPurged = @ON then 'PURGED'
															when @archivedTime is not null then 'ARCHIVED'
															when @isCancelled = @ON and @cancelledCount < @recipientCount then 'PARTIAL'
															when @sentTime is not null and @isGenerateOnly = @ON then 'GENERATED'
															when @sentTime is not null then 'SENT'
															when @queuingTime is not null then 'QUEUING' -- indicates records are in process of being queued | editing
															when @queuedTime is not null then 'QUEUED'
															when @mergedTime is not null then 'MERGING'	 -- indicates records are in process | no editing!
															else 'DRAFT'
														end
													 );

	set @isSent = (case when @notSentCount > 0 then @OFF else @ON end);
	set @isEditEnabled = (case when @messageStatusSCD = 'DRAFT' then @ON else @OFF end);

	-- allow cancelling of the message if the message
	-- is marked to be sent, and there are still some to send

	set @isCancelEnabled = (case
														when @isCancelled = @OFF and @isArchived = @OFF and @mergedTime is not null and @notSentCount > 0 then @ON
														else @OFF
													end
												 );

	-- update the return table with values calculated

	insert
		@emailMessage#Ext
	(
		MessageStatusSCD
	 ,MessageStatusLabel
	 ,RecipientCount
	 ,NotReceivedCount
	 ,IsQueued
	 ,IsSent
	 ,IsArchived
	 ,IsPurged
	 ,IsCancelled
	 ,IsCancelEnabled
	 ,SentTime
	 ,SentTimeLast
	 ,QueuingTime
	 ,SentCount
	 ,NotSentCount
	 ,IsEditEnabled
	 ,IsLinkEmbedded
	)
	select
		@messageStatusSCD
	 ,@messageStatusLabel
	 ,@recipientCount
	 ,@notReceivedCount
	 ,isnull(@isQueued, @OFF)
	 ,isnull(@isSent, @OFF)
	 ,isnull(@isArchived, @OFF)
	 ,isnull(@isPurged, @OFF)
	 ,isnull(@isCancelled, @OFF)
	 ,isnull(@isCancelEnabled, @OFF)
	 ,@sentTime
	 ,@sentTimeLast
	 ,@queuingTime
	 ,@sentCount
	 ,@notSentCount
	 ,isnull(@isEditEnabled, @OFF)
	 ,isnull(@isLinkEmbedded, @OFF);

	return;

end;
GO
