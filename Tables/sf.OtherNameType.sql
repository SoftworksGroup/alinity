SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[OtherNameType] (
		[OtherNameTypeSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[OtherNameTypeLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[OtherNameTypeXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_OtherNameType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_OtherNameType_OtherNameTypeLabel]
		UNIQUE
		NONCLUSTERED
		([OtherNameTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_OtherNameType]
		PRIMARY KEY
		CLUSTERED
		([OtherNameTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Other Name Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'CONSTRAINT', N'pk_OtherNameType'
GO
ALTER TABLE [sf].[OtherNameType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_OtherNameType]
	CHECK
	([sf].[fOtherNameType#Check]([OtherNameTypeSID],[OtherNameTypeLabel],[IsDefault],[IsActive],[OtherNameTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[OtherNameType]
CHECK CONSTRAINT [ck_OtherNameType]
GO
ALTER TABLE [sf].[OtherNameType]
	ADD
	CONSTRAINT [df_OtherNameType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [sf].[OtherNameType]
	ADD
	CONSTRAINT [df_OtherNameType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[OtherNameType]
	ADD
	CONSTRAINT [df_OtherNameType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[OtherNameType]
	ADD
	CONSTRAINT [df_OtherNameType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[OtherNameType]
	ADD
	CONSTRAINT [df_OtherNameType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[OtherNameType]
	ADD
	CONSTRAINT [df_OtherNameType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[OtherNameType]
	ADD
	CONSTRAINT [df_OtherNameType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[OtherNameType]
	ADD
	CONSTRAINT [df_OtherNameType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_OtherNameType_IsDefault]
	ON [sf].[OtherNameType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Other Name Type', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'INDEX', N'ux_OtherNameType_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the other name type assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'OtherNameTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the other name type to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'OtherNameTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default other name type to assign when new records are added', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this other name type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the other name type | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'OtherNameTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the other name type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this other name type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the other name type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the other name type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the other name type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'CONSTRAINT', N'uk_OtherNameType_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Other Name Type Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'OtherNameType', 'CONSTRAINT', N'uk_OtherNameType_OtherNameTypeLabel'
GO
ALTER TABLE [sf].[OtherNameType] SET (LOCK_ESCALATION = TABLE)
GO
