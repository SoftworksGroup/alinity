SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[EmailTrigger] (
		[EmailTriggerSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[EmailTriggerLabel]         [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EmailTemplateSID]          [int] NOT NULL,
		[QuerySID]                  [int] NOT NULL,
		[MinDaysToRepeat]           [int] NOT NULL,
		[ApplicationUserSID]        [int] NULL,
		[JobScheduleSID]            [int] NULL,
		[LastStartTime]             [datetimeoffset](7) NOT NULL,
		[LastEndTime]               [datetimeoffset](7) NOT NULL,
		[EarliestSelectionDate]     [date] NULL,
		[IsActive]                  [bit] NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[EmailTriggerXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_EmailTrigger_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_EmailTrigger_EmailTriggerLabel]
		UNIQUE
		NONCLUSTERED
		([EmailTriggerLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_EmailTrigger]
		PRIMARY KEY
		CLUSTERED
		([EmailTriggerSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Email Trigger table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'CONSTRAINT', N'pk_EmailTrigger'
GO
ALTER TABLE [sf].[EmailTrigger]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_EmailTrigger]
	CHECK
	([sf].[fEmailTrigger#Check]([EmailTriggerSID],[EmailTriggerLabel],[EmailTemplateSID],[QuerySID],[MinDaysToRepeat],[ApplicationUserSID],[JobScheduleSID],[LastStartTime],[LastEndTime],[EarliestSelectionDate],[IsActive],[EmailTriggerXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[EmailTrigger]
CHECK CONSTRAINT [ck_EmailTrigger]
GO
ALTER TABLE [sf].[EmailTrigger]
	ADD
	CONSTRAINT [df_EmailTrigger_LastStartTime]
	DEFAULT (sysdatetimeoffset()) FOR [LastStartTime]
GO
ALTER TABLE [sf].[EmailTrigger]
	ADD
	CONSTRAINT [df_EmailTrigger_LastEndTime]
	DEFAULT (sysdatetimeoffset()) FOR [LastEndTime]
GO
ALTER TABLE [sf].[EmailTrigger]
	ADD
	CONSTRAINT [df_EmailTrigger_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[EmailTrigger]
	ADD
	CONSTRAINT [df_EmailTrigger_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[EmailTrigger]
	ADD
	CONSTRAINT [df_EmailTrigger_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[EmailTrigger]
	ADD
	CONSTRAINT [df_EmailTrigger_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[EmailTrigger]
	ADD
	CONSTRAINT [df_EmailTrigger_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[EmailTrigger]
	ADD
	CONSTRAINT [df_EmailTrigger_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[EmailTrigger]
	ADD
	CONSTRAINT [df_EmailTrigger_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[EmailTrigger]
	ADD
	CONSTRAINT [df_EmailTrigger_MinDaysToRepeat]
	DEFAULT ((0)) FOR [MinDaysToRepeat]
GO
ALTER TABLE [sf].[EmailTrigger]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailTrigger_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
ALTER TABLE [sf].[EmailTrigger]
	CHECK CONSTRAINT [fk_EmailTrigger_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Email Trigger table match a application user system ID in the Application User table. It also ensures that records in the Application User table cannot be deleted if matching child records exist in Email Trigger. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Email Trigger.', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'CONSTRAINT', N'fk_EmailTrigger_ApplicationUser_ApplicationUserSID'
GO
ALTER TABLE [sf].[EmailTrigger]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailTrigger_JobSchedule_JobScheduleSID]
	FOREIGN KEY ([JobScheduleSID]) REFERENCES [sf].[JobSchedule] ([JobScheduleSID])
ALTER TABLE [sf].[EmailTrigger]
	CHECK CONSTRAINT [fk_EmailTrigger_JobSchedule_JobScheduleSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the job schedule system ID column in the Email Trigger table match a job schedule system ID in the Job Schedule table. It also ensures that records in the Job Schedule table cannot be deleted if matching child records exist in Email Trigger. Finally, the constraint blocks changes to the value of the job schedule system ID column in the Job Schedule if matching child records exist in Email Trigger.', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'CONSTRAINT', N'fk_EmailTrigger_JobSchedule_JobScheduleSID'
GO
ALTER TABLE [sf].[EmailTrigger]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailTrigger_Query_QuerySID]
	FOREIGN KEY ([QuerySID]) REFERENCES [sf].[Query] ([QuerySID])
ALTER TABLE [sf].[EmailTrigger]
	CHECK CONSTRAINT [fk_EmailTrigger_Query_QuerySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the query system ID column in the Email Trigger table match a query system ID in the Query table. It also ensures that records in the Query table cannot be deleted if matching child records exist in Email Trigger. Finally, the constraint blocks changes to the value of the query system ID column in the Query if matching child records exist in Email Trigger.', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'CONSTRAINT', N'fk_EmailTrigger_Query_QuerySID'
GO
ALTER TABLE [sf].[EmailTrigger]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailTrigger_EmailTemplate_EmailTemplateSID]
	FOREIGN KEY ([EmailTemplateSID]) REFERENCES [sf].[EmailTemplate] ([EmailTemplateSID])
ALTER TABLE [sf].[EmailTrigger]
	CHECK CONSTRAINT [fk_EmailTrigger_EmailTemplate_EmailTemplateSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the email template system ID column in the Email Trigger table match a email template system ID in the Email Template table. It also ensures that records in the Email Template table cannot be deleted if matching child records exist in Email Trigger. Finally, the constraint blocks changes to the value of the email template system ID column in the Email Template if matching child records exist in Email Trigger.', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'CONSTRAINT', N'fk_EmailTrigger_EmailTemplate_EmailTemplateSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailTrigger_ApplicationUserSID_EmailTriggerSID]
	ON [sf].[EmailTrigger] ([ApplicationUserSID], [EmailTriggerSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'INDEX', N'ix_EmailTrigger_ApplicationUserSID_EmailTriggerSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailTrigger_EmailTemplateSID_EmailTriggerSID]
	ON [sf].[EmailTrigger] ([EmailTemplateSID], [EmailTriggerSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Email Template SID foreign key column and avoids row contention on (parent) Email Template updates', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'INDEX', N'ix_EmailTrigger_EmailTemplateSID_EmailTriggerSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailTrigger_JobScheduleSID_EmailTriggerSID]
	ON [sf].[EmailTrigger] ([JobScheduleSID], [EmailTriggerSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Job Schedule SID foreign key column and avoids row contention on (parent) Job Schedule updates', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'INDEX', N'ix_EmailTrigger_JobScheduleSID_EmailTriggerSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailTrigger_QuerySID_EmailTriggerSID]
	ON [sf].[EmailTrigger] ([QuerySID], [EmailTriggerSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Query SID foreign key column and avoids row contention on (parent) Query updates', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'INDEX', N'ix_EmailTrigger_QuerySID_EmailTriggerSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_EmailTrigger_LegacyKey]
	ON [sf].[EmailTrigger] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'INDEX', N'ux_EmailTrigger_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table allows configurators to automate email message creation.  A trigger is made up of a query that isolates people for which email messages should be created.  The content for the message is defined by associating the trigger with an email template.  A schedule may be assigned to the trigger to re-run the query to look for new emails to create at regular intervals.  Note that the query needs to be constructued in such a way that if the email has been previously sent to the individual, another is not sent until the desired interval has passed.', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the email trigger assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'EmailTriggerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the email trigger to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'EmailTriggerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The email template assigned to this email trigger', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'EmailTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The query assigned to this email trigger', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'QuerySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The minimum number of days the system will wait before sending out the same message associated with this trigger | This setting allows duplicate messages to be avoided for the given period of time - without requiring hardcoding the interval in the query.', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'MinDaysToRepeat'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this email trigger', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job schedule assigned to this email trigger', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'JobScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time processing for this specific email trigger began | This value is used in determining when the trigger should be run next when a schedule is assigned', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'LastStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the trigger completed successfully, failed, or was cancelled through the Email Trigger job | Records where this value is not filled in are considered to be running', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'LastEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The earliest date for selecting records to email where a date criteria is used in the trigger query. The selection date is the later of this value and the Last-Start-Time.', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'EarliestSelectionDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this email trigger record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the email trigger | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'EmailTriggerXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the email trigger | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this email trigger record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the email trigger | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the email trigger record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the email trigger record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'CONSTRAINT', N'uk_EmailTrigger_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Email Trigger Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'EmailTrigger', 'CONSTRAINT', N'uk_EmailTrigger_EmailTriggerLabel'
GO
ALTER TABLE [sf].[EmailTrigger] SET (LOCK_ESCALATION = TABLE)
GO
