SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[TextTemplate] (
		[TextTemplateSID]               [int] IDENTITY(1000001, 1) NOT NULL,
		[TextTemplateLabel]             [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PriorityLevel]                 [tinyint] NOT NULL,
		[Body]                          [nvarchar](1600) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsApplicationUserRequired]     [bit] NOT NULL,
		[LinkExpiryHours]               [int] NOT NULL,
		[ApplicationEntitySID]          [int] NULL,
		[UsageNotes]                    [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]            [xml] NULL,
		[TextTemplateXID]               [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_TextTemplate_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_TextTemplate_TextTemplateLabel]
		UNIQUE
		NONCLUSTERED
		([TextTemplateLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_TextTemplate]
		PRIMARY KEY
		CLUSTERED
		([TextTemplateSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Text Template table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'CONSTRAINT', N'pk_TextTemplate'
GO
ALTER TABLE [sf].[TextTemplate]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_TextTemplate]
	CHECK
	([sf].[fTextTemplate#Check]([TextTemplateSID],[TextTemplateLabel],[PriorityLevel],[Body],[IsApplicationUserRequired],[LinkExpiryHours],[ApplicationEntitySID],[TextTemplateXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[TextTemplate]
CHECK CONSTRAINT [ck_TextTemplate]
GO
ALTER TABLE [sf].[TextTemplate]
	ADD
	CONSTRAINT [df_TextTemplate_PriorityLevel]
	DEFAULT ((5)) FOR [PriorityLevel]
GO
ALTER TABLE [sf].[TextTemplate]
	ADD
	CONSTRAINT [df_TextTemplate_IsApplicationUserRequired]
	DEFAULT ((0)) FOR [IsApplicationUserRequired]
GO
ALTER TABLE [sf].[TextTemplate]
	ADD
	CONSTRAINT [df_TextTemplate_LinkExpiryHours]
	DEFAULT ((24)) FOR [LinkExpiryHours]
GO
ALTER TABLE [sf].[TextTemplate]
	ADD
	CONSTRAINT [df_TextTemplate_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[TextTemplate]
	ADD
	CONSTRAINT [df_TextTemplate_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[TextTemplate]
	ADD
	CONSTRAINT [df_TextTemplate_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[TextTemplate]
	ADD
	CONSTRAINT [df_TextTemplate_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[TextTemplate]
	ADD
	CONSTRAINT [df_TextTemplate_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[TextTemplate]
	ADD
	CONSTRAINT [df_TextTemplate_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[TextTemplate]
	WITH CHECK
	ADD CONSTRAINT [fk_TextTemplate_ApplicationEntity_ApplicationEntitySID]
	FOREIGN KEY ([ApplicationEntitySID]) REFERENCES [sf].[ApplicationEntity] ([ApplicationEntitySID])
ALTER TABLE [sf].[TextTemplate]
	CHECK CONSTRAINT [fk_TextTemplate_ApplicationEntity_ApplicationEntitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application entity system ID column in the Text Template table match a application entity system ID in the Application Entity table. It also ensures that records in the Application Entity table cannot be deleted if matching child records exist in Text Template. Finally, the constraint blocks changes to the value of the application entity system ID column in the Application Entity if matching child records exist in Text Template.', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'CONSTRAINT', N'fk_TextTemplate_ApplicationEntity_ApplicationEntitySID'
GO
CREATE NONCLUSTERED INDEX [ix_TextTemplate_ApplicationEntitySID_TextTemplateSID]
	ON [sf].[TextTemplate] ([ApplicationEntitySID], [TextTemplateSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application Entity SID foreign key column and avoids row contention on (parent) Application Entity updates', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'INDEX', N'ix_TextTemplate_ApplicationEntitySID_TextTemplateSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TextTemplate_LegacyKey]
	ON [sf].[TextTemplate] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'INDEX', N'ux_TextTemplate_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Text Templates allow users to create re-usable messages that can be applied in common texting scenarios. Templates can be setup with merge fields, for example: [@FirstName] and [@LastName].  These fields are replaced when the message is generated and stored into the Person Text Message table.  The application automatically considers the Person Text Message entity (which includes most values from the Person entity) to be the default data source for replacing merge fields.  It is also possible to identify a second data source through the Application Entity column.  Note where application entity is used, that data source is processed before Person Text Message so that where any column names are the same, the application entity specified takes precedence.  While templates typically include merge fields, this is not required – templates can be set up which are text only.   Values from the template: body text, subscription to send the text under, etc. are copied from the template to the Text Message record but in general, can be overridden in the UI by users sending the text.  The configuration of data in this table requires that at least one Application User Invite template be established and if there are more than one, that one of them be marked as the Default.  That template is used by the system to confirm text phone numbers where web-site based sign-up to the application is allowed.   Invites are a text type that include a “confirmation link” the user clicks to validate the text phone they have provided.  Confirmation links should be set to expire fairly quickly to reduce the attack surface of the application. This is set through the Confirmation Expiry Days value.  The Restricted Access designation is an extra level of access control provided.  Security grants already control access to text and document screens but this designator be used to indicate an text is particularly sensitive and should only appear to users who also have an additional grant (e.g. “case conduct” administrators, or “clinicians”).   ', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the text template assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'TextTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the text template to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'TextTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A priority level used to rank texts for sending: 1 is the highest priority, 5 is medium and 10 is lowest | This value is used to sort texts for pickup by the text sending service', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The body of the message (in plain text format) and supporting replacement values from the data source -e.g. [@FirstName], [@LastName]', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'Body'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the eligibility check on recipients should ensure there is an active user account (recipient must be able to sign in) | Be sure this value is set for password reset texts', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'IsApplicationUserRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of hours after which any (confirmation) link included in the text is considered expired', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'LinkExpiryHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this text template', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Instructions for other users on when to use the template and other notes', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the text template | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'TextTemplateXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the text template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this text template record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the text template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the text template record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the text template record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'CONSTRAINT', N'uk_TextTemplate_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Text Template Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'TextTemplate', 'CONSTRAINT', N'uk_TextTemplate_TextTemplateLabel'
GO
ALTER TABLE [sf].[TextTemplate] SET (LOCK_ESCALATION = TABLE)
GO
