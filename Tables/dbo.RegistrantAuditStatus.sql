SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantAuditStatus] (
		[RegistrantAuditStatusSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantAuditSID]           [int] NOT NULL,
		[FormStatusSID]                [int] NOT NULL,
		[UserDefinedColumns]           [xml] NULL,
		[RegistrantAuditStatusXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                    [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                    [bit] NOT NULL,
		[CreateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                   [datetimeoffset](7) NOT NULL,
		[UpdateUser]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                   [datetimeoffset](7) NOT NULL,
		[RowGUID]                      [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                     [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantAuditStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantAuditStatus]
		PRIMARY KEY
		CLUSTERED
		([RegistrantAuditStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Audit Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'CONSTRAINT', N'pk_RegistrantAuditStatus'
GO
ALTER TABLE [dbo].[RegistrantAuditStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantAuditStatus]
	CHECK
	([dbo].[fRegistrantAuditStatus#Check]([RegistrantAuditStatusSID],[RegistrantAuditSID],[FormStatusSID],[RegistrantAuditStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantAuditStatus]
CHECK CONSTRAINT [ck_RegistrantAuditStatus]
GO
ALTER TABLE [dbo].[RegistrantAuditStatus]
	ADD
	CONSTRAINT [df_RegistrantAuditStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantAuditStatus]
	ADD
	CONSTRAINT [df_RegistrantAuditStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantAuditStatus]
	ADD
	CONSTRAINT [df_RegistrantAuditStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantAuditStatus]
	ADD
	CONSTRAINT [df_RegistrantAuditStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantAuditStatus]
	ADD
	CONSTRAINT [df_RegistrantAuditStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantAuditStatus]
	ADD
	CONSTRAINT [df_RegistrantAuditStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantAuditStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAuditStatus_RegistrantAudit_RegistrantAuditSID]
	FOREIGN KEY ([RegistrantAuditSID]) REFERENCES [dbo].[RegistrantAudit] ([RegistrantAuditSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrantAuditStatus]
	CHECK CONSTRAINT [fk_RegistrantAuditStatus_RegistrantAudit_RegistrantAuditSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant audit system ID column in the Registrant Audit Status table match a registrant audit system ID in the Registrant Audit table. It also ensures that when a record in the Registrant Audit table is deleted, matching child records in the Registrant Audit Status table are deleted as well. Finally, the constraint blocks changes to the value of the registrant audit system ID column in the Registrant Audit if matching child records exist in Registrant Audit Status.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'CONSTRAINT', N'fk_RegistrantAuditStatus_RegistrantAudit_RegistrantAuditSID'
GO
ALTER TABLE [dbo].[RegistrantAuditStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantAuditStatus_SF_FormStatus_FormStatusSID]
	FOREIGN KEY ([FormStatusSID]) REFERENCES [sf].[FormStatus] ([FormStatusSID])
ALTER TABLE [dbo].[RegistrantAuditStatus]
	CHECK CONSTRAINT [fk_RegistrantAuditStatus_SF_FormStatus_FormStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form status system ID column in the Registrant Audit Status table match a form status system ID in the Form Status table. It also ensures that records in the Form Status table cannot be deleted if matching child records exist in Registrant Audit Status. Finally, the constraint blocks changes to the value of the form status system ID column in the Form Status if matching child records exist in Registrant Audit Status.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'CONSTRAINT', N'fk_RegistrantAuditStatus_SF_FormStatus_FormStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAuditStatus_FormStatusSID_RegistrantAuditStatusSID]
	ON [dbo].[RegistrantAuditStatus] ([FormStatusSID], [RegistrantAuditStatusSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Status SID foreign key column and avoids row contention on (parent) Form Status updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'INDEX', N'ix_RegistrantAuditStatus_FormStatusSID_RegistrantAuditStatusSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantAuditStatus_LegacyKey]
	ON [dbo].[RegistrantAuditStatus] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'INDEX', N'ux_RegistrantAuditStatus_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantAuditStatus_RegistrantAuditSID_RegistrantAuditStatusSID]
	ON [dbo].[RegistrantAuditStatus] ([RegistrantAuditSID], [RegistrantAuditStatusSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant Audit SID foreign key column and avoids row contention on (parent) Registrant Audit updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'INDEX', N'ix_RegistrantAuditStatus_RegistrantAuditSID_RegistrantAuditStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant audit status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'RegistrantAuditStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the competence audit assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'RegistrantAuditSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant audit status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'RegistrantAuditStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant audit status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant audit status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant audit status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant audit status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant audit status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantAuditStatus', 'CONSTRAINT', N'uk_RegistrantAuditStatus_RowGUID'
GO
ALTER TABLE [dbo].[RegistrantAuditStatus] SET (LOCK_ESCALATION = TABLE)
GO
