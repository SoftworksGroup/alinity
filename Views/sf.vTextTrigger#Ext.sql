SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vTextTrigger#Ext]
as
/*********************************************************************************************************************************
View    : sf.vTextTrigger#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the sf.TextTrigger base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vTextTrigger (referred to as the "entity" view in SGI documentation).

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
	 ttgr.TextTriggerSID
	,qry.QueryCategorySID
	,qry.ApplicationPageSID
	,qry.QueryLabel
	,qry.ToolTip
	,qry.LastExecuteTime
	,qry.LastExecuteUser
	,qry.ExecuteCount
	,qry.QueryCode
	,qry.IsActive                                                           QueryIsActive
	,qry.IsApplicationPageDefault
	,qry.RowGUID                                                            QueryRowGUID
	,tt.TextTemplateLabel
	,tt.PriorityLevel
	,tt.Body
	,tt.IsApplicationUserRequired
	,tt.LinkExpiryHours
	,tt.ApplicationEntitySID
	,tt.RowGUID                                                             TextTemplateRowGUID
	,au.PersonSID
	,au.CultureSID
	,au.AuthenticationAuthoritySID
	,au.UserName
	,au.LastReviewTime
	,au.LastReviewUser
	,au.IsPotentialDuplicate
	,au.IsTemplate
	,au.GlassBreakPassword
	,au.LastGlassBreakPasswordChangeTime
	,au.IsActive                                                            ApplicationUserIsActive
	,au.AuthenticationSystemID
	,au.RowGUID                                                             ApplicationUserRowGUID
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
	,sf.fTextTrigger#IsDeleteEnabled(ttgr.TextTriggerSID)                   IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
	,zx.LastDurationMinutes																																						-- The minutes of runtime required to complete processing the last time the email trigger was run
	,zx.IsRunning																																											-- Indicates whether the processing of this trigger is currently running
	,zx.LastStartTimeClientTZ																																					-- The last time the processing of this trigger started
	,zx.LastEndTimeClientTZ																																						-- The ending time for the last time this trigger was processed (if blank - trigger processing is running)
	,zx.NextScheduledTime																																							-- The time this trigger is scheduled to run next (in the user timezone)
	,zx.NextScheduledTimeServerTZ																																			-- The time this trigger is scheduled to run next (in the server timezone)
  --! </MoreColumns>
from
	sf.TextTrigger     ttgr
join
	sf.Query           qry    on ttgr.QuerySID = qry.QuerySID
join
	sf.TextTemplate    tt     on ttgr.TextTemplateSID = tt.TextTemplateSID
left outer join
	sf.ApplicationUser au     on ttgr.ApplicationUserSID = au.ApplicationUserSID
left outer join
	sf.JobSchedule     js     on ttgr.JobScheduleSID = js.JobScheduleSID
--! <MoreJoins>
outer apply
	sf.fTextTrigger#Ext(ttgr.TextTriggerSID) zx
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the text trigger assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'TextTriggerSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The query category assigned to this query', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'QueryCategorySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the query to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'QueryLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A short help prompt explaining the purpose of the query to the end user when they mouse over the query label', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'ToolTip'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this query was last used | This value can be helpful in determining queries which are not being used and can be removed from the system', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'LastExecuteTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The identity of the user who last used this query | This value can be helpful in investigating queries which are not being used to ensure they are removed from the system', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'LastExecuteUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times this query has been used | This value can be helpful in determining queries which are not being used and can be removed from the system', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'ExecuteCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value defining the location of the query in the execution procedure | Prefix is "S!" for system/product queries.', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'QueryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this query record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'QueryIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default search for the menu option | This query is executed as the default search if the end-user has not saved their own default query', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsApplicationPageDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the query record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'QueryRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the text template to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'TextTemplateLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A priority level used to rank texts for sending: 1 is the highest priority, 5 is medium and 10 is lowest | This value is used to sort texts for pickup by the text sending service', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'PriorityLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The body of the message (in plain text format) and supporting replacement values from the data source -e.g. [@FirstName], [@LastName]', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'Body'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether the eligibility check on recipients should ensure there is an active user account (recipient must be able to sign in) | Be sure this value is set for password reset texts', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsApplicationUserRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of hours after which any (confirmation) link included in the text is considered expired', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'LinkExpiryHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The entity assigned to this text template', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'ApplicationEntitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the text template record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'TextTemplateRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this user is based on', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The culture this user is assigned to', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The authentication authority used for logging in to the application (e.g. Google account) | For systems using Tenant Services for login, the value is copied from Tenant Services to the client database when the account is created.  The value of this column cannot be changed after the account is created (delete the account and recreate or create a new account).', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'AuthenticationAuthoritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the identity of the user as recorded in Active Directory and using "user@domain" style - example:   tara.knowles@soa.com', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'UserName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'date and time this user profile was last reviewed to ensure it is still required', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'LastReviewTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'identity of the user (usually an administrator) who completed the last review of this user profile', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'LastReviewUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked indicates this may be a duplicate user profile and requires review from an administrator', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsPotentialDuplicate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates this user will appear in the list of templates to copy from when creating new users - sets up same grants as starting point', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'stores the hashed value of a password applied by the user when seeking temporary elevated access to functions or data their profile does not normally provide', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'GlassBreakPassword'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this user profile last changed their glass-break password | This value remains blank until password is initially set.  If password is cleared later, the time the password is set to NULL is stored.', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'LastGlassBreakPasswordChangeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this application user record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'ApplicationUserIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The GUID or similar identifier used by the authentication system to identify the user record | This value is used on federated logins (e.g. MS Account, Google Account) to identify the user since it is possible for the email captured in the UserName column to change over time.  The federated record identifier should not be captured into the UserName column since that value is used in the CreateUser and UpdateUser audit columns and GUID''s.  Note that where no federated provider is used (direct email login) this column is set to the same value as the RowGUID.  A bit in the entity view indicates whether the application user record is a federated login.', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'AuthenticationSystemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'ApplicationUserRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the job schedule to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'JobScheduleLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates jobs using this schedule should be run.  Turn this off to prevent all jobs on the schedule from running (e.g. to pause the schedule for maintenance)', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsRunMonday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsRunTuesday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsRunWednesday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsRunThursday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsRunFriday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsRunSaturday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the job is to be run on this day of the week', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsRunSunday'
GO
EXEC sp_addextendedproperty N'MS_Description', N'For jobs that should repeat within days, defines the number of minutes between subsequent calls | Note that a job will not be called if it is already running - even if parallel calls are allowed.  Also, the job only repeats within the processing window defined by the start and end times.', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'RepeatIntervalMinutes'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the specific time when this job should be run, or, if a repeat interval is defined, the start of processing window | This value can be used, for example, to have a job repeat every 30 minutes but only during regular business hours', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'StartTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the end of the processing window in which this job should be allowed to repeat - only relevant if a Repeat Interval is defined | This value can be used, for example, to have a job repeat every 30 minutes but only during regular business hours', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'EndTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the first date this schedule applies. A scheduled may be defined to begin in the future.', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'StartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Defines the last date this schedule applies - if blank, the schedule continued indefinitely.', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the job schedule record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'JobScheduleRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vTextTrigger#Ext', 'COLUMN', N'zContext'
GO
