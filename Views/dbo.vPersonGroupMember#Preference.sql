SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vPersonGroupMember#Preference
/*********************************************************************************************************************************
View		: Person Group Member - Preference
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns consent information for export
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This view is intended for retrieving history of preference changes.  One record is returned for each active period for each 
preference group. Preference groups are identified with the bit column "Is-Preference". The view includes columns providing the latest
registration information for the member including a bit indicating whether they are currently active.

<TestHarness>
  <Test Name = "Random" IsDefault="true" Description="Executes view for 2 consent groups selected at random">
    <SQLScript>
    <![CDATA[
select
	pgmp.*
from
(
	select top (2)
		pg.PersonGroupSID
	from
		sf.PersonGroup pg
	where
		pg.PersonGroupCategory is not null	--TODO: Tim Sep 2018 replace with IsPreferenceGroup
	order by newid()
)																 pg
join
	dbo.vPersonGroupMember#Preference pgmp on pg.PersonGroupSID = pgmp.PersonGroupSID
order by
	pgmp.RegistrantNo;

if @@rowcount = 0 
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;

    ]]>
    </SQLScript>
    <Assertions>
	    <Assertion Type="ExecutionTime" Value="00:00:02" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vPersonGroupMember#Preference'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	lReg.RegistrantNo
 ,lReg.RegistrantLabel
 ,lReg.RegistrationLabel
 ,lReg.LatestRegistrationYear
 ,lReg.RegistrantIsCurrentlyActive
 ,pg.PersonGroupLabel															PreferenceGroupLabel
 ,pgm.EffectiveTime																PreferenceEffectiveTime
 ,pgm.ExpiryTime																	PreferenceExpiryTime
 ,sf.fIsActive(pgm.EffectiveTime, pgm.ExpiryTime) PreferenceIsActive
 ,pmac.StreetAddress1
 ,pmac.StreetAddress2
 ,pmac.StreetAddress3
 ,pmac.CityName
 ,pmac.StateProvinceName
 ,pmac.PostalCode
 ,pmac.CountryName
 ,pmac.StateProvinceCode
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
 ,pgm.PersonGroupMemberSID
 ,pgm.PersonGroupSID
 ,pgm.PersonSID
 ,lReg.RegistrantSID
from
	sf.PersonGroupMember							 pgm
join
	dbo.vRegistrant#LatestRegistration lReg on pgm.PersonSID		= lReg.PersonSID
join
	sf.Person													 p on pgm.PersonSID				= p.PersonSID
join
	sf.PersonGroup										 pg on pgm.PersonGroupSID = pg.PersonGroupSID and pg.IsPreference = cast(1 as bit)
left outer join
	sf.PersonEmailAddress							 pea on p.PersonSID				= pea.PersonSID and pea.IsPrimary = cast(1 as bit)
left outer join
	dbo.vPersonMailingAddress#Current	 pmac on p.PersonSID			= pmac.PersonSID
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieves the history of consent changes. One record is returned for each member for each consent period in a group. |EXPORT+ ^GroupList ^PersonList', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupMember#Preference', NULL, NULL
GO
