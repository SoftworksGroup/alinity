SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vFileFormat]
as
/*********************************************************************************************************************************
View    : sf.vFileFormat
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.FileFormat - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.FileFormat table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vFileFormatExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vFileFormatExt documentation for details. To add additional content to this view, customize
the sf.vFileFormatExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ff.FileFormatSID
	,ff.FileFormatSCD
	,ff.FileFormatLabel
	,ff.IsDefault
	,ff.UserDefinedColumns
	,ff.FileFormatXID
	,ff.LegacyKey
	,ff.IsDeleted
	,ff.CreateUser
	,ff.CreateTime
	,ff.UpdateUser
	,ff.UpdateTime
	,ff.RowGUID
	,ff.RowStamp
	,ffx.IsDeleteEnabled
	,ffx.IsReselected
	,ffx.IsNullApplied
	,ffx.zContext
from
	sf.FileFormat      ff
join
	sf.vFileFormat#Ext ffx	on ff.FileFormatSID = ffx.FileFormatSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.FileFormat', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the file format assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'FileFormatSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the file format | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'FileFormatSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the file format to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'FileFormatLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default file format to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the file format | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'FileFormatXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the file format | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this file format record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the file format | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the file format record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the file format record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vFileFormat', 'COLUMN', N'zContext'
GO