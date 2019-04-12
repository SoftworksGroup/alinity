SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fPersonEmailMessage#Ext] (@PersonEmailMessageSID int)
returns @personEmailMessage#Ext table
(
	MessageLinkExpiryTime	 datetimeoffset(7) null			-- date and time the confirmation link on the email expires
 ,ConfirmationLagHours	 int							 null			-- hours between time the email was sent and the confirmation link was clicked (the hours waiting for user to confirm)
 ,MessageLinkStatusSCD	 varchar(10)			 null			-- code identifying status of the link in the email (if any) | If the value is "?", then the value of the derived status code was not found in the master table
 ,MessageLinkStatusLabel nvarchar(35)			 null			-- label identifying status of the link in the email (if any) | If the value is "?", then the value of the derived status code was not found in the master table
 ,IsPending							 bit							 not null -- indicates whether the link is still waiting for confirmation from the user ("pending" and not cancelled)
 ,IsConfirmed						 bit							 not null -- indicates whether the link has been accepted by the user resulting in creation of a user profile ("confirmed" status)
 ,IsExpired							 bit							 not null -- indicates whether the reserve period on the link has ended ("expired" status)
 ,IsCancelled						 bit							 not null -- indicates whether this link was revoked so that it can no longer be confirmed ("cancelled" status)
)
as
/*********************************************************************************************************************************
TableF	: PersonEmailMessage - Extended Columns
Notice  : Copyright © 2015 Softworks Group Inc.
Summary	: Returns a table of calculated columns for the PersonEmailMessage extended view (vPersonEmailMessage#Ext)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  					| Month Year		| Change Summary
				: --------------------+---------------|-----------------------------------------------------------------------------------
				: Tim Edlund					| Apr	2015			|	Initial Version

Comments	
--------
This function is called by the dbo.vPersonEmailMessage#Ext view to return a series of calculated columns.  This function is not 
intended for other purposes and has been designed to emphasize performance over flexibility for other uses.  By using a table 
function, many lookups required for the calculated values can be executed once rather than many times if separate functions are 
used.

Calculations which also provide data back to the #Ext view, but which use completely independent values are NOT included in this
function.

Example
-------

select top (1)
	 em.PersonEmailMessageSID
	,em.Subject
	,emx.*
from 
	sf.PersonEmailMessage em
outer apply
	sf.fPersonEmailMessage#Ext(em.PersonEmailMessageSID) emx

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@ON											bit = cast(1 as bit)	-- a constant to reduce repetitive cast syntax in bit comparisons
	 ,@OFF										bit = cast(0 as bit)	-- a constant to reduce repetitive cast syntax in bit comparisons
	 ,@messageLinkExpiryTime	datetimeoffset(7)			-- date and time the confirmation link on the email expires
	 ,@confirmationLagHours		int										-- hours between time the email was sent and the confirmation link was clicked (the hours waiting for user to confirm)
	 ,@messageLinkStatusSCD		varchar(10)						-- code identifying status of the link in the email (if any) 
	 ,@messageLinkStatusLabel nvarchar(35)					-- label identifying status of the link in the email (if any)
	 ,@isPending							bit										-- indicates whether the link is still waiting for confirmation from the user ("pending" and not cancelled)
	 ,@isConfirmed						bit										-- indicates whether the link has been accepted by the user resulting in creation of a user profile ("confirmed" status)
	 ,@isExpired							bit										-- indicates whether the reserve period on the link has ended ("expired" status)
	 ,@isCancelled						bit										-- indicates whether this link was revoked so that it can no longer be confirmed ("cancelled" status)
	 ,@confirmedTime					datetimeoffset(7)			-- tracks date and time link in email was confirmed
	 ,@cancelledTime					datetimeoffset(7)			-- tracks date and time link in email was cancelled
	 ,@isLinkEmbedded					bit										-- tracks whether email contains a link 

	select
		@messageLinkExpiryTime = isnull(pem.CancelledTime, dateadd(hour, em.LinkExpiryHours, pem.SentTime))
	 ,@confirmationLagHours	 = datediff(hour, pem.SentTime, pem.ConfirmedTime)
	 ,@confirmedTime				 = pem.ConfirmedTime
	 ,@cancelledTime				 = pem.CancelledTime
	 ,@isLinkEmbedded				 = (case when em.MessageLinkSID is null then @OFF else @ON end)
	from
		sf.PersonEmailMessage pem
	join
		sf.EmailMessage				em on pem.EmailMessageSID = em.EmailMessageSID
	where
		pem.PersonEmailMessageSID = @PersonEmailMessageSID;

	set @messageLinkStatusSCD = cast(case
																		 when @isLinkEmbedded = @OFF then null
																		 when @cancelledTime is not null then 'CANCELLED'
																		 when @confirmedTime is not null then 'CONFIRMED'
																		 when @messageLinkExpiryTime < sysdatetimeoffset() then 'EXPIRED'
																		 else 'PENDING'
																	 end as varchar(10));

	set @isPending = (case when @messageLinkStatusSCD = 'PENDING' then @ON else @OFF end);
	set @isConfirmed = (case when @messageLinkStatusSCD = 'CONFIRMED' then @ON else @OFF end);
	set @isExpired = (case when @messageLinkStatusSCD = 'EXPIRED' then @ON else @OFF end);
	set @isCancelled = (case when @messageLinkStatusSCD = 'CANCELLED' then @ON else @OFF end);

	if @isLinkEmbedded = @ON
	begin

		select
			@messageLinkStatusLabel = els.MessageLinkStatusLabel
		from
			sf.MessageLinkStatus els
		where
			els.MessageLinkStatusSCD = @messageLinkStatusSCD;

	end;

	-- update the return table with values calculated

	insert
		@personEmailMessage#Ext
	(
		MessageLinkExpiryTime
	 ,ConfirmationLagHours
	 ,MessageLinkStatusSCD
	 ,MessageLinkStatusLabel
	 ,IsPending
	 ,IsConfirmed
	 ,IsExpired
	 ,IsCancelled
	)
	select
		@messageLinkExpiryTime
	 ,@confirmationLagHours
	 ,@messageLinkStatusSCD
	 ,@messageLinkStatusLabel
	 ,isnull(@isPending, @OFF)
	 ,isnull(@isConfirmed, @OFF)
	 ,isnull(@isExpired, @OFF)
	 ,isnull(@isCancelled, @OFF)

	return;

end;
GO
