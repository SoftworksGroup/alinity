SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPracticeRestriction]
as
/*********************************************************************************************************************************
View    : dbo.vPracticeRestriction
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.PracticeRestriction - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.PracticeRestriction table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vPracticeRestrictionExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vPracticeRestrictionExt documentation for details. To add additional content to this view, customize
the dbo.vPracticeRestrictionExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 pr.PracticeRestrictionSID
	,pr.PracticeRestrictionLabel
	,pr.IsDisplayedOnLicense
	,pr.Description
	,pr.IsActive
	,pr.IsSupervisionRequired
	,pr.UserDefinedColumns
	,pr.PracticeRestrictionXID
	,pr.LegacyKey
	,pr.IsDeleted
	,pr.CreateUser
	,pr.CreateTime
	,pr.UpdateUser
	,pr.UpdateTime
	,pr.RowGUID
	,pr.RowStamp
	,prx.IsDeleteEnabled
	,prx.IsReselected
	,prx.IsNullApplied
	,prx.zContext
from
	dbo.PracticeRestriction      pr
join
	dbo.vPracticeRestriction#Ext prx	on pr.PracticeRestrictionSID = prx.PracticeRestrictionSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.PracticeRestriction', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice restriction assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'PracticeRestrictionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the practice restriction to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'PracticeRestrictionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this restriction should be shown on a certificate or the public registry. This is defaulted as on by design. It is more important to make sure the public is protected than it is to prevent a restriction accidentally being shown on the certficate or the public registry. The Ui should reflect the importance of this distinction very obviously. ', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'IsDisplayedOnLicense'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Documentation about the scenarios this document type applies to - available as help text on document type selection. This field is varbinary to ensure any searches done on this field disregard taged text and only search content text. ', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice restriction record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this condition-on-practice requires that a supervisor be identified to review/enforce the conditio', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'IsSupervisionRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the practice restriction | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'PracticeRestrictionXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the practice restriction | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this practice restriction record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the practice restriction | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the practice restriction record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice restriction record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vPracticeRestriction', 'COLUMN', N'zContext'
GO
