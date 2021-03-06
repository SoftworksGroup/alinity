SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vPersonTextMessage#Ext]
as
/*********************************************************************************************************************************
View    : sf.vPersonTextMessage#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the sf.PersonTextMessage base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vPersonTextMessage (referred to as the "entity" view in SGI documentation).

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
	 ptm.PersonTextMessageSID
	,person.GenderSID
	,person.NamePrefixSID
	,person.FirstName
	,person.CommonName
	,person.MiddleNames
	,person.LastName
	,person.BirthDate
	,person.DeathDate
	,person.HomePhone
	,person.MobilePhone                                                     PersonMobilePhone
	,person.IsTextMessagingEnabled
	,person.ImportBatch
	,person.RowGUID                                                         PersonRowGUID
	,tm.SenderPhone
	,tm.SenderDisplayName
	,tm.PriorityLevel
	,tm.Body                                                                TextMessageBody
	,tm.IsApplicationUserRequired
	,tm.ApplicationUserSID                                                  TextMessageApplicationUserSID
	,tm.MessageLinkSID
	,tm.LinkExpiryHours
	,tm.ApplicationEntitySID
	,tm.MergedTime
	,tm.QueuedTime
	,tm.CancelledTime                                                       TextMessageCancelledTime
	,tm.ArchivedTime
	,tm.RowGUID                                                             TextMessageRowGUID
	,ttgr.TextTriggerLabel
	,ttgr.TextTemplateSID
	,ttgr.QuerySID
	,ttgr.MinDaysToRepeat
	,ttgr.ApplicationUserSID                                                TextTriggerApplicationUserSID
	,ttgr.JobScheduleSID
	,ttgr.LastStartTime
	,ttgr.LastEndTime
	,ttgr.IsActive                                                          TextTriggerIsActive
	,ttgr.RowGUID                                                           TextTriggerRowGUID
	,cast(null as nvarchar(4000))                                           ChangeReason							--# Virtual column to capture latest reason for change that is written into audit log column
	,sf.fPersonTextMessage#IsDeleteEnabled(ptm.PersonTextMessageSID)        IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
	,isnull(ptm.Body, tm.Body)																							BodySent									--# The body of the text sent | This value includes replacement values if any were included in the text template
	,zext.MessageLinkExpiryTime																																				--# Date and time the confirmation link on the text expires
	,zext.ConfirmationLagHours																																				--# Hours between time the text was sent and the confirmation link was clicked (the hours waiting for user to confirm)
	,zext.MessageLinkStatusSCD																																				--# Code identifying status of the link in the text (if any)
	,zext.MessageLinkStatusLabel																																			--# Label identifying status of the link in the text (if any)
	,zext.IsPending																																										--# Indicates whether the link is still waiting for confirmation from the user ("pending" and not cancelled)
	,zext.IsConfirmed																																									--# Indicates whether the link has been accepted by the user resulting in creation of a user profile ("confirmed" status)
	,zext.IsExpired																																										--# Indicates whether the reserve period on the link has ended ("expired" status)
	,zext.IsCancelled																																									--# Indicates whether this link was revoked so that it can no longer be confirmed ("cancelled" status)
	,sf.fFormatFileAsName(person.LastName,person.FirstName, person.MiddleNames)												FileAsName	--# A filing label for the person based on last name, first name middle names
	,sf.fFormatFullName(person.LastName, person.FirstName, person.MiddleNames, znp.NamePrefixLabel)		FullName		--# A label for the person suitable for addressing based on name prefix (salutation) first name middle names last name
	,sf.fFormatDisplayName(person.LastName, isnull(person.CommonName, person.FirstName))							DisplayName	--# A label for the person suitable for use on the UI and reports based on first name last name
  ,sf.fAgeInYears(person.BirthDate,sf.fToday())																											AgeInYears	--# The age of the person reported in full years lived (the typical way we refer to how old we are)
  --! </MoreColumns>
from
	sf.PersonTextMessage ptm
join
	sf.Person            person on ptm.PersonSID = person.PersonSID
join
	sf.TextMessage       tm     on ptm.TextMessageSID = tm.TextMessageSID
left outer join
	sf.TextTrigger       ttgr   on ptm.TextTriggerSID = ttgr.TextTriggerSID
--! <MoreJoins>
left outer join
	sf.NamePrefix					znp   on person.NamePrefixSID = znp.NamePrefixSID
cross apply
	sf.fPersonTextMessage#Ext(ptm.PersonTextMessageSID) zext
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person text message assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'PersonTextMessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sending phone number for the message', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'SenderPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This is an information only field that shows the owner of the phone number used to send the message | This value cannot be sent to the recipient except as a replacement (merge) value', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'SenderDisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A priority level used to rank texts for sending: 1 is the highest priority, 5 is medium and 10 is lowest | This value is used to sort texts for pickup by the text sending service', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Body of the text note ', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'TextMessageBody'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the eligibility check on recipients should ensure there is an active user account (recipient must be able to sign in) | Be sure this value is set for password reset texts', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'IsApplicationUserRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A reference to an existing user record to use as a template for grants to apply to new user accounts created when this text is confirmed | 
Applies to user invite texts only', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'TextMessageApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the text link assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'MessageLinkSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of hours after which any (confirmation) link included in the text is considered expired', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'LinkExpiryHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this text message', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the process of finalizing the text content begins | No changes to recipients or template contents can occur after this value is set', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'MergedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this message was provided to the service for sending', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'QueuedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the text message was cancelled (not sent) after being queued but before being sent (prior to queuing the message can be deleted)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'TextMessageCancelledTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the text was put into archived status | Archived text remains available in the database but is not included in displays and searches by default', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'ArchivedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the text message record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'TextMessageRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the text trigger to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'TextTriggerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The text template assigned to this text trigger', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'TextTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The query assigned to this text trigger', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'QuerySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The minimum number of days the system will wait before sending out the same message associated with this trigger | This setting allows duplicate messages to be avoided for the given period of time - without requiring hardcoding the interval in the query.', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'MinDaysToRepeat'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this text trigger', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'TextTriggerApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job schedule assigned to this text trigger', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'JobScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time processing for this specific email trigger began | This value is used in determining when the trigger should be run next when a schedule is assigned', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'LastStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the trigger completed successfully, failed, or was cancelled through the TextMessage Trigger job | Records where this value is not filled in are considered to be running', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'LastEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this text trigger record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'TextTriggerIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the text trigger record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'TextTriggerRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Virtual column to capture latest reason for change that is written into audit log column', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'ChangeReason'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The body of the text sent | This value includes replacement values if any were included in the text template', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'BodySent'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the confirmation link on the text expires', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'MessageLinkExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Hours between time the text was sent and the confirmation link was clicked (the hours waiting for user to confirm)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'ConfirmationLagHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Code identifying status of the link in the text (if any)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'MessageLinkStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Label identifying status of the link in the text (if any)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'MessageLinkStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the link is still waiting for confirmation from the user ("pending" and not cancelled)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'IsPending'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the link has been accepted by the user resulting in creation of a user profile ("confirmed" status)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'IsConfirmed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the reserve period on the link has ended ("expired" status)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'IsExpired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this link was revoked so that it can no longer be confirmed ("cancelled" status)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'IsCancelled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A filing label for the person based on last name, first name middle names', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'FileAsName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label for the person suitable for addressing based on name prefix (salutation) first name middle names last name', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'FullName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label for the person suitable for use on the UI and reports based on first name last name', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'DisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The age of the person reported in full years lived (the typical way we refer to how old we are)', 'SCHEMA', N'sf', 'VIEW', N'vPersonTextMessage#Ext', 'COLUMN', N'AgeInYears'
GO
