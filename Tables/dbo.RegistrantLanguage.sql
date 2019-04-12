SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegistrantLanguage] (
		[RegistrantLanguageSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[RegistrantSID]             [int] NOT NULL,
		[LanguageSID]               [int] NOT NULL,
		[IsSpoken]                  [bit] NOT NULL,
		[IsWritten]                 [bit] NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[RegistrantLanguageXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_RegistrantLanguage_RegistrantSID_LanguageSID]
		UNIQUE
		NONCLUSTERED
		([RegistrantSID], [LanguageSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_RegistrantLanguage_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_RegistrantLanguage]
		PRIMARY KEY
		CLUSTERED
		([RegistrantLanguageSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Registrant Language table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'CONSTRAINT', N'pk_RegistrantLanguage'
GO
ALTER TABLE [dbo].[RegistrantLanguage]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_RegistrantLanguage]
	CHECK
	([dbo].[fRegistrantLanguage#Check]([RegistrantLanguageSID],[RegistrantSID],[LanguageSID],[IsSpoken],[IsWritten],[RegistrantLanguageXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [dbo].[RegistrantLanguage]
CHECK CONSTRAINT [ck_RegistrantLanguage]
GO
ALTER TABLE [dbo].[RegistrantLanguage]
	ADD
	CONSTRAINT [df_RegistrantLanguage_IsSpoken]
	DEFAULT ((1)) FOR [IsSpoken]
GO
ALTER TABLE [dbo].[RegistrantLanguage]
	ADD
	CONSTRAINT [df_RegistrantLanguage_IsWritten]
	DEFAULT ((1)) FOR [IsWritten]
GO
ALTER TABLE [dbo].[RegistrantLanguage]
	ADD
	CONSTRAINT [df_RegistrantLanguage_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[RegistrantLanguage]
	ADD
	CONSTRAINT [df_RegistrantLanguage_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [dbo].[RegistrantLanguage]
	ADD
	CONSTRAINT [df_RegistrantLanguage_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[RegistrantLanguage]
	ADD
	CONSTRAINT [df_RegistrantLanguage_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [dbo].[RegistrantLanguage]
	ADD
	CONSTRAINT [df_RegistrantLanguage_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [dbo].[RegistrantLanguage]
	ADD
	CONSTRAINT [df_RegistrantLanguage_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [dbo].[RegistrantLanguage]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantLanguage_Registrant_RegistrantSID]
	FOREIGN KEY ([RegistrantSID]) REFERENCES [dbo].[Registrant] ([RegistrantSID])
ALTER TABLE [dbo].[RegistrantLanguage]
	CHECK CONSTRAINT [fk_RegistrantLanguage_Registrant_RegistrantSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the registrant system ID column in the Registrant Language table match a registrant system ID in the Registrant table. It also ensures that records in the Registrant table cannot be deleted if matching child records exist in Registrant Language. Finally, the constraint blocks changes to the value of the registrant system ID column in the Registrant if matching child records exist in Registrant Language.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'CONSTRAINT', N'fk_RegistrantLanguage_Registrant_RegistrantSID'
GO
ALTER TABLE [dbo].[RegistrantLanguage]
	WITH CHECK
	ADD CONSTRAINT [fk_RegistrantLanguage_Language_LanguageSID]
	FOREIGN KEY ([LanguageSID]) REFERENCES [dbo].[Language] ([LanguageSID])
ALTER TABLE [dbo].[RegistrantLanguage]
	CHECK CONSTRAINT [fk_RegistrantLanguage_Language_LanguageSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the language system ID column in the Registrant Language table match a language system ID in the Language table. It also ensures that records in the Language table cannot be deleted if matching child records exist in Registrant Language. Finally, the constraint blocks changes to the value of the language system ID column in the Language if matching child records exist in Registrant Language.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'CONSTRAINT', N'fk_RegistrantLanguage_Language_LanguageSID'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantLanguage_LanguageSID_RegistrantLanguageSID]
	ON [dbo].[RegistrantLanguage] ([LanguageSID], [RegistrantLanguageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Language SID foreign key column and avoids row contention on (parent) Language updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'INDEX', N'ix_RegistrantLanguage_LanguageSID_RegistrantLanguageSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_RegistrantLanguage_LegacyKey]
	ON [dbo].[RegistrantLanguage] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'INDEX', N'ux_RegistrantLanguage_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_RegistrantLanguage_RegistrantSID_RegistrantLanguageSID]
	ON [dbo].[RegistrantLanguage] ([RegistrantSID], [RegistrantLanguageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Registrant SID foreign key column and avoids row contention on (parent) Registrant updates', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'INDEX', N'ix_RegistrantLanguage_RegistrantSID_RegistrantLanguageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records the list of languages the registrant has proficiency in.  Typically, only additional languages are recorded and not the primary language of the jurisdiction of practice.  Designators are provided that indicate whether the profession is verbal, written or both.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant language assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'RegistrantLanguageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant this language is defined for', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The language assigned to this registrant', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'LanguageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant language | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'RegistrantLanguageXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant language | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant language record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant language | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant language record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant language record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Registrant SID + Language SID" columns is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'CONSTRAINT', N'uk_RegistrantLanguage_RegistrantSID_LanguageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'dbo', 'TABLE', N'RegistrantLanguage', 'CONSTRAINT', N'uk_RegistrantLanguage_RowGUID'
GO
ALTER TABLE [dbo].[RegistrantLanguage] SET (LOCK_ESCALATION = TABLE)
GO
