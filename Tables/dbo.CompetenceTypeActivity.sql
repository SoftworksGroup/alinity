SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CompetenceTypeActivity] (
		[CompetenceTypeActivitySID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[CompetenceTypeSID]             [int] NOT NULL,
		[CompetenceActivitySID]         [int] NOT NULL,
		[EffectiveTime]                 [datetime] NOT NULL,
		[ExpiryTime]                    [datetime] NULL,
		[UserDefinedColumns]            [xml] NULL,
		[CompetenceTypeActivityXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_CompetenceTypeActivity_CompetenceTypeSID_CompetenceActivitySID_EffectiveTime]
		UNIQUE
		NONCLUSTERED
		([CompetenceTypeSID], [CompetenceActivitySID], [EffectiveTime])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_CompetenceTypeActivity_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_CompetenceTypeActivity]
		PRIMARY KEY
		CLUSTERED
		([CompetenceTypeActivitySID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Competence Type Activity table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'CONSTRAINT', N'pk_CompetenceTypeActivity'
GO
ALTER TABLE [dbo].[CompetenceTypeActivity]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_CompetenceTypeActivity]
	CHECK
	([dbo].[fCompetenceTypeActivity#Check]([CompetenceTypeActivitySID],[CompetenceTypeSID],[CompetenceActivitySID],[EffectiveTime],[ExpiryTime],[CompetenceTypeActivityXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[CompetenceTypeActivity]
CHECK CONSTRAINT [ck_CompetenceTypeActivity]
GO
ALTER TABLE [dbo].[CompetenceTypeActivity]
	ADD
	CONSTRAINT [df_CompetenceTypeActivity_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[CompetenceTypeActivity]
	ADD
	CONSTRAINT [df_CompetenceTypeActivity_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[CompetenceTypeActivity]
	ADD
	CONSTRAINT [df_CompetenceTypeActivity_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[CompetenceTypeActivity]
	ADD
	CONSTRAINT [df_CompetenceTypeActivity_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[CompetenceTypeActivity]
	ADD
	CONSTRAINT [df_CompetenceTypeActivity_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[CompetenceTypeActivity]
	ADD
	CONSTRAINT [df_CompetenceTypeActivity_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[CompetenceTypeActivity]
	WITH CHECK
	ADD CONSTRAINT [fk_CompetenceTypeActivity_CompetenceActivity_CompetenceActivitySID]
	FOREIGN KEY ([CompetenceActivitySID]) REFERENCES [dbo].[CompetenceActivity] ([CompetenceActivitySID])
ALTER TABLE [dbo].[CompetenceTypeActivity]
	CHECK CONSTRAINT [fk_CompetenceTypeActivity_CompetenceActivity_CompetenceActivitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the competence activity system ID column in the Competence Type Activity table match a competence activity system ID in the Competence Activity table. It also ensures that records in the Competence Activity table cannot be deleted if matching child records exist in Competence Type Activity. Finally, the constraint blocks changes to the value of the competence activity system ID column in the Competence Activity if matching child records exist in Competence Type Activity.', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'CONSTRAINT', N'fk_CompetenceTypeActivity_CompetenceActivity_CompetenceActivitySID'
GO
ALTER TABLE [dbo].[CompetenceTypeActivity]
	WITH CHECK
	ADD CONSTRAINT [fk_CompetenceTypeActivity_CompetenceType_CompetenceTypeSID]
	FOREIGN KEY ([CompetenceTypeSID]) REFERENCES [dbo].[CompetenceType] ([CompetenceTypeSID])
ALTER TABLE [dbo].[CompetenceTypeActivity]
	CHECK CONSTRAINT [fk_CompetenceTypeActivity_CompetenceType_CompetenceTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the competence type system ID column in the Competence Type Activity table match a competence type system ID in the Competence Type table. It also ensures that records in the Competence Type table cannot be deleted if matching child records exist in Competence Type Activity. Finally, the constraint blocks changes to the value of the competence type system ID column in the Competence Type if matching child records exist in Competence Type Activity.', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'CONSTRAINT', N'fk_CompetenceTypeActivity_CompetenceType_CompetenceTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_CompetenceTypeActivity_CompetenceActivitySID_CompetenceTypeActivitySID]
	ON [dbo].[CompetenceTypeActivity] ([CompetenceActivitySID], [CompetenceTypeActivitySID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Competence Activity SID foreign key column and avoids row contention on (parent) Competence Activity updates', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'INDEX', N'ix_CompetenceTypeActivity_CompetenceActivitySID_CompetenceTypeActivitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the list of activities allowed by the organization for entry in learning plans and reporting of competence for each competence type.  Competence Types are sometimes called “Standards of Practice” or “Competency Bands”.  Activities allowed for each competence type may be shared  across types, or they may be unique to a single competency type.  To stop an out-of-date activity from being available for use on a particular competence type fill in the expiry-time for the date you no longer want it to appear.  Note that when an assigned activity is expired, it prevents it from being selectable by a registrant on their learning plan going forward but does not mean that activity cannot be reassigned later.  To prevent an activity from being available for any new assignments mark it inactive in the Competence-Activity record.', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the competence type activity assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'CompetenceTypeActivitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the competence type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'CompetenceTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The competence activity assigned to this competence type activity', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'CompetenceActivitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this restriction/condition was put into effect or most recently changed | Check Change Audit column for history', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last day this Competence can be selected for learning plans and renewal reporting (only applies when Competence Type is "Active")', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the competence type activity | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'CompetenceTypeActivityXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the competence type activity | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this competence type activity record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the competence type activity | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the competence type activity record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the competence type activity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Competence Type SID + Competence Activity SID + Effective Time" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'CONSTRAINT', N'uk_CompetenceTypeActivity_CompetenceTypeSID_CompetenceActivitySID_EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CompetenceTypeActivity', 'CONSTRAINT', N'uk_CompetenceTypeActivity_RowGUID'
GO
ALTER TABLE [dbo].[CompetenceTypeActivity] SET (LOCK_ESCALATION = TABLE)
GO
