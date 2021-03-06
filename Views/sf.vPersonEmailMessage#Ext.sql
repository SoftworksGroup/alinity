SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vPersonEmailMessage#Ext]
as
/*********************************************************************************************************************************
View    : sf.vPersonEmailMessage#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the sf.PersonEmailMessage base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vPersonEmailMessage (referred to as the "entity" view in SGI documentation).

Columns required to support the EF include constants passed by client and middle tier modules into the table API procedures as
parameters. These values control the insert/update/delete behaviour of the sprocs. For example: the IsNullApplied bit is set ON
in the view so that update procedures overwrite column values when matching parameters are NULL on calls from the client tier.
The default for this column in the call signature of the sproc is 0 (off) so that calls from the back-end do not overwrite with
null values.  The zContext XML value is always null but is required for binding to sproc calls using EF and RIA.

You can add additional columns, joins and examples of calling syntax, by placing them between the code tag pairs provided.  Items
placed within code tag pairs are preserved on regeneration.  Note that all additions to this view become part of the base product
and deploy for all client configurations.  This view is NOT an extension point for client-specific configurations.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 pem.PersonEmailMessageSID
	,em.SenderEmailAddress
	,em.SenderDisplayName
	,em.PriorityLevel
	,em.Subject                                                             EmailMessageSubject
	,em.FileTypeSCD                                                         EmailMessageFileTypeSCD
	,em.FileTypeSID                                                         EmailMessageFileTypeSID
	,em.IsApplicationUserRequired
	,em.ApplicationUserSID                                                  EmailMessageApplicationUserSID
	,em.MessageLinkSID
	,em.LinkExpiryHours
	,em.ApplicationEntitySID
	,em.ApplicationGrantSID
	,em.IsGenerateOnly
	,em.MergedTime
	,em.QueuedTime
	,em.CancelledTime                                                       EmailMessageCancelledTime
	,em.ArchivedTime
	,em.PurgedTime
	,em.RowGUID                                                             EmailMessageRowGUID
	,ftype.FileTypeSCD                                                      FileTypeFileTypeSCD
	,ftype.FileTypeLabel
	,ftype.MimeType
	,ftype.IsInline
	,ftype.IsActive                                                         FileTypeIsActive
	,ftype.RowGUID                                                          FileTypeRowGUID
	,person.GenderSID
	,person.NamePrefixSID
	,person.FirstName
	,person.CommonName
	,person.MiddleNames
	,person.LastName
	,person.BirthDate
	,person.DeathDate
	,person.HomePhone
	,person.MobilePhone
	,person.IsTextMessagingEnabled
	,person.ImportBatch
	,person.RowGUID                                                         PersonRowGUID
	,emltgr.EmailTriggerLabel
	,emltgr.EmailTemplateSID
	,emltgr.QuerySID
	,emltgr.MinDaysToRepeat
	,emltgr.ApplicationUserSID                                              EmailTriggerApplicationUserSID
	,emltgr.JobScheduleSID
	,emltgr.LastStartTime
	,emltgr.LastEndTime
	,emltgr.EarliestSelectionDate
	,emltgr.IsActive                                                        EmailTriggerIsActive
	,emltgr.RowGUID                                                         EmailTriggerRowGUID
	,cast(null as nvarchar(4000))                                           ChangeReason							--# Virtual column to capture latest reason for change that is written into audit log column
	,sf.fPersonEmailMessage#IsDeleteEnabled(pem.PersonEmailMessageSID)      IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
--! <MoreColumns>	
 ,sf.fPersonEmailMessage#IsReadGranted(pem.PersonEmailMessageSID, zag.ApplicationGrantSCD)				 IsReadGranted				--# Indicates if access to this email is available to the currently logged in user
 ,isnull(pem.Subject, em.Subject)																																	 SubjectSent					--# The subject of the email sent | This value includes replacement values if the email was based on a template
 ,isnull(pem.Body, em.Body)																																				 BodySent							--# The body of the email sent | This value includes replacement values if any were included in the email template
 ,zext.MessageLinkExpiryTime																																														--# Date and time the confirmation link on the email expires
 ,zext.ConfirmationLagHours																																															--# Hours between time the email was sent and the confirmation link was clicked (the hours waiting for user to confirm)
 ,zext.MessageLinkStatusSCD																																															--# Code identifying status of the link in the email (if any)
 ,zext.MessageLinkStatusLabel																																														--# Label identifying status of the link in the email (if any)
 ,zext.IsPending																																																				--# Indicates whether the link is still waiting for confirmation from the user ("pending" and not cancelled)
 ,zext.IsConfirmed																																																			--# Indicates whether the link has been accepted by the user resulting in creation of a user profile ("confirmed" status)
 ,zext.IsExpired																																																				--# Indicates whether the reserve period on the link has ended ("expired" status)
 ,zext.IsCancelled																																																			--# Indicates whether this link was revoked so that it can no longer be confirmed ("cancelled" status)
 ,cast(case when pem.EmailDocument is null and em.PurgedTime is not null then 1 else 0 end as bit) IsPurged							--# Indicates if the email document associated wit this message has been purged (deleted) from the system
 ,zx.IsEmailOpenTracked																																																	--# Indicates whether tracking of this email is enabled (cases a beacon image to be included in the content)
 ,case when pem.NotReceivedNoticeTime is null then cast(0 as bit)else cast(1 as bit)end						 IsNotReceived				--# Indicates whether or not the email was "not received", usually an error in the service processing
 ,sf.fFormatFileAsName(person.LastName, person.FirstName, person.MiddleNames)											 FileAsName						--# A filing label for the person based on last name, first name middle names
 ,sf.fFormatFullName(person.LastName, person.FirstName, person.MiddleNames, znp.NamePrefixLabel)	 FullName							--# A label for the person suitable for addressing based on name prefix (salutation) first name middle names last name
 ,sf.fFormatDisplayName(person.LastName, isnull(person.CommonName, person.FirstName))							 DisplayName					--# A label for the person suitable for use on the UI and reports based on first name last name
 ,sf.fAgeInYears(person.BirthDate, zx.Today)																											 AgeInYears						--# The age of the person reported in full years lived (the typical way we refer to how old we are)
 ,zpea.EmailAddress																																								 CurrentEmailAddress	--# The current primary email address for this person (may not be the same as the one used on the email when sent)	
--! </MoreColumns>
from
	sf.PersonEmailMessage pem
join
	sf.EmailMessage       em     on pem.EmailMessageSID = em.EmailMessageSID
join
	sf.FileType           ftype  on pem.FileTypeSID = ftype.FileTypeSID
join
	sf.Person             person on pem.PersonSID = person.PersonSID
left outer join
	sf.EmailTrigger       emltgr on pem.EmailTriggerSID = emltgr.EmailTriggerSID
--! <MoreJoins>
join
(
	select
		sf.fToday()																											 Today
	 ,cast(isnull(sf.fConfigParam#Value('TrackEmailOpens'), 1) as bit) IsEmailOpenTracked
)																																	zx on 1 = 1
left outer join
	sf.NamePrefix																										znp on person.NamePrefixSID = znp.NamePrefixSID
left outer join
	sf.PersonEmailAddress																						zpea on person.PersonSID = zpea.PersonSID and zpea.IsPrimary = cast(1 as bit) and zpea.IsActive = cast(1 as bit)
left outer join
	sf.ApplicationGrant																							zag on em.ApplicationGrantSID = zag.ApplicationGrantSID
outer apply sf.fPersonEmailMessage#Ext(pem.PersonEmailMessageSID) zext;
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person email message assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'PersonEmailMessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sending email address for the note', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'SenderEmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is the text which will be displayed as part of the ''from'' field in a user''s email client.  E.g. In outlook the combination of a display name and the sender''s email address is displayed as ''John Doe <john.d@mailinator.com>''.', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'SenderDisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A priority level used to rank emails for sending: 1 is the highest priority, 5 is medium and 10 is lowest | This value is used to sort emails for pickup by the email sending service', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Subject of the email note', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'EmailMessageSubject'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file extension or type of document the email body is stored as | This value must match one of the registered filter types for full-text searching.  The list of document types supported is limited by the master table.  The value includes the leading period - e.g. ".HTML" Note that the default value is updated by an AFTER trigger defined on the table.', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'EmailMessageFileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of email message', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'EmailMessageFileTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the eligibility check on recipients should ensure there is an active user account (recipient must be able to sign in) | Be sure this value is set for password reset emails', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsApplicationUserRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A reference to an existing user record to use as a template for grants to apply to new user accounts created when this email is confirmed | 
Applies to user invite emails only', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'EmailMessageApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the email link assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'MessageLinkSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of hours after which any (confirmation) link included in the email is considered expired', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'LinkExpiryHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this email message', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, indicates the document is not to be mailed out. The PDF is saved to the member file for download and/or printing only.', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsGenerateOnly'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the process of finalizing the email content begins | No changes to recipients or template contents can occur after this value is set', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'MergedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this message was provided to the service for sending', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'QueuedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the email message was cancelled (not sent) after being queued but before being sent (prior to queuing the message can be deleted)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'EmailMessageCancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the email was put into archived status | Archived email remains available in the database but is not included in displays and searches by default', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'ArchivedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the email document is purged from online storage (documents can be exported at archive step)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'PurgedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the email message record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'EmailMessageRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the file type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'FileTypeFileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the file type to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'FileTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The MIME type to use when a client browser downloads or views a document.', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'MimeType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When a client browser downloads a document this indicates whether or not the browser should be asked to display rather than download the document. If the browser is unable to, due to lack of software or other settings, the file will instead be downloaded as normal.', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsInline'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this file type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'FileTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the file type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'FileTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the email trigger to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'EmailTriggerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The email template assigned to this email trigger', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'EmailTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The query assigned to this email trigger', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'QuerySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The minimum number of days the system will wait before sending out the same message associated with this trigger | This setting allows duplicate messages to be avoided for the given period of time - without requiring hardcoding the interval in the query.', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'MinDaysToRepeat'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this email trigger', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'EmailTriggerApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job schedule assigned to this email trigger', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'JobScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time processing for this specific email trigger began | This value is used in determining when the trigger should be run next when a schedule is assigned', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'LastStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the trigger completed successfully, failed, or was cancelled through the Email Trigger job | Records where this value is not filled in are considered to be running', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'LastEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The earliest date for selecting records to email where a date criteria is used in the trigger query. The selection date is the later of this value and the Last-Start-Time.', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'EarliestSelectionDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this email trigger record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'EmailTriggerIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the email trigger record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'EmailTriggerRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Virtual column to capture latest reason for change that is written into audit log column', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'ChangeReason'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if access to this email is available to the currently logged in user', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsReadGranted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The subject of the email sent | This value includes replacement values if the email was based on a template', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'SubjectSent'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The body of the email sent | This value includes replacement values if any were included in the email template', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'BodySent'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the confirmation link on the email expires', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'MessageLinkExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Hours between time the email was sent and the confirmation link was clicked (the hours waiting for user to confirm)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'ConfirmationLagHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Code identifying status of the link in the email (if any)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'MessageLinkStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Label identifying status of the link in the email (if any)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'MessageLinkStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the link is still waiting for confirmation from the user ("pending" and not cancelled)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsPending'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the link has been accepted by the user resulting in creation of a user profile ("confirmed" status)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsConfirmed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the reserve period on the link has ended ("expired" status)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsExpired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this link was revoked so that it can no longer be confirmed ("cancelled" status)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsCancelled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the email document associated wit this message has been purged (deleted) from the system', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsPurged'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether tracking of this email is enabled (cases a beacon image to be included in the content)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsEmailOpenTracked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether or not the email was "not received", usually an error in the service processing', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'IsNotReceived'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A filing label for the person based on last name, first name middle names', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'FileAsName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label for the person suitable for addressing based on name prefix (salutation) first name middle names last name', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'FullName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label for the person suitable for use on the UI and reports based on first name last name', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'DisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The age of the person reported in full years lived (the typical way we refer to how old we are)', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'AgeInYears'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The current primary email address for this person (may not be the same as the one used on the email when sent)	', 'SCHEMA', N'sf', 'VIEW', N'vPersonEmailMessage#Ext', 'COLUMN', N'CurrentEmailAddress'
GO
