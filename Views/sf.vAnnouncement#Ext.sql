SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vAnnouncement#Ext]
as
/*********************************************************************************************************************************
View    : sf.vAnnouncement#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the sf.Announcement base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vAnnouncement (referred to as the "entity" view in SGI documentation).

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
	 a.AnnouncementSID
	,sf.fIsActive(a.EffectiveTime, a.ExpiryTime)                            IsActive									--# Indicates if the assignment is currently active (not expired or future dated)
	,sf.fIsPending(a.EffectiveTime, a.ExpiryTime)                           IsPending									--# Indicates if the assignment will come into effect in the future
	,sf.fAnnouncement#IsDeleteEnabled(a.AnnouncementSID)                    IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
--! <MoreColumns>
 ,cast(case
				 when sf.fIsActive(a.EffectiveTime, a.ExpiryTime) = cast(1 as bit) and zca.ClearedAnnouncementSID is null then 0
				 else 1
			 end as bit)																																													 IsClearedOrExpired		--# Indicates if the announcement has expired or is cleared by the current user
 ,cast(case when isnull(zLastLogin.CreateTime, a.EffectiveTime) <= a.EffectiveTime then 1 else 0 end as bit) IsNew								--# Indicates if the announcement is new for the current user
 ,cast(null as varchar(30))																																									 ApplicationGrantSCD	--# Virtual column to allow setting of an initial grant for access to the announcement (e.g. "ADMIN.BASE")
--! </MoreColumns>
from
	sf.Announcement a
--! <MoreJoins>
cross apply
(select sf.fApplicationUserSessionUserSID() CurrentApplicationUserSID) zau
left outer join
	sf.ClearedAnnouncement zca on a.AnnouncementSID = zca.AnnouncementSID and zca.ApplicationUserSID = zau.CurrentApplicationUserSID
outer apply
(
	select
		cast(z.CreateTime as datetime) CreateTime
	from
	(
		select
			rank() over (order by aus.ApplicationUserSessionSID desc) RowNumber -- order their sessions
		 ,aus.CreateTime
		from
			sf.ApplicationUserSession aus
		where
			aus.ApplicationUserSID = zau.CurrentApplicationUserSID	-- isolate the login history for this user
	) z
	where
		z.RowNumber = 2 -- isolate their previous login (previous to the current one) to see if they saw the announcements previously
)												 zLastLogin;
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the announcement assigned by the system | Primary key - not editable', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncement#Ext', 'COLUMN', N'AnnouncementSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment is currently active (not expired or future dated)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncement#Ext', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment will come into effect in the future', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncement#Ext', 'COLUMN', N'IsPending'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncement#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncement#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncement#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncement#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the announcement has expired or is cleared by the current user', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncement#Ext', 'COLUMN', N'IsClearedOrExpired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the announcement is new for the current user', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncement#Ext', 'COLUMN', N'IsNew'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Virtual column to allow setting of an initial grant for access to the announcement (e.g. "ADMIN.BASE")', 'SCHEMA', N'sf', 'VIEW', N'vAnnouncement#Ext', 'COLUMN', N'ApplicationGrantSCD'
GO
