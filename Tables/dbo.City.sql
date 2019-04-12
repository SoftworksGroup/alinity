SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[City] (
		[CitySID]                   [int] IDENTITY(1000001, 1) NOT NULL,
		[CityName]                  [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[StateProvinceSID]          [int] NOT NULL,
		[IsDefault]                 [bit] NOT NULL,
		[IsActive]                  [bit] NOT NULL,
		[IsAdminReviewRequired]     [bit] NOT NULL,
		[ChangeLog]                 [xml] NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[CityXID]                   [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_City_CityName_StateProvinceSID]
		UNIQUE
		NONCLUSTERED
		([CityName], [StateProvinceSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_City_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_City]
		PRIMARY KEY
		CLUSTERED
		([CitySID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the City table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'City', 'CONSTRAINT', N'pk_City'
GO
ALTER TABLE [dbo].[City]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_City]
	CHECK
	([dbo].[fCity#Check]([CitySID],[CityName],[StateProvinceSID],[IsDefault],[IsActive],[IsAdminReviewRequired],[CityXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[City]
CHECK CONSTRAINT [ck_City]
GO
ALTER TABLE [dbo].[City]
	ADD
	CONSTRAINT [df_City_IsDefault]
	DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[City]
	ADD
	CONSTRAINT [df_City_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[City]
	ADD
	CONSTRAINT [df_City_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[City]
	ADD
	CONSTRAINT [df_City_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[City]
	ADD
	CONSTRAINT [df_City_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[City]
	ADD
	CONSTRAINT [df_City_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[City]
	ADD
	CONSTRAINT [df_City_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[City]
	ADD
	CONSTRAINT [df_City_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[City]
	ADD
	CONSTRAINT [df_City_ChangeLog]
	DEFAULT (CONVERT([xml],'<Changes />')) FOR [ChangeLog]
GO
ALTER TABLE [dbo].[City]
	ADD
	CONSTRAINT [df_City_IsAdminReviewRequired]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAdminReviewRequired]
GO
ALTER TABLE [dbo].[City]
	WITH CHECK
	ADD CONSTRAINT [fk_City_StateProvince_StateProvinceSID]
	FOREIGN KEY ([StateProvinceSID]) REFERENCES [dbo].[StateProvince] ([StateProvinceSID])
ALTER TABLE [dbo].[City]
	CHECK CONSTRAINT [fk_City_StateProvince_StateProvinceSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the state province system ID column in the City table match a state province system ID in the State Province table. It also ensures that records in the State Province table cannot be deleted if matching child records exist in City. Finally, the constraint blocks changes to the value of the state province system ID column in the State Province if matching child records exist in City.', 'SCHEMA', N'dbo', 'TABLE', N'City', 'CONSTRAINT', N'fk_City_StateProvince_StateProvinceSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_City_IsDefault]
	ON [dbo].[City] ([IsDefault])
	WHERE (([IsDefault]=(1)))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure that only 1 record is marked as the default City', 'SCHEMA', N'dbo', 'TABLE', N'City', 'INDEX', N'ux_City_IsDefault'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_City_LegacyKey]
	ON [dbo].[City] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'City', 'INDEX', N'ux_City_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_City_StateProvinceSID_CitySID]
	ON [dbo].[City] ([StateProvinceSID], [CitySID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the State Province SID foreign key column and avoids row contention on (parent) State Province updates', 'SCHEMA', N'dbo', 'TABLE', N'City', 'INDEX', N'ix_City_StateProvinceSID_CitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Contains the list of municipalities (could by towns, villages, hamlets, etc.) used on addresses. The application ships with the table populated for major cities. Note that if a city name is used in more than one State Province, a city record is required for each. Setting the Inactive bit ON removes the record from drop-down pick lists in the application where deletion would violate RI.', 'SCHEMA', N'dbo', 'TABLE', N'City', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the city assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'CitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'CityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The state province this city is in', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'StateProvinceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default city to assign when new records are added', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this city record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added through conversion or an address entered online)', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'IsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'History of changes of audit interest made to the record', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'ChangeLog'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the city | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'CityXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the city | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this city record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the city | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the city record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the city record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'City', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "City Name + State Province SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'City', 'CONSTRAINT', N'uk_City_CityName_StateProvinceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'City', 'CONSTRAINT', N'uk_City_RowGUID'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_City_ChangeLog]
	ON [dbo].[City] ([ChangeLog])
	WITH ( FILLFACTOR = 90)
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Change Log (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'City', 'INDEX', N'xp_City_ChangeLog'
GO
ALTER TABLE [dbo].[City] SET (LOCK_ESCALATION = TABLE)
GO
