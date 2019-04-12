SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OrgType] (
		[OrgTypeSID]             [int] IDENTITY(1000001, 1) NOT NULL,
		[OrgTypeName]            [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[OrgTypeCode]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SectorCode]             [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OrgTypeCategory]        [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDefault]              [bit] NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[OrgTypeXID]             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_OrgType_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_OrgType_OrgTypeName]
		UNIQUE
		NONCLUSTERED
		([OrgTypeName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_OrgType_OrgTypeCode]
		UNIQUE
		NONCLUSTERED
		([OrgTypeCode])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_OrgType]
		PRIMARY KEY
		CLUSTERED
		([OrgTypeSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Org Type table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'CONSTRAINT', N'pk_OrgType'
GO
ALTER TABLE [dbo].[OrgType]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_OrgType]
	CHECK
	([dbo].[fOrgType#Check]([OrgTypeSID],[OrgTypeName],[OrgTypeCode],[SectorCode],[OrgTypeCategory],[IsDefault],[IsActive],[OrgTypeXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[OrgType]
CHECK CONSTRAINT [ck_OrgType]
GO
ALTER TABLE [dbo].[OrgType]
	ADD
	CONSTRAINT [df_OrgType_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[OrgType]
	ADD
	CONSTRAINT [df_OrgType_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[OrgType]
	ADD
	CONSTRAINT [df_OrgType_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[OrgType]
	ADD
	CONSTRAINT [df_OrgType_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[OrgType]
	ADD
	CONSTRAINT [df_OrgType_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[OrgType]
	ADD
	CONSTRAINT [df_OrgType_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[OrgType]
	ADD
	CONSTRAINT [df_OrgType_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[OrgType]
	ADD
	CONSTRAINT [df_OrgType_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_OrgType_IsDefault]
	ON [dbo].[OrgType] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Org Type', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'INDEX', N'ux_OrgType_IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is a master list of types of employment describing the specific employment records reported during renewal.  Generally it is used to refer to whether the employment was "Full-Time", "Part-Time/Casual".  The values can refer to other organization type descriptions appropriate for the organization.  The code colum can be used to match codes which may be required for external report - e.g. for a Provider Directory or a national Workforce Planning authority.  If more than one code is required the Employment-Type-XID (external ID) column can also be used.', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the org type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'OrgTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the org type to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'OrgTypeName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional value used for external reporting of the oranization sector - e.g. "14" and "24" are the CIHI codes for Public and Private sectors', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'SectorCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'OrgTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default org type to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this org type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the org type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'OrgTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the org type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this org type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the org type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the org type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'CONSTRAINT', N'uk_OrgType_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Org Type Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'CONSTRAINT', N'uk_OrgType_OrgTypeName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Org Type Code column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'OrgType', 'CONSTRAINT', N'uk_OrgType_OrgTypeCode'
GO
ALTER TABLE [dbo].[OrgType] SET (LOCK_ESCALATION = TABLE)
GO
