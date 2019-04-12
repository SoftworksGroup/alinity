SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vComplainantType]
as
/*********************************************************************************************************************************
View    : dbo.vComplainantType
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.ComplainantType - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.ComplainantType table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vComplainantTypeExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vComplainantTypeExt documentation for details. To add additional content to this view, customize
the dbo.vComplainantTypeExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ctype.ComplainantTypeSID
	,ctype.ComplainantTypeLabel
	,ctype.ComplainantTypeCategory
	,ctype.IsDefault
	,ctype.Description
	,ctype.IsActive
	,ctype.UserDefinedColumns
	,ctype.ComplainantTypeXID
	,ctype.LegacyKey
	,ctype.IsDeleted
	,ctype.CreateUser
	,ctype.CreateTime
	,ctype.UpdateUser
	,ctype.UpdateTime
	,ctype.RowGUID
	,ctype.RowStamp
	,ctypex.IsDeleteEnabled
	,ctypex.IsReselected
	,ctypex.IsNullApplied
	,ctypex.zContext
from
	dbo.ComplainantType      ctype
join
	dbo.vComplainantType#Ext ctypex	on ctype.ComplainantTypeSID = ctypex.ComplainantTypeSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.ComplainantType', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the complainant type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'ComplainantTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the complainant type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'ComplainantTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'ComplainantTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default complainant type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this specialization type is applied to. This content is available as help text on specialization type selection. ', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this complainant type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the complainant type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'ComplainantTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the complainant type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this complainant type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the complainant type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the complainant type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complainant type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vComplainantType', 'COLUMN', N'zContext'
GO
