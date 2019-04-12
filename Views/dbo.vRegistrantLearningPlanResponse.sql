SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantLearningPlanResponse]
as
/*********************************************************************************************************************************
View    : dbo.vRegistrantLearningPlanResponse
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.RegistrantLearningPlanResponse - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.RegistrantLearningPlanResponse table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vRegistrantLearningPlanResponseExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vRegistrantLearningPlanResponseExt documentation for details. To add additional content to this view, customize
the dbo.vRegistrantLearningPlanResponseExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 rlpr.RegistrantLearningPlanResponseSID
	,rlpr.RegistrantLearningPlanSID
	,rlpr.FormOwnerSID
	,rlpr.FormResponse
	,rlpr.UserDefinedColumns
	,rlpr.RegistrantLearningPlanResponseXID
	,rlpr.LegacyKey
	,rlpr.IsDeleted
	,rlpr.CreateUser
	,rlpr.CreateTime
	,rlpr.UpdateUser
	,rlpr.UpdateTime
	,rlpr.RowGUID
	,rlpr.RowStamp
	,rlprx.RegistrantSID
	,rlprx.RegistrationYear
	,rlprx.LearningModelSID
	,rlprx.FormVersionSID
	,rlprx.LastValidateTime
	,rlprx.NextFollowUp
	,rlprx.ReasonSID
	,rlprx.IsAutoApprovalEnabled
	,rlprx.ParentRowGUID
	,rlprx.RegistrantLearningPlanRowGUID
	,rlprx.FormOwnerSCD
	,rlprx.FormOwnerLabel
	,rlprx.IsAssignee
	,rlprx.FormOwnerRowGUID
	,rlprx.IsDeleteEnabled
	,rlprx.IsReselected
	,rlprx.IsNullApplied
	,rlprx.zContext
	,rlprx.DisplayName
from
	dbo.RegistrantLearningPlanResponse      rlpr
join
	dbo.vRegistrantLearningPlanResponse#Ext rlprx	on rlpr.RegistrantLearningPlanResponseSID = rlprx.RegistrantLearningPlanResponseSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.RegistrantLearningPlanResponse', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant learning plan response assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'RegistrantLearningPlanResponseSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant learning plan assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'RegistrantLearningPlanSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form owner assigned to this registrant learning plan response', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant learning plan response | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'RegistrantLearningPlanResponseXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant learning plan response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant learning plan response record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant learning plan response | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant learning plan response record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant learning plan response record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant this learning plan is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The learning model assigned to this registrant learning plan', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'LearningModelSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the form content successfully passed validations', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'LastValidateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when the next follow-up is required on the form.  Leave blank if no follow-up required.  When this date is reached the record appears on the Administrators list for "next-to-act".', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'NextFollowUp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this registrant learning plan', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is set by customized rules in the form configuration to enable automatic approval of the form when required conditions have been met.  If all forms should be reviewed by adminsitrators, then the value is left turned off by the form. Note that the condition of making payment (e.g. to pay for the form if charges apply) is automatically taken into account and need not be addressed in the form configuration. It is possible to block automatic approval on any registrant through their profile.  That setting overrides the setting recorded here by rules in the form.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'IsAutoApprovalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The unique identifier of the parent form (typically a renewal or reinstatement) the Learning Plan is connected to.  | Null (blank) if this learning plan form is not part of a form-set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'ParentRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant learning plan record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'RegistrantLearningPlanRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the form owner | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'FormOwnerSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form owner to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'FormOwnerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this owner is a sub-type of assignee', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'IsAssignee'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form owner record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'FormOwnerRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the user who saved this version of the form', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantLearningPlanResponse', 'COLUMN', N'DisplayName'
GO
