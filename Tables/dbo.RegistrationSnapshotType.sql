SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrationSnapshotType] (
		[RegistrationSnapshotTypeSID]           [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrationSnapshotTypeLabel]         [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RegistrationSnapshotTypeSCD]           [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RegistrationSnapshotLabelTemplate]     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDefault]                             [bit] NOT NULL,
		[IsActive]                              [bit] NOT NULL,
		[UserDefinedColumns]                    [xml] NULL,
		[RegistrationSnapshotTypeXID]           [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                             [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                             [bit] NOT NULL,
		[CreateUser]                            [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                            [datetimeoffset](7) NOT NULL,
		[UpdateUser]                            [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                            [datetimeoffset](7) NOT NULL,
		[RowGUID]                               [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                              [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrationSnapshotType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrationSnapshotType_RegistrationSnapshotTypeLabel]
		UNIQUE
		NONCLUSTERED
		([RegistrationSnapshotTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrationSnapshotType_RegistrationSnapshotTypeSCD]
		UNIQUE
		NONCLUSTERED
		([RegistrationSnapshotTypeSCD])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrationSnapshotType]
		PRIMARY KEY
		CLUSTERED
		([RegistrationSnapshotTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registration Snapshot Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'CONSTRAINT', N'pk_RegistrationSnapshotType'
GO
ALTER TABLE [dbo].[RegistrationSnapshotType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrationSnapshotType]
	CHECK
	([dbo].[fRegistrationSnapshotType#Check]([RegistrationSnapshotTypeSID],[RegistrationSnapshotTypeLabel],[RegistrationSnapshotTypeSCD],[RegistrationSnapshotLabelTemplate],[IsDefault],[IsActive],[RegistrationSnapshotTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrationSnapshotType]
CHECK CONSTRAINT [ck_RegistrationSnapshotType]
GO
ALTER TABLE [dbo].[RegistrationSnapshotType]
	ADD
	CONSTRAINT [df_RegistrationSnapshotType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[RegistrationSnapshotType]
	ADD
	CONSTRAINT [df_RegistrationSnapshotType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[RegistrationSnapshotType]
	ADD
	CONSTRAINT [df_RegistrationSnapshotType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrationSnapshotType]
	ADD
	CONSTRAINT [df_RegistrationSnapshotType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrationSnapshotType]
	ADD
	CONSTRAINT [df_RegistrationSnapshotType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrationSnapshotType]
	ADD
	CONSTRAINT [df_RegistrationSnapshotType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrationSnapshotType]
	ADD
	CONSTRAINT [df_RegistrationSnapshotType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrationSnapshotType]
	ADD
	CONSTRAINT [df_RegistrationSnapshotType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrationSnapshotType_IsDefault]
	ON [dbo].[RegistrationSnapshotType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Registration Snapshot Type', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'INDEX', N'ux_RegistrationSnapshotType_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration snapshot type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'RegistrationSnapshotTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the registration snapshot type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'RegistrationSnapshotTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the registration snapshot type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'RegistrationSnapshotTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default registration snapshot type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this registration snapshot type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registration snapshot type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'RegistrationSnapshotTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registration snapshot type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registration snapshot type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registration snapshot type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registration snapshot type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration snapshot type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'CONSTRAINT', N'uk_RegistrationSnapshotType_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Registration Snapshot Type Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'CONSTRAINT', N'uk_RegistrationSnapshotType_RegistrationSnapshotTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Registration Snapshot Type SCD column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationSnapshotType', 'CONSTRAINT', N'uk_RegistrationSnapshotType_RegistrationSnapshotTypeSCD'
GO
ALTER TABLE [dbo].[RegistrationSnapshotType] SET (LOCK_ESCALATION = TABLE)
GO
