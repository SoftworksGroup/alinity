SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrationChangeStatus] (
		[RegistrationChangeStatusSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrationChangeSID]           [int] NOT NULL,
		[FormStatusSID]                   [int] NOT NULL,
		[UserDefinedColumns]              [xml] NULL,
		[RegistrationChangeStatusXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                       [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                       [bit] NOT NULL,
		[CreateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                      [datetimeoffset](7) NOT NULL,
		[UpdateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                      [datetimeoffset](7) NOT NULL,
		[RowGUID]                         [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                        [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrationChangeStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrationChangeStatus]
		PRIMARY KEY
		CLUSTERED
		([RegistrationChangeStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registration Change Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'CONSTRAINT', N'pk_RegistrationChangeStatus'
GO
ALTER TABLE [dbo].[RegistrationChangeStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrationChangeStatus]
	CHECK
	([dbo].[fRegistrationChangeStatus#Check]([RegistrationChangeStatusSID],[RegistrationChangeSID],[FormStatusSID],[RegistrationChangeStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrationChangeStatus]
CHECK CONSTRAINT [ck_RegistrationChangeStatus]
GO
ALTER TABLE [dbo].[RegistrationChangeStatus]
	ADD
	CONSTRAINT [df_RegistrationChangeStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrationChangeStatus]
	ADD
	CONSTRAINT [df_RegistrationChangeStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrationChangeStatus]
	ADD
	CONSTRAINT [df_RegistrationChangeStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrationChangeStatus]
	ADD
	CONSTRAINT [df_RegistrationChangeStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrationChangeStatus]
	ADD
	CONSTRAINT [df_RegistrationChangeStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrationChangeStatus]
	ADD
	CONSTRAINT [df_RegistrationChangeStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrationChangeStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationChangeStatus_SF_FormStatus_FormStatusSID]
	FOREIGN KEY ([FormStatusSID]) REFERENCES [sf].[FormStatus] ([FormStatusSID])
ALTER TABLE [dbo].[RegistrationChangeStatus]
	CHECK CONSTRAINT [fk_RegistrationChangeStatus_SF_FormStatus_FormStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form status system ID column in the Registration Change Status table match a form status system ID in the Form Status table. It also ensures that records in the Form Status table cannot be deleted if matching child records exist in Registration Change Status. Finally, the constraint blocks changes to the value of the form status system ID column in the Form Status if matching child records exist in Registration Change Status.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'CONSTRAINT', N'fk_RegistrationChangeStatus_SF_FormStatus_FormStatusSID'
GO
ALTER TABLE [dbo].[RegistrationChangeStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationChangeStatus_RegistrationChange_RegistrationChangeSID]
	FOREIGN KEY ([RegistrationChangeSID]) REFERENCES [dbo].[RegistrationChange] ([RegistrationChangeSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrationChangeStatus]
	CHECK CONSTRAINT [fk_RegistrationChangeStatus_RegistrationChange_RegistrationChangeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registration change system ID column in the Registration Change Status table match a registration change system ID in the Registration Change table. It also ensures that when a record in the Registration Change table is deleted, matching child records in the Registration Change Status table are deleted as well. Finally, the constraint blocks changes to the value of the registration change system ID column in the Registration Change if matching child records exist in Registration Change Status.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'CONSTRAINT', N'fk_RegistrationChangeStatus_RegistrationChange_RegistrationChangeSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationChangeStatus_FormStatusSID_RegistrationChangeStatusSID]
	ON [dbo].[RegistrationChangeStatus] ([FormStatusSID], [RegistrationChangeStatusSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Status SID foreign key column and avoids row contention on (parent) Form Status updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'INDEX', N'ix_RegistrationChangeStatus_FormStatusSID_RegistrationChangeStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationChangeStatus_RegistrationChangeSID_RegistrationChangeStatusSID]
	ON [dbo].[RegistrationChangeStatus] ([RegistrationChangeSID], [RegistrationChangeStatusSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registration Change SID foreign key column and avoids row contention on (parent) Registration Change updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'INDEX', N'ix_RegistrationChangeStatus_RegistrationChangeSID_RegistrationChangeStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration change status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'RegistrationChangeStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration change assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'RegistrationChangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registration change status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'RegistrationChangeStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registration change status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registration change status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registration change status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registration change status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration change status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationChangeStatus', 'CONSTRAINT', N'uk_RegistrationChangeStatus_RowGUID'
GO
ALTER TABLE [dbo].[RegistrationChangeStatus] SET (LOCK_ESCALATION = TABLE)
GO
