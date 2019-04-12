SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CredentialType] (
		[CredentialTypeSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[CredentialTypeLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CredentialTypeCategory]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDefault]                  [bit] NOT NULL,
		[Description]                [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsActive]                   [bit] NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[CredentialTypeXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_CredentialType_CredentialTypeLabel]
		UNIQUE
		NONCLUSTERED
		([CredentialTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_CredentialType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_CredentialType]
		PRIMARY KEY
		CLUSTERED
		([CredentialTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Credential Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'CONSTRAINT', N'pk_CredentialType'
GO
ALTER TABLE [dbo].[CredentialType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_CredentialType]
	CHECK
	([dbo].[fCredentialType#Check]([CredentialTypeSID],[CredentialTypeLabel],[CredentialTypeCategory],[IsDefault],[IsActive],[CredentialTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[CredentialType]
CHECK CONSTRAINT [ck_CredentialType]
GO
ALTER TABLE [dbo].[CredentialType]
	ADD
	CONSTRAINT [df_CredentialType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[CredentialType]
	ADD
	CONSTRAINT [df_CredentialType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[CredentialType]
	ADD
	CONSTRAINT [df_CredentialType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[CredentialType]
	ADD
	CONSTRAINT [df_CredentialType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[CredentialType]
	ADD
	CONSTRAINT [df_CredentialType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[CredentialType]
	ADD
	CONSTRAINT [df_CredentialType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[CredentialType]
	ADD
	CONSTRAINT [df_CredentialType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[CredentialType]
	ADD
	CONSTRAINT [df_CredentialType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_CredentialType_IsDefault]
	ON [dbo].[CredentialType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Credential Type', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'INDEX', N'ux_CredentialType_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the credential type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'CredentialTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the credential type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'CredentialTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'CredentialTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default credential type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this specialization type is applied to. This content is available as help text on specialization type selection. ', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this credential type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the credential type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'CredentialTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the credential type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this credential type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the credential type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the credential type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the credential type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Credential Type Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'CONSTRAINT', N'uk_CredentialType_CredentialTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'CredentialType', 'CONSTRAINT', N'uk_CredentialType_RowGUID'
GO
ALTER TABLE [dbo].[CredentialType] SET (LOCK_ESCALATION = TABLE)
GO
