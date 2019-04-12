SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ExportFile] (
		[ExportFileSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[ExportSourceGUID]        [uniqueidentifier] NOT NULL,
		[FileFormatSID]           [int] NOT NULL,
		[FileContent]             [varbinary](max) FILESTREAM NULL,
		[ProcessedTime]           [datetimeoffset](7) NULL,
		[ExportSpecification]     [xml] NOT NULL,
		[IsFailed]                [bit] NOT NULL,
		[MessageText]             [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]      [xml] NULL,
		[ExportFileXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]               [bit] NOT NULL,
		[CreateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]              [datetimeoffset](7) NOT NULL,
		[UpdateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]              [datetimeoffset](7) NOT NULL,
		[RowGUID]                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                [timestamp] NOT NULL,
		CONSTRAINT [uk_ExportFile_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ExportFile]
		PRIMARY KEY
		CLUSTERED
		([ExportFileSID])
	WITH FILLFACTOR=90
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Export File table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'CONSTRAINT', N'pk_ExportFile'
GO
ALTER TABLE [sf].[ExportFile]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ExportFile]
	CHECK
	([sf].[fExportFile#Check]([ExportFileSID],[ExportSourceGUID],[FileFormatSID],[ProcessedTime],[IsFailed],[MessageText],[ExportFileXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ExportFile]
CHECK CONSTRAINT [ck_ExportFile]
GO
ALTER TABLE [sf].[ExportFile]
	ADD
	CONSTRAINT [df_ExportFile_IsFailed]
	DEFAULT ((0)) FOR [IsFailed]
GO
ALTER TABLE [sf].[ExportFile]
	ADD
	CONSTRAINT [df_ExportFile_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ExportFile]
	ADD
	CONSTRAINT [df_ExportFile_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ExportFile]
	ADD
	CONSTRAINT [df_ExportFile_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ExportFile]
	ADD
	CONSTRAINT [df_ExportFile_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ExportFile]
	ADD
	CONSTRAINT [df_ExportFile_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ExportFile]
	ADD
	CONSTRAINT [df_ExportFile_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[ExportFile]
	WITH CHECK
	ADD CONSTRAINT [fk_ExportFile_FileFormat_FileFormatSID]
	FOREIGN KEY ([FileFormatSID]) REFERENCES [sf].[FileFormat] ([FileFormatSID])
ALTER TABLE [sf].[ExportFile]
	CHECK CONSTRAINT [fk_ExportFile_FileFormat_FileFormatSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the file format system ID column in the Export File table match a file format system ID in the File Format table. It also ensures that records in the File Format table cannot be deleted if matching child records exist in Export File. Finally, the constraint blocks changes to the value of the file format system ID column in the File Format if matching child records exist in Export File.', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'CONSTRAINT', N'fk_ExportFile_FileFormat_FileFormatSID'
GO
CREATE NONCLUSTERED INDEX [ix_ExportFile_FileFormatSID_ExportFileSID]
	ON [sf].[ExportFile] ([FileFormatSID], [ExportFileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the File Format SID foreign key column and avoids row contention on (parent) File Format updates', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'INDEX', N'ix_ExportFile_FileFormatSID_ExportFileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The unique identifier (GUID) of the data source, or data source application page, the export is being generated for | This value is used by the export process to determine the source of the export data', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the export file assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'ExportFileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A reference to the Export-Job or Data-Source the export was created from', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'ExportSourceGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file format assigned to this export file', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'FileFormatSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The content exported | This value is blank when the record is first created', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'FileContent'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the export service picked up the job for processing', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'ProcessedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value used internally by the system to record the column selection, file type, filename and other parameters for creating the export', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'ExportSpecification'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the export of this file failed or was cancelled', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'IsFailed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the export file | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'ExportFileXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the export file | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this export file record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the export file | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the export file record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the export file record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'CONSTRAINT', N'uk_ExportFile_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_ExportFile_ExportSpecification]
	ON [sf].[ExportFile] ([ExportSpecification])
	WITH ( FILLFACTOR = 90)
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Export Specification (XML) column', 'SCHEMA', N'sf', 'TABLE', N'ExportFile', 'INDEX', N'xp_ExportFile_ExportSpecification'
GO
ALTER TABLE [sf].[ExportFile] SET (LOCK_ESCALATION = TABLE)
GO
