SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vAgeRange]
as
/*********************************************************************************************************************************
View    : dbo.vAgeRange
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.AgeRange - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.AgeRange table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vAgeRangeExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vAgeRangeExt documentation for details. To add additional content to this view, customize
the dbo.vAgeRangeExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ar.AgeRangeSID
	,ar.AgeRangeTypeSID
	,ar.AgeRangeLabel
	,ar.StartAge
	,ar.EndAge
	,ar.IsDefault
	,ar.UserDefinedColumns
	,ar.AgeRangeXID
	,ar.LegacyKey
	,ar.IsDeleted
	,ar.CreateUser
	,ar.CreateTime
	,ar.UpdateUser
	,ar.UpdateTime
	,ar.RowGUID
	,ar.RowStamp
	,arx.AgeRangeTypeLabel
	,arx.AgeRangeTypeCode
	,arx.AgeRangeTypeIsDefault
	,arx.AgeRangeTypeRowGUID
	,arx.IsDeleteEnabled
	,arx.IsReselected
	,arx.IsNullApplied
	,arx.zContext
	,arx.DisplayOrder
from
	dbo.AgeRange      ar
join
	dbo.vAgeRange#Ext arx	on ar.AgeRangeSID = arx.AgeRangeSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.AgeRange', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the age range assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'AgeRangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the age range type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'AgeRangeTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the age range to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'AgeRangeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Starting age in years for the range', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'StartAge'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ending age in years for the range', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'EndAge'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default age range to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the age range | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'AgeRangeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the age range | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this age range record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the age range | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the age range record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the age range record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the age range type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'AgeRangeTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default age range type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'AgeRangeTypeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the age range type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'AgeRangeTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A sequence number for ordering display of the values (by starting age of the range)', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRange', 'COLUMN', N'DisplayOrder'
GO
