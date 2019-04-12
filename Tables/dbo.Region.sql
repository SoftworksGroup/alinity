SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Region] (
		[RegionSID]              [int] IDENTITY(1000001, 1) NOT NULL,
		[RegionLabel]            [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RegionName]             [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsDefault]              [bit] NOT NULL,
		[IsActive]               [bit] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[RegionXID]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_Region_RegionLabel]
		UNIQUE
		NONCLUSTERED
		([RegionLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Region_RegionName]
		UNIQUE
		NONCLUSTERED
		([RegionName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Region_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Region]
		PRIMARY KEY
		CLUSTERED
		([RegionSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Region table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'CONSTRAINT', N'pk_Region'
GO
ALTER TABLE [dbo].[Region]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Region]
	CHECK
	([dbo].[fRegion#Check]([RegionSID],[RegionLabel],[RegionName],[IsDefault],[IsActive],[RegionXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Region]
CHECK CONSTRAINT [ck_Region]
GO
ALTER TABLE [dbo].[Region]
	ADD
	CONSTRAINT [df_Region_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[Region]
	ADD
	CONSTRAINT [df_Region_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Region]
	ADD
	CONSTRAINT [df_Region_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Region]
	ADD
	CONSTRAINT [df_Region_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Region]
	ADD
	CONSTRAINT [df_Region_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Region]
	ADD
	CONSTRAINT [df_Region_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Region]
	ADD
	CONSTRAINT [df_Region_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Region]
	ADD
	CONSTRAINT [df_Region_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Region_IsDefault]
	ON [dbo].[Region] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Region', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'INDEX', N'ux_Region_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Region_LegacyKey]
	ON [dbo].[Region] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'INDEX', N'ux_Region_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the region assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the region to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'RegionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the region to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'RegionName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default region to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this region record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the region | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'RegionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the region | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this region record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the region | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the region record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the region record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Region Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'CONSTRAINT', N'uk_Region_RegionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Region Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'CONSTRAINT', N'uk_Region_RegionName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Region', 'CONSTRAINT', N'uk_Region_RowGUID'
GO
ALTER TABLE [dbo].[Region] SET (LOCK_ESCALATION = TABLE)
GO
