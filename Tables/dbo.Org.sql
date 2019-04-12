SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Org] (
		[OrgSID]                             [int] IDENTITY(1000001, 1) NOT NULL,
		[ParentOrgSID]                       [int] NULL,
		[OrgTypeSID]                         [int] NOT NULL,
		[OrgName]                            [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[OrgLabel]                           [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[StreetAddress1]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[StreetAddress2]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[StreetAddress3]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CitySID]                            [int] NOT NULL,
		[PostalCode]                         [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[RegionSID]                          [int] NOT NULL,
		[Phone]                              [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Fax]                                [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[WebSite]                            [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EmailAddress]                       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[InsuranceOrgSID]                    [int] NULL,
		[InsurancePolicyNo]                  [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[InsuranceAmount]                    [decimal](11, 2) NULL,
		[IsEmployer]                         [bit] NOT NULL,
		[IsCredentialAuthority]              [bit] NOT NULL,
		[IsInsurer]                          [bit] NOT NULL,
		[IsInsuranceCertificateRequired]     [bit] NOT NULL,
		[IsPublic]                           [nchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Comments]                           [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TagList]                            [xml] NOT NULL,
		[IsActive]                           [bit] NOT NULL,
		[IsAdminReviewRequired]              [bit] NOT NULL,
		[LastVerifiedTime]                   [datetimeoffset](7) NULL,
		[ChangeLog]                          [xml] NOT NULL,
		[UserDefinedColumns]                 [xml] NULL,
		[OrgXID]                             [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                          [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                          [bit] NOT NULL,
		[CreateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                         [datetimeoffset](7) NOT NULL,
		[UpdateUser]                         [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                         [datetimeoffset](7) NOT NULL,
		[RowGUID]                            [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                           [timestamp] NOT NULL,
		CONSTRAINT [uk_Org_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Org_OrgName]
		UNIQUE
		NONCLUSTERED
		([OrgName])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_Org_OrgLabel]
		UNIQUE
		NONCLUSTERED
		([OrgLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Org]
		PRIMARY KEY
		CLUSTERED
		([OrgSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Org table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'CONSTRAINT', N'pk_Org'
GO
ALTER TABLE [dbo].[Org]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Org]
	CHECK
	([dbo].[fOrg#Check]([OrgSID],[ParentOrgSID],[OrgTypeSID],[OrgName],[OrgLabel],[StreetAddress1],[StreetAddress2],[StreetAddress3],[CitySID],[PostalCode],[RegionSID],[Phone],[Fax],[WebSite],[EmailAddress],[InsuranceOrgSID],[InsurancePolicyNo],[InsuranceAmount],[IsEmployer],[IsCredentialAuthority],[IsInsurer],[IsInsuranceCertificateRequired],[IsPublic],[IsActive],[IsAdminReviewRequired],[LastVerifiedTime],[OrgXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[Org]
CHECK CONSTRAINT [ck_Org]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_IsEmployer]
	DEFAULT (CONVERT([bit],(0))) FOR [IsEmployer]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_IsCredentialAuthority]
	DEFAULT (CONVERT([bit],(0))) FOR [IsCredentialAuthority]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_IsInsurer]
	DEFAULT (CONVERT([bit],(0))) FOR [IsInsurer]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_IsInsuranceCertificateRequired]
	DEFAULT (CONVERT([bit],(0))) FOR [IsInsuranceCertificateRequired]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_TagList]
	DEFAULT (CONVERT([xml],N'<Tags/>')) FOR [TagList]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_IsAdminReviewRequired]
	DEFAULT (CONVERT([bit],(0))) FOR [IsAdminReviewRequired]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_ChangeLog]
	DEFAULT (CONVERT([xml],'<Changes />')) FOR [ChangeLog]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[Org]
	ADD
	CONSTRAINT [df_Org_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[Org]
	WITH CHECK
	ADD CONSTRAINT [fk_Org_OrgType_OrgTypeSID]
	FOREIGN KEY ([OrgTypeSID]) REFERENCES [dbo].[OrgType] ([OrgTypeSID])
ALTER TABLE [dbo].[Org]
	CHECK CONSTRAINT [fk_Org_OrgType_OrgTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the org type system ID column in the Org table match a org type system ID in the Org Type table. It also ensures that records in the Org Type table cannot be deleted if matching child records exist in Org. Finally, the constraint blocks changes to the value of the org type system ID column in the Org Type if matching child records exist in Org.', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'CONSTRAINT', N'fk_Org_OrgType_OrgTypeSID'
GO
ALTER TABLE [dbo].[Org]
	WITH CHECK
	ADD CONSTRAINT [fk_Org_Region_RegionSID]
	FOREIGN KEY ([RegionSID]) REFERENCES [dbo].[Region] ([RegionSID])
ALTER TABLE [dbo].[Org]
	CHECK CONSTRAINT [fk_Org_Region_RegionSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the region system ID column in the Org table match a region system ID in the Region table. It also ensures that records in the Region table cannot be deleted if matching child records exist in Org. Finally, the constraint blocks changes to the value of the region system ID column in the Region if matching child records exist in Org.', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'CONSTRAINT', N'fk_Org_Region_RegionSID'
GO
ALTER TABLE [dbo].[Org]
	WITH CHECK
	ADD CONSTRAINT [fk_Org_City_CitySID]
	FOREIGN KEY ([CitySID]) REFERENCES [dbo].[City] ([CitySID])
ALTER TABLE [dbo].[Org]
	CHECK CONSTRAINT [fk_Org_City_CitySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the city system ID column in the Org table match a city system ID in the City table. It also ensures that records in the City table cannot be deleted if matching child records exist in Org. Finally, the constraint blocks changes to the value of the city system ID column in the City if matching child records exist in Org.', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'CONSTRAINT', N'fk_Org_City_CitySID'
GO
ALTER TABLE [dbo].[Org]
	WITH CHECK
	ADD CONSTRAINT [fk_Org_Org_ParentOrgSID]
	FOREIGN KEY ([ParentOrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [dbo].[Org]
	CHECK CONSTRAINT [fk_Org_Org_ParentOrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the parent org system ID column in the Org table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Org. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Org.', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'CONSTRAINT', N'fk_Org_Org_ParentOrgSID'
GO
ALTER TABLE [dbo].[Org]
	WITH CHECK
	ADD CONSTRAINT [fk_Org_Org_InsuranceOrgSID]
	FOREIGN KEY ([InsuranceOrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [dbo].[Org]
	CHECK CONSTRAINT [fk_Org_Org_InsuranceOrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the insurance org system ID column in the Org table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Org. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Org.', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'CONSTRAINT', N'fk_Org_Org_InsuranceOrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_Org_CitySID_OrgSID]
	ON [dbo].[Org] ([CitySID], [OrgSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the City SID foreign key column and avoids row contention on (parent) City updates', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'INDEX', N'ix_Org_CitySID_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_Org_InsuranceOrgSID_OrgSID]
	ON [dbo].[Org] ([InsuranceOrgSID], [OrgSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Insurance Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'INDEX', N'ix_Org_InsuranceOrgSID_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_Org_IsCredentialAuthority_IsActive]
	ON [dbo].[Org] ([IsCredentialAuthority], [IsActive])
	INCLUDE ([OrgSID], [OrgName], [OrgLabel], [StreetAddress1], [StreetAddress2], [StreetAddress3], [CitySID], [PostalCode])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Org searches based on the Is Credential Authority + Is Active columns', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'INDEX', N'ix_Org_IsCredentialAuthority_IsActive'
GO
CREATE NONCLUSTERED INDEX [ix_Org_IsEmployer_IsActive]
	ON [dbo].[Org] ([IsEmployer], [IsActive])
	INCLUDE ([OrgSID], [OrgName], [OrgLabel], [StreetAddress1], [StreetAddress2], [StreetAddress3], [CitySID], [PostalCode])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Org searches based on the Is Employer + Is Active columns', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'INDEX', N'ix_Org_IsEmployer_IsActive'
GO
CREATE NONCLUSTERED INDEX [ix_Org_OrgTypeSID_OrgSID]
	ON [dbo].[Org] ([OrgTypeSID], [OrgSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Org Type SID foreign key column and avoids row contention on (parent) Org Type updates', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'INDEX', N'ix_Org_OrgTypeSID_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_Org_ParentOrgSID_OrgSID]
	ON [dbo].[Org] ([ParentOrgSID], [OrgSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Parent Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'INDEX', N'ix_Org_ParentOrgSID_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_Org_RegionSID_OrgSID]
	ON [dbo].[Org] ([RegionSID], [OrgSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Region SID foreign key column and avoids row contention on (parent) Region updates', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'INDEX', N'ix_Org_RegionSID_OrgSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Org_LegacyKey]
	ON [dbo].[Org] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'INDEX', N'ux_Org_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Describes an Organization in the system. | A record is created in the system for each organization.  As a general rule in Alinity, an organization should not be an individual, but the entity to which a person is a member.', 'SCHEMA', N'dbo', 'TABLE', N'Org', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the org assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'ParentOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of org', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'OrgTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the org to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'OrgName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the org to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'OrgLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The first line of the street address', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'StreetAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The second line of the street address', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'StreetAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The third line of the street address', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'StreetAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this org is in', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'CitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The postal or zip code of the organization', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'PostalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this org', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The phone number for the organization.', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'Phone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The fax number for the organization.', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'Fax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional email address to display on the Public Directory for general inquiries to the organization', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'EmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'InsuranceOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of employers applicants/registrants can choose from on forms | This value being enabled does not necessarily mean any applicants/registrants are actively employed by the organization', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'IsEmployer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of credential authorities user choose from when adding new credentials | This value being enabled does not necessarily mean any credentials are active for the organization', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'IsCredentialAuthority'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of insurers providing coverage to members | This value being enabled does not necessarily mean any member has identified this organization as an insurer', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'IsInsurer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Applies to insurance companies only and indicates if member must provide their insurance certificate number. ', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'IsInsuranceCertificateRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Additional comments or notes related to the organization.', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'Comments'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this org record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added as a new employer through an Application or Renewal entered online) The form can be configured to block automatic approval when new employer addresses are added in the case of renewals.', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'IsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last time the information collected on the organization was verified by an administrator (de-activate the record to avoid it being referenced going forward).', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'LastVerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'History of changes of audit interest made to the record', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'ChangeLog'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the org | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'OrgXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the org | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this org record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the org | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the org record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'CONSTRAINT', N'uk_Org_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Org Name column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'CONSTRAINT', N'uk_Org_OrgName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Org Label column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'CONSTRAINT', N'uk_Org_OrgLabel'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_Org_ChangeLog]
	ON [dbo].[Org] ([ChangeLog])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Change Log (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'INDEX', N'xp_Org_ChangeLog'
GO
SET ANSI_PADDING ON
GO
CREATE PRIMARY XML INDEX [xp_Org_TagList]
	ON [dbo].[Org] ([TagList])
GO
EXEC sp_addextendedproperty N'MS_Description', N'A primary XML index to support fast parsing of the Tag List (XML) column', 'SCHEMA', N'dbo', 'TABLE', N'Org', 'INDEX', N'xp_Org_TagList'
GO
ALTER TABLE [dbo].[Org] SET (LOCK_ESCALATION = TABLE)
GO
