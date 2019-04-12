SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ComplaintProcess] (
		[ComplaintProcessSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[ComplaintProcessLabel]         [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]                    [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDefault]                     [bit] NOT NULL,
		[ParentComplaintProcessSID]     [int] NULL,
		[UserDefinedColumns]            [xml] NULL,
		[ComplaintProcessXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                     [bit] NOT NULL,
		[CreateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                    [datetimeoffset](7) NOT NULL,
		[UpdateUser]                    [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                    [datetimeoffset](7) NOT NULL,
		[RowGUID]                       [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                      [timestamp] NOT NULL,
		CONSTRAINT [uk_ComplaintProcess_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ComplaintProcess_ComplaintProcessLabel]
		UNIQUE
		NONCLUSTERED
		([ComplaintProcessLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ComplaintProcess]
		PRIMARY KEY
		CLUSTERED
		([ComplaintProcessSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Complaint Process table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'CONSTRAINT', N'pk_ComplaintProcess'
GO
ALTER TABLE [dbo].[ComplaintProcess]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ComplaintProcess]
	CHECK
	([dbo].[fComplaintProcess#Check]([ComplaintProcessSID],[ComplaintProcessLabel],[IsDefault],[ParentComplaintProcessSID],[ComplaintProcessXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[ComplaintProcess]
CHECK CONSTRAINT [ck_ComplaintProcess]
GO
ALTER TABLE [dbo].[ComplaintProcess]
	ADD
	CONSTRAINT [df_ComplaintProcess_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ComplaintProcess]
	ADD
	CONSTRAINT [df_ComplaintProcess_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[ComplaintProcess]
	ADD
	CONSTRAINT [df_ComplaintProcess_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[ComplaintProcess]
	ADD
	CONSTRAINT [df_ComplaintProcess_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[ComplaintProcess]
	ADD
	CONSTRAINT [df_ComplaintProcess_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[ComplaintProcess]
	ADD
	CONSTRAINT [df_ComplaintProcess_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[ComplaintProcess]
	ADD
	CONSTRAINT [df_ComplaintProcess_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[ComplaintProcess]
	WITH CHECK
	ADD CONSTRAINT [fk_ComplaintProcess_ComplaintProcess_ParentComplaintProcessSID]
	FOREIGN KEY ([ParentComplaintProcessSID]) REFERENCES [dbo].[ComplaintProcess] ([ComplaintProcessSID])
ALTER TABLE [dbo].[ComplaintProcess]
	CHECK CONSTRAINT [fk_ComplaintProcess_ComplaintProcess_ParentComplaintProcessSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the parent complaint process system ID column in the Complaint Process table match a complaint process system ID in the Complaint Process table. It also ensures that records in the Complaint Process table cannot be deleted if matching child records exist in Complaint Process. Finally, the constraint blocks changes to the value of the complaint process system ID column in the Complaint Process if matching child records exist in Complaint Process.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'CONSTRAINT', N'fk_ComplaintProcess_ComplaintProcess_ParentComplaintProcessSID'
GO
CREATE NONCLUSTERED INDEX [ix_ComplaintProcess_ParentComplaintProcessSID_ComplaintProcessSID]
	ON [dbo].[ComplaintProcess] ([ParentComplaintProcessSID], [ComplaintProcessSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Parent Complaint Process SID foreign key column and avoids row contention on (parent) Complaint Process updates', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'INDEX', N'ix_ComplaintProcess_ParentComplaintProcessSID_ComplaintProcessSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ComplaintProcess_IsDefault]
	ON [dbo].[ComplaintProcess] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Complaint Process', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'INDEX', N'ux_ComplaintProcess_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the complaint process assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'ComplaintProcessSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the complaint process to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'ComplaintProcessLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default complaint process to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The complaint process this  is defined for', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'ParentComplaintProcessSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the complaint process | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'ComplaintProcessXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the complaint process | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this complaint process record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the complaint process | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the complaint process record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint process record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'CONSTRAINT', N'uk_ComplaintProcess_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Complaint Process Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'ComplaintProcess', 'CONSTRAINT', N'uk_ComplaintProcess_ComplaintProcessLabel'
GO
ALTER TABLE [dbo].[ComplaintProcess] SET (LOCK_ESCALATION = TABLE)
GO
