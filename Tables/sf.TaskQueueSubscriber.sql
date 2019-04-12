SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[TaskQueueSubscriber] (
		[TaskQueueSubscriberSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[TaskQueueSID]               [int] NOT NULL,
		[ApplicationUserSID]         [int] NOT NULL,
		[EffectiveTime]              [datetime] NOT NULL,
		[ExpiryTime]                 [datetime] NULL,
		[IsNewTaskEmailed]           [bit] NOT NULL,
		[IsDailySummaryEmailed]      [bit] NOT NULL,
		[ChangeAudit]                [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[TaskQueueSubscriberXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_TaskQueueSubscriber_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_TaskQueueSubscriber]
		PRIMARY KEY
		CLUSTERED
		([TaskQueueSubscriberSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Task Queue Subscriber table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'CONSTRAINT', N'pk_TaskQueueSubscriber'
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_TaskQueueSubscriber]
	CHECK
	([sf].[fTaskQueueSubscriber#Check]([TaskQueueSubscriberSID],[TaskQueueSID],[ApplicationUserSID],[EffectiveTime],[ExpiryTime],[IsNewTaskEmailed],[IsDailySummaryEmailed],[TaskQueueSubscriberXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
CHECK CONSTRAINT [ck_TaskQueueSubscriber]
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
	ADD
	CONSTRAINT [df_TaskQueueSubscriber_IsNewTaskEmailed]
	DEFAULT ((0)) FOR [IsNewTaskEmailed]
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
	ADD
	CONSTRAINT [df_TaskQueueSubscriber_IsDailySummaryEmailed]
	DEFAULT ((0)) FOR [IsDailySummaryEmailed]
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
	ADD
	CONSTRAINT [df_TaskQueueSubscriber_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
	ADD
	CONSTRAINT [df_TaskQueueSubscriber_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
	ADD
	CONSTRAINT [df_TaskQueueSubscriber_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
	ADD
	CONSTRAINT [df_TaskQueueSubscriber_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
	ADD
	CONSTRAINT [df_TaskQueueSubscriber_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
	ADD
	CONSTRAINT [df_TaskQueueSubscriber_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
	ADD
	CONSTRAINT [df_TaskQueueSubscriber_EffectiveTime]
	DEFAULT ([sf].[fNow]()) FOR [EffectiveTime]
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
	WITH CHECK
	ADD CONSTRAINT [fk_TaskQueueSubscriber_TaskQueue_TaskQueueSID]
	FOREIGN KEY ([TaskQueueSID]) REFERENCES [sf].[TaskQueue] ([TaskQueueSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[TaskQueueSubscriber]
	CHECK CONSTRAINT [fk_TaskQueueSubscriber_TaskQueue_TaskQueueSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the task queue system ID column in the Task Queue Subscriber table match a task queue system ID in the Task Queue table. It also ensures that when a record in the Task Queue table is deleted, matching child records in the Task Queue Subscriber table are deleted as well. Finally, the constraint blocks changes to the value of the task queue system ID column in the Task Queue if matching child records exist in Task Queue Subscriber.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'CONSTRAINT', N'fk_TaskQueueSubscriber_TaskQueue_TaskQueueSID'
GO
ALTER TABLE [sf].[TaskQueueSubscriber]
	WITH CHECK
	ADD CONSTRAINT [fk_TaskQueueSubscriber_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[TaskQueueSubscriber]
	CHECK CONSTRAINT [fk_TaskQueueSubscriber_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Task Queue Subscriber table match a application user system ID in the Application User table. It also ensures that when a record in the Application User table is deleted, matching child records in the Task Queue Subscriber table are deleted as well. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Task Queue Subscriber.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'CONSTRAINT', N'fk_TaskQueueSubscriber_ApplicationUser_ApplicationUserSID'
GO
CREATE NONCLUSTERED INDEX [ix_TaskQueueSubscriber_ApplicationUserSID_TaskQueueSubscriberSID]
	ON [sf].[TaskQueueSubscriber] ([ApplicationUserSID], [TaskQueueSubscriberSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'INDEX', N'ix_TaskQueueSubscriber_ApplicationUserSID_TaskQueueSubscriberSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TaskQueueSubscriber_LegacyKey]
	ON [sf].[TaskQueueSubscriber] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'INDEX', N'ux_TaskQueueSubscriber_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_TaskQueueSubscriber_TaskQueueSID_TaskQueueSubscriberSID]
	ON [sf].[TaskQueueSubscriber] ([TaskQueueSID], [TaskQueueSubscriberSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Task Queue SID foreign key column and avoids row contention on (parent) Task Queue updates', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'INDEX', N'ix_TaskQueueSubscriber_TaskQueueSID_TaskQueueSubscriberSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Individuals who are eligible for taking ownership of tasks in a queue are referred to as subscribers. If the queue is an "open subscription" type, then users can assign themselves to it. For closed queues, users must be assigned by a manager.  Once the user has been assigned to a queue they can see tasks not yet owned in the queue and can take ownership.  Other details of queue membership can be configured through values on the record.  Audit information of when users are assigned and unassigned on queues is also maintained.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the task queue subscriber assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'TaskQueueSubscriberSID'
GO
EXEC sp_addextendedproperty N'MSDescription', N'A unique sequence number assigned by the application to identify the record.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'TaskQueueSubscriberSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The task queue this subscriber is defined for', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'TaskQueueSID'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The unique number assigned to the Task queue used to relate the Task subscriber to the Task queue.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'TaskQueueSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this task queue subscriber', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this subscription was put into effect or most recently changed | Check Change Audit column for history', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ending time this subscription was effective.  When blank indicates subscription is active. | See Change Audit for history of subscription being turned on/off', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Directs the system to send an email to subscriber whenever a new task is assigned | It is recommended this value be left off for regular application users since open tasks are displayed on the dashboard', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'IsNewTaskEmailed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Directs the system to send a daily email to the subscriber summarizing open and late tasks associated with this subscription | It is recommended this value be left off for regular application users since tasks status is displayed on the dashboard', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'IsDailySummaryEmailed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'History of changes to this subscription | The UI prompts for a reason for disabling or re-enabling the subscription record and this reason, along with other audit information, is stored into this audit column.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'ChangeAudit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the task queue subscriber | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'TaskQueueSubscriberXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the task queue subscriber | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this task queue subscriber record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the task queue subscriber | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the task queue subscriber record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the task queue subscriber record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TaskQueueSubscriber', 'CONSTRAINT', N'uk_TaskQueueSubscriber_RowGUID'
GO
ALTER TABLE [sf].[TaskQueueSubscriber] SET (LOCK_ESCALATION = TABLE)
GO
