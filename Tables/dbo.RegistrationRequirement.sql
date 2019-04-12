SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrationRequirement] (
		[RegistrationRequirementSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrationRequirementTypeSID]     [int] NOT NULL,
		[RegistrationRequirementLabel]       [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RequirementDescription]             [varbinary](max) NULL,
		[AdminGuidance]                      [varbinary](max) NULL,
		[PersonDocTypeSID]                   [int] NULL,
		[ExamSID]                            [int] NULL,
		[ExpiryMonths]                       [smallint] NOT NULL,
		[IsActive]                           [bit] NOT NULL,
		[UserDefinedColumns]                 [xml] NULL,
		[RegistrationRequirementXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                          [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                          [bit] NOT NULL,
		[CreateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                         [datetimeoffset](7) NOT NULL,
		[UpdateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                         [datetimeoffset](7) NOT NULL,
		[RowGUID]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                           [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrationRequirement_RegistrationRequirementLabel]
		UNIQUE
		NONCLUSTERED
		([RegistrationRequirementLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrationRequirement_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrationRequirement]
		PRIMARY KEY
		CLUSTERED
		([RegistrationRequirementSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registration Requirement table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'CONSTRAINT', N'pk_RegistrationRequirement'
GO
ALTER TABLE [dbo].[RegistrationRequirement]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrationRequirement]
	CHECK
	([dbo].[fRegistrationRequirement#Check]([RegistrationRequirementSID],[RegistrationRequirementTypeSID],[RegistrationRequirementLabel],[PersonDocTypeSID],[ExamSID],[ExpiryMonths],[IsActive],[RegistrationRequirementXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrationRequirement]
CHECK CONSTRAINT [ck_RegistrationRequirement]
GO
ALTER TABLE [dbo].[RegistrationRequirement]
	ADD
	CONSTRAINT [df_RegistrationRequirement_ExpiryMonths]
	DEFAULT ((0)) FOR [ExpiryMonths]
GO
ALTER TABLE [dbo].[RegistrationRequirement]
	ADD
	CONSTRAINT [df_RegistrationRequirement_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[RegistrationRequirement]
	ADD
	CONSTRAINT [df_RegistrationRequirement_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrationRequirement]
	ADD
	CONSTRAINT [df_RegistrationRequirement_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrationRequirement]
	ADD
	CONSTRAINT [df_RegistrationRequirement_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrationRequirement]
	ADD
	CONSTRAINT [df_RegistrationRequirement_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrationRequirement]
	ADD
	CONSTRAINT [df_RegistrationRequirement_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrationRequirement]
	ADD
	CONSTRAINT [df_RegistrationRequirement_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrationRequirement]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationRequirement_PersonDocType_PersonDocTypeSID]
	FOREIGN KEY ([PersonDocTypeSID]) REFERENCES [dbo].[PersonDocType] ([PersonDocTypeSID])
ALTER TABLE [dbo].[RegistrationRequirement]
	CHECK CONSTRAINT [fk_RegistrationRequirement_PersonDocType_PersonDocTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person doc type system ID column in the Registration Requirement table match a person doc type system ID in the Person Doc Type table. It also ensures that records in the Person Doc Type table cannot be deleted if matching child records exist in Registration Requirement. Finally, the constraint blocks changes to the value of the person doc type system ID column in the Person Doc Type if matching child records exist in Registration Requirement.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'CONSTRAINT', N'fk_RegistrationRequirement_PersonDocType_PersonDocTypeSID'
GO
ALTER TABLE [dbo].[RegistrationRequirement]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationRequirement_Exam_ExamSID]
	FOREIGN KEY ([ExamSID]) REFERENCES [dbo].[Exam] ([ExamSID])
ALTER TABLE [dbo].[RegistrationRequirement]
	CHECK CONSTRAINT [fk_RegistrationRequirement_Exam_ExamSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the exam system ID column in the Registration Requirement table match a exam system ID in the Exam table. It also ensures that records in the Exam table cannot be deleted if matching child records exist in Registration Requirement. Finally, the constraint blocks changes to the value of the exam system ID column in the Exam if matching child records exist in Registration Requirement.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'CONSTRAINT', N'fk_RegistrationRequirement_Exam_ExamSID'
GO
ALTER TABLE [dbo].[RegistrationRequirement]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationRequirement_RegistrationRequirementType_RegistrationRequirementTypeSID]
	FOREIGN KEY ([RegistrationRequirementTypeSID]) REFERENCES [dbo].[RegistrationRequirementType] ([RegistrationRequirementTypeSID])
ALTER TABLE [dbo].[RegistrationRequirement]
	CHECK CONSTRAINT [fk_RegistrationRequirement_RegistrationRequirementType_RegistrationRequirementTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registration requirement type system ID column in the Registration Requirement table match a registration requirement type system ID in the Registration Requirement Type table. It also ensures that records in the Registration Requirement Type table cannot be deleted if matching child records exist in Registration Requirement. Finally, the constraint blocks changes to the value of the registration requirement type system ID column in the Registration Requirement Type if matching child records exist in Registration Requirement.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'CONSTRAINT', N'fk_RegistrationRequirement_RegistrationRequirementType_RegistrationRequirementTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationRequirement_ExamSID_RegistrationRequirementSID]
	ON [dbo].[RegistrationRequirement] ([ExamSID], [RegistrationRequirementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Exam SID foreign key column and avoids row contention on (parent) Exam updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'INDEX', N'ix_RegistrationRequirement_ExamSID_RegistrationRequirementSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationRequirement_PersonDocTypeSID_RegistrationRequirementSID]
	ON [dbo].[RegistrationRequirement] ([PersonDocTypeSID], [RegistrationRequirementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person Doc Type SID foreign key column and avoids row contention on (parent) Person Doc Type updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'INDEX', N'ix_RegistrationRequirement_PersonDocTypeSID_RegistrationRequirementSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationRequirement_RegistrationRequirementTypeSID_RegistrationRequirementSID]
	ON [dbo].[RegistrationRequirement] ([RegistrationRequirementTypeSID], [RegistrationRequirementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registration Requirement Type SID foreign key column and avoids row contention on (parent) Registration Requirement Type updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'INDEX', N'ix_RegistrationRequirement_RegistrationRequirementTypeSID_RegistrationRequirementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration requirement assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'RegistrationRequirementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of registration requirement', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'RegistrationRequirementTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the registration requirement to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'RegistrationRequirementLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the Person Doc Type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'PersonDocTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the exam type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'ExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of months a reviewed document or exam remains valid - e.g. a new Crimincal Record Check may be required every 36 months | This is a deafult copied to the change-requirement since the setting may be different in different registration-change contexts.  UI does not prompt unless Doc-Type or Exam Type is set.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'ExpiryMonths'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this registration requirement record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registration requirement | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'RegistrationRequirementXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registration requirement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registration requirement record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registration requirement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registration requirement record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration requirement record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Registration Requirement Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'CONSTRAINT', N'uk_RegistrationRequirement_RegistrationRequirementLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirement', 'CONSTRAINT', N'uk_RegistrationRequirement_RowGUID'
GO
ALTER TABLE [dbo].[RegistrationRequirement] SET (LOCK_ESCALATION = TABLE)
GO
