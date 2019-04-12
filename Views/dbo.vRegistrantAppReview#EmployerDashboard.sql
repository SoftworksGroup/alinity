SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantAppReview#EmployerDashboard]
as
/*********************************************************************************************************************************
View    : Employer dashboard
Notice  : Copyright © 2016 Softworks Group Inc.
Summary	: Returns a single combined entity for use on the employer dashboard
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris Dawson | Dec 2016      |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This view is designed to increase the performance of the employer registrant application dashboard component by performing
the joins in the back-end as opposed to using LINQ's SQL syntax or worse querying each related entity one at a time per record.

Example
-------

select top 100
	 *
from
	dbo.vRegistrantAppReview#EmployerDashboard

------------------------------------------------------------------------------------------------------------------------------- */

select
	 av.RegistrantAppReviewSID
	,sf.fFormatFileAsName(p.LastName, p.FirstName, p.MiddleNames) FileAsName
	,cs.LastStatusChangeTime
	,prs.PracticeRegisterSectionLabel
  ,av.IsEditEnabled
from
	dbo.vRegistrantAppReview av
join
	sf.ApplicationUser au on av.PersonSID = au.PersonSID
join
	dbo.RegistrantApp ra on av.RegistrantAppSID = ra.RegistrantAppSID
join
	dbo.PracticeRegisterSection prs on ra.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
join
	dbo.Registration re on ra.RegistrationSID = re.RegistrationSID
join
	dbo.Registrant r on re.RegistrantSID = r.RegistrantSID
join
	sf.Person p on r.PersonSID = p.PersonSID
cross apply
	dbo.fRegistrantApp#CurrentStatus(ra.RegistrantAppSID, -1) cs	
where
	au.ApplicationUserSID = sf.fApplicationUserSessionUserSID();
GO
