SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegionMapping] (
		[RegionMappingSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[PostalCodeMask]         [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RegionSID]              [int] NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[RegionMappingXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_RegionMapping_PostalCodeMask]
		UNIQUE
		NONCLUSTERED
		([PostalCodeMask])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegionMapping_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegionMapping]
		PRIMARY KEY
		CLUSTERED
		([RegionMappingSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Region Mapping table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'CONSTRAINT', N'pk_RegionMapping'
GO
ALTER TABLE [dbo].[RegionMapping]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegionMapping]
	CHECK
	([dbo].[fRegionMapping#Check]([RegionMappingSID],[PostalCodeMask],[RegionSID],[RegionMappingXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegionMapping]
CHECK CONSTRAINT [ck_RegionMapping]
GO
ALTER TABLE [dbo].[RegionMapping]
	ADD
	CONSTRAINT [df_RegionMapping_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegionMapping]
	ADD
	CONSTRAINT [df_RegionMapping_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegionMapping]
	ADD
	CONSTRAINT [df_RegionMapping_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegionMapping]
	ADD
	CONSTRAINT [df_RegionMapping_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegionMapping]
	ADD
	CONSTRAINT [df_RegionMapping_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegionMapping]
	ADD
	CONSTRAINT [df_RegionMapping_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegionMapping]
	WITH CHECK
	ADD CONSTRAINT [fk_RegionMapping_Region_RegionSID]
	FOREIGN KEY ([RegionSID]) REFERENCES [dbo].[Region] ([RegionSID])
ALTER TABLE [dbo].[RegionMapping]
	CHECK CONSTRAINT [fk_RegionMapping_Region_RegionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the region system ID column in the Region Mapping table match a region system ID in the Region table. It also ensures that records in the Region table cannot be deleted if matching child records exist in Region Mapping. Finally, the constraint blocks changes to the value of the region system ID column in the Region if matching child records exist in Region Mapping.', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'CONSTRAINT', N'fk_RegionMapping_Region_RegionSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegionMapping_LegacyKey]
	ON [dbo].[RegionMapping] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'INDEX', N'ux_RegionMapping_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_RegionMapping_RegionSID_RegionMappingSID]
	ON [dbo].[RegionMapping] ([RegionSID], [RegionMappingSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Region SID foreign key column and avoids row contention on (parent) Region updates', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'INDEX', N'ix_RegionMapping_RegionSID_RegionMappingSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used to assign regions to addresses. A template for matching postal codes is entered here and then compared to postal codes on addresses to find a match. Wild cards are supported. When values on this table are changed, logic must be executed to reassign region keys on the tables which have them. Note that these key values are not derived to improve performance. ', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the region mapping assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'RegionMappingSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a postal code pattern to match to a region - eg. "T9E" matches Leduc, Alberta (no quotes). | Use "%" as a general wild card and "_" to match a single character.', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'PostalCodeMask'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region this mapping is defined for', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the region mapping | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'RegionMappingXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the region mapping | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this region mapping record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the region mapping | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the region mapping record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the region mapping record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Postal Code Mask column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'CONSTRAINT', N'uk_RegionMapping_PostalCodeMask'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegionMapping', 'CONSTRAINT', N'uk_RegionMapping_RowGUID'
GO
ALTER TABLE [dbo].[RegionMapping] SET (LOCK_ESCALATION = TABLE)
GO
