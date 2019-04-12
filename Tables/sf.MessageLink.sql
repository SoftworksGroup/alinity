SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[MessageLink] (
		[MessageLinkSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[MessageLinkSCD]         [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MessageLinkLabel]       [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ApplicationPageSID]     [int] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[MessageLinkXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_MessageLink_MessageLinkLabel]
		UNIQUE
		NONCLUSTERED
		([MessageLinkLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_MessageLink_MessageLinkSCD]
		UNIQUE
		NONCLUSTERED
		([MessageLinkSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_MessageLink_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_MessageLink]
		PRIMARY KEY
		CLUSTERED
		([MessageLinkSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Message Link table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'CONSTRAINT', N'pk_MessageLink'
GO
ALTER TABLE [sf].[MessageLink]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_MessageLink]
	CHECK
	([sf].[fMessageLink#Check]([MessageLinkSID],[MessageLinkSCD],[MessageLinkLabel],[ApplicationPageSID],[MessageLinkXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[MessageLink]
CHECK CONSTRAINT [ck_MessageLink]
GO
ALTER TABLE [sf].[MessageLink]
	ADD
	CONSTRAINT [df_MessageLink_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[MessageLink]
	ADD
	CONSTRAINT [df_MessageLink_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[MessageLink]
	ADD
	CONSTRAINT [df_MessageLink_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[MessageLink]
	ADD
	CONSTRAINT [df_MessageLink_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[MessageLink]
	ADD
	CONSTRAINT [df_MessageLink_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[MessageLink]
	ADD
	CONSTRAINT [df_MessageLink_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[MessageLink]
	WITH CHECK
	ADD CONSTRAINT [fk_MessageLink_ApplicationPage_ApplicationPageSID]
	FOREIGN KEY ([ApplicationPageSID]) REFERENCES [sf].[ApplicationPage] ([ApplicationPageSID])
ALTER TABLE [sf].[MessageLink]
	CHECK CONSTRAINT [fk_MessageLink_ApplicationPage_ApplicationPageSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application page system ID column in the Message Link table match a application page system ID in the Application Page table. It also ensures that records in the Application Page table cannot be deleted if matching child records exist in Message Link. Finally, the constraint blocks changes to the value of the application page system ID column in the Application Page if matching child records exist in Message Link.', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'CONSTRAINT', N'fk_MessageLink_ApplicationPage_ApplicationPageSID'
GO
CREATE NONCLUSTERED INDEX [ix_MessageLink_ApplicationPageSID_MessageLinkSID]
	ON [sf].[MessageLink] ([ApplicationPageSID], [MessageLinkSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Page SID foreign key column and avoids row contention on (parent) Application Page updates', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'INDEX', N'ix_MessageLink_ApplicationPageSID_MessageLinkSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MessageLink_LegacyKey]
	ON [sf].[MessageLink] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'INDEX', N'ux_MessageLink_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the list of links that can be used in email and text-message templates.  The list of links cannot be updated by the end user (no add or delete) but descriptive column values can be updated to use terminology/language appropriate for the configuration.  Links are referenced in template merge fields – replaced by the Application Route value in related Application Page records. The list of email links is maintained by product installation and upgrade scripts.', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the message link assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'MessageLinkSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the message link | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'MessageLinkSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the message link to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'MessageLinkLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the message link | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'MessageLinkXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the message link | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this message link record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the message link | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the message link record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the message link record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Message Link Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'CONSTRAINT', N'uk_MessageLink_MessageLinkLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Message Link SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'CONSTRAINT', N'uk_MessageLink_MessageLinkSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'MessageLink', 'CONSTRAINT', N'uk_MessageLink_RowGUID'
GO
ALTER TABLE [sf].[MessageLink] SET (LOCK_ESCALATION = TABLE)
GO
