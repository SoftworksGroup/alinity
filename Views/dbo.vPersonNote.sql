SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPersonNote]
as
/*********************************************************************************************************************************
View    : dbo.vPersonNote
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.PersonNote - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.PersonNote table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vPersonNoteExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vPersonNoteExt documentation for details. To add additional content to this view, customize
the dbo.vPersonNoteExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 pn.PersonNoteSID
	,pn.PersonSID
	,pn.PersonNoteTypeSID
	,pn.NoteTitle
	,pn.NoteContent
	,pn.ShowToRegistrant
	,pn.ApplicationGrantSID
	,pn.TagList
	,pn.UserDefinedColumns
	,pn.PersonNoteXID
	,pn.LegacyKey
	,pn.IsDeleted
	,pn.CreateUser
	,pn.CreateTime
	,pn.UpdateUser
	,pn.UpdateTime
	,pn.RowGUID
	,pn.RowStamp
	,pnx.PersonNoteTypeLabel
	,pnx.PersonNoteTypeCategory
	,pnx.PersonNoteTypeIsDefault
	,pnx.PersonNoteTypeIsActive
	,pnx.PersonNoteTypeRowGUID
	,pnx.GenderSID
	,pnx.NamePrefixSID
	,pnx.FirstName
	,pnx.CommonName
	,pnx.MiddleNames
	,pnx.LastName
	,pnx.BirthDate
	,pnx.DeathDate
	,pnx.HomePhone
	,pnx.MobilePhone
	,pnx.IsTextMessagingEnabled
	,pnx.ImportBatch
	,pnx.PersonRowGUID
	,pnx.ApplicationGrantSCD
	,pnx.ApplicationGrantName
	,pnx.ApplicationGrantIsDefault
	,pnx.ApplicationGrantRowGUID
	,pnx.IsDeleteEnabled
	,pnx.IsReselected
	,pnx.IsNullApplied
	,pnx.zContext
	,pnx.IsReadGranted
	,pnx.NoteDisplayTitle
from
	dbo.PersonNote      pn
join
	dbo.vPersonNote#Ext pnx	on pn.PersonNoteSID = pnx.PersonNoteSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.PersonNote', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person note assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'PersonNoteSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this note is based on', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person note', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'PersonNoteTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Optional - may be used to specify a title for the note', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'NoteTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this note should be shown to the registrant it is related to on the client portal.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'ShowToRegistrant'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A list of tags used to classify the note and to support filtering and searching', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'TagList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person note | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'PersonNoteXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person note | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person note record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person note | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person note record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person note record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the person note type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'PersonNoteTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'PersonNoteTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default person note type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'PersonNoteTypeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this person note type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'PersonNoteTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person note type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'PersonNoteTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application grant | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'ApplicationGrantSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application grant to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'ApplicationGrantName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default application grant to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'ApplicationGrantIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application grant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'ApplicationGrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the current session user has access to view the note record', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'IsReadGranted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A title for the note - uses first part of note content if no title specified', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNote', 'COLUMN', N'NoteDisplayTitle'
GO