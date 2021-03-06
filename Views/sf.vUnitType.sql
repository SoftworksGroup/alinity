SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vUnitType]
as
/*********************************************************************************************************************************
View    : sf.vUnitType
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.UnitType - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.UnitType table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vUnitTypeExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vUnitTypeExt documentation for details. To add additional content to this view, customize
the sf.vUnitTypeExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 utype.UnitTypeSID
	,utype.UnitTypeLabel
	,utype.IsDefault
	,utype.IsActive
	,utype.UserDefinedColumns
	,utype.UnitTypeXID
	,utype.LegacyKey
	,utype.IsDeleted
	,utype.CreateUser
	,utype.CreateTime
	,utype.UpdateUser
	,utype.UpdateTime
	,utype.RowGUID
	,utype.RowStamp
	,utypex.IsDeleteEnabled
	,utypex.IsReselected
	,utypex.IsNullApplied
	,utypex.zContext
from
	sf.UnitType      utype
join
	sf.vUnitType#Ext utypex	on utype.UnitTypeSID = utypex.UnitTypeSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.UnitType', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the unit type assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'UnitTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the unit type to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'UnitTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default unit type to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this unit type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the unit type | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'UnitTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the unit type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this unit type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the unit type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the unit type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the unit type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vUnitType', 'COLUMN', N'zContext'
GO
