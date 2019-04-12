SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ImportFile] (
		[ImportFileSID]            [int] IDENTITY(1000001, 1) NOT NULL,
		[FileFormatSID]            [int] NOT NULL,
		[ApplicationEntitySID]     [int] NOT NULL,
		[FileName]                 [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FileContent]              [varbinary](max) FILESTREAM NULL,
		[LoadStartTime]            [datetimeoffset](7) NULL,
		[LoadEndTime]              [datetimeoffset](7) NULL,
		[IsFailed]                 [bit] NOT NULL,
		[MessageText]              [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]       [xml] NULL,
		[ImportFileXID]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                [bit] NOT NULL,
		[CreateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]               [datetimeoffset](7) NOT NULL,
		[UpdateUser]               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]               [datetimeoffset](7) NOT NULL,
		[RowGUID]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                 [timestamp] NOT NULL,
		CONSTRAINT [uk_ImportFile_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ImportFile]
		PRIMARY KEY
		CLUSTERED
		([ImportFileSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Import File table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'CONSTRAINT', N'pk_ImportFile'
GO
ALTER TABLE [sf].[ImportFile]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ImportFile]
	CHECK
	([sf].[fImportFile#Check]([ImportFileSID],[FileFormatSID],[ApplicationEntitySID],[FileName],[LoadStartTime],[LoadEndTime],[IsFailed],[MessageText],[ImportFileXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ImportFile]
CHECK CONSTRAINT [ck_ImportFile]
GO
ALTER TABLE [sf].[ImportFile]
	ADD
	CONSTRAINT [df_ImportFile_IsFailed]
	DEFAULT ((0)) FOR [IsFailed]
GO
ALTER TABLE [sf].[ImportFile]
	ADD
	CONSTRAINT [df_ImportFile_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ImportFile]
	ADD
	CONSTRAINT [df_ImportFile_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ImportFile]
	ADD
	CONSTRAINT [df_ImportFile_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ImportFile]
	ADD
	CONSTRAINT [df_ImportFile_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ImportFile]
	ADD
	CONSTRAINT [df_ImportFile_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ImportFile]
	ADD
	CONSTRAINT [df_ImportFile_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[ImportFile]
	WITH CHECK
	ADD CONSTRAINT [fk_ImportFile_ApplicationEntity_ApplicationEntitySID]
	FOREIGN KEY ([ApplicationEntitySID]) REFERENCES [sf].[ApplicationEntity] ([ApplicationEntitySID])
ALTER TABLE [sf].[ImportFile]
	CHECK CONSTRAINT [fk_ImportFile_ApplicationEntity_ApplicationEntitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application entity system ID column in the Import File table match a application entity system ID in the Application Entity table. It also ensures that records in the Application Entity table cannot be deleted if matching child records exist in Import File. Finally, the constraint blocks changes to the value of the application entity system ID column in the Application Entity if matching child records exist in Import File.', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'CONSTRAINT', N'fk_ImportFile_ApplicationEntity_ApplicationEntitySID'
GO
ALTER TABLE [sf].[ImportFile]
	WITH CHECK
	ADD CONSTRAINT [fk_ImportFile_FileFormat_FileFormatSID]
	FOREIGN KEY ([FileFormatSID]) REFERENCES [sf].[FileFormat] ([FileFormatSID])
ALTER TABLE [sf].[ImportFile]
	CHECK CONSTRAINT [fk_ImportFile_FileFormat_FileFormatSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the file format system ID column in the Import File table match a file format system ID in the File Format table. It also ensures that records in the File Format table cannot be deleted if matching child records exist in Import File. Finally, the constraint blocks changes to the value of the file format system ID column in the File Format if matching child records exist in Import File.', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'CONSTRAINT', N'fk_ImportFile_FileFormat_FileFormatSID'
GO
CREATE NONCLUSTERED INDEX [ix_ImportFile_ApplicationEntitySID_ImportFileSID]
	ON [sf].[ImportFile] ([ApplicationEntitySID], [ImportFileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Entity SID foreign key column and avoids row contention on (parent) Application Entity updates', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'INDEX', N'ix_ImportFile_ApplicationEntitySID_ImportFileSID'
GO
CREATE NONCLUSTERED INDEX [ix_ImportFile_FileFormatSID_ImportFileSID]
	ON [sf].[ImportFile] ([FileFormatSID], [ImportFileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the File Format SID foreign key column and avoids row contention on (parent) File Format updates', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'INDEX', N'ix_ImportFile_FileFormatSID_ImportFileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table tracks each occurrence of an imported file.  The file content is stored here only until it is processed.  After successful importing to the target table, the content is removed to conserve space. The target entity for each import is defined as a reference to the Application Entity table.  Normally target entities are in the staging (stg) schema.  The specific format of content to import is defined by the structure of the target entity - e.g. stg.Registrant Profile.  The status of each import is tracked through a combination of the Processed-Time and Is-Failed columns.  The processing status of each record of data imported is tracked through the target table record.', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the import file assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'ImportFileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file format assigned to this import file', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'FileFormatSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this import file', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the source file the import was read from (not necessarily unique).', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'FileName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The content to be imported (cleared after import)', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'FileContent'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the import service picked up the job for importing (start of import)', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'LoadStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the import of the file was completed successfully | Value is blank if Is-Failed is ON', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'LoadEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the import of this file failed or was cancelled by the user.', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'IsFailed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Summary of processing result (blank until processing is attempted).', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'MessageText'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the import file | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'ImportFileXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the import file | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this import file record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the import file | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the import file record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the import file record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ImportFile', 'CONSTRAINT', N'uk_ImportFile_RowGUID'
GO
ALTER TABLE [sf].[ImportFile] SET (LOCK_ESCALATION = TABLE)
GO
