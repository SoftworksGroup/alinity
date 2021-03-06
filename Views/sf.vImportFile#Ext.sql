SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vImportFile#Ext]
as
/*********************************************************************************************************************************
View    : sf.vImportFile#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the sf.ImportFile base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vImportFile (referred to as the "entity" view in SGI documentation).

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
	 imp.ImportFileSID
	,ae.ApplicationEntitySCD
	,ae.ApplicationEntityName
	,ae.IsMergeDataSource
	,ae.RowGUID                                                             ApplicationEntityRowGUID
	,ff.FileFormatSCD
	,ff.FileFormatLabel
	,ff.IsDefault                                                           FileFormatIsDefault
	,ff.RowGUID                                                             FileFormatRowGUID
	,sf.fImportFile#IsDeleteEnabled(imp.ImportFileSID)                      IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
																																																																							--! <MoreColumns>
 ,cast((case when imp.IsFailed = 0 and imp.LoadEndTime is not null then 1 else 0 end) as bit)																IsComplete				--# Indicates if the import is complete
 ,cast((case when imp.IsFailed = 0 and imp.LoadStartTime is not null and imp.LoadEndTime is null then 1 else 0 end) as bit) IsInProcess				--# Indicates if  the import is in process
 ,cast((case
					when imp.IsFailed = 0 and imp.LoadStartTime is not null and imp.LoadEndTime is null then datediff(minute, imp.LoadStartTime, sysdatetimeoffset())
					else null
				end
			 ) as int)																																																						MinutesInProcess	--# Indicates how long import has been running
 ,datalength(imp.FileContent)																																																FileLength				--#Size in bytes of the import file
--! </MoreColumns>
from
	sf.ImportFile        imp
join
	sf.ApplicationEntity ae     on imp.ApplicationEntitySID = ae.ApplicationEntitySID
join
	sf.FileFormat        ff     on imp.FileFormatSID = ff.FileFormatSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the import file assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'ImportFileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the application entity | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'ApplicationEntitySCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the application entity to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'ApplicationEntityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this application entity should be a source of replacement values for note templates | Only the core entities of the application should be established as merge-field data sources ', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'IsMergeDataSource'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application entity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'ApplicationEntityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the file format | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'FileFormatSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the file format to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'FileFormatLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default file format to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'FileFormatIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the file format record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'FileFormatRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the import is complete', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'IsComplete'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if  the import is in process', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'IsInProcess'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates how long import has been running', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'MinutesInProcess'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Size in bytes of the import file', 'SCHEMA', N'sf', 'VIEW', N'vImportFile#Ext', 'COLUMN', N'FileLength'
GO
