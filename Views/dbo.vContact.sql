SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vContact
as
/*********************************************************************************************************************************
View		: Contact
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns current profile information for a person
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| March		2017	|	Initial Version
				: Kris Dawson	| May 		2017	|	Added registrant #
				: Cory Ng			| Jan			2019	| Added preferred name
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This view combines Person information from several tables to return comprehensive profile information.  All person records
are included regardless of person type - e.g. registrants, non-registrants, users only - all appear in this view.

Example
-------
<TestHarness>
	<Test Name="One" Description="returns 1 record at random from the view">
		<SQLScript>
			<![CDATA[

			declare 
				@PersonSID int
			
			select
				@PersonSID	= x.PersonSID
			from
				sf.Person x
			
			select
				x.*
			from
				dbo.vContact x
			where
				x.ContactSID = @PersonSID

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
	<Test Name="All" IsDefault="True"  Description="returns all records from the view.">
		<SQLScript>
			<![CDATA[

			select
				 x.*
			from
				dbo.vContact x

			if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>	
</TestHarness>

	exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.vContact'
 ,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
select
	p.PersonSID																																									ContactSID	-- column is renamed for compatibility with EF assumptions throughout framework
 ,p.FirstName
 ,p.CommonName
 ,isnull(p.CommonName, p.FirstName)																														PreferredName
 ,p.MiddleNames
 ,p.LastName
 ,gender.GenderSCD
 ,gender.GenderLabel
 ,np.NamePrefixLabel
 ,p.BirthDate
 ,sf.fAgeInYears(p.BirthDate, sf.fToday())																										Age
 ,p.DeathDate
 ,pea.EmailAddress
 ,pma.StreetAddress1
 ,pma.StreetAddress2
 ,pma.StreetAddress3
 ,pma.CityName
 ,pma.StateProvinceName
 ,pma.PostalCode
 ,pma.CountryName
 ,pma.AddressBlockForPrint
 ,pma.AddressBlockForHTML
 ,p.HomePhone
 ,p.MobilePhone
 ,p.SignatureImage
 ,p.IdentityPhoto
 ,p.IsTextMessagingEnabled
 ,p.ImportBatch
 ,p.UserDefinedColumns
 ,p.PersonXID
 ,p.LegacyKey
 ,p.CreateUser
 ,p.CreateTime
 ,p.UpdateUser
 ,p.UpdateTime
 ,p.RowGUID
 ,sf.fFormatFileAsName(p.LastName, p.FirstName, p.MiddleNames)																FileAsName	--# A filing label for the contact based on last name, first name middle names
 ,sf.fFormatFullName(p.LastName, p.FirstName, p.MiddleNames, np.NamePrefixLabel)							FullName		--# A label for the contact suitable for formal addressing based on name prefix (salutation) first name middle names last name
 ,sf.fFormatDisplayName(p.LastName, isnull(p.CommonName, p.FirstName))												DisplayName --# A label for the contact suitable for use on the UI and reports based on first name last name
 ,sf.fFormatFullName(p.LastName, isnull(p.CommonName, p.FirstName), null, np.NamePrefixLabel) MailingName --# A label for the contact suitable for envelope addressing based on last name, common (or first name), and prefix (salutation)
 ,pea.PersonEmailAddressSID																																		EmailAddressSID
 ,gender.GenderSID
 ,p.NamePrefixSID
 ,reg.RegistrantNo
 ,rlc.RegistrationNo																																														--@dbo.Registration.RegistrationNo										
 ,rlc.PracticeRegisterSectionSID																																					--@dbo.Registration.PracticeRegisterSectionSID		
 ,rlc.EffectiveTime																																												--@dbo.Registration.EffectiveTime								
 ,rlc.ExpiryTime																																													--@dbo.Registration.ExpiryTime										
 ,rlc.PracticeRegisterName																																								--@dbo.PracticeRegister.PracticeRegisterName					
 ,rlc.PracticeRegisterLabel																																								--@dbo.PracticeRegister.PracticeRegisterLabel				
 ,rlc.IsActivePractice																																										--@dbo.PracticeRegister.IsActivePractice							
 ,rlc.PracticeRegisterSectionLabel																																				--@dbo.PracticeRegisterSection.PracticeRegisterSectionLabel	
 ,rlc.IsSectionDisplayedOnLicense																																					--@dbo.PracticeRegisterSection.IsDisplayedOnLicense					
from
	sf.Person																									 p
join
	sf.Gender																									 gender on p.GenderSID = gender.GenderSID
left outer join
	sf.NamePrefix																							 np on p.NamePrefixSID = np.NamePrefixSID
left outer join
	sf.PersonEmailAddress																			 pea on p.PersonSID = pea.PersonSID and pea.IsPrimary = cast(1 as bit) and pea.IsActive = cast(1 as bit)
left outer join
	dbo.Registrant																						 reg on p.PersonSID = reg.PersonSID
outer apply dbo.fPersonMailingAddress#Formatted(p.PersonSID) pma
outer apply dbo.fRegistrant#Ext(reg.RegistrantSID) rlc;
GO
