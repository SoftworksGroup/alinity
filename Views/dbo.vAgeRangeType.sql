SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vAgeRangeType]
as
/*********************************************************************************************************************************
View    : dbo.vAgeRangeType
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.AgeRangeType - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.AgeRangeType table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vAgeRangeTypeExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vAgeRangeTypeExt documentation for details. To add additional content to this view, customize
the dbo.vAgeRangeTypeExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 art.AgeRangeTypeSID
	,art.AgeRangeTypeLabel
	,art.AgeRangeTypeCode
	,art.IsDefault
	,art.Description
	,art.UserDefinedColumns
	,art.AgeRangeTypeXID
	,art.LegacyKey
	,art.IsDeleted
	,art.CreateUser
	,art.CreateTime
	,art.UpdateUser
	,art.UpdateTime
	,art.RowGUID
	,art.RowStamp
	,artx.IsDeleteEnabled
	,artx.IsReselected
	,artx.IsNullApplied
	,artx.zContext
from
	dbo.AgeRangeType      art
join
	dbo.vAgeRangeType#Ext artx	on art.AgeRangeTypeSID = artx.AgeRangeTypeSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.AgeRangeType', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the age range type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'AgeRangeTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the age range type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'AgeRangeTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default age range type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'IsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this specialization type is applied to. This content is available as help text on specialization type selection. ', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the age range type | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'AgeRangeTypeXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the age range type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this age range type record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the age range type | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the age range type record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the age range type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vAgeRangeType', 'COLUMN', N'zContext'
GO
