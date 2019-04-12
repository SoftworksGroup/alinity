SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [stg].[RegistrantProfile] (
		[RegistrantProfileSID]                [int] IDENTITY(1000001, 1) NOT NULL,
		[ImportFileSID]                       [int] NOT NULL,
		[ProcessingStatusSID]                 [int] NOT NULL,
		[LastName]                            [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[FirstName]                           [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CommonName]                          [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MiddleNames]                         [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EmailAddress]                        [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[HomePhone]                           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MobilePhone]                         [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsTextMessagingEnabled]              [bit] NULL,
		[GenderLabel]                         [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NamePrefixLabel]                     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BirthDate]                           [date] NULL,
		[DeathDate]                           [date] NULL,
		[UserName]                            [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SubDomain]                           [varchar](63) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Password]                            [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress1]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress2]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress3]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CityName]                            [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StateProvinceName]                   [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PostalCode]                          [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CountryName]                         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RegionLabel]                         [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RegistrantNo]                        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PersonGroupLabel1]                   [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PersonGroupTitle1]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PersonGroupIsAdministrator1]         [bit] NULL,
		[PersonGroupEffectiveDate1]           [date] NULL,
		[PersonGroupExpiryDate1]              [date] NULL,
		[PersonGroupLabel2]                   [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PersonGroupTitle2]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PersonGroupIsAdministrator2]         [bit] NULL,
		[PersonGroupEffectiveDate2]           [date] NULL,
		[PersonGroupExpiryDate2]              [date] NULL,
		[PersonGroupLabel3]                   [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PersonGroupTitle3]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PersonGroupIsAdministrator3]         [bit] NULL,
		[PersonGroupEffectiveDate3]           [date] NULL,
		[PersonGroupExpiryDate3]              [date] NULL,
		[PersonGroupLabel4]                   [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PersonGroupTitle4]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PersonGroupIsAdministrator4]         [bit] NULL,
		[PersonGroupEffectiveDate4]           [date] NULL,
		[PersonGroupExpiryDate4]              [date] NULL,
		[PersonGroupLabel5]                   [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PersonGroupTitle5]                   [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PersonGroupIsAdministrator5]         [bit] NULL,
		[PersonGroupEffectiveDate5]           [date] NULL,
		[PersonGroupExpiryDate5]              [date] NULL,
		[PracticeRegisterLabel]               [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PracticeRegisterSectionLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RegistrationEffectiveDate]           [date] NULL,
		[QualifyingCredentialLabel]           [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[QualifyingCredentialOrgLabel]        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[QualifyingProgramName]               [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[QualifyingProgramStartDate]          [date] NULL,
		[QualifyingProgramCompletionDate]     [date] NULL,
		[QualifyingFieldOfStudyName]          [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialLabel1]                    [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialOrgLabel1]                 [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialProgramName1]              [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialFieldOfStudyName1]         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialEffectiveDate1]            [date] NULL,
		[CredentialExpiryDate1]               [date] NULL,
		[CredentialLabel2]                    [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialOrgLabel2]                 [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialProgramName2]              [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialFieldOfStudyName2]         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialEffectiveDate2]            [date] NULL,
		[CredentialExpiryDate2]               [date] NULL,
		[CredentialLabel3]                    [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialOrgLabel3]                 [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialProgramName3]              [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialFieldOfStudyName3]         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialEffectiveDate3]            [date] NULL,
		[CredentialExpiryDate3]               [date] NULL,
		[CredentialLabel4]                    [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialOrgLabel4]                 [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialProgramName4]              [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialFieldOfStudyName4]         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialEffectiveDate4]            [date] NULL,
		[CredentialExpiryDate4]               [date] NULL,
		[CredentialLabel5]                    [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialOrgLabel5]                 [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialProgramName5]              [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialFieldOfStudyName5]         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialEffectiveDate5]            [date] NULL,
		[CredentialExpiryDate5]               [date] NULL,
		[CredentialLabel6]                    [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialOrgLabel6]                 [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialProgramName6]              [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialFieldOfStudyName6]         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialEffectiveDate6]            [date] NULL,
		[CredentialExpiryDate6]               [date] NULL,
		[CredentialLabel7]                    [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialOrgLabel7]                 [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialProgramName7]              [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialFieldOfStudyName7]         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialEffectiveDate7]            [date] NULL,
		[CredentialExpiryDate7]               [date] NULL,
		[CredentialLabel8]                    [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialOrgLabel8]                 [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialProgramName8]              [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialFieldOfStudyName8]         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialEffectiveDate8]            [date] NULL,
		[CredentialExpiryDate8]               [date] NULL,
		[CredentialLabel9]                    [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialOrgLabel9]                 [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialProgramName9]              [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialFieldOfStudyName9]         [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialEffectiveDate9]            [date] NULL,
		[CredentialExpiryDate9]               [date] NULL,
		[PersonSID]                           [int] NULL,
		[PersonEmailAddressSID]               [int] NULL,
		[ApplicationUserSID]                  [int] NULL,
		[PersonMailingAddressSID]             [int] NULL,
		[RegionSID]                           [int] NULL,
		[NamePrefixSID]                       [int] NULL,
		[GenderSID]                           [int] NULL,
		[CitySID]                             [int] NULL,
		[StateProvinceSID]                    [int] NULL,
		[CountrySID]                          [int] NULL,
		[RegistrantSID]                       [int] NULL,
		[ProcessingComments]                  [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]                  [xml] NULL,
		[RegistrantProfileXID]                [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                           [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                           [bit] NOT NULL,
		[CreateUser]                          [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                          [datetimeoffset](7) NOT NULL,
		[UpdateUser]                          [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                          [datetimeoffset](7) NOT NULL,
		[RowGUID]                             [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                            [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantProfile_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantProfile]
		PRIMARY KEY
		CLUSTERED
		([RegistrantProfileSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Profile table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'CONSTRAINT', N'pk_RegistrantProfile'
GO
ALTER TABLE [stg].[RegistrantProfile]
	ADD
	CONSTRAINT [df_RegistrantProfile_IsTextMessagingEnabled]
	DEFAULT ((0)) FOR [IsTextMessagingEnabled]
GO
ALTER TABLE [stg].[RegistrantProfile]
	ADD
	CONSTRAINT [df_RegistrantProfile_PersonGroupIsAdministrator1]
	DEFAULT ((0)) FOR [PersonGroupIsAdministrator1]
GO
ALTER TABLE [stg].[RegistrantProfile]
	ADD
	CONSTRAINT [df_RegistrantProfile_PersonGroupIsAdministrator2]
	DEFAULT ((0)) FOR [PersonGroupIsAdministrator2]
GO
ALTER TABLE [stg].[RegistrantProfile]
	ADD
	CONSTRAINT [df_RegistrantProfile_PersonGroupIsAdministrator3]
	DEFAULT ((0)) FOR [PersonGroupIsAdministrator3]
GO
ALTER TABLE [stg].[RegistrantProfile]
	ADD
	CONSTRAINT [df_RegistrantProfile_PersonGroupIsAdministrator4]
	DEFAULT ((0)) FOR [PersonGroupIsAdministrator4]
GO
ALTER TABLE [stg].[RegistrantProfile]
	ADD
	CONSTRAINT [df_RegistrantProfile_PersonGroupIsAdministrator5]
	DEFAULT ((0)) FOR [PersonGroupIsAdministrator5]
GO
ALTER TABLE [stg].[RegistrantProfile]
	ADD
	CONSTRAINT [df_RegistrantProfile_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [stg].[RegistrantProfile]
	ADD
	CONSTRAINT [df_RegistrantProfile_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [stg].[RegistrantProfile]
	ADD
	CONSTRAINT [df_RegistrantProfile_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [stg].[RegistrantProfile]
	ADD
	CONSTRAINT [df_RegistrantProfile_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [stg].[RegistrantProfile]
	ADD
	CONSTRAINT [df_RegistrantProfile_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [stg].[RegistrantProfile]
	ADD
	CONSTRAINT [df_RegistrantProfile_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [stg].[RegistrantProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantProfile_SF_ImportFile_ImportFileSID]
	FOREIGN KEY ([ImportFileSID]) REFERENCES [sf].[ImportFile] ([ImportFileSID])
	ON DELETE CASCADE
ALTER TABLE [stg].[RegistrantProfile]
	CHECK CONSTRAINT [fk_RegistrantProfile_SF_ImportFile_ImportFileSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the import file system ID column in the Registrant Profile table match a import file system ID in the Import File table. It also ensures that when a record in the Import File table is deleted, matching child records in the Registrant Profile table are deleted as well. Finally, the constraint blocks changes to the value of the import file system ID column in the Import File if matching child records exist in Registrant Profile.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'CONSTRAINT', N'fk_RegistrantProfile_SF_ImportFile_ImportFileSID'
GO
ALTER TABLE [stg].[RegistrantProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantProfile_SF_PersonEmailAddress_PersonEmailAddressSID]
	FOREIGN KEY ([PersonEmailAddressSID]) REFERENCES [sf].[PersonEmailAddress] ([PersonEmailAddressSID])
ALTER TABLE [stg].[RegistrantProfile]
	CHECK CONSTRAINT [fk_RegistrantProfile_SF_PersonEmailAddress_PersonEmailAddressSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person email address system ID column in the Registrant Profile table match a person email address system ID in the Person Email Address table. It also ensures that records in the Person Email Address table cannot be deleted if matching child records exist in Registrant Profile. Finally, the constraint blocks changes to the value of the person email address system ID column in the Person Email Address if matching child records exist in Registrant Profile.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'CONSTRAINT', N'fk_RegistrantProfile_SF_PersonEmailAddress_PersonEmailAddressSID'
GO
ALTER TABLE [stg].[RegistrantProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantProfile_SF_ProcessingStatus_ProcessingStatusSID]
	FOREIGN KEY ([ProcessingStatusSID]) REFERENCES [sf].[ProcessingStatus] ([ProcessingStatusSID])
ALTER TABLE [stg].[RegistrantProfile]
	CHECK CONSTRAINT [fk_RegistrantProfile_SF_ProcessingStatus_ProcessingStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the processing status system ID column in the Registrant Profile table match a processing status system ID in the Processing Status table. It also ensures that records in the Processing Status table cannot be deleted if matching child records exist in Registrant Profile. Finally, the constraint blocks changes to the value of the processing status system ID column in the Processing Status if matching child records exist in Registrant Profile.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'CONSTRAINT', N'fk_RegistrantProfile_SF_ProcessingStatus_ProcessingStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantProfile_EmailAddress]
	ON [stg].[RegistrantProfile] ([EmailAddress])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Registrant Profile searches based on the Email Address column', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'INDEX', N'ix_RegistrantProfile_EmailAddress'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantProfile_ImportFileSID_RegistrantProfileSID]
	ON [stg].[RegistrantProfile] ([ImportFileSID], [RegistrantProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Import File SID foreign key column and avoids row contention on (parent) Import File updates', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'INDEX', N'ix_RegistrantProfile_ImportFileSID_RegistrantProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantProfile_LastName_FirstName_MiddleNames_ImportFileSID]
	ON [stg].[RegistrantProfile] ([LastName], [FirstName], [MiddleNames], [ImportFileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Registrant Profile searches based on the Last Name + First Name + Middle Names + Import File SID columns', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'INDEX', N'ix_RegistrantProfile_LastName_FirstName_MiddleNames_ImportFileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantProfile_PersonEmailAddressSID_RegistrantProfileSID]
	ON [stg].[RegistrantProfile] ([PersonEmailAddressSID], [RegistrantProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person Email Address SID foreign key column and avoids row contention on (parent) Person Email Address updates', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'INDEX', N'ix_RegistrantProfile_PersonEmailAddressSID_RegistrantProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantProfile_ProcessingStatusSID_RegistrantProfileSID]
	ON [stg].[RegistrantProfile] ([ProcessingStatusSID], [RegistrantProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Processing Status SID foreign key column and avoids row contention on (parent) Processing Status updates', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'INDEX', N'ix_RegistrantProfile_ProcessingStatusSID_RegistrantProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantProfile_RegistrantNo]
	ON [stg].[RegistrantProfile] ([RegistrantNo])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Registrant Profile searches based on the Registrant No column', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'INDEX', N'ix_RegistrantProfile_RegistrantNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is used as the interim target for importing new registrant records.  The registrant records can be imported into the system from common text file formats like CSV.  The content is loaded into this staging table for validation and for processing into the main tables of the system including: Person, Registrant, Mailing Address, Registrant-Credential, and Person Groups. Most columns in the table can be left blank to support a wide range of import scenarios. Minimally the name and email values are required to create records.  The table format supports importing currently registered members, past members, and new graduates who need to be added to the Applicant register.  Importing records through the table is dependent on master table records already being defined in the system including Organization and Credential master records.  The key columns at the end of the table are used during processing to establish links to master table records when the data is copied into the main (dbo) tables.  Foreign keys are not established from this staging table to avoid complicating deletion of master table records.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant profile assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'RegistrantProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The import file assigned to this registrant profile', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'ImportFileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the registrant profile', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'ProcessingStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person email address assigned to this registrant profile', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'PersonEmailAddressSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant profile | Forms customization is required to access extended XML content', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'RegistrantProfileXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant profile record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant profile record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant profile record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'stg', 'TABLE', N'RegistrantProfile', 'CONSTRAINT', N'uk_RegistrantProfile_RowGUID'
GO
ALTER TABLE [stg].[RegistrantProfile] SET (LOCK_ESCALATION = TABLE)
GO
