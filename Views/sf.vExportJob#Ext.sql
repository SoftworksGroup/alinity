SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vExportJob#Ext]
as
/*********************************************************************************************************************************
View    : sf.vExportJob#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the sf.ExportJob base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vExportJob (referred to as the "entity" view in SGI documentation).

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
	 ej.ExportJobSID
	,ff.FileFormatSCD
	,ff.FileFormatLabel
	,ff.IsDefault                                                           FileFormatIsDefault
	,ff.RowGUID                                                             FileFormatRowGUID
	,js.JobScheduleLabel
	,js.IsEnabled
	,js.IsRunMonday
	,js.IsRunTuesday
	,js.IsRunWednesday
	,js.IsRunThursday
	,js.IsRunFriday
	,js.IsRunSaturday
	,js.IsRunSunday
	,js.RepeatIntervalMinutes
	,js.StartTime
	,js.EndTime
	,js.StartDate
	,js.EndDate
	,js.RowGUID                                                             JobScheduleRowGUID
	,sf.fExportJob#IsDeleteEnabled(ej.ExportJobSID)                         IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	sf.ExportJob   ej
join
	sf.FileFormat  ff     on ej.FileFormatSID = ff.FileFormatSID
left outer join
	sf.JobSchedule js     on ej.JobScheduleSID = js.JobScheduleSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the export job assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'ExportJobSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the file format | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'FileFormatSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the file format to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'FileFormatLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default file format to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'FileFormatIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the file format record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'FileFormatRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the job schedule to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'JobScheduleLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates jobs using this schedule should be run.  Turn this off to prevent all jobs on the schedule from running (e.g. to pause the schedule for maintenance)', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'IsEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'IsRunMonday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'IsRunTuesday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'IsRunWednesday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'IsRunThursday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'IsRunFriday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'IsRunSaturday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'IsRunSunday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'For jobs that should repeat within days, defines the number of minutes between subsequent calls | Note that a job will not be called if it is already running - even if parallel calls are allowed.  Also, the job only repeats within the processing window defined by the start and end times.', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'RepeatIntervalMinutes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the specific time when this job should be run, or, if a repeat interval is defined, the start of processing window | This value can be used, for example, to have a job repeat every 30 minutes but only during regular business hours', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'StartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the end of the processing window in which this job should be allowed to repeat - only relevant if a Repeat Interval is defined | This value can be used, for example, to have a job repeat every 30 minutes but only during regular business hours', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'EndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the first date this schedule applies. A scheduled may be defined to begin in the future.', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'StartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the last date this schedule applies - if blank, the schedule continued indefinitely.', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job schedule record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'JobScheduleRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vExportJob#Ext', 'COLUMN', N'zContext'
GO
