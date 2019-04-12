SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vFormList]
as
/*********************************************************************************************************************************
View    : sf.vFormList
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.FormList - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.FormList table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vFormListExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vFormListExt documentation for details. To add additional content to this view, customize
the sf.vFormListExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 fl.FormListSID
	,fl.FormListCode
	,fl.FormListLabel
	,fl.ToolTip
	,fl.UserDefinedColumns
	,fl.FormListXID
	,fl.LegacyKey
	,fl.IsDeleted
	,fl.CreateUser
	,fl.CreateTime
	,fl.UpdateUser
	,fl.UpdateTime
	,fl.RowGUID
	,fl.RowStamp
	,flx.IsDeleteEnabled
	,flx.IsReselected
	,flx.IsNullApplied
	,flx.zContext
from
	sf.FormList      fl
join
	sf.vFormList#Ext flx	on fl.FormListSID = flx.FormListSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.FormList', 'SCHEMA', N'sf', 'VIEW', N'vFormList', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form list assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'FormListSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code used to identify the list when referenced within a form.  DO NOT change this value without first ensuring any forms relying on it have been updated.', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'FormListCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form list to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'FormListLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Guidance about the intended use of thd form.  This value appears as help text when forms are being selected by end users and also by administrators who maintain the form.', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'ToolTip'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the form list | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'FormListXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the form list | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this form list record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the form list | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the form list record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form list record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vFormList', 'COLUMN', N'zContext'
GO
