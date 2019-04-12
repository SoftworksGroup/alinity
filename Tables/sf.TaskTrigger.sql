SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[TaskTrigger] (
		[TaskTriggerSID]              [int] IDENTITY(1000001, 1) NOT NULL,
		[TaskTriggerLabel]            [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TaskTitleTemplate]           [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TaskDescriptionTemplate]     [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[QuerySID]                    [int] NOT NULL,
		[TaskQueueSID]                [int] NOT NULL,
		[ApplicationUserSID]          [int] NULL,
		[IsAlert]                     [bit] NOT NULL,
		[PriorityLevel]               [tinyint] NOT NULL,
		[TargetCompletionDays]        [smallint] NOT NULL,
		[OpenTaskLimit]               [int] NOT NULL,
		[IsRegeneratedIfClosed]       [bit] NOT NULL,
		[ApplicationAction]           [varchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[JobScheduleSID]              [int] NULL,
		[LastStartTime]               [datetimeoffset](7) NULL,
		[LastEndTime]                 [datetimeoffset](7) NULL,
		[IsActive]                    [bit] NOT NULL,
		[UserDefinedColumns]          [xml] NULL,
		[TaskTriggerXID]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_TaskTrigger_QuerySID_TaskQueueSID]
		UNIQUE
		NONCLUSTERED
		([QuerySID], [TaskQueueSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_TaskTrigger_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_TaskTrigger_TaskTriggerLabel]
		UNIQUE
		NONCLUSTERED
		([TaskTriggerLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_TaskTrigger]
		PRIMARY KEY
		CLUSTERED
		([TaskTriggerSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Task Trigger table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'CONSTRAINT', N'pk_TaskTrigger'
GO
ALTER TABLE [sf].[TaskTrigger]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_TaskTrigger]
	CHECK
	([sf].[fTaskTrigger#Check]([TaskTriggerSID],[TaskTriggerLabel],[TaskTitleTemplate],[QuerySID],[TaskQueueSID],[ApplicationUserSID],[IsAlert],[PriorityLevel],[TargetCompletionDays],[OpenTaskLimit],[IsRegeneratedIfClosed],[ApplicationAction],[JobScheduleSID],[LastStartTime],[LastEndTime],[IsActive],[TaskTriggerXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[TaskTrigger]
CHECK CONSTRAINT [ck_TaskTrigger]
GO
ALTER TABLE [sf].[TaskTrigger]
	ADD
	CONSTRAINT [df_TaskTrigger_IsAlert]
	DEFAULT ((0)) FOR [IsAlert]
GO
ALTER TABLE [sf].[TaskTrigger]
	ADD
	CONSTRAINT [df_TaskTrigger_PriorityLevel]
	DEFAULT ((3)) FOR [PriorityLevel]
GO
ALTER TABLE [sf].[TaskTrigger]
	ADD
	CONSTRAINT [df_TaskTrigger_TargetCompletionDays]
	DEFAULT ((7)) FOR [TargetCompletionDays]
GO
ALTER TABLE [sf].[TaskTrigger]
	ADD
	CONSTRAINT [df_TaskTrigger_OpenTaskLimit]
	DEFAULT ((100)) FOR [OpenTaskLimit]
GO
ALTER TABLE [sf].[TaskTrigger]
	ADD
	CONSTRAINT [df_TaskTrigger_IsRegeneratedIfClosed]
	DEFAULT ((0)) FOR [IsRegeneratedIfClosed]
GO
ALTER TABLE [sf].[TaskTrigger]
	ADD
	CONSTRAINT [df_TaskTrigger_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[TaskTrigger]
	ADD
	CONSTRAINT [df_TaskTrigger_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[TaskTrigger]
	ADD
	CONSTRAINT [df_TaskTrigger_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[TaskTrigger]
	ADD
	CONSTRAINT [df_TaskTrigger_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[TaskTrigger]
	ADD
	CONSTRAINT [df_TaskTrigger_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[TaskTrigger]
	ADD
	CONSTRAINT [df_TaskTrigger_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[TaskTrigger]
	ADD
	CONSTRAINT [df_TaskTrigger_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[TaskTrigger]
	WITH CHECK
	ADD CONSTRAINT [fk_TaskTrigger_TaskQueue_TaskQueueSID]
	FOREIGN KEY ([TaskQueueSID]) REFERENCES [sf].[TaskQueue] ([TaskQueueSID])
ALTER TABLE [sf].[TaskTrigger]
	CHECK CONSTRAINT [fk_TaskTrigger_TaskQueue_TaskQueueSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the task queue system ID column in the Task Trigger table match a task queue system ID in the Task Queue table. It also ensures that records in the Task Queue table cannot be deleted if matching child records exist in Task Trigger. Finally, the constraint blocks changes to the value of the task queue system ID column in the Task Queue if matching child records exist in Task Trigger.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'CONSTRAINT', N'fk_TaskTrigger_TaskQueue_TaskQueueSID'
GO
ALTER TABLE [sf].[TaskTrigger]
	WITH CHECK
	ADD CONSTRAINT [fk_TaskTrigger_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
ALTER TABLE [sf].[TaskTrigger]
	CHECK CONSTRAINT [fk_TaskTrigger_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Task Trigger table match a application user system ID in the Application User table. It also ensures that records in the Application User table cannot be deleted if matching child records exist in Task Trigger. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Task Trigger.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'CONSTRAINT', N'fk_TaskTrigger_ApplicationUser_ApplicationUserSID'
GO
ALTER TABLE [sf].[TaskTrigger]
	WITH CHECK
	ADD CONSTRAINT [fk_TaskTrigger_JobSchedule_JobScheduleSID]
	FOREIGN KEY ([JobScheduleSID]) REFERENCES [sf].[JobSchedule] ([JobScheduleSID])
ALTER TABLE [sf].[TaskTrigger]
	CHECK CONSTRAINT [fk_TaskTrigger_JobSchedule_JobScheduleSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the job schedule system ID column in the Task Trigger table match a job schedule system ID in the Job Schedule table. It also ensures that records in the Job Schedule table cannot be deleted if matching child records exist in Task Trigger. Finally, the constraint blocks changes to the value of the job schedule system ID column in the Job Schedule if matching child records exist in Task Trigger.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'CONSTRAINT', N'fk_TaskTrigger_JobSchedule_JobScheduleSID'
GO
ALTER TABLE [sf].[TaskTrigger]
	WITH CHECK
	ADD CONSTRAINT [fk_TaskTrigger_Query_QuerySID]
	FOREIGN KEY ([QuerySID]) REFERENCES [sf].[Query] ([QuerySID])
ALTER TABLE [sf].[TaskTrigger]
	CHECK CONSTRAINT [fk_TaskTrigger_Query_QuerySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the query system ID column in the Task Trigger table match a query system ID in the Query table. It also ensures that records in the Query table cannot be deleted if matching child records exist in Task Trigger. Finally, the constraint blocks changes to the value of the query system ID column in the Query if matching child records exist in Task Trigger.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'CONSTRAINT', N'fk_TaskTrigger_Query_QuerySID'
GO
CREATE NONCLUSTERED INDEX [ix_TaskTrigger_ApplicationUserSID_TaskTriggerSID]
	ON [sf].[TaskTrigger] ([ApplicationUserSID], [TaskTriggerSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'INDEX', N'ix_TaskTrigger_ApplicationUserSID_TaskTriggerSID'
GO
CREATE NONCLUSTERED INDEX [ix_TaskTrigger_JobScheduleSID_TaskTriggerSID]
	ON [sf].[TaskTrigger] ([JobScheduleSID], [TaskTriggerSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Job Schedule SID foreign key column and avoids row contention on (parent) Job Schedule updates', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'INDEX', N'ix_TaskTrigger_JobScheduleSID_TaskTriggerSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TaskTrigger_LegacyKey]
	ON [sf].[TaskTrigger] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'INDEX', N'ux_TaskTrigger_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_TaskTrigger_QuerySID_TaskTriggerSID]
	ON [sf].[TaskTrigger] ([QuerySID], [TaskTriggerSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Query SID foreign key column and avoids row contention on (parent) Query updates', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'INDEX', N'ix_TaskTrigger_QuerySID_TaskTriggerSID'
GO
CREATE NONCLUSTERED INDEX [ix_TaskTrigger_TaskQueueSID_TaskTriggerSID]
	ON [sf].[TaskTrigger] ([TaskQueueSID], [TaskTriggerSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Task Queue SID foreign key column and avoids row contention on (parent) Task Queue updates', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'INDEX', N'ix_TaskTrigger_TaskQueueSID_TaskTriggerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table allows configurators to automate task creation.  A trigger is made up of a query that isolates records for which tasks should be created.  The text for the task is defined along with a name.  An application page to navigate to when the task is selected is associated through the Query record.  A schedule may be assigned to the trigger to re-run the query to look for new tasks to create at regular intervals.  Additional values may be defined on the trigger to indicate when the tasks should be considered late and the maximum number of tasks of the type that should be open.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the task trigger assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'TaskTriggerSID'
GO
EXEC sp_addextendedproperty N'MSDescription', N'A unique sequence number assigned by the application to identify the record.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'TaskTriggerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the task trigger to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'TaskTriggerLabel'
GO
EXEC sp_addextendedproperty N'MSDescription', N'THe tamplate used to create the Task name.  Task name Templates may use variables to dynamicaly create the Task.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'TaskTriggerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The title to give the task created - may include replacement values | Replacement values available are defined by the application e.g. "{ContactName}"', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'TaskTitleTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The description of work to give to the task - may include replacement values | Replacement values available are defined by the application e.g. "{ContactName}"', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'TaskDescriptionTemplate'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The text of the message to be supplied to a user for investigation.  May include variables to make the description dynamic.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'TaskDescriptionTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A reference to the query that locates records for which tasks need to be created | The query does not need to exclude records where open tasks already exist as duplicates are avoided by the built-in task trigger processor', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'QuerySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The task queue assigned to this task trigger', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'TaskQueueSID'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The unique identifier assigned to the Task queue used to relate the trigger to a Task queue.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'TaskQueueSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A reference to a specific application user if tasks generated by this trigger should automatically be assigned to the same person | This option is useful where one person is responsible for triaging and assigning all tasks in a queue (or there is only a single queue subscriber)', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this task trigger should generate an "alert" type task | Alert tasks are created and assigned to all users in the queue', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'IsAlert'
GO
EXEC sp_addextendedproperty N'MSDescription', N'Identifies if the trigger is an alert.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'IsAlert'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A ranking value indicating the priority of this task compared with others - scale is 1-5 with "3" being medium (default) | The due date and this value are used to sort tasks in priority sequence on the user interface', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Establishes the due date for tasks generated as the creation date + this number of days', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'TargetCompletionDays'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The number of days a Task should take before being closed.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'TargetCompletionDays'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Limits the total number of open tasks of this type allowed by the system - must be 1 or greater | This value is used in situations where the query may return hundreds or thousands of task records.  The limit ensures a manageable number of open tasks of this type will be allowed in the system at the same time.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'OpenTaskLimit'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The maximum number of Tasks of this type that may be open.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'OpenTaskLimit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates a new task should be created, even where a task for the record exists, if the old task is closed', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'IsRegeneratedIfClosed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This field contains technical information set by your configurator that controls the view the application displays when this task is accessed | This value applies in Model-View-Controller architectures. This is the "Action" called within the Controller when the user clicks/touches the task.   This data and the “Application Controller” value are used to complete the navigation. The “Application Page URI” columns is provided for Silverlight architectures. This value is included on the Task record as well as on the Task Trigger to allow users to create navigating-tasks, such as from the Application User module.   In these situations the application sets the value directly.  For task triggers, the value must be set by the configurator.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'ApplicationAction'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the job schedule assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'JobScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time processing for this specific task trigger began | This value is used in determining when the trigger should be run next when a schedule is assigned', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'LastStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the trigger completed successfully, failed, or was cancelled through the Task Trigger job | Records where this value is not filled in are considered to be running', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'LastEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this task trigger record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the task trigger | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'TaskTriggerXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the task trigger | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this task trigger record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the task trigger | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the task trigger record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the task trigger record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Query SID + Task Queue SID" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'CONSTRAINT', N'uk_TaskTrigger_QuerySID_TaskQueueSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'CONSTRAINT', N'uk_TaskTrigger_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Task Trigger Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TaskTrigger', 'CONSTRAINT', N'uk_TaskTrigger_TaskTriggerLabel'
GO
ALTER TABLE [sf].[TaskTrigger] SET (LOCK_ESCALATION = TABLE)
GO
