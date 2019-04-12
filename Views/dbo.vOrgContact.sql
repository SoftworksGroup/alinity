SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vOrgContact]
as
/*********************************************************************************************************************************
View    : dbo.vOrgContact
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.OrgContact - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.OrgContact table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vOrgContactExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vOrgContactExt documentation for details. To add additional content to this view, customize
the dbo.vOrgContactExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 oc.OrgContactSID
	,oc.OrgSID
	,oc.PersonSID
	,oc.EffectiveTime
	,oc.ExpiryTime
	,oc.IsReviewAdmin
	,oc.Title
	,oc.DirectPhone
	,oc.IsAdminContact
	,oc.OwnershipPercentage
	,oc.TagList
	,oc.ChangeLog
	,oc.UserDefinedColumns
	,oc.OrgContactXID
	,oc.LegacyKey
	,oc.IsDeleted
	,oc.CreateUser
	,oc.CreateTime
	,oc.UpdateUser
	,oc.UpdateTime
	,oc.RowGUID
	,oc.RowStamp
	,ocx.ParentOrgSID
	,ocx.OrgTypeSID
	,ocx.OrgName
	,ocx.OrgLabel
	,ocx.StreetAddress1
	,ocx.StreetAddress2
	,ocx.StreetAddress3
	,ocx.CitySID
	,ocx.PostalCode
	,ocx.RegionSID
	,ocx.Phone
	,ocx.Fax
	,ocx.WebSite
	,ocx.EmailAddress
	,ocx.InsuranceOrgSID
	,ocx.InsurancePolicyNo
	,ocx.InsuranceAmount
	,ocx.IsEmployer
	,ocx.IsCredentialAuthority
	,ocx.IsInsurer
	,ocx.IsInsuranceCertificateRequired
	,ocx.IsPublic
	,ocx.OrgIsActive
	,ocx.IsAdminReviewRequired
	,ocx.LastVerifiedTime
	,ocx.OrgRowGUID
	,ocx.GenderSID
	,ocx.NamePrefixSID
	,ocx.FirstName
	,ocx.CommonName
	,ocx.MiddleNames
	,ocx.LastName
	,ocx.BirthDate
	,ocx.DeathDate
	,ocx.HomePhone
	,ocx.MobilePhone
	,ocx.IsTextMessagingEnabled
	,ocx.ImportBatch
	,ocx.PersonRowGUID
	,ocx.IsActive
	,ocx.IsPending
	,ocx.IsDeleteEnabled
	,ocx.IsReselected
	,ocx.IsNullApplied
	,ocx.zContext
	,ocx.IsOwner
	,ocx.RegistrantEmploymentSID
from
	dbo.OrgContact      oc
join
	dbo.vOrgContact#Ext ocx	on oc.OrgContactSID = ocx.OrgContactSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.OrgContact', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the org contact assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'OrgContactSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the organization assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the Contact assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this individual can review/verify ALL applications for this organization without being specifically assigned as a reviewer', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsReviewAdmin'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The position or role name that describes the relationship with this organization (job title)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'Title'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Direct phone number for this individual at the organization address (note: separate fields available for mobile and main organization phone numbers)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'DirectPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this individual is a general contact for the organization.  This value distinguishes contacts administration can use for mailing information to for the organization, from contacts who have simply listed the organization as an employer.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsAdminContact'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When value is > 0 indicates the contact has a share-percentage of ownership in the organization. | Note that ownership percentages may also be specified in Registrant-Employment and must be combined to attain full ownership view.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'OwnershipPercentage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'History of changes of audit interest made to the record', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'ChangeLog'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the org contact | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'OrgContactXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the org contact | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this org contact record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the org contact | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the org contact record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org contact record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'ParentOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of org', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'OrgTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the org to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'OrgName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the org to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'OrgLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The first line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'StreetAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The second line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'StreetAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The third line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'StreetAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this org is in', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'CitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The postal or zip code of the organization', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'PostalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this org', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The phone number for the organization.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'Phone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The fax number for the organization.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'Fax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional email address to display on the Public Directory for general inquiries to the organization', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'EmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'InsuranceOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of employers applicants/registrants can choose from on forms | This value being enabled does not necessarily mean any applicants/registrants are actively employed by the organization', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsEmployer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of credential authorities user choose from when adding new credentials | This value being enabled does not necessarily mean any credentials are active for the organization', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsCredentialAuthority'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of insurers providing coverage to members | This value being enabled does not necessarily mean any member has identified this organization as an insurer', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsInsurer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Applies to insurance companies only and indicates if member must provide their insurance certificate number. ', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsInsuranceCertificateRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this org record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'OrgIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added as a new employer through an Application or Renewal entered online) The form can be configured to block automatic approval when new employer addresses are added in the case of renewals.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last time the information collected on the organization was verified by an administrator (de-activate the record to avoid it being referenced going forward).', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'LastVerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'OrgRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'CommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment is currently active (not expired or future dated)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment will come into effect in the future', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsPending'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the person is the owner or part owner of the organization (invalid for educational institutions)', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'IsOwner'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Virtual column used by the application to support creating organization contact records based on employment', 'SCHEMA', N'dbo', 'VIEW', N'vOrgContact', 'COLUMN', N'RegistrantEmploymentSID'
GO
