SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vBusinessRuleError]
as
/*********************************************************************************************************************************
View    : sf.vBusinessRuleError
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.BusinessRuleError - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.BusinessRuleError table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vBusinessRuleErrorExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vBusinessRuleErrorExt documentation for details. To add additional content to this view, customize
the sf.vBusinessRuleErrorExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 bre.BusinessRuleErrorSID
	,bre.BusinessRuleSID
	,bre.MessageText
	,bre.SourceSID
	,bre.SourceGUID
	,bre.UserDefinedColumns
	,bre.BusinessRuleErrorXID
	,bre.LegacyKey
	,bre.IsDeleted
	,bre.CreateUser
	,bre.CreateTime
	,bre.UpdateUser
	,bre.UpdateTime
	,bre.RowGUID
	,bre.RowStamp
	,brex.ApplicationEntitySID
	,brex.MessageSID
	,brex.ColumnName
	,brex.BusinessRuleStatus
	,brex.BusinessRuleRowGUID
	,brex.IsDeleteEnabled
	,brex.IsReselected
	,brex.IsNullApplied
	,brex.zContext
	,brex.MessageSCD
	,brex.ApplicationEntitySCD
from
	sf.BusinessRuleError      bre
join
	sf.vBusinessRuleError#Ext brex	on bre.BusinessRuleErrorSID = brex.BusinessRuleErrorSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.BusinessRuleError', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the business rule error assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'BusinessRuleErrorSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The business rule this error is defined for', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'BusinessRuleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the business rule error | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'BusinessRuleErrorXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the business rule error | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this business rule error record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the business rule error | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the business rule error record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the business rule error record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this business rule', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The message assigned to this business rule', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'MessageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The column name the rule applies to.  Required to distinguish betweeen rules when the same message is used on multiple columns in the same table.  If a rule involves multiple columns, choose the first column involved as it appears in the UI.', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'ColumnName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates whether rule is o-n, x-off, or p-ending (turned on but rule check not yet run on table)', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'BusinessRuleStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the business rule record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'BusinessRuleRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vBusinessRuleError', 'COLUMN', N'zContext'
GO
