SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[DefaultTextTemplate] (
		[DefaultTextTemplateSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[DefaultTextTemplateSCD]       [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DefaultTextTemplateLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[TextTemplateSID]              [int] NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[DefaultTextTemplateXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_DefaultTextTemplate_DefaultTextTemplateLabel]
		UNIQUE
		NONCLUSTERED
		([DefaultTextTemplateLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_DefaultTextTemplate_DefaultTextTemplateSCD]
		UNIQUE
		NONCLUSTERED
		([DefaultTextTemplateSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_DefaultTextTemplate_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_DefaultTextTemplate]
		PRIMARY KEY
		CLUSTERED
		([DefaultTextTemplateSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Default Text Template table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'CONSTRAINT', N'pk_DefaultTextTemplate'
GO
ALTER TABLE [sf].[DefaultTextTemplate]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_DefaultTextTemplate]
	CHECK
	([sf].[fDefaultTextTemplate#Check]([DefaultTextTemplateSID],[DefaultTextTemplateSCD],[DefaultTextTemplateLabel],[TextTemplateSID],[DefaultTextTemplateXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[DefaultTextTemplate]
CHECK CONSTRAINT [ck_DefaultTextTemplate]
GO
ALTER TABLE [sf].[DefaultTextTemplate]
	ADD
	CONSTRAINT [df_DefaultTextTemplate_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[DefaultTextTemplate]
	ADD
	CONSTRAINT [df_DefaultTextTemplate_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[DefaultTextTemplate]
	ADD
	CONSTRAINT [df_DefaultTextTemplate_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[DefaultTextTemplate]
	ADD
	CONSTRAINT [df_DefaultTextTemplate_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[DefaultTextTemplate]
	ADD
	CONSTRAINT [df_DefaultTextTemplate_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[DefaultTextTemplate]
	ADD
	CONSTRAINT [df_DefaultTextTemplate_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[DefaultTextTemplate]
	WITH CHECK
	ADD CONSTRAINT [fk_DefaultTextTemplate_TextTemplate_TextTemplateSID]
	FOREIGN KEY ([TextTemplateSID]) REFERENCES [sf].[TextTemplate] ([TextTemplateSID])
ALTER TABLE [sf].[DefaultTextTemplate]
	CHECK CONSTRAINT [fk_DefaultTextTemplate_TextTemplate_TextTemplateSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the text template system ID column in the Default Text Template table match a text template system ID in the Text Template table. It also ensures that records in the Text Template table cannot be deleted if matching child records exist in Default Text Template. Finally, the constraint blocks changes to the value of the text template system ID column in the Text Template if matching child records exist in Default Text Template.', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'CONSTRAINT', N'fk_DefaultTextTemplate_TextTemplate_TextTemplateSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_DefaultTextTemplate_LegacyKey]
	ON [sf].[DefaultTextTemplate] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'INDEX', N'ux_DefaultTextTemplate_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_DefaultTextTemplate_TextTemplateSID_DefaultTextTemplateSID]
	ON [sf].[DefaultTextTemplate] ([TextTemplateSID], [DefaultTextTemplateSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Text Template SID foreign key column and avoids row contention on (parent) Text Template updates', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'INDEX', N'ix_DefaultTextTemplate_TextTemplateSID_DefaultTextTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the default text template assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'DefaultTextTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the default text template | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'DefaultTextTemplateSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the default text template to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'DefaultTextTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The text template assigned to this default', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'TextTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the default text template | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'DefaultTextTemplateXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the default text template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this default text template record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the default text template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the default text template record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the default text template record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Default Text Template Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'CONSTRAINT', N'uk_DefaultTextTemplate_DefaultTextTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Default Text Template SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'CONSTRAINT', N'uk_DefaultTextTemplate_DefaultTextTemplateSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'DefaultTextTemplate', 'CONSTRAINT', N'uk_DefaultTextTemplate_RowGUID'
GO
ALTER TABLE [sf].[DefaultTextTemplate] SET (LOCK_ESCALATION = TABLE)
GO
