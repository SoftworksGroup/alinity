SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ConfigParam] (
		[ConfigParamSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[ConfigParamSCD]         [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ConfigParamName]        [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ParamValue]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[DefaultParamValue]      [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DataType]               [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MaxLength]              [int] NULL,
		[IsReadOnly]             [bit] NOT NULL,
		[UsageNotes]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]     [xml] NULL,
		[ConfigParamXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_ConfigParam_ConfigParamName]
		UNIQUE
		NONCLUSTERED
		([ConfigParamName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ConfigParam_ConfigParamSCD]
		UNIQUE
		NONCLUSTERED
		([ConfigParamSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ConfigParam_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ConfigParam]
		PRIMARY KEY
		CLUSTERED
		([ConfigParamSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Config Param table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'CONSTRAINT', N'pk_ConfigParam'
GO
ALTER TABLE [sf].[ConfigParam]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ConfigParam]
	CHECK
	([sf].[fConfigParam#Check]([ConfigParamSID],[ConfigParamSCD],[ConfigParamName],[DataType],[MaxLength],[IsReadOnly],[ConfigParamXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ConfigParam]
CHECK CONSTRAINT [ck_ConfigParam]
GO
ALTER TABLE [sf].[ConfigParam]
	ADD
	CONSTRAINT [df_ConfigParam_DataType]
	DEFAULT ('nvarchar') FOR [DataType]
GO
ALTER TABLE [sf].[ConfigParam]
	ADD
	CONSTRAINT [df_ConfigParam_IsReadOnly]
	DEFAULT ((0)) FOR [IsReadOnly]
GO
ALTER TABLE [sf].[ConfigParam]
	ADD
	CONSTRAINT [df_ConfigParam_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ConfigParam]
	ADD
	CONSTRAINT [df_ConfigParam_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ConfigParam]
	ADD
	CONSTRAINT [df_ConfigParam_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ConfigParam]
	ADD
	CONSTRAINT [df_ConfigParam_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ConfigParam]
	ADD
	CONSTRAINT [df_ConfigParam_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ConfigParam]
	ADD
	CONSTRAINT [df_ConfigParam_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ConfigParam_LegacyKey]
	ON [sf].[ConfigParam] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'INDEX', N'ux_ConfigParam_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the config param assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'ConfigParamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the config param | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'ConfigParamSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the config param to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'ConfigParamName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the config param | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'ConfigParamXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the config param | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this config param record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the config param | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the config param record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the config param record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Config Param Name column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'CONSTRAINT', N'uk_ConfigParam_ConfigParamName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Config Param SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'CONSTRAINT', N'uk_ConfigParam_ConfigParamSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ConfigParam', 'CONSTRAINT', N'uk_ConfigParam_RowGUID'
GO
ALTER TABLE [sf].[ConfigParam] SET (LOCK_ESCALATION = TABLE)
GO
