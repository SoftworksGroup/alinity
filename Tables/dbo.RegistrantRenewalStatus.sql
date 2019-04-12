SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantRenewalStatus] (
		[RegistrantRenewalStatusSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantRenewalSID]           [int] NOT NULL,
		[FormStatusSID]                  [int] NOT NULL,
		[UserDefinedColumns]             [xml] NULL,
		[RegistrantRenewalStatusXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                      [bit] NOT NULL,
		[CreateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                     [datetimeoffset](7) NOT NULL,
		[UpdateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                     [datetimeoffset](7) NOT NULL,
		[RowGUID]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                       [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantRenewalStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantRenewalStatus]
		PRIMARY KEY
		CLUSTERED
		([RegistrantRenewalStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Renewal Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'CONSTRAINT', N'pk_RegistrantRenewalStatus'
GO
ALTER TABLE [dbo].[RegistrantRenewalStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantRenewalStatus]
	CHECK
	([dbo].[fRegistrantRenewalStatus#Check]([RegistrantRenewalStatusSID],[RegistrantRenewalSID],[FormStatusSID],[RegistrantRenewalStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantRenewalStatus]
CHECK CONSTRAINT [ck_RegistrantRenewalStatus]
GO
ALTER TABLE [dbo].[RegistrantRenewalStatus]
	ADD
	CONSTRAINT [df_RegistrantRenewalStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantRenewalStatus]
	ADD
	CONSTRAINT [df_RegistrantRenewalStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantRenewalStatus]
	ADD
	CONSTRAINT [df_RegistrantRenewalStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantRenewalStatus]
	ADD
	CONSTRAINT [df_RegistrantRenewalStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantRenewalStatus]
	ADD
	CONSTRAINT [df_RegistrantRenewalStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantRenewalStatus]
	ADD
	CONSTRAINT [df_RegistrantRenewalStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantRenewalStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantRenewalStatus_RegistrantRenewal_RegistrantRenewalSID]
	FOREIGN KEY ([RegistrantRenewalSID]) REFERENCES [dbo].[RegistrantRenewal] ([RegistrantRenewalSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrantRenewalStatus]
	CHECK CONSTRAINT [fk_RegistrantRenewalStatus_RegistrantRenewal_RegistrantRenewalSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant renewal system ID column in the Registrant Renewal Status table match a registrant renewal system ID in the Registrant Renewal table. It also ensures that when a record in the Registrant Renewal table is deleted, matching child records in the Registrant Renewal Status table are deleted as well. Finally, the constraint blocks changes to the value of the registrant renewal system ID column in the Registrant Renewal if matching child records exist in Registrant Renewal Status.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'CONSTRAINT', N'fk_RegistrantRenewalStatus_RegistrantRenewal_RegistrantRenewalSID'
GO
ALTER TABLE [dbo].[RegistrantRenewalStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantRenewalStatus_SF_FormStatus_FormStatusSID]
	FOREIGN KEY ([FormStatusSID]) REFERENCES [sf].[FormStatus] ([FormStatusSID])
ALTER TABLE [dbo].[RegistrantRenewalStatus]
	CHECK CONSTRAINT [fk_RegistrantRenewalStatus_SF_FormStatus_FormStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form status system ID column in the Registrant Renewal Status table match a form status system ID in the Form Status table. It also ensures that records in the Form Status table cannot be deleted if matching child records exist in Registrant Renewal Status. Finally, the constraint blocks changes to the value of the form status system ID column in the Form Status if matching child records exist in Registrant Renewal Status.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'CONSTRAINT', N'fk_RegistrantRenewalStatus_SF_FormStatus_FormStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantRenewalStatus_FormStatusSID_RegistrantRenewalStatusSID]
	ON [dbo].[RegistrantRenewalStatus] ([FormStatusSID], [RegistrantRenewalStatusSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Status SID foreign key column and avoids row contention on (parent) Form Status updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'INDEX', N'ix_RegistrantRenewalStatus_FormStatusSID_RegistrantRenewalStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantRenewalStatus_RegistrantRenewalSID_RegistrantRenewalStatusSID]
	ON [dbo].[RegistrantRenewalStatus] ([RegistrantRenewalSID], [RegistrantRenewalStatusSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant Renewal SID foreign key column and avoids row contention on (parent) Registrant Renewal updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'INDEX', N'ix_RegistrantRenewalStatus_RegistrantRenewalSID_RegistrantRenewalStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant renewal status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'RegistrantRenewalStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant renewal assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'RegistrantRenewalSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant renewal status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'RegistrantRenewalStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant renewal status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant renewal status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant renewal status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant renewal status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant renewal status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantRenewalStatus', 'CONSTRAINT', N'uk_RegistrantRenewalStatus_RowGUID'
GO
ALTER TABLE [dbo].[RegistrantRenewalStatus] SET (LOCK_ESCALATION = TABLE)
GO
