SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vMessageLink#Ext]
as
/*********************************************************************************************************************************
View    : sf.vMessageLink#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the sf.MessageLink base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vMessageLink (referred to as the "entity" view in SGI documentation).

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
	 ml.MessageLinkSID
	,ap.ApplicationPageLabel
	,ap.ApplicationPageURI
	,ap.ApplicationRoute
	,ap.IsSearchPage
	,ap.ApplicationEntitySID
	,ap.RowGUID                                                             ApplicationPageRowGUID
	,sf.fMessageLink#IsDeleteEnabled(ml.MessageLinkSID)                     IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	sf.MessageLink     ml
join
	sf.ApplicationPage ap     on ml.ApplicationPageSID = ap.ApplicationPageSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the message link assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vMessageLink#Ext', 'COLUMN', N'MessageLinkSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the application page to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vMessageLink#Ext', 'COLUMN', N'ApplicationPageLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The base link for the page in the application | This value is set by the development team and used as the basis for linking other components (reports, queries, etc.) to appear on the same page ', 'SCHEMA', N'sf', 'VIEW', N'vMessageLink#Ext', 'COLUMN', N'ApplicationPageURI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Technical information used by the application to identify the web page a link should go to | This values applies in Model-View-Controller architectures. This is the “route” used – controller + action – by the application.  The “Application Page URI” columns is provided for Silverlight architectures. This value is to navigate from tasks to the corresponding pages where work can be carried out and is also used in email links to navigate directly to action pages for the user. ', 'SCHEMA', N'sf', 'VIEW', N'vMessageLink#Ext', 'COLUMN', N'ApplicationRoute'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this page supports query references being passed into it for automatic execution', 'SCHEMA', N'sf', 'VIEW', N'vMessageLink#Ext', 'COLUMN', N'IsSearchPage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this page', 'SCHEMA', N'sf', 'VIEW', N'vMessageLink#Ext', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application page record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vMessageLink#Ext', 'COLUMN', N'ApplicationPageRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vMessageLink#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vMessageLink#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vMessageLink#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vMessageLink#Ext', 'COLUMN', N'zContext'
GO
