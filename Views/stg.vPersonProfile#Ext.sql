SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [stg].[vPersonProfile#Ext]
as
/*********************************************************************************************************************************
View    : stg.vPersonProfile#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the stg.PersonProfile base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vPersonProfile (referred to as the "entity" view in SGI documentation).

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
	 pp.PersonProfileSID
	,ps.ProcessingStatusSCD
	,ps.ProcessingStatusLabel
	,ps.IsClosedStatus
	,ps.IsActive                                                            ProcessingStatusIsActive
	,ps.IsDefault                                                           ProcessingStatusIsDefault
	,ps.RowGUID                                                             ProcessingStatusRowGUID
	,city.CityName                                                          CityCityName
	,city.StateProvinceSID                                                  CityStateProvinceSID
	,city.IsDefault                                                         CityIsDefault
	,city.IsActive                                                          CityIsActive
	,city.IsAdminReviewRequired                                             CityIsAdminReviewRequired
	,city.RowGUID                                                           CityRowGUID
	,country.CountryName                                                    CountryCountryName
	,country.ISOA2
	,country.ISOA3
	,country.ISONumber                                                      CountryISONumber
	,country.IsStateProvinceRequired
	,country.IsDefault                                                      CountryIsDefault
	,country.IsActive                                                       CountryIsActive
	,country.RowGUID                                                        CountryRowGUID
	,pma.PersonSID                                                          PersonMailingAddressPersonSID
	,pma.StreetAddress1                                                     PersonMailingAddressStreetAddress1
	,pma.StreetAddress2                                                     PersonMailingAddressStreetAddress2
	,pma.StreetAddress3                                                     PersonMailingAddressStreetAddress3
	,pma.CitySID                                                            PersonMailingAddressCitySID
	,pma.PostalCode                                                         PersonMailingAddressPostalCode
	,pma.RegionSID                                                          PersonMailingAddressRegionSID
	,pma.EffectiveTime
	,pma.IsAdminReviewRequired                                              PersonMailingAddressIsAdminReviewRequired
	,pma.LastVerifiedTime
	,pma.RowGUID                                                            PersonMailingAddressRowGUID
	,region.RegionLabel                                                     RegionRegionLabel
	,region.RegionName                                                      RegionRegionName
	,region.IsDefault                                                       RegionIsDefault
	,region.IsActive                                                        RegionIsActive
	,region.RowGUID                                                         RegionRowGUID
	,registrant.PersonSID                                                   RegistrantPersonSID
	,registrant.RegistrantNo                                                RegistrantRegistrantNo
	,registrant.YearOfInitialEmployment
	,registrant.IsOnPublicRegistry                                          RegistrantIsOnPublicRegistry
	,registrant.CityNameOfBirth
	,registrant.CountrySID                                                  RegistrantCountrySID
	,registrant.DirectedAuditYearCompetence                                 RegistrantDirectedAuditYearCompetence
	,registrant.DirectedAuditYearPracticeHours                              RegistrantDirectedAuditYearPracticeHours
	,registrant.LateFeeExclusionYear
	,registrant.IsRenewalAutoApprovalBlocked
	,registrant.RenewalExtensionExpiryTime
	,registrant.ArchivedTime                                                RegistrantArchivedTime
	,registrant.RowGUID                                                     RegistrantRowGUID
	,sp.StateProvinceName                                                   StateProvinceStateProvinceName
	,sp.StateProvinceCode                                                   StateProvinceStateProvinceCode
	,sp.CountrySID                                                          StateProvinceCountrySID
	,sp.ISONumber                                                           StateProvinceISONumber
	,sp.IsDisplayed
	,sp.IsDefault                                                           StateProvinceIsDefault
	,sp.IsActive                                                            StateProvinceIsActive
	,sp.IsAdminReviewRequired                                               StateProvinceIsAdminReviewRequired
	,sp.RowGUID                                                             StateProvinceRowGUID
	,au.PersonSID                                                           ApplicationUserPersonSID
	,au.CultureSID
	,au.AuthenticationAuthoritySID
	,au.UserName                                                            ApplicationUserUserName
	,au.LastReviewTime
	,au.LastReviewUser
	,au.IsPotentialDuplicate
	,au.IsTemplate
	,au.GlassBreakPassword
	,au.LastGlassBreakPasswordChangeTime
	,au.IsActive                                                            ApplicationUserIsActive
	,au.AuthenticationSystemID
	,au.RowGUID                                                             ApplicationUserRowGUID
	,gender.GenderSCD
	,gender.GenderLabel                                                     GenderGenderLabel
	,gender.IsActive                                                        GenderIsActive
	,gender.RowGUID                                                         GenderRowGUID
	,np.NamePrefixLabel                                                     NamePrefixNamePrefixLabel
	,np.IsActive                                                            NamePrefixIsActive
	,np.RowGUID                                                             NamePrefixRowGUID
	,person.GenderSID                                                       PersonGenderSID
	,person.NamePrefixSID                                                   PersonNamePrefixSID
	,person.FirstName                                                       PersonFirstName
	,person.CommonName                                                      PersonCommonName
	,person.MiddleNames                                                     PersonMiddleNames
	,person.LastName                                                        PersonLastName
	,person.BirthDate                                                       PersonBirthDate
	,person.DeathDate                                                       PersonDeathDate
	,person.HomePhone                                                       PersonHomePhone
	,person.MobilePhone                                                     PersonMobilePhone
	,person.IsTextMessagingEnabled                                          PersonIsTextMessagingEnabled
	,person.ImportBatch
	,person.RowGUID                                                         PersonRowGUID
	,pea.PersonSID                                                          PersonEmailAddressPersonSID
	,pea.EmailAddress                                                       PersonEmailAddressEmailAddress
	,pea.IsPrimary
	,pea.IsActive                                                           PersonEmailAddressIsActive
	,pea.RowGUID                                                            PersonEmailAddressRowGUID
	,stg.fPersonProfile#IsDeleteEnabled(pp.PersonProfileSID)                IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
  --! <MoreColumns>
  --! </MoreColumns>
from
	stg.PersonProfile        pp
join
	sf.ProcessingStatus      ps         on pp.ProcessingStatusSID = ps.ProcessingStatusSID
left outer join
	dbo.City                 city       on pp.CitySID = city.CitySID
left outer join
	dbo.Country              country    on pp.CountrySID = country.CountrySID
left outer join
	dbo.PersonMailingAddress pma        on pp.PersonMailingAddressSID = pma.PersonMailingAddressSID
left outer join
	dbo.Region               region     on pp.RegionSID = region.RegionSID
left outer join
	dbo.Registrant           registrant on pp.RegistrantSID = registrant.RegistrantSID
left outer join
	dbo.StateProvince        sp         on pp.StateProvinceSID = sp.StateProvinceSID
left outer join
	sf.ApplicationUser       au         on pp.ApplicationUserSID = au.ApplicationUserSID
left outer join
	sf.Gender                gender     on pp.GenderSID = gender.GenderSID
left outer join
	sf.NamePrefix            np         on pp.NamePrefixSID = np.NamePrefixSID
left outer join
	sf.Person                person     on pp.PersonSID = person.PersonSID
left outer join
	sf.PersonEmailAddress    pea        on pp.PersonEmailAddressSID = pea.PersonEmailAddressSID
--! <MoreJoins>
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person profile assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonProfileSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the processing status | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'ProcessingStatusSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the processing status to present in lists and look ups (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'ProcessingStatusLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates records in this status should be considered as closed by the application (not retryable) | This value cannot be set by the end user', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'IsClosedStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this processing status record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'ProcessingStatusIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default processing status to assign when new records are added', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'ProcessingStatusIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the processing status record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'ProcessingStatusRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CityCityName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The state province this city is in', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CityStateProvinceSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default city to assign when new records are added', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CityIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this city record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CityIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added through conversion or an address entered online)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CityIsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the city record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CityRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the country to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CountryCountryName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A 2-letter abbreviation to refer to the country using the ISO 3166 coding standard ', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'ISOA2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A 3-letter abbreviation to refer to the country using the ISO 3166 coding standard ', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'ISOA3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number to refer to the country using the ISO 3166 coding standard (this is a 3 digit number)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CountryISONumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default country to assign when new records are added', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CountryIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this country record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CountryIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the country record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CountryRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonMailingAddressPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this person mailing address is in', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonMailingAddressCitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this person mailing address', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonMailingAddressRegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added as a new address through a profile update or renewal entered online).  The form can be configured to block automatic approval when addresses change in the case of renewals.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonMailingAddressIsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last time the information collected on the organization was verified by an administrator (de-activate the record to avoid it being referenced going forward).', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'LastVerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person mailing address record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonMailingAddressRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the region to present in lists and look ups (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'RegionRegionLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the region to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'RegionRegionName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default region to assign when new records are added', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'RegionIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this region record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'RegionIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the region record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'RegionRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'RegistrantPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The year of initial employment in the profession if required for reporting and full history of employment was not converted', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'YearOfInitialEmployment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CityNameOfBirth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this registrant', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'RegistrantCountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'RegistrantDirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'RegistrantDirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled out ensures the member will not be assessed late fees for the registration year selected (limited to one year)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'LateFeeExclusionYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates automatic approval of this form type is disabled for the registrant.  Administrator review and approval is required.  This setting is only required where rules in the form would not otherwise block automatic approval. (e.g. the form may block auto-approval if a criminal record is reported or other non-qualifying details.) The setting is relevant only where automatic approval is configured for the form type.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'IsRenewalAutoApprovalBlocked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a date to extend the renewal period for this specific registrant to the end of the day entered.  | The later of this value and the standard schedule is applied. ', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'RenewalExtensionExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'RegistrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the state province to display on search results and reports (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'StateProvinceStateProvinceName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this state province', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'StateProvinceCountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A number to refer to the state or province using a coding standard - e.g. the  ISO 3166 standard for principal subdivisions of countries', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'StateProvinceISONumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default state province to assign when new records are added', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'StateProvinceIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this state province record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'StateProvinceIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added through conversion or an address entered online)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'StateProvinceIsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the state province record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'StateProvinceRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this user is based on', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'ApplicationUserPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The culture this user is assigned to', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'CultureSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The authentication authority used for logging in to the application (e.g. Google account) | For systems using Tenant Services for login, the value is copied from Tenant Services to the client database when the account is created.  The value of this column cannot be changed after the account is created (delete the account and recreate or create a new account).', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'AuthenticationAuthoritySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'the identity of the user as recorded in Active Directory and using "user@domain" style - example:   tara.knowles@soa.com', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'ApplicationUserUserName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'date and time this user profile was last reviewed to ensure it is still required', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'LastReviewTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'identity of the user (usually an administrator) who completed the last review of this user profile', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'LastReviewUser'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked indicates this may be a duplicate user profile and requires review from an administrator', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'IsPotentialDuplicate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'indicates this user will appear in the list of templates to copy from when creating new users - sets up same grants as starting point', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'IsTemplate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'stores the hashed value of a password applied by the user when seeking temporary elevated access to functions or data their profile does not normally provide', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'GlassBreakPassword'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time this user profile last changed their glass-break password | This value remains blank until password is initially set.  If password is cleared later, the time the password is set to NULL is stored.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'LastGlassBreakPasswordChangeTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this application user record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'ApplicationUserIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The GUID or similar identifier used by the authentication system to identify the user record | This value is used on federated logins (e.g. MS Account, Google Account) to identify the user since it is possible for the email captured in the UserName column to change over time.  The federated record identifier should not be captured into the UserName column since that value is used in the CreateUser and UpdateUser audit columns and GUID''s.  Note that where no federated provider is used (direct email login) this column is set to the same value as the RowGUID.  A bit in the entity view indicates whether the application user record is a federated login.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'AuthenticationSystemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the application user record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'ApplicationUserRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code assigned by the product to identify the gender | The code is not editable and records cannot be added or deleted from this table', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'GenderSCD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the gender to present in lists and look ups (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'GenderGenderLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this gender record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'GenderIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the gender record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'GenderRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the name prefix to present in lists and look ups (must be unique)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'NamePrefixNamePrefixLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this name prefix record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'NamePrefixIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the name prefix record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'NamePrefixRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The gender this person is assigned', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonGenderSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The name prefix assigned to this person', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonNamePrefixSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'given name for the person', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonFirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The usual first name of the person if different than the given first name', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonCommonName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'middle name or middle names, if known, of the person', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonMiddleNames'
GO
EXEC sp_addextendedproperty N'MS_Description', N'surname/family name of the person Test', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonLastName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether sending text messages is enabled for the user | Text messages are used for reminders and quick follow-ups and augment but do not replace email messaging.  If a person opts out of a Message Subscription type then messages for that type are not sent via email or text messaging.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonIsTextMessagingEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An identifier of the import batch used to add this record - if not imported this value is blank | This value is typically set to the date and time the import started followed by the importing user name.  The value is often used to query for latest imports.', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'ImportBatch'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The person record  this email address is based on', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonEmailAddressPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this person email address record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonEmailAddressIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the person email address record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'PersonEmailAddressRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'stg', 'VIEW', N'vPersonProfile#Ext', 'COLUMN', N'zContext'
GO
