SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[FileType] (
		[FileTypeSID]            [int] IDENTITY(1000001, 1) NOT NULL,
		[FileTypeSCD]            [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FileTypeLabel]          [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MimeType]               [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsInline]               [bit] NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[FileTypeXID]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_FileType_FileTypeLabel]
		UNIQUE
		NONCLUSTERED
		([FileTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FileType_FileTypeSCD]
		UNIQUE
		NONCLUSTERED
		([FileTypeSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FileType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_FileType]
		PRIMARY KEY
		CLUSTERED
		([FileTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the File Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'CONSTRAINT', N'pk_FileType'
GO
ALTER TABLE [sf].[FileType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_FileType]
	CHECK
	([sf].[fFileType#Check]([FileTypeSID],[FileTypeSCD],[FileTypeLabel],[MimeType],[IsInline],[IsActive],[FileTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[FileType]
CHECK CONSTRAINT [ck_FileType]
GO
ALTER TABLE [sf].[FileType]
	ADD
	CONSTRAINT [df_FileType_IsInline]
	DEFAULT ((0)) FOR [IsInline]
GO
ALTER TABLE [sf].[FileType]
	ADD
	CONSTRAINT [df_FileType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[FileType]
	ADD
	CONSTRAINT [df_FileType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[FileType]
	ADD
	CONSTRAINT [df_FileType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[FileType]
	ADD
	CONSTRAINT [df_FileType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[FileType]
	ADD
	CONSTRAINT [df_FileType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[FileType]
	ADD
	CONSTRAINT [df_FileType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[FileType]
	ADD
	CONSTRAINT [df_FileType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_FileType_LegacyKey]
	ON [sf].[FileType] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'INDEX', N'ux_FileType_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to classify external documents imported into the system.  The classifications are set in the configuration according to requirements of the end user. The classifications are used to make locating documents easier when examining case records.  The classifications can also be used as a basis for branching custom business rules.  Note that branching logic, if implemented, should be based on the “XID” column in the record and not the label which can be modified by the end user. ', 'SCHEMA', N'sf', 'TABLE', N'FileType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the file type assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'FileTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the file type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'FileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the file type to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'FileTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The MIME type to use when a client browser downloads or views a document.', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'MimeType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When a client browser downloads a document this indicates whether or not the browser should be asked to display rather than download the document. If the browser is unable to, due to lack of software or other settings, the file will instead be downloaded as normal.', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'IsInline'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this file type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the file type | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'FileTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the file type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this file type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the file type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the file type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the file type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the File Type Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'CONSTRAINT', N'uk_FileType_FileTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the File Type SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'CONSTRAINT', N'uk_FileType_FileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FileType', 'CONSTRAINT', N'uk_FileType_RowGUID'
GO
ALTER TABLE [sf].[FileType] SET (LOCK_ESCALATION = TABLE)
GO
