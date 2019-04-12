SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[PersonMailingPreference] (
		[PersonMailingPreferenceSID]     [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]                      [int] NOT NULL,
		[MailingPreferenceSID]           [int] NOT NULL,
		[EffectiveTime]                  [datetime] NOT NULL,
		[ExpiryTime]                     [datetime] NULL,
		[ChangeAudit]                    [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]             [xml] NULL,
		[PersonMailingPreferenceXID]     [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                      [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                      [bit] NOT NULL,
		[CreateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                     [datetimeoffset](7) NOT NULL,
		[UpdateUser]                     [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                     [datetimeoffset](7) NOT NULL,
		[RowGUID]                        [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                       [timestamp] NOT NULL,
		CONSTRAINT [uk_PersonMailingPreference_PersonSID_MailingPreferenceSID]
		UNIQUE
		NONCLUSTERED
		([PersonSID], [MailingPreferenceSID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [uk_PersonMailingPreference_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_PersonMailingPreference]
		PRIMARY KEY
		CLUSTERED
		([PersonMailingPreferenceSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Person Mailing Preference table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'CONSTRAINT', N'pk_PersonMailingPreference'
GO
ALTER TABLE [sf].[PersonMailingPreference]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_PersonMailingPreference]
	CHECK
	([sf].[fPersonMailingPreference#Check]([PersonMailingPreferenceSID],[PersonSID],[MailingPreferenceSID],[EffectiveTime],[ExpiryTime],[PersonMailingPreferenceXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[PersonMailingPreference]
CHECK CONSTRAINT [ck_PersonMailingPreference]
GO
ALTER TABLE [sf].[PersonMailingPreference]
	ADD
	CONSTRAINT [df_PersonMailingPreference_EffectiveTime]
	DEFAULT ([sf].[fNow]()) FOR [EffectiveTime]
GO
ALTER TABLE [sf].[PersonMailingPreference]
	ADD
	CONSTRAINT [df_PersonMailingPreference_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[PersonMailingPreference]
	ADD
	CONSTRAINT [df_PersonMailingPreference_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[PersonMailingPreference]
	ADD
	CONSTRAINT [df_PersonMailingPreference_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[PersonMailingPreference]
	ADD
	CONSTRAINT [df_PersonMailingPreference_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[PersonMailingPreference]
	ADD
	CONSTRAINT [df_PersonMailingPreference_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[PersonMailingPreference]
	ADD
	CONSTRAINT [df_PersonMailingPreference_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[PersonMailingPreference]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonMailingPreference_MailingPreference_MailingPreferenceSID]
	FOREIGN KEY ([MailingPreferenceSID]) REFERENCES [sf].[MailingPreference] ([MailingPreferenceSID])
	ON DELETE CASCADE
ALTER TABLE [sf].[PersonMailingPreference]
	CHECK CONSTRAINT [fk_PersonMailingPreference_MailingPreference_MailingPreferenceSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the mailing preference system ID column in the Person Mailing Preference table match a mailing preference system ID in the Mailing Preference table. It also ensures that when a record in the Mailing Preference table is deleted, matching child records in the Person Mailing Preference table are deleted as well. Finally, the constraint blocks changes to the value of the mailing preference system ID column in the Mailing Preference if matching child records exist in Person Mailing Preference.', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'CONSTRAINT', N'fk_PersonMailingPreference_MailingPreference_MailingPreferenceSID'
GO
ALTER TABLE [sf].[PersonMailingPreference]
	WITH CHECK
	ADD CONSTRAINT [fk_PersonMailingPreference_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [sf].[PersonMailingPreference]
	CHECK CONSTRAINT [fk_PersonMailingPreference_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Person Mailing Preference table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Person Mailing Preference. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Person Mailing Preference.', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'CONSTRAINT', N'fk_PersonMailingPreference_Person_PersonSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_PersonMailingPreference_LegacyKey]
	ON [sf].[PersonMailingPreference] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'INDEX', N'ux_PersonMailingPreference_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_PersonMailingPreference_MailingPreferenceSID_PersonMailingPreferenceSID]
	ON [sf].[PersonMailingPreference] ([MailingPreferenceSID], [PersonMailingPreferenceSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Mailing Preference SID foreign key column and avoids row contention on (parent) Mailing Preference updates', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'INDEX', N'ix_PersonMailingPreference_MailingPreferenceSID_PersonMailingPreferenceSID'
GO
CREATE NONCLUSTERED INDEX [ix_PersonMailingPreference_PersonSID_PersonMailingPreferenceSID]
	ON [sf].[PersonMailingPreference] ([PersonSID], [PersonMailingPreferenceSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Person SID foreign key column and avoids row contention on (parent) Person updates', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'INDEX', N'ix_PersonMailingPreference_PersonSID_PersonMailingPreferenceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table supports an end-user “opt-out” option for categories of email.  The application provides an interface for end-users to update their profile including mailing preferences. This table then stores the inclusion which is checked before email/text is distributed to the person indicated. An option on the MailingPreference table indicates if people are opt-in automatically, if so a record is added to this table automatically when the person is created. At anytime if the user decides to opt-out the expiry time is filled in.', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person mailing preference assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'PersonMailingPreferenceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this mailing preference is based on', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The mailing preference assigned to this person', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'MailingPreferenceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this mailing preference (opt-in) was put into effect or most recently changed', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this mailing preference was cancelled (opt-out)', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'History of changes to this opt-out | The UI may prompt for a reason for disabling or re-enabling the opt-out and this reason, along with other audit information, is stored into this column.', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'ChangeAudit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person mailing preference | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'PersonMailingPreferenceXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person mailing preference | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person mailing preference record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person mailing preference | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person mailing preference record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person mailing preference record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the combination of values provided for the "Person SID + Mailing Preference SID" columns is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'CONSTRAINT', N'uk_PersonMailingPreference_PersonSID_MailingPreferenceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'PersonMailingPreference', 'CONSTRAINT', N'uk_PersonMailingPreference_RowGUID'
GO
ALTER TABLE [sf].[PersonMailingPreference] SET (LOCK_ESCALATION = TABLE)
GO
