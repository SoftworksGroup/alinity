SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[AltLanguage] (
		[AltLanguageSID]         [int] IDENTITY(1000001, 1) NOT NULL,
		[SourceGUID]             [uniqueidentifier] NOT NULL,
		[FieldID]                [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CultureSID]             [int] NOT NULL,
		[AltLanguageText]        [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[AltLanguageXID]         [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_AltLanguage_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_AltLanguage_SourceGUID_CultureSID_FieldID]
		UNIQUE
		NONCLUSTERED
		([SourceGUID], [CultureSID], [FieldID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_AltLanguage]
		PRIMARY KEY
		CLUSTERED
		([AltLanguageSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Alt Language table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'CONSTRAINT', N'pk_AltLanguage'
GO
ALTER TABLE [sf].[AltLanguage]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_AltLanguage]
	CHECK
	([sf].[fAltLanguage#Check]([AltLanguageSID],[SourceGUID],[FieldID],[CultureSID],[AltLanguageXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[AltLanguage]
CHECK CONSTRAINT [ck_AltLanguage]
GO
ALTER TABLE [sf].[AltLanguage]
	ADD
	CONSTRAINT [df_AltLanguage_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[AltLanguage]
	ADD
	CONSTRAINT [df_AltLanguage_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[AltLanguage]
	ADD
	CONSTRAINT [df_AltLanguage_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[AltLanguage]
	ADD
	CONSTRAINT [df_AltLanguage_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[AltLanguage]
	ADD
	CONSTRAINT [df_AltLanguage_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[AltLanguage]
	ADD
	CONSTRAINT [df_AltLanguage_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[AltLanguage]
	WITH CHECK
	ADD CONSTRAINT [fk_AltLanguage_Culture_CultureSID]
	FOREIGN KEY ([CultureSID]) REFERENCES [sf].[Culture] ([CultureSID])
ALTER TABLE [sf].[AltLanguage]
	CHECK CONSTRAINT [fk_AltLanguage_Culture_CultureSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the culture system ID column in the Alt Language table match a culture system ID in the Culture table. It also ensures that records in the Culture table cannot be deleted if matching child records exist in Alt Language. Finally, the constraint blocks changes to the value of the culture system ID column in the Culture if matching child records exist in Alt Language.', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'CONSTRAINT', N'fk_AltLanguage_Culture_CultureSID'
GO
CREATE NONCLUSTERED INDEX [ix_AltLanguage_CultureSID_AltLanguageSID]
	ON [sf].[AltLanguage] ([CultureSID], [AltLanguageSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Culture SID foreign key column and avoids row contention on (parent) Culture updates', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'INDEX', N'ix_AltLanguage_CultureSID_AltLanguageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table supports customization of the labels and messages for the preferred language of the application user which are produced from the database.  This includes (primarily) result messages, error messages and some labels returned on queries.  Support for alternate language for forms, button faces, menus and the rest of the user interface is provided through separate resource and configuration files stored in the middle or client tiers.  The application is provided in English only so support for other languages is only supported where customization of this table and the UI language components has been implemented.  No additional language support is provided by the base product.  This table supports customization by allowing alternate text to be entered which is associated with another record in the system.  Suppose for example, the error message for “Not Found” requires alternate text for Spanish or French.  First, the application user record for the affected users would have to configured with an alternate culture value – e.g. “fr-CA” for French (Canada).  When the error message is being presented, the database procedure checks if the logged in user is applying a non-default culture and if so, looks for the same message in that alternate culture in this table. It accomplishes the lookup by selecting for the Row GUID Of the default message (sf.message.rowguid) in the Source GUID of this table.  If alternate text is found it is returned instead of the default text, otherwise the default text is returned.  Note that not all areas of the application check for alternate text values.  Where this is supported, the screens for maintaining the default text will also support an option to enter the value for alternate languages.  If that option is not provided in the UI, then alternate text for that entity is not supported. ', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the alt language assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'AltLanguageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier for the on-screen field for which the alternate language text is required | This optional value must be specified where identifying the record alone (through the Source-GUID) is not specific enough or multiple fields require alternate text from the same record.', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'FieldID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The culture assigned to this alt language', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the alt language | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'AltLanguageXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the alt language | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this alt language record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the alt language | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the alt language record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the alt language record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'CONSTRAINT', N'uk_AltLanguage_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Source GUID + Culture SID + Field ID" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'AltLanguage', 'CONSTRAINT', N'uk_AltLanguage_SourceGUID_CultureSID_FieldID'
GO
ALTER TABLE [sf].[AltLanguage] SET (LOCK_ESCALATION = TABLE)
GO
