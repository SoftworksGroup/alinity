SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantEmploymentPracticeArea#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vRegistrantEmploymentPracticeArea#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.RegistrantEmploymentPracticeArea base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vRegistrantEmploymentPracticeArea (referred to as the "entity" view in SGI documentation).

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
	 repa.RegistrantEmploymentPracticeAreaSID
	,pa.PracticeAreaName
	,pa.PracticeAreaCode
	,pa.PracticeAreaCategory
	,pa.IsPracticeScopeRequired
	,pa.IsDefault                                                                                    PracticeAreaIsDefault
	,pa.IsActive                                                                                     PracticeAreaIsActive
	,pa.RowGUID                                                                                      PracticeAreaRowGUID
	,re.RegistrantSID
	,re.OrgSID
	,re.RegistrationYear
	,re.EmploymentTypeSID
	,re.EmploymentRoleSID
	,re.PracticeHours
	,re.PracticeScopeSID
	,re.AgeRangeSID
	,re.IsOnPublicRegistry
	,re.Phone
	,re.SiteLocation
	,re.EffectiveTime
	,re.ExpiryTime
	,re.Rank
	,re.OwnershipPercentage
	,re.IsEmployerInsurance
	,re.InsuranceOrgSID
	,re.InsurancePolicyNo
	,re.InsuranceAmount
	,re.RowGUID                                                                                      RegistrantEmploymentRowGUID
	,dbo.fRegistrantEmploymentPracticeArea#IsDeleteEnabled(repa.RegistrantEmploymentPracticeAreaSID) IsDeleteEnabled--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                                              IsReselected		-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                                                  IsNullApplied	-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                                               zContext				-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	dbo.RegistrantEmploymentPracticeArea repa
join
	dbo.PracticeArea                     pa     on repa.PracticeAreaSID = pa.PracticeAreaSID
join
	dbo.RegistrantEmployment             re     on repa.RegistrantEmploymentSID = re.RegistrantEmploymentSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant employment practice area assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'RegistrantEmploymentPracticeAreaSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the practice area to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'PracticeAreaName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize the practice areas', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'PracticeAreaCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that a Practice Scope must be specified (otherwise Practice Scope defaults to Not Applicable)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'IsPracticeScopeRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice area to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'PracticeAreaIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice area record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'PracticeAreaIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice area record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'PracticeAreaRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant this employment is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the org assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the employment type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'EmploymentTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the employment type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'EmploymentRoleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice scope assigned to this registrant employment', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'PracticeScopeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the Age Range assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'AgeRangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this employer should be included in employers listed for the registrant on the public directly. The default setting is on, however, if the public registry configuration does not include employment, this setting has no impact.  Where employment is included in the public registry, this value should be included in the Profile Update form so that registrants can turn on/off the employers which display during the year as their employment changes.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'IsOnPublicRegistry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A phone number for this individual at their place of employment (do not enter mobile phone numbers here)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'Phone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A location of employment within the organization facility (optional)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'SiteLocation'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the employment started if precision beyond registration year is required ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when employment ended (blank if employment is still ongoing or expiry is unknown)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Where no hours have been reported for the employer, a ranking value used to set primary, secondary, etc. employer position.  ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'Rank'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When non-zero indicates member is self-employed. When value is > 0, then a specific share-percentage of ownership is specified. | Note that the value "-1"  is used to indicate a member is self-employed but ownership is unknown or not specified.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'OwnershipPercentage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this registrant employment', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'InsuranceOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant employment record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'RegistrantEmploymentRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea#Ext', 'COLUMN', N'zContext'
GO
