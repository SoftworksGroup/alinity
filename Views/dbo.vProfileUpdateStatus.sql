SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vProfileUpdateStatus]
as
/*********************************************************************************************************************************
View    : dbo.vProfileUpdateStatus
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.ProfileUpdateStatus - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.ProfileUpdateStatus table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vProfileUpdateStatusExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vProfileUpdateStatusExt documentation for details. To add additional content to this view, customize
the dbo.vProfileUpdateStatusExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 pus.ProfileUpdateStatusSID
	,pus.ProfileUpdateSID
	,pus.FormStatusSID
	,pus.UserDefinedColumns
	,pus.ProfileUpdateStatusXID
	,pus.LegacyKey
	,pus.IsDeleted
	,pus.CreateUser
	,pus.CreateTime
	,pus.UpdateUser
	,pus.UpdateTime
	,pus.RowGUID
	,pus.RowStamp
	,pusx.PersonSID
	,pusx.RegistrationYear
	,pusx.FormVersionSID
	,pusx.LastValidateTime
	,pusx.NextFollowUp
	,pusx.IsAutoApprovalEnabled
	,pusx.ReasonSID
	,pusx.ParentRowGUID
	,pusx.ProfileUpdateRowGUID
	,pusx.FormStatusSCD
	,pusx.FormStatusLabel
	,pusx.IsFinal
	,pusx.FormStatusIsDefault
	,pusx.FormStatusSequence
	,pusx.FormOwnerSID
	,pusx.FormStatusRowGUID
	,pusx.IsDeleteEnabled
	,pusx.IsReselected
	,pusx.IsNullApplied
	,pusx.zContext
from
	dbo.ProfileUpdateStatus      pus
join
	dbo.vProfileUpdateStatus#Ext pusx	on pus.ProfileUpdateStatusSID = pusx.ProfileUpdateStatusSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.ProfileUpdateStatus', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the profile update status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'ProfileUpdateStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the profile update assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'ProfileUpdateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form status assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'FormStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the profile update status | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'ProfileUpdateStatusXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the profile update status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this profile update status record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the profile update status | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the profile update status record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the profile update status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration year the profile update was created in (set to current registration year by default)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'RegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the form content successfully passed validations', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'LastValidateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when the next follow-up is required on the form.  Leave blank if no follow-up required.  When this date is reached the record appears on the Administrators list for "next-to-act".', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'NextFollowUp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is set by customized rules in the form configuration to enable automatic approval of the form when required conditions have been met.  If all forms should be reviewed by adminsitrators, then the value is left turned off by the form. Note that the condition of making payment (e.g. to pay for the form if charges apply) is automatically taken into account and need not be addressed in the form configuration. It is possible to block automatic approval on any registrant through their profile.  That setting overrides the setting recorded here by rules in the form.', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'IsAutoApprovalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this profile update', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The unique identifier of the parent form (typically a renewal or reinstatement) the Profile Update is connected to.  | Null (blank) if this profile update form is not part of a form-set', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'ParentRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the profile update record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'ProfileUpdateRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the form status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'FormStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form status to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'FormStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this is a final status.  Once the form achieves this status it is considered closed.', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'IsFinal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default form status to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'FormStatusIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order this status should appear in the progression of a form from new to fully processed', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'FormStatusSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The form owner assigned to this form status', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'FormOwnerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'FormStatusRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateStatus', 'COLUMN', N'zContext'
GO