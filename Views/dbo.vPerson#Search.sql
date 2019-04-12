SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPerson#Search]
as
/*********************************************************************************************************************************
View    : Person Search
Notice  : Copyright © 2017 Softworks Group Inc.
Summary		: Returns columns required for display and filtering on the Person search screens
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Cory Ng   	| Jul 2017    |	Initial version
					: Tim Edlund	| Oct 2017		| Expanded column list returned to support new searches and improved performance.

Comments	
--------
This view returns a sub-set of the full Person entity.  It is intended for use in search and dashboard procedures.  Only 
columns required for display in UI search results, or which are required for selecting records in the search procedure are
included.

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[

	select 
		 x.*
	from
		dbo.vPerson#Search x
	where
		x.RegistrantNo = '10274'
		

]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vPerson#Search'

-------------------------------------------------------------------------------------------------------------------------------- */

select
	p.PersonSID
 ,case
	when r.RegistrantNo is null then sf.fFormatFileAsName(p.LastName, p.FirstName, p.MiddleNames)
	else dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRANT')
	end																																										 NameLabel		--# display label for the registrants, file as name for non-registrants
 ,p.LastName
 ,p.FirstName
 ,p.MiddleNames
 ,isnull(pea.EmailAddress, au.UserName)																									 EmailAddress
 ,p.HomePhone
 ,p.MobilePhone
 ,r.RegistrantNo
 ,r.RegistrantSID
 ,cast(isnull(aud.RegistrantSID,0) as bit)																							 HasOpenAudit --#Indicates if the register currently has an open audit (e.g. competence audit, practice hours audit, etc.)
 ,cast(null as int)																																			 OpenAuditReviewCount
 ,cast(null as int)																																			 OpenAppReviewCount
 ,cast(isnull(au.ApplicationUserSID, 0) as bit)																					 IsApplicationUser
 ,cast(isnull(r.RegistrantSID, 0) as bit)																								 IsRegistrant
 ,cast(0 as bit)																																				 IsApplicant
 ,cast((select	count(1) from dbo.OrgContact oc where oc.PersonSID = p.PersonSID) as bit) IsOrgContact
 ,sf.fIsGrantedToUserSID('ADMIN.BASE', au.ApplicationUserSID)														 IsAdministrator
 ,cast((
				 select
						count(1)
				 from
						dbo.PAPSubscription paps
				 where
					 paps.PersonSID																						= p.PersonSID
					 and sf.fIsActive(paps.EffectiveTime, paps.CancelledTime) = cast(1 as bit)
			 ) as bit)																																				 IsPAPSubscriber
from
	sf.Person							p
left outer join
	dbo.Registrant				r on p.PersonSID				 = r.PersonSID
left outer join
	sf.ApplicationUser		au on p.PersonSID				 = au.PersonSID
left outer join
	sf.PersonEmailAddress pea on p.PersonSID			 = pea.PersonSID
															 and pea.IsActive	 = cast(1 as bit)
															 and pea.IsPrimary = cast(1 as bit)
left outer join
(
	select distinct
		x.RegistrantSID
	from
		dbo.fRegistrantAudit#CurrentStatus(-1, -1) x
	where
		x.IsInProgress = 1
)												aud on r.RegistrantSID								= aud.RegistrantSID;
GO
