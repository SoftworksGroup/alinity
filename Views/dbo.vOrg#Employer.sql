SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vOrg#Employer]
as
/*********************************************************************************************************************************
View    : Org(anization) Employer
Notice  : Copyright © 2016 Softworks Group Inc.
Summary	: Returns the list of all active organizations identified as employers
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Aug 2016		| Initial version
				: Cory Ng			| Dec 2018		| Included OrgTypeCode in return list
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This view is called by the UI to populate drop-down lists of active employers for assignment to registrants and other stakeholders.
For organizations to be included they must be active (IsActive = 1) and they must also be associated with at least 1 registrant's
practice hours through a relationship (inner join) to dbo.RegistrantPractice. Note that an organization is considered an employer
if the employer attribute bit is turned on.  Even if the organization has one or more active registrant employment records but
does not have the employer attribute turned on, they are excluded.  This is done so that the view can be used as data source for 
selecting  employers.  If the organization is no longer an employer, but may have historical employment records, it is
excluded.

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Calls the view to return all records. Test ensures content is returned and
	that performance is acceptable.">
		<SQLScript>
			<![CDATA[
			
select
	 x.*
from
	dbo.vOrg#Employer x
	
if @@rowcount = 0 raiserror('** no sample data to support test **', 18, 1)

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.vOrg#Employer'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

select
	 o.OrgSID
	,o.OrgLabel
	,o.OrgName
	,o.IsActive
	,ot.OrgTypeCode
	,sf.fFormatAddressForHTML(null, o.StreetAddress1, o.StreetAddress2, o.StreetAddress3, c.CityName, sp.StateProvinceName, o.PostalCode, co.CountryName) FormattedAddress
from
	dbo.Org o
join
	dbo.OrgType					ot on o.OrgTypeSID = ot.OrgTypeSID
join
	dbo.City c on o.CitySID = c.CitySID
join
	dbo.StateProvince sp on c.StateProvinceSID = sp.StateProvinceSID
join
	dbo.Country co on sp.CountrySID = co.CountrySID
where
	o.IsActive = cast(1 as bit)
and
	o.IsEmployer = cast(1 as bit)
GO
