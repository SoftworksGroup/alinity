SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vCompetenceTypeActivity]
as
/*********************************************************************************************************************************
View    : dbo.vCompetenceTypeActivity
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.CompetenceTypeActivity - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.CompetenceTypeActivity table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vCompetenceTypeActivityExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vCompetenceTypeActivityExt documentation for details. To add additional content to this view, customize
the dbo.vCompetenceTypeActivityExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 cta.CompetenceTypeActivitySID
	,cta.CompetenceTypeSID
	,cta.CompetenceActivitySID
	,cta.EffectiveTime
	,cta.ExpiryTime
	,cta.UserDefinedColumns
	,cta.CompetenceTypeActivityXID
	,cta.LegacyKey
	,cta.IsDeleted
	,cta.CreateUser
	,cta.CreateTime
	,cta.UpdateUser
	,cta.UpdateTime
	,cta.RowGUID
	,cta.RowStamp
	,ctax.CompetenceActivityLabel
	,ctax.CompetenceActivityName
	,ctax.UnitValue
	,ctax.CompetenceActivityIsActive
	,ctax.CompetenceActivityRowGUID
	,ctax.CompetenceTypeLabel
	,ctax.CompetenceTypeCategory
	,ctax.CompetenceTypeIsDefault
	,ctax.CompetenceTypeIsActive
	,ctax.CompetenceTypeRowGUID
	,ctax.IsActive
	,ctax.IsPending
	,ctax.IsDeleteEnabled
	,ctax.IsReselected
	,ctax.IsNullApplied
	,ctax.zContext
	,ctax.CompetenceActivityXID
from
	dbo.CompetenceTypeActivity      cta
join
	dbo.vCompetenceTypeActivity#Ext ctax	on cta.CompetenceTypeActivitySID = ctax.CompetenceTypeActivitySID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.CompetenceTypeActivity', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the competence type activity assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceTypeActivitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the competence type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The competence activity assigned to this competence type activity', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceActivitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this restriction/condition was put into effect or most recently changed | Check Change Audit column for history', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last day this Competence can be selected for learning plans and renewal reporting (only applies when Competence Type is "Active")', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the competence type activity | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceTypeActivityXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the competence type activity | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this competence type activity record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the competence type activity | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the competence type activity record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the competence type activity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the competence activity to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceActivityLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the competence activity to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceActivityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'If the competence has a fixed value - e.g. "3 credits" -  enter it here.  Otherwise (when 0), the registrant will be able to enter the value of the item on their Learning Plan or Competency Claim.', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'UnitValue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this competence activity record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceActivityIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the competence activity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceActivityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the competence type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default competence type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceTypeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this competence type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the competence type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'CompetenceTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment is currently active (not expired or future dated)', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment will come into effect in the future', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'IsPending'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vCompetenceTypeActivity', 'COLUMN', N'zContext'
GO
