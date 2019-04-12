SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vPersonGroupMember#MailingAddress
/*********************************************************************************************************************************
View		: Person Group Member - Current
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns current mailing address information for each person in a group (expired addresses are not returned)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version
Comments	
--------
This view provides alternate call syntax for the fPersonGroupMember#MailingAddress table function with inclusion of the 
dbo.PersonGroupMember key so that it can be used to export addresses for a given group. The view format may be faster than
the function where a large percentage of the address list is being retrieved.  Unlike the table function, this view also includes
basic registrant information for context.  Note that it is possible for addresses to be returned for non-registrants however,
in which case the leading columns returned will be NULL.

The view provides one record with the latest, current mailing address for each person in the group. Not all person records will 
have a mailing address so an outer join to the view is required to avoid eliminating records if all person/registrant records are 
required in the data set.

See also table function:dbo.fPersonGroupMember#MailingAddress

Example
-------
<TestHarness>
	<Test Name = "Random" Description="Returns contents of the view for a set of group members selected for a random group.">
	<SQLScript>
	<![CDATA[
declare @personGroupSID int;

select top (1)
	@personGroupSID = pgx.PersonGroupSID
from
	sf.vPersonGroup#Ext pgx
where
	pgx.TotalActive > 0
order by
	newid();

if @@rowcount = 0 or @personGroupSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select top (100)
		x.*
	from
		dbo.vPersonGroupMember#MailingAddress x
	where
		x.PersonGroupSID = @personGroupSID

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
	 @ObjectName = 'dbo.vPersonGroupMember#MailingAddress'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	pgm.PersonGroupSID
 ,pgm.PersonGroupMemberSID
 ,lReg.RegistrantNo
 ,lReg.RegistrantLabel
 ,lReg.RegistrationLabel
 ,lReg.LatestRegistrationYear
 ,lReg.RegistrantIsCurrentlyActive
 ,lReg.RegistrantSID
 ,zpea.EmailAddress
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
from
	sf.PersonGroupMember																			 pgm
cross apply dbo.fPersonMailingAddress#Current(pgm.PersonSID) pmac
left outer join
	dbo.vRegistrant#LatestRegistration lReg on pmac.PersonSID = lReg.PersonSID
--! <MoreJoins>
left outer join
	sf.PersonEmailAddress						 zpea on pgm.PersonSID = zpea.PersonSID and zpea.IsPrimary = cast(1 as bit) and zpea.IsActive = cast(1 as bit);
--! </MoreJoins>
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns the latest mailing address fields for people in a group. If an address is future dated, it is not included. For an address to be considered current, it must be effective on or before the current date.  Not all person records will necessarily have a mailing address. |EXPORT ^PersonGroupMemberDetails', 'SCHEMA', N'dbo', 'VIEW', N'vPersonGroupMember#MailingAddress', NULL, NULL
GO
