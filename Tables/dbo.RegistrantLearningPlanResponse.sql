SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantLearningPlanResponse] (
		[RegistrantLearningPlanResponseSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantLearningPlanSID]             [int] NOT NULL,
		[FormOwnerSID]                          [int] NOT NULL,
		[FormResponse]                          [xml] NOT NULL,
		[UserDefinedColumns]                    [xml] NULL,
		[RegistrantLearningPlanResponseXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                             [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                             [bit] NOT NULL,
		[CreateUser]                            [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                            [datetimeoffset](7) NOT NULL,
		[UpdateUser]                            [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                            [datetimeoffset](7) NOT NULL,
		[RowGUID]                               [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                              [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantLearningPlanResponse_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantLearningPlanResponse]
		PRIMARY KEY
		CLUSTERED
		([RegistrantLearningPlanResponseSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Learning Plan Response table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'CONSTRAINT', N'pk_RegistrantLearningPlanResponse'
GO
ALTER TABLE [dbo].[RegistrantLearningPlanResponse]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantLearningPlanResponse]
	CHECK
	([dbo].[fRegistrantLearningPlanResponse#Check]([RegistrantLearningPlanResponseSID],[RegistrantLearningPlanSID],[FormOwnerSID],[RegistrantLearningPlanResponseXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantLearningPlanResponse]
CHECK CONSTRAINT [ck_RegistrantLearningPlanResponse]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanResponse]
	ADD
	CONSTRAINT [df_RegistrantLearningPlanResponse_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanResponse]
	ADD
	CONSTRAINT [df_RegistrantLearningPlanResponse_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanResponse]
	ADD
	CONSTRAINT [df_RegistrantLearningPlanResponse_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanResponse]
	ADD
	CONSTRAINT [df_RegistrantLearningPlanResponse_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanResponse]
	ADD
	CONSTRAINT [df_RegistrantLearningPlanResponse_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanResponse]
	ADD
	CONSTRAINT [df_RegistrantLearningPlanResponse_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanResponse]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantLearningPlanResponse_RegistrantLearningPlan_RegistrantLearningPlanSID]
	FOREIGN KEY ([RegistrantLearningPlanSID]) REFERENCES [dbo].[RegistrantLearningPlan] ([RegistrantLearningPlanSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrantLearningPlanResponse]
	CHECK CONSTRAINT [fk_RegistrantLearningPlanResponse_RegistrantLearningPlan_RegistrantLearningPlanSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant learning plan system ID column in the Registrant Learning Plan Response table match a registrant learning plan system ID in the Registrant Learning Plan table. It also ensures that when a record in the Registrant Learning Plan table is deleted, matching child records in the Registrant Learning Plan Response table are deleted as well. Finally, the constraint blocks changes to the value of the registrant learning plan system ID column in the Registrant Learning Plan if matching child records exist in Registrant Learning Plan Response.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'CONSTRAINT', N'fk_RegistrantLearningPlanResponse_RegistrantLearningPlan_RegistrantLearningPlanSID'
GO
ALTER TABLE [dbo].[RegistrantLearningPlanResponse]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantLearningPlanResponse_SF_FormOwner_FormOwnerSID]
	FOREIGN KEY ([FormOwnerSID]) REFERENCES [sf].[FormOwner] ([FormOwnerSID])
ALTER TABLE [dbo].[RegistrantLearningPlanResponse]
	CHECK CONSTRAINT [fk_RegistrantLearningPlanResponse_SF_FormOwner_FormOwnerSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form owner system ID column in the Registrant Learning Plan Response table match a form owner system ID in the Form Owner table. It also ensures that records in the Form Owner table cannot be deleted if matching child records exist in Registrant Learning Plan Response. Finally, the constraint blocks changes to the value of the form owner system ID column in the Form Owner if matching child records exist in Registrant Learning Plan Response.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'CONSTRAINT', N'fk_RegistrantLearningPlanResponse_SF_FormOwner_FormOwnerSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantLearningPlanResponse_FormOwnerSID_RegistrantLearningPlanResponseSID]
	ON [dbo].[RegistrantLearningPlanResponse] ([FormOwnerSID], [RegistrantLearningPlanResponseSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Owner SID foreign key column and avoids row contention on (parent) Form Owner updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'INDEX', N'ix_RegistrantLearningPlanResponse_FormOwnerSID_RegistrantLearningPlanResponseSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantLearningPlanResponse_RegistrantLearningPlanSID_RegistrantLearningPlanResponseSID]
	ON [dbo].[RegistrantLearningPlanResponse] ([RegistrantLearningPlanSID], [RegistrantLearningPlanResponseSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant Learning Plan SID foreign key column and avoids row contention on (parent) Registrant Learning Plan updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'INDEX', N'ix_RegistrantLearningPlanResponse_RegistrantLearningPlanSID_RegistrantLearningPlanResponseSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores this history of registrant learning plan form changes.  When the original form is submitted, a copy of responses is stored into this table.  If the applicant resubmits the form - e.g. to make corrections suggested by the administrator, a copy is stored for each submission.  Simiarly, if the administrator makes corrections of the form a version of the responses is saved each time.  The version that is approved is marked "Is-Approved".  Note that the Form-Response-Draft column in the parent Registrant-App table is used to maintain the currently edited version of form content.  The draft responses may or may not agree with any version of responses stored in this table since drafts can be saved but never submitted. ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant learning plan response assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'RegistrantLearningPlanResponseSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant learning plan assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'RegistrantLearningPlanSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form owner assigned to this registrant learning plan response', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant learning plan response | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'RegistrantLearningPlanResponseXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant learning plan response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant learning plan response record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant learning plan response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant learning plan response record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant learning plan response record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'CONSTRAINT', N'uk_RegistrantLearningPlanResponse_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_RegistrantLearningPlanResponse_FormResponse]
	ON [dbo].[RegistrantLearningPlanResponse] ([FormResponse])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Form Response (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanResponse', 'INDEX', N'xp_RegistrantLearningPlanResponse_FormResponse'
GO
ALTER TABLE [dbo].[RegistrantLearningPlanResponse] SET (LOCK_ESCALATION = TABLE)
GO
