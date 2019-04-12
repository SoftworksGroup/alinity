SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[PersonEmailMessage] (
		[PersonEmailMessageSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]                 [int] NOT NULL,
		[EmailMessageSID]           [int] NOT NULL,
		[EmailAddress]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SelectedTime]              [datetimeoffset](7) NULL,
		[SentTime]                  [datetimeoffset](7) NULL,
		[Subject]                   [nvarchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Body]                      [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EmailDocument]             [varbinary](max) FILESTREAM NULL,
		[FileTypeSID]               [int] NOT NULL,
		[FileTypeSCD]               [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[NotReceivedNoticeTime]     [datetime] NULL,
		[ConfirmedTime]             [datetimeoffset](7) NULL,
		[CancelledTime]             [datetimeoffset](7) NULL,
		[OpenedTime]                [datetimeoffset](7) NULL,
		[ChangeAudit]               [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MergeKey]                  [int] NULL,
		[EmailTriggerSID]           [int] NULL,
		[ServiceMessageID]          [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]        [xml] NULL,
		[PersonEmailMessageXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonEmailMessage_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonEmailMessage]
		PRIMARY KEY
		CLUSTERED
		([PersonEmailMessageSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Email Message table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'CONSTRAINT', N'pk_PersonEmailMessage'
GO
ALTER TABLE [sf].[PersonEmailMessage]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonEmailMessage]
	CHECK
	([sf].[fPersonEmailMessage#Check]([PersonEmailMessageSID],[PersonSID],[EmailMessageSID],[EmailAddress],[SelectedTime],[SentTime],[Subject],[FileTypeSID],[FileTypeSCD],[NotReceivedNoticeTime],[ConfirmedTime],[CancelledTime],[OpenedTime],[MergeKey],[EmailTriggerSID],[ServiceMessageID],[PersonEmailMessageXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[PersonEmailMessage]
CHECK CONSTRAINT [ck_PersonEmailMessage]
GO
ALTER TABLE [sf].[PersonEmailMessage]
	ADD
	CONSTRAINT [df_PersonEmailMessage_FileTypeSCD]
	DEFAULT ('.PDF') FOR [FileTypeSCD]
GO
ALTER TABLE [sf].[PersonEmailMessage]
	ADD
	CONSTRAINT [df_PersonEmailMessage_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[PersonEmailMessage]
	ADD
	CONSTRAINT [df_PersonEmailMessage_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[PersonEmailMessage]
	ADD
	CONSTRAINT [df_PersonEmailMessage_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[PersonEmailMessage]
	ADD
	CONSTRAINT [df_PersonEmailMessage_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[PersonEmailMessage]
	ADD
	CONSTRAINT [df_PersonEmailMessage_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[PersonEmailMessage]
	ADD
	CONSTRAINT [df_PersonEmailMessage_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[PersonEmailMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonEmailMessage_EmailTrigger_EmailTriggerSID]
	FOREIGN KEY ([EmailTriggerSID]) REFERENCES [sf].[EmailTrigger] ([EmailTriggerSID])
ALTER TABLE [sf].[PersonEmailMessage]
	CHECK CONSTRAINT [fk_PersonEmailMessage_EmailTrigger_EmailTriggerSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the email trigger system ID column in the Person Email Message table match a email trigger system ID in the Email Trigger table. It also ensures that records in the Email Trigger table cannot be deleted if matching child records exist in Person Email Message. Finally, the constraint blocks changes to the value of the email trigger system ID column in the Email Trigger if matching child records exist in Person Email Message.', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'CONSTRAINT', N'fk_PersonEmailMessage_EmailTrigger_EmailTriggerSID'
GO
ALTER TABLE [sf].[PersonEmailMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonEmailMessage_FileType_FileTypeSID]
	FOREIGN KEY ([FileTypeSID]) REFERENCES [sf].[FileType] ([FileTypeSID])
ALTER TABLE [sf].[PersonEmailMessage]
	CHECK CONSTRAINT [fk_PersonEmailMessage_FileType_FileTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the file type system ID column in the Person Email Message table match a file type system ID in the File Type table. It also ensures that records in the File Type table cannot be deleted if matching child records exist in Person Email Message. Finally, the constraint blocks changes to the value of the file type system ID column in the File Type if matching child records exist in Person Email Message.', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'CONSTRAINT', N'fk_PersonEmailMessage_FileType_FileTypeSID'
GO
ALTER TABLE [sf].[PersonEmailMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonEmailMessage_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [sf].[PersonEmailMessage]
	CHECK CONSTRAINT [fk_PersonEmailMessage_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Person Email Message table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Person Email Message. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Person Email Message.', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'CONSTRAINT', N'fk_PersonEmailMessage_Person_PersonSID'
GO
ALTER TABLE [sf].[PersonEmailMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonEmailMessage_EmailMessage_EmailMessageSID]
	FOREIGN KEY ([EmailMessageSID]) REFERENCES [sf].[EmailMessage] ([EmailMessageSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[PersonEmailMessage]
	CHECK CONSTRAINT [fk_PersonEmailMessage_EmailMessage_EmailMessageSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the email message system ID column in the Person Email Message table match a email message system ID in the Email Message table. It also ensures that when a record in the Email Message table is deleted, matching child records in the Person Email Message table are deleted as well. Finally, the constraint blocks changes to the value of the email message system ID column in the Email Message if matching child records exist in Person Email Message.', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'CONSTRAINT', N'fk_PersonEmailMessage_EmailMessage_EmailMessageSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonEmailMessage_EmailAddress]
	ON [sf].[PersonEmailMessage] ([EmailAddress])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Person Email Message searches based on the Email Address column', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'INDEX', N'ix_PersonEmailMessage_EmailAddress'
GO
CREATE NONCLUSTERED INDEX [ix_PersonEmailMessage_EmailTriggerSID_PersonEmailMessageSID]
	ON [sf].[PersonEmailMessage] ([EmailTriggerSID], [PersonEmailMessageSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Email Trigger SID foreign key column and avoids row contention on (parent) Email Trigger updates', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'INDEX', N'ix_PersonEmailMessage_EmailTriggerSID_PersonEmailMessageSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonEmailMessage_FileTypeSID_PersonEmailMessageSID]
	ON [sf].[PersonEmailMessage] ([FileTypeSID], [PersonEmailMessageSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the File Type SID foreign key column and avoids row contention on (parent) File Type updates', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'INDEX', N'ix_PersonEmailMessage_FileTypeSID_PersonEmailMessageSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonEmailMessage_LegacyKey]
	ON [sf].[PersonEmailMessage] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'INDEX', N'ux_PersonEmailMessage_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_PersonEmailMessage_PersonSID_PersonEmailMessageSID]
	ON [sf].[PersonEmailMessage] ([PersonSID], [PersonEmailMessageSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'INDEX', N'ix_PersonEmailMessage_PersonSID_PersonEmailMessageSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonEmailMessage_EmailMessageSID]
	ON [sf].[PersonEmailMessage] ([EmailMessageSID])
	INCLUDE ([SentTime], [NotReceivedNoticeTime], [CancelledTime])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Email Message SID foreign key column and avoids row contention on (parent) Email Message updates', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'INDEX', N'ix_PersonEmailMessage_EmailMessageSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonEmailMessage_SentTime_CancelledTime]
	ON [sf].[PersonEmailMessage] ([SentTime], [CancelledTime])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Person Email Message searches based on the Sent Time + Cancelled Time columns', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'INDEX', N'ix_PersonEmailMessage_SentTime_CancelledTime'
GO
CREATE FULLTEXT INDEX ON [sf].[PersonEmailMessage]
	([Subject] LANGUAGE 0, [EmailDocument] TYPE COLUMN [FileTypeSCD] LANGUAGE 0)
	KEY INDEX [pk_PersonEmailMessage]
	ON (FILEGROUP [FullTextIndexData], [ftcDefault])
	WITH CHANGE_TRACKING AUTO, STOPLIST OFF
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the recipient(s) for each Email Message along with a copy of the content which may be customized for that recipient. The table records the key of the Person and also the email address in effect at the time the message is sent. The email address is captured only when the user invokes the “send” action. The Merge Key column is used when merge field replacements are required that are not based on the Person-Email-Message entity itself (e.g. are based on a Patient or Registrant entity).  The value must be set to the system ID value (primary key) of the record related to the user the email is being set for.  Note that the identification of the entity the lookup occurs in is set in the Application Entity SID column in the parent Email Message table.   Regardless of whether or not merge fields are found in the parent Subject/Body content, a copy of the email is stored for each recipient in this table.  Details about the success or failure of email sent are not provided back through the email service so the status column in the parent email record only tracks basic flow from creation through sending.  If information is obtained indicating an email message was not received by a particular recipient that can be tracked in this table using the Not-Received Notice Time.  When this column is set a reason should be recorded in the Change Audit column if known – e.g. “Invalid email address” .  When the email message includes a confirmation link (e.g. a new user invite message), the Confirmed Time column is set when the user clicks the link.  Confirmation links should be set to expire using the lag days column provided in the parent email message (e.g. after 2 days).  To cancel a pending confirmation, the Cancelled Time column is set (which renders the link expired). ', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person email message assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'PersonEmailMessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this email message is based on', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The email message assigned to this person', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'EmailMessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The email address this note was sent to | Set by the application to primary email address when message is queued', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'EmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the email is picked up by the emailing service for processing', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'SelectedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the message was picked up by the email service for sending', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'SentTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Subject of the email note', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'Subject'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Body of the email note (HTML format)', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'Body'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person email message', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'FileTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file extension or type of document the email is stored as | This value must match one of the registered filter types for full-text searching.  The list of document types supported is limited by the master table.  The value includes the leading period - e.g. ".PDF" Note that the default value is updated by an AFTER trigger defined on the table.', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'FileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled in, indicates this email message was not received and records the time the notice of non-receipt was reported', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'NotReceivedNoticeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the user confirmed their invitation', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'ConfirmedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time an administrator revokes the confirmation link', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the email message was opened - requires downloading of "beacon image" by client | This value is not populated if images are not downloaded by the client software. See also: https://en.wikipedia.org/wiki/Web_beacon', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'OpenedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records a brief log of events and status changes for the email', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'ChangeAudit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The system identifier used to locate the source record for processing merge field replacements | Only required where a second data source is required for merging (the "Person" entity is applied as the last data source when merge fields are found)', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'MergeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the email trigger assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'EmailTriggerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier provided by the sending service for the message | Used for calling back to determine status and other auditing/debugging', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'ServiceMessageID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person email message | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'PersonEmailMessageXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person email message | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person email message record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person email message | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person email message record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person email message record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailMessage', 'CONSTRAINT', N'uk_PersonEmailMessage_RowGUID'
GO
ALTER TABLE [sf].[PersonEmailMessage] SET (LOCK_ESCALATION = TABLE)
GO
