SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantAudit#Search]
as
/*********************************************************************************************************************************
View			: Registrant Audit Search
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns columns required for display and filtering on Registrant Audit search screens
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| May 2017    |	Initial version

Comments	
--------
This view returns a sub-set of the full Registrant Audit entity.  It is intended for use in search and dashboard procedures.  Only 
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
		dbo.vRegistrantAudit#Search x

]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vRegistrantAudit#Search'

-------------------------------------------------------------------------------------------------------------------------------- */
select
	ra.RegistrantAuditSID
 ,r.RegistrantSID
 ,r.RegistrantNo
 ,sf.fFormatFileAsName(p.LastName, p.FirstName, p.MiddleNames)													 FileAsName
 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'AUDIT') RegistrantLabel
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
 ,ra.AuditTypeSID
 ,at.AuditTypeLabel
 ,cast((case when ra.NextFollowUp <= sf.fToday() then 1 else 0 end) as bit)							 IsFollowUpDue
 ,rax.FormOwnerSID
 ,rax.FormOwnerSCD
 ,rax.FormOwnerLabel
 ,rax.LastStatusChangeUser
 ,rax.LastStatusChangeTime
 ,rax.FormStatusSID
 ,rax.FormStatusSCD																																			 RegistrantAuditStatusSCD
 ,rax.FormStatusLabel																																		 RegistrantAuditStatusLabel
 ,rax.IsFinal
 ,case when rax.IsFinal = cast(1 as bit)
		then cast(0 as bit)
		else cast(1 as bit)
	end																																										 IsInProgress
 ,dbo.fRegistrantAudit#Recommendation(ra.RegistrantAuditSID)														 RecommendationLabel
 ,(case
	 when rax.IsFinal = cast(1 as bit) then cast(null as int)
	 else datediff(day, rax.LastStatusChangeTime, sysdatetimeoffset())
	 end
	)																																											 DaysSinceLastUpdate
 ,ra.RegistrantAuditXID
 ,ra.LegacyKey
from
	dbo.RegistrantAudit																																 ra
join
	dbo.Registrant																																		 r on ra.RegistrantSID = r.RegistrantSID
join
	sf.Person																																					 p on r.PersonSID = p.PersonSID
join
	dbo.AuditType																																			 at on ra.AuditTypeSID = at.AuditTypeSID
left outer join
	sf.PersonEmailAddress																															 pea on p.PersonSID = pea.PersonSID and pea.IsActive = cast(1 as bit) and pea.IsPrimary = cast(1 as bit)
outer apply dbo.fRegistrantAudit#CurrentStatus(ra.RegistrantAuditSID, -1) rax;
GO
