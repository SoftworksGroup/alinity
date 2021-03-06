SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vAltLanguage#Ext]
as
/*********************************************************************************************************************************
View    : sf.vAltLanguage#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the sf.AltLanguage base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vAltLanguage (referred to as the "entity" view in SGI documentation).

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
	 al.AltLanguageSID
	,culture.CultureSCD
	,culture.CultureLabel
	,culture.IsDefault                                                      CultureIsDefault
	,culture.IsActive                                                       CultureIsActive
	,culture.RowGUID                                                        CultureRowGUID
	,sf.fAltLanguage#IsDeleteEnabled(al.AltLanguageSID)                     IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	sf.AltLanguage al
join
	sf.Culture     culture on al.CultureSID = culture.CultureSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the alt language assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vAltLanguage#Ext', 'COLUMN', N'AltLanguageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the culture | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vAltLanguage#Ext', 'COLUMN', N'CultureSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the culture to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vAltLanguage#Ext', 'COLUMN', N'CultureLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default culture to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vAltLanguage#Ext', 'COLUMN', N'CultureIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this culture record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vAltLanguage#Ext', 'COLUMN', N'CultureIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the culture record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vAltLanguage#Ext', 'COLUMN', N'CultureRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vAltLanguage#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vAltLanguage#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vAltLanguage#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vAltLanguage#Ext', 'COLUMN', N'zContext'
GO
