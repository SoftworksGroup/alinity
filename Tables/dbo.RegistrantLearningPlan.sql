SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantLearningPlan] (
		[RegistrantLearningPlanSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantSID]                 [int] NOT NULL,
		[RegistrationYear]              [smallint] NOT NULL,
		[LearningModelSID]              [int] NOT NULL,
		[FormVersionSID]                [int] NOT NULL,
		[LastValidateTime]              [datetimeoffset](7) NULL,
		[FormResponseDraft]             [xml] NOT NULL,
		[AdminComments]                 [xml] NOT NULL,
		[NextFollowUp]                  [date] NULL,
		[ConfirmationDraft]             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ReasonSID]                     [int] NULL,
		[IsAutoApprovalEnabled]         [bit] NOT NULL,
		[ReviewReasonList]              [xml] NULL,
		[ParentRowGUID]                 [uniqueidentifier] NULL,
		[UserDefinedColumns]            [xml] NULL,
		[RegistrantLearningPlanXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantLearningPlan_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrantLearningPlan_RegistrantSID_RegistrationYear]
		UNIQUE
		NONCLUSTERED
		([RegistrantSID], [RegistrationYear])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantLearningPlan]
		PRIMARY KEY
		CLUSTERED
		([RegistrantLearningPlanSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Learning Plan table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'CONSTRAINT', N'pk_RegistrantLearningPlan'
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantLearningPlan]
	CHECK
	([dbo].[fRegistrantLearningPlan#Check]([RegistrantLearningPlanSID],[RegistrantSID],[RegistrationYear],[LearningModelSID],[FormVersionSID],[LastValidateTime],[NextFollowUp],[ReasonSID],[IsAutoApprovalEnabled],[ParentRowGUID],[RegistrantLearningPlanXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
CHECK CONSTRAINT [ck_RegistrantLearningPlan]
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	ADD
	CONSTRAINT [df_RegistrantLearningPlan_AdminComments]
	DEFAULT (CONVERT([xml],'<Comments />')) FOR [AdminComments]
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	ADD
	CONSTRAINT [df_RegistrantLearningPlan_IsAutoApprovalEnabled]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAutoApprovalEnabled]
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	ADD
	CONSTRAINT [df_RegistrantLearningPlan_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	ADD
	CONSTRAINT [df_RegistrantLearningPlan_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	ADD
	CONSTRAINT [df_RegistrantLearningPlan_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	ADD
	CONSTRAINT [df_RegistrantLearningPlan_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	ADD
	CONSTRAINT [df_RegistrantLearningPlan_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	ADD
	CONSTRAINT [df_RegistrantLearningPlan_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	ADD
	CONSTRAINT [df_RegistrantLearningPlan_FormResponseDraft]
	DEFAULT (CONVERT([xml],N'<FormResponses />')) FOR [FormResponseDraft]
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantLearningPlan_SF_FormVersion_FormVersionSID]
	FOREIGN KEY ([FormVersionSID]) REFERENCES [sf].[FormVersion] ([FormVersionSID])
ALTER TABLE [dbo].[RegistrantLearningPlan]
	CHECK CONSTRAINT [fk_RegistrantLearningPlan_SF_FormVersion_FormVersionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form version system ID column in the Registrant Learning Plan table match a form version system ID in the Form Version table. It also ensures that records in the Form Version table cannot be deleted if matching child records exist in Registrant Learning Plan. Finally, the constraint blocks changes to the value of the form version system ID column in the Form Version if matching child records exist in Registrant Learning Plan.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'CONSTRAINT', N'fk_RegistrantLearningPlan_SF_FormVersion_FormVersionSID'
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantLearningPlan_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [dbo].[RegistrantLearningPlan]
	CHECK CONSTRAINT [fk_RegistrantLearningPlan_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Registrant Learning Plan table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Registrant Learning Plan. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Registrant Learning Plan.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'CONSTRAINT', N'fk_RegistrantLearningPlan_Registrant_RegistrantSID'
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantLearningPlan_Reason_ReasonSID]
	FOREIGN KEY ([ReasonSID]) REFERENCES [dbo].[Reason] ([ReasonSID])
ALTER TABLE [dbo].[RegistrantLearningPlan]
	CHECK CONSTRAINT [fk_RegistrantLearningPlan_Reason_ReasonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reason system ID column in the Registrant Learning Plan table match a reason system ID in the Reason table. It also ensures that records in the Reason table cannot be deleted if matching child records exist in Registrant Learning Plan. Finally, the constraint blocks changes to the value of the reason system ID column in the Reason if matching child records exist in Registrant Learning Plan.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'CONSTRAINT', N'fk_RegistrantLearningPlan_Reason_ReasonSID'
GO
ALTER TABLE [dbo].[RegistrantLearningPlan]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantLearningPlan_LearningModel_LearningModelSID]
	FOREIGN KEY ([LearningModelSID]) REFERENCES [dbo].[LearningModel] ([LearningModelSID])
ALTER TABLE [dbo].[RegistrantLearningPlan]
	CHECK CONSTRAINT [fk_RegistrantLearningPlan_LearningModel_LearningModelSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the learning model system ID column in the Registrant Learning Plan table match a learning model system ID in the Learning Model table. It also ensures that records in the Learning Model table cannot be deleted if matching child records exist in Registrant Learning Plan. Finally, the constraint blocks changes to the value of the learning model system ID column in the Learning Model if matching child records exist in Registrant Learning Plan.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'CONSTRAINT', N'fk_RegistrantLearningPlan_LearningModel_LearningModelSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantLearningPlan_FormVersionSID_RegistrantLearningPlanSID]
	ON [dbo].[RegistrantLearningPlan] ([FormVersionSID], [RegistrantLearningPlanSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Version SID foreign key column and avoids row contention on (parent) Form Version updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'INDEX', N'ix_RegistrantLearningPlan_FormVersionSID_RegistrantLearningPlanSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantLearningPlan_LearningModelSID]
	ON [dbo].[RegistrantLearningPlan] ([LearningModelSID])
	INCLUDE ([RegistrantLearningPlanSID], [RegistrantSID], [RegistrationYear], [FormVersionSID], [ReasonSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Learning Model SID foreign key column and avoids row contention on (parent) Learning Model updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'INDEX', N'ix_RegistrantLearningPlan_LearningModelSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantLearningPlan_ReasonSID_RegistrantLearningPlanSID]
	ON [dbo].[RegistrantLearningPlan] ([ReasonSID], [RegistrantLearningPlanSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reason SID foreign key column and avoids row contention on (parent) Reason updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'INDEX', N'ix_RegistrantLearningPlan_ReasonSID_RegistrantLearningPlanSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantLearningPlan_RegistrantSID_RegistrantLearningPlanSID]
	ON [dbo].[RegistrantLearningPlan] ([RegistrantSID], [RegistrantLearningPlanSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'INDEX', N'ix_RegistrantLearningPlan_RegistrantSID_RegistrantLearningPlanSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantLearningPlan_LegacyKey]
	ON [dbo].[RegistrantLearningPlan] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'INDEX', N'ux_RegistrantLearningPlan_LegacyKey'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantLearningPlan_ParentRowGUID_RegistrationYear]
	ON [dbo].[RegistrantLearningPlan] ([ParentRowGUID], [RegistrationYear])
	WHERE (([ParentRowGUID] IS NOT NULL))
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Parent Row GUID + Registration Year" columns is not duplicated where the condition: "([ParentRowGUID] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'INDEX', N'ux_RegistrantLearningPlan_ParentRowGUID_RegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant learning plan assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'RegistrantLearningPlanSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant this learning plan is defined for', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The learning model assigned to this registrant learning plan', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'LearningModelSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the form content successfully passed validations', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'LastValidateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when the next follow-up is required on the form.  Leave blank if no follow-up required.  When this date is reached the record appears on the Administrators list for "next-to-act".', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'NextFollowUp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to store fragments of HTML rendered prior to approval confirmation (otherwise blank)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'ConfirmationDraft'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this registrant learning plan', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is set by customized rules in the form configuration to enable automatic approval of the form when required conditions have been met.  If all forms should be reviewed by adminsitrators, then the value is left turned off by the form. Note that the condition of making payment (e.g. to pay for the form if charges apply) is automatically taken into account and need not be addressed in the form configuration. It is possible to block automatic approval on any registrant through their profile.  That setting overrides the setting recorded here by rules in the form.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'IsAutoApprovalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Contains a list of reasons why Administrative Review of the form is required - null (blank) if no blocking reasons', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'ReviewReasonList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The unique identifier of the parent form (typically a renewal or reinstatement) the Learning Plan is connected to.  | Null (blank) if this learning plan form is not part of a form-set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'ParentRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant learning plan | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'RegistrantLearningPlanXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant learning plan | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant learning plan record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant learning plan | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant learning plan record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant learning plan record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'CONSTRAINT', N'uk_RegistrantLearningPlan_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Registrant SID + Registration Year" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'CONSTRAINT', N'uk_RegistrantLearningPlan_RegistrantSID_RegistrationYear'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_RegistrantLearningPlan_AdminComments]
	ON [dbo].[RegistrantLearningPlan] ([AdminComments])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Admin Comments (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'INDEX', N'xp_RegistrantLearningPlan_AdminComments'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_RegistrantLearningPlan_FormResponseDraft]
	ON [dbo].[RegistrantLearningPlan] ([FormResponseDraft])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Form Response Draft (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlan', 'INDEX', N'xp_RegistrantLearningPlan_FormResponseDraft'
GO
ALTER TABLE [dbo].[RegistrantLearningPlan] SET (LOCK_ESCALATION = TABLE)
GO
