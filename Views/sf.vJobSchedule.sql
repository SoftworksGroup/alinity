SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vJobSchedule]
as
/*********************************************************************************************************************************
View    : sf.vJobSchedule
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.JobSchedule - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.JobSchedule table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vJobScheduleExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vJobScheduleExt documentation for details. To add additional content to this view, customize
the sf.vJobScheduleExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 js.JobScheduleSID
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
	,js.UserDefinedColumns
	,js.JobScheduleXID
	,js.LegacyKey
	,js.IsDeleted
	,js.CreateUser
	,js.CreateTime
	,js.UpdateUser
	,js.UpdateTime
	,js.RowGUID
	,js.RowStamp
	,jsx.IsDeleteEnabled
	,jsx.IsReselected
	,jsx.IsNullApplied
	,jsx.zContext
	,jsx.StartTimeDateTime
	,jsx.EndTimeDateTime
from
	sf.JobSchedule      js
join
	sf.vJobSchedule#Ext jsx	on js.JobScheduleSID = jsx.JobScheduleSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.JobSchedule', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the job schedule assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'JobScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the job schedule to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'JobScheduleLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates jobs using this schedule should be run.  Turn this off to prevent all jobs on the schedule from running (e.g. to pause the schedule for maintenance)', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'IsEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'IsRunMonday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'IsRunTuesday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'IsRunWednesday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'IsRunThursday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'IsRunFriday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'IsRunSaturday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'IsRunSunday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'For jobs that should repeat within days, defines the number of minutes between subsequent calls | Note that a job will not be called if it is already running - even if parallel calls are allowed.  Also, the job only repeats within the processing window defined by the start and end times.', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'RepeatIntervalMinutes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the specific time when this job should be run, or, if a repeat interval is defined, the start of processing window | This value can be used, for example, to have a job repeat every 30 minutes but only during regular business hours', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'StartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the end of the processing window in which this job should be allowed to repeat - only relevant if a Repeat Interval is defined | This value can be used, for example, to have a job repeat every 30 minutes but only during regular business hours', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'EndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the first date this schedule applies. A scheduled may be defined to begin in the future.', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'StartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the last date this schedule applies - if blank, the schedule continued indefinitely.', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the job schedule | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'JobScheduleXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the job schedule | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this job schedule record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the job schedule | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the job schedule record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job schedule record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vJobSchedule', 'COLUMN', N'zContext'
GO
