SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[FormSubForm] (
		[FormSubFormSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[FormSID]                [int] NOT NULL,
		[SubFormSID]             [int] NOT NULL,
		[SubFormSequence]        [int] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[FormSubFormXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_FormSubForm_FormSID_SubFormSID]
		UNIQUE
		NONCLUSTERED
		([FormSID], [SubFormSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormSubForm_FormSubFormSID]
		UNIQUE
		NONCLUSTERED
		([FormSubFormSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_FormSubForm_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_FormSubForm]
		PRIMARY KEY
		CLUSTERED
		([FormSubFormSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Form Sub Form table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'CONSTRAINT', N'pk_FormSubForm'
GO
ALTER TABLE [sf].[FormSubForm]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_FormSubForm]
	CHECK
	([sf].[fFormSubForm#Check]([FormSubFormSID],[FormSID],[SubFormSID],[SubFormSequence],[FormSubFormXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[FormSubForm]
CHECK CONSTRAINT [ck_FormSubForm]
GO
ALTER TABLE [sf].[FormSubForm]
	ADD
	CONSTRAINT [df_FormSubForm_SubFormSequence]
	DEFAULT ((5)) FOR [SubFormSequence]
GO
ALTER TABLE [sf].[FormSubForm]
	ADD
	CONSTRAINT [df_FormSubForm_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[FormSubForm]
	ADD
	CONSTRAINT [df_FormSubForm_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[FormSubForm]
	ADD
	CONSTRAINT [df_FormSubForm_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[FormSubForm]
	ADD
	CONSTRAINT [df_FormSubForm_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[FormSubForm]
	ADD
	CONSTRAINT [df_FormSubForm_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[FormSubForm]
	ADD
	CONSTRAINT [df_FormSubForm_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[FormSubForm]
	WITH CHECK
	ADD CONSTRAINT [fk_FormSubForm_Form_FormSID]
	FOREIGN KEY ([FormSID]) REFERENCES [sf].[Form] ([FormSID])
ALTER TABLE [sf].[FormSubForm]
	CHECK CONSTRAINT [fk_FormSubForm_Form_FormSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form system ID column in the Form Sub Form table match a form system ID in the Form table. It also ensures that records in the Form table cannot be deleted if matching child records exist in Form Sub Form. Finally, the constraint blocks changes to the value of the form system ID column in the Form if matching child records exist in Form Sub Form.', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'CONSTRAINT', N'fk_FormSubForm_Form_FormSID'
GO
ALTER TABLE [sf].[FormSubForm]
	WITH CHECK
	ADD CONSTRAINT [fk_FormSubForm_Form_SubFormSID]
	FOREIGN KEY ([SubFormSID]) REFERENCES [sf].[Form] ([FormSID])
ALTER TABLE [sf].[FormSubForm]
	CHECK CONSTRAINT [fk_FormSubForm_Form_SubFormSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the sub form system ID column in the Form Sub Form table match a form system ID in the Form table. It also ensures that records in the Form table cannot be deleted if matching child records exist in Form Sub Form. Finally, the constraint blocks changes to the value of the form system ID column in the Form if matching child records exist in Form Sub Form.', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'CONSTRAINT', N'fk_FormSubForm_Form_SubFormSID'
GO
CREATE NONCLUSTERED INDEX [ix_FormSubForm_SubFormSID_FormSubFormSID]
	ON [sf].[FormSubForm] ([SubFormSID], [FormSubFormSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Sub Form SID foreign key column and avoids row contention on (parent) Form updates', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'INDEX', N'ix_FormSubForm_SubFormSID_FormSubFormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form sub form assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'FormSubFormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form this sub is defined for', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'FormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form this sub is defined for', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'SubFormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the form sub form | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'FormSubFormXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the form sub form | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this form sub form record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the form sub form | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the form sub form record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form sub form record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Form SID + Sub Form SID" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'CONSTRAINT', N'uk_FormSubForm_FormSID_SubFormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Form Sub Form SID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'CONSTRAINT', N'uk_FormSubForm_FormSubFormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'FormSubForm', 'CONSTRAINT', N'uk_FormSubForm_RowGUID'
GO
ALTER TABLE [sf].[FormSubForm] SET (LOCK_ESCALATION = TABLE)
GO
