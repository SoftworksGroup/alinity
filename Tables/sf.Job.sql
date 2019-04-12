SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[Job] (
		[JobSID]                         [int] IDENTITY(1000001, 1) NOT NULL,
		[JobSCD]                         [varchar](132) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[JobLabel]                       [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[JobDescription]                 [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CallSyntaxTemplate]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsCancelEnabled]                [bit] NOT NULL,
		[IsParallelEnabled]              [bit] NOT NULL,
		[IsFullTraceEnabled]             [bit] NOT NULL,
		[IsAlertOnSuccessEnabled]        [bit] NOT NULL,
		[JobScheduleSID]                 [int] NULL,
		[JobScheduleSequence]            [int] NOT NULL,
		[IsRunAfterPredecessorsOnly]     [bit] NOT NULL,
		[MaxErrorRate]                   [int] NOT NULL,
		[MaxRetriesOnFailure]            [tinyint] NOT NULL,
		[TraceLog]                       [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsActive]                       [bit] NOT NULL,
		[UserDefinedColumns]             [xml] NULL,
		[JobXID]                         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                      [bit] NOT NULL,
		[CreateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                     [datetimeoffset](7) NOT NULL,
		[UpdateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                     [datetimeoffset](7) NOT NULL,
		[RowGUID]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                       [timestamp] NOT NULL,
		CONSTRAINT [uk_Job_JobLabel]
		UNIQUE
		NONCLUSTERED
		([JobLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Job_JobSCD]
		UNIQUE
		NONCLUSTERED
		([JobSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Job_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Job]
		PRIMARY KEY
		CLUSTERED
		([JobSID])
	WITH FILLFACTOR=90
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Job table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'Job', 'CONSTRAINT', N'pk_Job'
GO
ALTER TABLE [sf].[Job]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Job]
	CHECK
	([sf].[fJob#Check]([JobSID],[JobSCD],[JobLabel],[IsCancelEnabled],[IsParallelEnabled],[IsFullTraceEnabled],[IsAlertOnSuccessEnabled],[JobScheduleSID],[JobScheduleSequence],[IsRunAfterPredecessorsOnly],[MaxErrorRate],[MaxRetriesOnFailure],[IsActive],[JobXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[Job]
CHECK CONSTRAINT [ck_Job]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_IsCancelEnabled]
	DEFAULT ((1)) FOR [IsCancelEnabled]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_IsParallelEnabled]
	DEFAULT ((0)) FOR [IsParallelEnabled]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_IsFullTraceEnabled]
	DEFAULT ((0)) FOR [IsFullTraceEnabled]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_IsAlertOnSuccessEnabled]
	DEFAULT ((0)) FOR [IsAlertOnSuccessEnabled]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_JobScheduleSequence]
	DEFAULT ((50)) FOR [JobScheduleSequence]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_IsRunAfterPredecessorsOnly]
	DEFAULT ((0)) FOR [IsRunAfterPredecessorsOnly]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_MaxErrorRate]
	DEFAULT ((0)) FOR [MaxErrorRate]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_MaxRetriesOnFailure]
	DEFAULT ((0)) FOR [MaxRetriesOnFailure]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[Job]
	ADD
	CONSTRAINT [df_Job_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[Job]
	WITH CHECK
	ADD CONSTRAINT [fk_Job_JobSchedule_JobScheduleSID]
	FOREIGN KEY ([JobScheduleSID]) REFERENCES [sf].[JobSchedule] ([JobScheduleSID])
ALTER TABLE [sf].[Job]
	CHECK CONSTRAINT [fk_Job_JobSchedule_JobScheduleSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the job schedule system ID column in the Job table match a job schedule system ID in the Job Schedule table. It also ensures that records in the Job Schedule table cannot be deleted if matching child records exist in Job. Finally, the constraint blocks changes to the value of the job schedule system ID column in the Job Schedule if matching child records exist in Job.', 'SCHEMA', N'sf', 'TABLE', N'Job', 'CONSTRAINT', N'fk_Job_JobSchedule_JobScheduleSID'
GO
CREATE NONCLUSTERED INDEX [ix_Job_JobScheduleSID_JobSID]
	ON [sf].[Job] ([JobScheduleSID], [JobSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Job Schedule SID foreign key column and avoids row contention on (parent) Job Schedule updates', 'SCHEMA', N'sf', 'TABLE', N'Job', 'INDEX', N'ix_Job_JobScheduleSID_JobSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Job_LegacyKey]
	ON [sf].[Job] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'Job', 'INDEX', N'ux_Job_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table defines the list of jobs in the system that can be run asynchronously.  The job system code (JobSCD) is the name of the stored procedure that is executed.  The JobSCD and CallSyntaxTemplate values cannot are shipped with the product and cannot be modified but most other values can be changed by configurators.  For asychronous calls from the UI, the call syntax template may include replaceable parameters that are then converted to the "CallSyntax" value stored in the JobRun table and executed dynamically. For scheduled jobs, the CallSyntaxTemplate must be literal. If a job is not scheduled - only ever called from the UI - the JobScheduleSID will be null.', 'SCHEMA', N'sf', 'TABLE', N'Job', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the job assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'JobSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the job | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'JobSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the job to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'JobLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the job and its intended use.  Include recommendations for schedule to assign where required.', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'JobDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The TSQL syntax used to call the procedure | This value may contain replacement values where the procedure is called from the user interface.  If the syntax contains replacement values, then the job cannot be put on a schedule (JobScheduleSID must remain NULL).', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'CallSyntaxTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether or not this job can be cancelled by the user once in progress.', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'IsCancelEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether multiple instances of this job can be run at the same time | If not enabled, attempts to call the procedure a second time while another copy is running block the second call', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'IsParallelEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a detailed log of job progress should be stored in addition to recording error messages  | This value is used for debugging by the Help Desk and should generally be turned off to allow processes to run more quickly.', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'IsFullTraceEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates an alert should be sent summarizing the results of the job when it completes successfully | Note that alerts on errors are always sent.  The alert is sent to the queue specified.', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'IsAlertOnSuccessEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job schedule assigned to this job - if any | If the job was not scheduled, this value is blank.', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'JobScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number used to control the order this job will start compared with other jobs assigned to the same schedule', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'JobScheduleSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this job should only be run when other jobs assigned to the same schedule and started earlier have completed successfully | To enable a schedule must be assigned and sequence number must be greater than 0', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'IsRunAfterPredecessorsOnly'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum error rate, as a percent of all records processed, that should be allowed to occur in the process before it automatically aborts (0 for no limit) | Note that this value is not considered until at least 100 records have been processed so the parameter has no impact on jobs with record counts < 100.', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'MaxErrorRate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'For scheduled jobs, the maximum number of consecutive occurrences of the job should be called where they end in failure - 0 for no limit| Failed jobs with the IsFailureCleared bit set to 1 in the Job Run table are not included in this count', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'MaxRetriesOnFailure'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A system-maintained log of calls to this job used by the Help Desk in support and troubleshooting of the application. | The log is only populated when the Is-Full-Trace-Enabled column is = 1 (ON)', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'TraceLog'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this job record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the job | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'JobXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the job | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this job record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the job | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the job record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'Job', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Job Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Job', 'CONSTRAINT', N'uk_Job_JobLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Job SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Job', 'CONSTRAINT', N'uk_Job_JobSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Job', 'CONSTRAINT', N'uk_Job_RowGUID'
GO
ALTER TABLE [sf].[Job] SET (LOCK_ESCALATION = TABLE)
GO
