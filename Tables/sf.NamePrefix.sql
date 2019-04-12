SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[NamePrefix] (
		[NamePrefixSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[NamePrefixLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[NamePrefixXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_NamePrefix_NamePrefixLabel]
		UNIQUE
		NONCLUSTERED
		([NamePrefixLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_NamePrefix_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_NamePrefix]
		PRIMARY KEY
		CLUSTERED
		([NamePrefixSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Name Prefix table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'CONSTRAINT', N'pk_NamePrefix'
GO
ALTER TABLE [sf].[NamePrefix]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_NamePrefix]
	CHECK
	([sf].[fNamePrefix#Check]([NamePrefixSID],[NamePrefixLabel],[IsActive],[NamePrefixXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[NamePrefix]
CHECK CONSTRAINT [ck_NamePrefix]
GO
ALTER TABLE [sf].[NamePrefix]
	ADD
	CONSTRAINT [df_NamePrefix_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[NamePrefix]
	ADD
	CONSTRAINT [df_NamePrefix_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[NamePrefix]
	ADD
	CONSTRAINT [df_NamePrefix_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[NamePrefix]
	ADD
	CONSTRAINT [df_NamePrefix_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[NamePrefix]
	ADD
	CONSTRAINT [df_NamePrefix_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[NamePrefix]
	ADD
	CONSTRAINT [df_NamePrefix_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[NamePrefix]
	ADD
	CONSTRAINT [df_NamePrefix_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_NamePrefix_LegacyKey]
	ON [sf].[NamePrefix] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'INDEX', N'ux_NamePrefix_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the name prefix assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the name prefix to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'NamePrefixLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this name prefix record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the name prefix | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'NamePrefixXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the name prefix | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this name prefix record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the name prefix | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the name prefix record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the name prefix record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Name Prefix Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'CONSTRAINT', N'uk_NamePrefix_NamePrefixLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'NamePrefix', 'CONSTRAINT', N'uk_NamePrefix_RowGUID'
GO
ALTER TABLE [sf].[NamePrefix] SET (LOCK_ESCALATION = TABLE)
GO
