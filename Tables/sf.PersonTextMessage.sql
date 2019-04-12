SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[PersonTextMessage] (
		[PersonTextMessageSID]      [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]                 [int] NOT NULL,
		[TextMessageSID]            [int] NOT NULL,
		[MobilePhone]               [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SentTime]                  [datetimeoffset](7) NULL,
		[Body]                      [nvarchar](1600) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NotReceivedNoticeTime]     [datetime] NULL,
		[ConfirmedTime]             [datetimeoffset](7) NULL,
		[CancelledTime]             [datetimeoffset](7) NULL,
		[DeliveredTime]             [datetimeoffset](7) NULL,
		[ChangeAudit]               [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MergeKey]                  [int] NULL,
		[TextTriggerSID]            [int] NULL,
		[ServiceMessageID]          [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]        [xml] NULL,
		[PersonTextMessageXID]      [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonTextMessage_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PersonTextMessage_TextMessageSID_PersonSID_NotReceivedNoticeTime]
		UNIQUE
		NONCLUSTERED
		([TextMessageSID], [PersonSID], [NotReceivedNoticeTime])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonTextMessage]
		PRIMARY KEY
		CLUSTERED
		([PersonTextMessageSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Text Message table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'CONSTRAINT', N'pk_PersonTextMessage'
GO
ALTER TABLE [sf].[PersonTextMessage]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonTextMessage]
	CHECK
	([sf].[fPersonTextMessage#Check]([PersonTextMessageSID],[PersonSID],[TextMessageSID],[MobilePhone],[SentTime],[Body],[NotReceivedNoticeTime],[ConfirmedTime],[CancelledTime],[DeliveredTime],[MergeKey],[TextTriggerSID],[ServiceMessageID],[PersonTextMessageXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[PersonTextMessage]
CHECK CONSTRAINT [ck_PersonTextMessage]
GO
ALTER TABLE [sf].[PersonTextMessage]
	ADD
	CONSTRAINT [df_PersonTextMessage_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[PersonTextMessage]
	ADD
	CONSTRAINT [df_PersonTextMessage_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[PersonTextMessage]
	ADD
	CONSTRAINT [df_PersonTextMessage_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[PersonTextMessage]
	ADD
	CONSTRAINT [df_PersonTextMessage_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[PersonTextMessage]
	ADD
	CONSTRAINT [df_PersonTextMessage_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[PersonTextMessage]
	ADD
	CONSTRAINT [df_PersonTextMessage_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[PersonTextMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonTextMessage_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [sf].[PersonTextMessage]
	CHECK CONSTRAINT [fk_PersonTextMessage_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Person Text Message table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Person Text Message. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Person Text Message.', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'CONSTRAINT', N'fk_PersonTextMessage_Person_PersonSID'
GO
ALTER TABLE [sf].[PersonTextMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonTextMessage_TextMessage_TextMessageSID]
	FOREIGN KEY ([TextMessageSID]) REFERENCES [sf].[TextMessage] ([TextMessageSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[PersonTextMessage]
	CHECK CONSTRAINT [fk_PersonTextMessage_TextMessage_TextMessageSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the text message system ID column in the Person Text Message table match a text message system ID in the Text Message table. It also ensures that when a record in the Text Message table is deleted, matching child records in the Person Text Message table are deleted as well. Finally, the constraint blocks changes to the value of the text message system ID column in the Text Message if matching child records exist in Person Text Message.', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'CONSTRAINT', N'fk_PersonTextMessage_TextMessage_TextMessageSID'
GO
ALTER TABLE [sf].[PersonTextMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonTextMessage_TextTrigger_TextTriggerSID]
	FOREIGN KEY ([TextTriggerSID]) REFERENCES [sf].[TextTrigger] ([TextTriggerSID])
ALTER TABLE [sf].[PersonTextMessage]
	CHECK CONSTRAINT [fk_PersonTextMessage_TextTrigger_TextTriggerSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the text trigger system ID column in the Person Text Message table match a text trigger system ID in the Text Trigger table. It also ensures that records in the Text Trigger table cannot be deleted if matching child records exist in Person Text Message. Finally, the constraint blocks changes to the value of the text trigger system ID column in the Text Trigger if matching child records exist in Person Text Message.', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'CONSTRAINT', N'fk_PersonTextMessage_TextTrigger_TextTriggerSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonTextMessage_LegacyKey]
	ON [sf].[PersonTextMessage] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'INDEX', N'ux_PersonTextMessage_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_PersonTextMessage_PersonSID_PersonTextMessageSID]
	ON [sf].[PersonTextMessage] ([PersonSID], [PersonTextMessageSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'INDEX', N'ix_PersonTextMessage_PersonSID_PersonTextMessageSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonTextMessage_TextTriggerSID_PersonTextMessageSID]
	ON [sf].[PersonTextMessage] ([TextTriggerSID], [PersonTextMessageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Text Trigger SID foreign key column and avoids row contention on (parent) Text Trigger updates', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'INDEX', N'ix_PersonTextMessage_TextTriggerSID_PersonTextMessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the recipient(s) for each Text Message along with a copy of the content which may be customized for that recipient. The table records the key of the Person and also the mobile phone in effect at the time the message is sent. The phone is captured only when the user invokes the “send” action. The Merge Key column is used when merge field replacements are required that are not based on the Person-Text-Message entity itself (e.g. are based on a Patient or Registrant entity).  The value must be set to the system ID value (primary key) of the record related to the user the text is being set for.  Note that the identification of the entity the lookup occurs in is set in the Application Entity SID column in the parent Text Message table.   Regardless of whether or not merge fields are found in the parent, Body content, a copy of the text is stored for each recipient in this table.  Details about the success or failure of text sent are not provided back through the text service so the status column in the parent text record only tracks basic flow from creation through sending.  If information is obtained indicating an text message was not received by a particular recipient that can be tracked in this table using the Not-Received Notice Time.  When this column is set a reason should be recorded in the Change Audit column if known – e.g. “Invalid text phone” .  When the text message includes a confirmation link (e.g. a new user invite message), the Confirmed Time column is set when the user clicks the link.  Confirmation links should be set to expire using the lag days column provided in the parent text message (e.g. after 2 days).  To cancel a pending confirmation, the Cancelled Time column is set (which renders the link expired). ', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person text message assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'PersonTextMessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this text message is based on', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The text message assigned to this person', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'TextMessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The text phone this note was sent to | Set by the application to primary text phone when message is queued', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'MobilePhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this message was sent by the text service to this recipient', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'SentTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Body of the text note (HTML format)', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'Body'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled in, indicates this text message was not received and records the time the notice of non-receipt was reported', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'NotReceivedNoticeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the user confirmed their invitation', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'ConfirmedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time an administrator revokes the confirmation link', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the text message was opened - requires downloading of "beacon image" by client | This value is not populated if images are not downloaded by the client software. See also: https://en.wikipedia.org/wiki/Web_beacon', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'DeliveredTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records a brief log of events and status changes for the text', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'ChangeAudit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The system identifier used to locate the source record for processing merge field replacements | Only required where a second data source is required for merging (the "Person" entity is applied as the last data source when merge fields are found)', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'MergeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the text message trigger assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'TextTriggerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier provided by the sending service for the message | Used for calling back to determine status and other auditing/debugging', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'ServiceMessageID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person text message | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'PersonTextMessageXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person text message | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person text message record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person text message | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person text message record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person text message record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'CONSTRAINT', N'uk_PersonTextMessage_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Text Message SID + Person SID + Not Received Notice Time" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'PersonTextMessage', 'CONSTRAINT', N'uk_PersonTextMessage_TextMessageSID_PersonSID_NotReceivedNoticeTime'
GO
ALTER TABLE [sf].[PersonTextMessage] SET (LOCK_ESCALATION = TABLE)
GO
