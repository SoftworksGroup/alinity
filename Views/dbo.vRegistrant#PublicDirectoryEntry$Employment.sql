SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrant#PublicDirectoryEntry$Employment
/*********************************************************************************************************************************
View			: Registrant - Public Directory Entry Employment
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a formatted employer list for use on the client portal registry features
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Taylor N		| Feb 2018    |	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns a formatted block of employers for use on the client portal registry features. This view is the default shipped with
the product but an ext view can be provided to customize the data returned as the feature uses an ADO query instead of EF to create
the JSON data stream.

This view excludes employment information where the member is NOT in active-practice.

Example
-------
<TestHarness>
	<Test Name="One" Description="returns 1 record at random from the view">
		<SQLScript>
			<![CDATA[

			declare 
				@RowGUID uniqueidentifier
			
			select top 1
				@RowGUID	= p.RowGUID
			from
				dbo.Registrant x
			join
				sf.Person p on x.PersonSID = p.PersonSID
			order by
				newid()

			select
			  x.*
			from
				dbo.vRegistrant#PublicDirectoryEntry$Employment x
			where
				x.RowGUID = @RowGUID

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
	<Test Name="Last name" IsDefault="True"  Description="runs a last name search">
		<SQLScript>
			<![CDATA[

			declare
				@randomPerson nvarchar(150)

			select top 1
				@randomPerson = substring(c.LastName, 1, 1) + '%'
			from
				sf.Person c
			join
				dbo.Registrant r on c.PersonSID = r.PersonSID
			order by
				newid()

			select
				x.*
			from
				dbo.vRegistrant#PublicDirectoryEntry$Employment x
			where
				x.LastName like @randomPerson
			order by
				x.RegistrantLabel

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:10"/>
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.vRegistrant#PublicDirectoryEntry$Employment'
 ,@DefaultTestOnly = 1

 -- use this query with modified WHERE clause to look for 
 -- specific examples to review in the UI

 	select top (5)
		rde.RegistrantNo
	 ,rde.FirstName
	 ,rde.MiddleNames
	 ,rde.LastName
	 ,rde.EffectiveTime
	 ,rde.FirstRegistrationDateCTZ
	from
		dbo.vRegistrant#PublicDirectoryEntry$Employment rde
	--where
	--	rde.MiddleNames is not null
	where
		year(rde.FirstRegistrationDateCTZ) < 1980
	order by
		newid()
-------------------------------------------------------------------------------------------------------------------------------- */
as
select
	p.PersonSID
 ,p.RowGUID
 ,isnull(
					stuff(
								 (
									 select
												'<tr>'
											+ '<td>' + isnull(x.OrgLabel, '-') + '</td>'
											+ '<td>' + isnull(x.Phone, '-') + '</td>'
											+ '</tr>'
									 from
										(
											select
												re.RegistrantSID
											 ,re.OrgSID
											 ,re.RegistrationYear
											 ,o.OrgLabel
											 ,re.PracticeHours
											 ,o.Phone
											 ,re.CreateTime
											from
												dbo.RegistrantEmployment re
											join
												dbo.vOrg								 o on re.OrgSID						= o.OrgSID
											cross apply
												dbo.fRegistrant#RegistrationCurrent(re.RegistrantSID) x
											where
												x.IsActivePractice = cast(1 as bit) -- ONLY INCLUDE employer data for active practice types
												and
												re.RegistrationYear >= (dbo.fRegistrationYear#Current() - 1) and re.RegistrantSID = r.RegistrantSID -- active as of last year or current year
												and
												(re.ExpiryTime is null or re.ExpiryTime >= sf.fNow()) -- not currently expired
										) x
									 order by
										 x.PracticeHours desc
										,x.CreateTime
									 for xml path(''), type
								 ).value('(./text())[1]', 'nvarchar(max)')
								,1
								,0
								,''
							 )
				 ,'-'
				)																																																																		 Employment
from
	sf.Person					 p
join
	dbo.Registrant		 r on p.PersonSID = r.PersonSID
GO
