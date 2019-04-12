SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[TextTrigger] (
		[TextTriggerSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[TextTriggerLabel]       [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TextTemplateSID]        [int] NOT NULL,
		[QuerySID]               [int] NOT NULL,
		[MinDaysToRepeat]        [int] NOT NULL,
		[ApplicationUserSID]     [int] NULL,
		[JobScheduleSID]         [int] NULL,
		[LastStartTime]          [datetimeoffset](7) NULL,
		[LastEndTime]            [datetimeoffset](7) NULL,
		[IsActive]               [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[TextTriggerXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_TextTrigger_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_TextTrigger_TextTriggerLabel]
		UNIQUE
		NONCLUSTERED
		([TextTriggerLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_TextTrigger]
		PRIMARY KEY
		CLUSTERED
		([TextTriggerSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Text Trigger table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'CONSTRAINT', N'pk_TextTrigger'
GO
ALTER TABLE [sf].[TextTrigger]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_TextTrigger]
	CHECK
	([sf].[fTextTrigger#Check]([TextTriggerSID],[TextTriggerLabel],[TextTemplateSID],[QuerySID],[MinDaysToRepeat],[ApplicationUserSID],[JobScheduleSID],[LastStartTime],[LastEndTime],[IsActive],[TextTriggerXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[TextTrigger]
CHECK CONSTRAINT [ck_TextTrigger]
GO
ALTER TABLE [sf].[TextTrigger]
	ADD
	CONSTRAINT [df_TextTrigger_MinDaysToRepeat]
	DEFAULT ((0)) FOR [MinDaysToRepeat]
GO
ALTER TABLE [sf].[TextTrigger]
	ADD
	CONSTRAINT [df_TextTrigger_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[TextTrigger]
	ADD
	CONSTRAINT [df_TextTrigger_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[TextTrigger]
	ADD
	CONSTRAINT [df_TextTrigger_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[TextTrigger]
	ADD
	CONSTRAINT [df_TextTrigger_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[TextTrigger]
	ADD
	CONSTRAINT [df_TextTrigger_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[TextTrigger]
	ADD
	CONSTRAINT [df_TextTrigger_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[TextTrigger]
	ADD
	CONSTRAINT [df_TextTrigger_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[TextTrigger]
	WITH CHECK
	ADD CONSTRAINT [fk_TextTrigger_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
ALTER TABLE [sf].[TextTrigger]
	CHECK CONSTRAINT [fk_TextTrigger_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Text Trigger table match a application user system ID in the Application User table. It also ensures that records in the Application User table cannot be deleted if matching child records exist in Text Trigger. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Text Trigger.', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'CONSTRAINT', N'fk_TextTrigger_ApplicationUser_ApplicationUserSID'
GO
ALTER TABLE [sf].[TextTrigger]
	WITH CHECK
	ADD CONSTRAINT [fk_TextTrigger_JobSchedule_JobScheduleSID]
	FOREIGN KEY ([JobScheduleSID]) REFERENCES [sf].[JobSchedule] ([JobScheduleSID])
ALTER TABLE [sf].[TextTrigger]
	CHECK CONSTRAINT [fk_TextTrigger_JobSchedule_JobScheduleSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the job schedule system ID column in the Text Trigger table match a job schedule system ID in the Job Schedule table. It also ensures that records in the Job Schedule table cannot be deleted if matching child records exist in Text Trigger. Finally, the constraint blocks changes to the value of the job schedule system ID column in the Job Schedule if matching child records exist in Text Trigger.', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'CONSTRAINT', N'fk_TextTrigger_JobSchedule_JobScheduleSID'
GO
ALTER TABLE [sf].[TextTrigger]
	WITH CHECK
	ADD CONSTRAINT [fk_TextTrigger_TextTemplate_TextTemplateSID]
	FOREIGN KEY ([TextTemplateSID]) REFERENCES [sf].[TextTemplate] ([TextTemplateSID])
ALTER TABLE [sf].[TextTrigger]
	CHECK CONSTRAINT [fk_TextTrigger_TextTemplate_TextTemplateSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the text template system ID column in the Text Trigger table match a text template system ID in the Text Template table. It also ensures that records in the Text Template table cannot be deleted if matching child records exist in Text Trigger. Finally, the constraint blocks changes to the value of the text template system ID column in the Text Template if matching child records exist in Text Trigger.', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'CONSTRAINT', N'fk_TextTrigger_TextTemplate_TextTemplateSID'
GO
ALTER TABLE [sf].[TextTrigger]
	WITH CHECK
	ADD CONSTRAINT [fk_TextTrigger_Query_QuerySID]
	FOREIGN KEY ([QuerySID]) REFERENCES [sf].[Query] ([QuerySID])
ALTER TABLE [sf].[TextTrigger]
	CHECK CONSTRAINT [fk_TextTrigger_Query_QuerySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the query system ID column in the Text Trigger table match a query system ID in the Query table. It also ensures that records in the Query table cannot be deleted if matching child records exist in Text Trigger. Finally, the constraint blocks changes to the value of the query system ID column in the Query if matching child records exist in Text Trigger.', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'CONSTRAINT', N'fk_TextTrigger_Query_QuerySID'
GO
CREATE NONCLUSTERED INDEX [ix_TextTrigger_ApplicationUserSID_TextTriggerSID]
	ON [sf].[TextTrigger] ([ApplicationUserSID], [TextTriggerSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'INDEX', N'ix_TextTrigger_ApplicationUserSID_TextTriggerSID'
GO
CREATE NONCLUSTERED INDEX [ix_TextTrigger_JobScheduleSID_TextTriggerSID]
	ON [sf].[TextTrigger] ([JobScheduleSID], [TextTriggerSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Job Schedule SID foreign key column and avoids row contention on (parent) Job Schedule updates', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'INDEX', N'ix_TextTrigger_JobScheduleSID_TextTriggerSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TextTrigger_LegacyKey]
	ON [sf].[TextTrigger] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'INDEX', N'ux_TextTrigger_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_TextTrigger_QuerySID_TextTriggerSID]
	ON [sf].[TextTrigger] ([QuerySID], [TextTriggerSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Query SID foreign key column and avoids row contention on (parent) Query updates', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'INDEX', N'ix_TextTrigger_QuerySID_TextTriggerSID'
GO
CREATE NONCLUSTERED INDEX [ix_TextTrigger_TextTemplateSID_TextTriggerSID]
	ON [sf].[TextTrigger] ([TextTemplateSID], [TextTriggerSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Text Template SID foreign key column and avoids row contention on (parent) Text Template updates', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'INDEX', N'ix_TextTrigger_TextTemplateSID_TextTriggerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table allows configurators to automate text message creation.  A trigger is made up of a query that isolates people for which text messages should be created.  The content for the message is defined by associating the trigger with a text message template.  A schedule may be assigned to the trigger to re-run the query to look for new messages to create at regular intervals.  Note that the query needs to be constructued in such a way that if the text message has been previously sent to the individual, another is not sent until the desired interval has passed.', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the text trigger assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'TextTriggerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the text trigger to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'TextTriggerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The text template assigned to this text trigger', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'TextTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The query assigned to this text trigger', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'QuerySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The minimum number of days the system will wait before sending out the same message associated with this trigger | This setting allows duplicate messages to be avoided for the given period of time - without requiring hardcoding the interval in the query.', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'MinDaysToRepeat'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this text trigger', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job schedule assigned to this text trigger', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'JobScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time processing for this specific email trigger began | This value is used in determining when the trigger should be run next when a schedule is assigned', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'LastStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the trigger completed successfully, failed, or was cancelled through the TextMessage Trigger job | Records where this value is not filled in are considered to be running', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'LastEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this text trigger record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the text trigger | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'TextTriggerXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the text trigger | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this text trigger record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the text trigger | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the text trigger record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the text trigger record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'CONSTRAINT', N'uk_TextTrigger_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Text Trigger Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TextTrigger', 'CONSTRAINT', N'uk_TextTrigger_TextTriggerLabel'
GO
ALTER TABLE [sf].[TextTrigger] SET (LOCK_ESCALATION = TABLE)
GO
