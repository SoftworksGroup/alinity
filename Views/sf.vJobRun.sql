SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vJobRun]
as
/*********************************************************************************************************************************
View    : sf.vJobRun
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.JobRun - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.JobRun table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vJobRunExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vJobRunExt documentation for details. To add additional content to this view, customize
the sf.vJobRunExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 jr.JobRunSID
	,jr.JobSID
	,jr.ConversationHandle
	,jr.CallSyntax
	,jr.StartTime
	,jr.EndTime
	,jr.TotalRecords
	,jr.TotalErrors
	,jr.RecordsProcessed
	,jr.CurrentProcessLabel
	,jr.IsFailed
	,jr.IsFailureCleared
	,jr.CancellationRequestTime
	,jr.IsCancelled
	,jr.ResultMessage
	,jr.TraceLog
	,jr.UserDefinedColumns
	,jr.JobRunXID
	,jr.LegacyKey
	,jr.IsDeleted
	,jr.CreateUser
	,jr.CreateTime
	,jr.UpdateUser
	,jr.UpdateTime
	,jr.RowGUID
	,jr.RowStamp
	,jrx.JobSCD
	,jrx.JobLabel
	,jrx.IsCancelEnabled
	,jrx.IsParallelEnabled
	,jrx.IsFullTraceEnabled
	,jrx.IsAlertOnSuccessEnabled
	,jrx.JobScheduleSID
	,jrx.JobScheduleSequence
	,jrx.IsRunAfterPredecessorsOnly
	,jrx.MaxErrorRate
	,jrx.MaxRetriesOnFailure
	,jrx.JobIsActive
	,jrx.JobRowGUID
	,jrx.IsDeleteEnabled
	,jrx.IsReselected
	,jrx.IsNullApplied
	,jrx.zContext
	,jrx.JobStatusSCD
	,jrx.JobStatusLabel
	,jrx.RecordsPerMinute
	,jrx.RecordsRemaining
	,jrx.EstimatedMinutesRemaining
	,jrx.EstimatedEndTime
	,jrx.DurationMinutes
	,jrx.StartTimeClientTZ
	,jrx.EndTimeClientTZ
	,jrx.CancellationRequestTimeClientTZ
from
	sf.JobRun      jr
join
	sf.vJobRun#Ext jrx	on jr.JobRunSID = jrx.JobRunSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.JobRun', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the job run assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'JobRunSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job this run is defined for', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'JobSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An internal system value used to coordinate communication about job status within the SQL Server message broker service', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'ConversationHandle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The TSQL syntax used to call the procedure', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'CallSyntax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the job began running', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'StartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the job completed successfully, failed, or was cancelled | Job run records where this value is not filled in are considered to be running', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'EndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The total count of records to process in the job (if set) | This value must be set by the job procedure at startup.  The value is used for calculating percent complete and estimated time of completion.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'TotalRecords'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The total number of errors encountered during the job run | This value must be set by the job procedure as errors are encountered.  The value is used in status reporting and may be used to abort the job automatically if the error rate exceeds the max rate defined in the Job table (only applies where at least 100 records have been processed).', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'TotalErrors'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The count of records processed in the job so far (if set) | This value must be set by the job procedure as records are processed. The value is used for calculating percent complete and estimated time of completion.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'RecordsProcessed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier displayed on the job monitoring screen in the UI advising the user what stage or operation is currently being carried out by the job - e.g. "Retrieving Records ..." | Note that the value can be replaced for display on the UI by defining a mapping record in sf.TermLabel', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'CurrentProcessLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job ended in an error or was aborted because the maximum error ratio, as defined in the Job table, was exceeded', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'IsFailed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that the failed status of the job has been cleared so that it can be run again if a "max retry on failure" limit was set for the job | This value is only enabled in the UI if the job run is showing a failed status', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'IsFailureCleared'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time a request to cancel the job was made | If the job is non-responsive, the cancellation will not occur and the job must be set to Failed manually from the Job Management screen', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'CancellationRequestTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job was cancelled before it completed', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'IsCancelled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A summary of the job result (if set) | This value must be set by the procedure the job is based on when it finishes or fails or is cancelled. | The procedure should use a MessageSCD from the sf.Message table to support globalization of this value', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'ResultMessage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A log of errors and, if Full Trace is enabled on the job run, of interim steps useful in investigating problems', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'TraceLog'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the job run | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'JobRunXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the job run | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this job run record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the job run | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the job run record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job run record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the job | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'JobSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the job to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'JobLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether or not this job can be cancelled by the user once in progress.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'IsCancelEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether multiple instances of this job can be run at the same time | If not enabled, attempts to call the procedure a second time while another copy is running block the second call', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'IsParallelEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a detailed log of job progress should be stored in addition to recording error messages  | This value is used for debugging by the Help Desk and should generally be turned off to allow processes to run more quickly.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'IsFullTraceEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates an alert should be sent summarizing the results of the job when it completes successfully | Note that alerts on errors are always sent.  The alert is sent to the queue specified.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'IsAlertOnSuccessEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job schedule assigned to this job - if any | If the job was not scheduled, this value is blank.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'JobScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number used to control the order this job will start compared with other jobs assigned to the same schedule', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'JobScheduleSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this job should only be run when other jobs assigned to the same schedule and started earlier have completed successfully | To enable a schedule must be assigned and sequence number must be greater than 0', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'IsRunAfterPredecessorsOnly'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum error rate, as a percent of all records processed, that should be allowed to occur in the process before it automatically aborts (0 for no limit) | Note that this value is not considered until at least 100 records have been processed so the parameter has no impact on jobs with record counts < 100.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'MaxErrorRate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'For scheduled jobs, the maximum number of consecutive occurrences of the job should be called where they end in failure - 0 for no limit| Failed jobs with the IsFailureCleared bit set to 1 in the Job Run table are not included in this count', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'MaxRetriesOnFailure'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this job record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'JobIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'JobRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A system assigned code indicating the current status of the job', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'JobStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A configurable label indicating the status of the job for presentation to the end user	', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'JobStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of records processed by the job per minute | This value is only available when record counts are provided by the job.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'RecordsPerMinute'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of records remaining to be processed | This value is only available when record counts are provided by the job.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'RecordsRemaining'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of minutes estimated for the job to complete processing | This value is only available when record counts are provided by the job.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'EstimatedMinutesRemaining'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the job is estimated to be complete (converted for the client time zone) | This value is only available when record counts are provided by the job.', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'EstimatedEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The total amount of time the job took to run | This value is updated as the job is running', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'DurationMinutes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Start time of the job - converted to the client timezone', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'StartTimeClientTZ'
GO
EXEC sp_addextendedproperty N'MS_Description', N'End time of the job - converted to the client timezone', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'EndTimeClientTZ'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time cancellation of the job was requested - converted to the client timezone', 'SCHEMA', N'sf', 'VIEW', N'vJobRun', 'COLUMN', N'CancellationRequestTimeClientTZ'
GO