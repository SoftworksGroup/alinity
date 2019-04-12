SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[PersonOtherName] (
		[PersonOtherNameSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]              [int] NOT NULL,
		[OtherNameTypeSID]       [int] NOT NULL,
		[FirstName]              [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CommonName]             [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MiddleNames]            [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LastName]               [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]     [xml] NULL,
		[PersonOtherNameXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]              [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]              [bit] NOT NULL,
		[CreateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]             [datetimeoffset](7) NOT NULL,
		[UpdateUser]             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]             [datetimeoffset](7) NOT NULL,
		[RowGUID]                [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]               [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonOtherName_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonOtherName]
		PRIMARY KEY
		CLUSTERED
		([PersonOtherNameSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Other Name table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'CONSTRAINT', N'pk_PersonOtherName'
GO
ALTER TABLE [sf].[PersonOtherName]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonOtherName]
	CHECK
	([sf].[fPersonOtherName#Check]([PersonOtherNameSID],[PersonSID],[OtherNameTypeSID],[FirstName],[CommonName],[MiddleNames],[LastName],[PersonOtherNameXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[PersonOtherName]
CHECK CONSTRAINT [ck_PersonOtherName]
GO
ALTER TABLE [sf].[PersonOtherName]
	ADD
	CONSTRAINT [df_PersonOtherName_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[PersonOtherName]
	ADD
	CONSTRAINT [df_PersonOtherName_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[PersonOtherName]
	ADD
	CONSTRAINT [df_PersonOtherName_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[PersonOtherName]
	ADD
	CONSTRAINT [df_PersonOtherName_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[PersonOtherName]
	ADD
	CONSTRAINT [df_PersonOtherName_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[PersonOtherName]
	ADD
	CONSTRAINT [df_PersonOtherName_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[PersonOtherName]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonOtherName_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [sf].[PersonOtherName]
	CHECK CONSTRAINT [fk_PersonOtherName_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Person Other Name table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Person Other Name. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Person Other Name.', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'CONSTRAINT', N'fk_PersonOtherName_Person_PersonSID'
GO
ALTER TABLE [sf].[PersonOtherName]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonOtherName_OtherNameType_OtherNameTypeSID]
	FOREIGN KEY ([OtherNameTypeSID]) REFERENCES [sf].[OtherNameType] ([OtherNameTypeSID])
ALTER TABLE [sf].[PersonOtherName]
	CHECK CONSTRAINT [fk_PersonOtherName_OtherNameType_OtherNameTypeSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the other name type system ID column in the Person Other Name table match a other name type system ID in the Other Name Type table. It also ensures that records in the Other Name Type table cannot be deleted if matching child records exist in Person Other Name. Finally, the constraint blocks changes to the value of the other name type system ID column in the Other Name Type if matching child records exist in Person Other Name.', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'CONSTRAINT', N'fk_PersonOtherName_OtherNameType_OtherNameTypeSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonOtherName_OtherNameTypeSID_PersonOtherNameSID]
	ON [sf].[PersonOtherName] ([OtherNameTypeSID], [PersonOtherNameSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Other Name Type SID foreign key column and avoids row contention on (parent) Other Name Type updates', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'INDEX', N'ix_PersonOtherName_OtherNameTypeSID_PersonOtherNameSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonOtherName_PersonSID_PersonOtherNameSID]
	ON [sf].[PersonOtherName] ([PersonSID], [PersonOtherNameSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'INDEX', N'ix_PersonOtherName_PersonSID_PersonOtherNameSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonOtherName_LegacyKey]
	ON [sf].[PersonOtherName] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'INDEX', N'ux_PersonOtherName_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_PersonOtherName_LastName_FirstName_MiddleNames]
	ON [sf].[PersonOtherName] ([LastName], [FirstName], [MiddleNames])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Person Other Name searches based on the Last Name + First Name + Middle Names columns', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'INDEX', N'ix_PersonOtherName_LastName_FirstName_MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person other name assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'PersonOtherNameSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this other name is based on', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person other name', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'OtherNameTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Decription', N'middle name or names if known', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname or family name of the person', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person other name | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'PersonOtherNameXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person other name | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person other name record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person other name | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person other name record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person other name record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'PersonOtherName', 'CONSTRAINT', N'uk_PersonOtherName_RowGUID'
GO
ALTER TABLE [sf].[PersonOtherName] SET (LOCK_ESCALATION = TABLE)
GO
