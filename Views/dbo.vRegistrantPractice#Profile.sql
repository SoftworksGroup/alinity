SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantPractice#Profile
/*********************************************************************************************************************************
View		: Registrant Practice - Profile
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns the registrant practice records for all registrants
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This view provides alternate calling syntax for the table function fRegistrantPractice#Profile. The view format produces faster
results that the table function in some query configurations where all practice records are required for a large portion of
registrants.

Note that it is possible for some Registrants - particularly where obtained through historical conversions - to not have
registrant-practice records defined.  Use OUTER join when linking to this dataset from Person and Registrant where parent records
should not be eliminated.

Example
-------
<TestHarness>
	<Test Name = "Random" Description="Returns practice information for 1 registrant selected at random.">
	<SQLScript>
	<![CDATA[

declare @registrantSID int;

select top (1)
	@registrantSID = regP.RegistrantSID
from
	dbo.RegistrantPractice regP
order by
	newid();

if @@rowcount = 0 or @registrantSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select x.* from dbo.vRegistrantPractice#Profile x where x.RegistrantSID = @registrantSID order by x.PracticeRegistrationYear
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
	dbo.RegistrantPractice regP
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select x.* from dbo.vRegistrantPractice#Profile x where x.PracticeRegistrationYear = @registrationYear
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
	 @ObjectName = 'dbo.vRegistrantPractice#Profile'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	--!<ColumnList DataSource="dbo.fRegistrantPractice#Profile" Alias="rpp">
	 rpp.RegistrantNo
	,rpp.RegistrantLabel
	,rpp.RegistrationLabel
	,rpp.LatestRegistrationYear
	,rpp.RegistrantIsCurrentlyActive
	,rpp.PracticeRegistrationYear
	,rpp.PlannedRetirementDate
	,rpp.OtherJurisdiction
	,rpp.OtherJurisdictionHours
	,rpp.EmploymentStatusName
	,rpp.EmploymentStatusCode
	,rpp.PracticeRegisterLabel
	,rpp.PracticeRegisterSectionLabel
	,rpp.EmailAddress
	,rpp.FirstName
	,rpp.CommonName
	,rpp.MiddleNames
	,rpp.LastName
	,rpp.PersonLegacyKey
	,rpp.RegistrantPracticeSID
	,rpp.RegistrantSID
	,rpp.EmploymentStatusSID
--!</ColumnList>
from
	dbo.fRegistrantPractice#Profile(-1, -1) rpp
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns one record per year per registrant summarizing practice information with extended coding (e.g. CIHI)|EXPORT+', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPractice#Profile', NULL, NULL
GO
