SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[QualifyingCredentialOrg] (
		[QualifyingCredentialOrgSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[CredentialSID]                  [int] NOT NULL,
		[OrgSID]                         [int] NOT NULL,
		[IsActive]                       [bit] NOT NULL,
		[UserDefinedColumns]             [xml] NULL,
		[QualifyingCredentialOrgXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                      [bit] NOT NULL,
		[CreateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                     [datetimeoffset](7) NOT NULL,
		[UpdateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                     [datetimeoffset](7) NOT NULL,
		[RowGUID]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                       [timestamp] NOT NULL,
		CONSTRAINT [uk_QualifyingCredentialOrg_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_QualifyingCredentialOrg_CredentialSID_OrgSID]
		UNIQUE
		NONCLUSTERED
		([CredentialSID], [OrgSID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_QualifyingCredentialOrg]
		PRIMARY KEY
		CLUSTERED
		([QualifyingCredentialOrgSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Qualifying Credential Org table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'CONSTRAINT', N'pk_QualifyingCredentialOrg'
GO
ALTER TABLE [dbo].[QualifyingCredentialOrg]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_QualifyingCredentialOrg]
	CHECK
	([dbo].[fQualifyingCredentialOrg#Check]([QualifyingCredentialOrgSID],[CredentialSID],[OrgSID],[IsActive],[QualifyingCredentialOrgXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[QualifyingCredentialOrg]
CHECK CONSTRAINT [ck_QualifyingCredentialOrg]
GO
ALTER TABLE [dbo].[QualifyingCredentialOrg]
	ADD
	CONSTRAINT [df_QualifyingCredentialOrg_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[QualifyingCredentialOrg]
	ADD
	CONSTRAINT [df_QualifyingCredentialOrg_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[QualifyingCredentialOrg]
	ADD
	CONSTRAINT [df_QualifyingCredentialOrg_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[QualifyingCredentialOrg]
	ADD
	CONSTRAINT [df_QualifyingCredentialOrg_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[QualifyingCredentialOrg]
	ADD
	CONSTRAINT [df_QualifyingCredentialOrg_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[QualifyingCredentialOrg]
	ADD
	CONSTRAINT [df_QualifyingCredentialOrg_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[QualifyingCredentialOrg]
	ADD
	CONSTRAINT [df_QualifyingCredentialOrg_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[QualifyingCredentialOrg]
	WITH CHECK
	ADD CONSTRAINT [fk_QualifyingCredentialOrg_Credential_CredentialSID]
	FOREIGN KEY ([CredentialSID]) REFERENCES [dbo].[Credential] ([CredentialSID])
ALTER TABLE [dbo].[QualifyingCredentialOrg]
	CHECK CONSTRAINT [fk_QualifyingCredentialOrg_Credential_CredentialSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the credential system ID column in the Qualifying Credential Org table match a credential system ID in the Credential table. It also ensures that records in the Credential table cannot be deleted if matching child records exist in Qualifying Credential Org. Finally, the constraint blocks changes to the value of the credential system ID column in the Credential if matching child records exist in Qualifying Credential Org.', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'CONSTRAINT', N'fk_QualifyingCredentialOrg_Credential_CredentialSID'
GO
ALTER TABLE [dbo].[QualifyingCredentialOrg]
	WITH CHECK
	ADD CONSTRAINT [fk_QualifyingCredentialOrg_Org_OrgSID]
	FOREIGN KEY ([OrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [dbo].[QualifyingCredentialOrg]
	CHECK CONSTRAINT [fk_QualifyingCredentialOrg_Org_OrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the org system ID column in the Qualifying Credential Org table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Qualifying Credential Org. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Qualifying Credential Org.', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'CONSTRAINT', N'fk_QualifyingCredentialOrg_Org_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_QualifyingCredentialOrg_CredentialSID_QualifyingCredentialOrgSID]
	ON [dbo].[QualifyingCredentialOrg] ([CredentialSID], [QualifyingCredentialOrgSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Credential SID foreign key column and avoids row contention on (parent) Credential updates', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'INDEX', N'ix_QualifyingCredentialOrg_CredentialSID_QualifyingCredentialOrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_QualifyingCredentialOrg_OrgSID_QualifyingCredentialOrgSID]
	ON [dbo].[QualifyingCredentialOrg] ([OrgSID], [QualifyingCredentialOrgSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'INDEX', N'ix_QualifyingCredentialOrg_OrgSID_QualifyingCredentialOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table defines the master list of credentials and the organizations which issue them, that qualify a registrant for their registration.  These are typically educational programs created specifically for the profession.  Some Colleges may also be interested in recording additional or alternate education that is not automatically qualifying for the registration, but these are not defined in this master list but rather, can be selected on an ad hoc basis by selecting organizations and credentials which are non-linked.', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the qualifying credential org assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'QualifyingCredentialOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the credential assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'CredentialSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the org assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this qualifying credential org record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the qualifying credential org | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'QualifyingCredentialOrgXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the qualifying credential org | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this qualifying credential org record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the qualifying credential org | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the qualifying credential org record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the qualifying credential org record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Credential SID + Org SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'CONSTRAINT', N'uk_QualifyingCredentialOrg_CredentialSID_OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'QualifyingCredentialOrg', 'CONSTRAINT', N'uk_QualifyingCredentialOrg_RowGUID'
GO
ALTER TABLE [dbo].[QualifyingCredentialOrg] SET (LOCK_ESCALATION = TABLE)
GO
