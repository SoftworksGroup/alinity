SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[Task] (
		[TaskSID]                [int] IDENTITY(1000001, 1) NOT NULL,
		[TaskTitle]              [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TaskQueueSID]           [int] NOT NULL,
		[TargetRowGUID]          [uniqueidentifier] NULL,
		[TaskDescription]        [varbinary](max) NULL,
		[IsAlert]                [bit] NOT NULL,
		[PriorityLevel]          [tinyint] NOT NULL,
		[ApplicationUserSID]     [int] NULL,
		[TaskStatusSID]          [int] NOT NULL,
		[AssignedTime]           [datetimeoffset](7) NULL,
		[DueDate]                [date] NOT NULL,
		[NextFollowUpDate]       [date] NULL,
		[ClosedTime]             [datetimeoffset](7) NULL,
		[ApplicationPageSID]     [int] NULL,
		[TaskTriggerSID]         [int] NULL,
		[RecipientList]          [xml] NOT NULL,
		[TagList]                [xml] NOT NULL,
		[FileExtension]          [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[TaskXID]                [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_Task_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Task]
		PRIMARY KEY
		CLUSTERED
		([TaskSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Task table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'Task', 'CONSTRAINT', N'pk_Task'
GO
ALTER TABLE [sf].[Task]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Task]
	CHECK
	([sf].[fTask#Check]([TaskSID],[TaskTitle],[TaskQueueSID],[TargetRowGUID],[IsAlert],[PriorityLevel],[ApplicationUserSID],[TaskStatusSID],[AssignedTime],[DueDate],[NextFollowUpDate],[ClosedTime],[ApplicationPageSID],[TaskTriggerSID],[FileExtension],[TaskXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[Task]
CHECK CONSTRAINT [ck_Task]
GO
ALTER TABLE [sf].[Task]
	ADD
	CONSTRAINT [df_Task_IsAlert]
	DEFAULT ((0)) FOR [IsAlert]
GO
ALTER TABLE [sf].[Task]
	ADD
	CONSTRAINT [df_Task_PriorityLevel]
	DEFAULT ((3)) FOR [PriorityLevel]
GO
ALTER TABLE [sf].[Task]
	ADD
	CONSTRAINT [df_Task_RecipientList]
	DEFAULT (CONVERT([xml],N'<Recipients />',(0))) FOR [RecipientList]
GO
ALTER TABLE [sf].[Task]
	ADD
	CONSTRAINT [df_Task_TagList]
	DEFAULT (CONVERT([xml],N'<Tags/>',(0))) FOR [TagList]
GO
ALTER TABLE [sf].[Task]
	ADD
	CONSTRAINT [df_Task_FileExtension]
	DEFAULT ('.html') FOR [FileExtension]
GO
ALTER TABLE [sf].[Task]
	ADD
	CONSTRAINT [df_Task_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[Task]
	ADD
	CONSTRAINT [df_Task_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[Task]
	ADD
	CONSTRAINT [df_Task_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[Task]
	ADD
	CONSTRAINT [df_Task_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[Task]
	ADD
	CONSTRAINT [df_Task_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[Task]
	ADD
	CONSTRAINT [df_Task_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[Task]
	WITH CHECK
	ADD CONSTRAINT [fk_Task_TaskQueue_TaskQueueSID]
	FOREIGN KEY ([TaskQueueSID]) REFERENCES [sf].[TaskQueue] ([TaskQueueSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[Task]
	CHECK CONSTRAINT [fk_Task_TaskQueue_TaskQueueSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the task queue system ID column in the Task table match a task queue system ID in the Task Queue table. It also ensures that when a record in the Task Queue table is deleted, matching child records in the Task table are deleted as well. Finally, the constraint blocks changes to the value of the task queue system ID column in the Task Queue if matching child records exist in Task.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'CONSTRAINT', N'fk_Task_TaskQueue_TaskQueueSID'
GO
ALTER TABLE [sf].[Task]
	WITH CHECK
	ADD CONSTRAINT [fk_Task_ApplicationPage_ApplicationPageSID]
	FOREIGN KEY ([ApplicationPageSID]) REFERENCES [sf].[ApplicationPage] ([ApplicationPageSID])
ALTER TABLE [sf].[Task]
	CHECK CONSTRAINT [fk_Task_ApplicationPage_ApplicationPageSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application page system ID column in the Task table match a application page system ID in the Application Page table. It also ensures that records in the Application Page table cannot be deleted if matching child records exist in Task. Finally, the constraint blocks changes to the value of the application page system ID column in the Application Page if matching child records exist in Task.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'CONSTRAINT', N'fk_Task_ApplicationPage_ApplicationPageSID'
GO
ALTER TABLE [sf].[Task]
	WITH CHECK
	ADD CONSTRAINT [fk_Task_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
ALTER TABLE [sf].[Task]
	CHECK CONSTRAINT [fk_Task_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Task table match a application user system ID in the Application User table. It also ensures that records in the Application User table cannot be deleted if matching child records exist in Task. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Task.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'CONSTRAINT', N'fk_Task_ApplicationUser_ApplicationUserSID'
GO
ALTER TABLE [sf].[Task]
	WITH CHECK
	ADD CONSTRAINT [fk_Task_TaskStatus_TaskStatusSID]
	FOREIGN KEY ([TaskStatusSID]) REFERENCES [sf].[TaskStatus] ([TaskStatusSID])
ALTER TABLE [sf].[Task]
	CHECK CONSTRAINT [fk_Task_TaskStatus_TaskStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the task status system ID column in the Task table match a task status system ID in the Task Status table. It also ensures that records in the Task Status table cannot be deleted if matching child records exist in Task. Finally, the constraint blocks changes to the value of the task status system ID column in the Task Status if matching child records exist in Task.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'CONSTRAINT', N'fk_Task_TaskStatus_TaskStatusSID'
GO
ALTER TABLE [sf].[Task]
	WITH CHECK
	ADD CONSTRAINT [fk_Task_TaskTrigger_TaskTriggerSID]
	FOREIGN KEY ([TaskTriggerSID]) REFERENCES [sf].[TaskTrigger] ([TaskTriggerSID])
ALTER TABLE [sf].[Task]
	CHECK CONSTRAINT [fk_Task_TaskTrigger_TaskTriggerSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the task trigger system ID column in the Task table match a task trigger system ID in the Task Trigger table. It also ensures that records in the Task Trigger table cannot be deleted if matching child records exist in Task. Finally, the constraint blocks changes to the value of the task trigger system ID column in the Task Trigger if matching child records exist in Task.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'CONSTRAINT', N'fk_Task_TaskTrigger_TaskTriggerSID'
GO
CREATE NONCLUSTERED INDEX [ix_Task_ApplicationPageSID_TaskSID]
	ON [sf].[Task] ([ApplicationPageSID], [TaskSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Page SID foreign key column and avoids row contention on (parent) Application Page updates', 'SCHEMA', N'sf', 'TABLE', N'Task', 'INDEX', N'ix_Task_ApplicationPageSID_TaskSID'
GO
CREATE NONCLUSTERED INDEX [ix_Task_ApplicationUserSID_TaskSID]
	ON [sf].[Task] ([ApplicationUserSID], [TaskSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'Task', 'INDEX', N'ix_Task_ApplicationUserSID_TaskSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Task_LegacyKey]
	ON [sf].[Task] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'Task', 'INDEX', N'ux_Task_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_Task_TargetRowGUID]
	ON [sf].[Task] ([TargetRowGUID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Task searches based on the Target Row GUID column', 'SCHEMA', N'sf', 'TABLE', N'Task', 'INDEX', N'ix_Task_TargetRowGUID'
GO
CREATE NONCLUSTERED INDEX [ix_Task_TaskQueueSID_TaskSID]
	ON [sf].[Task] ([TaskQueueSID], [TaskSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Task Queue SID foreign key column and avoids row contention on (parent) Task Queue updates', 'SCHEMA', N'sf', 'TABLE', N'Task', 'INDEX', N'ix_Task_TaskQueueSID_TaskSID'
GO
CREATE NONCLUSTERED INDEX [ix_Task_TaskStatusSID_TaskSID]
	ON [sf].[Task] ([TaskStatusSID], [TaskSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Task Status SID foreign key column and avoids row contention on (parent) Task Status updates', 'SCHEMA', N'sf', 'TABLE', N'Task', 'INDEX', N'ix_Task_TaskStatusSID_TaskSID'
GO
CREATE NONCLUSTERED INDEX [ix_Task_TaskTriggerSID_TaskSID]
	ON [sf].[Task] ([TaskTriggerSID], [TaskSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Task Trigger SID foreign key column and avoids row contention on (parent) Task Trigger updates', 'SCHEMA', N'sf', 'TABLE', N'Task', 'INDEX', N'ix_Task_TaskTriggerSID_TaskSID'
GO
CREATE FULLTEXT INDEX ON [sf].[Task]
	([TaskTitle] LANGUAGE 0, [TaskDescription] TYPE COLUMN [FileExtension] LANGUAGE 0)
	KEY INDEX [pk_Task]
	ON (FILEGROUP [FullTextIndexData], [ftcDefault])
	WITH CHANGE_TRACKING AUTO, STOPLIST OFF
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records works that is assigned to queues and users in the form of tasks. Tasks can be created manually or generated through task triggers. Tasks must be assigned to a queue.  Tasks do not need to be assigned to a speicific user initially unless they are of the type "Alert".  When a user is assigned to a task they become the task "owner".  A due date must be specified in order to create a task. This value is defaulted automatically if the task is created by a trigger.  A record of other key dates is maintained in the task including a "next follow-up date" which can be updated as work on the task proceeds.  The "NavigationURL" allows the UI to take the user to to the relevant record for completing the task when it is clicked (typically on a dashboard component).', 'SCHEMA', N'sf', 'TABLE', N'Task', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the task assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'TaskSID'
GO
EXEC sp_addextendedproperty N'MSDescription', N'A unique sequence number assigned by the application to identify the record.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'TaskSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the task to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'TaskTitle'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The description of a Task.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'TaskTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The queue this task should appear on | If not defined the task will be assigned to the default queue at runtime', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'TaskQueueSID'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The unique number assigned to a Task queue that relates a Task to a Task queue.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'TaskQueueSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the work required', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'TaskDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the task is a message that only needs to be acknowledged (read) by the assigned user.  | Alert tasks must be assigned immediately to a specific application user.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'IsAlert'
GO
EXEC sp_addextendedproperty N'MSDescription', N'Is alert indicates if a Task is informational only and requires no action.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'IsAlert'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A ranking value indicating the priority of this task compared with others - scale is 1-5 with "3" being medium (default) | The due date and this value are used to sort tasks in priority sequence on the user interface', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The priority level of a Task determines where is sorts on the users Task list.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user who this task has been assigned to (the task owner) | This value may be self-assigned by selecting the task from a queue, or it may be assigned by a task manager', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the task', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'TaskStatusSID'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The unique identifier assigned to a Task status code that allows the Task to be assigned a status.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'TaskStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this task was assigned (or last assigned if a re-assignment was done)', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'AssignedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the task is due', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'DueDate'
GO
EXEC sp_addextendedproperty N'MSDescription', N'Due date equates to when the Task is intended to be closed.  Tasks still open beyond the due date are conSIDered overdue.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'DueDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date this task should next appear for follow-up by the task owner | This value is a "bring forward" date that can be changed as work on the task proceeds', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'NextFollowUpDate'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The date when a Task requires additional followup and will appear on the users Task list.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'NextFollowUpDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the task was marked complete', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'ClosedTime'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The date and time that the Task status was changed to closed.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'ClosedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A reference to the task trigger that generated the task - blank if task was created manually | This value is required in order for task queries to determine if a task has already been created for the scenario', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'TaskTriggerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'List of individuals who should receive notification (via email and/or text) when task updates or new notes are entered.  | This value includes a designator to notify and display for user notes marked private', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'RecipientList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value required by the system to perform full-text indexing on the HTML formatted content in the record (do not expose in user interface).', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'FileExtension'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the task | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'TaskXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the task | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this task record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the task | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the task record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the task record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'Task', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Task', 'CONSTRAINT', N'uk_Task_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_Task_RecipientList]
	ON [sf].[Task] ([RecipientList])
	WITH ( FILLFACTOR = 90)
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Recipient List (XML) column', 'SCHEMA', N'sf', 'TABLE', N'Task', 'INDEX', N'xp_Task_RecipientList'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_Task_TagList]
	ON [sf].[Task] ([TagList])
	WITH ( FILLFACTOR = 90)
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Tag List (XML) column', 'SCHEMA', N'sf', 'TABLE', N'Task', 'INDEX', N'xp_Task_TagList'
GO
ALTER TABLE [sf].[Task] SET (LOCK_ESCALATION = TABLE)
GO
