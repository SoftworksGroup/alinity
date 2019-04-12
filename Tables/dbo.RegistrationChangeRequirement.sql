SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrationChangeRequirement] (
		[RegistrationChangeRequirementSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrationChangeSID]                [int] NOT NULL,
		[RegistrationRequirementSID]           [int] NOT NULL,
		[PersonDocSID]                         [int] NULL,
		[RegistrantExamSID]                    [int] NULL,
		[ExpiryMonths]                         [smallint] NOT NULL,
		[RequirementStatusSID]                 [int] NOT NULL,
		[RequirementSequence]                  [int] NOT NULL,
		[UserDefinedColumns]                   [xml] NULL,
		[RegistrationChangeRequirementXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                            [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                            [bit] NOT NULL,
		[CreateUser]                           [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                           [datetimeoffset](7) NOT NULL,
		[UpdateUser]                           [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                           [datetimeoffset](7) NOT NULL,
		[RowGUID]                              [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                             [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrationChangeRequirement_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrationChangeRequirement]
		PRIMARY KEY
		CLUSTERED
		([RegistrationChangeRequirementSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registration Change Requirement table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'CONSTRAINT', N'pk_RegistrationChangeRequirement'
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrationChangeRequirement]
	CHECK
	([dbo].[fRegistrationChangeRequirement#Check]([RegistrationChangeRequirementSID],[RegistrationChangeSID],[RegistrationRequirementSID],[PersonDocSID],[RegistrantExamSID],[ExpiryMonths],[RequirementStatusSID],[RequirementSequence],[RegistrationChangeRequirementXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
CHECK CONSTRAINT [ck_RegistrationChangeRequirement]
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	ADD
	CONSTRAINT [df_RegistrationChangeRequirement_ExpiryMonths]
	DEFAULT ((0)) FOR [ExpiryMonths]
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	ADD
	CONSTRAINT [df_RegistrationChangeRequirement_RequirementSequence]
	DEFAULT ((10)) FOR [RequirementSequence]
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	ADD
	CONSTRAINT [df_RegistrationChangeRequirement_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	ADD
	CONSTRAINT [df_RegistrationChangeRequirement_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	ADD
	CONSTRAINT [df_RegistrationChangeRequirement_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	ADD
	CONSTRAINT [df_RegistrationChangeRequirement_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	ADD
	CONSTRAINT [df_RegistrationChangeRequirement_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	ADD
	CONSTRAINT [df_RegistrationChangeRequirement_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationChangeRequirement_RegistrationRequirement_RegistrationRequirementSID]
	FOREIGN KEY ([RegistrationRequirementSID]) REFERENCES [dbo].[RegistrationRequirement] ([RegistrationRequirementSID])
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	CHECK CONSTRAINT [fk_RegistrationChangeRequirement_RegistrationRequirement_RegistrationRequirementSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registration requirement system ID column in the Registration Change Requirement table match a registration requirement system ID in the Registration Requirement table. It also ensures that records in the Registration Requirement table cannot be deleted if matching child records exist in Registration Change Requirement. Finally, the constraint blocks changes to the value of the registration requirement system ID column in the Registration Requirement if matching child records exist in Registration Change Requirement.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'CONSTRAINT', N'fk_RegistrationChangeRequirement_RegistrationRequirement_RegistrationRequirementSID'
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationChangeRequirement_RequirementStatus_RequirementStatusSID]
	FOREIGN KEY ([RequirementStatusSID]) REFERENCES [dbo].[RequirementStatus] ([RequirementStatusSID])
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	CHECK CONSTRAINT [fk_RegistrationChangeRequirement_RequirementStatus_RequirementStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the requirement status system ID column in the Registration Change Requirement table match a requirement status system ID in the Requirement Status table. It also ensures that records in the Requirement Status table cannot be deleted if matching child records exist in Registration Change Requirement. Finally, the constraint blocks changes to the value of the requirement status system ID column in the Requirement Status if matching child records exist in Registration Change Requirement.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'CONSTRAINT', N'fk_RegistrationChangeRequirement_RequirementStatus_RequirementStatusSID'
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationChangeRequirement_PersonDoc_PersonDocSID]
	FOREIGN KEY ([PersonDocSID]) REFERENCES [dbo].[PersonDoc] ([PersonDocSID])
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	CHECK CONSTRAINT [fk_RegistrationChangeRequirement_PersonDoc_PersonDocSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person doc system ID column in the Registration Change Requirement table match a person doc system ID in the Person Doc table. It also ensures that records in the Person Doc table cannot be deleted if matching child records exist in Registration Change Requirement. Finally, the constraint blocks changes to the value of the person doc system ID column in the Person Doc if matching child records exist in Registration Change Requirement.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'CONSTRAINT', N'fk_RegistrationChangeRequirement_PersonDoc_PersonDocSID'
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationChangeRequirement_RegistrantExam_RegistrantExamSID]
	FOREIGN KEY ([RegistrantExamSID]) REFERENCES [dbo].[RegistrantExam] ([RegistrantExamSID])
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	CHECK CONSTRAINT [fk_RegistrationChangeRequirement_RegistrantExam_RegistrantExamSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant exam system ID column in the Registration Change Requirement table match a registrant exam system ID in the Registrant Exam table. It also ensures that records in the Registrant Exam table cannot be deleted if matching child records exist in Registration Change Requirement. Finally, the constraint blocks changes to the value of the registrant exam system ID column in the Registrant Exam if matching child records exist in Registration Change Requirement.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'CONSTRAINT', N'fk_RegistrationChangeRequirement_RegistrantExam_RegistrantExamSID'
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationChangeRequirement_RegistrationChange_RegistrationChangeSID]
	FOREIGN KEY ([RegistrationChangeSID]) REFERENCES [dbo].[RegistrationChange] ([RegistrationChangeSID])
ALTER TABLE [dbo].[RegistrationChangeRequirement]
	CHECK CONSTRAINT [fk_RegistrationChangeRequirement_RegistrationChange_RegistrationChangeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registration change system ID column in the Registration Change Requirement table match a registration change system ID in the Registration Change table. It also ensures that records in the Registration Change table cannot be deleted if matching child records exist in Registration Change Requirement. Finally, the constraint blocks changes to the value of the registration change system ID column in the Registration Change if matching child records exist in Registration Change Requirement.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'CONSTRAINT', N'fk_RegistrationChangeRequirement_RegistrationChange_RegistrationChangeSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationChangeRequirement_PersonDocSID_RegistrationChangeRequirementSID]
	ON [dbo].[RegistrationChangeRequirement] ([PersonDocSID], [RegistrationChangeRequirementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person Doc SID foreign key column and avoids row contention on (parent) Person Doc updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'INDEX', N'ix_RegistrationChangeRequirement_PersonDocSID_RegistrationChangeRequirementSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationChangeRequirement_RegistrantExamSID_RegistrationChangeRequirementSID]
	ON [dbo].[RegistrationChangeRequirement] ([RegistrantExamSID], [RegistrationChangeRequirementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant Exam SID foreign key column and avoids row contention on (parent) Registrant Exam updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'INDEX', N'ix_RegistrationChangeRequirement_RegistrantExamSID_RegistrationChangeRequirementSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationChangeRequirement_RegistrationChangeSID_RegistrationChangeRequirementSID]
	ON [dbo].[RegistrationChangeRequirement] ([RegistrationChangeSID], [RegistrationChangeRequirementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registration Change SID foreign key column and avoids row contention on (parent) Registration Change updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'INDEX', N'ix_RegistrationChangeRequirement_RegistrationChangeSID_RegistrationChangeRequirementSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationChangeRequirement_RegistrationRequirementSID_RegistrationChangeRequirementSID]
	ON [dbo].[RegistrationChangeRequirement] ([RegistrationRequirementSID], [RegistrationChangeRequirementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registration Requirement SID foreign key column and avoids row contention on (parent) Registration Requirement updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'INDEX', N'ix_RegistrationChangeRequirement_RegistrationRequirementSID_RegistrationChangeRequirementSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationChangeRequirement_RequirementStatusSID_RegistrationChangeRequirementSID]
	ON [dbo].[RegistrationChangeRequirement] ([RequirementStatusSID], [RegistrationChangeRequirementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Requirement Status SID foreign key column and avoids row contention on (parent) Requirement Status updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'INDEX', N'ix_RegistrationChangeRequirement_RequirementStatusSID_RegistrationChangeRequirementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration change requirement assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'RegistrationChangeRequirementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration change assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'RegistrationChangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration requirement assigned to this registration change requirement', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'RegistrationRequirementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person doc assigned to this registration change requirement', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'PersonDocSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant exam assigned to this registration change requirement', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'RegistrantExamSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of months a reviewed document or exam remains valid - e.g. a new Crimincal Record Check may be required every 36 months | UI does not prompt unless Doc-Type or Exam Type is set.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'ExpiryMonths'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the registration change requirement', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'RequirementStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An value for ordering the presentation of requirements on the screen', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'RequirementSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registration change requirement | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'RegistrationChangeRequirementXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registration change requirement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registration change requirement record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registration change requirement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registration change requirement record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration change requirement record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeRequirement', 'CONSTRAINT', N'uk_RegistrationChangeRequirement_RowGUID'
GO
ALTER TABLE [dbo].[RegistrationChangeRequirement] SET (LOCK_ESCALATION = TABLE)
GO
