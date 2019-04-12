SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[EmailMessage] (
		[EmailMessageSID]               [int] IDENTITY(1000001, 1) NOT NULL,
		[SenderEmailAddress]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SenderDisplayName]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PriorityLevel]                 [tinyint] NOT NULL,
		[Subject]                       [nvarchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Body]                          [varbinary](max) NOT NULL,
		[FileTypeSCD]                   [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FileTypeSID]                   [int] NOT NULL,
		[RecipientList]                 [xml] NOT NULL,
		[IsApplicationUserRequired]     [bit] NOT NULL,
		[ApplicationUserSID]            [int] NULL,
		[MessageLinkSID]                [int] NULL,
		[LinkExpiryHours]               [int] NOT NULL,
		[ApplicationEntitySID]          [int] NULL,
		[ApplicationGrantSID]           [int] NULL,
		[IsGenerateOnly]                [bit] NOT NULL,
		[MergedTime]                    [datetimeoffset](7) NULL,
		[QueuedTime]                    [datetimeoffset](7) NULL,
		[CancelledTime]                 [datetimeoffset](7) NULL,
		[ArchivedTime]                  [datetimeoffset](7) NULL,
		[PurgedTime]                    [datetimeoffset](7) NULL,
		[UserDefinedColumns]            [xml] NULL,
		[EmailMessageXID]               [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_EmailMessage_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_EmailMessage]
		PRIMARY KEY
		CLUSTERED
		([EmailMessageSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Email Message table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'CONSTRAINT', N'pk_EmailMessage'
GO
ALTER TABLE [sf].[EmailMessage]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_EmailMessage]
	CHECK
	([sf].[fEmailMessage#Check]([EmailMessageSID],[SenderEmailAddress],[SenderDisplayName],[PriorityLevel],[Subject],[FileTypeSCD],[FileTypeSID],[IsApplicationUserRequired],[ApplicationUserSID],[MessageLinkSID],[LinkExpiryHours],[ApplicationEntitySID],[ApplicationGrantSID],[IsGenerateOnly],[MergedTime],[QueuedTime],[CancelledTime],[ArchivedTime],[PurgedTime],[EmailMessageXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[EmailMessage]
CHECK CONSTRAINT [ck_EmailMessage]
GO
ALTER TABLE [sf].[EmailMessage]
	ADD
	CONSTRAINT [df_EmailMessage_PriorityLevel]
	DEFAULT ((5)) FOR [PriorityLevel]
GO
ALTER TABLE [sf].[EmailMessage]
	ADD
	CONSTRAINT [df_EmailMessage_FileTypeSCD]
	DEFAULT ('.HTML') FOR [FileTypeSCD]
GO
ALTER TABLE [sf].[EmailMessage]
	ADD
	CONSTRAINT [df_EmailMessage_RecipientList]
	DEFAULT (CONVERT([xml],N'<Recipients />')) FOR [RecipientList]
GO
ALTER TABLE [sf].[EmailMessage]
	ADD
	CONSTRAINT [df_EmailMessage_IsApplicationUserRequired]
	DEFAULT ((0)) FOR [IsApplicationUserRequired]
GO
ALTER TABLE [sf].[EmailMessage]
	ADD
	CONSTRAINT [df_EmailMessage_LinkExpiryHours]
	DEFAULT ((24)) FOR [LinkExpiryHours]
GO
ALTER TABLE [sf].[EmailMessage]
	ADD
	CONSTRAINT [df_EmailMessage_IsGenerateOnly]
	DEFAULT (CONVERT([bit],(0))) FOR [IsGenerateOnly]
GO
ALTER TABLE [sf].[EmailMessage]
	ADD
	CONSTRAINT [df_EmailMessage_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[EmailMessage]
	ADD
	CONSTRAINT [df_EmailMessage_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[EmailMessage]
	ADD
	CONSTRAINT [df_EmailMessage_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[EmailMessage]
	ADD
	CONSTRAINT [df_EmailMessage_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[EmailMessage]
	ADD
	CONSTRAINT [df_EmailMessage_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[EmailMessage]
	ADD
	CONSTRAINT [df_EmailMessage_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[EmailMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailMessage_ApplicationEntity_ApplicationEntitySID]
	FOREIGN KEY ([ApplicationEntitySID]) REFERENCES [sf].[ApplicationEntity] ([ApplicationEntitySID])
ALTER TABLE [sf].[EmailMessage]
	CHECK CONSTRAINT [fk_EmailMessage_ApplicationEntity_ApplicationEntitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application entity system ID column in the Email Message table match a application entity system ID in the Application Entity table. It also ensures that records in the Application Entity table cannot be deleted if matching child records exist in Email Message. Finally, the constraint blocks changes to the value of the application entity system ID column in the Application Entity if matching child records exist in Email Message.', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'CONSTRAINT', N'fk_EmailMessage_ApplicationEntity_ApplicationEntitySID'
GO
ALTER TABLE [sf].[EmailMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailMessage_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
ALTER TABLE [sf].[EmailMessage]
	CHECK CONSTRAINT [fk_EmailMessage_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Email Message table match a application user system ID in the Application User table. It also ensures that records in the Application User table cannot be deleted if matching child records exist in Email Message. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Email Message.', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'CONSTRAINT', N'fk_EmailMessage_ApplicationUser_ApplicationUserSID'
GO
ALTER TABLE [sf].[EmailMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailMessage_MessageLink_MessageLinkSID]
	FOREIGN KEY ([MessageLinkSID]) REFERENCES [sf].[MessageLink] ([MessageLinkSID])
ALTER TABLE [sf].[EmailMessage]
	CHECK CONSTRAINT [fk_EmailMessage_MessageLink_MessageLinkSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the message link system ID column in the Email Message table match a message link system ID in the Message Link table. It also ensures that records in the Message Link table cannot be deleted if matching child records exist in Email Message. Finally, the constraint blocks changes to the value of the message link system ID column in the Message Link if matching child records exist in Email Message.', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'CONSTRAINT', N'fk_EmailMessage_MessageLink_MessageLinkSID'
GO
ALTER TABLE [sf].[EmailMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailMessage_FileType_FileTypeSID]
	FOREIGN KEY ([FileTypeSID]) REFERENCES [sf].[FileType] ([FileTypeSID])
ALTER TABLE [sf].[EmailMessage]
	CHECK CONSTRAINT [fk_EmailMessage_FileType_FileTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the file type system ID column in the Email Message table match a file type system ID in the File Type table. It also ensures that records in the File Type table cannot be deleted if matching child records exist in Email Message. Finally, the constraint blocks changes to the value of the file type system ID column in the File Type if matching child records exist in Email Message.', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'CONSTRAINT', N'fk_EmailMessage_FileType_FileTypeSID'
GO
ALTER TABLE [sf].[EmailMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailMessage_ApplicationGrant_ApplicationGrantSID]
	FOREIGN KEY ([ApplicationGrantSID]) REFERENCES [sf].[ApplicationGrant] ([ApplicationGrantSID])
ALTER TABLE [sf].[EmailMessage]
	CHECK CONSTRAINT [fk_EmailMessage_ApplicationGrant_ApplicationGrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application grant system ID column in the Email Message table match a application grant system ID in the Application Grant table. It also ensures that records in the Application Grant table cannot be deleted if matching child records exist in Email Message. Finally, the constraint blocks changes to the value of the application grant system ID column in the Application Grant if matching child records exist in Email Message.', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'CONSTRAINT', N'fk_EmailMessage_ApplicationGrant_ApplicationGrantSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailMessage_ApplicationEntitySID_EmailMessageSID]
	ON [sf].[EmailMessage] ([ApplicationEntitySID], [EmailMessageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Entity SID foreign key column and avoids row contention on (parent) Application Entity updates', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'INDEX', N'ix_EmailMessage_ApplicationEntitySID_EmailMessageSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailMessage_ApplicationGrantSID_EmailMessageSID]
	ON [sf].[EmailMessage] ([ApplicationGrantSID], [EmailMessageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Grant SID foreign key column and avoids row contention on (parent) Application Grant updates', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'INDEX', N'ix_EmailMessage_ApplicationGrantSID_EmailMessageSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailMessage_ApplicationUserSID_EmailMessageSID]
	ON [sf].[EmailMessage] ([ApplicationUserSID], [EmailMessageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'INDEX', N'ix_EmailMessage_ApplicationUserSID_EmailMessageSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailMessage_FileTypeSID_EmailMessageSID]
	ON [sf].[EmailMessage] ([FileTypeSID], [EmailMessageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the File Type SID foreign key column and avoids row contention on (parent) File Type updates', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'INDEX', N'ix_EmailMessage_FileTypeSID_EmailMessageSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailMessage_MessageLinkSID_EmailMessageSID]
	ON [sf].[EmailMessage] ([MessageLinkSID], [EmailMessageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Message Link SID foreign key column and avoids row contention on (parent) Message Link updates', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'INDEX', N'ix_EmailMessage_MessageLinkSID_EmailMessageSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_EmailMessage_LegacyKey]
	ON [sf].[EmailMessage] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'INDEX', N'ux_EmailMessage_LegacyKey'
GO
CREATE FULLTEXT INDEX ON [sf].[EmailMessage]
	([Subject] LANGUAGE 0, [Body] TYPE COLUMN [FileTypeSCD] LANGUAGE 0)
	KEY INDEX [pk_EmailMessage]
	ON (FILEGROUP [FullTextIndexData], [ftcDefault])
	WITH CHANGE_TRACKING AUTO, STOPLIST OFF
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the main content of email notes including the title, body content, and the sending email address.  If the email note has attachments, those are stored in the Email Message Attachment table.  The list of persons the email is sent to is tracked in the Person Email table – including the email address targeted at the time of sending. Email is sent by a service configured for each application.  When the email is available for sending by the service (the user has pressed “send”), the Queued Time is set.  The actual Sent Time is set on the Person Email Message table individually as each occurrence of the message is picked up by the service for sending to each recipient.  Email can be prioritized for sending by the Priority Level value which defaults to a medium setting.  Where email cannot be shared with all administrators of the application, the “Is Restricted Access” value should be set on. Details about the success or failure of email sent are not provided back through the service so the status column tracks basic flow from creation through sending only.  If information is obtained indicating an email message was not received, this can be tracked in the Email Message Person table.  Email messages may be created manually or based on a template.  Emails can be setup with merge fields, for example: [@FirstName] and [@LastName] which are replaced when the note is generated and stored into this record.  The merge field tokens exist in the Email Message subject and/or body columns but when the message is stored in this record, they are already replaced.  The application automatically considers the Person Email Message entity (which includes most values from the Person entity) to be the default data source for replacing merge fields.  It is also possible to identify a second data source through the Application Entity column on the parent Email Message record.  Note where application entity is used, that data source is processed before Person Email Message so that where any column names are the same, the application entity specified takes precedence. A record of any template used to produce the email is not linked directly on the email record since content from the template can be changed prior to sending.  The Subject line of the email can generally be used as a way to track the source template if required.  Emails used to confirm invitations to become a user of the system should have the Application User Invite column set on. Invites are an email type that include a “confirmation link” the user clicks to validate the email address they have provided.  Confirmation links should be set to expire fairly quickly to reduce the attack surface of the application. This is set through the Confirmation Expiry Days value.  The Restricted Access designation is an extra level of access control provided.  Security grants already control access to email and document screens but this designator be used to indicate an email is particularly sensitive and should only appear to users who also have an additional grant (e.g. “case conduct” administrators, or “clinicians”).   ', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the email message assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'EmailMessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sending email address for the note', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'SenderEmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is the text which will be displayed as part of the ''from'' field in a user''s email client.  E.g. In outlook the combination of a display name and the sender''s email address is displayed as ''John Doe <john.d@mailinator.com>''.', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'SenderDisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A priority level used to rank emails for sending: 1 is the highest priority, 5 is medium and 10 is lowest | This value is used to sort emails for pickup by the email sending service', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Subject of the email note', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'Subject'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Body of the email note (HTML format)', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'Body'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file extension or type of document the email body is stored as | This value must match one of the registered filter types for full-text searching.  The list of document types supported is limited by the master table.  The value includes the leading period - e.g. ".HTML" Note that the default value is updated by an AFTER trigger defined on the table.', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'FileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of email message', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'FileTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Buffer to store recipients while an email message is in draft mode. The list of identifiers (Person SIDs) is used to create the PersonEmailMessage record when the email message is sent.', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'RecipientList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the eligibility check on recipients should ensure there is an active user account (recipient must be able to sign in) | Be sure this value is set for password reset emails', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'IsApplicationUserRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A reference to an existing user record to use as a template for grants to apply to new user accounts created when this email is confirmed | 
Applies to user invite emails only', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the email link assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'MessageLinkSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of hours after which any (confirmation) link included in the email is considered expired', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'LinkExpiryHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this email message', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, indicates the document is not to be mailed out. The PDF is saved to the member file for download and/or printing only.', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'IsGenerateOnly'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the process of finalizing the email content begins | No changes to recipients or template contents can occur after this value is set', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'MergedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this message was provided to the service for sending', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'QueuedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the email message was cancelled (not sent) after being queued but before being sent (prior to queuing the message can be deleted)', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the email was put into archived status | Archived email remains available in the database but is not included in displays and searches by default', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'ArchivedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the email document is purged from online storage (documents can be exported at archive step)', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'PurgedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the email message | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'EmailMessageXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the email message | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this email message record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the email message | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the email message record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the email message record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'CONSTRAINT', N'uk_EmailMessage_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_EmailMessage_RecipientList]
	ON [sf].[EmailMessage] ([RecipientList])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Recipient List (XML) column', 'SCHEMA', N'sf', 'TABLE', N'EmailMessage', 'INDEX', N'xp_EmailMessage_RecipientList'
GO
ALTER TABLE [sf].[EmailMessage] SET (LOCK_ESCALATION = TABLE)
GO
