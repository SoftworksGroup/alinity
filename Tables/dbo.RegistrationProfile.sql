SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrationProfile] (
		[RegistrationProfileSID]                 [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrationSnapshotSID]                [int] NOT NULL,
		[JursidictionStateProvinceISONumber]     [smallint] NOT NULL,
		[RegistrantSID]                          [int] NOT NULL,
		[RegistrantNo]                           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[GenderSCD]                              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BirthDate]                              [date] NULL,
		[PersonMailingAddressSID]                [int] NULL,
		[ResidenceStateProvinceISONumber]        [smallint] NULL,
		[ResidencePostalCode]                    [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ResidenceCountryISONumber]              [smallint] NULL,
		[ResidenceIsDefaultCountry]              [bit] NOT NULL,
		[RegistrationSID]                        [int] NOT NULL,
		[IsActivePractice]                       [bit] NOT NULL,
		[Education1RegistrantCredentialSID]      [int] NULL,
		[Education1CredentialCode]               [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Education1GraduationYear]               [smallint] NULL,
		[Education1StateProvinceISONumber]       [smallint] NULL,
		[Education1CountryISONumber]             [smallint] NULL,
		[Education1IsDefaultCountry]             [bit] NOT NULL,
		[Education2RegistrantCredentialSID]      [int] NULL,
		[Education2CredentialCode]               [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Education2GraduationYear]               [smallint] NULL,
		[Education2StateProvinceISONumber]       [smallint] NULL,
		[Education2CountryISONumber]             [smallint] NULL,
		[Education2IsDefaultCountry]             [bit] NOT NULL,
		[Education3RegistrantCredentialSID]      [int] NULL,
		[Education3CredentialCode]               [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Education3GraduationYear]               [smallint] NULL,
		[Education3StateProvinceISONumber]       [smallint] NULL,
		[Education3CountryISONumber]             [smallint] NULL,
		[Education3IsDefaultCountry]             [bit] NOT NULL,
		[RegistrantPracticeSID]                  [int] NULL,
		[EmploymentStatusCode]                   [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EmploymentCount]                        [smallint] NULL,
		[PracticeHours]                          [smallint] NOT NULL,
		[Employment1RegistrantEmploymentSID]     [int] NULL,
		[Employment1TypeCode]                    [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment1StateProvinceISONumber]      [smallint] NULL,
		[Employment1CountryISONumber]            [smallint] NULL,
		[Employment1IsDefaultCountry]            [bit] NOT NULL,
		[Employment1PostalCode]                  [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment1OrgTypeCode]                 [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment1PracticeAreaCode]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment1PracticeScopeCode]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment1RoleCode]                    [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment2RegistrantEmploymentSID]     [int] NULL,
		[Employment2TypeCode]                    [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment2StateProvinceISONumber]      [smallint] NULL,
		[Employment2IsDefaultCountry]            [bit] NOT NULL,
		[Employment2CountryISONumber]            [smallint] NULL,
		[Employment2PostalCode]                  [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment2OrgTypeCode]                 [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment2PracticeAreaCode]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment2PracticeScopeCode]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment2RoleCode]                    [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment3RegistrantEmploymentSID]     [int] NULL,
		[Employment3TypeCode]                    [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment3StateProvinceISONumber]      [smallint] NULL,
		[Employment3CountryISONumber]            [smallint] NULL,
		[Employment3IsDefaultCountry]            [bit] NOT NULL,
		[Employment3PostalCode]                  [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment3OrgTypeCode]                 [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment3PracticeAreaCode]            [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment3PracticeScopeCode]           [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Employment3RoleCode]                    [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsInvalid]                              [bit] NOT NULL,
		[MessageText]                            [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CheckSumOnLastExport]                   [int] NULL,
		[UserDefinedColumns]                     [xml] NULL,
		[RegistrationProfileXID]                 [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                              [bit] NOT NULL,
		[CreateUser]                             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                             [datetimeoffset](7) NOT NULL,
		[UpdateUser]                             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                             [datetimeoffset](7) NOT NULL,
		[RowGUID]                                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                               [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrationProfile_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrationProfile_RegistrantSID_RegistrationSnapshotSID]
		UNIQUE
		NONCLUSTERED
		([RegistrantSID], [RegistrationSnapshotSID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrationProfile]
		PRIMARY KEY
		CLUSTERED
		([RegistrationProfileSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registration Profile table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'pk_RegistrationProfile'
GO
ALTER TABLE [dbo].[RegistrationProfile]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrationProfile]
	CHECK
	([dbo].[fRegistrationProfile#Check]([RegistrationProfileSID],[RegistrationSnapshotSID],[JursidictionStateProvinceISONumber],[RegistrantSID],[RegistrantNo],[GenderSCD],[BirthDate],[PersonMailingAddressSID],[ResidenceStateProvinceISONumber],[ResidencePostalCode],[ResidenceCountryISONumber],[ResidenceIsDefaultCountry],[RegistrationSID],[IsActivePractice],[Education1RegistrantCredentialSID],[Education1CredentialCode],[Education1GraduationYear],[Education1StateProvinceISONumber],[Education1CountryISONumber],[Education1IsDefaultCountry],[Education2RegistrantCredentialSID],[Education2CredentialCode],[Education2GraduationYear],[Education2StateProvinceISONumber],[Education2CountryISONumber],[Education2IsDefaultCountry],[Education3RegistrantCredentialSID],[Education3CredentialCode],[Education3GraduationYear],[Education3StateProvinceISONumber],[Education3CountryISONumber],[Education3IsDefaultCountry],[RegistrantPracticeSID],[EmploymentStatusCode],[EmploymentCount],[PracticeHours],[Employment1RegistrantEmploymentSID],[Employment1TypeCode],[Employment1StateProvinceISONumber],[Employment1CountryISONumber],[Employment1IsDefaultCountry],[Employment1PostalCode],[Employment1OrgTypeCode],[Employment1PracticeAreaCode],[Employment1PracticeScopeCode],[Employment1RoleCode],[Employment2RegistrantEmploymentSID],[Employment2TypeCode],[Employment2StateProvinceISONumber],[Employment2IsDefaultCountry],[Employment2CountryISONumber],[Employment2PostalCode],[Employment2OrgTypeCode],[Employment2PracticeAreaCode],[Employment2PracticeScopeCode],[Employment2RoleCode],[Employment3RegistrantEmploymentSID],[Employment3TypeCode],[Employment3StateProvinceISONumber],[Employment3CountryISONumber],[Employment3IsDefaultCountry],[Employment3PostalCode],[Employment3OrgTypeCode],[Employment3PracticeAreaCode],[Employment3PracticeScopeCode],[Employment3RoleCode],[IsInvalid],[MessageText],[CheckSumOnLastExport],[RegistrationProfileXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrationProfile]
CHECK CONSTRAINT [ck_RegistrationProfile]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_ResidenceIsDefaultCountry]
	DEFAULT (CONVERT([bit],(0))) FOR [ResidenceIsDefaultCountry]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_IsActivePractice]
	DEFAULT ((0)) FOR [IsActivePractice]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_Education1IsDefaultCountry]
	DEFAULT (CONVERT([bit],(0))) FOR [Education1IsDefaultCountry]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_Education2IsDefaultCountry]
	DEFAULT (CONVERT([bit],(0))) FOR [Education2IsDefaultCountry]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_Education3IsDefaultCountry]
	DEFAULT (CONVERT([bit],(0))) FOR [Education3IsDefaultCountry]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_PracticeHours]
	DEFAULT ((0)) FOR [PracticeHours]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_Employment1IsDefaultCountry]
	DEFAULT (CONVERT([bit],(0))) FOR [Employment1IsDefaultCountry]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_Employment2IsDefaultCountry]
	DEFAULT (CONVERT([bit],(0))) FOR [Employment2IsDefaultCountry]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_Employment3IsDefaultCountry]
	DEFAULT (CONVERT([bit],(0))) FOR [Employment3IsDefaultCountry]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_IsInvalid]
	DEFAULT (CONVERT([bit],(0))) FOR [IsInvalid]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	ADD
	CONSTRAINT [df_RegistrationProfile_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrationProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationProfile_PersonMailingAddress_PersonMailingAddressSID]
	FOREIGN KEY ([PersonMailingAddressSID]) REFERENCES [dbo].[PersonMailingAddress] ([PersonMailingAddressSID])
ALTER TABLE [dbo].[RegistrationProfile]
	CHECK CONSTRAINT [fk_RegistrationProfile_PersonMailingAddress_PersonMailingAddressSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person mailing address system ID column in the Registration Profile table match a person mailing address system ID in the Person Mailing Address table. It also ensures that records in the Person Mailing Address table cannot be deleted if matching child records exist in Registration Profile. Finally, the constraint blocks changes to the value of the person mailing address system ID column in the Person Mailing Address if matching child records exist in Registration Profile.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'fk_RegistrationProfile_PersonMailingAddress_PersonMailingAddressSID'
GO
ALTER TABLE [dbo].[RegistrationProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationProfile_RegistrationSnapshot_RegistrationSnapshotSID]
	FOREIGN KEY ([RegistrationSnapshotSID]) REFERENCES [dbo].[RegistrationSnapshot] ([RegistrationSnapshotSID])
	ON DELETE CASCADE
ALTER TABLE [dbo].[RegistrationProfile]
	CHECK CONSTRAINT [fk_RegistrationProfile_RegistrationSnapshot_RegistrationSnapshotSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registration snapshot system ID column in the Registration Profile table match a registration snapshot system ID in the Registration Snapshot table. It also ensures that when a record in the Registration Snapshot table is deleted, matching child records in the Registration Profile table are deleted as well. Finally, the constraint blocks changes to the value of the registration snapshot system ID column in the Registration Snapshot if matching child records exist in Registration Profile.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'fk_RegistrationProfile_RegistrationSnapshot_RegistrationSnapshotSID'
GO
ALTER TABLE [dbo].[RegistrationProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationProfile_RegistrantCredential_Education1RegistrantCredentialSID]
	FOREIGN KEY ([Education1RegistrantCredentialSID]) REFERENCES [dbo].[RegistrantCredential] ([RegistrantCredentialSID])
ALTER TABLE [dbo].[RegistrationProfile]
	CHECK CONSTRAINT [fk_RegistrationProfile_RegistrantCredential_Education1RegistrantCredentialSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the education 1registrant credential system ID column in the Registration Profile table match a registrant credential system ID in the Registrant Credential table. It also ensures that records in the Registrant Credential table cannot be deleted if matching child records exist in Registration Profile. Finally, the constraint blocks changes to the value of the registrant credential system ID column in the Registrant Credential if matching child records exist in Registration Profile.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'fk_RegistrationProfile_RegistrantCredential_Education1RegistrantCredentialSID'
GO
ALTER TABLE [dbo].[RegistrationProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationProfile_RegistrantCredential_Education2RegistrantCredentialSID]
	FOREIGN KEY ([Education2RegistrantCredentialSID]) REFERENCES [dbo].[RegistrantCredential] ([RegistrantCredentialSID])
ALTER TABLE [dbo].[RegistrationProfile]
	CHECK CONSTRAINT [fk_RegistrationProfile_RegistrantCredential_Education2RegistrantCredentialSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the education 2registrant credential system ID column in the Registration Profile table match a registrant credential system ID in the Registrant Credential table. It also ensures that records in the Registrant Credential table cannot be deleted if matching child records exist in Registration Profile. Finally, the constraint blocks changes to the value of the registrant credential system ID column in the Registrant Credential if matching child records exist in Registration Profile.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'fk_RegistrationProfile_RegistrantCredential_Education2RegistrantCredentialSID'
GO
ALTER TABLE [dbo].[RegistrationProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationProfile_RegistrantCredential_Education3RegistrantCredentialSID]
	FOREIGN KEY ([Education3RegistrantCredentialSID]) REFERENCES [dbo].[RegistrantCredential] ([RegistrantCredentialSID])
ALTER TABLE [dbo].[RegistrationProfile]
	CHECK CONSTRAINT [fk_RegistrationProfile_RegistrantCredential_Education3RegistrantCredentialSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the education 3registrant credential system ID column in the Registration Profile table match a registrant credential system ID in the Registrant Credential table. It also ensures that records in the Registrant Credential table cannot be deleted if matching child records exist in Registration Profile. Finally, the constraint blocks changes to the value of the registrant credential system ID column in the Registrant Credential if matching child records exist in Registration Profile.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'fk_RegistrationProfile_RegistrantCredential_Education3RegistrantCredentialSID'
GO
ALTER TABLE [dbo].[RegistrationProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationProfile_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [dbo].[RegistrationProfile]
	CHECK CONSTRAINT [fk_RegistrationProfile_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Registration Profile table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Registration Profile. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Registration Profile.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'fk_RegistrationProfile_Registrant_RegistrantSID'
GO
ALTER TABLE [dbo].[RegistrationProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationProfile_Registration_RegistrationSID]
	FOREIGN KEY ([RegistrationSID]) REFERENCES [dbo].[Registration] ([RegistrationSID])
ALTER TABLE [dbo].[RegistrationProfile]
	CHECK CONSTRAINT [fk_RegistrationProfile_Registration_RegistrationSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registration system ID column in the Registration Profile table match a registration system ID in the Registration table. It also ensures that records in the Registration table cannot be deleted if matching child records exist in Registration Profile. Finally, the constraint blocks changes to the value of the registration system ID column in the Registration if matching child records exist in Registration Profile.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'fk_RegistrationProfile_Registration_RegistrationSID'
GO
ALTER TABLE [dbo].[RegistrationProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationProfile_RegistrantEmployment_Employment1RegistrantEmploymentSID]
	FOREIGN KEY ([Employment1RegistrantEmploymentSID]) REFERENCES [dbo].[RegistrantEmployment] ([RegistrantEmploymentSID])
ALTER TABLE [dbo].[RegistrationProfile]
	CHECK CONSTRAINT [fk_RegistrationProfile_RegistrantEmployment_Employment1RegistrantEmploymentSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the employment 1registrant employment system ID column in the Registration Profile table match a registrant employment system ID in the Registrant Employment table. It also ensures that records in the Registrant Employment table cannot be deleted if matching child records exist in Registration Profile. Finally, the constraint blocks changes to the value of the registrant employment system ID column in the Registrant Employment if matching child records exist in Registration Profile.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'fk_RegistrationProfile_RegistrantEmployment_Employment1RegistrantEmploymentSID'
GO
ALTER TABLE [dbo].[RegistrationProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationProfile_RegistrantEmployment_Employment2RegistrantEmploymentSID]
	FOREIGN KEY ([Employment2RegistrantEmploymentSID]) REFERENCES [dbo].[RegistrantEmployment] ([RegistrantEmploymentSID])
ALTER TABLE [dbo].[RegistrationProfile]
	CHECK CONSTRAINT [fk_RegistrationProfile_RegistrantEmployment_Employment2RegistrantEmploymentSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the employment 2registrant employment system ID column in the Registration Profile table match a registrant employment system ID in the Registrant Employment table. It also ensures that records in the Registrant Employment table cannot be deleted if matching child records exist in Registration Profile. Finally, the constraint blocks changes to the value of the registrant employment system ID column in the Registrant Employment if matching child records exist in Registration Profile.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'fk_RegistrationProfile_RegistrantEmployment_Employment2RegistrantEmploymentSID'
GO
ALTER TABLE [dbo].[RegistrationProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationProfile_RegistrantEmployment_Employment3RegistrantEmploymentSID]
	FOREIGN KEY ([Employment3RegistrantEmploymentSID]) REFERENCES [dbo].[RegistrantEmployment] ([RegistrantEmploymentSID])
ALTER TABLE [dbo].[RegistrationProfile]
	CHECK CONSTRAINT [fk_RegistrationProfile_RegistrantEmployment_Employment3RegistrantEmploymentSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the employment 3registrant employment system ID column in the Registration Profile table match a registrant employment system ID in the Registrant Employment table. It also ensures that records in the Registrant Employment table cannot be deleted if matching child records exist in Registration Profile. Finally, the constraint blocks changes to the value of the registrant employment system ID column in the Registrant Employment if matching child records exist in Registration Profile.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'fk_RegistrationProfile_RegistrantEmployment_Employment3RegistrantEmploymentSID'
GO
ALTER TABLE [dbo].[RegistrationProfile]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrationProfile_RegistrantPractice_RegistrantPracticeSID]
	FOREIGN KEY ([RegistrantPracticeSID]) REFERENCES [dbo].[RegistrantPractice] ([RegistrantPracticeSID])
ALTER TABLE [dbo].[RegistrationProfile]
	CHECK CONSTRAINT [fk_RegistrationProfile_RegistrantPractice_RegistrantPracticeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant practice system ID column in the Registration Profile table match a registrant practice system ID in the Registrant Practice table. It also ensures that records in the Registrant Practice table cannot be deleted if matching child records exist in Registration Profile. Finally, the constraint blocks changes to the value of the registrant practice system ID column in the Registrant Practice if matching child records exist in Registration Profile.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'fk_RegistrationProfile_RegistrantPractice_RegistrantPracticeSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationProfile_Education1RegistrantCredentialSID_RegistrationProfileSID]
	ON [dbo].[RegistrationProfile] ([Education1RegistrantCredentialSID], [RegistrationProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Education 1Registrant Credential SID foreign key column and avoids row contention on (parent) Registrant Credential updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'INDEX', N'ix_RegistrationProfile_Education1RegistrantCredentialSID_RegistrationProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationProfile_Education2RegistrantCredentialSID_RegistrationProfileSID]
	ON [dbo].[RegistrationProfile] ([Education2RegistrantCredentialSID], [RegistrationProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Education 2Registrant Credential SID foreign key column and avoids row contention on (parent) Registrant Credential updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'INDEX', N'ix_RegistrationProfile_Education2RegistrantCredentialSID_RegistrationProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationProfile_Education3RegistrantCredentialSID_RegistrationProfileSID]
	ON [dbo].[RegistrationProfile] ([Education3RegistrantCredentialSID], [RegistrationProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Education 3Registrant Credential SID foreign key column and avoids row contention on (parent) Registrant Credential updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'INDEX', N'ix_RegistrationProfile_Education3RegistrantCredentialSID_RegistrationProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationProfile_Employment1RegistrantEmploymentSID_RegistrationProfileSID]
	ON [dbo].[RegistrationProfile] ([Employment1RegistrantEmploymentSID], [RegistrationProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Employment 1Registrant Employment SID foreign key column and avoids row contention on (parent) Registrant Employment updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'INDEX', N'ix_RegistrationProfile_Employment1RegistrantEmploymentSID_RegistrationProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationProfile_Employment2RegistrantEmploymentSID_RegistrationProfileSID]
	ON [dbo].[RegistrationProfile] ([Employment2RegistrantEmploymentSID], [RegistrationProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Employment 2Registrant Employment SID foreign key column and avoids row contention on (parent) Registrant Employment updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'INDEX', N'ix_RegistrationProfile_Employment2RegistrantEmploymentSID_RegistrationProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationProfile_Employment3RegistrantEmploymentSID_RegistrationProfileSID]
	ON [dbo].[RegistrationProfile] ([Employment3RegistrantEmploymentSID], [RegistrationProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Employment 3Registrant Employment SID foreign key column and avoids row contention on (parent) Registrant Employment updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'INDEX', N'ix_RegistrationProfile_Employment3RegistrantEmploymentSID_RegistrationProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationProfile_PersonMailingAddressSID_RegistrationProfileSID]
	ON [dbo].[RegistrationProfile] ([PersonMailingAddressSID], [RegistrationProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person Mailing Address SID foreign key column and avoids row contention on (parent) Person Mailing Address updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'INDEX', N'ix_RegistrationProfile_PersonMailingAddressSID_RegistrationProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationProfile_RegistrantPracticeSID_RegistrationProfileSID]
	ON [dbo].[RegistrationProfile] ([RegistrantPracticeSID], [RegistrationProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant Practice SID foreign key column and avoids row contention on (parent) Registrant Practice updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'INDEX', N'ix_RegistrationProfile_RegistrantPracticeSID_RegistrationProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationProfile_RegistrationSID_RegistrationProfileSID]
	ON [dbo].[RegistrationProfile] ([RegistrationSID], [RegistrationProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registration SID foreign key column and avoids row contention on (parent) Registration updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'INDEX', N'ix_RegistrationProfile_RegistrationSID_RegistrationProfileSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrationProfile_RegistrationSnapshotSID_RegistrationProfileSID]
	ON [dbo].[RegistrationProfile] ([RegistrationSnapshotSID], [RegistrationProfileSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registration Snapshot SID foreign key column and avoids row contention on (parent) Registration Snapshot updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'INDEX', N'ix_RegistrationProfile_RegistrationSnapshotSID_RegistrationProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records details of demographic, registration, education and employment data for each registrant at the time the snapshot is generated.  The values in this table can be edited in the user interface where corrections are required from third parties like CIHI and resubmitted.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration profile assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'RegistrationProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration snapshot assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'RegistrationSnapshotSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant assigned to this registration profile', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person mailing address assigned to this registration profile', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'PersonMailingAddressSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registration assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'RegistrationSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant credential assigned to this registration profile', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'Education1RegistrantCredentialSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant credential assigned to this registration profile', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'Education2RegistrantCredentialSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant credential assigned to this registration profile', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'Education3RegistrantCredentialSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant practice assigned to this registration profile', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'RegistrantPracticeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total hours reported for the year', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'PracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant employment assigned to this registration profile', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'Employment1RegistrantEmploymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant employment assigned to this registration profile', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'Employment2RegistrantEmploymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant employment assigned to this registration profile', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'Employment3RegistrantEmploymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the record has been marked invalid by the receving 3rd party (see Message Text)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'IsInvalid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A message from a 3rd party receiver of the record about its status or errors detected', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'MessageText'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The value of the record''s checksum on the last export (used to determine if record has been modified)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'CheckSumOnLastExport'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registration profile | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'RegistrationProfileXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registration profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registration profile record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registration profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registration profile record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registration profile record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'uk_RegistrationProfile_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Registrant SID + Registration Snapshot SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrationProfile', 'CONSTRAINT', N'uk_RegistrationProfile_RegistrantSID_RegistrationSnapshotSID'
GO
ALTER TABLE [dbo].[RegistrationProfile] SET (LOCK_ESCALATION = TABLE)
GO
