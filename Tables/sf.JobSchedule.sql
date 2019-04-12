SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[JobSchedule] (
		[JobScheduleSID]            [int] IDENTITY(1000001, 1) NOT NULL,
		[JobScheduleLabel]          [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsEnabled]                 [bit] NOT NULL,
		[IsRunMonday]               [bit] NOT NULL,
		[IsRunTuesday]              [bit] NOT NULL,
		[IsRunWednesday]            [bit] NOT NULL,
		[IsRunThursday]             [bit] NOT NULL,
		[IsRunFriday]               [bit] NOT NULL,
		[IsRunSaturday]             [bit] NOT NULL,
		[IsRunSunday]               [bit] NOT NULL,
		[RepeatIntervalMinutes]     [smallint] NOT NULL,
		[StartTime]                 [time](0) NOT NULL,
		[EndTime]                   [time](0) NOT NULL,
		[StartDate]                 [date] NOT NULL,
		[EndDate]                   [date] NULL,
		[UserDefinedColumns]        [xml] NULL,
		[JobScheduleXID]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_JobSchedule_JobScheduleLabel]
		UNIQUE
		NONCLUSTERED
		([JobScheduleLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_JobSchedule_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_JobSchedule]
		PRIMARY KEY
		CLUSTERED
		([JobScheduleSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Job Schedule table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'CONSTRAINT', N'pk_JobSchedule'
GO
ALTER TABLE [sf].[JobSchedule]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_JobSchedule]
	CHECK
	([sf].[fJobSchedule#Check]([JobScheduleSID],[JobScheduleLabel],[IsEnabled],[IsRunMonday],[IsRunTuesday],[IsRunWednesday],[IsRunThursday],[IsRunFriday],[IsRunSaturday],[IsRunSunday],[RepeatIntervalMinutes],[StartTime],[EndTime],[StartDate],[EndDate],[JobScheduleXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[JobSchedule]
CHECK CONSTRAINT [ck_JobSchedule]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_IsEnabled]
	DEFAULT ((1)) FOR [IsEnabled]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_IsRunMonday]
	DEFAULT ((0)) FOR [IsRunMonday]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_IsRunTuesday]
	DEFAULT ((0)) FOR [IsRunTuesday]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_IsRunWednesday]
	DEFAULT ((0)) FOR [IsRunWednesday]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_IsRunThursday]
	DEFAULT ((0)) FOR [IsRunThursday]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_IsRunFriday]
	DEFAULT ((0)) FOR [IsRunFriday]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_IsRunSaturday]
	DEFAULT ((0)) FOR [IsRunSaturday]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_IsRunSunday]
	DEFAULT ((0)) FOR [IsRunSunday]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_RepeatIntervalMinutes]
	DEFAULT ((0)) FOR [RepeatIntervalMinutes]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_StartTime]
	DEFAULT (CONVERT([time](0),'00:00:00',(0))) FOR [StartTime]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_EndTime]
	DEFAULT (CONVERT([time](0),'23:59:59',(0))) FOR [EndTime]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[JobSchedule]
	ADD
	CONSTRAINT [df_JobSchedule_StartDate]
	DEFAULT ([sf].[fToday]()) FOR [StartDate]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_JobSchedule_LegacyKey]
	ON [sf].[JobSchedule] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'INDEX', N'ux_JobSchedule_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines an optional schedule, configured as a pattern of recurrence, when 1 or more jobs should be run.  The configurator or end user may define as many jobs schedules as required.  Daily and weekly recurrence patterns, including recurrence within days, may be defined.', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the job schedule assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'JobScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the job schedule to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'JobScheduleLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates jobs using this schedule should be run.  Turn this off to prevent all jobs on the schedule from running (e.g. to pause the schedule for maintenance)', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'IsEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'IsRunMonday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'IsRunTuesday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'IsRunWednesday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'IsRunThursday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'IsRunFriday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'IsRunSaturday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'IsRunSunday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'For jobs that should repeat within days, defines the number of minutes between subsequent calls | Note that a job will not be called if it is already running - even if parallel calls are allowed.  Also, the job only repeats within the processing window defined by the start and end times.', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'RepeatIntervalMinutes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the specific time when this job should be run, or, if a repeat interval is defined, the start of processing window | This value can be used, for example, to have a job repeat every 30 minutes but only during regular business hours', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'StartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the end of the processing window in which this job should be allowed to repeat - only relevant if a Repeat Interval is defined | This value can be used, for example, to have a job repeat every 30 minutes but only during regular business hours', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'EndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the first date this schedule applies. A scheduled may be defined to begin in the future.', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'StartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the last date this schedule applies - if blank, the schedule continued indefinitely.', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the job schedule | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'JobScheduleXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the job schedule | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this job schedule record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the job schedule | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the job schedule record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job schedule record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Job Schedule Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'CONSTRAINT', N'uk_JobSchedule_JobScheduleLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'JobSchedule', 'CONSTRAINT', N'uk_JobSchedule_RowGUID'
GO
ALTER TABLE [sf].[JobSchedule] SET (LOCK_ESCALATION = TABLE)
GO
