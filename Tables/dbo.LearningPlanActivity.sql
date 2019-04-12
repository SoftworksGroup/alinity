SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LearningPlanActivity] (
		[LearningPlanActivitySID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantLearningPlanSID]        [int] NOT NULL,
		[CompetenceTypeActivitySID]        [int] NOT NULL,
		[UnitValue]                        [decimal](5, 2) NOT NULL,
		[CarryOverUnitValue]               [decimal](5, 2) NOT NULL,
		[ActivityDate]                     [date] NULL,
		[LearningClaimTypeSID]             [int] NOT NULL,
		[LearningPlanActivityCategory]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ActivityDescription]              [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PlannedCompletion]                [date] NULL,
		[OrgSID]                           [int] NULL,
		[IsSubjectToReview]                [bit] NOT NULL,
		[IsArchived]                       [bit] NOT NULL,
		[UserDefinedColumns]               [xml] NULL,
		[LearningPlanActivityXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                        [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                        [bit] NOT NULL,
		[CreateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                       [datetimeoffset](7) NOT NULL,
		[UpdateUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                       [datetimeoffset](7) NOT NULL,
		[RowGUID]                          [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                         [timestamp] NOT NULL,
		CONSTRAINT [uk_LearningPlanActivity_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_LearningPlanActivity]
		PRIMARY KEY
		CLUSTERED
		([LearningPlanActivitySID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Learning Plan Activity table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'CONSTRAINT', N'pk_LearningPlanActivity'
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_LearningPlanActivity]
	CHECK
	([dbo].[fLearningPlanActivity#Check]([LearningPlanActivitySID],[RegistrantLearningPlanSID],[CompetenceTypeActivitySID],[UnitValue],[CarryOverUnitValue],[ActivityDate],[LearningClaimTypeSID],[LearningPlanActivityCategory],[PlannedCompletion],[OrgSID],[IsSubjectToReview],[IsArchived],[LearningPlanActivityXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[LearningPlanActivity]
CHECK CONSTRAINT [ck_LearningPlanActivity]
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	ADD
	CONSTRAINT [df_LearningPlanActivity_UnitValue]
	DEFAULT ((1.0)) FOR [UnitValue]
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	ADD
	CONSTRAINT [df_LearningPlanActivity_CarryOverUnitValue]
	DEFAULT ((0.0)) FOR [CarryOverUnitValue]
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	ADD
	CONSTRAINT [df_LearningPlanActivity_IsSubjectToReview]
	DEFAULT (CONVERT([bit],(0))) FOR [IsSubjectToReview]
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	ADD
	CONSTRAINT [df_LearningPlanActivity_IsArchived]
	DEFAULT (CONVERT([bit],(0))) FOR [IsArchived]
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	ADD
	CONSTRAINT [df_LearningPlanActivity_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	ADD
	CONSTRAINT [df_LearningPlanActivity_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	ADD
	CONSTRAINT [df_LearningPlanActivity_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	ADD
	CONSTRAINT [df_LearningPlanActivity_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	ADD
	CONSTRAINT [df_LearningPlanActivity_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	ADD
	CONSTRAINT [df_LearningPlanActivity_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	WITH CHECK
	ADD CONSTRAINT [fk_LearningPlanActivity_LearningClaimType_LearningClaimTypeSID]
	FOREIGN KEY ([LearningClaimTypeSID]) REFERENCES [dbo].[LearningClaimType] ([LearningClaimTypeSID])
ALTER TABLE [dbo].[LearningPlanActivity]
	CHECK CONSTRAINT [fk_LearningPlanActivity_LearningClaimType_LearningClaimTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the learning claim type system ID column in the Learning Plan Activity table match a learning claim type system ID in the Learning Claim Type table. It also ensures that records in the Learning Claim Type table cannot be deleted if matching child records exist in Learning Plan Activity. Finally, the constraint blocks changes to the value of the learning claim type system ID column in the Learning Claim Type if matching child records exist in Learning Plan Activity.', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'CONSTRAINT', N'fk_LearningPlanActivity_LearningClaimType_LearningClaimTypeSID'
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	WITH CHECK
	ADD CONSTRAINT [fk_LearningPlanActivity_CompetenceTypeActivity_CompetenceTypeActivitySID]
	FOREIGN KEY ([CompetenceTypeActivitySID]) REFERENCES [dbo].[CompetenceTypeActivity] ([CompetenceTypeActivitySID])
ALTER TABLE [dbo].[LearningPlanActivity]
	CHECK CONSTRAINT [fk_LearningPlanActivity_CompetenceTypeActivity_CompetenceTypeActivitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the competence type activity system ID column in the Learning Plan Activity table match a competence type activity system ID in the Competence Type Activity table. It also ensures that records in the Competence Type Activity table cannot be deleted if matching child records exist in Learning Plan Activity. Finally, the constraint blocks changes to the value of the competence type activity system ID column in the Competence Type Activity if matching child records exist in Learning Plan Activity.', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'CONSTRAINT', N'fk_LearningPlanActivity_CompetenceTypeActivity_CompetenceTypeActivitySID'
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	WITH CHECK
	ADD CONSTRAINT [fk_LearningPlanActivity_RegistrantLearningPlan_RegistrantLearningPlanSID]
	FOREIGN KEY ([RegistrantLearningPlanSID]) REFERENCES [dbo].[RegistrantLearningPlan] ([RegistrantLearningPlanSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[LearningPlanActivity]
	CHECK CONSTRAINT [fk_LearningPlanActivity_RegistrantLearningPlan_RegistrantLearningPlanSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant learning plan system ID column in the Learning Plan Activity table match a registrant learning plan system ID in the Registrant Learning Plan table. It also ensures that when a record in the Registrant Learning Plan table is deleted, matching child records in the Learning Plan Activity table are deleted as well. Finally, the constraint blocks changes to the value of the registrant learning plan system ID column in the Registrant Learning Plan if matching child records exist in Learning Plan Activity.', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'CONSTRAINT', N'fk_LearningPlanActivity_RegistrantLearningPlan_RegistrantLearningPlanSID'
GO
ALTER TABLE [dbo].[LearningPlanActivity]
	WITH CHECK
	ADD CONSTRAINT [fk_LearningPlanActivity_Org_OrgSID]
	FOREIGN KEY ([OrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [dbo].[LearningPlanActivity]
	CHECK CONSTRAINT [fk_LearningPlanActivity_Org_OrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the org system ID column in the Learning Plan Activity table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Learning Plan Activity. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Learning Plan Activity.', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'CONSTRAINT', N'fk_LearningPlanActivity_Org_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_LearningPlanActivity_CompetenceTypeActivitySID]
	ON [dbo].[LearningPlanActivity] ([CompetenceTypeActivitySID])
	INCLUDE ([LearningPlanActivitySID], [RegistrantLearningPlanSID], [UnitValue], [LearningClaimTypeSID], [RowGUID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Competence Type Activity SID foreign key column and avoids row contention on (parent) Competence Type Activity updates', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'INDEX', N'ix_LearningPlanActivity_CompetenceTypeActivitySID'
GO
CREATE NONCLUSTERED INDEX [ix_LearningPlanActivity_LearningClaimTypeSID_LearningPlanActivitySID]
	ON [dbo].[LearningPlanActivity] ([LearningClaimTypeSID], [LearningPlanActivitySID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Learning Claim Type SID foreign key column and avoids row contention on (parent) Learning Claim Type updates', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'INDEX', N'ix_LearningPlanActivity_LearningClaimTypeSID_LearningPlanActivitySID'
GO
CREATE NONCLUSTERED INDEX [ix_LearningPlanActivity_OrgSID_LearningPlanActivitySID]
	ON [dbo].[LearningPlanActivity] ([OrgSID], [LearningPlanActivitySID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'INDEX', N'ix_LearningPlanActivity_OrgSID_LearningPlanActivitySID'
GO
CREATE NONCLUSTERED INDEX [ix_LearningPlanActivity_RegistrantLearningPlanSID_LearningPlanActivitySID]
	ON [dbo].[LearningPlanActivity] ([RegistrantLearningPlanSID], [LearningPlanActivitySID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant Learning Plan SID foreign key column and avoids row contention on (parent) Registrant Learning Plan updates', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'INDEX', N'ix_LearningPlanActivity_RegistrantLearningPlanSID_LearningPlanActivitySID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_LearningPlanActivity_LegacyKey]
	ON [dbo].[LearningPlanActivity] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'INDEX', N'ux_LearningPlanActivity_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the learning activities planned and/or completed by the member.  These are the details of learning for the Learning Plan/Portfolio for a given registration year. The details must meet the criteria established for total units of education or count of objectives defined in the configuration.  Evaluation for compliance of units/objectives-count is carried out at renewal and not during the year.  The same records are edited during the year as part of the Learning Plan/Portfolio maintenance and during Renewal.  The Learning Plan is typically established as a sub-form in the Renewal form set where different business rules may apply.', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the learning plan activity assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'LearningPlanActivitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant learning plan assigned to this learning plan activity', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'RegistrantLearningPlanSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The competence type activity assigned to this learning plan activity', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'CompetenceTypeActivitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of units from the total for the actitivity to be carried forward to the next learning cycle | The total carried forward may be subject to limits set at the Competence Type and/or Learning Model levels.', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'CarryOverUnitValue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the activity/document was completed/provided | This date must be in the claimed registration year  ', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'ActivityDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of learning plan activity', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'LearningClaimTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category to organize learning activities within the learning plan/report.', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'LearningPlanActivityCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the learning activity that took place.', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'ActivityDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the registrant plans to complete the activity', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'PlannedCompletion'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this learning plan activity', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this learning activity is targeted for achieving compliance with the continuing education policy and may therefore be is subject to review/audit', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'IsSubjectToReview'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked this activity is placed into a separate section of un-reported activities (helps separate current activities from historical ones)', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'IsArchived'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the learning plan activity | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'LearningPlanActivityXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the learning plan activity | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this learning plan activity record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the learning plan activity | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the learning plan activity record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the learning plan activity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'LearningPlanActivity', 'CONSTRAINT', N'uk_LearningPlanActivity_RowGUID'
GO
ALTER TABLE [dbo].[LearningPlanActivity] SET (LOCK_ESCALATION = TABLE)
GO
