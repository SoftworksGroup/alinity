SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vDefaultEmailTemplate]
as
/*********************************************************************************************************************************
View    : sf.vDefaultEmailTemplate
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.DefaultEmailTemplate - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.DefaultEmailTemplate table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vDefaultEmailTemplateExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vDefaultEmailTemplateExt documentation for details. To add additional content to this view, customize
the sf.vDefaultEmailTemplateExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 det.DefaultEmailTemplateSID
	,det.DefaultEmailTemplateSCD
	,det.DefaultEmailTemplateLabel
	,det.EmailTemplateSID
	,det.UserDefinedColumns
	,det.DefaultEmailTemplateXID
	,det.LegacyKey
	,det.IsDeleted
	,det.CreateUser
	,det.CreateTime
	,det.UpdateUser
	,det.UpdateTime
	,det.RowGUID
	,det.RowStamp
	,detx.EmailTemplateLabel
	,detx.PriorityLevel
	,detx.Subject
	,detx.IsApplicationUserRequired
	,detx.LinkExpiryHours
	,detx.ApplicationEntitySID
	,detx.ApplicationGrantSID
	,detx.EmailTemplateRowGUID
	,detx.IsDeleteEnabled
	,detx.IsReselected
	,detx.IsNullApplied
	,detx.zContext
from
	sf.DefaultEmailTemplate      det
join
	sf.vDefaultEmailTemplate#Ext detx	on det.DefaultEmailTemplateSID = detx.DefaultEmailTemplateSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.DefaultEmailTemplate', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the default email template assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'DefaultEmailTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the default email template | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'DefaultEmailTemplateSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the default email template to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'DefaultEmailTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The email template assigned to this default', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'EmailTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the default email template | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'DefaultEmailTemplateXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the default email template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this default email template record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the default email template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the default email template record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the default email template record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the email template to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'EmailTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A priority level used to rank emails for sending: 1 is the highest priority, 5 is medium and 10 is lowest | This value is used to sort emails for pickup by the email sending service', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A title or subject to appear in the generated email or task - can contain replacements  - e.g. [@FirstName] | This value is mandatory and defaults to the Email Template Label if not provided.  The value is ignored for SMS messages. Only the body is sent for SMS', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'Subject'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the eligibility check on recipients should ensure there is an active user account (recipient must be able to sign in) | Be sure this value is set for password reset emails', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'IsApplicationUserRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of hours after which any (confirmation) link included in the email is considered expired', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'LinkExpiryHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this email template', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the email template record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'EmailTemplateRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vDefaultEmailTemplate', 'COLUMN', N'zContext'
GO
