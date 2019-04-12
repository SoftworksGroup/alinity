SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonTextMessage#GetNext]
as
/*********************************************************************************************************************************
Sproc    : Person Text Message - Get Next
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Returns text address, subject and body text for next text message to send
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Cory Ng			| Jun	2016			| Initial version
				 : Cory Ng			| Feb 2017			| Updated to check if queued time is now or in the past (to supported scheduled texts)
				 : Tim Edlund		| Aug 2017			| Updated to avoid cancelled items
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------

This procedure is called by the text service to return the next text to send.  The procedure is called in a timing loop to
send text whenever unsent text is available.  Only the next (single text) message is returned.

Text messages must be in a QUEUED status and not scheduled in the future to be retrieved.  Retrieval occurs in priority order
based on priority level and date.  If no texts are available for sending a blank record set is returned.  The record set returned
will have 1 or 0 records only.

When an text is found, its sent time is automatically set to the current time at the server.  If any error is detected in by
the text service in sending the message, the error should be written into the ChangeAudit field with the error message, and
the NotReceived date column should be updated.

Calls during maintenance windows
--------------------------------
As the text service will be down during maintenance, there is no concern about checking for offline status.  Users will still
be able to queue texts while the text service is disabled/stopped.

Example:
--------

<TestHarness>
	<Test Name="Set Recipient List" IsDefault="false" Description="Creates a list of 5 persons and finds an un-queued text
	message.  The recipient list for the ">
		<SQLScript>
		<![CDATA[
		
			declare
				@textMessageSID						int
				,@personList							xml
				,@messageSubscriptionSID	int
				,@mobilePhone							varchar(25)		= '555-555-1111'
				,@body										nvarchar(1600)

			select
				top (1) @personList = cast('<Persons><Person PersonSID="' + cast(p.PersonSID as varchar(10)) + '" /></Persons>' as xml)
			from
				sf.Person p
			where
				p.MobilePhone is not null
	
			select
				top (1) @body = Body, @subject = [Subject], @messageSubscriptionSID = MessageSubscriptionSID
			from
				sf.TextTemplate

			if @mobilePhone is null or @body is null or @personList is null or @messageSubscriptionSID is null
			begin

				raiserror( '** ERROR: insufficient data to run test', 18, 1)

			end
			else
			begin
				exec sf.pTextMessage#Insert
					@TextMEssageSID						= @textMessageSID output
					,@MessageSubscriptionSID	= @messageSubscriptionSID
					,@MobilePhone							= @mobilePhone
					,@Body										= @body
					,@RecipientList						= @personList

				exec sf.pTextMessage#Queue
					@TextMessageSID = @textMessageSID

				waitfor delay '00:00:02'
	
				exec [sf].[pPersonTextMessage#GetNext]

				delete from sf.PersonTextMessage where TextMessageSID = @textMessageSID
				delete from sf.TextMessage where TextMessageSID = @textMessageSID
			end

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="EmptyResultSet" ResultSet="0"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pPersonTextMessage#GetNext'

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo                           int = 0														-- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@updateUser												nvarchar(75)											-- service ID requesting the text (for audit)
		,@now																datetimeoffset(7) = sysdatetimeoffset() -- current date

	declare @message table (personTextMessageSID int)

	begin try

		-- set the ID of the user for audit field

		if isnull(@updateUser, 'x') = N'SystemUser' set @updateUser = left(sf.fConfigParam#Value('SystemUser'),75)										-- override for "SystemUser"
		if isnull(@updateUser, 'x') <> N'SystemUser' set @updateUser = sf.fApplicationUserSession#UserName()													-- application user - or DB user if no application session set

		-- avoid EF sproc to minimize potential for record lock
		-- from another service and to minimize response time

		update
			sf.PersonTextMessage
		set
			 SentTime			= @now
			,UpdateTime		= @now
			,UpdateUser		= @updateUser
			,ChangeAudit	= sf.fChangeAudit#Comment(N'Sent by text service', ChangeAudit)
		output
			inserted.PersonTextMessageSID
		into
			@message
		where
			PersonTextMessageSID =
		(
			select top (1)
				pem.PersonTextMessageSID
			from
				sf.PersonTextMessage	pem
			join
					sf.TextMessage			em on em.TextMessageSID = pem.TextMessageSID
				where
						SentTime			is null
					and
						em.QueuedTime is not null
					and
						em.CancelledTime is null																			-- avoid cancelled items
					and
						isnull(em.QueuedTime, @now) < @now
				order by																													-- priority selection
					 em.PriorityLevel
					,em.CreateTime
					,pem.PersonTextMessageSID
		)

		select
		 --!<ColumnList DataSource="sf.vPersonTextMessage" Alias="ptm">
		  ptm.PersonTextMessageSID
		 ,ptm.PersonSID
		 ,ptm.TextMessageSID
		 ,ptm.MobilePhone
		 ,ptm.SentTime
		 ,ptm.Body
		 ,ptm.NotReceivedNoticeTime
		 ,ptm.ConfirmedTime
		 ,ptm.CancelledTime
		 ,ptm.DeliveredTime
		 ,ptm.ChangeAudit
		 ,ptm.MergeKey
		 ,ptm.TextTriggerSID
		 ,ptm.ServiceMessageID
		 ,ptm.UserDefinedColumns
		 ,ptm.PersonTextMessageXID
		 ,ptm.LegacyKey
		 ,ptm.IsDeleted
		 ,ptm.CreateUser
		 ,ptm.CreateTime
		 ,ptm.UpdateUser
		 ,ptm.UpdateTime
		 ,ptm.RowGUID
		 ,ptm.RowStamp
		 ,ptm.GenderSID
		 ,ptm.NamePrefixSID
		 ,ptm.FirstName
		 ,ptm.CommonName
		 ,ptm.MiddleNames
		 ,ptm.LastName
		 ,ptm.BirthDate
		 ,ptm.DeathDate
		 ,ptm.HomePhone
		 ,ptm.PersonMobilePhone
		 ,ptm.IsTextMessagingEnabled
		 ,ptm.ImportBatch
		 ,ptm.PersonRowGUID
		 ,ptm.SenderPhone
		 ,ptm.SenderDisplayName
		 ,ptm.PriorityLevel
		 ,ptm.TextMessageBody
		 ,ptm.IsApplicationUserRequired
		 ,ptm.TextMessageApplicationUserSID
		 ,ptm.MessageLinkSID
		 ,ptm.LinkExpiryHours
		 ,ptm.ApplicationEntitySID
		 ,ptm.MergedTime
		 ,ptm.QueuedTime
		 ,ptm.TextMessageCancelledTime
		 ,ptm.ArchivedTime
		 ,ptm.TextMessageRowGUID
		 ,ptm.TextTriggerLabel
		 ,ptm.TextTemplateSID
		 ,ptm.QuerySID
		 ,ptm.MinDaysToRepeat
		 ,ptm.TextTriggerApplicationUserSID
		 ,ptm.JobScheduleSID
		 ,ptm.LastStartTime
		 ,ptm.LastEndTime
		 ,ptm.TextTriggerIsActive
		 ,ptm.TextTriggerRowGUID
		 ,ptm.ChangeReason
		 ,ptm.IsDeleteEnabled
		 ,ptm.IsReselected
		 ,ptm.IsNullApplied
		 ,ptm.zContext
		 ,ptm.BodySent
		 ,ptm.MessageLinkExpiryTime
		 ,ptm.ConfirmationLagHours
		 ,ptm.MessageLinkStatusSCD
		 ,ptm.MessageLinkStatusLabel
		 ,ptm.IsPending
		 ,ptm.IsConfirmed
		 ,ptm.IsExpired
		 ,ptm.IsCancelled
		 ,ptm.FileAsName
		 ,ptm.FullName
		 ,ptm.DisplayName
		 ,ptm.AgeInYears
				--!</ColumnList>
			from
				sf.vPersonTextMessage ptm
			join
				@message m on ptm.PersonTextMessageSID = m.personTextMessageSID 			

	end try
	begin catch
		exec @errorNo  = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
