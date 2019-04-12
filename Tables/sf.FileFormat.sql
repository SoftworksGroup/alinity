SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[FileFormat] (
		[FileFormatSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[FileFormatSCD]          [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FileFormatLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[FileFormatXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_FileFormat_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FileFormat_FileFormatLabel]
		UNIQUE
		NONCLUSTERED
		([FileFormatLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FileFormat_FileFormatSCD]
		UNIQUE
		NONCLUSTERED
		([FileFormatSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_FileFormat]
		PRIMARY KEY
		CLUSTERED
		([FileFormatSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the File Format table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'CONSTRAINT', N'pk_FileFormat'
GO
ALTER TABLE [sf].[FileFormat]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_FileFormat]
	CHECK
	([sf].[fFileFormat#Check]([FileFormatSID],[FileFormatSCD],[FileFormatLabel],[IsDefault],[FileFormatXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[FileFormat]
CHECK CONSTRAINT [ck_FileFormat]
GO
ALTER TABLE [sf].[FileFormat]
	ADD
	CONSTRAINT [df_FileFormat_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[FileFormat]
	ADD
	CONSTRAINT [df_FileFormat_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[FileFormat]
	ADD
	CONSTRAINT [df_FileFormat_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[FileFormat]
	ADD
	CONSTRAINT [df_FileFormat_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[FileFormat]
	ADD
	CONSTRAINT [df_FileFormat_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[FileFormat]
	ADD
	CONSTRAINT [df_FileFormat_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[FileFormat]
	ADD
	CONSTRAINT [df_FileFormat_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_FileFormat_IsDefault]
	ON [sf].[FileFormat] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default File Format', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'INDEX', N'ux_FileFormat_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table defines the list of file types that are supported for export.  Only the label value should be made available for update in the user interface. ', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the file format assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'FileFormatSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the file format | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'FileFormatSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the file format to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'FileFormatLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default file format to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the file format | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'FileFormatXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the file format | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this file format record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the file format | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the file format record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the file format record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'CONSTRAINT', N'uk_FileFormat_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the File Format Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'CONSTRAINT', N'uk_FileFormat_FileFormatLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the File Format SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FileFormat', 'CONSTRAINT', N'uk_FileFormat_FileFormatSCD'
GO
ALTER TABLE [sf].[FileFormat] SET (LOCK_ESCALATION = TABLE)
GO
