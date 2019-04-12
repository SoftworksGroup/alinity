SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[Form] (
		[FormSID]                [int] IDENTITY(1000001, 1) NOT NULL,
		[FormTypeSID]            [int] NOT NULL,
		[FormName]               [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FormLabel]              [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FormContext]            [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AuthorCredit]           [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[UsageTerms]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ApplicationUserSID]     [int] NOT NULL,
		[UsageNotes]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FormInstructions]       [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VersionHistory]         [xml] NULL,
		[UserDefinedColumns]     [xml] NULL,
		[FormXID]                [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_Form_FormLabel]
		UNIQUE
		NONCLUSTERED
		([FormLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Form_FormName]
		UNIQUE
		NONCLUSTERED
		([FormName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Form_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Form]
		PRIMARY KEY
		CLUSTERED
		([FormSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Form table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'Form', 'CONSTRAINT', N'pk_Form'
GO
ALTER TABLE [sf].[Form]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Form]
	CHECK
	([sf].[fForm#Check]([FormSID],[FormTypeSID],[FormName],[FormLabel],[FormContext],[AuthorCredit],[IsActive],[ApplicationUserSID],[FormXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[Form]
CHECK CONSTRAINT [ck_Form]
GO
ALTER TABLE [sf].[Form]
	ADD
	CONSTRAINT [df_Form_AuthorCredit]
	DEFAULT ((('Anonymous Work'+char((13)))+char((10)))+'See https://commons.wikimedia.org/wiki/Anonymous_works') FOR [AuthorCredit]
GO
ALTER TABLE [sf].[Form]
	ADD
	CONSTRAINT [df_Form_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[Form]
	ADD
	CONSTRAINT [df_Form_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[Form]
	ADD
	CONSTRAINT [df_Form_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[Form]
	ADD
	CONSTRAINT [df_Form_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[Form]
	ADD
	CONSTRAINT [df_Form_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[Form]
	ADD
	CONSTRAINT [df_Form_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[Form]
	ADD
	CONSTRAINT [df_Form_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[Form]
	WITH CHECK
	ADD CONSTRAINT [fk_Form_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
ALTER TABLE [sf].[Form]
	CHECK CONSTRAINT [fk_Form_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Form table match a application user system ID in the Application User table. It also ensures that records in the Application User table cannot be deleted if matching child records exist in Form. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Form.', 'SCHEMA', N'sf', 'TABLE', N'Form', 'CONSTRAINT', N'fk_Form_ApplicationUser_ApplicationUserSID'
GO
ALTER TABLE [sf].[Form]
	WITH CHECK
	ADD CONSTRAINT [fk_Form_FormType_FormTypeSID]
	FOREIGN KEY ([FormTypeSID]) REFERENCES [sf].[FormType] ([FormTypeSID])
ALTER TABLE [sf].[Form]
	CHECK CONSTRAINT [fk_Form_FormType_FormTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form type system ID column in the Form table match a form type system ID in the Form Type table. It also ensures that records in the Form Type table cannot be deleted if matching child records exist in Form. Finally, the constraint blocks changes to the value of the form type system ID column in the Form Type if matching child records exist in Form.', 'SCHEMA', N'sf', 'TABLE', N'Form', 'CONSTRAINT', N'fk_Form_FormType_FormTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_Form_ApplicationUserSID_FormSID]
	ON [sf].[Form] ([ApplicationUserSID], [FormSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'sf', 'TABLE', N'Form', 'INDEX', N'ix_Form_ApplicationUserSID_FormSID'
GO
CREATE NONCLUSTERED INDEX [ix_Form_FormTypeSID_FormSID]
	ON [sf].[Form] ([FormTypeSID], [FormSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Type SID foreign key column and avoids row contention on (parent) Form Type updates', 'SCHEMA', N'sf', 'TABLE', N'Form', 'INDEX', N'ix_Form_FormTypeSID_FormSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Form_LegacyKey]
	ON [sf].[Form] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'Form', 'INDEX', N'ux_Form_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is a parent record for dynamic forms in the application.  The record requires a type of form be specified as defined in the Form Type table.  Examples for form types include application form, renewal, exam, synoptic form, enrollment form, etc. Each specific type of form has an implementation table unique to the application which uses it.  The implementation appears in the DBO schema. This table is part of the dynamic form framework used by Softworks applications.  The content (fields), layout and style elements of a form are stored in an XML column in the Form Version table.   As each version of a form is approved for use, a new version is created.', 'SCHEMA', N'sf', 'TABLE', N'Form', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'FormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the audit action assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'FormTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the form to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'FormName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'FormLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional identifier of the use-case or context where this form should be applied.  | This value enables 2 (or more) forms of the same type to be in effect at the same time.  By default the application chooses the latest published version but a context may be specified in the program code (e.g. a registration year) in which case the latest form for that context is selected.', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'FormContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name, organization and other registrant information of the form''s author as along with any restrictions on use.', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'AuthorCredit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this form record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the Usage Terms and/or Disclaimer text to be presented to the user when the form is opened. When blank the value does not appear.  | This column is intended for situations where a liability shield on use of a form is required (e.g. medical eligibility forms).', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'UsageTerms'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this form', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Guidance about the intended use of thd form.  This value appears as help text when forms are being selected by end users and also by administrators who maintain the form.', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Instructions to present to the end user when this form is presented. Note that instructions from the "Parent" form in a form set are always displayed first even if the parent form does not appear until later in the form-set sequence.', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'FormInstructions'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the form | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'FormXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the form | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this form record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the form | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the form record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'Form', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Form Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Form', 'CONSTRAINT', N'uk_Form_FormLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Form Name column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Form', 'CONSTRAINT', N'uk_Form_FormName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Form', 'CONSTRAINT', N'uk_Form_RowGUID'
GO
ALTER TABLE [sf].[Form] SET (LOCK_ESCALATION = TABLE)
GO
