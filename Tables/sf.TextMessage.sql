SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[TextMessage] (
		[TextMessageSID]                [int] IDENTITY(1000001, 1) NOT NULL,
		[SenderPhone]                   [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SenderDisplayName]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PriorityLevel]                 [tinyint] NOT NULL,
		[Body]                          [nvarchar](1600) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RecipientList]                 [xml] NOT NULL,
		[IsApplicationUserRequired]     [bit] NULL,
		[ApplicationUserSID]            [int] NULL,
		[MessageLinkSID]                [int] NULL,
		[LinkExpiryHours]               [int] NOT NULL,
		[ApplicationEntitySID]          [int] NULL,
		[MergedTime]                    [datetimeoffset](7) NULL,
		[QueuedTime]                    [datetimeoffset](7) NULL,
		[CancelledTime]                 [datetimeoffset](7) NULL,
		[ArchivedTime]                  [datetimeoffset](7) NULL,
		[UserDefinedColumns]            [xml] NULL,
		[TextMessageXID]                [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_TextMessage_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_TextMessage]
		PRIMARY KEY
		CLUSTERED
		([TextMessageSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Text Message table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'CONSTRAINT', N'pk_TextMessage'
GO
ALTER TABLE [sf].[TextMessage]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_TextMessage]
	CHECK
	([sf].[fTextMessage#Check]([TextMessageSID],[SenderPhone],[SenderDisplayName],[PriorityLevel],[Body],[IsApplicationUserRequired],[ApplicationUserSID],[MessageLinkSID],[LinkExpiryHours],[ApplicationEntitySID],[MergedTime],[QueuedTime],[CancelledTime],[ArchivedTime],[TextMessageXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[TextMessage]
CHECK CONSTRAINT [ck_TextMessage]
GO
ALTER TABLE [sf].[TextMessage]
	ADD
	CONSTRAINT [df_TextMessage_PriorityLevel]
	DEFAULT ((5)) FOR [PriorityLevel]
GO
ALTER TABLE [sf].[TextMessage]
	ADD
	CONSTRAINT [df_TextMessage_IsApplicationUserRequired]
	DEFAULT ((0)) FOR [IsApplicationUserRequired]
GO
ALTER TABLE [sf].[TextMessage]
	ADD
	CONSTRAINT [df_TextMessage_LinkExpiryHours]
	DEFAULT ((24)) FOR [LinkExpiryHours]
GO
ALTER TABLE [sf].[TextMessage]
	ADD
	CONSTRAINT [df_TextMessage_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[TextMessage]
	ADD
	CONSTRAINT [df_TextMessage_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[TextMessage]
	ADD
	CONSTRAINT [df_TextMessage_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[TextMessage]
	ADD
	CONSTRAINT [df_TextMessage_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[TextMessage]
	ADD
	CONSTRAINT [df_TextMessage_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[TextMessage]
	ADD
	CONSTRAINT [df_TextMessage_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[TextMessage]
	ADD
	CONSTRAINT [df_TextMessage_RecipientList]
	DEFAULT (CONVERT([xml],N'<Recipients />')) FOR [RecipientList]
GO
ALTER TABLE [sf].[TextMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_TextMessage_ApplicationEntity_ApplicationEntitySID]
	FOREIGN KEY ([ApplicationEntitySID]) REFERENCES [sf].[ApplicationEntity] ([ApplicationEntitySID])
ALTER TABLE [sf].[TextMessage]
	CHECK CONSTRAINT [fk_TextMessage_ApplicationEntity_ApplicationEntitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application entity system ID column in the Text Message table match a application entity system ID in the Application Entity table. It also ensures that records in the Application Entity table cannot be deleted if matching child records exist in Text Message. Finally, the constraint blocks changes to the value of the application entity system ID column in the Application Entity if matching child records exist in Text Message.', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'CONSTRAINT', N'fk_TextMessage_ApplicationEntity_ApplicationEntitySID'
GO
ALTER TABLE [sf].[TextMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_TextMessage_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
ALTER TABLE [sf].[TextMessage]
	CHECK CONSTRAINT [fk_TextMessage_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Text Message table match a application user system ID in the Application User table. It also ensures that records in the Application User table cannot be deleted if matching child records exist in Text Message. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Text Message.', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'CONSTRAINT', N'fk_TextMessage_ApplicationUser_ApplicationUserSID'
GO
ALTER TABLE [sf].[TextMessage]
	WITH CHECK
	ADD CONSTRAINT [fk_TextMessage_MessageLink_MessageLinkSID]
	FOREIGN KEY ([MessageLinkSID]) REFERENCES [sf].[MessageLink] ([MessageLinkSID])
ALTER TABLE [sf].[TextMessage]
	CHECK CONSTRAINT [fk_TextMessage_MessageLink_MessageLinkSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the message link system ID column in the Text Message table match a message link system ID in the Message Link table. It also ensures that records in the Message Link table cannot be deleted if matching child records exist in Text Message. Finally, the constraint blocks changes to the value of the message link system ID column in the Message Link if matching child records exist in Text Message.', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'CONSTRAINT', N'fk_TextMessage_MessageLink_MessageLinkSID'
GO
CREATE NONCLUSTERED INDEX [ix_TextMessage_ApplicationEntitySID_TextMessageSID]
	ON [sf].[TextMessage] ([ApplicationEntitySID], [TextMessageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Entity SID foreign key column and avoids row contention on (parent) Application Entity updates', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'INDEX', N'ix_TextMessage_ApplicationEntitySID_TextMessageSID'
GO
CREATE NONCLUSTERED INDEX [ix_TextMessage_ApplicationUserSID_TextMessageSID]
	ON [sf].[TextMessage] ([ApplicationUserSID], [TextMessageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'INDEX', N'ix_TextMessage_ApplicationUserSID_TextMessageSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TextMessage_LegacyKey]
	ON [sf].[TextMessage] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'INDEX', N'ux_TextMessage_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_TextMessage_MessageLinkSID_TextMessageSID]
	ON [sf].[TextMessage] ([MessageLinkSID], [TextMessageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Message Link SID foreign key column and avoids row contention on (parent) Message Link updates', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'INDEX', N'ix_TextMessage_MessageLinkSID_TextMessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the main content of text notes including the body content, and the sending text phone.  The list of persons the text is sent to is tracked in the Person Text table – including the text phone targeted at the time of sending. Text is sent by a service configured for each application.  When the text is available for sending by the service (the user has pressed “send”), the Queued Time is set.  The actual Sent Time is set on the Person Text Message table individually as each occurrence of the message is picked up by the service for sending to each recipient.  Text can be prioritized for sending by the Priority Level value which defaults to a medium setting.  Where text cannot be shared with all administrators of the application, the “Is Restricted Access” value should be set on. Details about the success or failure of text sent are not provided back through the service so the status column tracks basic flow from creation through sending only.  If information is obtained indicating an text message was not received, this can be tracked in the Text Message Person table.  Text messages may be created manually or based on a template.  Texts can be setup with merge fields, for example: [@FirstName] and [@LastName] which are replaced when the note is generated and stored into this record.  The merge field tokens exist in the Text Message body columns but when the message is stored in this record, they are already replaced.  The application automatically considers the Person Text Message entity (which includes most values from the Person entity) to be the default data source for replacing merge fields.  It is also possible to identify a second data source through the Application Entity column on the parent Text Message record.  Note where application entity is used, that data source is processed before Person Text Message so that where any column names are the same, the application entity specified takes precedence. A record of any template used to produce the text is not linked directly on the text record since content from the template can be changed prior to sending.  The Texts used to confirm invitations to become a user of the system should have the Application User Invite column set on. Invites are an text type that include a “confirmation link” the user clicks to validate the text phone they have provided.  Confirmation links should be set to expire fairly quickly to reduce the attack surface of the application. This is set through the Confirmation Expiry Days value.  The Restricted Access designation is an extra level of access control provided.  Security grants already control access to text and document screens but this designator be used to indicate an text is particularly sensitive and should only appear to users who also have an additional grant (e.g. “case conduct” administrators, or “clinicians”).   ', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the text message assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'TextMessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sending phone number for the message', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'SenderPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is an information only field that shows the owner of the phone number used to send the message | This value cannot be sent to the recipient except as a replacement (merge) value', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'SenderDisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A priority level used to rank texts for sending: 1 is the highest priority, 5 is medium and 10 is lowest | This value is used to sort texts for pickup by the text sending service', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Body of the text note ', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'Body'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Buffer to store recipients while an email message is in draft mode. The list of identifiers (Person SIDs) is used to create the PersonEmailMessage record when the email message is sent.', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'RecipientList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the eligibility check on recipients should ensure there is an active user account (recipient must be able to sign in) | Be sure this value is set for password reset texts', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'IsApplicationUserRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A reference to an existing user record to use as a template for grants to apply to new user accounts created when this text is confirmed | 
Applies to user invite texts only', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the text link assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'MessageLinkSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of hours after which any (confirmation) link included in the text is considered expired', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'LinkExpiryHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this text message', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the process of finalizing the text content begins | No changes to recipients or template contents can occur after this value is set', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'MergedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this message was provided to the service for sending', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'QueuedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the text message was cancelled (not sent) after being queued but before being sent (prior to queuing the message can be deleted)', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the text was put into archived status | Archived text remains available in the database but is not included in displays and searches by default', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'ArchivedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the text message | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'TextMessageXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the text message | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this text message record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the text message | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the text message record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the text message record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'CONSTRAINT', N'uk_TextMessage_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_TextMessage_RecipientList]
	ON [sf].[TextMessage] ([RecipientList])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Recipient List (XML) column', 'SCHEMA', N'sf', 'TABLE', N'TextMessage', 'INDEX', N'xp_TextMessage_RecipientList'
GO
ALTER TABLE [sf].[TextMessage] SET (LOCK_ESCALATION = TABLE)
GO
