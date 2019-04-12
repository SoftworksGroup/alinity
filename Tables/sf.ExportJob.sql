SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ExportJob] (
		[ExportJobSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[ExportJobName]          [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ExportJobCode]          [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[QuerySQL]               [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[QueryParameters]        [xml] NULL,
		[FileFormatSID]          [int] NOT NULL,
		[BodySpecification]      [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LineSpecification]      [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[XMLTransformation]      [xml] NULL,
		[JobScheduleSID]         [int] NULL,
		[EndPoint]               [xml] NULL,
		[LastExecuteTime]        [datetimeoffset](7) NOT NULL,
		[LastExecuteUser]        [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ExecuteCount]           [int] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[ExportJobXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_ExportJob_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ExportJob_ExportJobName]
		UNIQUE
		NONCLUSTERED
		([ExportJobName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ExportJob_ExportJobCode]
		UNIQUE
		NONCLUSTERED
		([ExportJobCode])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ExportJob]
		PRIMARY KEY
		CLUSTERED
		([ExportJobSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Export Job table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'CONSTRAINT', N'pk_ExportJob'
GO
ALTER TABLE [sf].[ExportJob]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ExportJob]
	CHECK
	([sf].[fExportJob#Check]([ExportJobSID],[ExportJobName],[ExportJobCode],[FileFormatSID],[JobScheduleSID],[LastExecuteTime],[LastExecuteUser],[ExecuteCount],[ExportJobXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ExportJob]
CHECK CONSTRAINT [ck_ExportJob]
GO
ALTER TABLE [sf].[ExportJob]
	ADD
	CONSTRAINT [df_ExportJob_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ExportJob]
	ADD
	CONSTRAINT [df_ExportJob_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ExportJob]
	ADD
	CONSTRAINT [df_ExportJob_ExecuteCount]
	DEFAULT ((0)) FOR [ExecuteCount]
GO
ALTER TABLE [sf].[ExportJob]
	ADD
	CONSTRAINT [df_ExportJob_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ExportJob]
	ADD
	CONSTRAINT [df_ExportJob_LastExecuteTime]
	DEFAULT (sysdatetimeoffset()) FOR [LastExecuteTime]
GO
ALTER TABLE [sf].[ExportJob]
	ADD
	CONSTRAINT [df_ExportJob_LastExecuteUser]
	DEFAULT (suser_sname()) FOR [LastExecuteUser]
GO
ALTER TABLE [sf].[ExportJob]
	ADD
	CONSTRAINT [df_ExportJob_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[ExportJob]
	ADD
	CONSTRAINT [df_ExportJob_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ExportJob]
	ADD
	CONSTRAINT [df_ExportJob_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ExportJob]
	WITH CHECK
	ADD CONSTRAINT [fk_ExportJob_FileFormat_FileFormatSID]
	FOREIGN KEY ([FileFormatSID]) REFERENCES [sf].[FileFormat] ([FileFormatSID])
ALTER TABLE [sf].[ExportJob]
	CHECK CONSTRAINT [fk_ExportJob_FileFormat_FileFormatSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the file format system ID column in the Export Job table match a file format system ID in the File Format table. It also ensures that records in the File Format table cannot be deleted if matching child records exist in Export Job. Finally, the constraint blocks changes to the value of the file format system ID column in the File Format if matching child records exist in Export Job.', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'CONSTRAINT', N'fk_ExportJob_FileFormat_FileFormatSID'
GO
ALTER TABLE [sf].[ExportJob]
	WITH CHECK
	ADD CONSTRAINT [fk_ExportJob_JobSchedule_JobScheduleSID]
	FOREIGN KEY ([JobScheduleSID]) REFERENCES [sf].[JobSchedule] ([JobScheduleSID])
ALTER TABLE [sf].[ExportJob]
	CHECK CONSTRAINT [fk_ExportJob_JobSchedule_JobScheduleSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the job schedule system ID column in the Export Job table match a job schedule system ID in the Job Schedule table. It also ensures that records in the Job Schedule table cannot be deleted if matching child records exist in Export Job. Finally, the constraint blocks changes to the value of the job schedule system ID column in the Job Schedule if matching child records exist in Export Job.', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'CONSTRAINT', N'fk_ExportJob_JobSchedule_JobScheduleSID'
GO
CREATE NONCLUSTERED INDEX [ix_ExportJob_FileFormatSID_ExportJobSID]
	ON [sf].[ExportJob] ([FileFormatSID], [ExportJobSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the File Format SID foreign key column and avoids row contention on (parent) File Format updates', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'INDEX', N'ix_ExportJob_FileFormatSID_ExportJobSID'
GO
CREATE NONCLUSTERED INDEX [ix_ExportJob_JobScheduleSID_ExportJobSID]
	ON [sf].[ExportJob] ([JobScheduleSID], [ExportJobSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Job Schedule SID foreign key column and avoids row contention on (parent) Job Schedule updates', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'INDEX', N'ix_ExportJob_JobScheduleSID_ExportJobSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the export job assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'ExportJobSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the export job to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'ExportJobName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores configuration information for automated exports. These exports must be configured by the Alinity Help Desk.  Exports are usually configured as “Jobs” that run automatically in the background according to a given schedule.  End users can modify descriptive values and the schedule assigned  but changes to technical values by end-users is not recommended as it may cause the export to fail. The system includes some standard export jobs (e.g. CIHI, Alberta Provincial Provider Registry, etc.) but these only execute when a Job-Schedule has been assigned.  Updates to the standard jobs is applied based on the setting of the “Job Code” value which must not be modifiable on the user interface. While exports are normally automated, they can be run interactively from the Utilities menu.  Note that this table is NOT used for end-user exports performed from search screens in the application.  Those exports are based on the “Data-Source” and related tables.', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'ExportJobCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The SQL syntax defining the selection of records for the query | Completing queries requires knowledge of SQL commands and the application database structure.', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'QuerySQL'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML structure used to store parameter names, data types, and other information needed to prompt the user for selection criteria to apply in the query | Query names must match values in the query SQL for replacement - e.g. "@MyParameter"', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'QueryParameters'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file format assigned to this export job', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'FileFormatSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job schedule assigned to this export job', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'JobScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this query was last used | This value can be helpful in determining queries which are not being used and can be removed from the system', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'LastExecuteTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The identity of the user who last used this query | This value can be helpful in investigating queries which are not being used to ensure they are removed from the system', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'LastExecuteUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times this query has been used | This value can be helpful in determining queries which are not being used and can be removed from the system', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'ExecuteCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the export job | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'ExportJobXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the export job | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this export job record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the export job | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the export job record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the export job record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Export Job Code column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'CONSTRAINT', N'uk_ExportJob_ExportJobCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'CONSTRAINT', N'uk_ExportJob_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Export Job Name column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ExportJob', 'CONSTRAINT', N'uk_ExportJob_ExportJobName'
GO
ALTER TABLE [sf].[ExportJob] SET (LOCK_ESCALATION = TABLE)
GO
