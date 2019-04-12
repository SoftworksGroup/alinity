SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[MailingPreference] (
		[MailingPreferenceSID]       [int] IDENTITY(1000001, 1) NOT NULL,
		[MailingPreferenceLabel]     [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UsageNotes]                 [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsAutoOptIn]                [bit] NOT NULL,
		[IsActive]                   [bit] NOT NULL,
		[UserDefinedColumns]         [xml] NULL,
		[MailingPreferenceXID]       [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                  [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                  [bit] NOT NULL,
		[CreateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                 [datetimeoffset](7) NOT NULL,
		[UpdateUser]                 [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                 [datetimeoffset](7) NOT NULL,
		[RowGUID]                    [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                   [timestamp] NOT NULL,
		CONSTRAINT [uk_MailingPreference_MailingPreferenceLabel]
		UNIQUE
		NONCLUSTERED
		([MailingPreferenceLabel])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_MailingPreference_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		ON [ApplicationIndexData],
		CONSTRAINT [pk_MailingPreference]
		PRIMARY KEY
		CLUSTERED
		([MailingPreferenceSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Mailing Preference table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'CONSTRAINT', N'pk_MailingPreference'
GO
ALTER TABLE [sf].[MailingPreference]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_MailingPreference]
	CHECK
	([sf].[fMailingPreference#Check]([MailingPreferenceSID],[MailingPreferenceLabel],[IsAutoOptIn],[IsActive],[MailingPreferenceXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[MailingPreference]
CHECK CONSTRAINT [ck_MailingPreference]
GO
ALTER TABLE [sf].[MailingPreference]
	ADD
	CONSTRAINT [df_MailingPreference_IsAutoOptIn]
	DEFAULT ((1)) FOR [IsAutoOptIn]
GO
ALTER TABLE [sf].[MailingPreference]
	ADD
	CONSTRAINT [df_MailingPreference_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[MailingPreference]
	ADD
	CONSTRAINT [df_MailingPreference_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[MailingPreference]
	ADD
	CONSTRAINT [df_MailingPreference_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[MailingPreference]
	ADD
	CONSTRAINT [df_MailingPreference_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[MailingPreference]
	ADD
	CONSTRAINT [df_MailingPreference_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[MailingPreference]
	ADD
	CONSTRAINT [df_MailingPreference_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[MailingPreference]
	ADD
	CONSTRAINT [df_MailingPreference_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MailingPreference_LegacyKey]
	ON [sf].[MailingPreference] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'INDEX', N'ux_MailingPreference_LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The mailing preference table is used to filter out people who have opted-out of receiving a type of mailing.  Most jurisdictions have legislation that requires end-users be able to opt-in on certain categories. When auto opt-in is set, every new user is automatically added to the mailing preference. When email message are created the mailing preference is used as a filter to disallow selection of users who did not opt-into the selected mailing preference.', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the mailing preference assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'MailingPreferenceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the mailing preference to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'MailingPreferenceLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the business scenarios this mailing preference is intended to support', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether new users are opted in to this mailing preference automatically or if they explicitly have to opt in to be part of the mailing list', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'IsAutoOptIn'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this mailing preference record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the mailing preference | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'MailingPreferenceXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the mailing preference | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this mailing preference record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the mailing preference | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the mailing preference record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the mailing preference record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Mailing Preference Label column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'CONSTRAINT', N'uk_MailingPreference_MailingPreferenceLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'MailingPreference', 'CONSTRAINT', N'uk_MailingPreference_RowGUID'
GO
ALTER TABLE [sf].[MailingPreference] SET (LOCK_ESCALATION = TABLE)
GO
