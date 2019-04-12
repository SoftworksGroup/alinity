SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrationRequirementType] (
		[RegistrationRequirementTypeSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrationRequirementTypeLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RegistrationRequirementTypeCode]         [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RegistrationRequirementTypeCategory]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsAppliedToPeople]                       [bit] NOT NULL,
		[IsAppliedToOrganizations]                [bit] NOT NULL,
		[IsDefault]                               [bit] NOT NULL,
		[IsActive]                                [bit] NOT NULL,
		[UserDefinedColumns]                      [xml] NULL,
		[RegistrationRequirementTypeXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                               [bit] NOT NULL,
		[CreateUser]                              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                              [datetimeoffset](7) NOT NULL,
		[UpdateUser]                              [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                              [datetimeoffset](7) NOT NULL,
		[RowGUID]                                 [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                                [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrationRequirementType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrationRequirementType_RegistrationRequirementTypeLabel]
		UNIQUE
		NONCLUSTERED
		([RegistrationRequirementTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrationRequirementType_RegistrationRequirementTypeCode]
		UNIQUE
		NONCLUSTERED
		([RegistrationRequirementTypeCode])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrationRequirementType]
		PRIMARY KEY
		CLUSTERED
		([RegistrationRequirementTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registration Requirement Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'CONSTRAINT', N'pk_RegistrationRequirementType'
GO
ALTER TABLE [dbo].[RegistrationRequirementType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrationRequirementType]
	CHECK
	([dbo].[fRegistrationRequirementType#Check]([RegistrationRequirementTypeSID],[RegistrationRequirementTypeLabel],[RegistrationRequirementTypeCode],[RegistrationRequirementTypeCategory],[IsAppliedToPeople],[IsAppliedToOrganizations],[IsDefault],[IsActive],[RegistrationRequirementTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrationRequirementType]
CHECK CONSTRAINT [ck_RegistrationRequirementType]
GO
ALTER TABLE [dbo].[RegistrationRequirementType]
	ADD
	CONSTRAINT [df_RegistrationRequirementType_IsAppliedToPeople]
	DEFAULT (CONVERT([bit],(1))) FOR [IsAppliedToPeople]
GO
ALTER TABLE [dbo].[RegistrationRequirementType]
	ADD
	CONSTRAINT [df_RegistrationRequirementType_IsAppliedToOrganizations]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAppliedToOrganizations]
GO
ALTER TABLE [dbo].[RegistrationRequirementType]
	ADD
	CONSTRAINT [df_RegistrationRequirementType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[RegistrationRequirementType]
	ADD
	CONSTRAINT [df_RegistrationRequirementType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[RegistrationRequirementType]
	ADD
	CONSTRAINT [df_RegistrationRequirementType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrationRequirementType]
	ADD
	CONSTRAINT [df_RegistrationRequirementType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrationRequirementType]
	ADD
	CONSTRAINT [df_RegistrationRequirementType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrationRequirementType]
	ADD
	CONSTRAINT [df_RegistrationRequirementType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrationRequirementType]
	ADD
	CONSTRAINT [df_RegistrationRequirementType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrationRequirementType]
	ADD
	CONSTRAINT [df_RegistrationRequirementType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrationRequirementType_IsDefault]
	ON [dbo].[RegistrationRequirementType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Registration Requirement Type', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'INDEX', N'ux_RegistrationRequirementType_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration requirement type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'RegistrationRequirementTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the registration requirement type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'RegistrationRequirementTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'RegistrationRequirementTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this type of requirement applies to people', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'IsAppliedToPeople'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this type of requirement applies to organizations', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'IsAppliedToOrganizations'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default registration requirement type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this registration requirement type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registration requirement type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'RegistrationRequirementTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registration requirement type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registration requirement type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registration requirement type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registration requirement type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration requirement type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Registration Requirement Type Code column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'CONSTRAINT', N'uk_RegistrationRequirementType_RegistrationRequirementTypeCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'CONSTRAINT', N'uk_RegistrationRequirementType_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Registration Requirement Type Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationRequirementType', 'CONSTRAINT', N'uk_RegistrationRequirementType_RegistrationRequirementTypeLabel'
GO
ALTER TABLE [dbo].[RegistrationRequirementType] SET (LOCK_ESCALATION = TABLE)
GO
