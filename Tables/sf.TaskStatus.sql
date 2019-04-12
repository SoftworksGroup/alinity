SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[TaskStatus] (
		[TaskStatusSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[TaskStatusSCD]          [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TaskStatusLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TaskStatusSequence]     [int] NOT NULL,
		[IsDerived]              [bit] NOT NULL,
		[IsClosedStatus]         [bit] NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[TaskStatusXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_TaskStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_TaskStatus_TaskStatusLabel]
		UNIQUE
		NONCLUSTERED
		([TaskStatusLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_TaskStatus_TaskStatusSCD]
		UNIQUE
		NONCLUSTERED
		([TaskStatusSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_TaskStatus]
		PRIMARY KEY
		CLUSTERED
		([TaskStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Task Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'CONSTRAINT', N'pk_TaskStatus'
GO
ALTER TABLE [sf].[TaskStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_TaskStatus]
	CHECK
	([sf].[fTaskStatus#Check]([TaskStatusSID],[TaskStatusSCD],[TaskStatusLabel],[TaskStatusSequence],[IsDerived],[IsClosedStatus],[IsActive],[IsDefault],[TaskStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[TaskStatus]
CHECK CONSTRAINT [ck_TaskStatus]
GO
ALTER TABLE [sf].[TaskStatus]
	ADD
	CONSTRAINT [df_TaskStatus_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[TaskStatus]
	ADD
	CONSTRAINT [df_TaskStatus_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[TaskStatus]
	ADD
	CONSTRAINT [df_TaskStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[TaskStatus]
	ADD
	CONSTRAINT [df_TaskStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[TaskStatus]
	ADD
	CONSTRAINT [df_TaskStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[TaskStatus]
	ADD
	CONSTRAINT [df_TaskStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[TaskStatus]
	ADD
	CONSTRAINT [df_TaskStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[TaskStatus]
	ADD
	CONSTRAINT [df_TaskStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[TaskStatus]
	ADD
	CONSTRAINT [df_TaskStatus_IsDerived]
	DEFAULT (CONVERT([bit],(0))) FOR [IsDerived]
GO
ALTER TABLE [sf].[TaskStatus]
	ADD
	CONSTRAINT [df_TaskStatus_TaskStatusSequence]
	DEFAULT ((0)) FOR [TaskStatusSequence]
GO
ALTER TABLE [sf].[TaskStatus]
	ADD
	CONSTRAINT [df_TaskStatus_IsClosedStatus]
	DEFAULT ((0)) FOR [IsClosedStatus]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TaskStatus_IsDefault]
	ON [sf].[TaskStatus] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Task Status', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'INDEX', N'ux_TaskStatus_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TaskStatus_LegacyKey]
	ON [sf].[TaskStatus] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'INDEX', N'ux_TaskStatus_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the list of tasks statuses supported by the application. The list of statuses cannot be updated by the end user (no add or delete) but descriptive column values can be updated to use terminology/language appropriate for the configuration.', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the task status assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'TaskStatusSID'
GO
EXEC sp_addextendedproperty N'MSDescription', N'A unique sequence number assigned by the application to identify the record.', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'TaskStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the task status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'TaskStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the task status to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'TaskStatusLabel'
GO
EXEC sp_addextendedproperty N'MSDescription', N'The name used to identify a Task.  This is the item displayed in the UI rather than a SID.', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'TaskStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the scenarios this task status is intended to support', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order this status should appear in on the task (Kanban) board display', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'TaskStatusSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the status is derived by the system. These types of statuses cannot be selected as parent statuses for Task Board columns.', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'IsDerived'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates tasks in this status should be considered as closed by the application | This value cannot be set by the end user', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'IsClosedStatus'
GO
EXEC sp_addextendedproperty N'MSDescription', N'Does this status cause the Task to be conSIDered closed?  Y/N.', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'IsClosedStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this task status record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default task status to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the task status | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'TaskStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the task status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this task status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the task status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the task status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the task status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'CONSTRAINT', N'uk_TaskStatus_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Task Status Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'CONSTRAINT', N'uk_TaskStatus_TaskStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Task Status SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TaskStatus', 'CONSTRAINT', N'uk_TaskStatus_TaskStatusSCD'
GO
ALTER TABLE [sf].[TaskStatus] SET (LOCK_ESCALATION = TABLE)
GO
