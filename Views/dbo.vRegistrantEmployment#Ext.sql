SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantEmployment#Ext]
as
/*********************************************************************************************************************************
View    : dbo.vRegistrantEmployment#Ext
Notice  : Copyright © 2019 Softworks Group Inc.
Summary : extends the dbo.RegistrantEmployment base entity with calculated values, entity properties and columns from related tables
-----------------------------------------------------------------------------------------------------------------------------------
Author  : Generated by DB Studio: pEVGen | Designer: Tim Edlund
Version : April 2019
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view includes the primary key of the table but no other content from the base entity. Descriptive columns from parent tables
and a set of columns required by the Entity Framework (EF) are provided. The content of this view is joined with the table columns
to provide complete attribution of the entity in the view vRegistrantEmployment (referred to as the "entity" view in SGI documentation).

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
	 re.RegistrantEmploymentSID
	,ar.AgeRangeTypeSID
	,ar.AgeRangeLabel
	,ar.StartAge
	,ar.EndAge
	,ar.IsDefault                                                           AgeRangeIsDefault
	,ar.RowGUID                                                             AgeRangeRowGUID
	,er.EmploymentRoleName
	,er.EmploymentRoleCode
	,er.IsDefault                                                           EmploymentRoleIsDefault
	,er.IsActive                                                            EmploymentRoleIsActive
	,er.RowGUID                                                             EmploymentRoleRowGUID
	,etype.EmploymentTypeName
	,etype.EmploymentTypeCode
	,etype.EmploymentTypeCategory
	,etype.IsDefault                                                        EmploymentTypeIsDefault
	,etype.IsActive                                                         EmploymentTypeIsActive
	,etype.RowGUID                                                          EmploymentTypeRowGUID
	,o1.ParentOrgSID                                                        OrgParentOrgSID
	,o1.OrgTypeSID                                                          OrgOrgTypeSID
	,o1.OrgName                                                             OrgOrgName
	,o1.OrgLabel                                                            OrgOrgLabel
	,o1.StreetAddress1                                                      OrgStreetAddress1
	,o1.StreetAddress2                                                      OrgStreetAddress2
	,o1.StreetAddress3                                                      OrgStreetAddress3
	,o1.CitySID                                                             OrgCitySID
	,o1.PostalCode                                                          OrgPostalCode
	,o1.RegionSID                                                           OrgRegionSID
	,o1.Phone                                                               OrgPhone
	,o1.Fax                                                                 OrgFax
	,o1.WebSite                                                             OrgWebSite
	,o1.EmailAddress                                                        OrgEmailAddress
	,o1.InsuranceOrgSID                                                     OrgInsuranceOrgSID
	,o1.InsurancePolicyNo                                                   OrgInsurancePolicyNo
	,o1.InsuranceAmount                                                     OrgInsuranceAmount
	,o1.IsEmployer                                                          OrgIsEmployer
	,o1.IsCredentialAuthority                                               OrgIsCredentialAuthority
	,o1.IsInsurer                                                           OrgIsInsurer
	,o1.IsInsuranceCertificateRequired                                      OrgIsInsuranceCertificateRequired
	,o1.IsPublic                                                            OrgIsPublic
	,o1.IsActive                                                            OrgIsActive
	,o1.IsAdminReviewRequired                                               OrgIsAdminReviewRequired
	,o1.LastVerifiedTime                                                    OrgLastVerifiedTime
	,o1.RowGUID                                                             OrgRowGUID
	,ps.PracticeScopeName
	,ps.PracticeScopeCode
	,ps.IsDefault                                                           PracticeScopeIsDefault
	,ps.IsActive                                                            PracticeScopeIsActive
	,ps.RowGUID                                                             PracticeScopeRowGUID
	,registrant.PersonSID
	,registrant.RegistrantNo
	,registrant.YearOfInitialEmployment
	,registrant.IsOnPublicRegistry                                          RegistrantIsOnPublicRegistry
	,registrant.CityNameOfBirth
	,registrant.CountrySID
	,registrant.DirectedAuditYearCompetence
	,registrant.DirectedAuditYearPracticeHours
	,registrant.LateFeeExclusionYear
	,registrant.IsRenewalAutoApprovalBlocked
	,registrant.RenewalExtensionExpiryTime
	,registrant.ArchivedTime
	,registrant.RowGUID                                                     RegistrantRowGUID
	,o.ParentOrgSID                                                         OrgInsuranceParentOrgSID
	,o.OrgTypeSID                                                           OrgInsuranceOrgTypeSID
	,o.OrgName                                                              OrgInsuranceOrgName
	,o.OrgLabel                                                             OrgInsuranceOrgLabel
	,o.StreetAddress1                                                       OrgInsuranceStreetAddress1
	,o.StreetAddress2                                                       OrgInsuranceStreetAddress2
	,o.StreetAddress3                                                       OrgInsuranceStreetAddress3
	,o.CitySID                                                              OrgInsuranceCitySID
	,o.PostalCode                                                           OrgInsurancePostalCode
	,o.RegionSID                                                            OrgInsuranceRegionSID
	,o.Phone                                                                OrgInsurancePhone
	,o.Fax                                                                  OrgInsuranceFax
	,o.WebSite                                                              OrgInsuranceWebSite
	,o.EmailAddress                                                         OrgInsuranceEmailAddress
	,o.InsuranceOrgSID                                                      OrgInsuranceInsuranceOrgSID
	,o.InsurancePolicyNo                                                    OrgInsuranceInsurancePolicyNo
	,o.InsuranceAmount                                                      OrgInsuranceInsuranceAmount
	,o.IsEmployer                                                           OrgInsuranceIsEmployer
	,o.IsCredentialAuthority                                                OrgInsuranceIsCredentialAuthority
	,o.IsInsurer                                                            OrgInsuranceIsInsurer
	,o.IsInsuranceCertificateRequired                                       OrgInsuranceIsInsuranceCertificateRequired
	,o.IsPublic                                                             OrgInsuranceIsPublic
	,o.IsActive                                                             OrgInsuranceIsActive
	,o.IsAdminReviewRequired                                                OrgInsuranceIsAdminReviewRequired
	,o.LastVerifiedTime                                                     OrgInsuranceLastVerifiedTime
	,o.RowGUID                                                              OrgInsuranceRowGUID
	,sf.fIsActive(re.EffectiveTime, re.ExpiryTime)                          IsActive									--# Indicates if the assignment is currently active (not expired or future dated)
	,sf.fIsPending(re.EffectiveTime, re.ExpiryTime)                         IsPending									--# Indicates if the assignment will come into effect in the future
	,dbo.fRegistrantEmployment#IsDeleteEnabled(re.RegistrantEmploymentSID)  IsDeleteEnabled						--# Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)
	,cast(1 as tinyint)                                                     IsReselected							-- parameter for sproc calls through EF - reselects row as dataset
	,cast(1 as bit)                                                         IsNullApplied							-- parameter for sproc calls through EF - writes null parameter values
	,cast(null as xml)                                                      zContext									-- parameter for sproc calls through EF - utility parameter for customization
--! <MoreColumns>
 ,cast(re.OwnershipPercentage as bit)																																											 IsSelfEmployed									--# Indicates the member is self-employed as an owner of the employing organization
 ,dbo.fRegistrantEmployment#Rank(re.RegistrantEmploymentSID)																															 EmploymentRankNo								--# Ranking for this employment record against others in the same registration year (breaks ranking ties where hours are the same)
 ,zrepa.PracticeAreaSID																																																		 PrimaryPracticeAreaSID					--# key of the primary practice area
 ,zpa.PracticeAreaName																																																		 PrimaryPracticeAreaName				--# Name of the primary practice area
 ,zpa.PracticeAreaCode																																																		 PrimaryPracticeAreaCode				--# Code (CIHI) for the primary practice area
 ,zpa.IsPracticeScopeRequired																																																															--# Indicates if a scope-of-practice record must be defined for employment
 ,zes.EmploymentSupervisorSID																																																															--# Key of first supervisor relationship record
 ,zes.PersonSID																																																						 SupervisorPersonSID						--# Person key of supervisor
 ,cast(case when re.IsEmployerInsurance = cast(0 as bit) and zRegP.InsurancePolicyNo is not null then 1 else 0 end as bit) IsPrivateInsurance							--# Indicates the member has private insurance coverage in effect at this location
 ,isnull(o.OrgName, zInsuranceOrg.OrgName)																																								 EffectiveInsuranceProviderName --# Name of insurance company providing coverage at this place of employment
 ,isnull(re.InsurancePolicyNo, zRegP.InsurancePolicyNo)																																		 EffectiveInsurancePolicyNo			--# Number of insurance policy applying at this place of employment
 ,isnull(re.InsuranceAmount, zRegP.InsuranceAmount)																																				 EffectiveInsuranceAmount				--# Amount of insurance coverage applying at this place of employment
--! </MoreColumns>
from
	dbo.RegistrantEmployment re
join
	dbo.AgeRange             ar         on re.AgeRangeSID = ar.AgeRangeSID
join
	dbo.EmploymentRole       er         on re.EmploymentRoleSID = er.EmploymentRoleSID
join
	dbo.EmploymentType       etype      on re.EmploymentTypeSID = etype.EmploymentTypeSID
join
	dbo.Org                  o1         on re.OrgSID = o1.OrgSID
join
	dbo.PracticeScope        ps         on re.PracticeScopeSID = ps.PracticeScopeSID
join
	dbo.Registrant           registrant on re.RegistrantSID = registrant.RegistrantSID
left outer join
	dbo.Org                  o          on re.InsuranceOrgSID = o.OrgSID
--! <MoreJoins>
left outer join
	dbo.RegistrantEmploymentPracticeArea zrepa on re.RegistrantEmploymentSID = zrepa.RegistrantEmploymentSID and zrepa.IsPrimary = cast(1 as bit)
left outer join
	dbo.PracticeArea										 zpa on zrepa.PracticeAreaSID = zpa.PracticeAreaSID
left outer join
	dbo.RegistrantPractice							 zRegP on registrant.RegistrantSID = zRegP.RegistrantSID and re.RegistrationYear = zRegP.RegistrationYear
left outer join
	dbo.Org															 zInsuranceOrg on zRegP.OrgSID = zInsuranceOrg.OrgSID
outer apply
(
	select top (1)
		zes.EmploymentSupervisorSID
	from
		dbo.EmploymentSupervisor zes
	where
		zes.RegistrantEmploymentSID = re.RegistrantEmploymentSID
	order by
		zes.CreateTime
	 ,zes.EmploymentSupervisorSID
)																			 zesMin
left outer join
	dbo.EmploymentSupervisor zes on zesMin.EmploymentSupervisorSID = zes.EmploymentSupervisorSID;
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the registrant employment assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'RegistrantEmploymentSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the age range type assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'AgeRangeTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the age range to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'AgeRangeLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Starting age in years for the range', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'StartAge'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ending age in years for the range', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EndAge'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default age range to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'AgeRangeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the age range record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'AgeRangeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the employment role to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EmploymentRoleName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default employment role to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EmploymentRoleIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this employment role record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EmploymentRoleIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the employment role record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EmploymentRoleRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the employment type to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EmploymentTypeName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional grouping or category label to organize these types', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EmploymentTypeCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default employment type to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EmploymentTypeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this employment type record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EmploymentTypeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the employment type record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EmploymentTypeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgParentOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of org', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgOrgTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the org to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgOrgName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the org to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgOrgLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The first line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgStreetAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The second line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgStreetAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The third line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgStreetAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this org is in', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgCitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The postal or zip code of the organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgPostalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this org', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgRegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The phone number for the organization.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgPhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The fax number for the organization.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgFax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional email address to display on the Public Directory for general inquiries to the organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgEmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of employers applicants/registrants can choose from on forms | This value being enabled does not necessarily mean any applicants/registrants are actively employed by the organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgIsEmployer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of credential authorities user choose from when adding new credentials | This value being enabled does not necessarily mean any credentials are active for the organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgIsCredentialAuthority'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of insurers providing coverage to members | This value being enabled does not necessarily mean any member has identified this organization as an insurer', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgIsInsurer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Applies to insurance companies only and indicates if member must provide their insurance certificate number. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgIsInsuranceCertificateRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this org record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added as a new employer through an Application or Renewal entered online) The form can be configured to block automatic approval when new employer addresses are added in the case of renewals.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgIsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last time the information collected on the organization was verified by an administrator (de-activate the record to avoid it being referenced going forward).', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgLastVerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the practice scope to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'PracticeScopeName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record is the default practice scope to assign when new records are added', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'PracticeScopeIsDefault'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this practice scope record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'PracticeScopeIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the practice scope record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'PracticeScopeRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique sequential identifier for the person assigned by the system | Primary key - not editable', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'PersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The year of initial employment in the profession if required for reporting and full history of employment was not converted', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'YearOfInitialEmployment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the city to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'CityNameOfBirth'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The country assigned to this registrant', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'CountrySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of continuing competence/education claims (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'DirectedAuditYearCompetence'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a year for which this registrant is to receive an audit of practice hours (non-random, direct audit inclusion)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'DirectedAuditYearPracticeHours'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When filled out ensures the member will not be assessed late fees for the registration year selected (limited to one year)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'LateFeeExclusionYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates automatic approval of this form type is disabled for the registrant.  Administrator review and approval is required.  This setting is only required where rules in the form would not otherwise block automatic approval. (e.g. the form may block auto-approval if a criminal record is reported or other non-qualifying details.) The setting is relevant only where automatic approval is configured for the form type.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'IsRenewalAutoApprovalBlocked'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Enter a date to extend the renewal period for this specific registrant to the end of the day entered.  | The later of this value and the standard schedule is applied. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'RenewalExtensionExpiryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the registrant record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'RegistrantRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceParentOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type of org', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceOrgTypeSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name for the org to display on search results and reports (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceOrgName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Short (max 35 characters) label for the org to present in lists and look ups (must be unique)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceOrgLabel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The first line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceStreetAddress1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The second line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceStreetAddress2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The third line of the street address', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceStreetAddress3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The city this org is in', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceCitySID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The postal or zip code of the organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsurancePostalCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The region assigned to this org', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceRegionSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The phone number for the organization.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsurancePhone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The fax number for the organization.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceFax'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An optional email address to display on the Public Directory for general inquiries to the organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceEmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The org this  is defined for', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceInsuranceOrgSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of employers applicants/registrants can choose from on forms | This value being enabled does not necessarily mean any applicants/registrants are actively employed by the organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceIsEmployer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of credential authorities user choose from when adding new credentials | This value being enabled does not necessarily mean any credentials are active for the organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceIsCredentialAuthority'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the organization will be included in the list of insurers providing coverage to members | This value being enabled does not necessarily mean any member has identified this organization as an insurer', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceIsInsurer'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Applies to insurance companies only and indicates if member must provide their insurance certificate number. ', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceIsInsuranceCertificateRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this org record is in active use; un-check to eliminate from new record dialogs and active search results', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceIsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates this record was added by a non-administrator and requires review (e.g. added as a new employer through an Application or Renewal entered online) The form can be configured to block automatic approval when new employer addresses are added in the case of renewals.', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceIsAdminReviewRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The last time the information collected on the organization was verified by an administrator (de-activate the record to avoid it being referenced going forward).', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceLastVerifiedTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'System assigned globally unique identifier for the org record used for offline synchronization | This is a GUID value with the "RowGUID" SQL Server property set', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'OrgInsuranceRowGUID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment is currently active (not expired or future dated)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'IsActive'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if the assignment will come into effect in the future', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'IsPending'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates whether deletion of record is allowed | May be blocked by child records, security grants, and table-specific logic (see function)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'IsDeleteEnabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether the record should be reselected after update (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'IsReselected'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to control whether blank values provided from the UI end should overwrite content (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'IsNullApplied'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Parameter used by the application to allow the database API procedures to accept customized parameters (not displayed)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'zContext'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the member is self-employed as an owner of the employing organization', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'IsSelfEmployed'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ranking for this employment record against others in the same registration year (breaks ranking ties where hours are the same)', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EmploymentRankNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'key of the primary practice area', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'PrimaryPracticeAreaSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the primary practice area', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'PrimaryPracticeAreaName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Code (CIHI) for the primary practice area', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'PrimaryPracticeAreaCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates if a scope-of-practice record must be defined for employment', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'IsPracticeScopeRequired'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Key of first supervisor relationship record', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EmploymentSupervisorSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Person key of supervisor', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'SupervisorPersonSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Indicates the member has private insurance coverage in effect at this location', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'IsPrivateInsurance'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of insurance company providing coverage at this place of employment', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EffectiveInsuranceProviderName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of insurance policy applying at this place of employment', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EffectiveInsurancePolicyNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Amount of insurance coverage applying at this place of employment', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Ext', 'COLUMN', N'EffectiveInsuranceAmount'
GO
