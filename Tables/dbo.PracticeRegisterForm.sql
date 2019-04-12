SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeRegisterForm] (
		[PracticeRegisterFormSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[PracticeRegisterSID]         [int] NOT NULL,
		[FormSID]                     [int] NOT NULL,
		[UserDefinedColumns]          [xml] NULL,
		[PracticeRegisterFormXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_PracticeRegisterForm_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PracticeRegisterForm]
		PRIMARY KEY
		CLUSTERED
		([PracticeRegisterFormSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Practice Register Form table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'CONSTRAINT', N'pk_PracticeRegisterForm'
GO
ALTER TABLE [dbo].[PracticeRegisterForm]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PracticeRegisterForm]
	CHECK
	([dbo].[fPracticeRegisterForm#Check]([PracticeRegisterFormSID],[PracticeRegisterSID],[FormSID],[PracticeRegisterFormXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PracticeRegisterForm]
CHECK CONSTRAINT [ck_PracticeRegisterForm]
GO
ALTER TABLE [dbo].[PracticeRegisterForm]
	ADD
	CONSTRAINT [df_PracticeRegisterForm_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PracticeRegisterForm]
	ADD
	CONSTRAINT [df_PracticeRegisterForm_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterForm]
	ADD
	CONSTRAINT [df_PracticeRegisterForm_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterForm]
	ADD
	CONSTRAINT [df_PracticeRegisterForm_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterForm]
	ADD
	CONSTRAINT [df_PracticeRegisterForm_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterForm]
	ADD
	CONSTRAINT [df_PracticeRegisterForm_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PracticeRegisterForm]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterForm_SF_Form_FormSID]
	FOREIGN KEY ([FormSID]) REFERENCES [sf].[Form] ([FormSID])
ALTER TABLE [dbo].[PracticeRegisterForm]
	CHECK CONSTRAINT [fk_PracticeRegisterForm_SF_Form_FormSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form system ID column in the Practice Register Form table match a form system ID in the Form table. It also ensures that records in the Form table cannot be deleted if matching child records exist in Practice Register Form. Finally, the constraint blocks changes to the value of the form system ID column in the Form if matching child records exist in Practice Register Form.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'CONSTRAINT', N'fk_PracticeRegisterForm_SF_Form_FormSID'
GO
ALTER TABLE [dbo].[PracticeRegisterForm]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterForm_PracticeRegister_PracticeRegisterSID]
	FOREIGN KEY ([PracticeRegisterSID]) REFERENCES [dbo].[PracticeRegister] ([PracticeRegisterSID])
ALTER TABLE [dbo].[PracticeRegisterForm]
	CHECK CONSTRAINT [fk_PracticeRegisterForm_PracticeRegister_PracticeRegisterSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register system ID column in the Practice Register Form table match a practice register system ID in the Practice Register table. It also ensures that records in the Practice Register table cannot be deleted if matching child records exist in Practice Register Form. Finally, the constraint blocks changes to the value of the practice register system ID column in the Practice Register if matching child records exist in Practice Register Form.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'CONSTRAINT', N'fk_PracticeRegisterForm_PracticeRegister_PracticeRegisterSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterForm_FormSID_PracticeRegisterFormSID]
	ON [dbo].[PracticeRegisterForm] ([FormSID], [PracticeRegisterFormSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form SID foreign key column and avoids row contention on (parent) Form updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'INDEX', N'ix_PracticeRegisterForm_FormSID_PracticeRegisterFormSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PracticeRegisterForm_LegacyKey]
	ON [dbo].[PracticeRegisterForm] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'INDEX', N'ux_PracticeRegisterForm_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterForm_PracticeRegisterSID_PracticeRegisterFormSID]
	ON [dbo].[PracticeRegisterForm] ([PracticeRegisterSID], [PracticeRegisterFormSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register SID foreign key column and avoids row contention on (parent) Practice Register updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'INDEX', N'ix_PracticeRegisterForm_PracticeRegisterSID_PracticeRegisterFormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table identifies the forms that are used for applying, verifying (by emloyers or supervisors) and renewing to each  of the Practice Register.  If there are no differences in the forms required for each  of the register, then the same form is referenced for each sectino.  Each practice register  may, however, use different application forms for different scenarios. For example, the requirements for a foreign applicant may be more extensive than for domestic grads in which case a separate form template can be setup.  In order to help the applicant, determine which form to use for applying, the Eligibility Notes should be completed for display on the user interface during form selection.  The name displayed during form selection comes from the Form table itself.  Note that either the Renewal, Appliaction or Verification form type must be specified for each record but it is also possible that one form may be used for both renewal and applications.  In most cases each register s configuration should contain forms for at least Application and Renewal.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register form assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'PracticeRegisterFormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'PracticeRegisterSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'FormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice register form | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'PracticeRegisterFormXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice register form | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice register form record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice register form | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice register form record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register form record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterForm', 'CONSTRAINT', N'uk_PracticeRegisterForm_RowGUID'
GO
ALTER TABLE [dbo].[PracticeRegisterForm] SET (LOCK_ESCALATION = TABLE)
GO
