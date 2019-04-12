SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrant#LatestProfile
/*********************************************************************************************************************************
View		: Registrant - Latest Profile
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns a comprehensive record of latest registration, employment, credential and contact information for registrants
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This view includes the major components of registrant records.  The view includes the latest or most recent data for each category.  
Content includes:

	o contact information, email, phone, address etc.
	o latest registration details ("latest" may still be expired)
	o qualifying credential information
	o latest practice information (practice area, age group, etc.)
	o languages
	o specializations
	o restrictions on practice
	o on-going audit status (yes=1 or No=0)
	o employment data for the latest primary employer

The view returns a record for all registrants - even if they have had only an application status and not actually become a permit holder. To filter the content to active members only - select where RegistrantIsCurrentlyActive = 1.  

Access from:  Table Management -> Registrant, and, People (for filtered exports)

<TestHarness>
	<Test Name = "Random" Description="Returns contents of the view for a set of active registrants selected at random.">
	<SQLScript>
	<![CDATA[

select top(100) x.* from	dbo.vRegistrant#LatestProfile x where x.RegistrantIsCurrentlyActive = 1

if @@rowcount = 0 
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:01:00" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vRegistrant#LatestProfile'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	lreg.RegistrantNo
 ,lreg.LatestRegistrationYear
 ,lreg.RegistrantLabel
 ,lreg.RegistrationLabel
 ,lreg.ReasonName
 ,lreg.LatestRegistrationEffectiveTime
 ,lreg.LatestRegistrationExpiryTime
 ,lreg.BirthDate
 ,lreg.DeathDate
 ,lreg.HomePhone
 ,lreg.MobilePhone
 ,lreg.IsOnPublicRegistry
 ,lreg.RegistrantIsCurrentlyActive
 ,dbo.fRegistrant#HasOpenAudit(lreg.RegistrantSID) HasOpenAudit
 ,pmac.StreetAddress1
 ,pmac.StreetAddress2
 ,pmac.StreetAddress3
 ,pmac.CityName
 ,pmac.StateProvinceName
 ,pmac.PostalCode
 ,pmac.CountryName
 ,pmac.StateProvinceCode
 ,rll.LanguageList
 ,rsl.SpecializationList
 ,rprl.PracticeRestrictionList
 ,rcq.CredentialLabel															 QualifyingCredentialLabel
 ,rcq.GraduationYear															 QualifyingGraduationYear
 ,rcq.GrantingOrgName															 QualifyingGrantingOrgName
 ,rcq.GrantingOrgCountryName											 QualifyingGrantingOrgCountryName
 ,rcq.GrantingOrgRegionName												 QualifyingGrantingOrgRegionName
 ,emp.OrgName
 ,emp.OrgTypeName
 ,emp.OrgTypeCode
 ,emp.OrgTypeCategory
 ,emp.EmployerPracticeHours
 ,emp.EmploymentTypeName
 ,emp.EmploymentTypeCode
 ,emp.EmploymentTypeCategory
 ,emp.EmploymentRoleName
 ,emp.EmploymentRoleCode
 ,emp.PracticeScopeName
 ,emp.PracticeScopeCode
 ,emp.PracticeAreaName														 PrimaryPracticeAreaName
 ,emp.PracticeAreaCode														 PrimaryPracticeAreaCode
 ,emp.PracticeAreaCategory												 PrimaryPracticeAreaCategory
 ,repal.PracticeAreaList
 ,emp.EmploymentDirectPhone
 ,emp.EmployerMainPhone
 ,emp.EmployerFaxPhone
 ,emp.EmployerStreetAddress1
 ,emp.EmployerStreetAddress2
 ,emp.EmployerStreetAddress3
 ,emp.EmployerOrgCityName
 ,emp.EmployerOrgStateProvinceCode
 ,emp.EmployerOrgCountryName
 ,emp.EmployerPostalCode
 ,emp.EmployerOrgRegionName
 ,emp.EmploymentEffectiveTime
 ,emp.EmploymentExpiryTime
 ,emp.EmploymentIsOnPublicRegistry
 ,rpl.PracticeRegistrationYear
 ,rpl.PlannedRetirementDate
 ,rpl.OtherJurisdiction
 ,rpl.OtherJurisdictionHours
 ,rpl.EmploymentStatusName
 ,rpl.EmploymentStatusCode
 ,emp.AgeRangeLabel
 ,emp.AgeRangeTypeLabel
 ,emp.AgeRangeTypeCode
	--- standard export columns  -------------------
 ,lReg.PracticeRegisterLabel
 ,lReg.PracticeRegisterSectionLabel
 ,lReg.EmailAddress
 ,lReg.FirstName
 ,lReg.CommonName
 ,lReg.MiddleNames
 ,lReg.LastName
 ,lReg.PersonLegacyKey
 ,emp.OrgLegacyKey
	----- System ID's ------------------------------
 ,lreg.RegistrationSID
 ,lreg.PersonSID
 ,lreg.RegistrantSID
 ,pmac.PersonMailingAddressSID
 ,emp.RegistrantEmploymentSID
 ,rcq.RegistrantCredentialSID											 QualifyingRegistrantCredentialSID
 ,rpl.RegistrantPracticeSID
from
	dbo.vRegistrant#LatestRegistration													lreg
left outer join
	dbo.vRegistrantEmployment#LatestPrimary											emp on lreg.RegistrantSID = emp.RegistrantSID
left outer join
	dbo.vPersonMailingAddress#Current pmac on lreg.PersonSID = pmac.PersonSID
left outer join
	dbo.vRegistrantCredential#Qualifying			 rcq on lreg.RegistrantSID						= rcq.RegistrantSID and rcq.QualifyingCredentialRank = 1
left outer join
	dbo.vRegistrantPractice#Latest						 rpl on lreg.RegistrantSID						= rpl.RegistrantSID
left outer join
	dbo.vRegistrantLanguage#List							 rll on lreg.RegistrantSID						= rll.RegistrantSID
left outer join
	dbo.vRegistrantSpecialization#List				 rsl on lreg.RegistrantSID						= rsl.RegistrantSID
left outer join
	dbo.vRegistrantPracticeRestriction#List		 rprl on lreg.RegistrantSID						= rprl.RegistrantSID
left outer join
	dbo.vRegistrantEmploymentPracticeArea#List repal on emp.RegistrantEmploymentSID = repal.RegistrantEmploymentSID;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns a comprehensive record for each member including the latest contact information, address, registration, qualifying credential, specialization and restrictions. Both current and inactive members are included.|EXPORT+ ^PersonList ^RegistrationList', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrant#LatestProfile', NULL, NULL
GO
