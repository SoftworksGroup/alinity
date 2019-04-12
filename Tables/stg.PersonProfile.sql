SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [stg].[PersonProfile] (
		[PersonProfileSID]                   [int] IDENTITY(1000001, 1) NOT NULL,
		[ProcessingStatusSID]                [int] NOT NULL,
		[SourceFileName]                     [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[LastName]                           [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FirstName]                          [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CommonName]                         [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MiddleNames]                        [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EmailAddress]                       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[HomePhone]                          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MobilePhone]                        [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsTextMessagingEnabled]             [bit] NULL,
		[SignatureImage]                     [varbinary](max) NULL,
		[IdentityPhoto]                      [varbinary](max) NULL,
		[GenderCode]                         [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[GenderLabel]                        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NamePrefixLabel]                    [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BirthDate]                          [date] NULL,
		[DeathDate]                          [date] NULL,
		[UserName]                           [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SubDomain]                          [varchar](63) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Password]                           [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress1]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress2]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress3]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CityName]                           [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StateProvinceName]                  [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StateProvinceCode]                  [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PostalCode]                         [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CountryName]                        [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CountryISOA3]                       [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AddressPhone]                       [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AddressFax]                         [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[AddressEffectiveTime]               [datetime] NULL,
		[RegionLabel]                        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RegionName]                         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RegistrantNo]                       [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ArchivedTime]                       [datetimeoffset](7) NULL,
		[IsOnPublicRegistry]                 [bit] NULL,
		[DirectedAuditYearCompetence]        [smallint] NULL,
		[DirectedAuditYearPracticeHours]     [smallint] NULL,
		[PersonSID]                          [int] NULL,
		[PersonEmailAddressSID]              [int] NULL,
		[ApplicationUserSID]                 [int] NULL,
		[PersonMailingAddressSID]            [int] NULL,
		[RegionSID]                          [int] NULL,
		[NamePrefixSID]                      [int] NULL,
		[GenderSID]                          [int] NULL,
		[CitySID]                            [int] NULL,
		[StateProvinceSID]                   [int] NULL,
		[CountrySID]                         [int] NULL,
		[RegistrantSID]                      [int] NULL,
		[ProcessingComments]                 [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]                 [xml] NULL,
		[PersonProfileXID]                   [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                          [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                          [bit] NOT NULL,
		[CreateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                         [datetimeoffset](7) NOT NULL,
		[UpdateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                         [datetimeoffset](7) NOT NULL,
		[RowGUID]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                           [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonProfile_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonProfile]
		PRIMARY KEY
		CLUSTERED
		([PersonProfileSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Profile table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'pk_PersonProfile'
GO
ALTER TABLE [stg].[PersonProfile]
	ADD
	CONSTRAINT [df_PersonProfile_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [stg].[PersonProfile]
	ADD
	CONSTRAINT [df_PersonProfile_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [stg].[PersonProfile]
	ADD
	CONSTRAINT [df_PersonProfile_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [stg].[PersonProfile]
	ADD
	CONSTRAINT [df_PersonProfile_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [stg].[PersonProfile]
	ADD
	CONSTRAINT [df_PersonProfile_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [stg].[PersonProfile]
	ADD
	CONSTRAINT [df_PersonProfile_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [stg].[PersonProfile]
	ADD
	CONSTRAINT [df_PersonProfile_IsOnPublicRegistry]
	DEFAULT (CONVERT([bit],(1))) FOR [IsOnPublicRegistry]
GO
ALTER TABLE [stg].[PersonProfile]
	ADD
	CONSTRAINT [df_PersonProfile_IsTextMessagingEnabled]
	DEFAULT (CONVERT([bit],(0))) FOR [IsTextMessagingEnabled]
GO
ALTER TABLE [stg].[PersonProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonProfile_DBO_StateProvince_StateProvinceSID]
	FOREIGN KEY ([StateProvinceSID]) REFERENCES [dbo].[StateProvince] ([StateProvinceSID])
ALTER TABLE [stg].[PersonProfile]
	CHECK CONSTRAINT [fk_PersonProfile_DBO_StateProvince_StateProvinceSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the state province system ID column in the Person Profile table match a state province system ID in the State Province table. It also ensures that records in the State Province table cannot be deleted if matching child records exist in Person Profile. Finally, the constraint blocks changes to the value of the state province system ID column in the State Province if matching child records exist in Person Profile.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'fk_PersonProfile_DBO_StateProvince_StateProvinceSID'
GO
ALTER TABLE [stg].[PersonProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonProfile_DBO_Country_CountrySID]
	FOREIGN KEY ([CountrySID]) REFERENCES [dbo].[Country] ([CountrySID])
ALTER TABLE [stg].[PersonProfile]
	CHECK CONSTRAINT [fk_PersonProfile_DBO_Country_CountrySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the country system ID column in the Person Profile table match a country system ID in the Country table. It also ensures that records in the Country table cannot be deleted if matching child records exist in Person Profile. Finally, the constraint blocks changes to the value of the country system ID column in the Country if matching child records exist in Person Profile.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'fk_PersonProfile_DBO_Country_CountrySID'
GO
ALTER TABLE [stg].[PersonProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonProfile_DBO_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [stg].[PersonProfile]
	CHECK CONSTRAINT [fk_PersonProfile_DBO_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Person Profile table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Person Profile. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Person Profile.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'fk_PersonProfile_DBO_Registrant_RegistrantSID'
GO
ALTER TABLE [stg].[PersonProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonProfile_DBO_PersonMailingAddress_PersonMailingAddressSID]
	FOREIGN KEY ([PersonMailingAddressSID]) REFERENCES [dbo].[PersonMailingAddress] ([PersonMailingAddressSID])
ALTER TABLE [stg].[PersonProfile]
	CHECK CONSTRAINT [fk_PersonProfile_DBO_PersonMailingAddress_PersonMailingAddressSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person mailing address system ID column in the Person Profile table match a person mailing address system ID in the Person Mailing Address table. It also ensures that records in the Person Mailing Address table cannot be deleted if matching child records exist in Person Profile. Finally, the constraint blocks changes to the value of the person mailing address system ID column in the Person Mailing Address if matching child records exist in Person Profile.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'fk_PersonProfile_DBO_PersonMailingAddress_PersonMailingAddressSID'
GO
ALTER TABLE [stg].[PersonProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonProfile_DBO_City_CitySID]
	FOREIGN KEY ([CitySID]) REFERENCES [dbo].[City] ([CitySID])
ALTER TABLE [stg].[PersonProfile]
	CHECK CONSTRAINT [fk_PersonProfile_DBO_City_CitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the city system ID column in the Person Profile table match a city system ID in the City table. It also ensures that records in the City table cannot be deleted if matching child records exist in Person Profile. Finally, the constraint blocks changes to the value of the city system ID column in the City if matching child records exist in Person Profile.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'fk_PersonProfile_DBO_City_CitySID'
GO
ALTER TABLE [stg].[PersonProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonProfile_DBO_Region_RegionSID]
	FOREIGN KEY ([RegionSID]) REFERENCES [dbo].[Region] ([RegionSID])
ALTER TABLE [stg].[PersonProfile]
	CHECK CONSTRAINT [fk_PersonProfile_DBO_Region_RegionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the region system ID column in the Person Profile table match a region system ID in the Region table. It also ensures that records in the Region table cannot be deleted if matching child records exist in Person Profile. Finally, the constraint blocks changes to the value of the region system ID column in the Region if matching child records exist in Person Profile.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'fk_PersonProfile_DBO_Region_RegionSID'
GO
ALTER TABLE [stg].[PersonProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonProfile_SF_ApplicationUser_ApplicationUserSID]
	FOREIGN KEY ([ApplicationUserSID]) REFERENCES [sf].[ApplicationUser] ([ApplicationUserSID])
ALTER TABLE [stg].[PersonProfile]
	CHECK CONSTRAINT [fk_PersonProfile_SF_ApplicationUser_ApplicationUserSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the application user system ID column in the Person Profile table match a application user system ID in the Application User table. It also ensures that records in the Application User table cannot be deleted if matching child records exist in Person Profile. Finally, the constraint blocks changes to the value of the application user system ID column in the Application User if matching child records exist in Person Profile.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'fk_PersonProfile_SF_ApplicationUser_ApplicationUserSID'
GO
ALTER TABLE [stg].[PersonProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonProfile_SF_Gender_GenderSID]
	FOREIGN KEY ([GenderSID]) REFERENCES [sf].[Gender] ([GenderSID])
ALTER TABLE [stg].[PersonProfile]
	CHECK CONSTRAINT [fk_PersonProfile_SF_Gender_GenderSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the gender system ID column in the Person Profile table match a gender system ID in the Gender table. It also ensures that records in the Gender table cannot be deleted if matching child records exist in Person Profile. Finally, the constraint blocks changes to the value of the gender system ID column in the Gender if matching child records exist in Person Profile.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'fk_PersonProfile_SF_Gender_GenderSID'
GO
ALTER TABLE [stg].[PersonProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonProfile_SF_NamePrefix_NamePrefixSID]
	FOREIGN KEY ([NamePrefixSID]) REFERENCES [sf].[NamePrefix] ([NamePrefixSID])
ALTER TABLE [stg].[PersonProfile]
	CHECK CONSTRAINT [fk_PersonProfile_SF_NamePrefix_NamePrefixSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the name prefix system ID column in the Person Profile table match a name prefix system ID in the Name Prefix table. It also ensures that records in the Name Prefix table cannot be deleted if matching child records exist in Person Profile. Finally, the constraint blocks changes to the value of the name prefix system ID column in the Name Prefix if matching child records exist in Person Profile.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'fk_PersonProfile_SF_NamePrefix_NamePrefixSID'
GO
ALTER TABLE [stg].[PersonProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonProfile_SF_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [stg].[PersonProfile]
	CHECK CONSTRAINT [fk_PersonProfile_SF_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Person Profile table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Person Profile. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Person Profile.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'fk_PersonProfile_SF_Person_PersonSID'
GO
ALTER TABLE [stg].[PersonProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonProfile_SF_PersonEmailAddress_PersonEmailAddressSID]
	FOREIGN KEY ([PersonEmailAddressSID]) REFERENCES [sf].[PersonEmailAddress] ([PersonEmailAddressSID])
ALTER TABLE [stg].[PersonProfile]
	CHECK CONSTRAINT [fk_PersonProfile_SF_PersonEmailAddress_PersonEmailAddressSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person email address system ID column in the Person Profile table match a person email address system ID in the Person Email Address table. It also ensures that records in the Person Email Address table cannot be deleted if matching child records exist in Person Profile. Finally, the constraint blocks changes to the value of the person email address system ID column in the Person Email Address if matching child records exist in Person Profile.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'fk_PersonProfile_SF_PersonEmailAddress_PersonEmailAddressSID'
GO
ALTER TABLE [stg].[PersonProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonProfile_SF_ProcessingStatus_ProcessingStatusSID]
	FOREIGN KEY ([ProcessingStatusSID]) REFERENCES [sf].[ProcessingStatus] ([ProcessingStatusSID])
ALTER TABLE [stg].[PersonProfile]
	CHECK CONSTRAINT [fk_PersonProfile_SF_ProcessingStatus_ProcessingStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the processing status system ID column in the Person Profile table match a processing status system ID in the Processing Status table. It also ensures that records in the Processing Status table cannot be deleted if matching child records exist in Person Profile. Finally, the constraint blocks changes to the value of the processing status system ID column in the Processing Status if matching child records exist in Person Profile.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'fk_PersonProfile_SF_ProcessingStatus_ProcessingStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonProfile_ApplicationUserSID_PersonProfileSID]
	ON [stg].[PersonProfile] ([ApplicationUserSID], [PersonProfileSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Application User SID foreign key column and avoids row contention on (parent) Application User updates', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'INDEX', N'ix_PersonProfile_ApplicationUserSID_PersonProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonProfile_CitySID_PersonProfileSID]
	ON [stg].[PersonProfile] ([CitySID], [PersonProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the City SID foreign key column and avoids row contention on (parent) City updates', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'INDEX', N'ix_PersonProfile_CitySID_PersonProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonProfile_CountrySID_PersonProfileSID]
	ON [stg].[PersonProfile] ([CountrySID], [PersonProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Country SID foreign key column and avoids row contention on (parent) Country updates', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'INDEX', N'ix_PersonProfile_CountrySID_PersonProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonProfile_GenderSID_PersonProfileSID]
	ON [stg].[PersonProfile] ([GenderSID], [PersonProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Gender SID foreign key column and avoids row contention on (parent) Gender updates', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'INDEX', N'ix_PersonProfile_GenderSID_PersonProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonProfile_NamePrefixSID_PersonProfileSID]
	ON [stg].[PersonProfile] ([NamePrefixSID], [PersonProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Name Prefix SID foreign key column and avoids row contention on (parent) Name Prefix updates', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'INDEX', N'ix_PersonProfile_NamePrefixSID_PersonProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonProfile_PersonEmailAddressSID_PersonProfileSID]
	ON [stg].[PersonProfile] ([PersonEmailAddressSID], [PersonProfileSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person Email Address SID foreign key column and avoids row contention on (parent) Person Email Address updates', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'INDEX', N'ix_PersonProfile_PersonEmailAddressSID_PersonProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonProfile_PersonMailingAddressSID_PersonProfileSID]
	ON [stg].[PersonProfile] ([PersonMailingAddressSID], [PersonProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person Mailing Address SID foreign key column and avoids row contention on (parent) Person Mailing Address updates', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'INDEX', N'ix_PersonProfile_PersonMailingAddressSID_PersonProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonProfile_PersonSID_PersonProfileSID]
	ON [stg].[PersonProfile] ([PersonSID], [PersonProfileSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'INDEX', N'ix_PersonProfile_PersonSID_PersonProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonProfile_ProcessingStatusSID_PersonProfileSID]
	ON [stg].[PersonProfile] ([ProcessingStatusSID], [PersonProfileSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Processing Status SID foreign key column and avoids row contention on (parent) Processing Status updates', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'INDEX', N'ix_PersonProfile_ProcessingStatusSID_PersonProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonProfile_RegionSID_PersonProfileSID]
	ON [stg].[PersonProfile] ([RegionSID], [PersonProfileSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Region SID foreign key column and avoids row contention on (parent) Region updates', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'INDEX', N'ix_PersonProfile_RegionSID_PersonProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonProfile_RegistrantSID_PersonProfileSID]
	ON [stg].[PersonProfile] ([RegistrantSID], [PersonProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'INDEX', N'ix_PersonProfile_RegistrantSID_PersonProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonProfile_StateProvinceSID_PersonProfileSID]
	ON [stg].[PersonProfile] ([StateProvinceSID], [PersonProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the State Province SID foreign key column and avoids row contention on (parent) State Province updates', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'INDEX', N'ix_PersonProfile_StateProvinceSID_PersonProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stages ContactProfile records for import.  The table supports importing ContactProfiles from a known file format, (similar to CSV files that can be exported from Microsoft Outlook), and then allows that content to be validated by the application and applied to the various tables in the main (dbo) database schema. The table supports name, phone, email and mailing address components of the ContactProfile’s profile.  For advanced users, a collection of Group names can be specified for the ContactProfile.  When the record is imported, the ContactProfile is automatically given membership in the groups identified on the record. Note that all users are automatically given membership in the “default group” if one is defined.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person profile assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'PersonProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the person profile', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'ProcessingStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the file this record was obtained from on the end-user''s system | The full path and filename can be provided.  This value can be used to find all ContactProfile records imported in a batch if the file name is changed for each upload.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'SourceFileName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Surname or family name of the person', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Given name of first name of the person', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Middle name or middle names, if known, of the person - may also be used for middle initial(s)', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Email address for the person - must be unique - shared email addresses are not allowed | This value does not have to be unique in this table but is validated for uniqueness in the Person Email Address table prior to import', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'EmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The home phone number of the person', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'HomePhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The cellular phone number of the person', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'MobilePhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sex of the person - may be entered as any valid code or label as stored in the Gender master table', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'GenderLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A salutation to put with the person''s name - e.g. "Ms.", "Dr.", "Mr." etc.  -  value is checked against Name Prefix master table', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'NamePrefixLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person''s date of birth', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'BirthDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The first line of the preferred mail address for this person', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'StreetAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The second line of the preferred mail address for this person (do not enter City or State here)', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'StreetAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The third line of the preferred mail address for this person (do not enter City or State here)', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'StreetAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the city where this person lives', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'CityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the state or province where this person lives', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'StateProvinceName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The zip code or postal code for the mailing address provided', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'PostalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'DirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'DirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this profile is based on', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person email address assigned to this person profile', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'PersonEmailAddressSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this person profile', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person mailing address assigned to this person profile', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'PersonMailingAddressSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this person profile', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person profile', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person profile is assigned', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this person profile is in', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'CitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The state province this person profile is in', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'StateProvinceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this person profile', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant assigned to this person profile', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A log of errors or warnings encountered when processing the record', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'ProcessingComments'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person profile | Forms customization is required to access extended XML content', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'PersonProfileXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person profile record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person profile record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person profile record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'stg', 'TABLE', N'PersonProfile', 'CONSTRAINT', N'uk_PersonProfile_RowGUID'
GO
ALTER TABLE [stg].[PersonProfile] SET (LOCK_ESCALATION = TABLE)
GO
