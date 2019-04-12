SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[PersonEmailAddress] (
		[PersonEmailAddressSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]                 [int] NOT NULL,
		[EmailAddress]              [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsPrimary]                 [bit] NOT NULL,
		[IsActive]                  [bit] NOT NULL,
		[ChangeAudit]               [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]        [xml] NULL,
		[PersonEmailAddressXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                 [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                 [bit] NOT NULL,
		[CreateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                [datetimeoffset](7) NOT NULL,
		[UpdateUser]                [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                [datetimeoffset](7) NOT NULL,
		[RowGUID]                   [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                  [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonEmailAddress_EmailAddress]
		UNIQUE
		NONCLUSTERED
		([EmailAddress])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PersonEmailAddress_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonEmailAddress]
		PRIMARY KEY
		CLUSTERED
		([PersonEmailAddressSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Email Address table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'CONSTRAINT', N'pk_PersonEmailAddress'
GO
ALTER TABLE [sf].[PersonEmailAddress]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonEmailAddress]
	CHECK
	([sf].[fPersonEmailAddress#Check]([PersonEmailAddressSID],[PersonSID],[EmailAddress],[IsPrimary],[IsActive],[PersonEmailAddressXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[PersonEmailAddress]
CHECK CONSTRAINT [ck_PersonEmailAddress]
GO
ALTER TABLE [sf].[PersonEmailAddress]
	ADD
	CONSTRAINT [df_PersonEmailAddress_IsPrimary]
	DEFAULT ((1)) FOR [IsPrimary]
GO
ALTER TABLE [sf].[PersonEmailAddress]
	ADD
	CONSTRAINT [df_PersonEmailAddress_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[PersonEmailAddress]
	ADD
	CONSTRAINT [df_PersonEmailAddress_ChangeAudit]
	DEFAULT ('Activated by '+suser_sname()) FOR [ChangeAudit]
GO
ALTER TABLE [sf].[PersonEmailAddress]
	ADD
	CONSTRAINT [df_PersonEmailAddress_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[PersonEmailAddress]
	ADD
	CONSTRAINT [df_PersonEmailAddress_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[PersonEmailAddress]
	ADD
	CONSTRAINT [df_PersonEmailAddress_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[PersonEmailAddress]
	ADD
	CONSTRAINT [df_PersonEmailAddress_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[PersonEmailAddress]
	ADD
	CONSTRAINT [df_PersonEmailAddress_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[PersonEmailAddress]
	ADD
	CONSTRAINT [df_PersonEmailAddress_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[PersonEmailAddress]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonEmailAddress_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[PersonEmailAddress]
	CHECK CONSTRAINT [fk_PersonEmailAddress_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Person Email Address table match a person system ID in the Person table. It also ensures that when a record in the Person table is deleted, matching child records in the Person Email Address table are deleted as well. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Person Email Address.', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'CONSTRAINT', N'fk_PersonEmailAddress_Person_PersonSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonEmailAddress_LegacyKey]
	ON [sf].[PersonEmailAddress] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'INDEX', N'ux_PersonEmailAddress_LegacyKey'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonEmailAddress_PersonSID_IsPrimary]
	ON [sf].[PersonEmailAddress] ([PersonSID], [IsPrimary])
	WHERE (([IsPrimary]=CONVERT([bit],(1),(0))))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Person SID + Is Primary" columns is not duplicated where the condition: "([IsPrimary]=CONVERT([bit],(1),(0)))" is met', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'INDEX', N'ux_PersonEmailAddress_PersonSID_IsPrimary'
GO
CREATE NONCLUSTERED INDEX [ix_PersonEmailAddress_PersonSID_PersonEmailAddressSID]
	ON [sf].[PersonEmailAddress] ([PersonSID], [PersonEmailAddressSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'INDEX', N'ix_PersonEmailAddress_PersonSID_PersonEmailAddressSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonEmailAddress_IsPrimary_IsActive]
	ON [sf].[PersonEmailAddress] ([IsPrimary], [IsActive])
	INCLUDE ([PersonSID], [EmailAddress])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Person Email Address searches based on the Is Primary + Is Active columns', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'INDEX', N'ix_PersonEmailAddress_IsPrimary_IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table records one or more email addresses for each person in the system. Generally only a single address should be stored, however, if an address is known to be invalid it should be marked as not active and a replacement email entered when available.  Note that even if multiple email addresses are not stored, the system tracks the address used on each email message sent (Person Email Message table).  Email addresses are validated for standard formatting upon entry by built-in system rules.', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person email address assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'PersonEmailAddressSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this email address is based on', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this person email address record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'History of changes to the active status of the email address | Shows date, time and user where active status was toggled on/off.', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'ChangeAudit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person email address | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'PersonEmailAddressXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person email address | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person email address record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person email address | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person email address record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person email address record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Email Address column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'CONSTRAINT', N'uk_PersonEmailAddress_EmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'PersonEmailAddress', 'CONSTRAINT', N'uk_PersonEmailAddress_RowGUID'
GO
ALTER TABLE [sf].[PersonEmailAddress] SET (LOCK_ESCALATION = TABLE)
GO
