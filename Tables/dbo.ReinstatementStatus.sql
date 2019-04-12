SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReinstatementStatus] (
		[ReinstatementStatusSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ReinstatementSID]           [int] NOT NULL,
		[FormStatusSID]              [int] NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[ReinstatementStatusXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_ReinstatementStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ReinstatementStatus]
		PRIMARY KEY
		CLUSTERED
		([ReinstatementStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Reinstatement Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'CONSTRAINT', N'pk_ReinstatementStatus'
GO
ALTER TABLE [dbo].[ReinstatementStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ReinstatementStatus]
	CHECK
	([dbo].[fReinstatementStatus#Check]([ReinstatementStatusSID],[ReinstatementSID],[FormStatusSID],[ReinstatementStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ReinstatementStatus]
CHECK CONSTRAINT [ck_ReinstatementStatus]
GO
ALTER TABLE [dbo].[ReinstatementStatus]
	ADD
	CONSTRAINT [df_ReinstatementStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ReinstatementStatus]
	ADD
	CONSTRAINT [df_ReinstatementStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ReinstatementStatus]
	ADD
	CONSTRAINT [df_ReinstatementStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ReinstatementStatus]
	ADD
	CONSTRAINT [df_ReinstatementStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ReinstatementStatus]
	ADD
	CONSTRAINT [df_ReinstatementStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ReinstatementStatus]
	ADD
	CONSTRAINT [df_ReinstatementStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ReinstatementStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_ReinstatementStatus_Reinstatement_ReinstatementSID]
	FOREIGN KEY ([ReinstatementSID]) REFERENCES [dbo].[Reinstatement] ([ReinstatementSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[ReinstatementStatus]
	CHECK CONSTRAINT [fk_ReinstatementStatus_Reinstatement_ReinstatementSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the reinstatement system ID column in the Reinstatement Status table match a reinstatement system ID in the Reinstatement table. It also ensures that when a record in the Reinstatement table is deleted, matching child records in the Reinstatement Status table are deleted as well. Finally, the constraint blocks changes to the value of the reinstatement system ID column in the Reinstatement if matching child records exist in Reinstatement Status.', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'CONSTRAINT', N'fk_ReinstatementStatus_Reinstatement_ReinstatementSID'
GO
ALTER TABLE [dbo].[ReinstatementStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_ReinstatementStatus_SF_FormStatus_FormStatusSID]
	FOREIGN KEY ([FormStatusSID]) REFERENCES [sf].[FormStatus] ([FormStatusSID])
ALTER TABLE [dbo].[ReinstatementStatus]
	CHECK CONSTRAINT [fk_ReinstatementStatus_SF_FormStatus_FormStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form status system ID column in the Reinstatement Status table match a form status system ID in the Form Status table. It also ensures that records in the Form Status table cannot be deleted if matching child records exist in Reinstatement Status. Finally, the constraint blocks changes to the value of the form status system ID column in the Form Status if matching child records exist in Reinstatement Status.', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'CONSTRAINT', N'fk_ReinstatementStatus_SF_FormStatus_FormStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_ReinstatementStatus_FormStatusSID_ReinstatementStatusSID]
	ON [dbo].[ReinstatementStatus] ([FormStatusSID], [ReinstatementStatusSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Status SID foreign key column and avoids row contention on (parent) Form Status updates', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'INDEX', N'ix_ReinstatementStatus_FormStatusSID_ReinstatementStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_ReinstatementStatus_ReinstatementSID_ReinstatementStatusSID]
	ON [dbo].[ReinstatementStatus] ([ReinstatementSID], [ReinstatementStatusSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Reinstatement SID foreign key column and avoids row contention on (parent) Reinstatement updates', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'INDEX', N'ix_ReinstatementStatus_ReinstatementSID_ReinstatementStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the reinstatement status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'ReinstatementStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the reinstatement assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'ReinstatementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the reinstatement status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'ReinstatementStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the reinstatement status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this reinstatement status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the reinstatement status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the reinstatement status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reinstatement status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ReinstatementStatus', 'CONSTRAINT', N'uk_ReinstatementStatus_RowGUID'
GO
ALTER TABLE [dbo].[ReinstatementStatus] SET (LOCK_ESCALATION = TABLE)
GO
