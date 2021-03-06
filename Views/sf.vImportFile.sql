SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vImportFile]
as
/*********************************************************************************************************************************
View    : sf.vImportFile
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.ImportFile - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.ImportFile table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vImportFileExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vImportFileExt documentation for details. To add additional content to this view, customize
the sf.vImportFileExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 imp.ImportFileSID
	,imp.FileFormatSID
	,imp.ApplicationEntitySID
	,imp.FileName
	,imp.FileContent
	,imp.LoadStartTime
	,imp.LoadEndTime
	,imp.IsFailed
	,imp.MessageText
	,imp.UserDefinedColumns
	,imp.ImportFileXID
	,imp.LegacyKey
	,imp.IsDeleted
	,imp.CreateUser
	,imp.CreateTime
	,imp.UpdateUser
	,imp.UpdateTime
	,imp.RowGUID
	,imp.RowStamp
	,impx.ApplicationEntitySCD
	,impx.ApplicationEntityName
	,impx.IsMergeDataSource
	,impx.ApplicationEntityRowGUID
	,impx.FileFormatSCD
	,impx.FileFormatLabel
	,impx.FileFormatIsDefault
	,impx.FileFormatRowGUID
	,impx.IsDeleteEnabled
	,impx.IsReselected
	,impx.IsNullApplied
	,impx.zContext
	,impx.IsComplete
	,impx.IsInProcess
	,impx.MinutesInProcess
	,impx.FileLength
from
	sf.ImportFile      imp
join
	sf.vImportFile#Ext impx	on imp.ImportFileSID = impx.ImportFileSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.ImportFile', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the import file assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'ImportFileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file format assigned to this import file', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'FileFormatSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this import file', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the source file the import was read from (not necessarily unique).', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'FileName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The content to be imported (cleared after import)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'FileContent'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the import service picked up the job for importing (start of import)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'LoadStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the import of the file was completed successfully | Value is blank if Is-Failed is ON', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'LoadEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the import of this file failed or was cancelled by the user.', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'IsFailed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Summary of processing result (blank until processing is attempted).', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'MessageText'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the import file | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'ImportFileXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the import file | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this import file record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the import file | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the import file record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the import file record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application entity | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'ApplicationEntitySCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application entity to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'ApplicationEntityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this application entity should be a source of replacement values for note templates | Only the core entities of the application should be established as merge-field data sources ', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'IsMergeDataSource'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application entity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'ApplicationEntityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the file format | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'FileFormatSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the file format to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'FileFormatLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default file format to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'FileFormatIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the file format record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'FileFormatRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the import is complete', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'IsComplete'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if  the import is in process', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'IsInProcess'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates how long import has been running', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'MinutesInProcess'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Size in bytes of the import file', 'SCHEMA', N'sf', 'VIEW', N'vImportFile', 'COLUMN', N'FileLength'
GO
