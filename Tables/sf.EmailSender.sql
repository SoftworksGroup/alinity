SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[EmailSender] (
		[EmailSenderSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[SenderEmailAddress]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SenderDisplayName]      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsPrivate]              [bit] NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[EmailSenderXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_EmailSender_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_EmailSender_SenderDisplayName]
		UNIQUE
		NONCLUSTERED
		([SenderDisplayName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_EmailSender_SenderEmailAddress]
		UNIQUE
		NONCLUSTERED
		([SenderEmailAddress])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_EmailSender]
		PRIMARY KEY
		CLUSTERED
		([EmailSenderSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Email Sender table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'CONSTRAINT', N'pk_EmailSender'
GO
ALTER TABLE [sf].[EmailSender]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_EmailSender]
	CHECK
	([sf].[fEmailSender#Check]([EmailSenderSID],[SenderEmailAddress],[SenderDisplayName],[IsPrivate],[IsDefault],[EmailSenderXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[EmailSender]
CHECK CONSTRAINT [ck_EmailSender]
GO
ALTER TABLE [sf].[EmailSender]
	ADD
	CONSTRAINT [df_EmailSender_IsPrivate]
	DEFAULT ((0)) FOR [IsPrivate]
GO
ALTER TABLE [sf].[EmailSender]
	ADD
	CONSTRAINT [df_EmailSender_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[EmailSender]
	ADD
	CONSTRAINT [df_EmailSender_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[EmailSender]
	ADD
	CONSTRAINT [df_EmailSender_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[EmailSender]
	ADD
	CONSTRAINT [df_EmailSender_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[EmailSender]
	ADD
	CONSTRAINT [df_EmailSender_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[EmailSender]
	ADD
	CONSTRAINT [df_EmailSender_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[EmailSender]
	ADD
	CONSTRAINT [df_EmailSender_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_EmailSender_IsDefault]
	ON [sf].[EmailSender] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Email Sender', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'INDEX', N'ux_EmailSender_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_EmailSender_LegacyKey]
	ON [sf].[EmailSender] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'INDEX', N'ux_EmailSender_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used on the user interface to populate a list of possible sending email addresses to use when sending email from the system.  The sending address is also the address that receives replies.  If the email address of the user sending the email appears in this table, then it is automatically set as the default for sending for that session.  If a group email address should be used for sending instead however, it can be selected from the values in this table.  Note that records marked "private" are not presented as potential sending addresses unless “sending-on-behalf-of functionality” is desired in which case the private check-mark should be removed.  The table also identifies one record that will be used as the default sending address if a sending address is not specifically selected. A foreign key is not established between this table and Email Message since the Email Address is stored directly when the sender is specified (preserves audit trail of sender). ', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the email sender assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'EmailSenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sending email address for the note', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'SenderEmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is the text which will be displayed as part of the "From" field in a user''s email client.  E.g. In outlook the combination of a display name and the sender''s email address is displayed as "Richard Kaiser <richard.k@alinityapp.com>".', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'SenderDisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates address can only be used by the owner of the account.  Best practice is to check this option for non-group email addresses.', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'IsPrivate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default email sender to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the email sender | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'EmailSenderXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the email sender | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this email sender record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the email sender | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the email sender record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the email sender record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'CONSTRAINT', N'uk_EmailSender_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Sender Display Name column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'CONSTRAINT', N'uk_EmailSender_SenderDisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Sender Email Address column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'EmailSender', 'CONSTRAINT', N'uk_EmailSender_SenderEmailAddress'
GO
ALTER TABLE [sf].[EmailSender] SET (LOCK_ESCALATION = TABLE)
GO
