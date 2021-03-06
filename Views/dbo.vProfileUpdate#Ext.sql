SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vProfileUpdate#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vProfileUpdate#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.ProfileUpdate base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vProfileUpdate (referred to as the "entity" view in SGI documentation).

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
	 pu.ProfileUpdateSID
	,fv.FormSID
	,fv.VersionNo
	,fv.RevisionNo
	,fv.IsSaveDisplayed
	,fv.ApprovedTime
	,fv.RowGUID                                                             FormVersionRowGUID
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
	,reason.ReasonGroupSID
	,reason.ReasonName
	,reason.ReasonCode
	,reason.ReasonSequence
	,reason.ToolTip
	,reason.IsActive                                                        ReasonIsActive
	,reason.RowGUID                                                         ReasonRowGUID
	,dbo.fProfileUpdate#IsDeleteEnabled(pu.ProfileUpdateSID)                IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
																																						--! <MoreColumns>
 ,pux.ProfileUpdateLabel																										--# A summary label for the profile update based on the member name and profile update status
 ,pux.IsViewEnabled																													--# Indicates whether either the (logged in) user or administrator can view the profile updat
 ,pux.IsEditEnabled																													--# Indicates whether the (logged in) user can edit/correct the form
 ,pux.IsSaveBtnDisplayed																										--# Indicates whether the save button is displayed on the form
 ,pux.IsApproveEnabled																											--# Indicates whether the approve button should be made available to the user
 ,pux.IsRejectEnabled																												--# Indicates whether the reject button should be made available to the user
 ,pux.IsUnlockEnabled																												--# Indicates administrator can unlock form for editing even when in certain final statuses
 ,pux.IsWithdrawalEnabled																										--# Indicates the profile update form can be withdrawn by administrators or SA's
 ,pux.IsInProgress																													--# Indicates if the form is now closed/finalized or still in progress (open)	
 ,pux.IsReviewRequired																											--# Indicates if admin review of the form is required
 ,pux.FormStatusSID																													--# Key of current/latest profile update status
 ,pux.FormStatusSCD																													--# Current/latest profile update status		
 ,pux.FormStatusLabel																												--# User-friendly name for the profile update status		
 ,pux.FormOwnerSID																													--# Key of the related sf.FormOwner record
 ,pux.FormOwnerSCD																													--# Person/group expected to perform next action to progress the form
 ,pux.FormOwnerLabel																												--# User-friendly name of person/group expected to perform next action to progress the form
 ,pux.LastStatusChangeUser																									--# Username who made the last status change
 ,pux.LastStatusChangeTime																									--# Date and time the last status change was made
 ,pux.IsPDFDisplayed																												--# Indicates if PDF form version should be displayed rather than the HTML (form is complete)
 ,pux.PersonDocSID																													--# Key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)
 ,cast(null as varchar(25))																NewFormStatusSCD	--# Used internally by the system to set the form to a new status value
--! </MoreColumns>
from
	dbo.ProfileUpdate pu
join
	sf.FormVersion    fv     on pu.FormVersionSID = fv.FormVersionSID
join
	sf.Person         person on pu.PersonSID = person.PersonSID
left outer join
	dbo.Reason        reason on pu.ReasonSID = reason.ReasonSID
--! <MoreJoins>
outer apply dbo.fProfileUpdate#Ext(pu.ProfileUpdateSID) pux;
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the profile update assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'ProfileUpdateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form this version is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'FormSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The version number of the form - e.g. 1, 2, 3, 999.  When a new version of the form is approved the version number moves up to the next whole number.  | Revision numbers are always 0 for approved versions of the form.', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'VersionNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number assigned as changes are made and saved between approved Versions of the form.  | Revision enable users to back to a previous state of the form and edit from that point.  When a form version is Approved, the form is saved, the version number is updated to the next whole number, and the revision number is set to 0. ', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'RevisionNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the Save/Save-For-Later button is displayed (otherwise only Submit is allowed) | Note that other business rules may also impact whether the Save button option is displayed', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsSaveDisplayed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this version of the form was approved for use in production.  | This value is blank for revisions of the form saved between production versions.', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'ApprovedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form version record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'FormVersionRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason group assigned to this reason', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the reason to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'ReasonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional code used to refer to this reason - most often applicable where reason coding is provided to external parties - e.g. Provider Directory, Workforce Planning authority, etc. ', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this reason record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'ReasonIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reason record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'ReasonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A summary label for the profile update based on the member name and profile update status', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'ProfileUpdateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether either the (logged in) user or administrator can view the profile updat', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsViewEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the (logged in) user can edit/correct the form', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsEditEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the save button is displayed on the form', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsSaveBtnDisplayed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the approve button should be made available to the user', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsApproveEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the reject button should be made available to the user', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsRejectEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates administrator can unlock form for editing even when in certain final statuses', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsUnlockEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the profile update form can be withdrawn by administrators or SA''s', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsWithdrawalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the form is now closed/finalized or still in progress (open)	', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsInProgress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if admin review of the form is required', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of current/latest profile update status', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to set the form to a new status value', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'FormStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User-friendly name for the profile update status		', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'FormStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of the related sf.FormOwner record', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Person/group expected to perform next action to progress the form', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'FormOwnerSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User-friendly name of person/group expected to perform next action to progress the form', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'FormOwnerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Username who made the last status change', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'LastStatusChangeUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the last status change was made', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'LastStatusChangeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates if PDF form version should be displayed rather than the HTML (form is complete)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'IsPDFDisplayed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'key of the form PDF (blank/null if the PDF is not available or form is not yet finalized)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'PersonDocSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Used internally by the system to set the form to a new status value', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdate#Ext', 'COLUMN', N'NewFormStatusSCD'
GO
