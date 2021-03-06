SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegion]
as
/*********************************************************************************************************************************
View    : dbo.vRegion
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.Region - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.Region table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vRegionExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vRegionExt documentation for details. To add additional content to this view, customize
the dbo.vRegionExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 region.RegionSID
	,region.RegionLabel
	,region.RegionName
	,region.IsDefault
	,region.IsActive
	,region.UserDefinedColumns
	,region.RegionXID
	,region.LegacyKey
	,region.IsDeleted
	,region.CreateUser
	,region.CreateTime
	,region.UpdateUser
	,region.UpdateTime
	,region.RowGUID
	,region.RowStamp
	,regionx.IsDeleteEnabled
	,regionx.IsReselected
	,regionx.IsNullApplied
	,regionx.zContext
from
	dbo.Region      region
join
	dbo.vRegion#Ext regionx	on region.RegionSID = regionx.RegionSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.Region', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the region assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the region to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'RegionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the region to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'RegionName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default region to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this region record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the region | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'RegionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the region | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this region record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the region | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the region record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the region record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegion', 'COLUMN', N'zContext'
GO
