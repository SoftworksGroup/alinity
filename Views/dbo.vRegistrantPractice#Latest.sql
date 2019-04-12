SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantPractice#Latest
/*********************************************************************************************************************************
View		: Registrant Practice - Latest
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns the latest practice records for all registrants
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This view provides alternate calling syntax for the table function fRegistrantPractice#Profile that returns registrant-practice
information and restricts results to the latest registration year only. The view - vRegistrantPractice#Profile - returns all
records.

The view format produces faster results that the table function in some query configurations where all practice records are
required for a large portion of registrants.

Note that it is possible for some Registrants - particularly where obtained through historical conversions - to not have
registrant-practice records defined.  Use OUTER join when linking to this dataset from Person and Registrant where parent records
should not be eliminated.

Example
-------
<TestHarness>
	<Test Name = "Random" Description="Returns latest practice information for 1 registrant selected at random.">
	<SQLScript>
	<![CDATA[

declare @registrantSID int;

select top (1)
	@registrantSID = regP.RegistrantSID
from
	dbo.vRegistrant#LatestRegistration lreg
join
	dbo.RegistrantPractice regP on lreg.RegistrantSID = regp.RegistrantSID and lreg.LatestRegistrationYear = regp.RegistrationYear
order by
	newid();

if @@rowcount = 0 or @registrantSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select x.* from dbo.vRegistrantPractice#Latest x where x.RegistrantSID = @registrantSID
end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
	<Test Name = "AllForYear" Description="Returns practice information for all registrants for a year selected at random.">
	<SQLScript>
	<![CDATA[
declare @registrationYear smallint;

select top (1)
	@registrationYear = regP.RegistrationYear
from
	dbo.vRegistrant#LatestRegistration lreg
join
	dbo.RegistrantPractice regP on lreg.RegistrantSID = regp.RegistrantSID and lreg.LatestRegistrationYear = regp.RegistrationYear
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select x.* from dbo.vRegistrantPractice#Latest x where x.PracticeRegistrationYear = @registrationYear
end
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:30" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vRegistrantPractice#Latest'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	--!<ColumnList DataSource="dbo.fRegistrantPractice#Profile" Alias="rpl">
	 rpl.RegistrantNo
	,rpl.RegistrantLabel
	,rpl.RegistrationLabel
	,rpl.LatestRegistrationYear
	,rpl.RegistrantIsCurrentlyActive
	,rpl.PracticeRegistrationYear
	,rpl.PlannedRetirementDate
	,rpl.OtherJurisdiction
	,rpl.OtherJurisdictionHours
	,rpl.EmploymentStatusName
	,rpl.EmploymentStatusCode
	,rpl.PracticeRegisterLabel
	,rpl.PracticeRegisterSectionLabel
	,rpl.EmailAddress
	,rpl.FirstName
	,rpl.CommonName
	,rpl.MiddleNames
	,rpl.LastName
	,rpl.PersonLegacyKey
	,rpl.RegistrantPracticeSID
	,rpl.RegistrantSID
	,rpl.EmploymentStatusSID
--!</ColumnList>
from
	dbo.fRegistrantPractice#Profile(-1, -1) rpl
where
	rpl.LatestRegistrationYear = rpl.PracticeRegistrationYear
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns one record per registrant summarizing practice information for their latest year of registration with extended coding (e.g. CIHI)|EXPORT+', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPractice#Latest', NULL, NULL
GO
