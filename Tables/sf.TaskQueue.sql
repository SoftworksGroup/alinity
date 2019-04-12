SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[TaskQueue] (
		[TaskQueueSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[TaskQueueLabel]         [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TaskQueueCode]          [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsAutoAssigned]         [bit] NOT NULL,
		[IsOpenSubscription]     [bit] NOT NULL,
		[ApplicationUserSID]     [int] NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[TaskQueueXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_TaskQueue_TaskQueueLabel]
		UNIQUE
		NONCLUSTERED
		([TaskQueueLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_TaskQueue_TaskQueueCode]
		UNIQUE
		NONCLUSTERED
		([TaskQueueCode])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_TaskQueue_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_TaskQueue]
		PRIMARY KEY
		CLUSTERED
		([TaskQueueSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Task Queue table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'CONSTRAINT', N'pk_TaskQueue'
GO
ALTER TABLE [sf].[TaskQueue]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_TaskQueue]
	CHECK
	([sf].[fTaskQueue#Check]([TaskQueueSID],[TaskQueueLabel],[TaskQueueCode],[IsAutoAssigned],[IsOpenSubscription],[ApplicationUserSID],[IsActive],[IsDefault],[TaskQueueXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[TaskQueue]
CHECK CONSTRAINT [ck_TaskQueue]
GO
ALTER TABLE [sf].[TaskQueue]
	ADD
	CONSTRAINT [df_TaskQueue_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[TaskQueue]
	ADD
	CONSTRAINT [df_TaskQueue_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[TaskQueue]
	ADD
	CONSTRAINT [df_TaskQueue_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[TaskQueue]
	ADD
	CONSTRAINT [df_TaskQueue_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[TaskQueue]
	ADD
	CONSTRAINT [df_TaskQueue_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[TaskQueue]
	ADD
	CONSTRAINT [df_TaskQueue_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[TaskQueue]
	ADD
	CONSTRAINT [df_TaskQueue_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[TaskQueue]
	ADD
	CONSTRAINT [df_TaskQueue_IsAutoAssigned]
	DEFAULT ((0)) FOR [IsAutoAssigned]
GO
ALTER TABLE [sf].[TaskQueue]
	ADD
	CONSTRAINT [df_TaskQueue_IsOpenSubscription]
	DEFAULT ((1)) FOR [IsOpenSubscription]
GO
ALTER TABLE [sf].[TaskQueue]
	ADD
	CONSTRAINT [df_TaskQueue_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[TaskQueue]
	WITH CHECK
	ADD CONSTRAINT [fk_TaskQueue_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
ALTER TABLE [sf].[TaskQueue]
	CHECK CONSTRAINT [fk_TaskQueue_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Task Queue table match a application user system ID in the Application User table. It also ensures that records in the Application User table cannot be deleted if matching child records exist in Task Queue. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Task Queue.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'CONSTRAINT', N'fk_TaskQueue_ApplicationUser_ApplicationUserSID'
GO
CREATE NONCLUSTERED INDEX [ix_TaskQueue_ApplicationUserSID_TaskQueueSID]
	ON [sf].[TaskQueue] ([ApplicationUserSID], [TaskQueueSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'INDEX', N'ix_TaskQueue_ApplicationUserSID_TaskQueueSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TaskQueue_IsDefault]
	ON [sf].[TaskQueue] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Task Queue', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'INDEX', N'ux_TaskQueue_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TaskQueue_LegacyKey]
	ON [sf].[TaskQueue] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'INDEX', N'ux_TaskQueue_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tasks in the system are organized into groups called "Queues".  Each queue may have a different manager responsible for the tasks in the group and for late task follow-up.  Individuals who are eligible for taking ownership of tasks in a queue are referred to as Queue Subscribers. If the queue is an "open subscription" type, then users can assign themselves to it. For closed queues, users must be assigned by a manager.  Other details of queue management can be configured through values on the record.  Audit information of when managers are assigned or changed is also maintained.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the task queue assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'TaskQueueSID'
GO
EXEC sp_addextendedproperty N'MSDescription', N'A unique sequence number assigned by the application to identify the record.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'TaskQueueSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the task queue to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'TaskQueueLabel'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The name given to this Task queue.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'TaskQueueLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the scenarios this task queue is intended to support', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates new users are automatically assigned to this queue | Note that value only impacts creation of new users.  If this setting is checked after users have already been created, they are not automatically assigned to the queue.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'IsAutoAssigned'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that any user can assign themselves to this task queue', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'IsOpenSubscription'
GO
EXEC sp_addextendedproperty N'MSDescription', N'Open subscriptions allow users to subscribe and unsubscribe to this queue at their leisure.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'IsOpenSubscription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this task queue', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this task queue record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default task queue to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the task queue | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'TaskQueueXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the task queue | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this task queue record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the task queue | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the task queue record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the task queue record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Task Queue Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'CONSTRAINT', N'uk_TaskQueue_TaskQueueLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Task Queue Code column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'CONSTRAINT', N'uk_TaskQueue_TaskQueueCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TaskQueue', 'CONSTRAINT', N'uk_TaskQueue_RowGUID'
GO
ALTER TABLE [sf].[TaskQueue] SET (LOCK_ESCALATION = TABLE)
GO
