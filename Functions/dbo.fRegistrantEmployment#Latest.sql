SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantEmployment#Latest (@RegistrantSID int, @RegistrationYear smallint, @TopLimit int)
returns table
as
/*********************************************************************************************************************************
TableFcn	: Registrant Employment - Latest
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the latest the employment record within the registration year based on highest practice hours + manual rank
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This table function can be selected for a single registrant key or for all registrants. The results can be filtered to employment
for a specific registration year.  If only the top 1 or top 3 employers are required, set the @TopLimit parameter. To leave a
criteria unfiltered, pass -1 in the corresponding parameter.

The function returns one record for each non-expired, unique employer for each registrant.  If the same employer (dbo.Org) is
reported  for multiple registration years, the record from the latest registration year is used.  The function avoids returning any
organization of a 'S!PLACEHOLDER' type (often used in conversion).

Two ranking columns are returned to order employers for assignment in reports. The first ranks all non-expired employment
records returned.  The second ranks employment records reported in the same registration year. Both ranking column use
the same general method.  The primary (1st rank) employer is considered to be the one with the most hours reported in any
given year. For the "all" value, years are ranked in descending order so that the latest year of employment is always
assigned a higher priority.  There is a also "rank" value the member can enter to break ties if the same hours, or 0 hours,
are reported. This only applies if hours are the same between employment records.

The view includes registrant information in the leading columns for context including a "Registrant Is Currently Active"
bit to enable selection of active members only.

Note that it is possible, particularly for in-active members, that all employment records are expired for them.  The function does
not return expired records and therefore use OUTER APPLY when linking to this dataset from Person and Registrant where
parent records should not be eliminated.

Example
-------
<TestHarness>
	<Test Name = "Random" Description="Returns top 2 (max) employment records for 1 registrant selected at random.">
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
	select x.* from dbo.fRegistrantEmployment#Latest(@registrantSID, -1, 2) x;
end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
	<Test Name = "All" Description="Returns primary employment record for all registrants.">
	<SQLScript>
	<![CDATA[
select x.* from dbo.fRegistrantEmployment#Latest(-1, -1, 1) x;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:30" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrantEmployment#Latest'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
return
(
	select
		x.*
	from
	(
		select
			--!<ColumnList DataSource="dbo.vRegistrantEmployment#Profile" Alias="re">
			 re.RegistrantNo
			,re.RegistrantLabel
			,re.RegistrationLabel
			,re.LatestRegistrationYear
			,re.RegistrantIsCurrentlyActive
			,re.EmploymentReportedYear
			,re.OrgName
			,re.ParentOrgName
			,re.OrgTypeName
			,re.OrgTypeCode
			,re.OrgTypeCategory
			,re.EmploymentManualRank
			,re.EmployerPracticeHours
			,re.TotalPracticeHours
			,re.EmploymentTypeName
			,re.EmploymentTypeCode
			,re.EmploymentTypeCategory
			,re.EmploymentRoleName
			,re.EmploymentRoleCode
			,re.PracticeScopeName
			,re.PracticeScopeCode
			,re.PracticeAreaName
			,re.PracticeAreaCode
			,re.PracticeAreaCategory
			,re.AgeRangeLabel
			,re.StartAge
			,re.EndAge
			,re.AgeRangeTypeLabel
			,re.AgeRangeTypeCode
			,re.EmploymentDirectPhone
			,re.EmployerMainPhone
			,re.EmployerFaxPhone
			,re.EmployerStreetAddress1
			,re.EmployerStreetAddress2
			,re.EmployerStreetAddress3
			,re.EmployerOrgCityName
			,re.EmployerOrgStateProvinceCode
			,re.EmployerOrgCountryName
			,re.EmployerPostalCode
			,re.EmployerOrgRegionName
			,re.EmploymentEffectiveTime
			,re.EmploymentExpiryTime
			,re.IsEmploymentActive
			,re.EmploymentIsOnPublicRegistry
			,re.EmploymentCreateTime
			,re.PracticeRegisterLabel
			,re.PracticeRegisterSectionLabel
			,re.LatestRegistrationEffectiveTime
			,re.EmailAddress
			,re.FirstName
			,re.CommonName
			,re.MiddleNames
			,re.LastName
			,re.PersonLegacyKey
			,re.OrgLegacyKey
			,re.RegistrantEmploymentSID
			,re.RegistrationSID
			,re.PersonSID
			,re.RegistrantSID
			,re.OrgSID
			,re.ParentOrgSID
			,re.OrgTypeSID
			,re.EmploymentTypeSID
			,re.EmploymentRoleSID
			,re.PrimaryPracticeAreaSID
			,re.AgeRangeSID
			,re.AgeRangeTypeSID
			--!</ColumnList>
		 ,re.EmploymentReportedYear LatestYearEmployerReported
		 ,row_number() over (partition by
													 re.RegistrantSID
												 order by
													 re.EmploymentReportedYear desc
													,re.EmployerPracticeHours desc
													,re.EmploymentManualRank asc	-- "rank" is only applicable where no hours are recorded
													,re.EmploymentCreateTime desc
												)				AllEmploymentRankNo
		 ,row_number() over (partition by
													 re.RegistrantSID
													,re.EmploymentReportedYear
												 order by
													 re.EmployerPracticeHours desc
													,re.EmploymentManualRank asc
													,re.EmploymentCreateTime desc
												)				YearEmploymentRankNo
		from
		(
			select
				re.RegistrantSID
			 ,re.OrgSID
			 ,max(re.RegistrationYear) RegistrationYear -- isolate the latest employment record for each organization
			from
				dbo.RegistrantEmployment re
			where
				(re.RegistrantSID				 = @RegistrantSID or @RegistrantSID = -1) -- -1 is passed to return employment for all registrants
				and (re.RegistrationYear = @RegistrationYear or @RegistrationYear = -1) -- to limit to a specific year or -1 for all years
				and re.ExpiryTime is null -- avoid expired records (no check for future dated expiries to improve performance)
			group by
				re.RegistrantSID
			 ,re.OrgSID
		)																		lre
		join
			dbo.vRegistrantEmployment#Profile re on lre.RegistrantSID				 = re.RegistrantSID
																							and lre.OrgSID					 = re.OrgSID
																							and lre.RegistrationYear = re.EmploymentReportedYear
	) x
where
	x.AllEmploymentRankNo <= @TopLimit or @TopLimit = -1
);
GO
