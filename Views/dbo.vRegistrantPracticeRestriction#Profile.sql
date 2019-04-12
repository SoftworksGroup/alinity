SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantPracticeRestriction#Profile
/*********************************************************************************************************************************
View		: Registrant Practice Restriction - Profile
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns conditions-on-practice information for all registrants
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This view returns all practice-condition information for all registrants.  Both active and expired conditions are included.
A bit column - IsConditionActive - can be used to filter to currently active conditions only.  The leading columns of the 
data set provide current registration information so that output can be filted to currently active registrants only.

Most members will not have conditions-on-practice so use OUTER join when linking to this dataset from Person and Registrant 
where parent records should not be eliminated.

Example
-------
<TestHarness>
	<Test Name = "Random" Description="Returns condition-on-practice information for 1 registrant selected at random.">
	<SQLScript>
	<![CDATA[
declare @registrantSID int;

select top (1)
	@registrantSID = rpr.RegistrantSID
from
	dbo.RegistrantPracticeRestriction rpr 
order by
	newid();

if @@rowcount = 0 or @registrantSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select x.* from dbo.vRegistrantPracticeRestriction#Profile x where x.RegistrantSID = @registrantSID order by x.EffectiveTime
end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
	<Test Name = "AllActive" Description="Returns all active conditions-on-practice">
	<SQLScript>
	<![CDATA[
select
	x.*
from
	dbo.vRegistrantPracticeRestriction#Profile x
where
	x.IsConditionActive = 1
order by
	x.registrantno;

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
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
	 @ObjectName = 'dbo.vRegistrantPracticeRestriction#Profile'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	lreg.RegistrantNo
 ,lreg.RegistrantLabel
 ,lreg.RegistrationLabel
 ,lreg.LatestRegistrationYear
 ,lreg.RegistrantIsCurrentlyActive
 ,rpr.EffectiveTime
 ,pr.PracticeRestrictionLabel											PracticeConditionLabel
 ,pr.Description
 ,pr.IsSupervisionRequired
 ,rpr.ExpiryTime
 ,sf.fIsActive(rpr.EffectiveTime, rpr.ExpiryTime) IsConditionActive
 ,rpr.IsDisplayedOnLicense
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
 ,rpr.RegistrantPracticeRestrictionSID
 ,rpr.RegistrantSID
 ,rpr.PracticeRestrictionSID
 ,lreg.PersonSID
from
	dbo.RegistrantPracticeRestriction	 rpr
join
	dbo.vRegistrant#LatestRegistration lreg on rpr.RegistrantSID				= lreg.RegistrantSID
join
	dbo.PracticeRestriction						 pr on rpr.PracticeRestrictionSID = pr.PracticeRestrictionSID;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns one record for each condition-on-practice along with latest registration information|EXPORT+ ^PersonList', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantPracticeRestriction#Profile', NULL, NULL
GO
