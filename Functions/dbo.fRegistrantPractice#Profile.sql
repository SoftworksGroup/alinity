SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantPractice#Profile (@RegistrantSID int, @RegistrationYear smallint)
returns table
as
/*********************************************************************************************************************************
TableFcn	: Registrant Practice - Profile
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns registrant practice information with supporting code/classification values
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund  | Aug 2018		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This table function can be selected for a single registrant key or for all registrants. The results can be filtered to the 
practice record for a specific registration year.  To leave a criteria unfiltered, pass -1 in the corresponding parameter.

The function returns one record for each registrant-practice record meeting the criteria.  The table includes values from
related classification tables for reporting.

Note that it is possible for some Registrants - particularly where obtained through historical conversions - to not have 
registrant-practice records defined.  Use OUTER APPLY when linking to this dataset from Person and Registrant where
parent records should not be eliminated. 

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
	select x.* from dbo.fRegistrantPractice#Profile(@registrantSID, -1) x order by x.PracticeRegistrationYear;
end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
	<Test Name = "AllforYear" Description="Returns practice information for a year selected at random.">
	<SQLScript>
	<![CDATA[

declare @registrationYear smallint;

select top (1)
	@registrationYear = regP.RegistrationYear
from
	dbo.RegistrantPractice regP
order by
	newid();

select x.* from dbo.fRegistrantPractice#Profile(-1, @registrationYear) x;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:30" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrantPractice#Profile'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
return
(
	select
		lreg.RegistrantNo
	 ,lreg.RegistrantLabel
	 ,lreg.RegistrationLabel
	 ,lreg.LatestRegistrationYear
	 ,lreg.RegistrantIsCurrentlyActive
	 ,regP.RegistrationYear PracticeRegistrationYear
	 ,regP.PlannedRetirementDate
	 ,regP.OtherJurisdiction
	 ,regP.OtherJurisdictionHours
	 ,es.EmploymentStatusName
	 ,es.EmploymentStatusCode
		--- standard export columns  -------------------
	 ,lReg.PracticeRegisterLabel
	 ,lReg.PracticeRegisterSectionLabel
	 ,lReg.EmailAddress
	 ,lReg.FirstName
	 ,lReg.CommonName
	 ,lReg.MiddleNames
	 ,lReg.LastName
	 ,lReg.PersonLegacyKey
		-- system ID's ---------------------------------
	 ,regP.RegistrantPracticeSID
	 ,regP.RegistrantSID
	 ,regP.EmploymentStatusSID
	from
	(
		select
			regP.RegistrantPracticeSID
		from
			dbo.RegistrantPractice regP
		where
			(regP.RegistrantSID = @RegistrantSID or @RegistrantSID = -1) and (regP.RegistrationYear = @RegistrationYear or @RegistrationYear = -1)
	)																		 x
	join
		dbo.RegistrantPractice						 regP on x.RegistrantPracticeSID = regP.RegistrantPracticeSID
	join
		dbo.vRegistrant#LatestRegistration lreg on regP.RegistrantSID			 = lreg.RegistrantSID
	join
		dbo.EmploymentStatus							 es on regP.EmploymentStatusSID	 = es.EmploymentStatusSID
);
GO
