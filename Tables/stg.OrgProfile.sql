SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [stg].[OrgProfile] (
		[OrgProfileSID]              [int] IDENTITY(1000001, 1) NOT NULL,
		[ProcessingStatusSID]        [int] NOT NULL,
		[SourceFileName]             [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[OrgName]                    [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OrgLabel]                   [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EmailAddress]               [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress1]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress2]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress3]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CityName]                   [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StateProvinceName]          [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PostalCode]                 [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CountryName]                [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RegionName]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Phone]                      [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Fax]                        [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[WebSite]                    [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Comments]                   [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LastVerifiedTime]           [datetimeoffset](7) NULL,
		[IsEmployer]                 [bit] NULL,
		[IsEducationInstitution]     [bit] NULL,
		[IsActive]                   [bit] NOT NULL,
		[ParentOrgProfileSID]        [int] NULL,
		[CitySID]                    [int] NULL,
		[StateProvinceSID]           [int] NULL,
		[CountrySID]                 [int] NULL,
		[RegionSID]                  [int] NULL,
		[ProcessingComments]         [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]         [xml] NULL,
		[OrgProfileXID]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_OrgProfile_OrgLabel]
		UNIQUE
		NONCLUSTERED
		([OrgLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_OrgProfile_OrgName]
		UNIQUE
		NONCLUSTERED
		([OrgName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_OrgProfile_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_OrgProfile]
		PRIMARY KEY
		CLUSTERED
		([OrgProfileSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Org Profile table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'CONSTRAINT', N'pk_OrgProfile'
GO
ALTER TABLE [stg].[OrgProfile]
	ADD
	CONSTRAINT [df_OrgProfile_IsEducationInstitution]
	DEFAULT (CONVERT([bit],(0))) FOR [IsEducationInstitution]
GO
ALTER TABLE [stg].[OrgProfile]
	ADD
	CONSTRAINT [df_OrgProfile_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [stg].[OrgProfile]
	ADD
	CONSTRAINT [df_OrgProfile_IsEmployer]
	DEFAULT (CONVERT([bit],(0))) FOR [IsEmployer]
GO
ALTER TABLE [stg].[OrgProfile]
	ADD
	CONSTRAINT [df_OrgProfile_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [stg].[OrgProfile]
	ADD
	CONSTRAINT [df_OrgProfile_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [stg].[OrgProfile]
	ADD
	CONSTRAINT [df_OrgProfile_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [stg].[OrgProfile]
	ADD
	CONSTRAINT [df_OrgProfile_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [stg].[OrgProfile]
	ADD
	CONSTRAINT [df_OrgProfile_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [stg].[OrgProfile]
	ADD
	CONSTRAINT [df_OrgProfile_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [stg].[OrgProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_OrgProfile_SF_ProcessingStatus_ProcessingStatusSID]
	FOREIGN KEY ([ProcessingStatusSID]) REFERENCES [sf].[ProcessingStatus] ([ProcessingStatusSID])
ALTER TABLE [stg].[OrgProfile]
	CHECK CONSTRAINT [fk_OrgProfile_SF_ProcessingStatus_ProcessingStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the processing status system ID column in the Org Profile table match a processing status system ID in the Processing Status table. It also ensures that records in the Processing Status table cannot be deleted if matching child records exist in Org Profile. Finally, the constraint blocks changes to the value of the processing status system ID column in the Processing Status if matching child records exist in Org Profile.', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'CONSTRAINT', N'fk_OrgProfile_SF_ProcessingStatus_ProcessingStatusSID'
GO
CREATE NONCLUSTERED INDEX [ix_OrgProfile_ProcessingStatusSID_OrgProfileSID]
	ON [stg].[OrgProfile] ([ProcessingStatusSID], [OrgProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Processing Status SID foreign key column and avoids row contention on (parent) Processing Status updates', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'INDEX', N'ix_OrgProfile_ProcessingStatusSID_OrgProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Describes an Organization in the system. | A record is created in the system for each organization.  As a general rule in Alinity, an organization should not be an individual, but the entity to which a person is a member.', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the org profile assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'OrgProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the org profile', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'ProcessingStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the file this record was obtained from on the end-user''s system | The full path and filename can be provided.  This value can be used to find all ContactProfile records imported in a batch if the file name is changed for each upload.', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'SourceFileName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the org to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'OrgName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the org to present in lists and look ups (must be unique)', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'OrgLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The main email address of the organization', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'EmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The first line of the street address', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'StreetAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The second line of the street address', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'StreetAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The third line of the street address', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'StreetAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the state or province where this person lives', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'StateProvinceName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The postal or zip code of the organization', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'PostalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The phone number for the organization.', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'Phone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The fax number for the organization.', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'Fax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Additional comments or notes related to the organization.', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'Comments'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last the time organization was verified to be active. When applicants enter new organization this value will be null until it is verified by an administrator.', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'LastVerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this organization should be included in the list of employers for application and renewal forms (only included when Active).', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'IsEmployer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this organization should be included in the list of educational institutions (issuer of credentials) for application and renewal forms (only included when Active).', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'IsEducationInstitution'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this org profile record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'ParentOrgProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this org is in', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'CitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this org', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A log of errors or warnings encountered when processing the record', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'ProcessingComments'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the org profile | Forms customization is required to access extended XML content', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'OrgProfileXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the org profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this org profile record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the org profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the org profile record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org profile record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Org Label column is not duplicated', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'CONSTRAINT', N'uk_OrgProfile_OrgLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Org Name column is not duplicated', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'CONSTRAINT', N'uk_OrgProfile_OrgName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'stg', 'TABLE', N'OrgProfile', 'CONSTRAINT', N'uk_OrgProfile_RowGUID'
GO
ALTER TABLE [stg].[OrgProfile] SET (LOCK_ESCALATION = TABLE)
GO
