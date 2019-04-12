SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[JobRun] (
		[JobRunSID]                   [int] IDENTITY(1000001, 1) NOT NULL,
		[JobSID]                      [int] NOT NULL,
		[ConversationHandle]          [uniqueidentifier] NOT NULL,
		[CallSyntax]                  [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[StartTime]                   [datetimeoffset](7) NOT NULL,
		[EndTime]                     [datetimeoffset](7) NULL,
		[TotalRecords]                [int] NOT NULL,
		[TotalErrors]                 [int] NOT NULL,
		[RecordsProcessed]            [int] NOT NULL,
		[CurrentProcessLabel]         [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsFailed]                    [bit] NOT NULL,
		[IsFailureCleared]            [bit] NOT NULL,
		[CancellationRequestTime]     [datetimeoffset](7) NULL,
		[IsCancelled]                 [bit] NOT NULL,
		[ResultMessage]               [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TraceLog]                    [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]          [xml] NULL,
		[JobRunXID]                   [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_JobRun_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [uk_JobRun_ConversationHandle]
		UNIQUE
		NONCLUSTERED
		([ConversationHandle])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_JobRun]
		PRIMARY KEY
		CLUSTERED
		([JobRunSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Job Run table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'CONSTRAINT', N'pk_JobRun'
GO
ALTER TABLE [sf].[JobRun]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_JobRun]
	CHECK
	([sf].[fJobRun#Check]([JobRunSID],[JobSID],[ConversationHandle],[StartTime],[EndTime],[TotalRecords],[TotalErrors],[RecordsProcessed],[CurrentProcessLabel],[IsFailed],[IsFailureCleared],[CancellationRequestTime],[IsCancelled],[JobRunXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[JobRun]
CHECK CONSTRAINT [ck_JobRun]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_StartTime]
	DEFAULT (sysdatetimeoffset()) FOR [StartTime]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_TotalRecords]
	DEFAULT ((0)) FOR [TotalRecords]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_TotalErrors]
	DEFAULT ((0)) FOR [TotalErrors]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_RecordsProcessed]
	DEFAULT ((0)) FOR [RecordsProcessed]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_IsFailed]
	DEFAULT (CONVERT([bit],(0),(0))) FOR [IsFailed]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_IsFailureCleared]
	DEFAULT ((0)) FOR [IsFailureCleared]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_IsCancelled]
	DEFAULT (CONVERT([bit],(0),(0))) FOR [IsCancelled]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[JobRun]
	ADD
	CONSTRAINT [df_JobRun_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[JobRun]
	WITH CHECK
	ADD CONSTRAINT [fk_JobRun_Job_JobSID]
	FOREIGN KEY ([JobSID]) REFERENCES [sf].[Job] ([JobSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[JobRun]
	CHECK CONSTRAINT [fk_JobRun_Job_JobSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the job system ID column in the Job Run table match a job system ID in the Job table. It also ensures that when a record in the Job table is deleted, matching child records in the Job Run table are deleted as well. Finally, the constraint blocks changes to the value of the job system ID column in the Job if matching child records exist in Job Run.', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'CONSTRAINT', N'fk_JobRun_Job_JobSID'
GO
CREATE NONCLUSTERED INDEX [ix_JobRun_JobSID_JobRunSID]
	ON [sf].[JobRun] ([JobSID], [JobRunSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Job SID foreign key column and avoids row contention on (parent) Job updates', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'INDEX', N'ix_JobRun_JobSID_JobRunSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_JobRun_LegacyKey]
	ON [sf].[JobRun] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'INDEX', N'ux_JobRun_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the job run assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'JobRunSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job this run is defined for', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'JobSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An internal system value used to coordinate communication about job status within the SQL Server message broker service', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'ConversationHandle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The TSQL syntax used to call the procedure', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'CallSyntax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the job began running', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'StartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the job completed successfully, failed, or was cancelled | Job run records where this value is not filled in are considered to be running', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'EndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The total count of records to process in the job (if set) | This value must be set by the job procedure at startup.  The value is used for calculating percent complete and estimated time of completion.', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'TotalRecords'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The total number of errors encountered during the job run | This value must be set by the job procedure as errors are encountered.  The value is used in status reporting and may be used to abort the job automatically if the error rate exceeds the max rate defined in the Job table (only applies where at least 100 records have been processed).', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'TotalErrors'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The count of records processed in the job so far (if set) | This value must be set by the job procedure as records are processed. The value is used for calculating percent complete and estimated time of completion.', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'RecordsProcessed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier displayed on the job monitoring screen in the UI advising the user what stage or operation is currently being carried out by the job - e.g. "Retrieving Records ..." | Note that the value can be replaced for display on the UI by defining a mapping record in sf.TermLabel', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'CurrentProcessLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job ended in an error or was aborted because the maximum error ratio, as defined in the Job table, was exceeded', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'IsFailed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that the failed status of the job has been cleared so that it can be run again if a "max retry on failure" limit was set for the job | This value is only enabled in the UI if the job run is showing a failed status', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'IsFailureCleared'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time a request to cancel the job was made | If the job is non-responsive, the cancellation will not occur and the job must be set to Failed manually from the Job Management screen', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'CancellationRequestTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job was cancelled before it completed', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'IsCancelled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A summary of the job result (if set) | This value must be set by the procedure the job is based on when it finishes or fails or is cancelled. | The procedure should use a MessageSCD from the sf.Message table to support globalization of this value', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'ResultMessage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A log of errors and, if Full Trace is enabled on the job run, of interim steps useful in investigating problems', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'TraceLog'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the job run | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'JobRunXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the job run | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this job run record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the job run | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the job run record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job run record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'CONSTRAINT', N'uk_JobRun_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Conversation Handle column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'JobRun', 'CONSTRAINT', N'uk_JobRun_ConversationHandle'
GO
ALTER TABLE [sf].[JobRun] SET (LOCK_ESCALATION = TABLE)
GO
