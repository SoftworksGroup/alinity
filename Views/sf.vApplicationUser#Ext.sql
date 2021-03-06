SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vApplicationUser#Ext]
as
/*********************************************************************************************************************************
View    : sf.vApplicationUser#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the sf.ApplicationUser base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vApplicationUser (referred to as the "entity" view in SGI documentation).

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
	 au.ApplicationUserSID
	,aa.AuthenticationAuthoritySCD
	,aa.AuthenticationAuthorityLabel
	,aa.IsActive                                                            AuthenticationAuthorityIsActive
	,aa.IsDefault                                                           AuthenticationAuthorityIsDefault
	,aa.RowGUID                                                             AuthenticationAuthorityRowGUID
	,culture.CultureSCD
	,culture.CultureLabel
	,culture.IsDefault                                                      CultureIsDefault
	,culture.IsActive                                                       CultureIsActive
	,culture.RowGUID                                                        CultureRowGUID
	,person.GenderSID
	,person.NamePrefixSID
	,person.FirstName
	,person.CommonName
	,person.MiddleNames
	,person.LastName
	,person.BirthDate
	,person.DeathDate
	,person.HomePhone
	,person.MobilePhone
	,person.IsTextMessagingEnabled
	,person.ImportBatch
	,person.RowGUID                                                         PersonRowGUID
	,cast(null as nvarchar(4000))                                           ChangeReason							--# Virtual column to capture latest reason for change that is written into audit log column
	,sf.fApplicationUser#IsDeleteEnabled(au.ApplicationUserSID)             IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
	--! <MoreColumns>
	,zaus.ApplicationUserSessionSID
	,zaus.RowGUID                                                           SessionGUID
	,sf.fFormatFileAsName(person.LastName, person.FirstName, person.MiddleNames)											FileAsName	--# A filing label for the application user based on last name,first name middle names
	,sf.fFormatFullName(person.LastName, person.FirstName, person.MiddleNames, znp.NamePrefixLabel)		FullName		--# A label for the application user suitable for addressing based on name prefix (salutation) first name middle names last name
	,sf.fFormatDisplayName(person.LastName, isnull(person.CommonName, person.FirstName))																					DisplayName	--# A label for the application user suitable for use on the UI and reports based on first name last name
	,zpea.EmailAddress																											PrimaryEmailAddress
	,zpea.PersonEmailAddressSID     PrimaryEmailAddressSID
	,isnull
		(
		 person.MobilePhone
		,person.HomePhone
		)                                                                     PreferredPhone		        --#Shows mobile phone if provided otherwise home phone - or blank if no phone numbers are provided
	,isnull(zaus2.LoginCount,0)                                             LoginCount                --#The number of logins in history for this user  - when > 0 the user name cannot be changed
	,dateadd
		(
		 month
		,isnull(convert(smallint, sf.fConfigParam#Value('UserProfileReviewMonths')), 12)
		,convert(smalldatetime, au.LastReviewTime)
		)                                                                     NextProfileReviewDueDate	--# The date the next review of this user profile is due | Review target duration is a configuration parameter
	,cast(
		case
			when
				dateadd
				(
				 month
				,isnull(convert(smallint, sf.fConfigParam#Value('UserProfileReviewMonths')), 12)
				,convert(smalldatetime, au.LastReviewTime)
				) < convert(smalldatetime, sysdatetimeoffset()) then 1
			else
				0
		 end
	 as bit)                                                                IsNextProfileReviewOverdue --# Indicates whether this user profile is overdue for review | Review target duration is a configuration parameter
	,dateadd
		(
		 month
		,isnull(convert(smallint, sf.fConfigParam#Value('GlassBreakPwdChangeMonths')), 12)
		,convert(smalldatetime, au.LastGlassBreakPasswordChangeTime)
		)                                                                     NextGlassBreakPasswordChangeDueDate	--# The date a change to the glass break password is due | Glass break password duration is a configuration parameter
	,cast(
		case
			when
				dateadd
				(
				 month
				,isnull(convert(smallint, sf.fConfigParam#Value('GlassBreakPwdChangeMonths')), 12)
				,convert(smalldatetime, au.LastGlassBreakPasswordChangeTime)
				) < convert(smalldatetime, sysdatetimeoffset()) then 1
			else
				0
		 end
	 as bit)                                                                IsNextGlassBreakPasswordOverdue	--# Indicates whether a change to the glass break password is overdue| Glass break password duration is a configuration parameter
	,(
		select
			count(1)
		from
			sf.vRecordAudit ra
		where
			ra.ApplicationUserSID = au.ApplicationUserSID
		and
			ra.IsGlassBreak = 1
		and
			datediff(hour, ra.UpdateTime, sysdatetimeoffset()) <= 24
		)																																			GlassBreakCountInLast24Hours --#The number of times this user has accessed records using glass break in the last 24 hours
	,l.License																																												--@sf.License.License
	,sf.fIsGrantedToUserSID('SysAdmin',au.ApplicationUserSID)               IsSysAdmin								--# Indicates this user has the System Administrator grant which provides access to all functions in the system
	,zaus2.LastDBAccessTime
	,round(datediff(day,zaus2.LastDBAccessTime, sysdatetimeoffset()),0)     DaysSinceLastDBAccess
	,cast
		(case
			when zaus2.ActiveSessionCount > 0
			and round(datediff(minute,zaus2.LastDBAccessTime, sysdatetimeoffset()),0) between 0 and 15 then 1			-- avoid negative login times (from sample data)
			else 0
		end
		as bit
		)                                                                     IsAccessingNow						--#Indicates that this user appears to be logged in currently (access to the database within last 15 minutes)
	,cast
		(
		case
			when
			(
			case
				when zaus2.LastDBAccessTime is null  then round(datediff(day,au.CreateTime, sysdatetimeoffset()),0) -- if no logins ever, calculated based on create time of record
				else round(datediff(day,zaus2.LastDBAccessTime, sysdatetimeoffset()),0)                             -- difference between current date and last access time
			end
			) > cast(isnull(sf.fConfigParam#Value('UnusedAccountWarningDays'), 90) as int) then 1         -- if greater than warning days in configuration - set bit ON
			else 0
		end
		as bit
		)                                                                     IsUnused                    --# Indicates that the account has not been used recently and may require marking inactive
	,cast(null as int)                                                      TemplateApplicationUserSID  --# Virtual column used to direct framework to copy functional grants from template
	,sf.fLastUpdateTime
	(
		 au.UpdateTime
		,person.UpdateTime
		,null
	)																																				LatestUpdateTime					--#The latest time any component of the record (Application User or Person) was updated
	,sf.fLastUpdateUser
	(
		 au.UpdateTime
		,au.UpdateUser
		,person.UpdateTime
		,person.UpdateUser
		,null
		,null
	)																																				LatestUpdateUser					--#The user who made the latest update to any component of the record (Application User or Person)
	,db_name()																															DatabaseName
	,cast(
		case
			when (au.LastReviewTime >= au.CreateTime)	then	1
			else 0
		end	
		as bit)																																IsConfirmed								--# Indicates if user account requires verification | Derived from the Last Review Time and the Create Time; if values are the same, the user is considered verified.
	,cast(isnull(sf.fConfigParam#Value('AutoSaveInterval'), 5) as smallint)	AutoSaveInterval					--# The interval (in minutes) after which the system should automatically save report and template entries.
	,cast(
		case
			when cast(au.RowGUID as nvarchar(50)) <> au.AuthenticationSystemID then 1
			else 0
		end
		as bit)																																IsFederatedLogin					--# Indicates if the user is logging in through a federated account (e.g. Microsoft or Google account) | Otherwise Active Directory or email login is being used (set by UI tier)
	,cast(null as nvarchar(129))                                            DatabaseDisplayName				-- these placeholders below are overridden in pApplicationUser#Authorize
	,cast(null as char(9))                                                  DatabaseStatusColor				-- not calculated here for performance (columns only needed at login)
	,cast(null as xml)                                                      ApplicationGrantXML				-- these values are only required during login
	,cast(null as nvarchar(50))																							[Password]								-- applies on insert only to convert initial password from plain text to encrypted storage
	--! </MoreColumns>
from
	sf.ApplicationUser         au
join
	sf.AuthenticationAuthority aa      on au.AuthenticationAuthoritySID = aa.AuthenticationAuthoritySID
join
	sf.Culture                 culture on au.CultureSID = culture.CultureSID
join
	sf.Person                  person  on au.PersonSID = person.PersonSID
--! <MoreJoins>
outer apply
	(select l.License from sf.License l)  l
left outer join
	sf.NamePrefix             znp  on person.NamePrefixSID = znp.NamePrefixSID
left outer join -- only 1 active session allowed (see sf.pApplicationUser#Authorize)
	sf.ApplicationUserSession zaus on au.ApplicationUserSID = zaus.ApplicationUserSID and zaus.IsActive = 1
left outer join
	sf.PersonEmailAddress     zpea on  person.PersonSID = zpea.PersonSID and zpea.IsPrimary = cast(1 as bit) and zpea.IsActive = cast(1 as bit)  -- only 1 primary email - protected by unique index constraint (ux)
left outer join
	(
		select
			 aus.ApplicationUserSID
			,sum(cast(aus.IsActive as int))		ActiveSessionCount
			,count(1)													LoginCount
			,max(aus.UpdateTime)							LastDBAccessTime
		from      sf.ApplicationUserSession aus
		group by
			aus.ApplicationUserSID
	) zaus2 on au.ApplicationUserSID = zaus2.ApplicationUserSID
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the application user assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the authentication authority | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'AuthenticationAuthoritySCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the authentication authority to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'AuthenticationAuthorityLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this authentication authority record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'AuthenticationAuthorityIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default authentication authority to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'AuthenticationAuthorityIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the authentication authority record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'AuthenticationAuthorityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the culture | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'CultureSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the culture to present in lists and look ups (must be unique)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'CultureLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default culture to assign when new records are added', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'CultureIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this culture record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'CultureIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the culture record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'CultureRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Virtual column to capture latest reason for change that is written into audit log column', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'ChangeReason'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A filing label for the application user based on last name,first name middle names', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'FileAsName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label for the application user suitable for addressing based on name prefix (salutation) first name middle names last name', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'FullName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A label for the application user suitable for use on the UI and reports based on first name last name', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'DisplayName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shows mobile phone if provided otherwise home phone - or blank if no phone numbers are provided', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'PreferredPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of logins in history for this user  - when > 0 the user name cannot be changed', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'LoginCount'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date the next review of this user profile is due | Review target duration is a configuration parameter', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'NextProfileReviewDueDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether this user profile is overdue for review | Review target duration is a configuration parameter', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'IsNextProfileReviewOverdue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date a change to the glass break password is due | Glass break password duration is a configuration parameter', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'NextGlassBreakPasswordChangeDueDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a change to the glass break password is overdue| Glass break password duration is a configuration parameter', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'IsNextGlassBreakPasswordOverdue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The number of times this user has accessed records using glass break in the last 24 hours', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'GlassBreakCountInLast24Hours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'License'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this user has the System Administrator grant which provides access to all functions in the system', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'IsSysAdmin'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that this user appears to be logged in currently (access to the database within last 15 minutes)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'IsAccessingNow'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that the account has not been used recently and may require marking inactive', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'IsUnused'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Virtual column used to direct framework to copy functional grants from template', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'TemplateApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The latest time any component of the record (Application User or Person) was updated', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'LatestUpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user who made the latest update to any component of the record (Application User or Person)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'LatestUpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if user account requires verification | Derived from the Last Review Time and the Create Time; if values are the same, the user is considered verified.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'IsConfirmed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The interval (in minutes) after which the system should automatically save report and template entries.', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'AutoSaveInterval'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the user is logging in through a federated account (e.g. Microsoft or Google account) | Otherwise Active Directory or email login is being used (set by UI tier)', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'IsFederatedLogin'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether a change to the glass break password is overdue| Glass break password duration is a configuration parameter', 'SCHEMA', N'sf', 'VIEW', N'vApplicationUser#Ext', 'COLUMN', N'Password'
GO
