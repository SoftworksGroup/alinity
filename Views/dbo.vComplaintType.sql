SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vComplaintType]
as
/*********************************************************************************************************************************
View    : dbo.vComplaintType
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.ComplaintType - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.ComplaintType table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vComplaintTypeExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vComplaintTypeExt documentation for details. To add additional content to this view, customize
the dbo.vComplaintTypeExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ctype.ComplaintTypeSID
	,ctype.ComplaintTypeLabel
	,ctype.ComplaintTypeCategory
	,ctype.IsDefault
	,ctype.Description
	,ctype.IsActive
	,ctype.UserDefinedColumns
	,ctype.ComplaintTypeXID
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
	dbo.ComplaintType      ctype
join
	dbo.vComplaintType#Ext ctypex	on ctype.ComplaintTypeSID = ctypex.ComplaintTypeSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.ComplaintType', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the complaint type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'ComplaintTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the complaint type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'ComplaintTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'ComplaintTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default complaint type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this specialization type is applied to. This content is available as help text on specialization type selection. ', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this complaint type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the complaint type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'ComplaintTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the complaint type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this complaint type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the complaint type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the complaint type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaintType', 'COLUMN', N'zContext'
GO