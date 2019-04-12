SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[DefaultEmailTemplate] (
		[DefaultEmailTemplateSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[DefaultEmailTemplateSCD]       [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DefaultEmailTemplateLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[EmailTemplateSID]              [int] NOT NULL,
		[UserDefinedColumns]            [xml] NULL,
		[DefaultEmailTemplateXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_DefaultEmailTemplate_DefaultEmailTemplateLabel]
		UNIQUE
		NONCLUSTERED
		([DefaultEmailTemplateLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_DefaultEmailTemplate_DefaultEmailTemplateSCD]
		UNIQUE
		NONCLUSTERED
		([DefaultEmailTemplateSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_DefaultEmailTemplate_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_DefaultEmailTemplate]
		PRIMARY KEY
		CLUSTERED
		([DefaultEmailTemplateSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Default Email Template table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'CONSTRAINT', N'pk_DefaultEmailTemplate'
GO
ALTER TABLE [sf].[DefaultEmailTemplate]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_DefaultEmailTemplate]
	CHECK
	([sf].[fDefaultEmailTemplate#Check]([DefaultEmailTemplateSID],[DefaultEmailTemplateSCD],[DefaultEmailTemplateLabel],[EmailTemplateSID],[DefaultEmailTemplateXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[DefaultEmailTemplate]
CHECK CONSTRAINT [ck_DefaultEmailTemplate]
GO
ALTER TABLE [sf].[DefaultEmailTemplate]
	ADD
	CONSTRAINT [df_DefaultEmailTemplate_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[DefaultEmailTemplate]
	ADD
	CONSTRAINT [df_DefaultEmailTemplate_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[DefaultEmailTemplate]
	ADD
	CONSTRAINT [df_DefaultEmailTemplate_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[DefaultEmailTemplate]
	ADD
	CONSTRAINT [df_DefaultEmailTemplate_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[DefaultEmailTemplate]
	ADD
	CONSTRAINT [df_DefaultEmailTemplate_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[DefaultEmailTemplate]
	ADD
	CONSTRAINT [df_DefaultEmailTemplate_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[DefaultEmailTemplate]
	WITH CHECK
	ADD CONSTRAINT [fk_DefaultEmailTemplate_EmailTemplate_EmailTemplateSID]
	FOREIGN KEY ([EmailTemplateSID]) REFERENCES [sf].[EmailTemplate] ([EmailTemplateSID])
ALTER TABLE [sf].[DefaultEmailTemplate]
	CHECK CONSTRAINT [fk_DefaultEmailTemplate_EmailTemplate_EmailTemplateSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the email template system ID column in the Default Email Template table match a email template system ID in the Email Template table. It also ensures that records in the Email Template table cannot be deleted if matching child records exist in Default Email Template. Finally, the constraint blocks changes to the value of the email template system ID column in the Email Template if matching child records exist in Default Email Template.', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'CONSTRAINT', N'fk_DefaultEmailTemplate_EmailTemplate_EmailTemplateSID'
GO
CREATE NONCLUSTERED INDEX [ix_DefaultEmailTemplate_EmailTemplateSID_DefaultEmailTemplateSID]
	ON [sf].[DefaultEmailTemplate] ([EmailTemplateSID], [DefaultEmailTemplateSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Email Template SID foreign key column and avoids row contention on (parent) Email Template updates', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'INDEX', N'ix_DefaultEmailTemplate_EmailTemplateSID_DefaultEmailTemplateSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_DefaultEmailTemplate_LegacyKey]
	ON [sf].[DefaultEmailTemplate] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'INDEX', N'ux_DefaultEmailTemplate_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the default email template assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'DefaultEmailTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the default email template | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'DefaultEmailTemplateSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the default email template to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'DefaultEmailTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The email template assigned to this default', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'EmailTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the default email template | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'DefaultEmailTemplateXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the default email template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this default email template record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the default email template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the default email template record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the default email template record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Default Email Template Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'CONSTRAINT', N'uk_DefaultEmailTemplate_DefaultEmailTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Default Email Template SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'CONSTRAINT', N'uk_DefaultEmailTemplate_DefaultEmailTemplateSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'DefaultEmailTemplate', 'CONSTRAINT', N'uk_DefaultEmailTemplate_RowGUID'
GO
ALTER TABLE [sf].[DefaultEmailTemplate] SET (LOCK_ESCALATION = TABLE)
GO
