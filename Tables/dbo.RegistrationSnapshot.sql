SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrationSnapshot] (
		[RegistrationSnapshotSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrationSnapshotTypeSID]     [int] NOT NULL,
		[RegistrationSnapshotLabel]       [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RegistrationYear]                [smallint] NOT NULL,
		[Description]                     [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[QueuedTime]                      [datetimeoffset](7) NOT NULL,
		[LockedTime]                      [datetimeoffset](7) NULL,
		[LastCodeUpdateTime]              [datetimeoffset](7) NULL,
		[LastVerifiedTime]                [datetimeoffset](7) NULL,
		[JobRunSID]                       [int] NULL,
		[UserDefinedColumns]              [xml] NULL,
		[RegistrationSnapshotXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                       [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                       [bit] NOT NULL,
		[CreateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                      [datetimeoffset](7) NOT NULL,
		[UpdateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                      [datetimeoffset](7) NOT NULL,
		[RowGUID]                         [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                        [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrationSnapshot_RegistrationSnapshotLabel]
		UNIQUE
		NONCLUSTERED
		([RegistrationSnapshotLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrationSnapshot_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrationSnapshot]
		PRIMARY KEY
		CLUSTERED
		([RegistrationSnapshotSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registration Snapshot table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'CONSTRAINT', N'pk_RegistrationSnapshot'
GO
ALTER TABLE [dbo].[RegistrationSnapshot]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrationSnapshot]
	CHECK
	([dbo].[fRegistrationSnapshot#Check]([RegistrationSnapshotSID],[RegistrationSnapshotTypeSID],[RegistrationSnapshotLabel],[RegistrationYear],[QueuedTime],[LockedTime],[LastCodeUpdateTime],[LastVerifiedTime],[JobRunSID],[RegistrationSnapshotXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrationSnapshot]
CHECK CONSTRAINT [ck_RegistrationSnapshot]
GO
ALTER TABLE [dbo].[RegistrationSnapshot]
	ADD
	CONSTRAINT [df_RegistrationSnapshot_RegistrationYear]
	DEFAULT ([dbo].[fRegistrationYear#Current]()) FOR [RegistrationYear]
GO
ALTER TABLE [dbo].[RegistrationSnapshot]
	ADD
	CONSTRAINT [df_RegistrationSnapshot_QueuedTime]
	DEFAULT (sysdatetimeoffset()) FOR [QueuedTime]
GO
ALTER TABLE [dbo].[RegistrationSnapshot]
	ADD
	CONSTRAINT [df_RegistrationSnapshot_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrationSnapshot]
	ADD
	CONSTRAINT [df_RegistrationSnapshot_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrationSnapshot]
	ADD
	CONSTRAINT [df_RegistrationSnapshot_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrationSnapshot]
	ADD
	CONSTRAINT [df_RegistrationSnapshot_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrationSnapshot]
	ADD
	CONSTRAINT [df_RegistrationSnapshot_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrationSnapshot]
	ADD
	CONSTRAINT [df_RegistrationSnapshot_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrationSnapshot]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationSnapshot_SF_JobRun_JobRunSID]
	FOREIGN KEY ([JobRunSID]) REFERENCES [sf].[JobRun] ([JobRunSID])
ALTER TABLE [dbo].[RegistrationSnapshot]
	CHECK CONSTRAINT [fk_RegistrationSnapshot_SF_JobRun_JobRunSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the job run system ID column in the Registration Snapshot table match a job run system ID in the Job Run table. It also ensures that records in the Job Run table cannot be deleted if matching child records exist in Registration Snapshot. Finally, the constraint blocks changes to the value of the job run system ID column in the Job Run if matching child records exist in Registration Snapshot.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'CONSTRAINT', N'fk_RegistrationSnapshot_SF_JobRun_JobRunSID'
GO
ALTER TABLE [dbo].[RegistrationSnapshot]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationSnapshot_RegistrationSnapshotType_RegistrationSnapshotTypeSID]
	FOREIGN KEY ([RegistrationSnapshotTypeSID]) REFERENCES [dbo].[RegistrationSnapshotType] ([RegistrationSnapshotTypeSID])
ALTER TABLE [dbo].[RegistrationSnapshot]
	CHECK CONSTRAINT [fk_RegistrationSnapshot_RegistrationSnapshotType_RegistrationSnapshotTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registration snapshot type system ID column in the Registration Snapshot table match a registration snapshot type system ID in the Registration Snapshot Type table. It also ensures that records in the Registration Snapshot Type table cannot be deleted if matching child records exist in Registration Snapshot. Finally, the constraint blocks changes to the value of the registration snapshot type system ID column in the Registration Snapshot Type if matching child records exist in Registration Snapshot.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'CONSTRAINT', N'fk_RegistrationSnapshot_RegistrationSnapshotType_RegistrationSnapshotTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationSnapshot_JobRunSID_RegistrationSnapshotSID]
	ON [dbo].[RegistrationSnapshot] ([JobRunSID], [RegistrationSnapshotSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Job Run SID foreign key column and avoids row contention on (parent) Job Run updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'INDEX', N'ix_RegistrationSnapshot_JobRunSID_RegistrationSnapshotSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationSnapshot_RegistrationSnapshotTypeSID_RegistrationSnapshotSID]
	ON [dbo].[RegistrationSnapshot] ([RegistrationSnapshotTypeSID], [RegistrationSnapshotSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registration Snapshot Type SID foreign key column and avoids row contention on (parent) Registration Snapshot Type updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'INDEX', N'ix_RegistrationSnapshot_RegistrationSnapshotTypeSID_RegistrationSnapshotSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A record is added to this table when a new set of Registration Profiles are generated.  These profiles are typically used for reporting to external parties like CIHI and provincial/state registries.   The records in this table appear in the user interface to allow navigation to snapshots created at different times.  Some editing of the profiles generated in the snapshot is allowed.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration snapshot assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'RegistrationSnapshotSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration snapshot type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'RegistrationSnapshotTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the registration snapshot to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'RegistrationSnapshotLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional description of what the snapshot was generated for.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the generation of this snapshot should begin ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'QueuedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the snapshot is marked as locked which disallows further editing. A system-administrator can unlock.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'LockedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the code update process was last run on this snapshot.  Blank when pending (in process).', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'LastCodeUpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the verification process was last run on this snapshot.  Blank when pending (in process).', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'LastVerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the job run assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'JobRunSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registration snapshot | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'RegistrationSnapshotXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registration snapshot | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registration snapshot record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registration snapshot | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registration snapshot record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration snapshot record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Registration Snapshot Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'CONSTRAINT', N'uk_RegistrationSnapshot_RegistrationSnapshotLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshot', 'CONSTRAINT', N'uk_RegistrationSnapshot_RowGUID'
GO
ALTER TABLE [dbo].[RegistrationSnapshot] SET (LOCK_ESCALATION = TABLE)
GO
