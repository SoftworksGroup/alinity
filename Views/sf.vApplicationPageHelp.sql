SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vApplicationPageHelp]
as
/*********************************************************************************************************************************
View    : sf.vApplicationPageHelp
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.ApplicationPageHelp - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.ApplicationPageHelp table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vApplicationPageHelpExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vApplicationPageHelpExt documentation for details. To add additional content to this view, customize
the sf.vApplicationPageHelpExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 aph.ApplicationPageHelpSID
	,aph.ApplicationPageSID
	,aph.ApplicationPageHelpID
	,aph.HelpContent
	,aph.StepSequence
	,aph.UserDefinedColumns
	,aph.ApplicationPageHelpXID
	,aph.LegacyKey
	,aph.IsDeleted
	,aph.CreateUser
	,aph.CreateTime
	,aph.UpdateUser
	,aph.UpdateTime
	,aph.RowGUID
	,aph.RowStamp
	,aphx.ApplicationPageLabel
	,aphx.ApplicationPageURI
	,aphx.ApplicationRoute
	,aphx.IsSearchPage
	,aphx.ApplicationEntitySID
	,aphx.ApplicationPageRowGUID
	,aphx.IsDeleteEnabled
	,aphx.IsReselected
	,aphx.IsNullApplied
	,aphx.zContext
from
	sf.ApplicationPageHelp      aph
join
	sf.vApplicationPageHelp#Ext aphx	on aph.ApplicationPageHelpSID = aphx.ApplicationPageHelpSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.ApplicationPageHelp', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page help assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'ApplicationPageHelpSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application page help | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'ApplicationPageHelpID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the application page help | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'ApplicationPageHelpXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the application page help | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this application page help record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the application page help | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the application page help record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application page help record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the application page to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'ApplicationPageLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The base link for the page in the application | This value is set by the development team and used as the basis for linking other components (reports, queries, etc.) to appear on the same page ', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'ApplicationPageURI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Technical information used by the application to identify the web page a link should go to | This values applies in Model-View-Controller architectures. This is the “route” used – controller + action – by the application.  The “Application Page URI” columns is provided for Silverlight architectures. This value is to navigate from tasks to the corresponding pages where work can be carried out and is also used in email links to navigate directly to action pages for the user. ', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'ApplicationRoute'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this page supports query references being passed into it for automatic execution', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'IsSearchPage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this page', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application page record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'ApplicationPageRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationPageHelp', 'COLUMN', N'zContext'
GO
