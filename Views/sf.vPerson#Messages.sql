SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vPerson#Messages]
as
/*********************************************************************************************************************************
View			: Person - Messages
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Returns a dataset with all emails and text messages.
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Cory Ng			| Jun 2016		|	Initial version
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view combines all email and text messages and returns them as one dataset using the UNION operator. The view is used on the
person details UI which shows all messages sent to the person. The body of the email and text message is left out of this view
to reduce the amount of data sent to the client when populating the list.

Example
-------
<TestHarness>
<Test Name = "Simple" IsDefault="true" Description="Gets the messages for a person at random that has at least 1 email message.">
<SQLScript>
<![CDATA[

		declare
			@personSID int

		select
			@personSID = pem.PersonSID
		from
			sf.PersonEmailMessage pem
		order by
			newid()
		
		select
			 x.*
		from
			sf.vPerson#Messages x
		where
			x.PersonSID = @personSID
]]>
</SQLScript>
<Assertions>
	<Assertion Type="ExecutionTime" Value="00:00:02" />
</Assertions>
</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vPerson#Messages'
-------------------------------------------------------------------------------------------------------------------------------- */
select
	 isnull(row_number() over (order by pm.PersonSID), -1) RowNumber										-- EF requires column with unique values
	,pm.PersonSID
	,pm.RecordSID
	,pm.EmailAddress
	,pm.MobilePhone
	,pm.SentTime
	,pm.[Subject]
	,pm.NotReceivedNoticeTime
	,pm.ConfirmedTime
	,pm.CancelledTime
	,pm.OpenedTime
	,pm.ChangeAudit
	,pm.MessageType
from
(
	select
		 pem.PersonSID
		,pem.PersonEmailMessageSID			RecordSID
		,pem.EmailAddress																
		,null														MobilePhone
		,pem.SentTime
		,pem.[Subject]
		,pem.NotReceivedNoticeTime
		,pem.ConfirmedTime
		,pem.CancelledTime
		,pem.OpenedTime
		,pem.ChangeAudit
		,'EMAIL'												MessageType
	from
		sf.PersonEmailMessage pem
	union
	select
		 ptm.PersonSID
		,ptm.PersonTextMessageSID				RecordSID
		,null														EmailAddress
		,ptm.MobilePhone						
		,ptm.SentTime
		,null														[Subject]
		,ptm.NotReceivedNoticeTime
		,ptm.ConfirmedTime
		,ptm.CancelledTime
		,null														OpenTime
		,ptm.ChangeAudit
		,'TEXT'													MessageType
	from
		sf.PersonTextMessage ptm
) pm
GO
