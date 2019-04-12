SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrant#PublicDirectoryEntry
/*********************************************************************************************************************************
View			: Registrant - Public Directory Entry
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a list of registrant records for use on the client portal registry features
History		: Author(s)  						| Month Year	| Change Summary
					: ----------------------|-------------|----------------------------------------------------------------------------------
					: Kris Dawson						| Feb 2018    |	Initial version
					: Tim Edlund						| Jun 2018		| Added effective and expiry in client TZ and date of initial registration.
					: Cory Ng								| Jul 2018		| Split out directory view to be specific to the screen (public, member, employer)
					: Tim Edlund						| Aug 2018		| Implemented register label function and removed mailing address
					: Cory Ng								| Nov 2018		| Added next year registration details
					: Russell Poirier				|	Dec 2018		|	Expired permits now appear
					: Taylor Napier					| Mar 2019		| Added the RegistrationSID so that ext views can optionally grab more info
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns a list of registrants for use on the client portal registry features. This view is the default shipped with
the product but an ext view can be provided to customize the data returned as the feature uses an ADO query instead of EF to create
the JSON data stream. RowGUID (from Person), PersonSID, IsOnPublicRegistry and IsOnMemberRegistry are required in any ext view.

Separate product versions of the view are create for "Member" and "Employer" directories which are based on this view.

This view excludes employment information where the member is NOT in active-practice.

NOTE this view is intended to be called with select * from the wrapping procedure used by the middle tier so the tests reflect this.

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
				dbo.vRegistrant#PublicDirectoryEntry x
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
				dbo.vRegistrant#PublicDirectoryEntry x
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
  @ObjectName = 'dbo.vRegistrant#PublicDirectoryEntry'
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
		dbo.vRegistrant#PublicDirectoryEntry rde
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
 ,case
		when (r.IsOnPublicRegistry = cast(1 as bit) and pr.IsPublicRegistryEnabled = cast(1 as bit)) or ( zrx.RegistrationSID is null and zrxl.RegistrationSID is not null and zrxl.IsOnPublicRegistry = cast(1 as bit)) then cast(1 as bit)
		else cast(0 as bit)
	end																																																																				 IsOnPublicRegistry
 ,p.GenderSID
 ,g.GenderLabel
 ,p.NamePrefixSID
 ,np.NamePrefixLabel
 ,p.FirstName
 ,isnull(p.CommonName, p.FirstName) CommonName
 ,p.MiddleNames
 ,p.LastName
 ,p.BirthDate
 ,p.DeathDate
 ,p.HomePhone
 ,p.MobilePhone
 ,c.CultureLabel
 ,sf.fFormatFullName(p.LastName, p.FirstName, p.MiddleNames, sf.fAltLanguage#Field(np.RowGUID, 'NamePrefixLabel', np.NamePrefixLabel, null)) FullName
 ,pea.PersonEmailAddressSID																																																									 PrimaryEmailAddressSID
 ,pea.EmailAddress																																																													 PrimaryEmailAddress
 ,r.RegistrantSID
 ,r.RegistrantNo
 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRANT')																								 RegistrantLabel
 ,sf.fFormatFileAsName(p.LastName, p.FirstName, p.MiddleNames)																																							 FileAsName
 ,r.PublicDirectoryComment
 ,zrx.RegistrationNo
 ,zrx.RegistrationSID
 ,zrx.PracticeRegisterSID
 ,isnull(zrx.PracticeRegisterName, 'Expired')                                                                                                PracticeRegisterName
 ,isnull(dbo.fRegistration#PublicDirectoryLabel(zrx.RegistrationSID), 'Expired')																														 PracticeRegisterLabel
 ,zrx.PracticeRegisterSectionSID
 ,zrx.PracticeRegisterSectionLabel																							
 ,format(coalesce(zrx.EffectiveTime, zrxl.EffectiveTime, cast(null as datetime)), 'dd-MMM-yyyy')																						 EffectiveTime
 ,coalesce(zrx.EffectiveTime, zrxl.EffectiveTime, cast(null as date))																																				 EffectiveTimeRaw
 ,format((case when year(isnull(zrx.ExpiryTime, zrxl.ExpiryTime)) > 2075 then cast(null as datetime) else coalesce(zrx.ExpiryTime, zrxl.ExpiryTime, cast(null as datetime)) end), 'dd-MMM-yyyy')	ExpiryTime
 ,coalesce(zrx.ExpiryTime, zrxl.ExpiryTime, cast(null as datetime))																																					 ExpiryTimeRaw
 ,fzrx.RegistrationNo																																																												 NextRegistrationNo
 ,fzrx.PracticeRegisterName																																																									 NextPracticeRegisterName
 ,dbo.fRegistration#PublicDirectoryLabel(fzrx.RegistrationSID)																																							 NextPracticeRegisterLabel
 ,format(fzrx.EffectiveTime, 'dd-MMM-yyyy')																																																	 NextEffectiveTime
 ,fzrx.EffectiveTime																																																												 NextEffectiveTimeRaw
 ,format((case when year(fzrx.ExpiryTime) > 2075 then cast(null as datetime) else fzrx.ExpiryTime end), 'dd-MMM-yyyy')											 NextExpiryTime
 ,fzrx.ExpiryTime																																																														 NextExpiryTimeRaw
 ,isnull(zrx.IsActivePractice, cast(0 as bit))                                                                                               IsActivePractice
 ,case when zrx.IsActivePractice = cast(1 as bit) then 'Practicing' else 'Non-Practicing' end																								 PracticingStatus
 ,case when zrx.IsActivePractice = cast(1 as bit) then 'Licensed' else 'Not Licensed' end																										 LicensingStatus
 ,prs.IsDisplayedOnLicense																																																									 SectionIsDisplayedOnLicense
 ,x.CurrentDateCTZ
 ,x.CurrentDateRaw
 ,x.CurrentDateTimeCTZ
 ,x.CurrentDateTimeRaw
 ,format(x.FirstRegistrationDateRaw,'dd-MMM-yyyy')																																													 FirstRegistrationDateCTZ
 ,x.FirstRegistrationDateRaw
 ,isnull(
					'<ul style="margin-left:12px;margin-bottom:0;">'
					+ stuff((
										select
											'<li>' + prx.PracticeRestrictionLabel + '</li>'
										from
											dbo.RegistrantPracticeRestriction rprx
										join
											dbo.PracticeRestriction						prx on rprx.PracticeRestrictionSID = prx.PracticeRestrictionSID
										where
											rprx.RegistrantSID = r.RegistrantSID 
										and
											rprx.IsDisplayedOnLicense = cast(1 as bit)
										and 
											sf.fIsActive(rprx.EffectiveTime, rprx.ExpiryTime) = cast(1 as bit)
										for xml path(''), type
									).value('(./text())[1]', 'varchar(max)')
									,1
									,0
									,''
								 ) + '</ul>'
				 ,'None'
				)																																																																		 Conditions
 ,isnull(
					'<ul style="margin-left:12px;margin-bottom:0;">'
					+ stuff((
										select
											'<li>' + psx.CredentialLabel + '</li>'
										from
											dbo.RegistrantCredential rlsx
										join
											dbo.Credential	 psx on rlsx.CredentialSID = psx.CredentialSID and psx.IsSpecialization = cast(1 as bit)
										where
											rlsx.RegistrantSID = r.RegistrantSID and sf.fIsActive(rlsx.EffectiveTime, rlsx.ExpiryTime) = cast(1 as bit)
										for xml path(''), type
									).value('(./text())[1]', 'varchar(max)')
									,1
									,0
									,''
								 ) + '</ul>'
				 ,'None'
				)																																																																		 Specializations
 ,isnull(
					'<ul style="margin-left:12px;margin-bottom:0;">'
					+ stuff((
										select
											'<li>' + cast(c.OutcomeSummary as nvarchar(max)) + '</li>'
										from
											dbo.Complaint c
										where
											c.RegistrantSID = r.RegistrantSID and c.IsDisplayedOnPublicRegistry = cast(1 as bit)
										for xml path(''), type
									).value('(./text())[1]', 'varchar(max)')
									,1
									,0
									,''
								 ) + '</ul>'
				 ,'None'
				)																																																																		 ComplaintOutcomeSummaries
from
	sf.Person					 p
join
	sf.Gender					 g on p.GenderSID = g.GenderSID
left join
	sf.ApplicationUser au on p.PersonSID = au.PersonSID
join
	sf.Culture				 c on au.CultureSID = c.CultureSID or au.ApplicationUserSID is null and c.IsDefault = cast(1 as bit)
left outer join
	sf.NamePrefix			 np on p.NamePrefixSID = np.NamePrefixSID
join
	dbo.Registrant		 r on p.PersonSID = r.PersonSID
cross apply
(
	select
		format(sf.fToday(), 'dd-MMM-yyyy')		 CurrentDateCTZ
	 ,sf.fToday()														 CurrentDateRaw
	 ,format(sf.fNow(), 'dd-MMM-yyyy HH:mm') CurrentDateTimeCTZ
	 ,sf.fNow()															 CurrentDateTimeRaw
	 ,dbo.fRegistrationYear#Current() + 1		 NextRegistrationYear
	 ,(
			select
				min(reg.EffectiveTime)
			from
				dbo.Registration reg
			join
				dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			join
				dbo.PracticeRegister pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
			where
				reg.RegistrantSID = r.RegistrantSID
			and
				pr.IsActivePractice = cast(1 as bit)
		)																			 FirstRegistrationDateRaw
)										 x
left outer join
	sf.PersonEmailAddress																					 pea on p.PersonSID = pea.PersonSID and pea.IsPrimary = cast(1 as bit) and pea.IsActive = cast(1 as bit)
outer apply dbo.fRegistrant#RegistrationCurrent(r.RegistrantSID) zrx
outer apply dbo.fRegistrant#RegistrationForYear(r.RegistrantSID, x.NextRegistrationYear) fzrx
left join
	dbo.PracticeRegisterSection prs on zrx.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
left join
	dbo.PracticeRegister				pr on prs.PracticeRegisterSID					= pr.PracticeRegisterSID
outer apply dbo.fRegistrant#LatestRegistration(r.RegistrantSID, dbo.fRegistrationYear#Current()) zrxl
GO
