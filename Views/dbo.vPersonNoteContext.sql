SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPersonNoteContext]
as
/*********************************************************************************************************************************
View    : dbo.vPersonNoteContext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.PersonNoteContext - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.PersonNoteContext table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vPersonNoteContextExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vPersonNoteContextExt documentation for details. To add additional content to this view, customize
the dbo.vPersonNoteContextExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 pnc.PersonNoteContextSID
	,pnc.PersonNoteSID
	,pnc.ApplicationEntitySID
	,pnc.EntitySID
	,pnc.UserDefinedColumns
	,pnc.PersonNoteContextXID
	,pnc.LegacyKey
	,pnc.IsDeleted
	,pnc.CreateUser
	,pnc.CreateTime
	,pnc.UpdateUser
	,pnc.UpdateTime
	,pnc.RowGUID
	,pnc.RowStamp
	,pncx.PersonSID
	,pncx.PersonNoteTypeSID
	,pncx.NoteTitle
	,pncx.ShowToRegistrant
	,pncx.ApplicationGrantSID
	,pncx.PersonNoteRowGUID
	,pncx.ApplicationEntitySCD
	,pncx.ApplicationEntityName
	,pncx.IsMergeDataSource
	,pncx.ApplicationEntityRowGUID
	,pncx.IsDeleteEnabled
	,pncx.IsReselected
	,pncx.IsNullApplied
	,pncx.zContext
from
	dbo.PersonNoteContext      pnc
join
	dbo.vPersonNoteContext#Ext pncx	on pnc.PersonNoteContextSID = pncx.PersonNoteContextSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.PersonNoteContext', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person note context assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'PersonNoteContextSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person note this context is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'PersonNoteSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this person note context', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The SID of the related entity. The query to get the entity row can be determined by the entity type (ApplicationEntitySID).', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'EntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person note context | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'PersonNoteContextXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person note context | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person note context record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person note context | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person note context record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person note context record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this note is based on', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of person note', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'PersonNoteTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Optional - may be used to specify a title for the note', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'NoteTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this note should be shown to the registrant it is related to on the client portal.', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'ShowToRegistrant'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person note record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'PersonNoteRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application entity | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'ApplicationEntitySCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application entity to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'ApplicationEntityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this application entity should be a source of replacement values for note templates | Only the core entities of the application should be established as merge-field data sources ', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'IsMergeDataSource'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application entity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'ApplicationEntityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPersonNoteContext', 'COLUMN', N'zContext'
GO
