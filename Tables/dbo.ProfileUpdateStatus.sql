SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProfileUpdateStatus] (
		[ProfileUpdateStatusSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[ProfileUpdateSID]           [int] NOT NULL,
		[FormStatusSID]              [int] NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[ProfileUpdateStatusXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_ProfileUpdateStatus_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ProfileUpdateStatus]
		PRIMARY KEY
		CLUSTERED
		([ProfileUpdateStatusSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Profile Update Status table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'CONSTRAINT', N'pk_ProfileUpdateStatus'
GO
ALTER TABLE [dbo].[ProfileUpdateStatus]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ProfileUpdateStatus]
	CHECK
	([dbo].[fProfileUpdateStatus#Check]([ProfileUpdateStatusSID],[ProfileUpdateSID],[FormStatusSID],[ProfileUpdateStatusXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ProfileUpdateStatus]
CHECK CONSTRAINT [ck_ProfileUpdateStatus]
GO
ALTER TABLE [dbo].[ProfileUpdateStatus]
	ADD
	CONSTRAINT [df_ProfileUpdateStatus_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ProfileUpdateStatus]
	ADD
	CONSTRAINT [df_ProfileUpdateStatus_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ProfileUpdateStatus]
	ADD
	CONSTRAINT [df_ProfileUpdateStatus_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ProfileUpdateStatus]
	ADD
	CONSTRAINT [df_ProfileUpdateStatus_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ProfileUpdateStatus]
	ADD
	CONSTRAINT [df_ProfileUpdateStatus_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ProfileUpdateStatus]
	ADD
	CONSTRAINT [df_ProfileUpdateStatus_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ProfileUpdateStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_ProfileUpdateStatus_SF_FormStatus_FormStatusSID]
	FOREIGN KEY ([FormStatusSID]) REFERENCES [sf].[FormStatus] ([FormStatusSID])
ALTER TABLE [dbo].[ProfileUpdateStatus]
	CHECK CONSTRAINT [fk_ProfileUpdateStatus_SF_FormStatus_FormStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the form status system ID column in the Profile Update Status table match a form status system ID in the Form Status table. It also ensures that records in the Form Status table cannot be deleted if matching child records exist in Profile Update Status. Finally, the constraint blocks changes to the value of the form status system ID column in the Form Status if matching child records exist in Profile Update Status.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'CONSTRAINT', N'fk_ProfileUpdateStatus_SF_FormStatus_FormStatusSID'
GO
ALTER TABLE [dbo].[ProfileUpdateStatus]
	WITH CHECK
	ADD CONSTRAINT [fk_ProfileUpdateStatus_ProfileUpdate_ProfileUpdateSID]
	FOREIGN KEY ([ProfileUpdateSID]) REFERENCES [dbo].[ProfileUpdate] ([ProfileUpdateSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[ProfileUpdateStatus]
	CHECK CONSTRAINT [fk_ProfileUpdateStatus_ProfileUpdate_ProfileUpdateSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the profile update system ID column in the Profile Update Status table match a profile update system ID in the Profile Update table. It also ensures that when a record in the Profile Update table is deleted, matching child records in the Profile Update Status table are deleted as well. Finally, the constraint blocks changes to the value of the profile update system ID column in the Profile Update if matching child records exist in Profile Update Status.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'CONSTRAINT', N'fk_ProfileUpdateStatus_ProfileUpdate_ProfileUpdateSID'
GO
CREATE NONCLUSTERED INDEX [ix_ProfileUpdateStatus_FormStatusSID_ProfileUpdateStatusSID]
	ON [dbo].[ProfileUpdateStatus] ([FormStatusSID], [ProfileUpdateStatusSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Form Status SID foreign key column and avoids row contention on (parent) Form Status updates', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'INDEX', N'ix_ProfileUpdateStatus_FormStatusSID_ProfileUpdateStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_ProfileUpdateStatus_ProfileUpdateSID_ProfileUpdateStatusSID]
	ON [dbo].[ProfileUpdateStatus] ([ProfileUpdateSID], [ProfileUpdateStatusSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Profile Update SID foreign key column and avoids row contention on (parent) Profile Update updates', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'INDEX', N'ix_ProfileUpdateStatus_ProfileUpdateSID_ProfileUpdateStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the profile update status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'ProfileUpdateStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the profile update assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'ProfileUpdateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the profile update status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'ProfileUpdateStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the profile update status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this profile update status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the profile update status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the profile update status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the profile update status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ProfileUpdateStatus', 'CONSTRAINT', N'uk_ProfileUpdateStatus_RowGUID'
GO
ALTER TABLE [dbo].[ProfileUpdateStatus] SET (LOCK_ESCALATION = TABLE)
GO
