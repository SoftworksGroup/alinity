SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrant#MemberDirectoryEntry
/*********************************************************************************************************************************
View			: Registrant - Member Directory Entry
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a list of registrant records for viewing by members (not the public) on the client portal registry
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Jul 2018    |	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns a list of registrant records for viewing by members (not the public) on the client portal registry. The member
version of the public registry generally contains additional information.  The base columns of this view is based on the
public-directory-entry view.

This view is the default shipped with the product but an extended configuration-specific view can be created customize the data
returned.  The directory feature uses an ADO query instead of EF to create the JSON data stream. RowGUID (from Person), PersonSID,
IsOnPublicRegistry and IsOnMemberRegistry are required in any ext view.

Separate product versions of the view are create for "Public" and "Employer" directories.

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
				dbo.vRegistrant#MemberDirectoryEntry x
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
				dbo.vRegistrant#MemberDirectoryEntry x
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
  @ObjectName = 'dbo.vRegistrant#MemberDirectoryEntry'
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
		dbo.vRegistrant#MemberDirectoryEntry rde
	--where
	--	rde.MiddleNames is not null
	where
		year(rde.FirstRegistrationDateCTZ) < 1980
	order by
		newid()
-------------------------------------------------------------------------------------------------------------------------------- */
as
select
  --!<ColumnList DataSource="dbo.vRegistrant#PublicDirectoryEntry" Alias="pd">
   pd.PersonSID
  ,pd.RowGUID
  ,pd.IsOnPublicRegistry
  ,pd.GenderSID
  ,pd.GenderLabel
  ,pd.NamePrefixSID
  ,pd.NamePrefixLabel
  ,pd.FirstName
  ,pd.CommonName
  ,pd.MiddleNames
  ,pd.LastName
  ,pd.BirthDate
  ,pd.DeathDate
  ,pd.HomePhone
  ,pd.MobilePhone
  ,pd.CultureLabel
  ,pd.FullName
  ,pd.PrimaryEmailAddressSID
  ,pd.PrimaryEmailAddress
  ,pd.RegistrantSID
  ,pd.RegistrantNo
  ,pd.RegistrantLabel
  ,pd.FileAsName
  ,pd.PublicDirectoryComment
  ,pd.RegistrationNo
  ,pd.RegistrationSID
  ,pd.PracticeRegisterSID
  ,pd.PracticeRegisterName
  ,pd.PracticeRegisterLabel
  ,pd.PracticeRegisterSectionSID
  ,pd.PracticeRegisterSectionLabel
  ,pd.EffectiveTime
  ,pd.EffectiveTimeRaw
  ,pd.ExpiryTime
  ,pd.ExpiryTimeRaw
  ,pd.NextRegistrationNo
  ,pd.NextPracticeRegisterName
  ,pd.NextPracticeRegisterLabel
  ,pd.NextEffectiveTime
  ,pd.NextEffectiveTimeRaw
  ,pd.NextExpiryTime
  ,pd.NextExpiryTimeRaw
  ,pd.IsActivePractice
  ,pd.PracticingStatus
  ,pd.LicensingStatus
  ,pd.SectionIsDisplayedOnLicense
  ,pd.CurrentDateCTZ
  ,pd.CurrentDateRaw
  ,pd.CurrentDateTimeCTZ
  ,pd.CurrentDateTimeRaw
  ,pd.FirstRegistrationDateCTZ
  ,pd.FirstRegistrationDateRaw
  ,pd.Conditions
  ,pd.Specializations
  ,pd.ComplaintOutcomeSummaries
	--!</ColumnList>
from
	dbo.vRegistrant#PublicDirectoryEntry pd
GO
