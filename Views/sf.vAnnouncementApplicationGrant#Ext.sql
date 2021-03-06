SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vAnnouncementApplicationGrant#Ext]
as
/*********************************************************************************************************************************
View    : sf.vAnnouncementApplicationGrant#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the sf.AnnouncementApplicationGrant base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vAnnouncementApplicationGrant (referred to as the "entity" view in SGI documentation).

Columns required to support the EF include constants passed by client and middle tier modules into the table API procedures as
parameters. These values control the insert/update/delete behaviour of the sprocs. For example: the IsNullApplied bit is set ON
in the view so that update procedures overwrite column values when matching parameters are NULL on calls from the client tier.
The default for this column in the call signature of the sproc is 0 (off) so that calls from the back-end do not overwrite with
null values.  The zContext XML value is always null but is required for binding to sproc calls using EF and RIA.

You can add additional columns, joins and examples of calling syntax, by placing them between the code tag pairs provided.  Items
placed within code tag pairs are preserved on regeneration.  Note that all additions to this view become part of the base product
and deploy for all client configurations.  This view is NOT an extension point for client-specific configurations.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 aag.AnnouncementApplicationGrantSID
	,a.Title
	,a.AnnouncementText
	,a.EffectiveTime
	,a.ExpiryTime
	,a.AdditionalInfoPageURI
	,a.IsLoginAlert
	,a.IsExtendedFormat
	,a.RowGUID                                                                             AnnouncementRowGUID
	,ag.ApplicationGrantSCD
	,ag.ApplicationGrantName
	,ag.IsDefault                                                                          ApplicationGrantIsDefault
	,ag.RowGUID                                                                            ApplicationGrantRowGUID
	,sf.fAnnouncementApplicationGrant#IsDeleteEnabled(aag.AnnouncementApplicationGrantSID) IsDeleteEnabled--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                                    IsReselected		-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                                        IsNullApplied	-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                                     zContext		-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	sf.AnnouncementApplicationGrant aag
join
	sf.Announcement                 a      on aag.AnnouncementSID = a.AnnouncementSID
join
	sf.ApplicationGrant             ag     on aag.ApplicationGrantSID = ag.ApplicationGrantSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the announcement application grant assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'AnnouncementApplicationGrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Title of the announcement that appears as a heading on landing page control', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'Title'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this announcement should first become available to users on the system | Announcements can be post dated to appear in the future', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A date (and optionally time) after which the announcement should no longer be displayed', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A link to a web page providing additional content on the announcement ', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'AdditionalInfoPageURI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the announcement is displayed as an alert after login on the dashboard ', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'IsLoginAlert'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates all formatting for the announcement is embedded in the content (no standard wrapping applied by the application) | Used internally by the help desk to create custom-format announcements', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'IsExtendedFormat'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the announcement record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'AnnouncementRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application grant | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'ApplicationGrantSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application grant to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'ApplicationGrantName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default application grant to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'ApplicationGrantIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application grant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'ApplicationGrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncementApplicationGrant#Ext', 'COLUMN', N'zContext'
GO
