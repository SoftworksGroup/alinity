SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fPersonMailingAddress#Formatted
(
	@PersonSID int -- key of person record to return mailing address information for
)
/*********************************************************************************************************************************
Function: Person Mailing Address - Current
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns the active mailing address for a person including block formats (HTML and plain text)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ----------- + ----------- + --------------------------------------------------------------------------------------------
				: Tim Edlund	| Jan 2018		|	Initial Version
				: Taylor N		| Dec 2018		| Tweaked to include PersonSID so that it can be used in a mass sub-select
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function determines the latest mailing address for a person and returns the detailed address lines and "address blocks"
formatted as plain text and HTML.  The view is designed for use in views where a formatted form of the address (a text/HTML block)
is required.  

Note that the function dbo.fPersonMailingAddress#Current will return the current address columns without the block formats and is 
faster.  Ideally the formatted version of the address is only returned after records have been filtered.

Example
-------

<TestHarness>
  <Test Name = "Random100" IsDefault ="true" Description="Returns 100 current formatted address records selected 
at random. May contain blank addresses (valid).">
    <SQLScript>
      <![CDATA[
select
	p.PersonSID
 ,x.*
from
(select top (100) p.PersonSID from sf.Person p order by newid()) p
outer apply dbo.fPersonMailingAddress#Formatted(p.PersonSID)		 x;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = N'dbo.fPersonMailingAddress#Formatted'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

returns table
as
return
(
	select
		pma.PersonSID
	 ,pma.PersonMailingAddressSID
	 ,pma.StreetAddress1
	 ,pma.StreetAddress2
	 ,pma.StreetAddress3
	 ,pma.CityName
	 ,pma.StateProvinceName
	 ,pma.PostalCode
	 ,pma.IsAdminReviewRequired
	 ,pma.CountryName
	 ,pma.CountryIsDefault
	 ,pma.CitySID
	 ,sf.fFormatAddress(
											 null
											,pma.StreetAddress1
											,pma.StreetAddress2
											,pma.StreetAddress3
											,pma.CityName
											,pma.StateProvinceName
											,pma.PostalCode
											,(case when pma.CountryIsDefault = cast(1 as bit) then null else pma.CountryName end)
										 )				AddressBlockForPrint
	 ,sf.fFormatAddressForHTML(
															null
														 ,pma.StreetAddress1
														 ,pma.StreetAddress2
														 ,pma.StreetAddress3
														 ,pma.CityName
														 ,pma.StateProvinceName
														 ,pma.PostalCode
														 ,(case when pma.CountryIsDefault = cast(1 as bit) then null else pma.CountryName end)
														) AddressBlockForHTML
	from
		dbo.fPersonMailingAddress#Current(@PersonSID) pma
);
GO
