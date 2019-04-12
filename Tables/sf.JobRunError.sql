SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[JobRunError] (
		[JobRunErrorSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[JobRunSID]              [int] NOT NULL,
		[MessageText]            [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DataSource]             [nvarchar](257) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RecordKey]              [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[JobRunErrorXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_JobRunError_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_JobRunError]
		PRIMARY KEY
		CLUSTERED
		([JobRunErrorSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Job Run Error table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'CONSTRAINT', N'pk_JobRunError'
GO
ALTER TABLE [sf].[JobRunError]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_JobRunError]
	CHECK
	([sf].[fJobRunError#Check]([JobRunErrorSID],[JobRunSID],[MessageText],[DataSource],[RecordKey],[JobRunErrorXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[JobRunError]
CHECK CONSTRAINT [ck_JobRunError]
GO
ALTER TABLE [sf].[JobRunError]
	ADD
	CONSTRAINT [df_JobRunError_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[JobRunError]
	ADD
	CONSTRAINT [df_JobRunError_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[JobRunError]
	ADD
	CONSTRAINT [df_JobRunError_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[JobRunError]
	ADD
	CONSTRAINT [df_JobRunError_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[JobRunError]
	ADD
	CONSTRAINT [df_JobRunError_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[JobRunError]
	ADD
	CONSTRAINT [df_JobRunError_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[JobRunError]
	WITH CHECK
	ADD CONSTRAINT [fk_JobRunError_JobRun_JobRunSID]
	FOREIGN KEY ([JobRunSID]) REFERENCES [sf].[JobRun] ([JobRunSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[JobRunError]
	CHECK CONSTRAINT [fk_JobRunError_JobRun_JobRunSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the job run system ID column in the Job Run Error table match a job run system ID in the Job Run table. It also ensures that when a record in the Job Run table is deleted, matching child records in the Job Run Error table are deleted as well. Finally, the constraint blocks changes to the value of the job run system ID column in the Job Run if matching child records exist in Job Run Error.', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'CONSTRAINT', N'fk_JobRunError_JobRun_JobRunSID'
GO
CREATE NONCLUSTERED INDEX [ix_JobRunError_JobRunSID_JobRunErrorSID]
	ON [sf].[JobRunError] ([JobRunSID], [JobRunErrorSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Job Run SID foreign key column and avoids row contention on (parent) Job Run updates', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'INDEX', N'ix_JobRunError_JobRunSID_JobRunErrorSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table can be used to record errors from job runs.  The error message and reference to the data source and key value where the error originated from is also stored.  Note that since jobs may include write events to external databases, the key value is stored as a string.', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the job run error assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'JobRunErrorSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job run this error is defined for', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'JobRunSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The schema and name of the table view or other database object which is the source of the error. | This value is not validated and may reference objects in an external database.', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'DataSource'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key value of the record where the error originated | This value is stored as a string to allow capture from non-Softworks systems where keys may not be numeric and may involve multiple columns', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'RecordKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the job run error | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'JobRunErrorXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the job run error | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this job run error record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the job run error | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the job run error record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job run error record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'JobRunError', 'CONSTRAINT', N'uk_JobRunError_RowGUID'
GO
ALTER TABLE [sf].[JobRunError] SET (LOCK_ESCALATION = TABLE)
GO
