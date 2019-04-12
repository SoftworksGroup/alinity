SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vComplaint#Search
as
/*********************************************************************************************************************************
View			: Complaint Search
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns columns required for display and filtering on the Complaint search screens
----------------------------------------------------------------------------------------------------------------------------------
History		: Author							| Month Year	| Change Summary
					: ------------------- + ----------- + ----------------------------------------------------------------------------------
 					: Tim Edlund          | Mar 2019		|	Initial version

Comments
--------
This view returns a sub-set of the full Complaint entity.  It is intended for use in search and dashboard procedures.  Only 
columns required for display in UI search results, or which are required for selecting records in the search procedure are
included.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[

select top (100) * from		dbo.vComplaint#Search x order by x.LastName, x.Firstname

]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vComplaint#Search'
-------------------------------------------------------------------------------------------------------------------------------- */

select
	c.ComplaintSID
 ,c.ComplaintNo
 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRANT')																							 RegistrantLabel
 ,ctype.ComplaintTypeLabel
 ,cs.ComplaintSeverityLabel
 ,cl.ComplainantList
 ,c.IsDisplayedOnPublicRegistry
 ,c.OpenedDate
 ,isnull(c.ClosedDate, c.DismissedDate)																																																		 DecisionDate
 ,isnull(format(c.ConductStartDate, 'dd-MMM-yyyy'), '')
	+ (case when c.ConductStartDate = c.ConductEndDate then '' else ' - ' + format(c.ConductEndDate, 'dd-MMM-yyyy') end)										 ConductDates
 ,nextE.ComplaintEventTypeLabel																																																						 NextEventLabel
 ,nextE.DueDate																																																														 NextEventDueDate
 ,cast(case when c.DismissedDate is not null then 1 else 0 end as bit)																																		 IsDismissed	
 ,cast(case when c.ClosedDate is not null then 1 else 0 end as bit)																																				 IsClosed			
 ,cast(case when c.DismissedDate is not null then 'Dismissed' when c.ClosedDate is not null then 'Closed' else 'Open' end as nvarchar(35)) ComplaintStatusLabel
 ,c.ComplaintSummary
 -- member information 
 ,p.LastName
 ,p.FirstName
 ,p.MiddleNames
 ,p.HomePhone
 ,p.MobilePhone
 ,r.RegistrantNo
 ,r.RegistrantSID
 ,r.PersonSID
 -- access/security bits --
 ,cast(isnull(aud.RegistrantSID, 0) as bit)																																																 HasOpenAudit
 ,sf.fIsGrantedToUserSID('ADMIN.BASE', au.ApplicationUserSID)																																							 IsAdministrator
 ,case
		when sf.fIsGrantedToUserSID('ADMIN.COMPLAINTS', au.ApplicationUserSID) = cast(1 as bit) then cast(1 as bit) -- complaint admin's have view access
		else
			cast((
						 select
								count(1)
						 from
								dbo.ComplaintContact																			 cc
						 join
							 dbo.ComplaintContactRole																		ccr on cc.ComplaintContactRoleSID = ccr.ComplaintContactRoleSID and ccr.ComplaintContactRoleSCD = 'INVESTIGATOR' -- external reviewers assigned to the case have view access
						 join
							 sf.ApplicationUser																					au on cc.PersonSID								= au.PersonSID
						 join
						 (select sf .fApplicationUserSessionUserSID() LoggedInUserSID) x on 1														 = 1
						 where
							 sf.fIsActive(cc.EffectiveTime, cc.ExpiryTime) = cast(1 as bit) and au.ApplicationUserSID = x.LoggedInUserSID
					 ) as bit)
	end																																																																			 IsViewEnabled
from
	dbo.Complaint					c
join
	dbo.ComplaintType			ctype on c.ComplaintTypeSID = ctype.ComplaintTypeSID
join
	dbo.ComplaintSeverity	cs on c.ComplaintSeveritySID = cs.ComplaintSeveritySID
join
	dbo.Registrant				r on c.RegistrantSID = r.RegistrantSID
join
	sf.Person							p on r.PersonSID = p.PersonSID
join
	sf.ApplicationUser		au on c.ApplicationUserSID = au.ApplicationUserSID
left outer join
(
	select distinct
		x.RegistrantSID
	from
		dbo.fRegistrantAudit#CurrentStatus(-1, -1) x
	where
		x.IsInProgress = 1
)												aud on r.RegistrantSID = aud.RegistrantSID
outer apply
(
	select
		substring((
								select
									',' + p.FirstName + ' ' + p.LastName as [text()]
								from
									dbo.ComplaintContact		 cc
								join
									sf.Person								 p on cc.PersonSID								 = p.PersonSID
								join
									dbo.ComplaintContactRole ccr on cc.ComplaintContactRoleSID = ccr.ComplaintContactRoleSID and ccr.ComplaintContactRoleSCD = 'COMPLAINANT'
								where
									cc.ComplaintSID = c.ComplaintSID
								for xml path('')
							)
							,2
							,130
						 ) ComplainantList
)												cl
outer apply
(
	select top (1)
		cet.ComplaintEventTypeLabel
	 ,ce.DueDate
	from
		dbo.ComplaintEvent		 ce
	join
		dbo.ComplaintEventType cet on ce.ComplaintEventTypeSID = cet.ComplaintEventTypeSID
	where
		ce.ComplaintSID = c.ComplaintSID and ce.CompleteTime is null
	order by
		ce.DueDate
	 ,ce.ComplaintEventSID
) nextE;
GO
