SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantLearningPlanStatus] (
		[RegistrantLearningPlanStatusSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantLearningPlanSID]           [int] NOT NULL,
		[FormStatusSID]                       [int] NOT NULL,
		[UserDefinedColumns]                  [xml] NULL,
		[RegistrantLearningPlanStatusXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                           [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                           [bit] NOT NULL,
		[CreateUser]                          [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                          [datetimeoffset](7) NOT NULL,
		[UpdateUser]                          [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                          [datetimeoffset](7) NOT NULL,
		[RowGUID]                             [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                            [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantLearningPlanStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantLearningPlanStatus]
		PRIMARY KEY
		CLUSTERED
		([RegistrantLearningPlanStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Learning Plan Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'CONSTRAINT', N'pk_RegistrantLearningPlanStatus'
GO
ALTER TABLE [dbo].[RegistrantLearningPlanStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantLearningPlanStatus]
	CHECK
	([dbo].[fRegistrantLearningPlanStatus#Check]([RegistrantLearningPlanStatusSID],[RegistrantLearningPlanSID],[FormStatusSID],[RegistrantLearningPlanStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantLearningPlanStatus]
CHECK CONSTRAINT [ck_RegistrantLearningPlanStatus]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanStatus]
	ADD
	CONSTRAINT [df_RegistrantLearningPlanStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanStatus]
	ADD
	CONSTRAINT [df_RegistrantLearningPlanStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanStatus]
	ADD
	CONSTRAINT [df_RegistrantLearningPlanStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanStatus]
	ADD
	CONSTRAINT [df_RegistrantLearningPlanStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanStatus]
	ADD
	CONSTRAINT [df_RegistrantLearningPlanStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanStatus]
	ADD
	CONSTRAINT [df_RegistrantLearningPlanStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantLearningPlanStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantLearningPlanStatus_RegistrantLearningPlan_RegistrantLearningPlanSID]
	FOREIGN KEY ([RegistrantLearningPlanSID]) REFERENCES [dbo].[RegistrantLearningPlan] ([RegistrantLearningPlanSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrantLearningPlanStatus]
	CHECK CONSTRAINT [fk_RegistrantLearningPlanStatus_RegistrantLearningPlan_RegistrantLearningPlanSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant learning plan system ID column in the Registrant Learning Plan Status table match a registrant learning plan system ID in the Registrant Learning Plan table. It also ensures that when a record in the Registrant Learning Plan table is deleted, matching child records in the Registrant Learning Plan Status table are deleted as well. Finally, the constraint blocks changes to the value of the registrant learning plan system ID column in the Registrant Learning Plan if matching child records exist in Registrant Learning Plan Status.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'CONSTRAINT', N'fk_RegistrantLearningPlanStatus_RegistrantLearningPlan_RegistrantLearningPlanSID'
GO
ALTER TABLE [dbo].[RegistrantLearningPlanStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantLearningPlanStatus_SF_FormStatus_FormStatusSID]
	FOREIGN KEY ([FormStatusSID]) REFERENCES [sf].[FormStatus] ([FormStatusSID])
ALTER TABLE [dbo].[RegistrantLearningPlanStatus]
	CHECK CONSTRAINT [fk_RegistrantLearningPlanStatus_SF_FormStatus_FormStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form status system ID column in the Registrant Learning Plan Status table match a form status system ID in the Form Status table. It also ensures that records in the Form Status table cannot be deleted if matching child records exist in Registrant Learning Plan Status. Finally, the constraint blocks changes to the value of the form status system ID column in the Form Status if matching child records exist in Registrant Learning Plan Status.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'CONSTRAINT', N'fk_RegistrantLearningPlanStatus_SF_FormStatus_FormStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantLearningPlanStatus_FormStatusSID_RegistrantLearningPlanStatusSID]
	ON [dbo].[RegistrantLearningPlanStatus] ([FormStatusSID], [RegistrantLearningPlanStatusSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Status SID foreign key column and avoids row contention on (parent) Form Status updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'INDEX', N'ix_RegistrantLearningPlanStatus_FormStatusSID_RegistrantLearningPlanStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantLearningPlanStatus_RegistrantLearningPlanSID_RegistrantLearningPlanStatusSID]
	ON [dbo].[RegistrantLearningPlanStatus] ([RegistrantLearningPlanSID], [RegistrantLearningPlanStatusSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant Learning Plan SID foreign key column and avoids row contention on (parent) Registrant Learning Plan updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'INDEX', N'ix_RegistrantLearningPlanStatus_RegistrantLearningPlanSID_RegistrantLearningPlanStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant learning plan status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'RegistrantLearningPlanStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant learning plan assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'RegistrantLearningPlanSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant learning plan status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'RegistrantLearningPlanStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant learning plan status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant learning plan status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant learning plan status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant learning plan status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant learning plan status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLearningPlanStatus', 'CONSTRAINT', N'uk_RegistrantLearningPlanStatus_RowGUID'
GO
ALTER TABLE [dbo].[RegistrantLearningPlanStatus] SET (LOCK_ESCALATION = TABLE)
GO
