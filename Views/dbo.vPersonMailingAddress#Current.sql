SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vPersonMailingAddress#Current
/*********************************************************************************************************************************
View		: Person Mailing Address - Current
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns current mailing address information for each person (expired addresses are not returned)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version
Comments	
--------
This view provides alternate call syntax for the fPersonMailingAddress#Current table function. The view format may be faster than
the function where a large percentage of the address list is being retrieved.  Unlike the table function, this view also includes
basic registrant information for context.  Note that it is possible for addresses to be returned for non-registrants however,
in which case the leading columns returned will be NULL.

The view provides one record with the latest, current mailing address for each person. Not all person records will have a
mailing address so an outer join to the view is required to avoid eliminating records if all person/registrant records are required in
the data set.

See also table function:dbo.fPersonMailingAddress#Current

Example
-------
<TestHarness>
	<Test Name = "Random" Description="Returns contents of the view for a set of active registrants selected at random.">
	<SQLScript>
	<![CDATA[

select top(100) x.* from	dbo.vPersonMailingAddress#Current x where x.RegistrantIsCurrentlyActive = 1

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
	 @ObjectName = 'dbo.vPersonMailingAddress#Current'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	lReg.RegistrantNo
 ,lReg.RegistrantLabel
 ,lReg.RegistrationLabel
 ,lReg.LatestRegistrationYear
 ,lReg.RegistrantIsCurrentlyActive
 ,lReg.RegistrantSID
 ,lReg.RegistrationSID
	--!<ColumnList DataSource="dbo.fPersonMailingAddress#Current" Alias="pmac">
	,pmac.PersonSID
	,pmac.PersonMailingAddressSID
	,pmac.NamePrefixLabel
	,pmac.FirstName
	,pmac.MiddleNames
	,pmac.LastName
	,pmac.StreetAddress1
	,pmac.StreetAddress2
	,pmac.StreetAddress3
	,pmac.CityName
	,pmac.StateProvinceName
	,pmac.PostalCode
	,pmac.IsAdminReviewRequired
	,pmac.CountryName
	,pmac.CountryIsDefault
	,pmac.CitySID
	,pmac.StateProvinceSID
	,pmac.StateProvinceCode
	,pmac.StateProvinceISONumber
	,pmac.CountrySID
	,pmac.CountryISOA2
	,pmac.CountryISOA3
	,pmac.CountryISONumber
	,pmac.RegionSID
	,pmac.RegionLabel
	,pmac.RegionName
--!</ColumnList>
from
	dbo.fPersonMailingAddress#Current(-1) pmac
left outer join
	dbo.vRegistrant#LatestRegistration		lReg on pmac.PersonSID = lReg.PersonSID
left outer join
	sf.PersonEmailAddress pea on pmac.PersonSID = pea.PersonSID and pea.IsPrimary = 1;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns the latest mailing address fields for a person. If an address is future dated, it is not included. For an address to be considered current, it must be effective on or before the current date.  Not all person records will necessarily have a mailing address. |EXPORT ^PersonList ^RegistrationList', 'SCHEMA', N'dbo', 'VIEW', N'vPersonMailingAddress#Current', NULL, NULL
GO
