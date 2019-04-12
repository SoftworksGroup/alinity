SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fPersonTextMessage#Ext]
(
	@PersonTextMessageSID									int
)
returns @personTextMessage#Ext	table
(
	 MessageLinkExpiryTime									datetimeoffset(7)											-- date and time the confirmation link on the text expires
	,ConfirmationLagHours										int																		-- hours between time the text was sent and the confirmation link was clicked (the hours waiting for user to confirm)
	,MessageLinkStatusSCD										varchar(10)														-- code identifying status of the link in the text (if any) | If the value is "?", then the value of the derived status code was not found in the master table
	,MessageLinkStatusLabel									nvarchar(35)													-- label identifying status of the link in the text (if any) | If the value is "?", then the value of the derived status code was not found in the master table
	,IsPending															bit																		-- indicates whether the link is still waiting for confirmation from the user ("pending" and not cancelled)
	,IsConfirmed														bit																		-- indicates whether the link has been accepted by the user resulting in creation of a user profile ("confirmed" status)
	,IsExpired															bit																		-- indicates whether the reserve period on the link has ended ("expired" status)
	,IsCancelled														bit																		-- indicates whether this link was revoked so that it can no longer be confirmed ("cancelled" status)
)
as
/*********************************************************************************************************************************
TableF	: PersonTextMessage - Extended Columns
Notice  : Copyright © 2015 Softworks Group Inc.
Summary	: Returns a table of calculated columns for the PersonTextMessage extended view (vPersonTextMessage#Ext)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | Jun	2016			|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is called by the dbo.vPersonTextMessage#Ext view to return a series of calculated columns.  This function is not 
intended for other purposes and has been designed to emphasize performance over flexibility for other uses.  By using a table 
function, many lookups required for the calculated values can be executed once rather than many times if separate functions are 
used.

Calculations which also provide data back to the #Ext view, but which use completely independent values are NOT included in this
function.

Example
-------

select top (1)
	 em.PersonTextMessageSID
	,em.Subject
	,emx.*
from 
	sf.PersonTextMessage em
outer apply
	sf.fPersonTextMessage#Ext(em.PersonTextMessageSID) emx

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @ON                              bit = cast(1 as bit)								-- a constant to reduce repetitive cast syntax in bit comparisons
		,@OFF                             bit = cast(0 as bit)								-- a constant to reduce repetitive cast syntax in bit comparisons
		,@messageLinkExpiryTime						datetimeoffset(7)										-- date and time the confirmation link on the text expires
		,@confirmationLagHours						int																	-- hours between time the text was sent and the confirmation link was clicked (the hours waiting for user to confirm)
		,@messageLinkStatusSCD						varchar(10)													-- code identifying status of the link in the text (if any) 
		,@messageLinkStatusLabel					nvarchar(35)												-- label identifying status of the link in the text (if any)
		,@isPending												bit																	-- indicates whether the link is still waiting for confirmation from the user ("pending" and not cancelled)
		,@isConfirmed											bit																	-- indicates whether the link has been accepted by the user resulting in creation of a user profile ("confirmed" status)
		,@isExpired												bit																	-- indicates whether the reserve period on the link has ended ("expired" status)
		,@isCancelled											bit																	-- indicates whether this link was revoked so that it can no longer be confirmed ("cancelled" status)
		,@confirmedTime										datetimeoffset(7)										-- tracks date and time link in text was confirmed
		,@cancelledTime										datetimeoffset(7)										-- tracks date and time link in text was cancelled
		,@personSID												int																	-- key of person text was sent to
		,@isLinkEmbedded									bit																	-- tracks whether text contains a link 

	-- get status

	select 
		 @messageLinkExpiryTime	 = isnull(pem.CancelledTime, dateadd(hour, em.LinkExpiryHours, pem.SentTime))
		,@confirmationLagHours = datediff(hour,pem.SentTime, pem.ConfirmedTime)
		,@confirmedTime				 = pem.ConfirmedTime
		,@cancelledTime				 = pem.CancelledTime
		,@personSID						 = pem.PersonSID
		,@isLinkEmbedded			 = (case when em.MessageLinkSID is null then @OFF else @ON end)
	from
		sf.PersonTextMessage pem
	join
		sf.TextMessage				em on pem.TextMessageSID = em.TextMessageSID
	where
		pem.PersonTextMessageSID = @PersonTextMessageSID

	set @messageLinkStatusSCD =
		cast
		(		
			case
				when @isLinkEmbedded = @OFF												then null
				when @cancelledTime	is not null										then 'CANCELLED'																					
				when @confirmedTime	is not null										then 'CONFIRMED'
				when @messageLinkExpiryTime < sysdatetimeoffset() then 'EXPIRED'
				else 'PENDING'
			end
		as varchar(10)
		)

	set @isPending		= cast(case when @messageLinkStatusSCD = 'PENDING'		then 1 else 0 end as bit)
	set @isConfirmed	= cast(case when @messageLinkStatusSCD = 'CONFIRMED'	then 1 else 0 end as bit)
	set	@isExpired		= cast(case when @messageLinkStatusSCD = 'EXPIRED'		then 1 else 0 end as bit)
	set	@isCancelled	= cast(case when @messageLinkStatusSCD = 'CANCELLED'	then 1 else 0 end as bit)

	if @isLinkEmbedded = @ON
	begin

		select
			@messageLinkStatusLabel = els.MessageLinkStatusLabel
		from
			sf.MessageLinkStatus els
		where
			els.MessageLinkStatusSCD = @messageLinkStatusSCD

	end

	-- update the return table with values calculated

	insert 
		@personTextMessage#Ext
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
		,@isPending							
		,@isConfirmed						
		,@isExpired
		,@isCancelled

	return

end
GO
