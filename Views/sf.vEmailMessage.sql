SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vEmailMessage]
as
/*********************************************************************************************************************************
View    : sf.vEmailMessage
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.EmailMessage - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.EmailMessage table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vEmailMessageExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vEmailMessageExt documentation for details. To add additional content to this view, customize
the sf.vEmailMessageExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 em.EmailMessageSID
	,em.SenderEmailAddress
	,em.SenderDisplayName
	,em.PriorityLevel
	,em.Subject
	,em.Body
	,em.FileTypeSCD
	,em.FileTypeSID
	,em.RecipientList
	,em.IsApplicationUserRequired
	,em.ApplicationUserSID
	,em.MessageLinkSID
	,em.LinkExpiryHours
	,em.ApplicationEntitySID
	,em.ApplicationGrantSID
	,em.IsGenerateOnly
	,em.MergedTime
	,em.QueuedTime
	,em.CancelledTime
	,em.ArchivedTime
	,em.PurgedTime
	,em.UserDefinedColumns
	,em.EmailMessageXID
	,em.LegacyKey
	,em.IsDeleted
	,em.CreateUser
	,em.CreateTime
	,em.UpdateUser
	,em.UpdateTime
	,em.RowGUID
	,em.RowStamp
	,emx.FileTypeFileTypeSCD
	,emx.FileTypeLabel
	,emx.MimeType
	,emx.IsInline
	,emx.FileTypeIsActive
	,emx.FileTypeRowGUID
	,emx.MessageLinkSCD
	,emx.MessageLinkLabel
	,emx.ApplicationPageSID
	,emx.MessageLinkRowGUID
	,emx.ApplicationEntitySCD
	,emx.ApplicationEntityName
	,emx.IsMergeDataSource
	,emx.ApplicationEntityRowGUID
	,emx.ApplicationGrantSCD
	,emx.ApplicationGrantName
	,emx.ApplicationGrantIsDefault
	,emx.ApplicationGrantRowGUID
	,emx.PersonSID
	,emx.CultureSID
	,emx.AuthenticationAuthoritySID
	,emx.UserName
	,emx.LastReviewTime
	,emx.LastReviewUser
	,emx.IsPotentialDuplicate
	,emx.IsTemplate
	,emx.GlassBreakPassword
	,emx.LastGlassBreakPasswordChangeTime
	,emx.ApplicationUserIsActive
	,emx.AuthenticationSystemID
	,emx.ApplicationUserRowGUID
	,emx.IsDeleteEnabled
	,emx.IsReselected
	,emx.IsNullApplied
	,emx.zContext
	,emx.LinkURI
	,emx.MessageStatusSCD
	,emx.MessageStatusLabel
	,emx.RecipientCount
	,emx.NotReceivedCount
	,emx.IsQueued
	,emx.IsSent
	,emx.IsCancelled
	,emx.IsCancelEnabled
	,emx.IsArchived
	,emx.IsPurged
	,emx.SentTime
	,emx.SentTimeLast
	,emx.SentCount
	,emx.NotSentCount
	,emx.IsEditEnabled
	,emx.IsLinkEmbedded
	,emx.QueuingTime
	,emx.RecipientPersonSID
from
	sf.EmailMessage      em
join
	sf.vEmailMessage#Ext emx	on em.EmailMessageSID = emx.EmailMessageSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.EmailMessage', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the email message assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'EmailMessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sending email address for the note', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'SenderEmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is the text which will be displayed as part of the ''from'' field in a user''s email client.  E.g. In outlook the combination of a display name and the sender''s email address is displayed as ''John Doe <john.d@mailinator.com>''.', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'SenderDisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A priority level used to rank emails for sending: 1 is the highest priority, 5 is medium and 10 is lowest | This value is used to sort emails for pickup by the email sending service', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Subject of the email note', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'Subject'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Body of the email note (HTML format)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'Body'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file extension or type of document the email body is stored as | This value must match one of the registered filter types for full-text searching.  The list of document types supported is limited by the master table.  The value includes the leading period - e.g. ".HTML" Note that the default value is updated by an AFTER trigger defined on the table.', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'FileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of email message', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'FileTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Buffer to store recipients while an email message is in draft mode. The list of identifiers (Person SIDs) is used to create the PersonEmailMessage record when the email message is sent.', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'RecipientList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the eligibility check on recipients should ensure there is an active user account (recipient must be able to sign in) | Be sure this value is set for password reset emails', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsApplicationUserRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A reference to an existing user record to use as a template for grants to apply to new user accounts created when this email is confirmed | 
Applies to user invite emails only', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the email link assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'MessageLinkSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of hours after which any (confirmation) link included in the email is considered expired', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'LinkExpiryHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this email message', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, indicates the document is not to be mailed out. The PDF is saved to the member file for download and/or printing only.', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsGenerateOnly'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the process of finalizing the email content begins | No changes to recipients or template contents can occur after this value is set', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'MergedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this message was provided to the service for sending', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'QueuedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the email message was cancelled (not sent) after being queued but before being sent (prior to queuing the message can be deleted)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'CancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the email was put into archived status | Archived email remains available in the database but is not included in displays and searches by default', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ArchivedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the email document is purged from online storage (documents can be exported at archive step)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'PurgedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the email message | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'EmailMessageXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the email message | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this email message record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the email message | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the email message record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the email message record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the file type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'FileTypeFileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the file type to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'FileTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The MIME type to use when a client browser downloads or views a document.', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'MimeType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When a client browser downloads a document this indicates whether or not the browser should be asked to display rather than download the document. If the browser is unable to, due to lack of software or other settings, the file will instead be downloaded as normal.', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsInline'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this file type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'FileTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the file type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'FileTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the message link | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'MessageLinkSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the message link to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'MessageLinkLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the message link record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'MessageLinkRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application entity | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationEntitySCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application entity to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationEntityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this application entity should be a source of replacement values for note templates | Only the core entities of the application should be established as merge-field data sources ', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsMergeDataSource'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application entity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationEntityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application grant | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationGrantSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application grant to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationGrantName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default application grant to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationGrantIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application grant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationGrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this user is based on', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The culture this user is assigned to', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The authentication authority used for logging in to the application (e.g. Google account) | For systems using Tenant Services for login, the value is copied from Tenant Services to the client database when the account is created.  The value of this column cannot be changed after the account is created (delete the account and recreate or create a new account).', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'AuthenticationAuthoritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the identity of the user as recorded in Active Directory and using "user@domain" style - example:   tara.knowles@soa.com', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'UserName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'date and time this user profile was last reviewed to ensure it is still required', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'LastReviewTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'identity of the user (usually an administrator) who completed the last review of this user profile', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'LastReviewUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked indicates this may be a duplicate user profile and requires review from an administrator', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsPotentialDuplicate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates this user will appear in the list of templates to copy from when creating new users - sets up same grants as starting point', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'stores the hashed value of a password applied by the user when seeking temporary elevated access to functions or data their profile does not normally provide', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'GlassBreakPassword'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this user profile last changed their glass-break password | This value remains blank until password is initially set.  If password is cleared later, the time the password is set to NULL is stored.', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'LastGlassBreakPasswordChangeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this application user record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationUserIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The GUID or similar identifier used by the authentication system to identify the user record | This value is used on federated logins (e.g. MS Account, Google Account) to identify the user since it is possible for the email captured in the UserName column to change over time.  The federated record identifier should not be captured into the UserName column since that value is used in the CreateUser and UpdateUser audit columns and GUID''s.  Note that where no federated provider is used (direct email login) this column is set to the same value as the RowGUID.  A bit in the entity view indicates whether the application user record is a federated login.', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'AuthenticationSystemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'ApplicationUserRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the message status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'MessageStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the message status to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'MessageStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total message recipients', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'RecipientCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total recipients who have since been identified as not having received the message (e.g. invalid address, delivery failures, etc.)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'NotReceivedCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if message is queued (ready for sending by the email service if not already sent)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsQueued'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if message is sent (the sent date and time is filled in)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsSent'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the message was stopped from being sent (cancelled time filled in)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsCancelled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates whether the cancellation function can be used (only after queuing)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsCancelEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if message is archived (message has been sent but was moved out of current mail category)', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsArchived'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the recipient email documents have been purged (deleted) from the system', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsPurged'
GO
EXEC sp_addextendedproperty N'MS_Description', N'date and time message was sent for last recipient', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'SentTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'date and time message was sent for last recipient', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'SentTimeLast'
GO
EXEC sp_addextendedproperty N'MS_Description', N'count of recipients message is not sent for', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'SentCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'count of recipients message is not sent for', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'NotSentCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if content or recipients of email can be changed or email sent', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsEditEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the email contains a confirmation page address', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'IsLinkEmbedded'
GO
EXEC sp_addextendedproperty N'MS_Description', N'DateTime of when queue job was started', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'QueuingTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Virtual column to allow email message to be created and sent to one person immediately', 'SCHEMA', N'sf', 'VIEW', N'vEmailMessage', 'COLUMN', N'RecipientPersonSID'
GO