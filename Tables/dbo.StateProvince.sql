SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StateProvince] (
		[StateProvinceSID]          [int] IDENTITY(1000001, 1) NOT NULL,
		[StateProvinceName]         [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[StateProvinceCode]         [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CountrySID]                [int] NOT NULL,
		[ISONumber]                 [smallint] NULL,
		[IsDisplayed]               [bit] NOT NULL,
		[IsDefault]                 [bit] NOT NULL,
		[IsActive]                  [bit] NOT NULL,
		[IsAdminReviewRequired]     [bit] NOT NULL,
		[ChangeLog]                 [xml] NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[StateProvinceXID]          [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_StateProvince_StateProvinceName_CountrySID]
		UNIQUE
		NONCLUSTERED
		([StateProvinceName], [CountrySID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_StateProvince_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_StateProvince]
		PRIMARY KEY
		CLUSTERED
		([StateProvinceSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the State Province table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'CONSTRAINT', N'pk_StateProvince'
GO
ALTER TABLE [dbo].[StateProvince]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_StateProvince]
	CHECK
	([dbo].[fStateProvince#Check]([StateProvinceSID],[StateProvinceName],[StateProvinceCode],[CountrySID],[ISONumber],[IsDisplayed],[IsDefault],[IsActive],[IsAdminReviewRequired],[StateProvinceXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[StateProvince]
CHECK CONSTRAINT [ck_StateProvince]
GO
ALTER TABLE [dbo].[StateProvince]
	ADD
	CONSTRAINT [df_StateProvince_IsDisplayed]
	DEFAULT ((1)) FOR [IsDisplayed]
GO
ALTER TABLE [dbo].[StateProvince]
	ADD
	CONSTRAINT [df_StateProvince_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[StateProvince]
	ADD
	CONSTRAINT [df_StateProvince_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[StateProvince]
	ADD
	CONSTRAINT [df_StateProvince_IsAdminReviewRequired]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAdminReviewRequired]
GO
ALTER TABLE [dbo].[StateProvince]
	ADD
	CONSTRAINT [df_StateProvince_ChangeLog]
	DEFAULT (CONVERT([xml],'<Changes />')) FOR [ChangeLog]
GO
ALTER TABLE [dbo].[StateProvince]
	ADD
	CONSTRAINT [df_StateProvince_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[StateProvince]
	ADD
	CONSTRAINT [df_StateProvince_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[StateProvince]
	ADD
	CONSTRAINT [df_StateProvince_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[StateProvince]
	ADD
	CONSTRAINT [df_StateProvince_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[StateProvince]
	ADD
	CONSTRAINT [df_StateProvince_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[StateProvince]
	ADD
	CONSTRAINT [df_StateProvince_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[StateProvince]
	WITH CHECK
	ADD CONSTRAINT [fk_StateProvince_Country_CountrySID]
	FOREIGN KEY ([CountrySID]) REFERENCES [dbo].[Country] ([CountrySID])
ALTER TABLE [dbo].[StateProvince]
	CHECK CONSTRAINT [fk_StateProvince_Country_CountrySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the country system ID column in the State Province table match a country system ID in the Country table. It also ensures that records in the Country table cannot be deleted if matching child records exist in State Province. Finally, the constraint blocks changes to the value of the country system ID column in the Country if matching child records exist in State Province.', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'CONSTRAINT', N'fk_StateProvince_Country_CountrySID'
GO
CREATE NONCLUSTERED INDEX [ix_StateProvince_CountrySID_StateProvinceSID]
	ON [dbo].[StateProvince] ([CountrySID], [StateProvinceSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Country SID foreign key column and avoids row contention on (parent) Country updates', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'INDEX', N'ix_StateProvince_CountrySID_StateProvinceSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_StateProvince_CountrySID_IsDefault]
	ON [dbo].[StateProvince] ([CountrySID], [IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default State Province for each Country SID', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'INDEX', N'ux_StateProvince_CountrySID_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_StateProvince_LegacyKey]
	ON [dbo].[StateProvince] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'INDEX', N'ux_StateProvince_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Records the list of states or provinces for a country. The application ships with the table populated for major western countries. If a country does not use states or provinces, a placeholder row is still required in the table because the State/Province FK in the City table is mandatory (simplifies reporting). Set the "Is Displayed" bit on placeholder State/Province records OFF. Based on that bit, the names of placeholder State/Provinces are eliminated from addresses. Setting the Inactive bit ON removes the record from drop-down pick lists in the application where deletion would violate RI.', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the state province assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'StateProvinceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the state province to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'StateProvinceName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this state province', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number to refer to the state or province using a coding standard - e.g. the  ISO 3166 standard for principal subdivisions of countries', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'ISONumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default state province to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this state province record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added through conversion or an address entered online)', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'IsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'History of changes of audit interest made to the record', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'ChangeLog'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the state province | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'StateProvinceXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the state province | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this state province record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the state province | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the state province record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the state province record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "State Province Name + Country SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'CONSTRAINT', N'uk_StateProvince_StateProvinceName_CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'CONSTRAINT', N'uk_StateProvince_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_StateProvince_ChangeLog]
	ON [dbo].[StateProvince] ([ChangeLog])
	WITH ( FILLFACTOR = 90)
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Change Log (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'StateProvince', 'INDEX', N'xp_StateProvince_ChangeLog'
GO
ALTER TABLE [dbo].[StateProvince] SET (LOCK_ESCALATION = TABLE)
GO
