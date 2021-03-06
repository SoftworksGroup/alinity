SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vTextTemplate]
as
/*********************************************************************************************************************************
View    : sf.vTextTemplate
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.TextTemplate - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.TextTemplate table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vTextTemplateExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vTextTemplateExt documentation for details. To add additional content to this view, customize
the sf.vTextTemplateExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 tt.TextTemplateSID
	,tt.TextTemplateLabel
	,tt.PriorityLevel
	,tt.Body
	,tt.IsApplicationUserRequired
	,tt.LinkExpiryHours
	,tt.ApplicationEntitySID
	,tt.UsageNotes
	,tt.UserDefinedColumns
	,tt.TextTemplateXID
	,tt.LegacyKey
	,tt.IsDeleted
	,tt.CreateUser
	,tt.CreateTime
	,tt.UpdateUser
	,tt.UpdateTime
	,tt.RowGUID
	,tt.RowStamp
	,ttx.ApplicationEntitySCD
	,ttx.ApplicationEntityName
	,ttx.IsMergeDataSource
	,ttx.ApplicationEntityRowGUID
	,ttx.IsDeleteEnabled
	,ttx.IsReselected
	,ttx.IsNullApplied
	,ttx.zContext
from
	sf.TextTemplate      tt
join
	sf.vTextTemplate#Ext ttx	on tt.TextTemplateSID = ttx.TextTemplateSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.TextTemplate', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the text template assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'TextTemplateSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the text template to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'TextTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A priority level used to rank texts for sending: 1 is the highest priority, 5 is medium and 10 is lowest | This value is used to sort texts for pickup by the text sending service', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The body of the message (in plain text format) and supporting replacement values from the data source -e.g. [@FirstName], [@LastName]', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'Body'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the eligibility check on recipients should ensure there is an active user account (recipient must be able to sign in) | Be sure this value is set for password reset texts', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'IsApplicationUserRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of hours after which any (confirmation) link included in the text is considered expired', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'LinkExpiryHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this text template', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Instructions for other users on when to use the template and other notes', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'UsageNotes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the text template | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'TextTemplateXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the text template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this text template record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the text template | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the text template record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the text template record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application entity | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'ApplicationEntitySCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application entity to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'ApplicationEntityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this application entity should be a source of replacement values for note templates | Only the core entities of the application should be established as merge-field data sources ', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'IsMergeDataSource'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application entity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'ApplicationEntityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vTextTemplate', 'COLUMN', N'zContext'
GO
