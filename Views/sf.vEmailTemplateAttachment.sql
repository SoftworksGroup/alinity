SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vEmailTemplateAttachment]
as
/*********************************************************************************************************************************
View    : sf.vEmailTemplateAttachment
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.EmailTemplateAttachment - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.EmailTemplateAttachment table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vEmailTemplateAttachmentExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vEmailTemplateAttachmentExt documentation for details. To add additional content to this view, customize
the sf.vEmailTemplateAttachmentExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 eta.EmailTemplateAttachmentSID
	,eta.EmailTemplateSID
	,eta.DocumentTitle
	,eta.FileTypeSID
	,eta.FileTypeSCD
	,eta.DocumentContent
	,eta.UserDefinedColumns
	,eta.EmailTemplateAttachmentXID
	,eta.LegacyKey
	,eta.IsDeleted
	,eta.CreateUser
	,eta.CreateTime
	,eta.UpdateUser
	,eta.UpdateTime
	,eta.RowGUID
	,eta.RowStamp
	,etax.EmailTemplateLabel
	,etax.PriorityLevel
	,etax.Subject
	,etax.IsApplicationUserRequired
	,etax.LinkExpiryHours
	,etax.ApplicationEntitySID
	,etax.ApplicationGrantSID
	,etax.EmailTemplateRowGUID
	,etax.FileTypeFileTypeSCD
	,etax.FileTypeLabel
	,etax.MimeType
	,etax.IsInline
	,etax.FileTypeIsActive
	,etax.FileTypeRowGUID
	,etax.IsDeleteEnabled
	,etax.IsReselected
	,etax.IsNullApplied
	,etax.zContext
from
	sf.EmailTemplateAttachment      eta
join
	sf.vEmailTemplateAttachment#Ext etax	on eta.EmailTemplateAttachmentSID = etax.EmailTemplateAttachmentSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.EmailTemplateAttachment', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the email template attachment assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'EmailTemplateAttachmentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The email template this attachment is defined for', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'EmailTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name or title of the document to show in the user interface (defaults to the file name uploaded)', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'DocumentTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of email template attachment', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'FileTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The file extension or type of document | This value must match one of the registered filter types for full-text searching.  The list of document types supported is limited by the master table.  The value includes the leading period - e.g. ".pdf" Note that the default value is updated by an AFTER trigger defined on the table.', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'FileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The content of the document in native format (e.g. an Adobe PDF "binary")', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'DocumentContent'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the email template attachment | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'EmailTemplateAttachmentXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the email template attachment | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this email template attachment record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the email template attachment | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the email template attachment record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the email template attachment record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the email template to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'EmailTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A priority level used to rank emails for sending: 1 is the highest priority, 5 is medium and 10 is lowest | This value is used to sort emails for pickup by the email sending service', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A title or subject to appear in the generated email or task - can contain replacements  - e.g. [@FirstName] | This value is mandatory and defaults to the Email Template Label if not provided.  The value is ignored for SMS messages. Only the body is sent for SMS', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'Subject'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the eligibility check on recipients should ensure there is an active user account (recipient must be able to sign in) | Be sure this value is set for password reset emails', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'IsApplicationUserRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of hours after which any (confirmation) link included in the email is considered expired', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'LinkExpiryHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this email template', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the email template record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'EmailTemplateRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the file type | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'FileTypeFileTypeSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the file type to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'FileTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The MIME type to use when a client browser downloads or views a document.', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'MimeType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When a client browser downloads a document this indicates whether or not the browser should be asked to display rather than download the document. If the browser is unable to, due to lack of software or other settings, the file will instead be downloaded as normal.', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'IsInline'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this file type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'FileTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the file type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'FileTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vEmailTemplateAttachment', 'COLUMN', N'zContext'
GO