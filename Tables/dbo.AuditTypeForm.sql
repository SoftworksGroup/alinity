SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AuditTypeForm] (
		[AuditTypeFormSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[AuditTypeSID]           [int] NOT NULL,
		[FormSID]                [int] NOT NULL,
		[IsReviewForm]           [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[AuditTypeFormXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_AuditTypeForm_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_AuditTypeForm]
		PRIMARY KEY
		CLUSTERED
		([AuditTypeFormSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Audit Type Form table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'CONSTRAINT', N'pk_AuditTypeForm'
GO
ALTER TABLE [dbo].[AuditTypeForm]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_AuditTypeForm]
	CHECK
	([dbo].[fAuditTypeForm#Check]([AuditTypeFormSID],[AuditTypeSID],[FormSID],[IsReviewForm],[AuditTypeFormXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[AuditTypeForm]
CHECK CONSTRAINT [ck_AuditTypeForm]
GO
ALTER TABLE [dbo].[AuditTypeForm]
	ADD
	CONSTRAINT [df_AuditTypeForm_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[AuditTypeForm]
	ADD
	CONSTRAINT [df_AuditTypeForm_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[AuditTypeForm]
	ADD
	CONSTRAINT [df_AuditTypeForm_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[AuditTypeForm]
	ADD
	CONSTRAINT [df_AuditTypeForm_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[AuditTypeForm]
	ADD
	CONSTRAINT [df_AuditTypeForm_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[AuditTypeForm]
	ADD
	CONSTRAINT [df_AuditTypeForm_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[AuditTypeForm]
	ADD
	CONSTRAINT [df_AuditTypeForm_IsReviewForm]
	DEFAULT (CONVERT([bit],(0))) FOR [IsReviewForm]
GO
ALTER TABLE [dbo].[AuditTypeForm]
	WITH CHECK
	ADD CONSTRAINT [fk_AuditTypeForm_AuditType_AuditTypeSID]
	FOREIGN KEY ([AuditTypeSID]) REFERENCES [dbo].[AuditType] ([AuditTypeSID])
ALTER TABLE [dbo].[AuditTypeForm]
	CHECK CONSTRAINT [fk_AuditTypeForm_AuditType_AuditTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the audit type system ID column in the Audit Type Form table match a audit type system ID in the Audit Type table. It also ensures that records in the Audit Type table cannot be deleted if matching child records exist in Audit Type Form. Finally, the constraint blocks changes to the value of the audit type system ID column in the Audit Type if matching child records exist in Audit Type Form.', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'CONSTRAINT', N'fk_AuditTypeForm_AuditType_AuditTypeSID'
GO
ALTER TABLE [dbo].[AuditTypeForm]
	WITH CHECK
	ADD CONSTRAINT [fk_AuditTypeForm_SF_Form_FormSID]
	FOREIGN KEY ([FormSID]) REFERENCES [sf].[Form] ([FormSID])
ALTER TABLE [dbo].[AuditTypeForm]
	CHECK CONSTRAINT [fk_AuditTypeForm_SF_Form_FormSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form system ID column in the Audit Type Form table match a form system ID in the Form table. It also ensures that records in the Form table cannot be deleted if matching child records exist in Audit Type Form. Finally, the constraint blocks changes to the value of the form system ID column in the Form if matching child records exist in Audit Type Form.', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'CONSTRAINT', N'fk_AuditTypeForm_SF_Form_FormSID'
GO
CREATE NONCLUSTERED INDEX [ix_AuditTypeForm_AuditTypeSID_AuditTypeFormSID]
	ON [dbo].[AuditTypeForm] ([AuditTypeSID], [AuditTypeFormSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Audit Type SID foreign key column and avoids row contention on (parent) Audit Type updates', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'INDEX', N'ix_AuditTypeForm_AuditTypeSID_AuditTypeFormSID'
GO
CREATE NONCLUSTERED INDEX [ix_AuditTypeForm_FormSID_AuditTypeFormSID]
	ON [dbo].[AuditTypeForm] ([FormSID], [AuditTypeFormSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form SID foreign key column and avoids row contention on (parent) Form updates', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'INDEX', N'ix_AuditTypeForm_FormSID_AuditTypeFormSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_AuditTypeForm_LegacyKey]
	ON [dbo].[AuditTypeForm] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'INDEX', N'ux_AuditTypeForm_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the audit type form assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'AuditTypeFormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of audit type form', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'AuditTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form assigned to this audit type', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'FormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this form is filled out by the person(s) reviewing the audit (not the Registrant audit form)', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'IsReviewForm'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the audit type form | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'AuditTypeFormXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the audit type form | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this audit type form record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the audit type form | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the audit type form record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the audit type form record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'AuditTypeForm', 'CONSTRAINT', N'uk_AuditTypeForm_RowGUID'
GO
ALTER TABLE [dbo].[AuditTypeForm] SET (LOCK_ESCALATION = TABLE)
GO
