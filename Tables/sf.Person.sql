SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[Person] (
		[PersonSID]                  [int] IDENTITY(1000001, 1) NOT NULL,
		[GenderSID]                  [int] NOT NULL,
		[NamePrefixSID]              [int] NULL,
		[FirstName]                  [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CommonName]                 [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MiddleNames]                [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LastName]                   [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[BirthDate]                  [date] NULL,
		[DeathDate]                  [date] NULL,
		[HomePhone]                  [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MobilePhone]                [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsTextMessagingEnabled]     [bit] NOT NULL,
		[SignatureImage]             [varbinary](max) NULL,
		[IdentityPhoto]              [varbinary](max) NULL,
		[ImportBatch]                [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UserDefinedColumns]         [xml] NULL,
		[PersonXID]                  [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_Person_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_Person]
		PRIMARY KEY
		CLUSTERED
		([PersonSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'Person', 'CONSTRAINT', N'pk_Person'
GO
ALTER TABLE [sf].[Person]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_Person]
	CHECK
	([sf].[fPerson#Check]([PersonSID],[GenderSID],[NamePrefixSID],[FirstName],[CommonName],[MiddleNames],[LastName],[BirthDate],[DeathDate],[HomePhone],[MobilePhone],[IsTextMessagingEnabled],[ImportBatch],[PersonXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[Person]
CHECK CONSTRAINT [ck_Person]
GO
ALTER TABLE [sf].[Person]
	ADD
	CONSTRAINT [df_Person_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[Person]
	ADD
	CONSTRAINT [df_Person_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[Person]
	ADD
	CONSTRAINT [df_Person_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[Person]
	ADD
	CONSTRAINT [df_Person_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[Person]
	ADD
	CONSTRAINT [df_Person_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[Person]
	ADD
	CONSTRAINT [df_Person_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[Person]
	ADD
	CONSTRAINT [df_Person_IsTextMessagingEnabled]
	DEFAULT (CONVERT([bit],(0))) FOR [IsTextMessagingEnabled]
GO
ALTER TABLE [sf].[Person]
	WITH CHECK
	ADD CONSTRAINT [fk_Person_Gender_GenderSID]
	FOREIGN KEY ([GenderSID]) REFERENCES [sf].[Gender] ([GenderSID])
ALTER TABLE [sf].[Person]
	CHECK CONSTRAINT [fk_Person_Gender_GenderSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the gender system ID column in the Person table match a gender system ID in the Gender table. It also ensures that records in the Gender table cannot be deleted if matching child records exist in Person. Finally, the constraint blocks changes to the value of the gender system ID column in the Gender if matching child records exist in Person.', 'SCHEMA', N'sf', 'TABLE', N'Person', 'CONSTRAINT', N'fk_Person_Gender_GenderSID'
GO
ALTER TABLE [sf].[Person]
	WITH CHECK
	ADD CONSTRAINT [fk_Person_NamePrefix_NamePrefixSID]
	FOREIGN KEY ([NamePrefixSID]) REFERENCES [sf].[NamePrefix] ([NamePrefixSID])
ALTER TABLE [sf].[Person]
	CHECK CONSTRAINT [fk_Person_NamePrefix_NamePrefixSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the name prefix system ID column in the Person table match a name prefix system ID in the Name Prefix table. It also ensures that records in the Name Prefix table cannot be deleted if matching child records exist in Person. Finally, the constraint blocks changes to the value of the name prefix system ID column in the Name Prefix if matching child records exist in Person.', 'SCHEMA', N'sf', 'TABLE', N'Person', 'CONSTRAINT', N'fk_Person_NamePrefix_NamePrefixSID'
GO
CREATE NONCLUSTERED INDEX [ix_Person_GenderSID_PersonSID]
	ON [sf].[Person] ([GenderSID], [PersonSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Gender SID foreign key column and avoids row contention on (parent) Gender updates', 'SCHEMA', N'sf', 'TABLE', N'Person', 'INDEX', N'ix_Person_GenderSID_PersonSID'
GO
CREATE NONCLUSTERED INDEX [ix_Person_ImportBatch_PersonSID]
	ON [sf].[Person] ([ImportBatch], [PersonSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Person searches based on the Import Batch + Person SID columns', 'SCHEMA', N'sf', 'TABLE', N'Person', 'INDEX', N'ix_Person_ImportBatch_PersonSID'
GO
CREATE NONCLUSTERED INDEX [ix_Person_LastName_FirstName_MiddleNames]
	ON [sf].[Person] ([LastName], [FirstName], [MiddleNames])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Person searches based on the Last Name + First Name + Middle Names columns', 'SCHEMA', N'sf', 'TABLE', N'Person', 'INDEX', N'ix_Person_LastName_FirstName_MiddleNames'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_Person_LegacyKey]
	ON [sf].[Person] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'Person', 'INDEX', N'ux_Person_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_Person_NamePrefixSID_PersonSID]
	ON [sf].[Person] ([NamePrefixSID], [PersonSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Name Prefix SID foreign key column and avoids row contention on (parent) Name Prefix updates', 'SCHEMA', N'sf', 'TABLE', N'Person', 'INDEX', N'ix_Person_NamePrefixSID_PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table is one of the principal entities in the database model.  A record is created for each stakeholder of interest to the application – whether end user, patient, registrant etc.  The type and status of the person is further described through additional attributes.  A single person may have multiple roles in the application.  For example, they may be a staff user and a registrant, a patient and a provider, etc.  Regardless of the number of roles held each individual will only have a single Person record. Routines provided in the framework provide look ups for creating new Person records that identify potential duplicates.  The information captured in this entity is basic: name, birthdate and personal phone numbers along with signature and photo ID image.  Where online access is provided to a person, they will have an Application User" record associated on a 1-1 basis.', 'SCHEMA', N'sf', 'TABLE', N'Person', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An image file representing the users signature applied to documents when signed by the user electronically', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'SignatureImage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A picture of the person - may be used for identity confirmation', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'IdentityPhoto'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'PersonXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'Person', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'Person', 'CONSTRAINT', N'uk_Person_RowGUID'
GO
ALTER TABLE [sf].[Person] SET (LOCK_ESCALATION = TABLE)
GO
