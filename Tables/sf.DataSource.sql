SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[DataSource] (
		[DataSourceSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[DataSourceLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DBObjectName]           [nvarchar](257) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ToolTip]                [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FileFormatSID]          [int] NOT NULL,
		[ExportDefaults]         [xml] NOT NULL,
		[LastExecuteTime]        [datetimeoffset](7) NOT NULL,
		[LastExecuteUser]        [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ExecuteCount]           [int] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[DataSourceXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_DataSource_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [uk_DataSource_DataSourceLabel]
		UNIQUE
		NONCLUSTERED
		([DataSourceLabel])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_DataSource]
		PRIMARY KEY
		CLUSTERED
		([DataSourceSID])
	WITH FILLFACTOR=90
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Data Source table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'CONSTRAINT', N'pk_DataSource'
GO
ALTER TABLE [sf].[DataSource]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_DataSource]
	CHECK
	([sf].[fDataSource#Check]([DataSourceSID],[DataSourceLabel],[DBObjectName],[ToolTip],[FileFormatSID],[LastExecuteTime],[LastExecuteUser],[ExecuteCount],[DataSourceXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[DataSource]
CHECK CONSTRAINT [ck_DataSource]
GO
ALTER TABLE [sf].[DataSource]
	ADD
	CONSTRAINT [df_DataSource_LastExecuteTime]
	DEFAULT (sysdatetimeoffset()) FOR [LastExecuteTime]
GO
ALTER TABLE [sf].[DataSource]
	ADD
	CONSTRAINT [df_DataSource_LastExecuteUser]
	DEFAULT (suser_sname()) FOR [LastExecuteUser]
GO
ALTER TABLE [sf].[DataSource]
	ADD
	CONSTRAINT [df_DataSource_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[DataSource]
	ADD
	CONSTRAINT [df_DataSource_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[DataSource]
	ADD
	CONSTRAINT [df_DataSource_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[DataSource]
	ADD
	CONSTRAINT [df_DataSource_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[DataSource]
	ADD
	CONSTRAINT [df_DataSource_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[DataSource]
	ADD
	CONSTRAINT [df_DataSource_ExecuteCount]
	DEFAULT ((0)) FOR [ExecuteCount]
GO
ALTER TABLE [sf].[DataSource]
	ADD
	CONSTRAINT [df_DataSource_ExportDefaults]
	DEFAULT (CONVERT([xml],'<ExportDefaults />')) FOR [ExportDefaults]
GO
ALTER TABLE [sf].[DataSource]
	ADD
	CONSTRAINT [df_DataSource_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[DataSource]
	WITH CHECK
	ADD CONSTRAINT [fk_DataSource_FileFormat_FileFormatSID]
	FOREIGN KEY ([FileFormatSID]) REFERENCES [sf].[FileFormat] ([FileFormatSID])
ALTER TABLE [sf].[DataSource]
	CHECK CONSTRAINT [fk_DataSource_FileFormat_FileFormatSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the file format system ID column in the Data Source table match a file format system ID in the File Format table. It also ensures that records in the File Format table cannot be deleted if matching child records exist in Data Source. Finally, the constraint blocks changes to the value of the file format system ID column in the File Format if matching child records exist in Data Source.', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'CONSTRAINT', N'fk_DataSource_FileFormat_FileFormatSID'
GO
CREATE NONCLUSTERED INDEX [ix_DataSource_FileFormatSID_DataSourceSID]
	ON [sf].[DataSource] ([FileFormatSID], [DataSourceSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the File Format SID foreign key column and avoids row contention on (parent) File Format updates', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'INDEX', N'ix_DataSource_FileFormatSID_DataSourceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the list of tables, views and table-functions included in the client configuration as the basis for exports.  The data-source is identified through the database object name but a user-friendly label (which also must be unique) is also available.  The Data-Source is made available on search screens through the Data-Source-Application-Page table assignments. The end-user must have the ADMIN.EXPORT grant in order to use the export feature.  When a data-source is selected the user may select columns to include, sort order, a file name and file format to save to.  The user may choose to save their selections as a default which is then recorded in the Export-Defaults XML document stored in the record.  Any filter combination or quick search (query) available on the screen can be used as the basis for filtering records to include in the export.  It is also possible for the data-source to be configured with an underlying WHERE clause that will also filter records before filtering at the user-interface is applied.', 'SCHEMA', N'sf', 'TABLE', N'DataSource', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the data source assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'DataSourceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the data source to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'DataSourceLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the database table, view or table-function | This is the technical name in the schema', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'DBObjectName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A brief description to show to end-users selecting from among available data sources (e.g. for export)', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'ToolTip'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the file format assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'FileFormatSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A list of defaults to apply when the data source is selected for export (columns to include, sort order, file-name, etc.)', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'ExportDefaults'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this query was last used | This value can be helpful in determining queries which are not being used and can be removed from the system', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'LastExecuteTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The identity of the user who last used this query | This value can be helpful in investigating queries which are not being used to ensure they are removed from the system', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'LastExecuteUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times this query has been used | This value can be helpful in determining queries which are not being used and can be removed from the system', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'ExecuteCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the data source | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'DataSourceXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the data source | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this data source record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the data source | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the data source record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the data source record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'CONSTRAINT', N'uk_DataSource_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Data Source Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'CONSTRAINT', N'uk_DataSource_DataSourceLabel'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_DataSource_ExportDefaults]
	ON [sf].[DataSource] ([ExportDefaults])
	WITH ( FILLFACTOR = 90)
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Export Defaults (XML) column', 'SCHEMA', N'sf', 'TABLE', N'DataSource', 'INDEX', N'xp_DataSource_ExportDefaults'
GO
ALTER TABLE [sf].[DataSource] SET (LOCK_ESCALATION = TABLE)
GO
