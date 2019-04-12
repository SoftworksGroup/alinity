SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LearningRequirementCompetenceType] (
		[LearningRequirementCompetenceTypeSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[LearningRequirementSID]                   [int] NOT NULL,
		[CompetenceTypeSID]                        [int] NOT NULL,
		[UserDefinedColumns]                       [xml] NULL,
		[LearningRequirementCompetenceTypeXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                                [bit] NOT NULL,
		[CreateUser]                               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                               [datetimeoffset](7) NOT NULL,
		[UpdateUser]                               [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                               [datetimeoffset](7) NOT NULL,
		[RowGUID]                                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                                 [timestamp] NOT NULL,
		CONSTRAINT [uk_LearningRequirementCompetenceType_LearningRequirementSID_CompetenceTypeSID]
		UNIQUE
		NONCLUSTERED
		([LearningRequirementSID], [CompetenceTypeSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_LearningRequirementCompetenceType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_LearningRequirementCompetenceType]
		PRIMARY KEY
		CLUSTERED
		([LearningRequirementCompetenceTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Learning Requirement Competence Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'CONSTRAINT', N'pk_LearningRequirementCompetenceType'
GO
ALTER TABLE [dbo].[LearningRequirementCompetenceType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_LearningRequirementCompetenceType]
	CHECK
	([dbo].[fLearningRequirementCompetenceType#Check]([LearningRequirementCompetenceTypeSID],[LearningRequirementSID],[CompetenceTypeSID],[LearningRequirementCompetenceTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[LearningRequirementCompetenceType]
CHECK CONSTRAINT [ck_LearningRequirementCompetenceType]
GO
ALTER TABLE [dbo].[LearningRequirementCompetenceType]
	ADD
	CONSTRAINT [df_LearningRequirementCompetenceType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[LearningRequirementCompetenceType]
	ADD
	CONSTRAINT [df_LearningRequirementCompetenceType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[LearningRequirementCompetenceType]
	ADD
	CONSTRAINT [df_LearningRequirementCompetenceType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[LearningRequirementCompetenceType]
	ADD
	CONSTRAINT [df_LearningRequirementCompetenceType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[LearningRequirementCompetenceType]
	ADD
	CONSTRAINT [df_LearningRequirementCompetenceType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[LearningRequirementCompetenceType]
	ADD
	CONSTRAINT [df_LearningRequirementCompetenceType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[LearningRequirementCompetenceType]
	WITH CHECK
	ADD CONSTRAINT [fk_LearningRequirementCompetenceType_CompetenceType_CompetenceTypeSID]
	FOREIGN KEY ([CompetenceTypeSID]) REFERENCES [dbo].[CompetenceType] ([CompetenceTypeSID])
ALTER TABLE [dbo].[LearningRequirementCompetenceType]
	CHECK CONSTRAINT [fk_LearningRequirementCompetenceType_CompetenceType_CompetenceTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the competence type system ID column in the Learning Requirement Competence Type table match a competence type system ID in the Competence Type table. It also ensures that records in the Competence Type table cannot be deleted if matching child records exist in Learning Requirement Competence Type. Finally, the constraint blocks changes to the value of the competence type system ID column in the Competence Type if matching child records exist in Learning Requirement Competence Type.', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'CONSTRAINT', N'fk_LearningRequirementCompetenceType_CompetenceType_CompetenceTypeSID'
GO
ALTER TABLE [dbo].[LearningRequirementCompetenceType]
	WITH CHECK
	ADD CONSTRAINT [fk_LearningRequirementCompetenceType_LearningRequirement_LearningRequirementSID]
	FOREIGN KEY ([LearningRequirementSID]) REFERENCES [dbo].[LearningRequirement] ([LearningRequirementSID])
ALTER TABLE [dbo].[LearningRequirementCompetenceType]
	CHECK CONSTRAINT [fk_LearningRequirementCompetenceType_LearningRequirement_LearningRequirementSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the learning requirement system ID column in the Learning Requirement Competence Type table match a learning requirement system ID in the Learning Requirement table. It also ensures that records in the Learning Requirement table cannot be deleted if matching child records exist in Learning Requirement Competence Type. Finally, the constraint blocks changes to the value of the learning requirement system ID column in the Learning Requirement if matching child records exist in Learning Requirement Competence Type.', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'CONSTRAINT', N'fk_LearningRequirementCompetenceType_LearningRequirement_LearningRequirementSID'
GO
CREATE NONCLUSTERED INDEX [ix_LearningRequirementCompetenceType_CompetenceTypeSID_LearningRequirementCompetenceTypeSID]
	ON [dbo].[LearningRequirementCompetenceType] ([CompetenceTypeSID], [LearningRequirementCompetenceTypeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Competence Type SID foreign key column and avoids row contention on (parent) Competence Type updates', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'INDEX', N'ix_LearningRequirementCompetenceType_CompetenceTypeSID_LearningRequirementCompetenceTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the learning requirement competence type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'LearningRequirementCompetenceTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the learning requirement assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'LearningRequirementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the competence type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'CompetenceTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the learning requirement competence type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'LearningRequirementCompetenceTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the learning requirement competence type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this learning requirement competence type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the learning requirement competence type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the learning requirement competence type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the learning requirement competence type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Learning Requirement SID + Competence Type SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'CONSTRAINT', N'uk_LearningRequirementCompetenceType_LearningRequirementSID_CompetenceTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'LearningRequirementCompetenceType', 'CONSTRAINT', N'uk_LearningRequirementCompetenceType_RowGUID'
GO
ALTER TABLE [dbo].[LearningRequirementCompetenceType] SET (LOCK_ESCALATION = TABLE)
GO
