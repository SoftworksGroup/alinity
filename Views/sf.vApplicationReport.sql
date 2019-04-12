SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vApplicationReport]
as
/*********************************************************************************************************************************
View    : sf.vApplicationReport
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.ApplicationReport - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.ApplicationReport table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vApplicationReportExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vApplicationReportExt documentation for details. To add additional content to this view, customize
the sf.vApplicationReportExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ar.ApplicationReportSID
	,ar.ApplicationReportName
	,ar.IconPathData
	,ar.IconFillColor
	,ar.DisplayRank
	,ar.ReportDefinition
	,ar.ReportParameters
	,ar.IsCustom
	,ar.UserDefinedColumns
	,ar.ApplicationReportXID
	,ar.LegacyKey
	,ar.IsDeleted
	,ar.CreateUser
	,ar.CreateTime
	,ar.UpdateUser
	,ar.UpdateTime
	,ar.RowGUID
	,ar.RowStamp
	,arx.IsDeleteEnabled
	,arx.IsReselected
	,arx.IsNullApplied
	,arx.zContext
from
	sf.ApplicationReport      ar
join
	sf.vApplicationReport#Ext arx	on ar.ApplicationReportSID = arx.ApplicationReportSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.ApplicationReport', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application report assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'ApplicationReportSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application report to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'ApplicationReportName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Coorindate data (technical) that describes the icon to display for the report in the charm bar', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'IconPathData'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A 9 character value that describes the color the icon should be displayed in on the charm bar', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'IconFillColor'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Controls the order this report appears in within report menus (built-in and custom reports are separated)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'DisplayRank'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The "report definition language" (RDL) file that describes the report', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'ReportDefinition'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML structure used to store parameter names, data types, and other information needed to prompt the user for selection criteria to apply in the report| Parameter names must match property names in the entity  - e.g. the parameter "@FacilitySID" would be replaced by the key of the facility record if one were selected in the user interface at the time the report is called.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'ReportParameters'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, indicates this report was added specificially to the configuration and is not a built-in product report', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'IsCustom'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application report | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'ApplicationReportXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application report | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application report record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application report | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application report record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application report record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationReport', 'COLUMN', N'zContext'
GO
