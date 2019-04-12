SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vApplicationUser]
as
/*********************************************************************************************************************************
View    : sf.vApplicationUser
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.ApplicationUser - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.ApplicationUser table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vApplicationUserExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vApplicationUserExt documentation for details. To add additional content to this view, customize
the sf.vApplicationUserExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 au.ApplicationUserSID
	,au.PersonSID
	,au.CultureSID
	,au.AuthenticationAuthoritySID
	,au.UserName
	,au.LastReviewTime
	,au.LastReviewUser
	,au.IsPotentialDuplicate
	,au.IsTemplate
	,au.GlassBreakPassword
	,au.LastGlassBreakPasswordChangeTime
	,au.Comments
	,au.IsActive
	,au.AuthenticationSystemID
	,au.ChangeAudit
	,au.UserDefinedColumns
	,au.ApplicationUserXID
	,au.LegacyKey
	,au.IsDeleted
	,au.CreateUser
	,au.CreateTime
	,au.UpdateUser
	,au.UpdateTime
	,au.RowGUID
	,au.RowStamp
	,aux.AuthenticationAuthoritySCD
	,aux.AuthenticationAuthorityLabel
	,aux.AuthenticationAuthorityIsActive
	,aux.AuthenticationAuthorityIsDefault
	,aux.AuthenticationAuthorityRowGUID
	,aux.CultureSCD
	,aux.CultureLabel
	,aux.CultureIsDefault
	,aux.CultureIsActive
	,aux.CultureRowGUID
	,aux.GenderSID
	,aux.NamePrefixSID
	,aux.FirstName
	,aux.CommonName
	,aux.MiddleNames
	,aux.LastName
	,aux.BirthDate
	,aux.DeathDate
	,aux.HomePhone
	,aux.MobilePhone
	,aux.IsTextMessagingEnabled
	,aux.ImportBatch
	,aux.PersonRowGUID
	,aux.ChangeReason
	,aux.IsDeleteEnabled
	,aux.IsReselected
	,aux.IsNullApplied
	,aux.zContext
	,aux.ApplicationUserSessionSID
	,aux.SessionGUID
	,aux.FileAsName
	,aux.FullName
	,aux.DisplayName
	,aux.PrimaryEmailAddress
	,aux.PrimaryEmailAddressSID
	,aux.PreferredPhone
	,aux.LoginCount
	,aux.NextProfileReviewDueDate
	,aux.IsNextProfileReviewOverdue
	,aux.NextGlassBreakPasswordChangeDueDate
	,aux.IsNextGlassBreakPasswordOverdue
	,aux.GlassBreakCountInLast24Hours
	,aux.License
	,aux.IsSysAdmin
	,aux.LastDBAccessTime
	,aux.DaysSinceLastDBAccess
	,aux.IsAccessingNow
	,aux.IsUnused
	,aux.TemplateApplicationUserSID
	,aux.LatestUpdateTime
	,aux.LatestUpdateUser
	,aux.DatabaseName
	,aux.IsConfirmed
	,aux.AutoSaveInterval
	,aux.IsFederatedLogin
	,aux.DatabaseDisplayName
	,aux.DatabaseStatusColor
	,aux.ApplicationGrantXML
	,aux.Password
from
	sf.ApplicationUser      au
join
	sf.vApplicationUser#Ext aux	on au.ApplicationUserSID = aux.ApplicationUserSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.ApplicationUser', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application user assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this user is based on', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The culture this user is assigned to', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The authentication authority used for logging in to the application (e.g. Google account) | For systems using Tenant Services for login, the value is copied from Tenant Services to the client database when the account is created.  The value of this column cannot be changed after the account is created (delete the account and recreate or create a new account).', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'AuthenticationAuthoritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the identity of the user as recorded in Active Directory and using "user@domain" style - example:   tara.knowles@soa.com', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'UserName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'date and time this user profile was last reviewed to ensure it is still required', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'LastReviewTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'identity of the user (usually an administrator) who completed the last review of this user profile', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'LastReviewUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked indicates this may be a duplicate user profile and requires review from an administrator', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsPotentialDuplicate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates this user will appear in the list of templates to copy from when creating new users - sets up same grants as starting point', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'stores the hashed value of a password applied by the user when seeking temporary elevated access to functions or data their profile does not normally provide', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'GlassBreakPassword'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this user profile last changed their glass-break password | This value remains blank until password is initially set.  If password is cleared later, the time the password is set to NULL is stored.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'LastGlassBreakPasswordChangeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'administrative notes about the setup of this user profile - for help-desk notes on incidents use "Application User Note" table', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'Comments'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this application user record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The GUID or similar identifier used by the authentication system to identify the user record | This value is used on federated logins (e.g. MS Account, Google Account) to identify the user since it is possible for the email captured in the UserName column to change over time.  The federated record identifier should not be captured into the UserName column since that value is used in the CreateUser and UpdateUser audit columns and GUID''s.  Note that where no federated provider is used (direct email login) this column is set to the same value as the RowGUID.  A bit in the entity view indicates whether the application user record is a federated login.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'AuthenticationSystemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'History of changes to the active status of the account | Shows date, time and user where active status was toggled on/off.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'ChangeAudit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application user | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'ApplicationUserXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application user | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application user record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application user | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application user record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the authentication authority | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'AuthenticationAuthoritySCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the authentication authority to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'AuthenticationAuthorityLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this authentication authority record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'AuthenticationAuthorityIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default authentication authority to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'AuthenticationAuthorityIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the authentication authority record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'AuthenticationAuthorityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the culture | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'CultureSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the culture to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'CultureLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default culture to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'CultureIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this culture record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'CultureIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the culture record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'CultureRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Virtual column to capture latest reason for change that is written into audit log column', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'ChangeReason'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A filing label for the application user based on last name,first name middle names', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'FileAsName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label for the application user suitable for addressing based on name prefix (salutation) first name middle names last name', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'FullName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label for the application user suitable for use on the UI and reports based on first name last name', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'DisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shows mobile phone if provided otherwise home phone - or blank if no phone numbers are provided', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'PreferredPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of logins in history for this user  - when > 0 the user name cannot be changed', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'LoginCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the next review of this user profile is due | Review target duration is a configuration parameter', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'NextProfileReviewDueDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this user profile is overdue for review | Review target duration is a configuration parameter', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsNextProfileReviewOverdue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date a change to the glass break password is due | Glass break password duration is a configuration parameter', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'NextGlassBreakPasswordChangeDueDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a change to the glass break password is overdue| Glass break password duration is a configuration parameter', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsNextGlassBreakPasswordOverdue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times this user has accessed records using glass break in the last 24 hours', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'GlassBreakCountInLast24Hours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'License'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this user has the System Administrator grant which provides access to all functions in the system', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsSysAdmin'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that this user appears to be logged in currently (access to the database within last 15 minutes)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsAccessingNow'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that the account has not been used recently and may require marking inactive', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsUnused'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Virtual column used to direct framework to copy functional grants from template', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'TemplateApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The latest time any component of the record (Application User or Person) was updated', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'LatestUpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user who made the latest update to any component of the record (Application User or Person)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'LatestUpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if user account requires verification | Derived from the Last Review Time and the Create Time; if values are the same, the user is considered verified.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsConfirmed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The interval (in minutes) after which the system should automatically save report and template entries.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'AutoSaveInterval'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the user is logging in through a federated account (e.g. Microsoft or Google account) | Otherwise Active Directory or email login is being used (set by UI tier)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'IsFederatedLogin'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a change to the glass break password is overdue| Glass break password duration is a configuration parameter', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser', 'COLUMN', N'Password'
GO
