SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vOrgOtherName]
as
/*********************************************************************************************************************************
View    : dbo.vOrgOtherName
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.OrgOtherName - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.OrgOtherName table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vOrgOtherNameExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vOrgOtherNameExt documentation for details. To add additional content to this view, customize
the dbo.vOrgOtherNameExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 oon.OrgOtherNameSID
	,oon.OrgSID
	,oon.OrgName
	,oon.ExpiryDate
	,oon.UserDefinedColumns
	,oon.OrgOtherNameXID
	,oon.LegacyKey
	,oon.IsDeleted
	,oon.CreateUser
	,oon.CreateTime
	,oon.UpdateUser
	,oon.UpdateTime
	,oon.RowGUID
	,oon.RowStamp
	,oonx.ParentOrgSID
	,oonx.OrgTypeSID
	,oonx.OrgOrgName
	,oonx.OrgLabel
	,oonx.StreetAddress1
	,oonx.StreetAddress2
	,oonx.StreetAddress3
	,oonx.CitySID
	,oonx.PostalCode
	,oonx.RegionSID
	,oonx.Phone
	,oonx.Fax
	,oonx.WebSite
	,oonx.EmailAddress
	,oonx.InsuranceOrgSID
	,oonx.InsurancePolicyNo
	,oonx.InsuranceAmount
	,oonx.IsEmployer
	,oonx.IsCredentialAuthority
	,oonx.IsInsurer
	,oonx.IsInsuranceCertificateRequired
	,oonx.IsPublic
	,oonx.OrgIsActive
	,oonx.IsAdminReviewRequired
	,oonx.LastVerifiedTime
	,oonx.OrgRowGUID
	,oonx.IsDeleteEnabled
	,oonx.IsReselected
	,oonx.IsNullApplied
	,oonx.zContext
	,oonx.EffectiveDate
from
	dbo.OrgOtherName      oon
join
	dbo.vOrgOtherName#Ext oonx	on oon.OrgOtherNameSID = oonx.OrgOtherNameSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.OrgOtherName', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the org other name assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'OrgOtherNameSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this other name is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the organization', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'OrgName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the org other name | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'OrgOtherNameXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the org other name | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this org other name record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the org other name | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the org other name record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org other name record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'ParentOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of org', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'OrgTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the org to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'OrgOrgName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the org to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'OrgLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The first line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'StreetAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The second line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'StreetAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The third line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'StreetAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this org is in', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'CitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The postal or zip code of the organization', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'PostalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this org', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The phone number for the organization.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'Phone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The fax number for the organization.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'Fax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional email address to display on the Public Directory for general inquiries to the organization', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'EmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'InsuranceOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of employers applicants/registrants can choose from on forms | This value being enabled does not necessarily mean any applicants/registrants are actively employed by the organization', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'IsEmployer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of credential authorities user choose from when adding new credentials | This value being enabled does not necessarily mean any credentials are active for the organization', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'IsCredentialAuthority'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of insurers providing coverage to members | This value being enabled does not necessarily mean any member has identified this organization as an insurer', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'IsInsurer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Applies to insurance companies only and indicates if member must provide their insurance certificate number. ', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'IsInsuranceCertificateRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this org record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'OrgIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added as a new employer through an Application or Renewal entered online) The form can be configured to block automatic approval when new employer addresses are added in the case of renewals.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'IsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last time the information collected on the organization was verified by an administrator (de-activate the record to avoid it being referenced going forward).', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'LastVerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'OrgRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date this organization name became effective (derived from previous expiry)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgOtherName', 'COLUMN', N'EffectiveDate'
GO
