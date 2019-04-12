SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vTask]
as
/*********************************************************************************************************************************
View    : sf.vTask
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.Task - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.Task table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vTaskExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vTaskExt documentation for details. To add additional content to this view, customize
the sf.vTaskExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 task.TaskSID
	,task.TaskTitle
	,task.TaskQueueSID
	,task.TargetRowGUID
	,task.TaskDescription
	,task.IsAlert
	,task.PriorityLevel
	,task.ApplicationUserSID
	,task.TaskStatusSID
	,task.AssignedTime
	,task.DueDate
	,task.NextFollowUpDate
	,task.ClosedTime
	,task.ApplicationPageSID
	,task.TaskTriggerSID
	,task.RecipientList
	,task.TagList
	,task.FileExtension
	,task.UserDefinedColumns
	,task.TaskXID
	,task.LegacyKey
	,task.IsDeleted
	,task.CreateUser
	,task.CreateTime
	,task.UpdateUser
	,task.UpdateTime
	,task.RowGUID
	,task.RowStamp
	,taskx.TaskQueueLabel
	,taskx.TaskQueueCode
	,taskx.IsAutoAssigned
	,taskx.IsOpenSubscription
	,taskx.TaskQueueApplicationUserSID
	,taskx.TaskQueueIsActive
	,taskx.TaskQueueIsDefault
	,taskx.TaskQueueRowGUID
	,taskx.TaskStatusSCD
	,taskx.TaskStatusLabel
	,taskx.TaskStatusSequence
	,taskx.IsDerived
	,taskx.IsClosedStatus
	,taskx.TaskStatusIsActive
	,taskx.TaskStatusIsDefault
	,taskx.TaskStatusRowGUID
	,taskx.TaskTriggerLabel
	,taskx.TaskTitleTemplate
	,taskx.QuerySID
	,taskx.TaskTriggerTaskQueueSID
	,taskx.TaskTriggerApplicationUserSID
	,taskx.TaskTriggerIsAlert
	,taskx.TaskTriggerPriorityLevel
	,taskx.TargetCompletionDays
	,taskx.OpenTaskLimit
	,taskx.IsRegeneratedIfClosed
	,taskx.ApplicationAction
	,taskx.JobScheduleSID
	,taskx.LastStartTime
	,taskx.LastEndTime
	,taskx.TaskTriggerIsActive
	,taskx.TaskTriggerRowGUID
	,taskx.ApplicationPageLabel
	,taskx.ApplicationPageURI
	,taskx.ApplicationRoute
	,taskx.IsSearchPage
	,taskx.ApplicationEntitySID
	,taskx.ApplicationPageRowGUID
	,taskx.PersonSID
	,taskx.CultureSID
	,taskx.AuthenticationAuthoritySID
	,taskx.UserName
	,taskx.LastReviewTime
	,taskx.LastReviewUser
	,taskx.IsPotentialDuplicate
	,taskx.IsTemplate
	,taskx.GlassBreakPassword
	,taskx.LastGlassBreakPasswordChangeTime
	,taskx.ApplicationUserIsActive
	,taskx.AuthenticationSystemID
	,taskx.ApplicationUserRowGUID
	,taskx.IsDeleteEnabled
	,taskx.IsReselected
	,taskx.IsNullApplied
	,taskx.zContext
	,taskx.IsOverdue
	,taskx.IsOpen
	,taskx.IsCancelled
	,taskx.IsClosed
	,taskx.IsTaskTakeOverEnabled
	,taskx.IsCloseEnabled
	,taskx.IsUpdateEnabled
	,taskx.IsClosedWithinADay
	,taskx.EntityLabel
from
	sf.Task      task
join
	sf.vTask#Ext taskx	on task.TaskSID = taskx.TaskSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.Task', 'SCHEMA', N'sf', 'VIEW', N'vTask', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the task assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the task to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskTitle'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The queue this task should appear on | If not defined the task will be assigned to the default queue at runtime', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskQueueSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A description of the work required', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the task is a message that only needs to be acknowledged (read) by the assigned user.  | Alert tasks must be assigned immediately to a specific application user.', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsAlert'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A ranking value indicating the priority of this task compared with others - scale is 1-5 with "3" being medium (default) | The due date and this value are used to sort tasks in priority sequence on the user interface', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user who this task has been assigned to (the task owner) | This value may be self-assigned by selecting the task from a queue, or it may be assigned by a task manager', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the task', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this task was assigned (or last assigned if a re-assignment was done)', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'AssignedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the task is due', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'DueDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date this task should next appear for follow-up by the task owner | This value is a "bring forward" date that can be changed as work on the task proceeds', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'NextFollowUpDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the task was marked complete', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'ClosedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A reference to the task trigger that generated the task - blank if task was created manually | This value is required in order for task queries to determine if a task has already been created for the scenario', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskTriggerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'List of individuals who should receive notification (via email and/or text) when task updates or new notes are entered.  | This value includes a designator to notify and display for user notes marked private', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'RecipientList'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value required by the system to perform full-text indexing on the HTML formatted content in the record (do not expose in user interface).', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'FileExtension'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the task | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the task | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this task record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the task | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the task record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the task record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the task queue to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskQueueLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates new users are automatically assigned to this queue | Note that value only impacts creation of new users.  If this setting is checked after users have already been created, they are not automatically assigned to the queue.', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsAutoAssigned'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that any user can assign themselves to this task queue', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsOpenSubscription'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this task queue', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskQueueApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this task queue record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskQueueIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default task queue to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskQueueIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the task queue record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskQueueRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the task status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the task status to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The order this status should appear in on the task (Kanban) board display', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskStatusSequence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the status is derived by the system. These types of statuses cannot be selected as parent statuses for Task Board columns.', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsDerived'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates tasks in this status should be considered as closed by the application | This value cannot be set by the end user', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsClosedStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this task status record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskStatusIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default task status to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskStatusIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the task status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskStatusRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the task trigger to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskTriggerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The title to give the task created - may include replacement values | Replacement values available are defined by the application e.g. "{ContactName}"', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskTitleTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A reference to the query that locates records for which tasks need to be created | The query does not need to exclude records where open tasks already exist as duplicates are avoided by the built-in task trigger processor', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'QuerySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The task queue assigned to this task trigger', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskTriggerTaskQueueSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A reference to a specific application user if tasks generated by this trigger should automatically be assigned to the same person | This option is useful where one person is responsible for triaging and assigning all tasks in a queue (or there is only a single queue subscriber)', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskTriggerApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this task trigger should generate an "alert" type task | Alert tasks are created and assigned to all users in the queue', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskTriggerIsAlert'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A ranking value indicating the priority of this task compared with others - scale is 1-5 with "3" being medium (default) | The due date and this value are used to sort tasks in priority sequence on the user interface', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskTriggerPriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Establishes the due date for tasks generated as the creation date + this number of days', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TargetCompletionDays'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Limits the total number of open tasks of this type allowed by the system - must be 1 or greater | This value is used in situations where the query may return hundreds or thousands of task records.  The limit ensures a manageable number of open tasks of this type will be allowed in the system at the same time.', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'OpenTaskLimit'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates a new task should be created, even where a task for the record exists, if the old task is closed', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsRegeneratedIfClosed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This field contains technical information set by your configurator that controls the view the application displays when this task is accessed | This value applies in Model-View-Controller architectures. This is the "Action" called within the Controller when the user clicks/touches the task.   This data and the “Application Controller” value are used to complete the navigation. The “Application Page URI” columns is provided for Silverlight architectures. This value is included on the Task record as well as on the Task Trigger to allow users to create navigating-tasks, such as from the Application User module.   In these situations the application sets the value directly.  For task triggers, the value must be set by the configurator.', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'ApplicationAction'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the job schedule assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'JobScheduleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time processing for this specific task trigger began | This value is used in determining when the trigger should be run next when a schedule is assigned', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'LastStartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the trigger completed successfully, failed, or was cancelled through the Task Trigger job | Records where this value is not filled in are considered to be running', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'LastEndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this task trigger record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskTriggerIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the task trigger record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'TaskTriggerRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the application page to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'ApplicationPageLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The base link for the page in the application | This value is set by the development team and used as the basis for linking other components (reports, queries, etc.) to appear on the same page ', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'ApplicationPageURI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Technical information used by the application to identify the web page a link should go to | This values applies in Model-View-Controller architectures. This is the “route” used – controller + action – by the application.  The “Application Page URI” columns is provided for Silverlight architectures. This value is to navigate from tasks to the corresponding pages where work can be carried out and is also used in email links to navigate directly to action pages for the user. ', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'ApplicationRoute'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this page supports query references being passed into it for automatic execution', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsSearchPage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this page', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application page record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'ApplicationPageRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this user is based on', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The culture this user is assigned to', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The authentication authority used for logging in to the application (e.g. Google account) | For systems using Tenant Services for login, the value is copied from Tenant Services to the client database when the account is created.  The value of this column cannot be changed after the account is created (delete the account and recreate or create a new account).', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'AuthenticationAuthoritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the identity of the user as recorded in Active Directory and using "user@domain" style - example:   tara.knowles@soa.com', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'UserName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'date and time this user profile was last reviewed to ensure it is still required', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'LastReviewTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'identity of the user (usually an administrator) who completed the last review of this user profile', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'LastReviewUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked indicates this may be a duplicate user profile and requires review from an administrator', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsPotentialDuplicate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates this user will appear in the list of templates to copy from when creating new users - sets up same grants as starting point', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'stores the hashed value of a password applied by the user when seeking temporary elevated access to functions or data their profile does not normally provide', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'GlassBreakPassword'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this user profile last changed their glass-break password | This value remains blank until password is initially set.  If password is cleared later, the time the password is set to NULL is stored.', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'LastGlassBreakPasswordChangeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this application user record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'ApplicationUserIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The GUID or similar identifier used by the authentication system to identify the user record | This value is used on federated logins (e.g. MS Account, Google Account) to identify the user since it is possible for the email captured in the UserName column to change over time.  The federated record identifier should not be captured into the UserName column since that value is used in the CreateUser and UpdateUser audit columns and GUID''s.  Note that where no federated provider is used (direct email login) this column is set to the same value as the RowGUID.  A bit in the entity view indicates whether the application user record is a federated login.', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'AuthenticationSystemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'ApplicationUserRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates the task is overdue		', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsOverdue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates the task is open', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsOpen'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates the task is cancelled', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsCancelled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates the task has been closed within the last 24 hours', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsClosed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the task can be taken over by the logged in user', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsTaskTakeOverEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the task can be closed by the owner of the task or queue', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsCloseEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the task can be updated by the owner of the task or queue', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsUpdateEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates the task has been closed within the last 24 hours', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'IsClosedWithinADay'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the label for the entity (eg: Person) the task is targeted for | Override in product DB project to include supported entities--! </MoreColumns>from', 'SCHEMA', N'sf', 'VIEW', N'vTask', 'COLUMN', N'EntityLabel'
GO