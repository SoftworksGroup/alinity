SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vAnnouncementApplicationGrant]
as
/*********************************************************************************************************************************
View    : sf.vAnnouncementApplicationGrant
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.AnnouncementApplicationGrant - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.AnnouncementApplicationGrant table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vAnnouncementApplicationGrantExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vAnnouncementApplicationGrantExt documentation for details. To add additional content to this view, customize
the sf.vAnnouncementApplicationGrantExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 aag.AnnouncementApplicationGrantSID
	,aag.AnnouncementSID
	,aag.ApplicationGrantSID
	,aag.UserDefinedColumns
	,aag.AnnouncementApplicationGrantXID
	,aag.LegacyKey
	,aag.IsDeleted
	,aag.CreateUser
	,aag.CreateTime
	,aag.UpdateUser
	,aag.UpdateTime
	,aag.RowGUID
	,aag.RowStamp
	,aagx.Title
	,aagx.AnnouncementText
	,aagx.EffectiveTime
	,aagx.ExpiryTime
	,aagx.AdditionalInfoPageURI
	,aagx.IsLoginAlert
	,aagx.IsExtendedFormat
	,aagx.AnnouncementRowGUID
	,aagx.ApplicationGrantSCD
	,aagx.ApplicationGrantName
	,aagx.ApplicationGrantIsDefault
	,aagx.ApplicationGrantRowGUID
	,aagx.IsDeleteEnabled
	,aagx.IsReselected
	,aagx.IsNullApplied
	,aagx.zContext
from
	sf.AnnouncementApplicationGrant      aag
join
	sf.vAnnouncementApplicationGrant#Ext aagx	on aag.AnnouncementApplicationGrantSID = aagx.AnnouncementApplicationGrantSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.AnnouncementApplicationGrant', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the announcement application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'AnnouncementApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The announcement this grant is defined for', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'AnnouncementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The grant assigned to this announcement', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'ApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the announcement application grant | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'AnnouncementApplicationGrantXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the announcement application grant | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this announcement application grant record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the announcement application grant | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the announcement application grant record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the announcement application grant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Title of the announcement that appears as a heading on landing page control', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'Title'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this announcement should first become available to users on the system | Announcements can be post dated to appear in the future', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A date (and optionally time) after which the announcement should no longer be displayed', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A link to a web page providing additional content on the announcement ', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'AdditionalInfoPageURI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the announcement is displayed as an alert after login on the dashboard ', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'IsLoginAlert'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates all formatting for the announcement is embedded in the content (no standard wrapping applied by the application) | Used internally by the help desk to create custom-format announcements', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'IsExtendedFormat'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the announcement record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'AnnouncementRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application grant | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'ApplicationGrantSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application grant to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'ApplicationGrantName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default application grant to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'ApplicationGrantIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application grant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'ApplicationGrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant', 'COLUMN', N'zContext'
GO
