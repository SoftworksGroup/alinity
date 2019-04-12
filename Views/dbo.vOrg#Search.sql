SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vOrg#Search
as
/*********************************************************************************************************************************
View    : dbo.vOrg#Ext
Notice  : Copyright © 2017 Softworks Group Inc.
Summary		: Returns columns required for display and filtering on the Org search screens
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Jul 2017    |	Initial version
					: Robin Payne	| Jul 2017		| Added IsAdminReviewRequired, IsEmployer, CityName, RegionName and RegionLabel, HTMLAddress
					: Tim Edlund	| Jun 2018		| Display label as first 35 of full name if legacy key is in the label column

Comments
--------
This view returns a sub-set of the full Org entity.  It is intended for use in search and dashboard procedures.  Only
columns required for display in UI search results, or which are required for selecting records in the search procedure should be
included.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[
	select top 1000
		 x.*
	from
		dbo.vOrg#Search x

]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vOrg#Search'

-------------------------------------------------------------------------------------------------------------------------------- */

select
	o.OrgSID
 ,(case when o.OrgLabel = o.LegacyKey then left(o.OrgName, 35)else o.OrgLabel end)																																						OrgLabel
 ,o.OrgName
 ,o.CitySID
 ,o.RegionSID
 ,o.IsActive
 ,o.IsAdminReviewRequired
 ,o.IsCredentialAuthority
 ,o.IsEmployer
 ,o.Phone
 ,o.TagList
 ,o.Comments
 ,c.CityName
 ,dbo.fOrg#FullLabel(o.OrgSID)																																																																FullOrgLabel		--# Organization label including all parent organizations separated by a dash
-- SQL Prompt formatting off
	,	(
			select
				count(1)
			from
				dbo.RegistrantCredential x
			where
				x.OrgSID = o.OrgSID
		)																																			CredentialCount						--# The total number of times this organization appears as a credential authority on registrant credentials
	,(
		select
			count(1)
		from
			dbo.RegistrantEmployment	x
		where
			x.OrgSID = o.OrgSID
		)																																			EmploymentCount						--# The total number of times this organization appears as an employer on registrant-employment records
	,	cast
		(
			case
				when
					o.LastVerifiedTime is null then 1
				when
					dateadd
					(
						month
					,isnull(convert(smallint, sf.fConfigParam#Value('OrgReviewMonths')), 12)
					,convert(smalldatetime, o.LastVerifiedTime)
					) < convert(smalldatetime, sysdatetimeoffset()) then 1
				else
					0
				end
			as bit)																															IsNextReviewDue						--# Indicates if the organization is overdue for review (according to time-for-review established in configuration settings)
	,	sf.fFormatAddressForHTML(o.OrgName, o.StreetAddress1, o.StreetAddress2, o.StreetAddress3, c.CityName, case when sp.IsDisplayed = 1 then sp.StateProvinceName end, o.PostalCode, ctry.CountryName) HtmlAddress --# Fully formatted address for the organization
-- SQL Prompt formatting on
from
	dbo.Org						o
join
	dbo.City					c on c.CitySID						= o.CitySID
join
	dbo.StateProvince sp on sp.StateProvinceSID = c.StateProvinceSID
join
	dbo.Country				ctry on ctry.CountrySID		= sp.CountrySID
left join
	dbo.Region				r on r.RegionSID					= o.RegionSID;
GO
