SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [stg].[vPersonProfile]
as
/*********************************************************************************************************************************
View    : stg.vPersonProfile
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : entity view for stg.PersonProfile - includes all table columns and columns from extended view
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is the main view for the stg.PersonProfile table.  The view provides a comprehensive set of attributes for the entity
 and is the recommended data source for user interface and detailed reporting queries.

This view joins to stg.vPersonProfileExt which includes related columns from parent tables, counts of records from child tables
and calculated columns. See stg.vPersonProfileExt documentation for details. To add additional content to this view, customize
the stg.vPersonProfileExt view – do NOT customize this view directly. Customization of the "Example" block is the only area of
source code preserved on regeneration.  This view is NOT an extension point for client-specific configuration.

-------------------------------------------------------------------------------------------------------------------------------- */

select
	 pp.PersonProfileSID
	,pp.ProcessingStatusSID
	,pp.SourceFileName
	,pp.LastName
	,pp.FirstName
	,pp.CommonName
	,pp.MiddleNames
	,pp.EmailAddress
	,pp.HomePhone
	,pp.MobilePhone
	,pp.IsTextMessagingEnabled
	,pp.SignatureImage
	,pp.IdentityPhoto
	,pp.GenderCode
	,pp.GenderLabel
	,pp.NamePrefixLabel
	,pp.BirthDate
	,pp.DeathDate
	,pp.UserName
	,pp.SubDomain
	,pp.Password
	,pp.StreetAddress1
	,pp.StreetAddress2
	,pp.StreetAddress3
	,pp.CityName
	,pp.StateProvinceName
	,pp.StateProvinceCode
	,pp.PostalCode
	,pp.CountryName
	,pp.CountryISOA3
	,pp.AddressPhone
	,pp.AddressFax
	,pp.AddressEffectiveTime
	,pp.RegionLabel
	,pp.RegionName
	,pp.RegistrantNo
	,pp.ArchivedTime
	,pp.IsOnPublicRegistry
	,pp.DirectedAuditYearCompetence
	,pp.DirectedAuditYearPracticeHours
	,pp.PersonSID
	,pp.PersonEmailAddressSID
	,pp.ApplicationUserSID
	,pp.PersonMailingAddressSID
	,pp.RegionSID
	,pp.NamePrefixSID
	,pp.GenderSID
	,pp.CitySID
	,pp.StateProvinceSID
	,pp.CountrySID
	,pp.RegistrantSID
	,pp.ProcessingComments
	,pp.UserDefinedColumns
	,pp.PersonProfileXID
	,pp.LegacyKey
	,pp.IsDeleted
	,pp.CreateUser
	,pp.CreateTime
	,pp.UpdateUser
	,pp.UpdateTime
	,pp.RowGUID
	,pp.RowStamp
	,ppx.ProcessingStatusSCD
	,ppx.ProcessingStatusLabel
	,ppx.IsClosedStatus
	,ppx.ProcessingStatusIsActive
	,ppx.ProcessingStatusIsDefault
	,ppx.ProcessingStatusRowGUID
	,ppx.CityCityName
	,ppx.CityStateProvinceSID
	,ppx.CityIsDefault
	,ppx.CityIsActive
	,ppx.CityIsAdminReviewRequired
	,ppx.CityRowGUID
	,ppx.CountryCountryName
	,ppx.ISOA2
	,ppx.ISOA3
	,ppx.CountryISONumber
	,ppx.IsStateProvinceRequired
	,ppx.CountryIsDefault
	,ppx.CountryIsActive
	,ppx.CountryRowGUID
	,ppx.PersonMailingAddressPersonSID
	,ppx.PersonMailingAddressStreetAddress1
	,ppx.PersonMailingAddressStreetAddress2
	,ppx.PersonMailingAddressStreetAddress3
	,ppx.PersonMailingAddressCitySID
	,ppx.PersonMailingAddressPostalCode
	,ppx.PersonMailingAddressRegionSID
	,ppx.EffectiveTime
	,ppx.PersonMailingAddressIsAdminReviewRequired
	,ppx.LastVerifiedTime
	,ppx.PersonMailingAddressRowGUID
	,ppx.RegionRegionLabel
	,ppx.RegionRegionName
	,ppx.RegionIsDefault
	,ppx.RegionIsActive
	,ppx.RegionRowGUID
	,ppx.RegistrantPersonSID
	,ppx.RegistrantRegistrantNo
	,ppx.YearOfInitialEmployment
	,ppx.RegistrantIsOnPublicRegistry
	,ppx.CityNameOfBirth
	,ppx.RegistrantCountrySID
	,ppx.RegistrantDirectedAuditYearCompetence
	,ppx.RegistrantDirectedAuditYearPracticeHours
	,ppx.LateFeeExclusionYear
	,ppx.IsRenewalAutoApprovalBlocked
	,ppx.RenewalExtensionExpiryTime
	,ppx.RegistrantArchivedTime
	,ppx.RegistrantRowGUID
	,ppx.StateProvinceStateProvinceName
	,ppx.StateProvinceStateProvinceCode
	,ppx.StateProvinceCountrySID
	,ppx.StateProvinceISONumber
	,ppx.IsDisplayed
	,ppx.StateProvinceIsDefault
	,ppx.StateProvinceIsActive
	,ppx.StateProvinceIsAdminReviewRequired
	,ppx.StateProvinceRowGUID
	,ppx.ApplicationUserPersonSID
	,ppx.CultureSID
	,ppx.AuthenticationAuthoritySID
	,ppx.ApplicationUserUserName
	,ppx.LastReviewTime
	,ppx.LastReviewUser
	,ppx.IsPotentialDuplicate
	,ppx.IsTemplate
	,ppx.GlassBreakPassword
	,ppx.LastGlassBreakPasswordChangeTime
	,ppx.ApplicationUserIsActive
	,ppx.AuthenticationSystemID
	,ppx.ApplicationUserRowGUID
	,ppx.GenderSCD
	,ppx.GenderGenderLabel
	,ppx.GenderIsActive
	,ppx.GenderRowGUID
	,ppx.NamePrefixNamePrefixLabel
	,ppx.NamePrefixIsActive
	,ppx.NamePrefixRowGUID
	,ppx.PersonGenderSID
	,ppx.PersonNamePrefixSID
	,ppx.PersonFirstName
	,ppx.PersonCommonName
	,ppx.PersonMiddleNames
	,ppx.PersonLastName
	,ppx.PersonBirthDate
	,ppx.PersonDeathDate
	,ppx.PersonHomePhone
	,ppx.PersonMobilePhone
	,ppx.PersonIsTextMessagingEnabled
	,ppx.ImportBatch
	,ppx.PersonRowGUID
	,ppx.PersonEmailAddressPersonSID
	,ppx.PersonEmailAddressEmailAddress
	,ppx.IsPrimary
	,ppx.PersonEmailAddressIsActive
	,ppx.PersonEmailAddressRowGUID
	,ppx.IsDeleteEnabled
	,ppx.IsReselected
	,ppx.IsNullApplied
	,ppx.zContext
from
	stg.PersonProfile      pp
join
	stg.vPersonProfile#Ext ppx	on pp.PersonProfileSID = ppx.PersonProfileSID
GO
EXEC sp_addextendedproperty N'SGI_ApplicationEntitySCD', N'stg.PersonProfile', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person profile assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The status of the person profile', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ProcessingStatusSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the file this record was obtained from on the end-user''s system | The full path and filename can be provided.  This value can be used to find all ContactProfile records imported in a batch if the file name is changed for each upload.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'SourceFileName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Surname or family name of the person', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'LastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Given name of first name of the person', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Middle name or middle names, if known, of the person - may also be used for middle initial(s)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'MiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Email address for the person - must be unique - shared email addresses are not allowed | This value does not have to be unique in this table but is validated for uniqueness in the Person Email Address table prior to import', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'EmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The home phone number of the person', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'HomePhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The cellular phone number of the person', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'MobilePhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The sex of the person - may be entered as any valid code or label as stored in the Gender master table', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'GenderLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A salutation to put with the person''s name - e.g. "Ms.", "Dr.", "Mr." etc.  -  value is checked against Name Prefix master table', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'NamePrefixLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person''s date of birth', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'BirthDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The first line of the preferred mail address for this person', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'StreetAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The second line of the preferred mail address for this person (do not enter City or State here)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'StreetAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The third line of the preferred mail address for this person (do not enter City or State here)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'StreetAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the city where this person lives', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name of the state or province where this person lives', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'StateProvinceName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The zip code or postal code for the mailing address provided', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PostalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'DirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'DirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this profile is based on', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person email address assigned to this person profile', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonEmailAddressSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user assigned to this person profile', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ApplicationUserSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person mailing address assigned to this person profile', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonMailingAddressSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this person profile', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person profile', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'NamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person profile is assigned', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'GenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this person profile is in', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The state province this person profile is in', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'StateProvinceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this person profile', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The registrant assigned to this person profile', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RegistrantSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A log of errors or warnings encountered when processing the record', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ProcessingComments'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An XML document defining additional values to store with the person profile | Forms customization is required to access extended XML content', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'UserDefinedColumns'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier value used in extended logic and business rules | Customization is required to apply the identifier', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonProfileXID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key or linking value from previous system used in the conversion of records into the current database | No unique-constraint is enforced on this column', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'LegacyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates deletion is in progress - enables capture of audit details of the deleting user', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'IsDeleted'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who created the person profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CreateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this person profile record was created | System assigned.  Value includes timezone offset.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CreateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The application user who last updated the person profile | Application user names appear as: "user@domain" while database user names appear as: "domain\user"', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'UpdateUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the person profile record was last updated | Tracks updates through the application only. System assigned.  Value includes time zone offset.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'UpdateTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person profile record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record version identifier used to avoid overwrites during concurrent updates | This value is not displayed in the user interface', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RowStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the processing status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ProcessingStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the processing status to present in lists and look ups (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ProcessingStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates records in this status should be considered as closed by the application (not retryable) | This value cannot be set by the end user', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'IsClosedStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this processing status record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ProcessingStatusIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default processing status to assign when new records are added', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ProcessingStatusIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the processing status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ProcessingStatusRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CityCityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The state province this city is in', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CityStateProvinceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default city to assign when new records are added', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CityIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this city record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CityIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added through conversion or an address entered online)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CityIsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the city record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the country to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CountryCountryName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A 2-letter abbreviation to refer to the country using the ISO 3166 coding standard ', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ISOA2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A 3-letter abbreviation to refer to the country using the ISO 3166 coding standard ', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ISOA3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number to refer to the country using the ISO 3166 coding standard (this is a 3 digit number)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CountryISONumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default country to assign when new records are added', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CountryIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this country record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CountryIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the country record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CountryRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonMailingAddressPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this person mailing address is in', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonMailingAddressCitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this person mailing address', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonMailingAddressRegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added as a new address through a profile update or renewal entered online).  The form can be configured to block automatic approval when addresses change in the case of renewals.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonMailingAddressIsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last time the information collected on the organization was verified by an administrator (de-activate the record to avoid it being referenced going forward).', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'LastVerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person mailing address record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonMailingAddressRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the region to present in lists and look ups (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RegionRegionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the region to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RegionRegionName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default region to assign when new records are added', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RegionIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this region record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RegionIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the region record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RegionRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RegistrantPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The year of initial employment in the profession if required for reporting and full history of employment was not converted', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'YearOfInitialEmployment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CityNameOfBirth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this registrant', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RegistrantCountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RegistrantDirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RegistrantDirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled out ensures the member will not be assessed late fees for the registration year selected (limited to one year)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'LateFeeExclusionYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates automatic approval of this form type is disabled for the registrant.  Administrator review and approval is required.  This setting is only required where rules in the form would not otherwise block automatic approval. (e.g. the form may block auto-approval if a criminal record is reported or other non-qualifying details.) The setting is relevant only where automatic approval is configured for the form type.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'IsRenewalAutoApprovalBlocked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a date to extend the renewal period for this specific registrant to the end of the day entered.  | The later of this value and the standard schedule is applied. ', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RenewalExtensionExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'RegistrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the state province to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'StateProvinceStateProvinceName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this state province', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'StateProvinceCountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number to refer to the state or province using a coding standard - e.g. the  ISO 3166 standard for principal subdivisions of countries', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'StateProvinceISONumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default state province to assign when new records are added', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'StateProvinceIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this state province record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'StateProvinceIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added through conversion or an address entered online)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'StateProvinceIsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the state province record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'StateProvinceRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this user is based on', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ApplicationUserPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The culture this user is assigned to', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The authentication authority used for logging in to the application (e.g. Google account) | For systems using Tenant Services for login, the value is copied from Tenant Services to the client database when the account is created.  The value of this column cannot be changed after the account is created (delete the account and recreate or create a new account).', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'AuthenticationAuthoritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the identity of the user as recorded in Active Directory and using "user@domain" style - example:   tara.knowles@soa.com', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ApplicationUserUserName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'date and time this user profile was last reviewed to ensure it is still required', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'LastReviewTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'identity of the user (usually an administrator) who completed the last review of this user profile', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'LastReviewUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked indicates this may be a duplicate user profile and requires review from an administrator', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'IsPotentialDuplicate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates this user will appear in the list of templates to copy from when creating new users - sets up same grants as starting point', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'IsTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'stores the hashed value of a password applied by the user when seeking temporary elevated access to functions or data their profile does not normally provide', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'GlassBreakPassword'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this user profile last changed their glass-break password | This value remains blank until password is initially set.  If password is cleared later, the time the password is set to NULL is stored.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'LastGlassBreakPasswordChangeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this application user record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ApplicationUserIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The GUID or similar identifier used by the authentication system to identify the user record | This value is used on federated logins (e.g. MS Account, Google Account) to identify the user since it is possible for the email captured in the UserName column to change over time.  The federated record identifier should not be captured into the UserName column since that value is used in the CreateUser and UpdateUser audit columns and GUID''s.  Note that where no federated provider is used (direct email login) this column is set to the same value as the RowGUID.  A bit in the entity view indicates whether the application user record is a federated login.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'AuthenticationSystemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ApplicationUserRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the gender | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'GenderSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the gender to present in lists and look ups (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'GenderGenderLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this gender record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'GenderIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the gender record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'GenderRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the name prefix to present in lists and look ups (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'NamePrefixNamePrefixLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this name prefix record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'NamePrefixIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the name prefix record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'NamePrefixRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonGenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonNamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonFirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonCommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonMiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonLastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonIsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this email address is based on', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonEmailAddressPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this person email address record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonEmailAddressIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person email address record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'PersonEmailAddressRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile', 'COLUMN', N'zContext'
GO