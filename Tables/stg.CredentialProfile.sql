SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [stg].[CredentialProfile] (
		[CredentialProfileSID]            [int] IDENTITY(1000001, 1) NOT NULL,
		[ProcessingStatusSID]             [int] NOT NULL,
		[SourceFileName]                  [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ProgramStartDate]                [date] NULL,
		[ProgramTargetCompletionDate]     [date] NULL,
		[EffectiveTime]                   [date] NULL,
		[IsDisplayedOnLicense]            [bit] NULL,
		[ProgramName]                     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OrgName]                         [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OrgLabel]                        [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress1]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress2]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreedAddress3]                  [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CityName]                        [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StateProvinceName]               [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StateProvinceCode]               [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PostalCode]                      [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CountryName]                     [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CountryISOA3]                    [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Phone]                           [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Fax]                             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[WebSite]                         [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RegionLabel]                     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RegionName]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CredentialTypeLabel]             [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[RegistrantSID]                   [int] NULL,
		[CredentialSID]                   [int] NULL,
		[CredentialTypeSID]               [int] NULL,
		[OrgSID]                          [int] NULL,
		[RegionSID]                       [int] NULL,
		[ProcessingComments]              [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]              [xml] NULL,
		[CredentialProfileXID]            [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                       [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                       [bit] NOT NULL,
		[CreateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                      [datetimeoffset](7) NOT NULL,
		[UpdateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                      [datetimeoffset](7) NOT NULL,
		[RowGUID]                         [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                        [timestamp] NOT NULL,
		CONSTRAINT [uk_CredentialProfile_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_CredentialProfile]
		PRIMARY KEY
		CLUSTERED
		([CredentialProfileSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Credential Profile table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'CONSTRAINT', N'pk_CredentialProfile'
GO
ALTER TABLE [stg].[CredentialProfile]
	ADD
	CONSTRAINT [df_CredentialProfile_IsDisplayedOnLicense]
	DEFAULT ((0)) FOR [IsDisplayedOnLicense]
GO
ALTER TABLE [stg].[CredentialProfile]
	ADD
	CONSTRAINT [df_CredentialProfile_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [stg].[CredentialProfile]
	ADD
	CONSTRAINT [df_CredentialProfile_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [stg].[CredentialProfile]
	ADD
	CONSTRAINT [df_CredentialProfile_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [stg].[CredentialProfile]
	ADD
	CONSTRAINT [df_CredentialProfile_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [stg].[CredentialProfile]
	ADD
	CONSTRAINT [df_CredentialProfile_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [stg].[CredentialProfile]
	ADD
	CONSTRAINT [df_CredentialProfile_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [stg].[CredentialProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_CredentialProfile_DBO_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [stg].[CredentialProfile]
	CHECK CONSTRAINT [fk_CredentialProfile_DBO_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Credential Profile table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Credential Profile. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Credential Profile.', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'CONSTRAINT', N'fk_CredentialProfile_DBO_Registrant_RegistrantSID'
GO
ALTER TABLE [stg].[CredentialProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_CredentialProfile_DBO_Credential_CredentialSID]
	FOREIGN KEY ([CredentialSID]) REFERENCES [dbo].[Credential] ([CredentialSID])
ALTER TABLE [stg].[CredentialProfile]
	CHECK CONSTRAINT [fk_CredentialProfile_DBO_Credential_CredentialSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the credential system ID column in the Credential Profile table match a credential system ID in the Credential table. It also ensures that records in the Credential table cannot be deleted if matching child records exist in Credential Profile. Finally, the constraint blocks changes to the value of the credential system ID column in the Credential if matching child records exist in Credential Profile.', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'CONSTRAINT', N'fk_CredentialProfile_DBO_Credential_CredentialSID'
GO
ALTER TABLE [stg].[CredentialProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_CredentialProfile_DBO_Region_RegionSID]
	FOREIGN KEY ([RegionSID]) REFERENCES [dbo].[Region] ([RegionSID])
ALTER TABLE [stg].[CredentialProfile]
	CHECK CONSTRAINT [fk_CredentialProfile_DBO_Region_RegionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the region system ID column in the Credential Profile table match a region system ID in the Region table. It also ensures that records in the Region table cannot be deleted if matching child records exist in Credential Profile. Finally, the constraint blocks changes to the value of the region system ID column in the Region if matching child records exist in Credential Profile.', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'CONSTRAINT', N'fk_CredentialProfile_DBO_Region_RegionSID'
GO
ALTER TABLE [stg].[CredentialProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_CredentialProfile_SF_ProcessingStatus_ProcessingStatusSID]
	FOREIGN KEY ([ProcessingStatusSID]) REFERENCES [sf].[ProcessingStatus] ([ProcessingStatusSID])
ALTER TABLE [stg].[CredentialProfile]
	CHECK CONSTRAINT [fk_CredentialProfile_SF_ProcessingStatus_ProcessingStatusSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the processing status system ID column in the Credential Profile table match a processing status system ID in the Processing Status table. It also ensures that records in the Processing Status table cannot be deleted if matching child records exist in Credential Profile. Finally, the constraint blocks changes to the value of the processing status system ID column in the Processing Status if matching child records exist in Credential Profile.', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'CONSTRAINT', N'fk_CredentialProfile_SF_ProcessingStatus_ProcessingStatusSID'
GO
ALTER TABLE [stg].[CredentialProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_CredentialProfile_DBO_Org_OrgSID]
	FOREIGN KEY ([OrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [stg].[CredentialProfile]
	CHECK CONSTRAINT [fk_CredentialProfile_DBO_Org_OrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the org system ID column in the Credential Profile table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Credential Profile. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Credential Profile.', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'CONSTRAINT', N'fk_CredentialProfile_DBO_Org_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_CredentialProfile_CredentialSID_CredentialProfileSID]
	ON [stg].[CredentialProfile] ([CredentialSID], [CredentialProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Credential SID foreign key column and avoids row contention on (parent) Credential updates', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'INDEX', N'ix_CredentialProfile_CredentialSID_CredentialProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_CredentialProfile_CredentialTypeSID_CredentialProfileSID]
	ON [stg].[CredentialProfile] ([CredentialTypeSID], [CredentialProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Credential Profile searches based on the Credential Type SID + Credential Profile SID columns', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'INDEX', N'ix_CredentialProfile_CredentialTypeSID_CredentialProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_CredentialProfile_OrgSID_CredentialProfileSID]
	ON [stg].[CredentialProfile] ([OrgSID], [CredentialProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'INDEX', N'ix_CredentialProfile_OrgSID_CredentialProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_CredentialProfile_ProcessingStatusSID_CredentialProfileSID]
	ON [stg].[CredentialProfile] ([ProcessingStatusSID], [CredentialProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Processing Status SID foreign key column and avoids row contention on (parent) Processing Status updates', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'INDEX', N'ix_CredentialProfile_ProcessingStatusSID_CredentialProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_CredentialProfile_RegionSID_CredentialProfileSID]
	ON [stg].[CredentialProfile] ([RegionSID], [CredentialProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Region SID foreign key column and avoids row contention on (parent) Region updates', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'INDEX', N'ix_CredentialProfile_RegionSID_CredentialProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_CredentialProfile_RegistrantSID_CredentialProfileSID]
	ON [stg].[CredentialProfile] ([RegistrantSID], [CredentialProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'INDEX', N'ix_CredentialProfile_RegistrantSID_CredentialProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the credential profile assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'CredentialProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the credential profile', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'ProcessingStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the file this record was obtained from on the end-user''s system | The full path and filename can be provided.  This value can be used to find all ContactProfile records imported in a batch if the file name is changed for each upload.', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'SourceFileName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the city where this person lives', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'CityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the state or province where this person lives', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'StateProvinceName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The zip code or postal code for the mailing address provided', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'PostalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant assigned to this credential profile', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The credential this profile is defined for', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'CredentialSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of credential profile', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'CredentialTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this credential profile', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this credential profile', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A log of errors or warnings encountered when processing the record', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'ProcessingComments'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the credential profile | Forms customization is required to access extended XML content', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'CredentialProfileXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the credential profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this credential profile record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the credential profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the credential profile record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the credential profile record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'stg', 'TABLE', N'CredentialProfile', 'CONSTRAINT', N'uk_CredentialProfile_RowGUID'
GO
ALTER TABLE [stg].[CredentialProfile] SET (LOCK_ESCALATION = TABLE)
GO
