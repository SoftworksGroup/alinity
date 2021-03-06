SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vComplaint#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vComplaint#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.Complaint base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vComplaint (referred to as the "entity" view in SGI documentation).

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
	 complaint.ComplaintSID
	,ctype1.ComplainantTypeLabel
	,ctype1.ComplainantTypeCategory
	,ctype1.IsDefault                                                       ComplainantTypeIsDefault
	,ctype1.IsActive                                                        ComplainantTypeIsActive
	,ctype1.RowGUID                                                         ComplainantTypeRowGUID
	,cs.ComplaintSeverityLabel
	,cs.ComplaintSeverityCategory
	,cs.IsDefault                                                           ComplaintSeverityIsDefault
	,cs.IsActive                                                            ComplaintSeverityIsActive
	,cs.RowGUID                                                             ComplaintSeverityRowGUID
	,ctype.ComplaintTypeLabel
	,ctype.ComplaintTypeCategory
	,ctype.IsDefault                                                        ComplaintTypeIsDefault
	,ctype.IsActive                                                         ComplaintTypeIsActive
	,ctype.RowGUID                                                          ComplaintTypeRowGUID
	,registrant.PersonSID                                                   RegistrantPersonSID
	,registrant.RegistrantNo
	,registrant.YearOfInitialEmployment
	,registrant.IsOnPublicRegistry
	,registrant.CityNameOfBirth
	,registrant.CountrySID
	,registrant.DirectedAuditYearCompetence
	,registrant.DirectedAuditYearPracticeHours
	,registrant.LateFeeExclusionYear
	,registrant.IsRenewalAutoApprovalBlocked
	,registrant.RenewalExtensionExpiryTime
	,registrant.ArchivedTime
	,registrant.RowGUID                                                     RegistrantRowGUID
	,au.PersonSID                                                           ApplicationUserPersonSID
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
	,reason.ReasonGroupSID
	,reason.ReasonName
	,reason.ReasonCode
	,reason.ReasonSequence
	,reason.ToolTip
	,reason.IsActive                                                        ReasonIsActive
	,reason.RowGUID                                                         ReasonRowGUID
	,dbo.fComplaint#IsDeleteEnabled(complaint.ComplaintSID)                 IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
--! <MoreColumns>
 ,cast(dbo.fRegistrant#Label(zp.LastName, zp.FirstName, zp.MiddleNames, registrant.RegistrantNo, 'REGISTRANT') + ': ' + ctype.ComplaintTypeLabel as nvarchar(115)) ComplaintLabel				--# A label used to identify the member and the complaint type
 ,cast(case when complaint.DismissedDate is not null then 1 else 0 end as bit)																																										 IsDismissed					--# Indicates if the complaint is dismissed
 ,cast(case when complaint.ClosedDate is not null then 1 else 0 end as bit)																																												 IsClosed							--# Indicates if complaint is closed
 ,cast(case when complaint.ClosedDate is null and zOpenE.OpenEventCount = 0 then 1 else 0 end as bit)																															 IsCloseEnabled				--# Indicates closing of the complaint is possible (all events are complete)
 ,cast(null as int)																																																																								 ComplaintProcessSID	--# A value used by the application to add a series of events for the complaint based on a process template
 ,cast(null as int)																																																																								 ComplainantPersonSID --# A value used by the application when the complaint is created to immediately add the complainant
 ,cast(case
				 when complaint.DismissedDate is not null then 'Dismissed'
				 when complaint.ClosedDate is not null then 'Closed'
				 else 'Open'
			 end as nvarchar(35))																																																																				 ComplaintStatusLabel
--! </MoreColumns>
from
	dbo.Complaint         complaint
join
	dbo.ComplainantType   ctype1     on complaint.ComplainantTypeSID = ctype1.ComplainantTypeSID
join
	dbo.ComplaintSeverity cs         on complaint.ComplaintSeveritySID = cs.ComplaintSeveritySID
join
	dbo.ComplaintType     ctype      on complaint.ComplaintTypeSID = ctype.ComplaintTypeSID
join
	dbo.Registrant        registrant on complaint.RegistrantSID = registrant.RegistrantSID
join
	sf.ApplicationUser    au         on complaint.ApplicationUserSID = au.ApplicationUserSID
left outer join
	dbo.Reason            reason     on complaint.ReasonSID = reason.ReasonSID
--! <MoreJoins>
left outer join
	sf.Person							zp on registrant.PersonSID						 = zp.PersonSID
outer apply
(
			select
				count(1) OpenEventCount
			from
				dbo.ComplaintEvent ce
			where
				ce.ComplaintSID = complaint.ComplaintSID and ce.CompleteTime is null
) zOpenE
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the complaint assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the complainant type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplainantTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplainantTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default complainant type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplainantTypeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this complainant type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplainantTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complainant type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplainantTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the complaint severity to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintSeverityLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintSeverityCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default complaint severity to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintSeverityIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this complaint severity record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintSeverityIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint severity record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintSeverityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the complaint type to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintTypeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default complaint type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintTypeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this complaint type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the complaint type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'RegistrantPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The year of initial employment in the profession if required for reporting and full history of employment was not converted', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'YearOfInitialEmployment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'CityNameOfBirth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this registrant', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'DirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'DirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled out ensures the member will not be assessed late fees for the registration year selected (limited to one year)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'LateFeeExclusionYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates automatic approval of this form type is disabled for the registrant.  Administrator review and approval is required.  This setting is only required where rules in the form would not otherwise block automatic approval. (e.g. the form may block auto-approval if a criminal record is reported or other non-qualifying details.) The setting is relevant only where automatic approval is configured for the form type.', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'IsRenewalAutoApprovalBlocked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a date to extend the renewal period for this specific registrant to the end of the day entered.  | The later of this value and the standard schedule is applied. ', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'RenewalExtensionExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'RegistrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this user is based on', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ApplicationUserPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The culture this user is assigned to', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The authentication authority used for logging in to the application (e.g. Google account) | For systems using Tenant Services for login, the value is copied from Tenant Services to the client database when the account is created.  The value of this column cannot be changed after the account is created (delete the account and recreate or create a new account).', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'AuthenticationAuthoritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the identity of the user as recorded in Active Directory and using "user@domain" style - example:   tara.knowles@soa.com', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'UserName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'date and time this user profile was last reviewed to ensure it is still required', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'LastReviewTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'identity of the user (usually an administrator) who completed the last review of this user profile', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'LastReviewUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked indicates this may be a duplicate user profile and requires review from an administrator', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'IsPotentialDuplicate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates this user will appear in the list of templates to copy from when creating new users - sets up same grants as starting point', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'IsTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'stores the hashed value of a password applied by the user when seeking temporary elevated access to functions or data their profile does not normally provide', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'GlassBreakPassword'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this user profile last changed their glass-break password | This value remains blank until password is initially set.  If password is cleared later, the time the password is set to NULL is stored.', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'LastGlassBreakPasswordChangeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this application user record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ApplicationUserIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The GUID or similar identifier used by the authentication system to identify the user record | This value is used on federated logins (e.g. MS Account, Google Account) to identify the user since it is possible for the email captured in the UserName column to change over time.  The federated record identifier should not be captured into the UserName column since that value is used in the CreateUser and UpdateUser audit columns and GUID''s.  Note that where no federated provider is used (direct email login) this column is set to the same value as the RowGUID.  A bit in the entity view indicates whether the application user record is a federated login.', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'AuthenticationSystemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ApplicationUserRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason group assigned to this reason', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ReasonGroupSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the reason to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ReasonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional code used to refer to this reason - most often applicable where reason coding is provided to external parties - e.g. Provider Directory, Workforce Planning authority, etc. ', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this reason record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ReasonIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the reason record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ReasonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label used to identify the member and the complaint type', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the complaint is dismissed', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'IsDismissed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if complaint is closed', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'IsClosed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates closing of the complaint is possible (all events are complete)', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'IsCloseEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value used by the application to add a series of events for the complaint based on a process template', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplaintProcessSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A value used by the application when the complaint is created to immediately add the complainant', 'SCHEMA', N'dbo', 'VIEW', N'vComplaint#Ext', 'COLUMN', N'ComplainantPersonSID'
GO
