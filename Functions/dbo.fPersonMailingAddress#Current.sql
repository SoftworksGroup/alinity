SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fPersonMailingAddress#Current
(
	@PersonSID int	-- key of person record to return latest current mailing address information for or -1 for all current addresses
)
/*********************************************************************************************************************************
Function: Person Mailing Address - Current
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns the active mailing address for a person
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ----------- + ----------- + --------------------------------------------------------------------------------------------
				: Tim Edlund	| Sep	2017		|	Initial Version
				: Tim Edlund	| Jul 2018		| Added FK and ISO values and added -1 option in parameter to return ALL current addresses
				: Tim Edlund	| Jan 2019		| Added logic to suppress state/province name and code when IsDisplayed = 0 (off)

Comments	
--------
This function determines the latest mailing address for a single person key, or for all Person records where the parameter is
passed as -1.  The table function is designed for use in views and functions which require a current mailing address. It can also 
be used as a data source in forms for obtaining current address values.  

If an address is future dated, it is not returned in this view!  For an address to be considered current, it must be effective
on or before the current date

Keep in mind that not all person rows will necessarily have a mailing address and therefore an outer apply must be used.

Maintenance Note
----------------
Including a function to return the address information formatted as a block for display in the UI or for printing, is 
intentionally NOT included within the function as it negatively impacts performance.  A function is available
that also returns the address as HTML and plain text blocks - see dbo.fPersonMailingAddress#Formatted. Alternatively
you can apply the formatted directly as shown below after records have been filtered:

	... sf.fFormatAddress
	(
		 null                                   
		,x.StreetAddress1
		,x.StreetAddress2
		,x.StreetAddress3
		,cty.CityName
		,sp.StateProvinceName
		,x.PostalCode
		,(case when ctry.IsDefault = cast(1 as bit) then null else ctry.CountryName end)
	)  AddressBlock

It is better to apply TSQL functions after all filtering has occurred on the result set. 

Example
-------
<TestHarness>
	<Test Name="Random" Description="Returns a current address selected at random">
		<SQLScript>
			<![CDATA[
declare @PersonSID int;

select top (1)
	@PersonSID = pma.PersonSID
from
	dbo.PersonMailingAddress pma
order by
	newid();

if @PersonSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select x.* from dbo.fPersonMailingAddress#Current(@PersonSID) x;
end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fPersonMailingAddress#Current'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
returns table
as
return
(
	select
		x.PersonSID
	 ,x.PersonMailingAddressSID
	 ,np.NamePrefixLabel
	 ,p.FirstName
	 ,p.MiddleNames
	 ,p.LastName
	 ,x.StreetAddress1
	 ,x.StreetAddress2
	 ,x.StreetAddress3
	 ,cty.CityName
	 ,(case when sp.IsDisplayed = cast(1 as bit) then sp.StateProvinceName else cast(null as nvarchar(30))end) StateProvinceName
	 ,x.PostalCode
	 ,x.IsAdminReviewRequired
	 ,ctry.CountryName
	 ,ctry.IsDefault																																													 CountryIsDefault
	 ,x.CitySID
	 ,cty.StateProvinceSID
	 ,(case when sp.IsDisplayed = cast(1 as bit) then sp.StateProvinceCode else cast(null as nvarchar(5))end)	 StateProvinceCode
	 ,sp.ISONumber																																														 StateProvinceISONumber
	 ,sp.CountrySID
	 ,ctry.ISOA2																																															 CountryISOA2
	 ,ctry.ISOA3																																															 CountryISOA3
	 ,ctry.ISONumber																																													 CountryISONumber
	 ,x.RegionSID
	 ,rgn.RegionLabel
	 ,rgn.RegionName
	from
	(
		select
			pma.PersonSID
		 ,row_number() over (partition by
													 pma.PersonSID
												 order by
													 EffectiveTime desc
													,PersonMailingAddressSID desc
												) rn	-- order by latest effective then SID
		 ,pma.PersonMailingAddressSID
		 ,pma.StreetAddress1
		 ,pma.StreetAddress2
		 ,pma.StreetAddress3
		 ,pma.CitySID
		 ,pma.RegionSID
		 ,pma.PostalCode
		 ,pma.IsAdminReviewRequired
		from
			dbo.PersonMailingAddress pma
		where
			(pma.PersonSID = @PersonSID or @PersonSID = -1) and pma.EffectiveTime <= sf.fNow()	-- compare to current time in the user's timezone
	)										x
	join
		sf.Person					p on x.PersonSID					 = p.PersonSID
	join
		dbo.City					cty on x.CitySID					 = cty.CitySID
	join
		dbo.StateProvince sp on cty.StateProvinceSID = sp.StateProvinceSID
	join
		dbo.Country				ctry on sp.CountrySID			 = ctry.CountrySID
	left outer join
		dbo.Region				rgn on x.RegionSID				 = rgn.RegionSID
	left outer join
		sf.NamePrefix			np on p.NamePrefixSID			 = np.NamePrefixSID
	where
		x.rn = 1	-- filter to latest row for each Person SID
);
GO
