SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vPersonMailingAddress#Formatted
/*********************************************************************************************************************************
View		: Person Mailing Address - Formatted
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns current mailing address information for all persons including formatted blocks for print and HTML
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Dec 2018		|	Initial version

Comments	
--------
This view provides alternate call syntax for the fPersonMailingAddress#Formatted table function. It executes the underlying function
passing -1 as the parameter to execute the function for all Person records.  The view format may be faster than the function where a 
large percentage of the address list is being retrieved.  

The view provides one record with the latest, current mailing address for each person. Not all person records will have a current 
mailing address so an outer join to the view is required to avoid eliminating records if all person/registrant records are required in
the data set.

See also table function:dbo.fPersonMailingAddress#Formatted

Example
-------
<TestHarness>
	<Test Name = "Random" Description="Returns contents of the view for a set of persons selected at random.">
	<SQLScript>
	<![CDATA[

select top(100) x.* from	dbo.vPersonMailingAddress#Formatted x

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
	 @ObjectName = 'dbo.vPersonMailingAddress#Formatted'
	,@DefaultTestOnly = 1	
------------------------------------------------------------------------------------------------------------------------------- */
as
	select
		pmac.PersonSID
	 ,pmac.PersonMailingAddressSID
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
	 ,sf.fFormatAddress(
											 null
											,pmac.StreetAddress1
											,pmac.StreetAddress2
											,pmac.StreetAddress3
											,pmac.CityName
											,pmac.StateProvinceName
											,pmac.PostalCode
											,(case when pmac.CountryIsDefault = cast(1 as bit) then null else pmac.CountryName end)
										 )				AddressBlockForPrint
	 ,sf.fFormatAddressForHTML(
															null
														 ,pmac.StreetAddress1
														 ,pmac.StreetAddress2
														 ,pmac.StreetAddress3
														 ,pmac.CityName
														 ,pmac.StateProvinceName
														 ,pmac.PostalCode
														 ,(case when pmac.CountryIsDefault = cast(1 as bit) then null else pmac.CountryName end)
														) AddressBlockForHTML
	from
		dbo.fPersonMailingAddress#Current(-1) pmac


GO
