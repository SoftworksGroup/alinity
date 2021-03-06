SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vPersonGroup]
as
/*********************************************************************************************************************************
View    : sf.vPersonGroup
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for sf.PersonGroup - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the sf.PersonGroup table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to sf.vPersonGroupExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See sf.vPersonGroupExt documentation for details. To add additional content to this view, customize
the sf.vPersonGroupExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 pg.PersonGroupSID
	,pg.PersonGroupName
	,pg.PersonGroupLabel
	,pg.PersonGroupCategory
	,pg.Description
	,pg.ApplicationUserSID
	,pg.IsPreference
	,pg.IsDocumentLibraryEnabled
	,pg.QuerySID
	,pg.LastReviewUser
	,pg.LastReviewTime
	,pg.TagList
	,pg.SmartGroupCount
	,pg.SmartGroupCountTime
	,pg.IsActive
	,pg.UserDefinedColumns
	,pg.PersonGroupXID
	,pg.LegacyKey
	,pg.IsDeleted
	,pg.CreateUser
	,pg.CreateTime
	,pg.UpdateUser
	,pg.UpdateTime
	,pg.RowGUID
	,pg.RowStamp
	,pgx.PersonSID
	,pgx.CultureSID
	,pgx.AuthenticationAuthoritySID
	,pgx.UserName
	,pgx.ApplicationUserLastReviewTime
	,pgx.ApplicationUserLastReviewUser
	,pgx.IsPotentialDuplicate
	,pgx.IsTemplate
	,pgx.GlassBreakPassword
	,pgx.LastGlassBreakPasswordChangeTime
	,pgx.ApplicationUserIsActive
	,pgx.AuthenticationSystemID
	,pgx.ApplicationUserRowGUID
	,pgx.QueryCategorySID
	,pgx.ApplicationPageSID
	,pgx.QueryLabel
	,pgx.ToolTip
	,pgx.LastExecuteTime
	,pgx.LastExecuteUser
	,pgx.ExecuteCount
	,pgx.QueryCode
	,pgx.QueryIsActive
	,pgx.IsApplicationPageDefault
	,pgx.QueryRowGUID
	,pgx.IsDeleteEnabled
	,pgx.IsReselected
	,pgx.IsNullApplied
	,pgx.zContext
	,pgx.IsSmartGroup
	,pgx.NextReviewDueDate
	,pgx.TotalActive
	,pgx.TotalPending
	,pgx.TotalRequiringReplacement
	,pgx.IsNextReviewOverdue
from
	sf.PersonGroup      pg
join
	sf.vPersonGroup#Ext pgx	on pg.PersonGroupSID = pgx.PersonGroupSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'sf.PersonGroup', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person group assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'PersonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the person group to display on search results and reports (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'PersonGroupName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the person group to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'PersonGroupLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize groups under', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'PersonGroupCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this person group', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the member/client can manage membership in the group as a preference in their profile', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'IsPreference'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The query assigned to this person group', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'QuerySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Identity of the user (an administrator) who completed the last review of this group', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'LastReviewUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this group was last reviewed to ensure it is still required', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'LastReviewTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The total number of group members the last time the  smart-group query was executed', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'SmartGroupCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time the count of members in the smart group was last updated', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'SmartGroupCountTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this person group record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person group | Forms customization is required to access extended XML content', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'PersonGroupXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person group | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person group record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person group | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person group record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person group record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this user is based on', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The culture this user is assigned to', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The authentication authority used for logging in to the application (e.g. Google account) | For systems using Tenant Services for login, the value is copied from Tenant Services to the client database when the account is created.  The value of this column cannot be changed after the account is created (delete the account and recreate or create a new account).', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'AuthenticationAuthoritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the identity of the user as recorded in Active Directory and using "user@domain" style - example:   tara.knowles@soa.com', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'UserName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'date and time this user profile was last reviewed to ensure it is still required', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'ApplicationUserLastReviewTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'identity of the user (usually an administrator) who completed the last review of this user profile', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'ApplicationUserLastReviewUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked indicates this may be a duplicate user profile and requires review from an administrator', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'IsPotentialDuplicate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates this user will appear in the list of templates to copy from when creating new users - sets up same grants as starting point', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'IsTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'stores the hashed value of a password applied by the user when seeking temporary elevated access to functions or data their profile does not normally provide', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'GlassBreakPassword'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this user profile last changed their glass-break password | This value remains blank until password is initially set.  If password is cleared later, the time the password is set to NULL is stored.', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'LastGlassBreakPasswordChangeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this application user record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'ApplicationUserIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The GUID or similar identifier used by the authentication system to identify the user record | This value is used on federated logins (e.g. MS Account, Google Account) to identify the user since it is possible for the email captured in the UserName column to change over time.  The federated record identifier should not be captured into the UserName column since that value is used in the CreateUser and UpdateUser audit columns and GUID''s.  Note that where no federated provider is used (direct email login) this column is set to the same value as the RowGUID.  A bit in the entity view indicates whether the application user record is a federated login.', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'AuthenticationSystemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'ApplicationUserRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The query category assigned to this query', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'QueryCategorySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application page assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'ApplicationPageSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the query to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'QueryLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A short help prompt explaining the purpose of the query to the end user when they mouse over the query label', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'ToolTip'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time this query was last used | This value can be helpful in determining queries which are not being used and can be removed from the system', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'LastExecuteTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The identity of the user who last used this query | This value can be helpful in investigating queries which are not being used to ensure they are removed from the system', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'LastExecuteUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times this query has been used | This value can be helpful in determining queries which are not being used and can be removed from the system', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'ExecuteCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value defining the location of the query in the execution procedure | Prefix is "S!" for system/product queries.', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'QueryCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this query record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'QueryIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default search for the menu option | This query is executed as the default search if the end-user has not saved their own default query', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'IsApplicationPageDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the query record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'QueryRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this group is based on a query so group membership is updated automatically (do not add group members!)', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'IsSmartGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the next review of this group is due | The review period length is a configuration parameter', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'NextReviewDueDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count of group members currently active (not expired)', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'TotalActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count of group members who are future dated for membership in the group', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'TotalPending'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count of group positions due for replacement', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'TotalRequiringReplacement'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this group is overdue for review | The review period length is a configuration parameter', 'SCHEMA', N'sf', 'VIEW', N'vPersonGroup', 'COLUMN', N'IsNextReviewOverdue'
GO
