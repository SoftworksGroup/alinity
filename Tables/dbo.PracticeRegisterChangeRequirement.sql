SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeRegisterChangeRequirement] (
		[PracticeRegisterChangeRequirementSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[PracticeRegisterChangeSID]                [int] NOT NULL,
		[RegistrationRequirementSID]               [int] NOT NULL,
		[IsMandatory]                              [bit] NOT NULL,
		[ExpiryMonths]                             [smallint] NOT NULL,
		[IsActive]                                 [bit] NOT NULL,
		[RequirementSequence]                      [int] NOT NULL,
		[UserDefinedColumns]                       [xml] NULL,
		[PracticeRegisterChangeRequirementXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                                [bit] NOT NULL,
		[CreateUser]                               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                               [datetimeoffset](7) NOT NULL,
		[UpdateUser]                               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                               [datetimeoffset](7) NOT NULL,
		[RowGUID]                                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                                 [timestamp] NOT NULL,
		CONSTRAINT [uk_PracticeRegisterChangeRequirement_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PracticeRegisterChangeRequirement]
		PRIMARY KEY
		CLUSTERED
		([PracticeRegisterChangeRequirementSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Practice Register Change Requirement table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'CONSTRAINT', N'pk_PracticeRegisterChangeRequirement'
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PracticeRegisterChangeRequirement]
	CHECK
	([dbo].[fPracticeRegisterChangeRequirement#Check]([PracticeRegisterChangeRequirementSID],[PracticeRegisterChangeSID],[RegistrationRequirementSID],[IsMandatory],[ExpiryMonths],[IsActive],[RequirementSequence],[PracticeRegisterChangeRequirementXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
CHECK CONSTRAINT [ck_PracticeRegisterChangeRequirement]
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	ADD
	CONSTRAINT [df_PracticeRegisterChangeRequirement_IsMandatory]
	DEFAULT (CONVERT([bit],(0))) FOR [IsMandatory]
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	ADD
	CONSTRAINT [df_PracticeRegisterChangeRequirement_ExpiryMonths]
	DEFAULT ((0)) FOR [ExpiryMonths]
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	ADD
	CONSTRAINT [df_PracticeRegisterChangeRequirement_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	ADD
	CONSTRAINT [df_PracticeRegisterChangeRequirement_RequirementSequence]
	DEFAULT ((10)) FOR [RequirementSequence]
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	ADD
	CONSTRAINT [df_PracticeRegisterChangeRequirement_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	ADD
	CONSTRAINT [df_PracticeRegisterChangeRequirement_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	ADD
	CONSTRAINT [df_PracticeRegisterChangeRequirement_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	ADD
	CONSTRAINT [df_PracticeRegisterChangeRequirement_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	ADD
	CONSTRAINT [df_PracticeRegisterChangeRequirement_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	ADD
	CONSTRAINT [df_PracticeRegisterChangeRequirement_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterChangeRequirement_RegistrationRequirement_RegistrationRequirementSID]
	FOREIGN KEY ([RegistrationRequirementSID]) REFERENCES [dbo].[RegistrationRequirement] ([RegistrationRequirementSID])
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	CHECK CONSTRAINT [fk_PracticeRegisterChangeRequirement_RegistrationRequirement_RegistrationRequirementSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registration requirement system ID column in the Practice Register Change Requirement table match a registration requirement system ID in the Registration Requirement table. It also ensures that records in the Registration Requirement table cannot be deleted if matching child records exist in Practice Register Change Requirement. Finally, the constraint blocks changes to the value of the registration requirement system ID column in the Registration Requirement if matching child records exist in Practice Register Change Requirement.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'CONSTRAINT', N'fk_PracticeRegisterChangeRequirement_RegistrationRequirement_RegistrationRequirementSID'
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegisterChangeRequirement_PracticeRegisterChange_PracticeRegisterChangeSID]
	FOREIGN KEY ([PracticeRegisterChangeSID]) REFERENCES [dbo].[PracticeRegisterChange] ([PracticeRegisterChangeSID])
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement]
	CHECK CONSTRAINT [fk_PracticeRegisterChangeRequirement_PracticeRegisterChange_PracticeRegisterChangeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register change system ID column in the Practice Register Change Requirement table match a practice register change system ID in the Practice Register Change table. It also ensures that records in the Practice Register Change table cannot be deleted if matching child records exist in Practice Register Change Requirement. Finally, the constraint blocks changes to the value of the practice register change system ID column in the Practice Register Change if matching child records exist in Practice Register Change Requirement.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'CONSTRAINT', N'fk_PracticeRegisterChangeRequirement_PracticeRegisterChange_PracticeRegisterChangeSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterChangeRequirement_PracticeRegisterChangeSID_PracticeRegisterChangeRequirementSID]
	ON [dbo].[PracticeRegisterChangeRequirement] ([PracticeRegisterChangeSID], [PracticeRegisterChangeRequirementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register Change SID foreign key column and avoids row contention on (parent) Practice Register Change updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'INDEX', N'ix_PracticeRegisterChangeRequirement_PracticeRegisterChangeSID_PracticeRegisterChangeRequirementSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegisterChangeRequirement_RegistrationRequirementSID_PracticeRegisterChangeRequirementSID]
	ON [dbo].[PracticeRegisterChangeRequirement] ([RegistrationRequirementSID], [PracticeRegisterChangeRequirementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registration Requirement SID foreign key column and avoids row contention on (parent) Registration Requirement updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'INDEX', N'ix_PracticeRegisterChangeRequirement_RegistrationRequirementSID_PracticeRegisterChangeRequirementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register change requirement assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'PracticeRegisterChangeRequirementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register change assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'PracticeRegisterChangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration requirement assigned to this practice register change requirement', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'RegistrationRequirementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the requirement is mandatory for this practice register change | When checked, the UI will not display the option for administrators to mark the requirement "Not Applicable" ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'IsMandatory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of months a reviewed document or exam remains valid - e.g. a new Crimincal Record Check may be required every 36 months | This is a deafult copied to the change-requirement since the setting may be different in different registration-change contexts.  UI does not prompt unless Doc-Type or Exam Type is set.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'ExpiryMonths'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice register change requirement record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An value for ordering the presentation of requirements on the screen', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'RequirementSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice register change requirement | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'PracticeRegisterChangeRequirementXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice register change requirement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice register change requirement record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice register change requirement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice register change requirement record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register change requirement record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegisterChangeRequirement', 'CONSTRAINT', N'uk_PracticeRegisterChangeRequirement_RowGUID'
GO
ALTER TABLE [dbo].[PracticeRegisterChangeRequirement] SET (LOCK_ESCALATION = TABLE)
GO
