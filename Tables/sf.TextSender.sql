SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[TextSender] (
		[TextSenderSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[SenderPhone]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SenderDisplayName]      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsPrivate]              [bit] NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[TextSenderXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_TextSender_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_TextSender_SenderDisplayName]
		UNIQUE
		NONCLUSTERED
		([SenderDisplayName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_TextSender_SenderPhone]
		UNIQUE
		NONCLUSTERED
		([SenderPhone])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_TextSender]
		PRIMARY KEY
		CLUSTERED
		([TextSenderSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Text Sender table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'CONSTRAINT', N'pk_TextSender'
GO
ALTER TABLE [sf].[TextSender]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_TextSender]
	CHECK
	([sf].[fTextSender#Check]([TextSenderSID],[SenderPhone],[SenderDisplayName],[IsPrivate],[IsDefault],[TextSenderXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[TextSender]
CHECK CONSTRAINT [ck_TextSender]
GO
ALTER TABLE [sf].[TextSender]
	ADD
	CONSTRAINT [df_TextSender_IsPrivate]
	DEFAULT ((0)) FOR [IsPrivate]
GO
ALTER TABLE [sf].[TextSender]
	ADD
	CONSTRAINT [df_TextSender_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[TextSender]
	ADD
	CONSTRAINT [df_TextSender_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[TextSender]
	ADD
	CONSTRAINT [df_TextSender_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[TextSender]
	ADD
	CONSTRAINT [df_TextSender_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[TextSender]
	ADD
	CONSTRAINT [df_TextSender_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[TextSender]
	ADD
	CONSTRAINT [df_TextSender_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[TextSender]
	ADD
	CONSTRAINT [df_TextSender_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TextSender_IsDefault]
	ON [sf].[TextSender] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Text Sender', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'INDEX', N'ux_TextSender_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TextSender_LegacyKey]
	ON [sf].[TextSender] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'INDEX', N'ux_TextSender_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to populate a list of possible sending text phone numbers to use when sending text messages from the system.  The sending phone is also the phone that receives replies.  If the phone number of the user sending the text appears in this table, then it is automatically set as the default for sending for that session.  If a group text phone should be used for sending instead however, it can be selected from the values in this table.  Note that records marked "private" are not presented as potential sending phonees unless “sending-on-behalf-of functionality” is desired in which case the private check-mark should be removed.  The table also identifies one record that will be used as the default sending phone if a sending phone is not specifically selected. A foreign key is not established between this table and Text Message since the sending phone is stored directly when the sender is specified (preserves audit trail of sender). ', 'SCHEMA', N'sf', 'TABLE', N'TextSender', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the text sender assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'TextSenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sending phone number for the message', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'SenderPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value documents the person who controls the sending phone number | This value is not sent with the text message but can be used as a merge value in the text content (otherwise only the number appears to the recipient).', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'SenderDisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates phone can only be used by the owner of the account.  Best practice is to check this option for non-group text phone numbers.', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'IsPrivate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default text sender to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the text sender | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'TextSenderXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the text sender | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this text sender record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the text sender | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the text sender record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the text sender record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'CONSTRAINT', N'uk_TextSender_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Sender Display Name column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'CONSTRAINT', N'uk_TextSender_SenderDisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Sender Phone column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TextSender', 'CONSTRAINT', N'uk_TextSender_SenderPhone'
GO
ALTER TABLE [sf].[TextSender] SET (LOCK_ESCALATION = TABLE)
GO
