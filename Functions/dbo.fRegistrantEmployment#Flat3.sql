SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantEmployment#Flat3 (@RegistrantSID int, @RegistrationYear smallint, @AsOfTime datetime)
returns table
as
/*********************************************************************************************************************************
TableFcn	: Registrant Employment - Top 3
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the top 3 ranked employment records into a single row, with each employer distinguished by a Rank#
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Jul 2018		|	Initial version
					: Tim Edlund	| Dec 2018		| Updated to include AgeRange details associated with the employment record

Comments
--------
This function supports returning the top 3 ranked employers for a given registration year as a single row. If a RegistrantSID
is not provided, or is passed as -1, then the results are returned for AlL Registrants.  The top 3 ranked employers by hours
are a common source for exports. This function avoids running multiple select statements to  return the three employers. The
function also joins to several tables related to the employment use commonly in reporting - e.g. dbo.PracticeArea.  This
table is used in the CIHI snapshot process.

Note that the "@AsOfTime" parameter is used to exclude terminated employment records but also has other implications for
selection criteria.  If the value is passed as NULL, then no check for terminated records is performed.  The current time
(in the user timezone) must be passed when using this function in generation of snapshots for CIHI.  See the table function
dbo.fRegistrantEmployment#Top for details on how this parameter is applied in NULL and NOT NULL contexts.

Example
-------

<TestHarness>
	<Test Name = "Random1000" IsDefault= "true" Description="Returns top 3 employers for 1000 random registrants in 
	previous year (no AsOfDate).">
	<SQLScript>
	<![CDATA[

declare @registrationYear smallint = dbo.fRegistrationYear#Current() - 1;

select
	x.RegistrantSID
 ,r.RegistrantLabel
 ,f3.Rank1RegistrantEmploymentSID
 ,f3.Rank1OrgName
 ,f3.Rank1RegistrationYear
 ,f3.Rank1EffectiveTime
 ,f3.Rank1ExpiryTime
 ,f3.Rank2RegistrantEmploymentSID
 ,f3.Rank2OrgName
 ,f3.Rank2RegistrationYear
 ,f3.Rank2EffectiveTime
 ,f3.Rank2ExpiryTime
 ,f3.Rank3RegistrantEmploymentSID
 ,f3.Rank3OrgName
 ,f3.Rank3RegistrationYear
 ,f3.Rank3EffectiveTime
 ,f3.Rank3ExpiryTime
from
(select top (1000) x.RegistrantSID from dbo .Registrant x order by newid())						x
join
	dbo.vRegistrant																																			r on x.RegistrantSID = r.RegistrantSID
outer apply dbo.fRegistrantEmployment#Flat3(x.RegistrantSID, @registrationYear, null) f3
where
  f3.RegistrantSID is not null -- uncomment to only include records with employment
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:15" />
	</Assertions>
	</Test>
	<Test Name = "CIHI1000" IsDefault= "false" Description="Returns top 3 employers for 1000 random registrants in 
	previous year with current AsOfDate.">
	<SQLScript>
	<![CDATA[

declare
	@registrationYear smallint = dbo.fRegistrationYear#Current()
 ,@asOfTime					datetime = sf.fNow();

select
	x.RegistrantSID
 ,r.RegistrantLabel
 ,f3.Rank1RegistrantEmploymentSID
 ,f3.Rank1OrgName
 ,f3.Rank1RegistrationYear
 ,f3.Rank1EffectiveTime
 ,f3.Rank1ExpiryTime
 ,f3.Rank2RegistrantEmploymentSID
 ,f3.Rank2OrgName
 ,f3.Rank2RegistrationYear
 ,f3.Rank2EffectiveTime
 ,f3.Rank2ExpiryTime
 ,f3.Rank3RegistrantEmploymentSID
 ,f3.Rank3OrgName
 ,f3.Rank3RegistrationYear
 ,f3.Rank3EffectiveTime
 ,f3.Rank3ExpiryTime
from
(select top (1000) x .RegistrantSID from dbo .Registrant x order by newid())								 x
join
	dbo.vRegistrant																																					 r on x.RegistrantSID = r.RegistrantSID
outer apply dbo.fRegistrantEmployment#Flat3(x.RegistrantSID, @registrationYear, @asOfTime) f3
where
	f3.RegistrantSID is not null -- uncomment to only include records with employment
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:15" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrantEmployment#Flat3'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
return
(
	select
		re.RegistrantSID
	 ,max(r.PersonSID)																													 PersonSID
		-- primary employer
	 ,max(case when re.EmploymentRankNo = 1 then re.RegistrantEmploymentSID end) Rank1RegistrantEmploymentSID
	 ,max(case when re.EmploymentRankNo = 1 then re.RegistrationYear end)				 Rank1RegistrationYear
	 ,max(case when re.EmploymentRankNo = 1 then re.OrgSID end)									 Rank1OrgSID
	 ,max(case when re.EmploymentRankNo = 1 then og.OrgName end)								 Rank1OrgName
	 ,max(case when re.EmploymentRankNo = 1 then ot.OrgTypeCode end)						 Rank1OrgTypeCode
	 ,max(case when re.EmploymentRankNo = 1 then og.PostalCode end)							 Rank1OrgPostalCode
	 ,max(case when re.EmploymentRankNo = 1 then sp.ISONumber end)							 Rank1OrgStateProvinceISONumber
	 ,max(case when re.EmploymentRankNo = 1 then c.ISONumber end)								 Rank1OrgCountryISONumber
	 ,max(case when re.EmploymentRankNo = 1 then re.EmploymentTypeSID end)			 Rank1EmploymentTypeSID
	 ,max(case when re.EmploymentRankNo = 1 then et.EmploymentTypeName end)			 Rank1EmploymentTypeName
	 ,max(case when re.EmploymentRankNo = 1 then et.EmploymentTypeCode end)			 Rank1EmploymentTypeCode
	 ,max(case when re.EmploymentRankNo = 1 then re.EmploymentRoleSID end)			 Rank1EmploymentRoleSID
	 ,max(case when re.EmploymentRankNo = 1 then er.EmploymentRoleName end)			 Rank1EmploymentRoleName
	 ,max(case when re.EmploymentRankNo = 1 then er.EmploymentRoleCode end)			 Rank1EmploymentRoleCode
	 ,max(case when re.EmploymentRankNo = 1 then re.PracticeHours end)					 Rank1PracticeHours
	 ,max(case when re.EmploymentRankNo = 1 then re.PrimaryPracticeAreaSID end)	 Rank1PracticeAreaSID
	 ,max(case when re.EmploymentRankNo = 1 then pa.PracticeAreaName end)				 Rank1PracticeAreaName
	 ,max(case when re.EmploymentRankNo = 1 then pa.PracticeAreaCode end)				 Rank1PracticeAreaCode
	 ,max(case when re.EmploymentRankNo = 1 then re.PracticeScopeSID end)				 Rank1PracticeScopeSID
	 ,max(case when re.EmploymentRankNo = 1 then ps.PracticeScopeName end)			 Rank1PracticeScopeName
	 ,max(case when re.EmploymentRankNo = 1 then ps.PracticeScopeCode end)			 Rank1PracticeScopeCode
	 ,max(case when re.EmploymentRankNo = 1 then re.AgeRangeSID end)						 Rank1AgeRangeSID
	 ,max(case when re.EmploymentRankNo = 1 then ar.AgeRangeLabel end)					 Rank1AgeRangeLabel
	 ,max(case when re.EmploymentRankNo = 1 then art.AgeRangeTypeCode end)			 Rank1AgeRangeCode
	 ,max(case when re.EmploymentRankNo = 1 then re.Phone end)									 Rank1Phone
	 ,max(case when re.EmploymentRankNo = 1 then re.EffectiveTime end)					 Rank1EffectiveTime
	 ,max(case when re.EmploymentRankNo = 1 then re.ExpiryTime end)							 Rank1ExpiryTime
	 ,max(case when re.EmploymentRankNo = 1 then re.RegistrantEmploymentXID end) Rank1RegistrantEmploymentXID
	 ,max(case when re.EmploymentRankNo = 1 then re.LegacyKey end)							 Rank1LegacyKey
		-- secondary employer
	 ,max(case when re.EmploymentRankNo = 2 then re.RegistrantEmploymentSID end) Rank2RegistrantEmploymentSID
	 ,max(case when re.EmploymentRankNo = 2 then re.RegistrationYear end)				 Rank2RegistrationYear
	 ,max(case when re.EmploymentRankNo = 2 then re.OrgSID end)									 Rank2OrgSID
	 ,max(case when re.EmploymentRankNo = 2 then og.OrgName end)								 Rank2OrgName
	 ,max(case when re.EmploymentRankNo = 2 then ot.OrgTypeCode end)						 Rank2OrgTypeCode
	 ,max(case when re.EmploymentRankNo = 2 then og.PostalCode end)							 Rank2OrgPostalCode
	 ,max(case when re.EmploymentRankNo = 2 then sp.ISONumber end)							 Rank2OrgStateProvinceISONumber
	 ,max(case when re.EmploymentRankNo = 2 then c.ISONumber end)								 Rank2OrgCountryISONumber
	 ,max(case when re.EmploymentRankNo = 2 then re.EmploymentTypeSID end)			 Rank2EmploymentTypeSID
	 ,max(case when re.EmploymentRankNo = 2 then et.EmploymentTypeName end)			 Rank2EmploymentTypeName
	 ,max(case when re.EmploymentRankNo = 2 then et.EmploymentTypeCode end)			 Rank2EmploymentTypeCode
	 ,max(case when re.EmploymentRankNo = 2 then re.EmploymentRoleSID end)			 Rank2EmploymentRoleSID
	 ,max(case when re.EmploymentRankNo = 2 then er.EmploymentRoleName end)			 Rank2EmploymentRoleName
	 ,max(case when re.EmploymentRankNo = 2 then er.EmploymentRoleCode end)			 Rank2EmploymentRoleCode
	 ,max(case when re.EmploymentRankNo = 2 then re.PracticeHours end)					 Rank2PracticeHours
	 ,max(case when re.EmploymentRankNo = 2 then re.PrimaryPracticeAreaSID end)	 Rank2PracticeAreaSID
	 ,max(case when re.EmploymentRankNo = 2 then pa.PracticeAreaName end)				 Rank2PracticeAreaName
	 ,max(case when re.EmploymentRankNo = 2 then pa.PracticeAreaCode end)				 Rank2PracticeAreaCode
	 ,max(case when re.EmploymentRankNo = 2 then re.PracticeScopeSID end)				 Rank2PracticeScopeSID
	 ,max(case when re.EmploymentRankNo = 2 then ps.PracticeScopeName end)			 Rank2PracticeScopeName
	 ,max(case when re.EmploymentRankNo = 2 then ps.PracticeScopeCode end)			 Rank2PracticeScopeCode
	 ,max(case when re.EmploymentRankNo = 2 then re.AgeRangeSID end)						 Rank2AgeRangeSID
	 ,max(case when re.EmploymentRankNo = 2 then ar.AgeRangeLabel end)					 Rank2AgeRangeLabel
	 ,max(case when re.EmploymentRankNo = 2 then art.AgeRangeTypeCode end)			 Rank2AgeRangeCode
	 ,max(case when re.EmploymentRankNo = 2 then re.Phone end)									 Rank2Phone
	 ,max(case when re.EmploymentRankNo = 2 then re.EffectiveTime end)					 Rank2EffectiveTime
	 ,max(case when re.EmploymentRankNo = 2 then re.ExpiryTime end)							 Rank2ExpiryTime
	 ,max(case when re.EmploymentRankNo = 2 then re.RegistrantEmploymentXID end) Rank2RegistrantEmploymentXID
	 ,max(case when re.EmploymentRankNo = 2 then re.LegacyKey end)							 Rank2LegacyKey
		-- tertiary employer
	 ,max(case when re.EmploymentRankNo = 3 then re.RegistrantEmploymentSID end) Rank3RegistrantEmploymentSID
	 ,max(case when re.EmploymentRankNo = 3 then re.RegistrationYear end)				 Rank3RegistrationYear
	 ,max(case when re.EmploymentRankNo = 3 then re.OrgSID end)									 Rank3OrgSID
	 ,max(case when re.EmploymentRankNo = 3 then og.OrgName end)								 Rank3OrgName
	 ,max(case when re.EmploymentRankNo = 3 then ot.OrgTypeCode end)						 Rank3OrgTypeCode
	 ,max(case when re.EmploymentRankNo = 3 then og.PostalCode end)							 Rank3OrgPostalCode
	 ,max(case when re.EmploymentRankNo = 3 then sp.ISONumber end)							 Rank3OrgStateProvinceISONumber
	 ,max(case when re.EmploymentRankNo = 3 then c.ISONumber end)								 Rank3OrgCountryISONumber
	 ,max(case when re.EmploymentRankNo = 3 then re.EmploymentTypeSID end)			 Rank3EmploymentTypeSID
	 ,max(case when re.EmploymentRankNo = 3 then et.EmploymentTypeName end)			 Rank3EmploymentTypeName
	 ,max(case when re.EmploymentRankNo = 3 then et.EmploymentTypeCode end)			 Rank3EmploymentTypeCode
	 ,max(case when re.EmploymentRankNo = 3 then re.EmploymentRoleSID end)			 Rank3EmploymentRoleSID
	 ,max(case when re.EmploymentRankNo = 3 then er.EmploymentRoleName end)			 Rank3EmploymentRoleName
	 ,max(case when re.EmploymentRankNo = 3 then er.EmploymentRoleCode end)			 Rank3EmploymentRoleCode
	 ,max(case when re.EmploymentRankNo = 3 then re.PracticeHours end)					 Rank3PracticeHours
	 ,max(case when re.EmploymentRankNo = 3 then re.PrimaryPracticeAreaSID end)	 Rank3PracticeAreaSID
	 ,max(case when re.EmploymentRankNo = 3 then pa.PracticeAreaName end)				 Rank3PracticeAreaName
	 ,max(case when re.EmploymentRankNo = 3 then pa.PracticeAreaCode end)				 Rank3PracticeAreaCode
	 ,max(case when re.EmploymentRankNo = 3 then re.PracticeScopeSID end)				 Rank3PracticeScopeSID
	 ,max(case when re.EmploymentRankNo = 3 then ps.PracticeScopeName end)			 Rank3PracticeScopeName
	 ,max(case when re.EmploymentRankNo = 3 then ps.PracticeScopeCode end)			 Rank3PracticeScopeCode
	 ,max(case when re.EmploymentRankNo = 3 then re.AgeRangeSID end)						 Rank3AgeRangeSID
	 ,max(case when re.EmploymentRankNo = 3 then ar.AgeRangeLabel end)					 Rank3AgeRangeLabel
	 ,max(case when re.EmploymentRankNo = 3 then art.AgeRangeTypeCode end)			 Rank3AgeRangeCode
	 ,max(case when re.EmploymentRankNo = 3 then re.Phone end)									 Rank3Phone
	 ,max(case when re.EmploymentRankNo = 3 then re.EffectiveTime end)					 Rank3EffectiveTime
	 ,max(case when re.EmploymentRankNo = 3 then re.ExpiryTime end)							 Rank3ExpiryTime
	 ,max(case when re.EmploymentRankNo = 3 then re.RegistrantEmploymentXID end) Rank3RegistrantEmploymentXID
	 ,max(case when re.EmploymentRankNo = 3 then re.LegacyKey end)							 Rank3LegacyKey
	from
		dbo.Registrant																																						r
	cross apply dbo.fRegistrantEmployment#Top(r.RegistrantSID, @RegistrationYear, 3, @AsOfTime) re
	join
		dbo.Org						 og on re.OrgSID								 = og.OrgSID
	join
		dbo.OrgType				 ot on og.OrgTypeSID						 = ot.OrgTypeSID
	join
		dbo.City					 cty on og.CitySID							 = cty.CitySID
	join
		dbo.StateProvince	 sp on cty.StateProvinceSID			 = sp.StateProvinceSID
	join
		dbo.Country				 c on sp.CountrySID							 = c.CountrySID
	join
		dbo.EmploymentType et on re.EmploymentTypeSID			 = et.EmploymentTypeSID
	join
		dbo.EmploymentRole er on re.EmploymentRoleSID			 = er.EmploymentRoleSID
	join
		dbo.PracticeArea	 pa on re.PrimaryPracticeAreaSID = pa.PracticeAreaSID
	join
		dbo.PracticeScope	 ps on re.PracticeScopeSID			 = ps.PracticeScopeSID
	join
		dbo.AgeRange			 ar on re.AgeRangeSID						 = ar.AgeRangeSID
	join
		dbo.AgeRangeType	 art on ar.AgeRangeTypeSID			 = art.AgeRangeTypeSID
	where
		r.RegistrantSID = @RegistrantSID or @RegistrantSID is null
	group by
		re.RegistrantSID
);
GO
