SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantCredential] (
		[RegistrantCredentialSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantSID]                   [int] NOT NULL,
		[CredentialSID]                   [int] NOT NULL,
		[OrgSID]                          [int] NULL,
		[ProgramName]                     [nvarchar](65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ProgramStartDate]                [date] NULL,
		[ProgramTargetCompletionDate]     [date] NULL,
		[EffectiveTime]                   [datetime] NULL,
		[ExpiryTime]                      [datetime] NULL,
		[FieldOfStudySID]                 [int] NOT NULL,
		[UserDefinedColumns]              [xml] NULL,
		[RegistrantCredentialXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                       [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                       [bit] NOT NULL,
		[CreateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                      [datetimeoffset](7) NOT NULL,
		[UpdateUser]                      [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                      [datetimeoffset](7) NOT NULL,
		[RowGUID]                         [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                        [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantCredential_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantCredential]
		PRIMARY KEY
		CLUSTERED
		([RegistrantCredentialSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Credential table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'CONSTRAINT', N'pk_RegistrantCredential'
GO
ALTER TABLE [dbo].[RegistrantCredential]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantCredential]
	CHECK
	([dbo].[fRegistrantCredential#Check]([RegistrantCredentialSID],[RegistrantSID],[CredentialSID],[OrgSID],[ProgramName],[ProgramStartDate],[ProgramTargetCompletionDate],[EffectiveTime],[ExpiryTime],[FieldOfStudySID],[RegistrantCredentialXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantCredential]
CHECK CONSTRAINT [ck_RegistrantCredential]
GO
ALTER TABLE [dbo].[RegistrantCredential]
	ADD
	CONSTRAINT [df_RegistrantCredential_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantCredential]
	ADD
	CONSTRAINT [df_RegistrantCredential_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantCredential]
	ADD
	CONSTRAINT [df_RegistrantCredential_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantCredential]
	ADD
	CONSTRAINT [df_RegistrantCredential_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantCredential]
	ADD
	CONSTRAINT [df_RegistrantCredential_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantCredential]
	ADD
	CONSTRAINT [df_RegistrantCredential_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantCredential]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantCredential_Credential_CredentialSID]
	FOREIGN KEY ([CredentialSID]) REFERENCES [dbo].[Credential] ([CredentialSID])
ALTER TABLE [dbo].[RegistrantCredential]
	CHECK CONSTRAINT [fk_RegistrantCredential_Credential_CredentialSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the credential system ID column in the Registrant Credential table match a credential system ID in the Credential table. It also ensures that records in the Credential table cannot be deleted if matching child records exist in Registrant Credential. Finally, the constraint blocks changes to the value of the credential system ID column in the Credential if matching child records exist in Registrant Credential.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'CONSTRAINT', N'fk_RegistrantCredential_Credential_CredentialSID'
GO
ALTER TABLE [dbo].[RegistrantCredential]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantCredential_FieldOfStudy_FieldOfStudySID]
	FOREIGN KEY ([FieldOfStudySID]) REFERENCES [dbo].[FieldOfStudy] ([FieldOfStudySID])
ALTER TABLE [dbo].[RegistrantCredential]
	CHECK CONSTRAINT [fk_RegistrantCredential_FieldOfStudy_FieldOfStudySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the field of study system ID column in the Registrant Credential table match a field of study system ID in the Field Of Study table. It also ensures that records in the Field Of Study table cannot be deleted if matching child records exist in Registrant Credential. Finally, the constraint blocks changes to the value of the field of study system ID column in the Field Of Study if matching child records exist in Registrant Credential.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'CONSTRAINT', N'fk_RegistrantCredential_FieldOfStudy_FieldOfStudySID'
GO
ALTER TABLE [dbo].[RegistrantCredential]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantCredential_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [dbo].[RegistrantCredential]
	CHECK CONSTRAINT [fk_RegistrantCredential_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Registrant Credential table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Registrant Credential. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Registrant Credential.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'CONSTRAINT', N'fk_RegistrantCredential_Registrant_RegistrantSID'
GO
ALTER TABLE [dbo].[RegistrantCredential]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantCredential_Org_OrgSID]
	FOREIGN KEY ([OrgSID]) REFERENCES [dbo].[Org] ([OrgSID])
ALTER TABLE [dbo].[RegistrantCredential]
	CHECK CONSTRAINT [fk_RegistrantCredential_Org_OrgSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the org system ID column in the Registrant Credential table match a org system ID in the Org table. It also ensures that records in the Org table cannot be deleted if matching child records exist in Registrant Credential. Finally, the constraint blocks changes to the value of the org system ID column in the Org if matching child records exist in Registrant Credential.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'CONSTRAINT', N'fk_RegistrantCredential_Org_OrgSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantCredential_CredentialSID_RegistrantCredentialSID]
	ON [dbo].[RegistrantCredential] ([CredentialSID], [RegistrantCredentialSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Credential SID foreign key column and avoids row contention on (parent) Credential updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'INDEX', N'ix_RegistrantCredential_CredentialSID_RegistrantCredentialSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantCredential_FieldOfStudySID_RegistrantCredentialSID]
	ON [dbo].[RegistrantCredential] ([FieldOfStudySID], [RegistrantCredentialSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Field Of Study SID foreign key column and avoids row contention on (parent) Field Of Study updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'INDEX', N'ix_RegistrantCredential_FieldOfStudySID_RegistrantCredentialSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantCredential_OrgSID_RegistrantCredentialSID]
	ON [dbo].[RegistrantCredential] ([OrgSID], [RegistrantCredentialSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Org SID foreign key column and avoids row contention on (parent) Org updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'INDEX', N'ix_RegistrantCredential_OrgSID_RegistrantCredentialSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantCredential_RegistrantSID_RegistrantCredentialSID]
	ON [dbo].[RegistrantCredential] ([RegistrantSID], [RegistrantCredentialSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'INDEX', N'ix_RegistrantCredential_RegistrantSID_RegistrantCredentialSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantCredential_LegacyKey]
	ON [dbo].[RegistrantCredential] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'INDEX', N'ux_RegistrantCredential_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The Registrant Credential table defines the education or training programs the person holds that are relevant for licensing.  The table also defines specializations for the individual because some credentials can be identified as resulting in a specialization.  For education credentials, a granting organization must always be provided.  For specializations, it is allowable to not specify an organization. The credential is not effective until an Actual Completion Date is entered (goes into the Effective-Time column). To track programs in process (e.g. for student members) use the Program Start and Program Target Completion dates.  ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant credential assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'RegistrantCredentialSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The credential assigned to this registrant', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'CredentialSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this registrant credential', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this restriction/condition was put into effect or most recently changed | Check Change Audit column for history', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'ProgramStartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ending time this restriction/condition was effective.  When blank indicates restriction remains in effect. | See Change Audit for history of restriction being turned on/off', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'ProgramTargetCompletionDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The starting date this specialization or credential was effective', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ending date the specialization or credential was effective.  When blank indicates the specialization remains in effect. ', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The field of study assigned to this registrant credential', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'FieldOfStudySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant credential | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'RegistrantCredentialXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant credential | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant credential record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant credential | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant credential record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant credential record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantCredential', 'CONSTRAINT', N'uk_RegistrantCredential_RowGUID'
GO
ALTER TABLE [dbo].[RegistrantCredential] SET (LOCK_ESCALATION = TABLE)
GO
