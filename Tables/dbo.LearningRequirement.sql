SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LearningRequirement] (
		[LearningRequirementSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[PracticeRegisterSID]          [int] NOT NULL,
		[LearningRequirementLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[StartingRegistrationYear]     [smallint] NOT NULL,
		[Minimum]                      [decimal](5, 2) NOT NULL,
		[Maximum]                      [decimal](5, 2) NOT NULL,
		[MaximumCarryOver]             [decimal](5, 2) NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[LearningRequirementXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_LearningRequirement_LearningRequirementLabel]
		UNIQUE
		NONCLUSTERED
		([LearningRequirementLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_LearningRequirement_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_LearningRequirement]
		PRIMARY KEY
		CLUSTERED
		([LearningRequirementSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Learning Requirement table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'CONSTRAINT', N'pk_LearningRequirement'
GO
ALTER TABLE [dbo].[LearningRequirement]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_LearningRequirement]
	CHECK
	([dbo].[fLearningRequirement#Check]([LearningRequirementSID],[PracticeRegisterSID],[LearningRequirementLabel],[StartingRegistrationYear],[Minimum],[Maximum],[MaximumCarryOver],[LearningRequirementXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[LearningRequirement]
CHECK CONSTRAINT [ck_LearningRequirement]
GO
ALTER TABLE [dbo].[LearningRequirement]
	ADD
	CONSTRAINT [df_LearningRequirement_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[LearningRequirement]
	ADD
	CONSTRAINT [df_LearningRequirement_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[LearningRequirement]
	ADD
	CONSTRAINT [df_LearningRequirement_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[LearningRequirement]
	ADD
	CONSTRAINT [df_LearningRequirement_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[LearningRequirement]
	ADD
	CONSTRAINT [df_LearningRequirement_MaximumCarryOver]
	DEFAULT ((999.9)) FOR [MaximumCarryOver]
GO
ALTER TABLE [dbo].[LearningRequirement]
	ADD
	CONSTRAINT [df_LearningRequirement_StartingRegistrationYear]
	DEFAULT ([sf].[fTodayYear]()) FOR [StartingRegistrationYear]
GO
ALTER TABLE [dbo].[LearningRequirement]
	ADD
	CONSTRAINT [df_LearningRequirement_Maximum]
	DEFAULT ((999.9)) FOR [Maximum]
GO
ALTER TABLE [dbo].[LearningRequirement]
	ADD
	CONSTRAINT [df_LearningRequirement_Minimum]
	DEFAULT ((1.0)) FOR [Minimum]
GO
ALTER TABLE [dbo].[LearningRequirement]
	ADD
	CONSTRAINT [df_LearningRequirement_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[LearningRequirement]
	ADD
	CONSTRAINT [df_LearningRequirement_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[LearningRequirement]
	WITH CHECK
	ADD CONSTRAINT [fk_LearningRequirement_PracticeRegister_PracticeRegisterSID]
	FOREIGN KEY ([PracticeRegisterSID]) REFERENCES [dbo].[PracticeRegister] ([PracticeRegisterSID])
ALTER TABLE [dbo].[LearningRequirement]
	CHECK CONSTRAINT [fk_LearningRequirement_PracticeRegister_PracticeRegisterSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the practice register system ID column in the Learning Requirement table match a practice register system ID in the Practice Register table. It also ensures that records in the Practice Register table cannot be deleted if matching child records exist in Learning Requirement. Finally, the constraint blocks changes to the value of the practice register system ID column in the Practice Register if matching child records exist in Learning Requirement.', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'CONSTRAINT', N'fk_LearningRequirement_PracticeRegister_PracticeRegisterSID'
GO
CREATE NONCLUSTERED INDEX [ix_LearningRequirement_PracticeRegisterSID_LearningRequirementSID]
	ON [dbo].[LearningRequirement] ([PracticeRegisterSID], [LearningRequirementSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Practice Register SID foreign key column and avoids row contention on (parent) Practice Register updates', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'INDEX', N'ix_LearningRequirement_PracticeRegisterSID_LearningRequirementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Learning requirements for a type of registration are established through entries in this table.  The table supports configuration of either a CEU (Continuing Education Unit) model – where a total number of units of education activity must be carried out each period – e.g. 20 hours – or an Activity based model where a certain number of activities must be completed. The type of learning model applied is established on the practice register. Each requirement must be assigned a starting registration year from which the policy is to apply going forward. A maximum number of units in a period may also be specified.  In order to support configurations where a number of CEU’s or activities is required for a specific competence type or group of competence types, then Learning-Requirement-Competence-Table must be filled out.  If no records exist in this table for the requirement the system assumes the requirement can be met using all of the active Competence Type’s available (e.g. “5 activities required per year” – and any of the eligible activities can be used).  A more fine grained requirement would specific a competence type . For example, a minimum of 5 hours of activity related to Competence Type – “Professional Standards – Patient Privacy”, and another 3 hours required in some other category – or all other categories.  To allow any category for the requirement do not include Learning-Requirement-Competence-Type records.  The term is rolling so the system evaluates – at each renewal point – whether the registrant has met the requirement for the cycle length ending with the current year.  The number of units can be pro-rated for individuals who are not licensed for the full cycle.  For example, if the requirement is 30 hours per 3 years and the individual has only been licensed (or active) for 18 months of that cycle then their requirement is 15 hours. If there are multiple requirements applying each is prorated.  For Activity based models, the units are simply counts of items.  You can restrict which type of items the requirement applies to by specifying one or more competence types – e.g. a minimum of 1 and maximum of 3 from the “Internet Research” competence type.  ', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the learning requirement assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'LearningRequirementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice register assigned to this learning requirement', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'PracticeRegisterSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the learning requirement to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'LearningRequirementLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum number of units that can be applied to the next cycle when the minimum units are exceeded - enter 9999 for unlimited, default is 0 (no carry over)', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'MaximumCarryOver'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the learning requirement | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'LearningRequirementXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the learning requirement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this learning requirement record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the learning requirement | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the learning requirement record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the learning requirement record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Learning Requirement Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'CONSTRAINT', N'uk_LearningRequirement_LearningRequirementLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirement', 'CONSTRAINT', N'uk_LearningRequirement_RowGUID'
GO
ALTER TABLE [dbo].[LearningRequirement] SET (LOCK_ESCALATION = TABLE)
GO
