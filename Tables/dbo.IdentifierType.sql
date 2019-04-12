SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IdentifierType] (
		[IdentifierTypeSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[OrgSID]                     [int] NOT NULL,
		[IdentifierTypeLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IdentifierTypeCategory]     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsOtherRegistration]        [bit] NOT NULL,
		[DisplayRank]                [tinyint] NOT NULL,
		[EditMask]                   [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IdentifierCode]             [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]                  [bit] NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[IdentifierTypeXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_IdentifierType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_IdentifierType_IdentifierTypeLabel]
		UNIQUE
		NONCLUSTERED
		([IdentifierTypeLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_IdentifierType_IdentifierCode]
		UNIQUE
		NONCLUSTERED
		([IdentifierCode])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_IdentifierType]
		PRIMARY KEY
		CLUSTERED
		([IdentifierTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Identifier Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'CONSTRAINT', N'pk_IdentifierType'
GO
ALTER TABLE [dbo].[IdentifierType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_IdentifierType]
	CHECK
	([dbo].[fIdentifierType#Check]([IdentifierTypeSID],[OrgSID],[IdentifierTypeLabel],[IdentifierTypeCategory],[IsOtherRegistration],[DisplayRank],[EditMask],[IdentifierCode],[IsDefault],[IdentifierTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[IdentifierType]
CHECK CONSTRAINT [ck_IdentifierType]
GO
ALTER TABLE [dbo].[IdentifierType]
	ADD
	CONSTRAINT [df_IdentifierType_IsOtherRegistration]
	DEFAULT (CONVERT([bit],(1))) FOR [IsOtherRegistration]
GO
ALTER TABLE [dbo].[IdentifierType]
	ADD
	CONSTRAINT [df_IdentifierType_DisplayRank]
	DEFAULT ((5)) FOR [DisplayRank]
GO
ALTER TABLE [dbo].[IdentifierType]
	ADD
	CONSTRAINT [df_IdentifierType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[IdentifierType]
	ADD
	CONSTRAINT [df_IdentifierType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[IdentifierType]
	ADD
	CONSTRAINT [df_IdentifierType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[IdentifierType]
	ADD
	CONSTRAINT [df_IdentifierType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[IdentifierType]
	ADD
	CONSTRAINT [df_IdentifierType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[IdentifierType]
	ADD
	CONSTRAINT [df_IdentifierType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[IdentifierType]
	ADD
	CONSTRAINT [df_IdentifierType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[IdentifierType]
	WITH CHECK
	ADD CONSTRAINT [fk_IdentifierType_Org_OrgSID]
	FOREIGN KEY ([OrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [dbo].[IdentifierType]
	CHECK CONSTRAINT [fk_IdentifierType_Org_OrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the org system ID column in the Identifier Type table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Identifier Type. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Identifier Type.', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'CONSTRAINT', N'fk_IdentifierType_Org_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_IdentifierType_OrgSID_IdentifierTypeSID]
	ON [dbo].[IdentifierType] ([OrgSID], [IdentifierTypeSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'INDEX', N'ix_IdentifierType_OrgSID_IdentifierTypeSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_IdentifierType_IsDefault]
	ON [dbo].[IdentifierType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Identifier Type', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'INDEX', N'ux_IdentifierType_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Identifier Type table is used to categorize alternate identifiers assigned to Registrants.  The main identifier for registrants is the Registrant-No stored in dbo.Registrant. This table stores alternate identifiers which may be provided by national licensing bodies, or other regulators where the person holds a permit/license.  These identifiers  are usually defined by external systems or registries.  One of the Identifier Types can be defined as the "Default" for the system. When an identifier is added to an Registrant, the default type is automatically assigned. In order to control the formatting and validation of different types of identifiers for entry, an edit/validation mask can be defined.  The Edit Mask is also used in search routines to determine which identifiers should be searched when search-text is provided.', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the identifier type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'IdentifierTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this identifier type', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the identifier type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'IdentifierTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these identifier types.', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'IdentifierTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this identifier type is issued from another Regulator in the same or related profession to include the type in "Other registrations" queries and reports', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'IsOtherRegistration'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value defining the format of letters, numbers and constants the ID must follow to be valid (uses "REGEX" format)| Assistance is required from the help desk to set it.', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'EditMask'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code used to represent this type of identifier to external systems', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'IdentifierCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default identifier type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the identifier type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'IdentifierTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the identifier type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this identifier type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the identifier type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the identifier type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the identifier type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'CONSTRAINT', N'uk_IdentifierType_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Identifier Type Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'CONSTRAINT', N'uk_IdentifierType_IdentifierTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Identifier Code column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'IdentifierType', 'CONSTRAINT', N'uk_IdentifierType_IdentifierCode'
GO
ALTER TABLE [dbo].[IdentifierType] SET (LOCK_ESCALATION = TABLE)
GO
