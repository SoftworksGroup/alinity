SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Country] (
		[CountrySID]                  [int] IDENTITY(1000001, 1) NOT NULL,
		[CountryName]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ISOA2]                       [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ISOA3]                       [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ISONumber]                   [smallint] NULL,
		[IsStateProvinceRequired]     [bit] NOT NULL,
		[IsDefault]                   [bit] NOT NULL,
		[IsActive]                    [bit] NOT NULL,
		[UserDefinedColumns]          [xml] NULL,
		[CountryXID]                  [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                   [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                   [bit] NOT NULL,
		[CreateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                  [datetimeoffset](7) NOT NULL,
		[UpdateUser]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                  [datetimeoffset](7) NOT NULL,
		[RowGUID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                    [timestamp] NOT NULL,
		CONSTRAINT [uk_Country_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Country_CountryName]
		UNIQUE
		NONCLUSTERED
		([CountryName])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Country]
		PRIMARY KEY
		CLUSTERED
		([CountrySID])
	WITH FILLFACTOR=90
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Country table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'CONSTRAINT', N'pk_Country'
GO
ALTER TABLE [dbo].[Country]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Country]
	CHECK
	([dbo].[fCountry#Check]([CountrySID],[CountryName],[ISOA2],[ISOA3],[ISONumber],[IsStateProvinceRequired],[IsDefault],[IsActive],[CountryXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Country]
CHECK CONSTRAINT [ck_Country]
GO
ALTER TABLE [dbo].[Country]
	ADD
	CONSTRAINT [df_Country_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Country]
	ADD
	CONSTRAINT [df_Country_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Country]
	ADD
	CONSTRAINT [df_Country_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Country]
	ADD
	CONSTRAINT [df_Country_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Country]
	ADD
	CONSTRAINT [df_Country_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Country]
	ADD
	CONSTRAINT [df_Country_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Country]
	ADD
	CONSTRAINT [df_Country_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[Country]
	ADD
	CONSTRAINT [df_Country_IsStateProvinceRequired]
	DEFAULT ((0)) FOR [IsStateProvinceRequired]
GO
ALTER TABLE [dbo].[Country]
	ADD
	CONSTRAINT [df_Country_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Country_IsDefault]
	ON [dbo].[Country] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default Country', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'INDEX', N'ux_Country_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Country_LegacyKey]
	ON [dbo].[Country] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'INDEX', N'ux_Country_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the country assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the country to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'CountryName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A 2-letter abbreviation to refer to the country using the ISO 3166 coding standard ', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'ISOA2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A 3-letter abbreviation to refer to the country using the ISO 3166 coding standard ', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'ISOA3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number to refer to the country using the ISO 3166 coding standard (this is a 3 digit number)', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'ISONumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default country to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this country record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the country | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'CountryXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the country | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this country record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the country | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the country record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the country record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'CONSTRAINT', N'uk_Country_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Country Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Country', 'CONSTRAINT', N'uk_Country_CountryName'
GO
ALTER TABLE [dbo].[Country] SET (LOCK_ESCALATION = TABLE)
GO
