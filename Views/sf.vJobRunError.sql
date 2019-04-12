SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vJobRunError]
as
/*********************************************************************************************************************************
View    : sf.vJobRunError
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.JobRunError - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.JobRunError table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vJobRunErrorExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vJobRunErrorExt documentation for details. To add additional content to this view, customize
the sf.vJobRunErrorExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 jre.JobRunErrorSID
	,jre.JobRunSID
	,jre.MessageText
	,jre.DataSource
	,jre.RecordKey
	,jre.UserDefinedColumns
	,jre.JobRunErrorXID
	,jre.LegacyKey
	,jre.IsDeleted
	,jre.CreateUser
	,jre.CreateTime
	,jre.UpdateUser
	,jre.UpdateTime
	,jre.RowGUID
	,jre.RowStamp
	,jrex.JobSID
	,jrex.ConversationHandle
	,jrex.StartTime
	,jrex.EndTime
	,jrex.TotalRecords
	,jrex.TotalErrors
	,jrex.RecordsProcessed
	,jrex.CurrentProcessLabel
	,jrex.IsFailed
	,jrex.IsFailureCleared
	,jrex.CancellationRequestTime
	,jrex.IsCancelled
	,jrex.JobRunRowGUID
	,jrex.IsDeleteEnabled
	,jrex.IsReselected
	,jrex.IsNullApplied
	,jrex.zContext
from
	sf.JobRunError      jre
join
	sf.vJobRunError#Ext jrex	on jre.JobRunErrorSID = jrex.JobRunErrorSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.JobRunError', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the job run error assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'JobRunErrorSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job run this error is defined for', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'JobRunSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The schema and name of the table view or other database object which is the source of the error. | This value is not validated and may reference objects in an external database.', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'DataSource'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The primary key value of the record where the error originated | This value is stored as a string to allow capture from non-Softworks systems where keys may not be numeric and may involve multiple columns', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'RecordKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the job run error | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'JobRunErrorXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the job run error | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this job run error record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the job run error | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the job run error record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job run error record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The job this run is defined for', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'JobSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An internal system value used to coordinate communication about job status within the SQL Server message broker service', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'ConversationHandle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the job began running', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'StartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the job completed successfully, failed, or was cancelled | Job run records where this value is not filled in are considered to be running', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'EndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The total count of records to process in the job (if set) | This value must be set by the job procedure at startup.  The value is used for calculating percent complete and estimated time of completion.', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'TotalRecords'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The total number of errors encountered during the job run | This value must be set by the job procedure as errors are encountered.  The value is used in status reporting and may be used to abort the job automatically if the error rate exceeds the max rate defined in the Job table (only applies where at least 100 records have been processed).', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'TotalErrors'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The count of records processed in the job so far (if set) | This value must be set by the job procedure as records are processed. The value is used for calculating percent complete and estimated time of completion.', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'RecordsProcessed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier displayed on the job monitoring screen in the UI advising the user what stage or operation is currently being carried out by the job - e.g. "Retrieving Records ..." | Note that the value can be replaced for display on the UI by defining a mapping record in sf.TermLabel', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'CurrentProcessLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job ended in an error or was aborted because the maximum error ratio, as defined in the Job table, was exceeded', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'IsFailed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that the failed status of the job has been cleared so that it can be run again if a "max retry on failure" limit was set for the job | This value is only enabled in the UI if the job run is showing a failed status', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'IsFailureCleared'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time a request to cancel the job was made | If the job is non-responsive, the cancellation will not occur and the job must be set to Failed manually from the Job Management screen', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'CancellationRequestTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job was cancelled before it completed', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'IsCancelled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job run record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'JobRunRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vJobRunError', 'COLUMN', N'zContext'
GO
