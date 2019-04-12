SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vProfileUpdateResponse#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vProfileUpdateResponse#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.ProfileUpdateResponse base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : March 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vProfileUpdateResponse (referred to as the "entity" view in SGI documentation).

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
	 pur.ProfileUpdateResponseSID
	,pu.PersonSID
	,pu.RegistrationYear
	,pu.FormVersionSID
	,pu.LastValidateTime
	,pu.NextFollowUp
	,pu.IsAutoApprovalEnabled
	,pu.ReasonSID
	,pu.ParentRowGUID
	,pu.RowGUID                                                               ProfileUpdateRowGUID
	,fo.FormOwnerSCD
	,fo.FormOwnerLabel
	,fo.IsAssignee
	,fo.RowGUID                                                               FormOwnerRowGUID
	,dbo.fProfileUpdateResponse#IsDeleteEnabled(pur.ProfileUpdateResponseSID) IsDeleteEnabled					--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                       IsReselected						-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                           IsNullApplied						-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                        zContext								-- parameter for sproc calls through EF - utility parameter for customization
--! <MoreColumns>
 ,isnull(sf.fFormatDisplayName(zp.LastName, isnull(zp.CommonName, zp.FirstName)), pur.CreateUser) DisplayName			--# Name of the user who saved this version of the form
--! </MoreColumns>
from
	dbo.ProfileUpdateResponse pur
join
	dbo.ProfileUpdate         pu     on pur.ProfileUpdateSID = pu.ProfileUpdateSID
join
	sf.FormOwner              fo     on pur.FormOwnerSID = fo.FormOwnerSID
--! <MoreJoins>
left outer join
	sf.ApplicationUser				zau on pur.CreateUser			 = zau.UserName -- we don't have the user SID who made the change; only their user name so OUTER join in case of delete
left outer join
	sf.Person									zp on zau.PersonSID				 = zp.PersonSID;
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the profile update response assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'ProfileUpdateResponseSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registration year the profile update was created in (set to current registration year by default)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'RegistrationYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the form version assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'FormVersionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the form content successfully passed validations', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'LastValidateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date when the next follow-up is required on the form.  Leave blank if no follow-up required.  When this date is reached the record appears on the Administrators list for "next-to-act".', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'NextFollowUp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'This value is set by customized rules in the form configuration to enable automatic approval of the form when required conditions have been met.  If all forms should be reviewed by adminsitrators, then the value is left turned off by the form. Note that the condition of making payment (e.g. to pay for the form if charges apply) is automatically taken into account and need not be addressed in the form configuration. It is possible to block automatic approval on any registrant through their profile.  That setting overrides the setting recorded here by rules in the form.', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'IsAutoApprovalEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The reason assigned to this profile update', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'ReasonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The unique identifier of the parent form (typically a renewal or reinstatement) the Profile Update is connected to.  | Null (blank) if this profile update form is not part of a form-set', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'ParentRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the profile update record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'ProfileUpdateRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the form owner | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'FormOwnerSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the form owner to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'FormOwnerLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this owner is a sub-type of assignee', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'IsAssignee'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the form owner record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'FormOwnerRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the user who saved this version of the form', 'SCHEMA', N'dbo', 'VIEW', N'vProfileUpdateResponse#Ext', 'COLUMN', N'DisplayName'
GO
