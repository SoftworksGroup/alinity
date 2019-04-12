SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantApp#Search]
as
/*********************************************************************************************************************************
View			: Registrant Application Search
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns columns required for display and filtering on Registrant Application search screens
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Aug 2017    |	Initial version
					: Tim Edlund	| Oct 2017		| Updated to be consistent with design of Registrant Application search

Comments	
--------
This view returns a sub-set of the full Registrant Application entity.  It is intended for use in search and dashboard procedures.  
Only columns required for display in UI search results, or which are required for filtering records in the search procedure should be 
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
		dbo.vRegistrantApp#Search x

]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vRegistrantApp#Search'

-------------------------------------------------------------------------------------------------------------------------------- */
select
	ra.RegistrantAppSID
 ,r.RegistrantSID
 ,r.RegistrantNo
 ,sf.fFormatFileAsName(p.LastName, p.FirstName, p.MiddleNames)																 FileAsName
 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'APPLICATION') RegistrantLabel
 ,ra.RegistrationYear
 ,p.PersonSID
 ,p.FirstName
 ,p.CommonName
 ,p.MiddleNames
 ,p.LastName
 ,p.BirthDate
 ,p.HomePhone
 ,p.MobilePhone
 ,pea.EmailAddress
 ,pr.PracticeRegisterLabel
 ,prs.PracticeRegisterSectionLabel
 ,pr.PracticeRegisterSID
 ,prs.PracticeRegisterSectionSID
 ,ra.NextFollowUp
 ,cast((case when ra.NextFollowUp <= sf.fToday() then 1 else 0 end) as bit)										 IsFollowUpDue
 ,rax.FormOwnerSCD
 ,rax.FormOwnerLabel
 ,rax.LastStatusChangeUser
 ,rax.LastStatusChangeTime
 ,rax.FormStatusSID
 ,rax.FormStatusSCD																																						 RegistrantAppStatusSCD
 ,rax.FormStatusLabel																																					 RegistrantAppStatusLabel
 ,rax.IsFinal
 ,rax.IsInProgress
 ,dbo.fRegistrantApp#Recommendation(ra.RegistrantAppSID)																			 RecommendationLabel
 ,(case
		 when rax.IsFinal = cast(1 as bit) then cast(null as int)
		 else datediff(day, rax.LastStatusChangeTime, sysdatetimeoffset())
	 end
	)																																														 DaysSinceLastUpdate
 ,pma.AddressBlockForHTML																																			 PersonAddressBlockForHTML
 ,pma.AddressBlockForPrint																																		 PersonAddressBlockForPrint
 ,ra.RegistrantAppXID
 ,ra.LegacyKey
from
	dbo.RegistrantApp																					 ra
join
	dbo.Registration																					 reg on ra.RegistrationSID = reg.RegistrationSID
join
	dbo.Registrant																						 r on reg.RegistrantSID = r.RegistrantSID
join
	sf.Person																									 p on r.PersonSID = p.PersonSID
join
	dbo.PracticeRegisterSection																 prs on ra.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
join
	dbo.PracticeRegister																			 pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
left outer join
	sf.PersonEmailAddress																			 pea on p.PersonSID = pea.PersonSID and pea.IsActive = cast(1 as bit) and pea.IsPrimary = cast(1 as bit)
outer apply dbo.fPersonMailingAddress#Formatted(p.PersonSID) pma
outer apply dbo.fRegistrantApp#CurrentStatus(ra.RegistrantAppSID, -1) rax;
GO
