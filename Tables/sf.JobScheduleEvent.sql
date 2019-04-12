SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[JobScheduleEvent] (
		[JobScheduleEventSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[EventName]               [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EventDescription]        [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]      [xml] NULL,
		[JobScheduleEventXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]               [bit] NOT NULL,
		[CreateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]              [datetimeoffset](7) NOT NULL,
		[UpdateUser]              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]              [datetimeoffset](7) NOT NULL,
		[RowGUID]                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                [timestamp] NOT NULL,
		CONSTRAINT [uk_JobScheduleEvent_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_JobScheduleEvent]
		PRIMARY KEY
		CLUSTERED
		([JobScheduleEventSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Job Schedule Event table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'CONSTRAINT', N'pk_JobScheduleEvent'
GO
ALTER TABLE [sf].[JobScheduleEvent]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_JobScheduleEvent]
	CHECK
	([sf].[fJobScheduleEvent#Check]([JobScheduleEventSID],[EventName],[JobScheduleEventXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[JobScheduleEvent]
CHECK CONSTRAINT [ck_JobScheduleEvent]
GO
ALTER TABLE [sf].[JobScheduleEvent]
	ADD
	CONSTRAINT [df_JobScheduleEvent_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[JobScheduleEvent]
	ADD
	CONSTRAINT [df_JobScheduleEvent_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[JobScheduleEvent]
	ADD
	CONSTRAINT [df_JobScheduleEvent_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[JobScheduleEvent]
	ADD
	CONSTRAINT [df_JobScheduleEvent_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[JobScheduleEvent]
	ADD
	CONSTRAINT [df_JobScheduleEvent_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[JobScheduleEvent]
	ADD
	CONSTRAINT [df_JobScheduleEvent_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_JobScheduleEvent_LegacyKey]
	ON [sf].[JobScheduleEvent] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'INDEX', N'ux_JobScheduleEvent_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Job Schedule Event table logs actions that occur on the schedule.  The data captured is used to verify that the schedule is being read at regular intervals.  It also records the procedures that were considered “due” for calling.  This information can help administrators and the Help Desk investigate issues related to scheduled jobs.    The main event types supported are:  Schedule Started, Scheduled Stopped, Schedule Read, and Job Called.  Details for each type of event is stored in the Event Description column.   Purging of this table occurs automatically.  The system retains records according to the value set for the “Log Retention Months” configuration parameter. The default value is 3 months.', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the job schedule event assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'JobScheduleEventSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A title for the scheduling event that occurred – assigned by the system:  Schedule Started, Scheduled Stopped, Schedule Read, and Job Called.', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'EventName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the event including the name of procedures called for scheduled jobs.', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'EventDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the job schedule event | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'JobScheduleEventXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the job schedule event | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this job schedule event record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the job schedule event | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the job schedule event record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job schedule event record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'JobScheduleEvent', 'CONSTRAINT', N'uk_JobScheduleEvent_RowGUID'
GO
ALTER TABLE [sf].[JobScheduleEvent] SET (LOCK_ESCALATION = TABLE)
GO
