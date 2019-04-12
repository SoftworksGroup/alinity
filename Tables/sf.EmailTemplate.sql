SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[EmailTemplate] (
		[EmailTemplateSID]              [int] IDENTITY(1000001, 1) NOT NULL,
		[EmailTemplateLabel]            [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PriorityLevel]                 [tinyint] NOT NULL,
		[Subject]                       [nvarchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Body]                          [varbinary](max) NOT NULL,
		[ChangeLogSummary]              [varbinary](max) NULL,
		[IsApplicationUserRequired]     [bit] NOT NULL,
		[LinkExpiryHours]               [int] NOT NULL,
		[ApplicationEntitySID]          [int] NULL,
		[ApplicationGrantSID]           [int] NULL,
		[UsageNotes]                    [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]            [xml] NULL,
		[EmailTemplateXID]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_EmailTemplate_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_EmailTemplate_EmailTemplateLabel]
		UNIQUE
		NONCLUSTERED
		([EmailTemplateLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_EmailTemplate]
		PRIMARY KEY
		CLUSTERED
		([EmailTemplateSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Email Template table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'CONSTRAINT', N'pk_EmailTemplate'
GO
ALTER TABLE [sf].[EmailTemplate]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_EmailTemplate]
	CHECK
	([sf].[fEmailTemplate#Check]([EmailTemplateSID],[EmailTemplateLabel],[PriorityLevel],[Subject],[IsApplicationUserRequired],[LinkExpiryHours],[ApplicationEntitySID],[ApplicationGrantSID],[EmailTemplateXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[EmailTemplate]
CHECK CONSTRAINT [ck_EmailTemplate]
GO
ALTER TABLE [sf].[EmailTemplate]
	ADD
	CONSTRAINT [df_EmailTemplate_PriorityLevel]
	DEFAULT ((5)) FOR [PriorityLevel]
GO
ALTER TABLE [sf].[EmailTemplate]
	ADD
	CONSTRAINT [df_EmailTemplate_IsApplicationUserRequired]
	DEFAULT ((0)) FOR [IsApplicationUserRequired]
GO
ALTER TABLE [sf].[EmailTemplate]
	ADD
	CONSTRAINT [df_EmailTemplate_LinkExpiryHours]
	DEFAULT ((24)) FOR [LinkExpiryHours]
GO
ALTER TABLE [sf].[EmailTemplate]
	ADD
	CONSTRAINT [df_EmailTemplate_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[EmailTemplate]
	ADD
	CONSTRAINT [df_EmailTemplate_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[EmailTemplate]
	ADD
	CONSTRAINT [df_EmailTemplate_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[EmailTemplate]
	ADD
	CONSTRAINT [df_EmailTemplate_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[EmailTemplate]
	ADD
	CONSTRAINT [df_EmailTemplate_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[EmailTemplate]
	ADD
	CONSTRAINT [df_EmailTemplate_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[EmailTemplate]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailTemplate_ApplicationEntity_ApplicationEntitySID]
	FOREIGN KEY ([ApplicationEntitySID]) REFERENCES [sf].[ApplicationEntity] ([ApplicationEntitySID])
ALTER TABLE [sf].[EmailTemplate]
	CHECK CONSTRAINT [fk_EmailTemplate_ApplicationEntity_ApplicationEntitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application entity system ID column in the Email Template table match a application entity system ID in the Application Entity table. It also ensures that records in the Application Entity table cannot be deleted if matching child records exist in Email Template. Finally, the constraint blocks changes to the value of the application entity system ID column in the Application Entity if matching child records exist in Email Template.', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'CONSTRAINT', N'fk_EmailTemplate_ApplicationEntity_ApplicationEntitySID'
GO
ALTER TABLE [sf].[EmailTemplate]
	WITH CHECK
	ADD CONSTRAINT [fk_EmailTemplate_ApplicationGrant_ApplicationGrantSID]
	FOREIGN KEY ([ApplicationGrantSID]) REFERENCES [sf].[ApplicationGrant] ([ApplicationGrantSID])
ALTER TABLE [sf].[EmailTemplate]
	CHECK CONSTRAINT [fk_EmailTemplate_ApplicationGrant_ApplicationGrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application grant system ID column in the Email Template table match a application grant system ID in the Application Grant table. It also ensures that records in the Application Grant table cannot be deleted if matching child records exist in Email Template. Finally, the constraint blocks changes to the value of the application grant system ID column in the Application Grant if matching child records exist in Email Template.', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'CONSTRAINT', N'fk_EmailTemplate_ApplicationGrant_ApplicationGrantSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailTemplate_ApplicationEntitySID_EmailTemplateSID]
	ON [sf].[EmailTemplate] ([ApplicationEntitySID], [EmailTemplateSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Entity SID foreign key column and avoids row contention on (parent) Application Entity updates', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'INDEX', N'ix_EmailTemplate_ApplicationEntitySID_EmailTemplateSID'
GO
CREATE NONCLUSTERED INDEX [ix_EmailTemplate_ApplicationGrantSID_EmailTemplateSID]
	ON [sf].[EmailTemplate] ([ApplicationGrantSID], [EmailTemplateSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Grant SID foreign key column and avoids row contention on (parent) Application Grant updates', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'INDEX', N'ix_EmailTemplate_ApplicationGrantSID_EmailTemplateSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_EmailTemplate_LegacyKey]
	ON [sf].[EmailTemplate] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'INDEX', N'ux_EmailTemplate_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Email Templates allow users to create re-usable text that can be applied in common emailing scenarios. Templates can be setup with merge fields, for example: [@FirstName] and [@LastName].  These fields are replaced when the note is generated and stored into the Person Email Message table.  The application automatically considers the Person Email Message entity (which includes most values from the Person entity) to be the default data source for replacing merge fields.  It is also possible to identify a second data source through the Application Entity column.  Note where application entity is used, that data source is processed before Person Email Message so that where any column names are the same, the application entity specified takes precedence.  While templates typically include merge fields, this is not required – templates can be set up which are text only.   Values from the template, subject, body text, subscription to send the email under, etc. are copied from the template to the Email Message record but in general, can be overridden in the UI by users sending the email.  The configuration of data in this table requires that at least one Application User Invite template be established and if there are more than one, that one of them be marked as the Default.  That template is used by the system to confirm email addresses where web-site based sign-up to the application is allowed.   Invites are an email type that include a “confirmation link” the user clicks to validate the email address they have provided.  Confirmation links should be set to expire fairly quickly to reduce the attack surface of the application. This is set through the Confirmation Expiry Days value.  The Restricted Access designation is an extra level of access control provided.  Security grants already control access to email and document screens but this designator be used to indicate an email is particularly sensitive and should only appear to users who also have an additional grant (e.g. “case conduct” administrators, or “clinicians”).   ', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the email template assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'EmailTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the email template to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'EmailTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A priority level used to rank emails for sending: 1 is the highest priority, 5 is medium and 10 is lowest | This value is used to sort emails for pickup by the email sending service', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A title or subject to appear in the generated email or task - can contain replacements  - e.g. [@FirstName] | This value is mandatory and defaults to the Email Template Label if not provided.  The value is ignored for SMS messages. Only the body is sent for SMS', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'Subject'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The body of the message in HTML format and supporting replacement values from the data source -e.g. [@FirstName], [@LastName]', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'Body'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of the email message to include in change logs - e.g. comment area of form - to describe the email message sent. | This value is expected to be in HTML format', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'ChangeLogSummary'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the eligibility check on recipients should ensure there is an active user account (recipient must be able to sign in) | Be sure this value is set for password reset emails', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'IsApplicationUserRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of hours after which any (confirmation) link included in the email is considered expired', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'LinkExpiryHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this email template', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Instructions for other users on when to use the template and other notes', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the email template | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'EmailTemplateXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the email template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this email template record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the email template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the email template record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the email template record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'CONSTRAINT', N'uk_EmailTemplate_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Email Template Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'EmailTemplate', 'CONSTRAINT', N'uk_EmailTemplate_EmailTemplateLabel'
GO
ALTER TABLE [sf].[EmailTemplate] SET (LOCK_ESCALATION = TABLE)
GO
