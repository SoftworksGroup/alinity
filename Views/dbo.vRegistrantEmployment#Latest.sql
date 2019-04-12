SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantEmployment#Latest
/*********************************************************************************************************************************
View		: Registrant Employment - Latest Primary
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns the latest non-expired, unique-by-employer, employment records for all registrants
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version
Comments	
--------
This view provides alternate calling syntax for the table function of the same name that returns non-expired, unique employment
records for registrants. The view format produces faster results in some query configurations where all employment records are
required for a large portion of registrants.

If the same employer (dbo.Org) is reported for multiple registration years, the record from the latest registration year is
used.

Note that it is possible, particularly for in-active members, that all employment records are expired for them.  The view does
not return expired records and therefore use an OUTER JOIN when linking from Person and Registrant where parent records should not
be eliminated.

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
where
	re.ExpiryTime is null
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
		dbo.vRegistrantEmployment#Latest x
	where
		x.RegistrantSID = @registrantSID

end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
	<Test Name = "AllActive" Description="Returns primary employment records for all active registrants.">
	<SQLScript>
	<![CDATA[
select
	x.*
from
	dbo.vRegistrantEmployment#Latest x
where
	x.RegistrantIsCurrentlyActive = 1
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:30" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vRegistrantEmployment#Latest'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	--!<ColumnList DataSource="dbo.fRegistrantEmployment#Latest" Alias="emp">
	emp.RegistrantNo
 ,emp.RegistrantLabel
 ,emp.RegistrationLabel
 ,emp.LatestRegistrationYear
 ,emp.RegistrantIsCurrentlyActive
 ,emp.EmploymentReportedYear
 ,emp.ParentOrgSID
 ,emp.ParentOrgName
 ,emp.OrgName
 ,emp.OrgTypeName
 ,emp.OrgTypeCode
 ,emp.OrgTypeCategory
 ,emp.EmploymentManualRank
 ,emp.EmployerPracticeHours
 ,emp.TotalPracticeHours
 ,emp.EmploymentTypeName
 ,emp.EmploymentTypeCode
 ,emp.EmploymentTypeCategory
 ,emp.EmploymentRoleName
 ,emp.EmploymentRoleCode
 ,emp.PracticeScopeName
 ,emp.PracticeScopeCode
 ,emp.PracticeAreaName
 ,emp.PracticeAreaCode
 ,emp.PracticeAreaCategory
 ,emp.AgeRangeLabel
 ,emp.StartAge
 ,emp.EndAge
 ,emp.AgeRangeTypeLabel
 ,emp.AgeRangeTypeCode
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
 ,emp.IsEmploymentActive
 ,emp.EmploymentIsOnPublicRegistry
 ,emp.EmploymentCreateTime
 ,emp.PracticeRegisterLabel
 ,emp.PracticeRegisterSectionLabel
 ,emp.LatestRegistrationEffectiveTime
 ,emp.EmailAddress
 ,emp.FirstName
 ,emp.CommonName
 ,emp.MiddleNames
 ,emp.LastName
 ,emp.PersonLegacyKey
 ,emp.OrgLegacyKey
 ,emp.RegistrantEmploymentSID
 ,emp.RegistrationSID
 ,emp.PersonSID
 ,emp.RegistrantSID
 ,emp.OrgSID
 ,emp.OrgTypeSID
 ,emp.EmploymentTypeSID
 ,emp.EmploymentRoleSID
 ,emp.PrimaryPracticeAreaSID
 ,emp.AgeRangeSID
 ,emp.AgeRangeTypeSID
 ,emp.LatestYearEmployerReported
 ,emp.AllEmploymentRankNo
 ,emp.YearEmploymentRankNo
--!</ColumnList>
from
	dbo.fRegistrantEmployment#Latest(-1, -1, 1) emp; -- see also table function for logic details
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns one record for each non-expired, unique employer for members. If the same employer is reported for multiple registration years, the record from the latest registration year is returned. Any employer of a "PLACEHOLDER" type (often used in conversion) is excluded.|EXPORT+ ^PersonList ^OrgList ^RegistrationList', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Latest', NULL, NULL
GO
