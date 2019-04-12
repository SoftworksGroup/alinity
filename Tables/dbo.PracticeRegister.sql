SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PracticeRegister] (
		[PracticeRegisterSID]             [int] IDENTITY(1000001, 1) NOT NULL,
		[PracticeRegisterTypeSID]         [int] NOT NULL,
		[RegistrationScheduleSID]         [int] NOT NULL,
		[PracticeRegisterName]            [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PracticeRegisterLabel]           [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsActivePractice]                [bit] NOT NULL,
		[IsPublicRegistryEnabled]         [bit] NOT NULL,
		[IsRenewalEnabled]                [bit] NOT NULL,
		[IsLearningPlanEnabled]           [bit] NOT NULL,
		[IsNextCEFormAutoAdded]           [bit] NOT NULL,
		[IsEligibleSupervisor]            [bit] NOT NULL,
		[IsSupervisionRequired]           [bit] NOT NULL,
		[IsEmploymentTerminated]          [bit] NOT NULL,
		[IsGroupMembershipTerminated]     [bit] NOT NULL,
		[TermPermitDays]                  [int] NOT NULL,
		[RegisterRank]                    [smallint] NOT NULL,
		[LearningModelSID]                [int] NULL,
		[ReasonGroupSID]                  [int] NULL,
		[IsDefault]                       [bit] NOT NULL,
		[IsDefaultInactivePractice]       [bit] NOT NULL,
		[Description]                     [varbinary](max) NULL,
		[IsActive]                        [bit] NOT NULL,
		[UserDefinedColumns]              [xml] NULL,
		[PracticeRegisterXID]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                       [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                       [bit] NOT NULL,
		[CreateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                      [datetimeoffset](7) NOT NULL,
		[UpdateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                      [datetimeoffset](7) NOT NULL,
		[RowGUID]                         [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                        [timestamp] NOT NULL,
		CONSTRAINT [uk_PracticeRegister_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PracticeRegister_PracticeRegisterName]
		UNIQUE
		NONCLUSTERED
		([PracticeRegisterName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PracticeRegister_PracticeRegisterLabel]
		UNIQUE
		NONCLUSTERED
		([PracticeRegisterLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PracticeRegister]
		PRIMARY KEY
		CLUSTERED
		([PracticeRegisterSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Practice Register table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'CONSTRAINT', N'pk_PracticeRegister'
GO
ALTER TABLE [dbo].[PracticeRegister]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PracticeRegister]
	CHECK
	([dbo].[fPracticeRegister#Check]([PracticeRegisterSID],[PracticeRegisterTypeSID],[RegistrationScheduleSID],[PracticeRegisterName],[PracticeRegisterLabel],[IsActivePractice],[IsPublicRegistryEnabled],[IsRenewalEnabled],[IsLearningPlanEnabled],[IsNextCEFormAutoAdded],[IsEligibleSupervisor],[IsSupervisionRequired],[IsEmploymentTerminated],[IsGroupMembershipTerminated],[TermPermitDays],[RegisterRank],[LearningModelSID],[ReasonGroupSID],[IsDefault],[IsDefaultInactivePractice],[IsActive],[PracticeRegisterXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[PracticeRegister]
CHECK CONSTRAINT [ck_PracticeRegister]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsActivePractice]
	DEFAULT ((1)) FOR [IsActivePractice]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsPublicRegistryEnabled]
	DEFAULT ((1)) FOR [IsPublicRegistryEnabled]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsRenewalEnabled]
	DEFAULT ((1)) FOR [IsRenewalEnabled]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsLearningPlanEnabled]
	DEFAULT ((0)) FOR [IsLearningPlanEnabled]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsNextCEFormAutoAdded]
	DEFAULT (CONVERT([bit],(1))) FOR [IsNextCEFormAutoAdded]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsEligibleSupervisor]
	DEFAULT (CONVERT([bit],(0))) FOR [IsEligibleSupervisor]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsSupervisionRequired]
	DEFAULT (CONVERT([bit],(0))) FOR [IsSupervisionRequired]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsEmploymentTerminated]
	DEFAULT (CONVERT([bit],(0))) FOR [IsEmploymentTerminated]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsGroupMembershipTerminated]
	DEFAULT (CONVERT([bit],(0))) FOR [IsGroupMembershipTerminated]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_TermPermitDays]
	DEFAULT ((0)) FOR [TermPermitDays]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_RegisterRank]
	DEFAULT ((500)) FOR [RegisterRank]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsDefaultInactivePractice]
	DEFAULT (CONVERT([bit],(0))) FOR [IsDefaultInactivePractice]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[PracticeRegister]
	ADD
	CONSTRAINT [df_PracticeRegister_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[PracticeRegister]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegister_PracticeRegisterType_PracticeRegisterTypeSID]
	FOREIGN KEY ([PracticeRegisterTypeSID]) REFERENCES [dbo].[PracticeRegisterType] ([PracticeRegisterTypeSID])
ALTER TABLE [dbo].[PracticeRegister]
	CHECK CONSTRAINT [fk_PracticeRegister_PracticeRegisterType_PracticeRegisterTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register type system ID column in the Practice Register table match a practice register type system ID in the Practice Register Type table. It also ensures that records in the Practice Register Type table cannot be deleted if matching child records exist in Practice Register. Finally, the constraint blocks changes to the value of the practice register type system ID column in the Practice Register Type if matching child records exist in Practice Register.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'CONSTRAINT', N'fk_PracticeRegister_PracticeRegisterType_PracticeRegisterTypeSID'
GO
ALTER TABLE [dbo].[PracticeRegister]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegister_ReasonGroup_ReasonGroupSID]
	FOREIGN KEY ([ReasonGroupSID]) REFERENCES [dbo].[ReasonGroup] ([ReasonGroupSID])
ALTER TABLE [dbo].[PracticeRegister]
	CHECK CONSTRAINT [fk_PracticeRegister_ReasonGroup_ReasonGroupSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason group system ID column in the Practice Register table match a reason group system ID in the Reason Group table. It also ensures that records in the Reason Group table cannot be deleted if matching child records exist in Practice Register. Finally, the constraint blocks changes to the value of the reason group system ID column in the Reason Group if matching child records exist in Practice Register.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'CONSTRAINT', N'fk_PracticeRegister_ReasonGroup_ReasonGroupSID'
GO
ALTER TABLE [dbo].[PracticeRegister]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegister_RegistrationSchedule_RegistrationScheduleSID]
	FOREIGN KEY ([RegistrationScheduleSID]) REFERENCES [dbo].[RegistrationSchedule] ([RegistrationScheduleSID])
ALTER TABLE [dbo].[PracticeRegister]
	CHECK CONSTRAINT [fk_PracticeRegister_RegistrationSchedule_RegistrationScheduleSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registration schedule system ID column in the Practice Register table match a registration schedule system ID in the Registration Schedule table. It also ensures that records in the Registration Schedule table cannot be deleted if matching child records exist in Practice Register. Finally, the constraint blocks changes to the value of the registration schedule system ID column in the Registration Schedule if matching child records exist in Practice Register.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'CONSTRAINT', N'fk_PracticeRegister_RegistrationSchedule_RegistrationScheduleSID'
GO
ALTER TABLE [dbo].[PracticeRegister]
	WITH CHECK
	ADD CONSTRAINT [fk_PracticeRegister_LearningModel_LearningModelSID]
	FOREIGN KEY ([LearningModelSID]) REFERENCES [dbo].[LearningModel] ([LearningModelSID])
ALTER TABLE [dbo].[PracticeRegister]
	CHECK CONSTRAINT [fk_PracticeRegister_LearningModel_LearningModelSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the learning model system ID column in the Practice Register table match a learning model system ID in the Learning Model table. It also ensures that records in the Learning Model table cannot be deleted if matching child records exist in Practice Register. Finally, the constraint blocks changes to the value of the learning model system ID column in the Learning Model if matching child records exist in Practice Register.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'CONSTRAINT', N'fk_PracticeRegister_LearningModel_LearningModelSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegister_LearningModelSID_PracticeRegisterSID]
	ON [dbo].[PracticeRegister] ([LearningModelSID], [PracticeRegisterSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Learning Model SID foreign key column and avoids row contention on (parent) Learning Model updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'INDEX', N'ix_PracticeRegister_LearningModelSID_PracticeRegisterSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegister_PracticeRegisterTypeSID_PracticeRegisterSID]
	ON [dbo].[PracticeRegister] ([PracticeRegisterTypeSID], [PracticeRegisterSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register Type SID foreign key column and avoids row contention on (parent) Practice Register Type updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'INDEX', N'ix_PracticeRegister_PracticeRegisterTypeSID_PracticeRegisterSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegister_ReasonGroupSID_PracticeRegisterSID]
	ON [dbo].[PracticeRegister] ([ReasonGroupSID], [PracticeRegisterSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason Group SID foreign key column and avoids row contention on (parent) Reason Group updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'INDEX', N'ix_PracticeRegister_ReasonGroupSID_PracticeRegisterSID'
GO
CREATE NONCLUSTERED INDEX [ix_PracticeRegister_RegistrationScheduleSID_PracticeRegisterSID]
	ON [dbo].[PracticeRegister] ([RegistrationScheduleSID], [PracticeRegisterSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registration Schedule SID foreign key column and avoids row contention on (parent) Registration Schedule updates', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'INDEX', N'ix_PracticeRegister_RegistrationScheduleSID_PracticeRegisterSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PracticeRegister_IsDefault]
	ON [dbo].[PracticeRegister] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Practice Register', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'INDEX', N'ux_PracticeRegister_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PracticeRegister_IsDefaultInactivePractice]
	ON [dbo].[PracticeRegister] ([IsDefaultInactivePractice])
	WHERE (([IsDefaultInactivePractice]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Is Default Inactive Practice value is not duplicated where the condition: "([IsDefaultInactivePractice]=(1))" is met', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'INDEX', N'ux_PracticeRegister_IsDefaultInactivePractice'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PracticeRegister_LegacyKey]
	ON [dbo].[PracticeRegister] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'INDEX', N'ux_PracticeRegister_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The records in this table represent the types of registration or registrations supported by the organization.  Requirements for licensing, prices, learning plan rules, scheudule for renewal, late fees etc. are all associated with these records.  It is possible to create sections within a register for display or where different requirements apply for membership.  The sections are most often created to support multiple streams of applicants (local, national, international).  The Reason-Group is optional but is provided to support recording of reasons why registrants change onto this register (e.g. to record why a member is renewing as inactive for example).  ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice register assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'PracticeRegisterSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of practice register', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'PracticeRegisterTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration schedule assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'RegistrationScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the practice register to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'PracticeRegisterName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the practice register to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'PracticeRegisterLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates people on this register are authorized for active practice - if not checked, then the register is for non-practicing members which may include retired, maternity leave, students, etc. and competence requirements do not apply', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsActivePractice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates people included on this register will appear on the College''s public website unless they have opted out individually.  Note that this value is automatically disabled for in-active practice registers.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsPublicRegistryEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the renewal process is enabled for this register.  This value will generally be on except for some types of permits which cannot renew.  ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsRenewalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a CE/Learning plan should be enabled for members on this register  | This value must be checked for active-practice registers', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsLearningPlanEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a Learning Plan/CE form should automatically be added for the next reporting period when the previous CE report is complete', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsNextCEFormAutoAdded'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates members on this register are eligible to act as employment supervisors for other members', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsEligibleSupervisor'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates members on this register must have supervisors on practice (e.g. applies to provisional, student registers, etc.)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsSupervisionRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Directs the application to expire active employment records when the member is moved onto this register | This setting only applies where employment terms are used (effective time must be filled in)', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsEmploymentTerminated'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Directs the application to expire all group memberships when the member is moved onto this register ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsGroupMembershipTerminated'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The default length of the term in days - applies only to Term-Permits | An administrator can override the default length of the term-permit by setting specific effective and expiry dates when the registration is created', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'TermPermitDays'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is relevant to Colleges that allow multiple concurrent registrations only.  It is used to set the priority or sequence of the most important registration where registrations on multiple registers exist for the same type period (does not apply to most configurations).', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'RegisterRank'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The learning model assigned to this practice register', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'LearningModelSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason group assigned to this practice register', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice register to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this register is the default for in-active practice status | UI only enables access where Is-Active-Practice is not checked. The value is used mostly during conversion to avoid gaps in registration history.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsDefaultInactivePractice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this document type applies to - available as help text on document type selection. This field is varbinary to ensure any searches done on this field disregard taged text and only search content text. ', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice register record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice register | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'PracticeRegisterXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice register | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice register record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice register | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice register record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice register record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'CONSTRAINT', N'uk_PracticeRegister_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Practice Register Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'CONSTRAINT', N'uk_PracticeRegister_PracticeRegisterName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Practice Register Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'PracticeRegister', 'CONSTRAINT', N'uk_PracticeRegister_PracticeRegisterLabel'
GO
ALTER TABLE [dbo].[PracticeRegister] SET (LOCK_ESCALATION = TABLE)
GO
