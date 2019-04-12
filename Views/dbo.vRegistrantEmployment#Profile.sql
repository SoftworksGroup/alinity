SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE view dbo.vRegistrantEmployment#Profile
/*********************************************************************************************************************************
TableFcn	: Registrant Employment - Profile
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns detailed record of each registrant employment including active, expired and  all years
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version
				: Tim Edlund					| Dec 2018		| Updated to incorporate Age-Range values associated with employment location

Comments	
--------
This view returns comprehensive employment information.  One record is returned for each employer reported for each registration
year. Both active and expired employment records are included. Note that the same employer may be reported for multiple years
and to avoid duplication, the fRegistrantEmployment#Latest/vRegistrantEmployment#Latest objects should be used which return only
the latest employment for each employer.  

The view includes registrant information in the leading columns for context including a "Registrant Is Currently Active"
bit to enable selection of active members only.

Example
-------
<TestHarness>
	<Test Name = "Random" Description="Returns employment information for 1 registrant selected at random.">
	<SQLScript>
	<![CDATA[
declare @registrantSID int;

select top (1)
	@registrantSID = re.RegistrantSID
from
	dbo.RegistrantEmployment re
order by
	newid();

if @@rowcount = 0 or @registrantSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		x.*
	from
		dbo.vRegistrantEmployment#Profile x
	where
		x.RegistrantSID = @registrantSID
	order by
		x.EmploymentReportedYear

end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
	<Test Name = "AllForYear" Description="Returns employment information for a year selected at random.">
	<SQLScript>
	<![CDATA[
declare @registrationYear smallint;

select top (1)
	@registrationYear = re.RegistrationYear
from
	dbo.RegistrantEmployment re
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		x.*
	from
		dbo.vRegistrantEmployment#Profile x
	where
		x.EmploymentReportedYear = @registrationYear
	order by
		x.EmploymentReportedYear

end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:30" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vRegistrantEmployment#Profile'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	lreg.RegistrantNo
 ,lreg.RegistrantLabel
 ,lreg.RegistrationLabel
 ,lreg.LatestRegistrationYear
 ,lreg.RegistrantIsCurrentlyActive
 ,re.RegistrationYear														EmploymentReportedYear
 ,org.OrgName
 ,porg.OrgName																	ParentOrgName
 ,ot.OrgTypeName
 ,ot.OrgTypeCode
 ,ot.OrgTypeCategory
 ,re.Rank																				EmploymentManualRank
 ,re.PracticeHours															EmployerPracticeHours
 ,regP.TotalPracticeHours												TotalPracticeHours
 ,et.EmploymentTypeName
 ,et.EmploymentTypeCode
 ,et.EmploymentTypeCategory
 ,er.EmploymentRoleName
 ,er.EmploymentRoleCode
 ,ps.PracticeScopeName
 ,ps.PracticeScopeCode
 ,pa.PracticeAreaName
 ,pa.PracticeAreaCode
 ,pa.PracticeAreaCategory
 ,ar.AgeRangeLabel
 ,ar.StartAge
 ,ar.EndAge
 ,art.AgeRangeTypeLabel
 ,art.AgeRangeTypeCode
 ,re.Phone																			EmploymentDirectPhone
 ,org.Phone																			EmployerMainPhone
 ,org.Fax																				EmployerFaxPhone
 ,org.StreetAddress1														EmployerStreetAddress1
 ,org.StreetAddress2														EmployerStreetAddress2
 ,org.StreetAddress3														EmployerStreetAddress3
 ,cty.CityName																	EmployerOrgCityName
 ,sp.StateProvinceCode													EmployerOrgStateProvinceCode
 ,ctry.CountryName															EmployerOrgCountryName
 ,org.PostalCode																EmployerPostalCode
 ,rgn.RegionName																EmployerOrgRegionName
 ,re.EffectiveTime															EmploymentEffectiveTime
 ,re.ExpiryTime																	EmploymentExpiryTime
 ,sf.fIsActive(re.EffectiveTime, re.ExpiryTime) IsEmploymentActive
 ,re.IsOnPublicRegistry													EmploymentIsOnPublicRegistry
 ,re.CreateTime																	EmploymentCreateTime
	--- standard export columns  -------------------
 ,lreg.PracticeRegisterLabel
 ,lreg.PracticeRegisterSectionLabel
 ,lreg.LatestRegistrationEffectiveTime
 ,lreg.EmailAddress
 ,lreg.FirstName
 ,lreg.CommonName
 ,lreg.MiddleNames
 ,lreg.LastName
 ,lreg.PersonLegacyKey
 ,org.LegacyKey																	OrgLegacyKey
	-- system ID's ---------------------------------
 ,re.RegistrantEmploymentSID
 ,lreg.RegistrationSID
 ,lreg.PersonSID
 ,re.RegistrantSID
 ,re.OrgSID
 ,org.OrgSID																		ParentOrgSID
 ,org.OrgTypeSID
 ,re.EmploymentTypeSID
 ,re.EmploymentRoleSID
 ,repa.PracticeAreaSID													PrimaryPracticeAreaSID
 ,ar.AgeRangeSID
 ,ar.AgeRangeTypeSID
from
	dbo.RegistrantEmployment						 re
join
	dbo.vRegistrant#LatestRegistration	 lreg on re.RegistrantSID						= lreg.RegistrantSID
join
	dbo.Org															 org on re.OrgSID										= org.OrgSID
join
	dbo.OrgType													 ot on org.OrgTypeSID								= ot.OrgTypeSID
join
	dbo.City														 cty on org.CitySID									= cty.CitySID
join
	dbo.StateProvince										 sp on cty.StateProvinceSID					= sp.StateProvinceSID
join
	dbo.Country													 ctry on sp.CountrySID							= ctry.CountrySID
join
	dbo.Region													 rgn on org.RegionSID								= rgn.RegionSID
join
	dbo.EmploymentType									 et on re.EmploymentTypeSID					= et.EmploymentTypeSID
join
	dbo.EmploymentRole									 er on re.EmploymentRoleSID					= er.EmploymentRoleSID
join
	dbo.PracticeScope										 ps on re.PracticeScopeSID					= ps.PracticeScopeSID
join
	dbo.AgeRange												 ar on re.AgeRangeSID								= ar.AgeRangeSID
join
	dbo.AgeRangeType										 art on ar.AgeRangeTypeSID					= art.AgeRangeTypeSID
left outer join
	dbo.RegistrantPractice							 regP on re.RegistrantSID						= regP.RegistrantSID and re.RegistrationYear = regP.RegistrationYear
left outer join
	dbo.RegistrantEmploymentPracticeArea repa on re.RegistrantEmploymentSID = repa.RegistrantEmploymentSID and repa.IsPrimary = cast(1 as bit)
left outer join
	dbo.PracticeArea										 pa on repa.PracticeAreaSID					= pa.PracticeAreaSID
left outer join
	dbo.Org															 porg on org.ParentOrgSID						= porg.OrgSID;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns comprehensive employment information. One record is included for each employer reported by each registrant in all registration years. |EXPORT+ ^PersonList ^OrgList ^RegistrationList', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Profile', NULL, NULL
GO
