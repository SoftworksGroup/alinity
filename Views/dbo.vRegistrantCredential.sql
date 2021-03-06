SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantCredential]
as
/*********************************************************************************************************************************
View    : dbo.vRegistrantCredential
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for dbo.RegistrantCredential - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the dbo.RegistrantCredential table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to dbo.vRegistrantCredentialExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See dbo.vRegistrantCredentialExt documentation for details. To add additional content to this view, customize
the dbo.vRegistrantCredentialExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 rc.RegistrantCredentialSID
	,rc.RegistrantSID
	,rc.CredentialSID
	,rc.OrgSID
	,rc.ProgramName
	,rc.ProgramStartDate
	,rc.ProgramTargetCompletionDate
	,rc.EffectiveTime
	,rc.ExpiryTime
	,rc.FieldOfStudySID
	,rc.UserDefinedColumns
	,rc.RegistrantCredentialXID
	,rc.LegacyKey
	,rc.IsDeleted
	,rc.CreateUser
	,rc.CreateTime
	,rc.UpdateUser
	,rc.UpdateTime
	,rc.RowGUID
	,rc.RowStamp
	,rcx.CredentialTypeSID
	,rcx.CredentialLabel
	,rcx.ToolTip
	,rcx.IsRelatedToProfession
	,rcx.IsProgramRequired
	,rcx.IsSpecialization
	,rcx.CredentialIsActive
	,rcx.CredentialCode
	,rcx.CredentialRowGUID
	,rcx.FieldOfStudyName
	,rcx.FieldOfStudyCode
	,rcx.FieldOfStudyCategory
	,rcx.FieldOfStudyIsDefault
	,rcx.FieldOfStudyIsActive
	,rcx.FieldOfStudyRowGUID
	,rcx.PersonSID
	,rcx.RegistrantNo
	,rcx.YearOfInitialEmployment
	,rcx.IsOnPublicRegistry
	,rcx.CityNameOfBirth
	,rcx.CountrySID
	,rcx.DirectedAuditYearCompetence
	,rcx.DirectedAuditYearPracticeHours
	,rcx.LateFeeExclusionYear
	,rcx.IsRenewalAutoApprovalBlocked
	,rcx.RenewalExtensionExpiryTime
	,rcx.ArchivedTime
	,rcx.RegistrantRowGUID
	,rcx.ParentOrgSID
	,rcx.OrgTypeSID
	,rcx.OrgName
	,rcx.OrgLabel
	,rcx.StreetAddress1
	,rcx.StreetAddress2
	,rcx.StreetAddress3
	,rcx.CitySID
	,rcx.PostalCode
	,rcx.RegionSID
	,rcx.Phone
	,rcx.Fax
	,rcx.WebSite
	,rcx.EmailAddress
	,rcx.InsuranceOrgSID
	,rcx.InsurancePolicyNo
	,rcx.InsuranceAmount
	,rcx.IsEmployer
	,rcx.IsCredentialAuthority
	,rcx.IsInsurer
	,rcx.IsInsuranceCertificateRequired
	,rcx.IsPublic
	,rcx.OrgIsActive
	,rcx.IsAdminReviewRequired
	,rcx.LastVerifiedTime
	,rcx.OrgRowGUID
	,rcx.IsActive
	,rcx.IsPending
	,rcx.IsDeleteEnabled
	,rcx.IsReselected
	,rcx.IsNullApplied
	,rcx.zContext
	,rcx.IsQualifying
from
	dbo.RegistrantCredential      rc
join
	dbo.vRegistrantCredential#Ext rcx	on rc.RegistrantCredentialSID = rcx.RegistrantCredentialSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'dbo.RegistrantCredential', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant credential assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'RegistrantCredentialSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The credential assigned to this registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'CredentialSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org assigned to this registrant credential', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'OrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The time this restriction/condition was put into effect or most recently changed | Check Change Audit column for history', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'ProgramStartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ending time this restriction/condition was effective.  When blank indicates restriction remains in effect. | See Change Audit for history of restriction being turned on/off', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'ProgramTargetCompletionDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The starting date this specialization or credential was effective', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'EffectiveTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The ending date the specialization or credential was effective.  When blank indicates the specialization remains in effect. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'ExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The field of study assigned to this registrant credential', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'FieldOfStudySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the registrant credential | Forms customization is required to access extended XML content', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'RegistrantCredentialXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the registrant credential | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this registrant credential record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the registrant credential | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the registrant credential record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant credential record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of credential', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'CredentialTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the credential to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'CredentialLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short explanatory text describing the credential often shown to end-users on mouse-over and/or press of info button', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'ToolTip'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if this credential is related to professional practice | This value is automaticallly set on by the application where the credential is set a qualifying', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsRelatedToProfession'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if a program-name must be entered when this credential is claimed | This option should be checked if the credential is a generic type like "Diploma", "Certificate", etc. where a specific field of study is not mentioned.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsProgramRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this credential should be displayed as a specialization on the license/permit and Public Directory', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsSpecialization'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this credential record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'CredentialIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A code used to report on this credential either internally or externally.  The code for CIHI for "Not Provided" is "9" (set as default)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'CredentialCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the credential record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'CredentialRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the field of study to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'FieldOfStudyName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize the practice areas', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'FieldOfStudyCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default field of study to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'FieldOfStudyIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this field of study record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'FieldOfStudyIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the field of study record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'FieldOfStudyRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The year of initial employment in the profession if required for reporting and full history of employment was not converted', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'YearOfInitialEmployment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'CityNameOfBirth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'DirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'DirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled out ensures the member will not be assessed late fees for the registration year selected (limited to one year)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'LateFeeExclusionYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates automatic approval of this form type is disabled for the registrant.  Administrator review and approval is required.  This setting is only required where rules in the form would not otherwise block automatic approval. (e.g. the form may block auto-approval if a criminal record is reported or other non-qualifying details.) The setting is relevant only where automatic approval is configured for the form type.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsRenewalAutoApprovalBlocked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a date to extend the renewal period for this specific registrant to the end of the day entered.  | The later of this value and the standard schedule is applied. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'RenewalExtensionExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'RegistrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'ParentOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of org', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'OrgTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the org to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'OrgName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the org to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'OrgLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The first line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'StreetAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The second line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'StreetAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The third line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'StreetAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this org is in', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'CitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The postal or zip code of the organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'PostalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this org', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The phone number for the organization.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'Phone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The fax number for the organization.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'Fax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional email address to display on the Public Directory for general inquiries to the organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'EmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'InsuranceOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of employers applicants/registrants can choose from on forms | This value being enabled does not necessarily mean any applicants/registrants are actively employed by the organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsEmployer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of credential authorities user choose from when adding new credentials | This value being enabled does not necessarily mean any credentials are active for the organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsCredentialAuthority'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of insurers providing coverage to members | This value being enabled does not necessarily mean any member has identified this organization as an insurer', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsInsurer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Applies to insurance companies only and indicates if member must provide their insurance certificate number. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsInsuranceCertificateRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this org record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'OrgIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added as a new employer through an Application or Renewal entered online) The form can be configured to block automatic approval when new employer addresses are added in the case of renewals.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last time the information collected on the organization was verified by an administrator (de-activate the record to avoid it being referenced going forward).', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'LastVerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'OrgRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment is currently active (not expired or future dated)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment will come into effect in the future', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsPending'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the credential is qualifying for practice in the profession', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential', 'COLUMN', N'IsQualifying'
GO
