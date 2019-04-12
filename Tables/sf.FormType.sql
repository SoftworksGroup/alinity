SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[FormType] (
		[FormTypeSID]            [int] IDENTITY(1000001, 1) NOT NULL,
		[FormTypeSCD]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FormTypeLabel]          [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FormOwnerSID]           [int] NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[FormTypeXID]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_FormType_FormTypeLabel]
		UNIQUE
		NONCLUSTERED
		([FormTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormType_FormTypeSCD]
		UNIQUE
		NONCLUSTERED
		([FormTypeSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_FormType]
		PRIMARY KEY
		CLUSTERED
		([FormTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Form Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'CONSTRAINT', N'pk_FormType'
GO
ALTER TABLE [sf].[FormType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_FormType]
	CHECK
	([sf].[fFormType#Check]([FormTypeSID],[FormTypeSCD],[FormTypeLabel],[FormOwnerSID],[IsDefault],[FormTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[FormType]
CHECK CONSTRAINT [ck_FormType]
GO
ALTER TABLE [sf].[FormType]
	ADD
	CONSTRAINT [df_FormType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[FormType]
	ADD
	CONSTRAINT [df_FormType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[FormType]
	ADD
	CONSTRAINT [df_FormType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[FormType]
	ADD
	CONSTRAINT [df_FormType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[FormType]
	ADD
	CONSTRAINT [df_FormType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[FormType]
	ADD
	CONSTRAINT [df_FormType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[FormType]
	ADD
	CONSTRAINT [df_FormType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[FormType]
	WITH CHECK
	ADD CONSTRAINT [fk_FormType_FormOwner_FormOwnerSID]
	FOREIGN KEY ([FormOwnerSID]) REFERENCES [sf].[FormOwner] ([FormOwnerSID])
ALTER TABLE [sf].[FormType]
	CHECK CONSTRAINT [fk_FormType_FormOwner_FormOwnerSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form owner system ID column in the Form Type table match a form owner system ID in the Form Owner table. It also ensures that records in the Form Owner table cannot be deleted if matching child records exist in Form Type. Finally, the constraint blocks changes to the value of the form owner system ID column in the Form Owner if matching child records exist in Form Type.', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'CONSTRAINT', N'fk_FormType_FormOwner_FormOwnerSID'
GO
CREATE NONCLUSTERED INDEX [ix_FormType_FormOwnerSID_FormTypeSID]
	ON [sf].[FormType] ([FormOwnerSID], [FormTypeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Owner SID foreign key column and avoids row contention on (parent) Form Owner updates', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'INDEX', N'ix_FormType_FormOwnerSID_FormTypeSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_FormType_IsDefault]
	ON [sf].[FormType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Form Type', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'INDEX', N'ux_FormType_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_FormType_LegacyKey]
	ON [sf].[FormType] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'INDEX', N'ux_FormType_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores the list of form types supported by application.  These form types are used internally by the program and do not correspond to end-user classification of forms. The list of form types cannot be updated by the end user (no add or delete) but descriptive column values can be updated to use terminology/language appropriate for the configuration.  Specific application logic detects each form type using the Form-Type-SCD value from this table.  Each configuration may also set the default owner associated with each form type.  This is used to categorize who is responsible for the next action on the form when in an open status.  The eligible selections come from the Form-Owner table and must be established as ASSIGNEE records. ', 'SCHEMA', N'sf', 'TABLE', N'FormType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form type assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'FormTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the form type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'FormTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form type to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'FormTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description of the audit action - e.g. "Patient record access"', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form owner assigned to this form type', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default form type to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the form type | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'FormTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the form type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this form type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the form type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the form type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Form Type Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'CONSTRAINT', N'uk_FormType_FormTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Form Type SCD column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'CONSTRAINT', N'uk_FormType_FormTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormType', 'CONSTRAINT', N'uk_FormType_RowGUID'
GO
ALTER TABLE [sf].[FormType] SET (LOCK_ESCALATION = TABLE)
GO
