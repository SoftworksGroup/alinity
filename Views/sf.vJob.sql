SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vJob]
as
/*********************************************************************************************************************************
View    : sf.vJob
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.Job - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.Job table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vJobExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vJobExt documentation for details. To add additional content to this view, customize
the sf.vJobExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 jb.JobSID
	,jb.JobSCD
	,jb.JobLabel
	,jb.JobDescription
	,jb.CallSyntaxTemplate
	,jb.IsCancelEnabled
	,jb.IsParallelEnabled
	,jb.IsFullTraceEnabled
	,jb.IsAlertOnSuccessEnabled
	,jb.JobScheduleSID
	,jb.JobScheduleSequence
	,jb.IsRunAfterPredecessorsOnly
	,jb.MaxErrorRate
	,jb.MaxRetriesOnFailure
	,jb.TraceLog
	,jb.IsActive
	,jb.UserDefinedColumns
	,jb.JobXID
	,jb.LegacyKey
	,jb.IsDeleted
	,jb.CreateUser
	,jb.CreateTime
	,jb.UpdateUser
	,jb.UpdateTime
	,jb.RowGUID
	,jb.RowStamp
	,jbx.JobScheduleLabel
	,jbx.IsEnabled
	,jbx.IsRunMonday
	,jbx.IsRunTuesday
	,jbx.IsRunWednesday
	,jbx.IsRunThursday
	,jbx.IsRunFriday
	,jbx.IsRunSaturday
	,jbx.IsRunSunday
	,jbx.RepeatIntervalMinutes
	,jbx.StartTime
	,jbx.EndTime
	,jbx.StartDate
	,jbx.EndDate
	,jbx.JobScheduleRowGUID
	,jbx.IsDeleteEnabled
	,jbx.IsReselected
	,jbx.IsNullApplied
	,jbx.zContext
	,jbx.LastJobStatusSCD
	,jbx.LastJobStatusLabel
	,jbx.LastStartTime
	,jbx.LastEndTime
	,jbx.NextScheduledTime
	,jbx.NextScheduledTimeServerTZ
	,jbx.MinDuration
	,jbx.MaxDuration
	,jbx.AvgDuration
	,jbx.IsTaskTriggerJob
	,jbx.LastRunRecords
	,jbx.LastRunProcessed
	,jbx.LastRunErrors
from
	sf.Job      jb
join
	sf.vJob#Ext jbx	on jb.JobSID = jbx.JobSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.Job', 'SCHEMA', N'sf', 'VIEW', N'vJob', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the job assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'JobSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the job | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'JobSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the job to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'JobLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the job and its intended use.  Include recommendations for schedule to assign where required.', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'JobDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The TSQL syntax used to call the procedure | This value may contain replacement values where the procedure is called from the user interface.  If the syntax contains replacement values, then the job cannot be put on a schedule (JobScheduleSID must remain NULL).', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'CallSyntaxTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether or not this job can be cancelled by the user once in progress.', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsCancelEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether multiple instances of this job can be run at the same time | If not enabled, attempts to call the procedure a second time while another copy is running block the second call', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsParallelEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a detailed log of job progress should be stored in addition to recording error messages  | This value is used for debugging by the Help Desk and should generally be turned off to allow processes to run more quickly.', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsFullTraceEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates an alert should be sent summarizing the results of the job when it completes successfully | Note that alerts on errors are always sent.  The alert is sent to the queue specified.', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsAlertOnSuccessEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job schedule assigned to this job - if any | If the job was not scheduled, this value is blank.', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'JobScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number used to control the order this job will start compared with other jobs assigned to the same schedule', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'JobScheduleSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this job should only be run when other jobs assigned to the same schedule and started earlier have completed successfully | To enable a schedule must be assigned and sequence number must be greater than 0', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsRunAfterPredecessorsOnly'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum error rate, as a percent of all records processed, that should be allowed to occur in the process before it automatically aborts (0 for no limit) | Note that this value is not considered until at least 100 records have been processed so the parameter has no impact on jobs with record counts < 100.', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'MaxErrorRate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'For scheduled jobs, the maximum number of consecutive occurrences of the job should be called where they end in failure - 0 for no limit| Failed jobs with the IsFailureCleared bit set to 1 in the Job Run table are not included in this count', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'MaxRetriesOnFailure'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A system-maintained log of calls to this job used by the Help Desk in support and troubleshooting of the application. | The log is only populated when the Is-Full-Trace-Enabled column is = 1 (ON)', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'TraceLog'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this job record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the job | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'JobXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the job | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this job record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the job | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the job record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the job schedule to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'JobScheduleLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates jobs using this schedule should be run.  Turn this off to prevent all jobs on the schedule from running (e.g. to pause the schedule for maintenance)', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsRunMonday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsRunTuesday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsRunWednesday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsRunThursday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsRunFriday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsRunSaturday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsRunSunday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'For jobs that should repeat within days, defines the number of minutes between subsequent calls | Note that a job will not be called if it is already running - even if parallel calls are allowed.  Also, the job only repeats within the processing window defined by the start and end times.', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'RepeatIntervalMinutes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the specific time when this job should be run, or, if a repeat interval is defined, the start of processing window | This value can be used, for example, to have a job repeat every 30 minutes but only during regular business hours', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'StartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the end of the processing window in which this job should be allowed to repeat - only relevant if a Repeat Interval is defined | This value can be used, for example, to have a job repeat every 30 minutes but only during regular business hours', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'EndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the first date this schedule applies. A scheduled may be defined to begin in the future.', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'StartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the last date this schedule applies - if blank, the schedule continued indefinitely.', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job schedule record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'JobScheduleRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total records from the last job run', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'LastRunRecords'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total number of processed records from last job run', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'LastRunProcessed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total number of errors from last job run', 'SCHEMA', N'sf', 'VIEW', N'vJob', 'COLUMN', N'LastRunErrors'
GO
