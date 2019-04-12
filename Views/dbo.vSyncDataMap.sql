SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSyncDataMap]
as
/*********************************************************************************************************************************
View    : dbo.vSyncDataMap
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.SyncDataMap - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.SyncDataMap table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vSyncDataMapExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vSyncDataMapExt documentation for details. To add additional content to this view, customize
the dbo.vSyncDataMapExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 sdm.SyncDataMapSID
	,sdm.ApplicationEntitySID
	,sdm.SyncMode
	,sdm.IsDeleteProcessed
	,sdm.IsEnabled
	,sdm.UserDefinedColumns
	,sdm.SyncDataMapXID
	,sdm.LegacyKey
	,sdm.IsDeleted
	,sdm.CreateUser
	,sdm.CreateTime
	,sdm.UpdateUser
	,sdm.UpdateTime
	,sdm.RowGUID
	,sdm.RowStamp
	,sdmx.ApplicationEntitySCD
	,sdmx.ApplicationEntityName
	,sdmx.IsMergeDataSource
	,sdmx.ApplicationEntityRowGUID
	,sdmx.IsDeleteEnabled
	,sdmx.IsReselected
	,sdmx.IsNullApplied
	,sdmx.zContext
from
	dbo.SyncDataMap      sdm
join
	dbo.vSyncDataMap#Ext sdmx	on sdm.SyncDataMapSID = sdmx.SyncDataMapSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.SyncDataMap', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the sync data map assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'SyncDataMapSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this sync data map', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The direction of the sync:  PUSH to push Alinity changes to the legacy database or PULL to update Alinity with external changes.', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'SyncMode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion actions (which may only inactivate records) is to be processed on the target database', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'IsDeleteProcessed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Turn off this setting to disable the synchronization in order to correct errors, while allowing other synchronizations to proceed.', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'IsEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the sync data map | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'SyncDataMapXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the sync data map | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this sync data map record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the sync data map | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the sync data map record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the sync data map record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application entity | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'ApplicationEntitySCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application entity to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'ApplicationEntityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this application entity should be a source of replacement values for note templates | Only the core entities of the application should be established as merge-field data sources ', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'IsMergeDataSource'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application entity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'ApplicationEntityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vSyncDataMap', 'COLUMN', N'zContext'
GO
