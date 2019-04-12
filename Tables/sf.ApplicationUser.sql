SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [sf].[ApplicationUser] (
		[ApplicationUserSID]                   [int] IDENTITY(1000001, 1) NOT NULL,
		[PersonSID]                            [int] NOT NULL,
		[CultureSID]                           [int] NOT NULL,
		[AuthenticationAuthoritySID]           [int] NOT NULL,
		[UserName]                             [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[LastReviewTime]                       [datetimeoffset](7) NOT NULL,
		[LastReviewUser]                       [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[IsPotentialDuplicate]                 [bit] NOT NULL,
		[IsTemplate]                           [bit] NOT NULL,
		[GlassBreakPassword]                   [varbinary](8000) NULL,
		[LastGlassBreakPasswordChangeTime]     [datetimeoffset](7) NULL,
		[Comments]                             [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsActive]                             [bit] NOT NULL,
		[AuthenticationSystemID]               [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ChangeAudit]                          [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UserDefinedColumns]                   [xml] NULL,
		[ApplicationUserXID]                   [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[LegacyKey]                            [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[IsDeleted]                            [bit] NOT NULL,
		[CreateUser]                           [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CreateTime]                           [datetimeoffset](7) NOT NULL,
		[UpdateUser]                           [nvarchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[UpdateTime]                           [datetimeoffset](7) NOT NULL,
		[RowGUID]                              [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[RowStamp]                             [timestamp] NOT NULL,
		CONSTRAINT [uk_ApplicationUser_AuthenticationSystemID]
		UNIQUE
		NONCLUSTERED
		([AuthenticationSystemID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationUser_PersonSID]
		UNIQUE
		NONCLUSTERED
		([PersonSID])
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationUser_RowGUID]
		UNIQUE
		NONCLUSTERED
		([RowGUID])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [uk_ApplicationUser_UserName]
		UNIQUE
		NONCLUSTERED
		([UserName])
		WITH FILLFACTOR=90
		ON [ApplicationIndexData],
		CONSTRAINT [pk_ApplicationUser]
		PRIMARY KEY
		CLUSTERED
		([ApplicationUserSID])
	ON [ApplicationRowData]
)
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key constraint that ensures the unique system identifier (SID) assigned to the Application User table is not duplicated (referenced in all foreign keys where this table is the parent)', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'CONSTRAINT', N'pk_ApplicationUser'
GO
ALTER TABLE [sf].[ApplicationUser]
	WITH NOCHECK
	ADD
	CONSTRAINT [ck_ApplicationUser]
	CHECK
	([sf].[fApplicationUser#Check]([ApplicationUserSID],[PersonSID],[CultureSID],[AuthenticationAuthoritySID],[UserName],[LastReviewTime],[LastReviewUser],[IsPotentialDuplicate],[IsTemplate],[GlassBreakPassword],[LastGlassBreakPasswordChangeTime],[IsActive],[AuthenticationSystemID],[ApplicationUserXID],[LegacyKey],[IsDeleted],[CreateUser],[CreateTime],[UpdateUser],[UpdateTime],[RowGUID])=(1))
GO
ALTER TABLE [sf].[ApplicationUser]
CHECK CONSTRAINT [ck_ApplicationUser]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_LastReviewTime]
	DEFAULT (sysdatetimeoffset()) FOR [LastReviewTime]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_LastReviewUser]
	DEFAULT (suser_sname()) FOR [LastReviewUser]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_IsPotentialDuplicate]
	DEFAULT (CONVERT([bit],(0))) FOR [IsPotentialDuplicate]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_IsTemplate]
	DEFAULT ((0)) FOR [IsTemplate]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_IsActive]
	DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_AuthenticationSystemID]
	DEFAULT (N'[!'+CONVERT([nvarchar](48),newid(),(0))) FOR [AuthenticationSystemID]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_ChangeAudit]
	DEFAULT ('Activated by '+suser_sname()) FOR [ChangeAudit]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_IsDeleted]
	DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_CreateUser]
	DEFAULT (suser_sname()) FOR [CreateUser]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_CreateTime]
	DEFAULT (sysdatetimeoffset()) FOR [CreateTime]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_UpdateUser]
	DEFAULT (suser_sname()) FOR [UpdateUser]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_UpdateTime]
	DEFAULT (sysdatetimeoffset()) FOR [UpdateTime]
GO
ALTER TABLE [sf].[ApplicationUser]
	ADD
	CONSTRAINT [df_ApplicationUser_RowGUID]
	DEFAULT (newsequentialid()) FOR [RowGUID]
GO
ALTER TABLE [sf].[ApplicationUser]
	WITH CHECK
	ADD CONSTRAINT [fk_ApplicationUser_Culture_CultureSID]
	FOREIGN KEY ([CultureSID]) REFERENCES [sf].[Culture] ([CultureSID])
ALTER TABLE [sf].[ApplicationUser]
	CHECK CONSTRAINT [fk_ApplicationUser_Culture_CultureSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the culture system ID column in the Application User table match a culture system ID in the Culture table. It also ensures that records in the Culture table cannot be deleted if matching child records exist in Application User. Finally, the constraint blocks changes to the value of the culture system ID column in the Culture if matching child records exist in Application User.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'CONSTRAINT', N'fk_ApplicationUser_Culture_CultureSID'
GO
ALTER TABLE [sf].[ApplicationUser]
	WITH CHECK
	ADD CONSTRAINT [fk_ApplicationUser_AuthenticationAuthority_AuthenticationAuthoritySID]
	FOREIGN KEY ([AuthenticationAuthoritySID]) REFERENCES [sf].[AuthenticationAuthority] ([AuthenticationAuthoritySID])
ALTER TABLE [sf].[ApplicationUser]
	CHECK CONSTRAINT [fk_ApplicationUser_AuthenticationAuthority_AuthenticationAuthoritySID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the authentication authority system ID column in the Application User table match a authentication authority system ID in the Authentication Authority table. It also ensures that records in the Authentication Authority table cannot be deleted if matching child records exist in Application User. Finally, the constraint blocks changes to the value of the authentication authority system ID column in the Authentication Authority if matching child records exist in Application User.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'CONSTRAINT', N'fk_ApplicationUser_AuthenticationAuthority_AuthenticationAuthoritySID'
GO
ALTER TABLE [sf].[ApplicationUser]
	WITH CHECK
	ADD CONSTRAINT [fk_ApplicationUser_Person_PersonSID]
	FOREIGN KEY ([PersonSID]) REFERENCES [sf].[Person] ([PersonSID])
ALTER TABLE [sf].[ApplicationUser]
	CHECK CONSTRAINT [fk_ApplicationUser_Person_PersonSID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'This referential integrity constraint ensures values in the person system ID column in the Application User table match a person system ID in the Person table. It also ensures that records in the Person table cannot be deleted if matching child records exist in Application User. Finally, the constraint blocks changes to the value of the person system ID column in the Person if matching child records exist in Application User.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'CONSTRAINT', N'fk_ApplicationUser_Person_PersonSID'
GO
CREATE NONCLUSTERED INDEX [ix_ApplicationUser_AuthenticationAuthoritySID_ApplicationUserSID]
	ON [sf].[ApplicationUser] ([AuthenticationAuthoritySID], [ApplicationUserSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Authentication Authority SID foreign key column and avoids row contention on (parent) Authentication Authority updates', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'INDEX', N'ix_ApplicationUser_AuthenticationAuthoritySID_ApplicationUserSID'
GO
CREATE NONCLUSTERED INDEX [ix_ApplicationUser_CultureSID_ApplicationUserSID]
	ON [sf].[ApplicationUser] ([CultureSID], [ApplicationUserSID])
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ensures fast join access on the Culture SID foreign key column and avoids row contention on (parent) Culture updates', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'INDEX', N'ix_ApplicationUser_CultureSID_ApplicationUserSID'
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_ApplicationUser_LegacyKey]
	ON [sf].[ApplicationUser] ([LegacyKey])
	WHERE (([LegacyKey] IS NOT NULL))
	WITH ( FILLFACTOR = 90)
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the Legacy Key value is not duplicated where the condition: "([LegacyKey] IS NOT NULL)" is met', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'INDEX', N'ux_ApplicationUser_LegacyKey'
GO
CREATE NONCLUSTERED INDEX [ix_ApplicationUser_IsActive_UserName]
	ON [sf].[ApplicationUser] ([IsActive], [UserName])
	INCLUDE ([ApplicationUserSID])
	ON [ApplicationIndexData]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Improves performance of Application User searches based on the Is Active + User Name columns', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'INDEX', N'ix_ApplicationUser_IsActive_UserName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This table stores user accounts which may or may not include password for authentication.  The login process applied is driven by the value of the Authentication Authority column which determines whether login will occur against Active Directory, a federated account (e.g. Google, Microsoft) or the local database. For systems using Tenant Services for login, the value is copied from Tenant Services to the client database when the account is created.  The value of this column cannot be changed after the account is created (delete the account and recreate or create a new account).The user profile entity is completed through inheritance of attributes - including name, registrant numbers and email address – from the Person and Person Email tables.  Once a user is authenticated through their authority, their profile is looked up in this table (Application User) to establish their roles (authorization), if any, in the application.  If a user has a successful login but no authorization in this specific application, access is denied.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application user assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this user is based on', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The culture this user is assigned to', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The authentication authority used for logging in to the application (e.g. Google account) | For systems using Tenant Services for login, the value is copied from Tenant Services to the client database when the account is created.  The value of this column cannot be changed after the account is created (delete the account and recreate or create a new account).', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'AuthenticationAuthoritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the identity of the user as recorded in Active Directory and using "user@domain" style - example:   tara.knowles@soa.com', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'UserName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'date and time this user profile was last reviewed to ensure it is still required', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'LastReviewTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'identity of the user (usually an administrator) who completed the last review of this user profile', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'LastReviewUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked indicates this may be a duplicate user profile and requires review from an administrator', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'IsPotentialDuplicate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates this user will appear in the list of templates to copy from when creating new users - sets up same grants as starting point', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'IsTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'stores the hashed value of a password applied by the user when seeking temporary elevated access to functions or data their profile does not normally provide', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'GlassBreakPassword'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this user profile last changed their glass-break password | This value remains blank until password is initially set.  If password is cleared later, the time the password is set to NULL is stored.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'LastGlassBreakPasswordChangeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'administrative notes about the setup of this user profile - for help-desk notes on incidents use "Application User Note" table', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'Comments'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this application user record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The GUID or similar identifier used by the authentication system to identify the user record | This value is used on federated logins (e.g. MS Account, Google Account) to identify the user since it is possible for the email captured in the UserName column to change over time.  The federated record identifier should not be captured into the UserName column since that value is used in the CreateUser and UpdateUser audit columns and GUID''s.  Note that where no federated provider is used (direct email login) this column is set to the same value as the RowGUID.  A bit in the entity view indicates whether the application user record is a federated login.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'AuthenticationSystemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'History of changes to the active status of the account | Shows date, time and user where active status was toggled on/off.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'ChangeAudit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application user | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'ApplicationUserXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application user | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application user record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application user | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application user record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Authentication System ID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'CONSTRAINT', N'uk_ApplicationUser_AuthenticationSystemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Person SID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'CONSTRAINT', N'uk_ApplicationUser_PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the Row GUID column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'CONSTRAINT', N'uk_ApplicationUser_RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Implements a business rule to ensure the value provided for the User Name column is not duplicated', 'SCHEMA', N'sf', 'TABLE', N'ApplicationUser', 'CONSTRAINT', N'uk_ApplicationUser_UserName'
GO
ALTER TABLE [sf].[ApplicationUser] SET (LOCK_ESCALATION = TABLE)
GO
