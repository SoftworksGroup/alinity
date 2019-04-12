SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantEmploymentPracticeArea]
as
/*********************************************************************************************************************************
View    : dbo.vRegistrantEmploymentPracticeArea
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.RegistrantEmploymentPracticeArea - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.RegistrantEmploymentPracticeArea table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vRegistrantEmploymentPracticeAreaExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vRegistrantEmploymentPracticeAreaExt documentation for details. To add additional content to this view, customize
the dbo.vRegistrantEmploymentPracticeAreaExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 repa.RegistrantEmploymentPracticeAreaSID
	,repa.RegistrantEmploymentSID
	,repa.PracticeAreaSID
	,repa.IsPrimary
	,repa.UserDefinedColumns
	,repa.RegistrantEmploymentPracticeAreaXID
	,repa.LegacyKey
	,repa.IsDeleted
	,repa.CreateUser
	,repa.CreateTime
	,repa.UpdateUser
	,repa.UpdateTime
	,repa.RowGUID
	,repa.RowStamp
	,repax.PracticeAreaName
	,repax.PracticeAreaCode
	,repax.PracticeAreaCategory
	,repax.IsPracticeScopeRequired
	,repax.PracticeAreaIsDefault
	,repax.PracticeAreaIsActive
	,repax.PracticeAreaRowGUID
	,repax.RegistrantSID
	,repax.OrgSID
	,repax.RegistrationYear
	,repax.EmploymentTypeSID
	,repax.EmploymentRoleSID
	,repax.PracticeHours
	,repax.PracticeScopeSID
	,repax.AgeRangeSID
	,repax.IsOnPublicRegistry
	,repax.Phone
	,repax.SiteLocation
	,repax.EffectiveTime
	,repax.ExpiryTime
	,repax.Rank
	,repax.OwnershipPercentage
	,repax.IsEmployerInsurance
	,repax.InsuranceOrgSID
	,repax.InsurancePolicyNo
	,repax.InsuranceAmount
	,repax.RegistrantEmploymentRowGUID
	,repax.IsDeleteEnabled
	,repax.IsReselected
	,repax.IsNullApplied
	,repax.zContext
from
	dbo.RegistrantEmploymentPracticeArea      repa
join
	dbo.vRegistrantEmploymentPracticeArea#Ext repax	on repa.RegistrantEmploymentPracticeAreaSID = repax.RegistrantEmploymentPracticeAreaSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.RegistrantEmploymentPracticeArea', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant employment practice area assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'RegistrantEmploymentPracticeAreaSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant employment assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'RegistrantEmploymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the practice area assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'PracticeAreaSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant employment practice area | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'RegistrantEmploymentPracticeAreaXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant employment practice area | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant employment practice area record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant employment practice area | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant employment practice area record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant employment practice area record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the practice area to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'PracticeAreaName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize the practice areas', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'PracticeAreaCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates that a Practice Scope must be specified (otherwise Practice Scope defaults to Not Applicable)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'IsPracticeScopeRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice area to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'PracticeAreaIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice area record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'PracticeAreaIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice area record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'PracticeAreaRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant this employment is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the org assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the employment type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'EmploymentTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the employment type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'EmploymentRoleSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The practice scope assigned to this registrant employment', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'PracticeScopeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the Age Range assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'AgeRangeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this employer should be included in employers listed for the registrant on the public directly. The default setting is on, however, if the public registry configuration does not include employment, this setting has no impact.  Where employment is included in the public registry, this value should be included in the Profile Update form so that registrants can turn on/off the employers which display during the year as their employment changes.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'IsOnPublicRegistry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A phone number for this individual at their place of employment (do not enter mobile phone numbers here)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'Phone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A location of employment within the organization facility (optional)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'SiteLocation'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time the employment started if precision beyond registration year is required ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time when employment ended (blank if employment is still ongoing or expiry is unknown)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Where no hours have been reported for the employer, a ranking value used to set primary, secondary, etc. employer position.  ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'Rank'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When non-zero indicates member is self-employed. When value is > 0, then a specific share-percentage of ownership is specified. | Note that the value "-1"  is used to indicate a member is self-employed but ownership is unknown or not specified.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'OwnershipPercentage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this registrant employment', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'InsuranceOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant employment record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'RegistrantEmploymentRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmploymentPracticeArea', 'COLUMN', N'zContext'
GO
