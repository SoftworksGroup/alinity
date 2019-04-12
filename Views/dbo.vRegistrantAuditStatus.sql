SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantAuditStatus]
as
/*********************************************************************************************************************************
View    : dbo.vRegistrantAuditStatus
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.RegistrantAuditStatus - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.RegistrantAuditStatus table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vRegistrantAuditStatusExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vRegistrantAuditStatusExt documentation for details. To add additional content to this view, customize
the dbo.vRegistrantAuditStatusExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 ras.RegistrantAuditStatusSID
	,ras.RegistrantAuditSID
	,ras.FormStatusSID
	,ras.UserDefinedColumns
	,ras.RegistrantAuditStatusXID
	,ras.LegacyKey
	,ras.IsDeleted
	,ras.CreateUser
	,ras.CreateTime
	,ras.UpdateUser
	,ras.UpdateTime
	,ras.RowGUID
	,ras.RowStamp
	,rasx.RegistrantSID
	,rasx.AuditTypeSID
	,rasx.RegistrationYear
	,rasx.FormVersionSID
	,rasx.LastValidateTime
	,rasx.NextFollowUp
	,rasx.ReasonSID
	,rasx.IsAutoApprovalEnabled
	,rasx.RegistrantAuditRowGUID
	,rasx.FormStatusSCD
	,rasx.FormStatusLabel
	,rasx.IsFinal
	,rasx.FormStatusIsDefault
	,rasx.FormStatusSequence
	,rasx.FormOwnerSID
	,rasx.FormStatusRowGUID
	,rasx.IsDeleteEnabled
	,rasx.IsReselected
	,rasx.IsNullApplied
	,rasx.zContext
from
	dbo.RegistrantAuditStatus      ras
join
	dbo.vRegistrantAuditStatus#Ext rasx	on ras.RegistrantAuditStatusSID = rasx.RegistrantAuditStatusSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.RegistrantAuditStatus', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant audit status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'RegistrantAuditStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the competence audit assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'RegistrantAuditSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant audit status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'RegistrantAuditStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant audit status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant audit status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant audit status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant audit status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant audit status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of registrant audit', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'AuditTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the form content successfully passed validations', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'LastValidateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when the next follow-up is required on the form.  Leave blank if no follow-up required.  When this date is reached the record appears on the Administrators list for "next-to-act".', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'NextFollowUp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this registrant audit', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is set by customized rules in the form configuration to enable automatic approval of the form when required conditions have been met.  If all forms should be reviewed by adminsitrators, then the value is left turned off by the form. Note that the condition of making payment (e.g. to pay for the form if charges apply) is automatically taken into account and need not be addressed in the form configuration. It is possible to block automatic approval on any registrant through their profile.  That setting overrides the setting recorded here by rules in the form.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'IsAutoApprovalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant audit record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'RegistrantAuditRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the form status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'FormStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form status to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'FormStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a final status.  Once the form achieves this status it is considered closed.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'IsFinal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default form status to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'FormStatusIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order this status should appear in the progression of a form from new to fully processed', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'FormStatusSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form owner assigned to this form status', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'FormStatusRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantAuditStatus', 'COLUMN', N'zContext'
GO
