SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistration#ReinstatementStatus
(
	@RegistrationYear int -- the base "FROM" registration year to use as basis for returning status of reinstatements
)
returns table
/*********************************************************************************************************************************
Function : Registration - Reinstatement Status
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns status of reinstatements for the given year (query data source)
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- + ----------- + --------------------------------------------------------------------------------------
				 : Tim Edlund				| Oct 2018		| Initial version
 
Comments
--------
This table function is used as a source for queries on the Registration Management screen.  Only those columns required for 
querying are included.  The function operates on a base year of registrations and then looks for reinstatement form records
created in the same year to see the status of each, and which have resulted in new registration records (completed reinstatements).
A reinstatement is complete when it has resulted in a new registration record.  

The @RegistrationYear parameter is required.

Reinstatements in a status of WITHDRAWN are ignored by the returned data set.  When a reinstatement is WITHDRAWN the registrant is 
considered to be in the same status of not having started their reinstatement (No Form).

Normalization 
-------------
A maximum of 1 registration row is returned for each registrant.  If their reinstatement already resulted in a new registration
they are not included.

Example
-------
<TestHarness>
  <Test Name = "AllForYear" IsDefault ="true" Description="Executes the function to return registration and reinstatement
	data for a year selected at random.">
    <SQLScript>
      <![CDATA[

declare @registrationYear smallint;

select top (1)
	@registrationYear = frm.RegistrationYear
from
	dbo.Reinstatement	frm
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	print @registrationYear;

	select
		x.*
	from
		dbo.fRegistration#ReinstatementStatus(@registrationYear) x;

end;
		]]>
    </SQLScript>
    <Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
      <Assertion Type="ExecutionTime" Value="00:00:15"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistration#ReinstatementStatus'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		z.RegistrantSID
	 ,r.RegistrantNo
	 ,z.RegistrationSIDFrom
	 ,prFr.PracticeRegisterSID	 PracticeRegisterSIDFrom
	 ,prFr.PracticeRegisterLabel PracticeRegisterLabelFrom
	 ,z.ReinstatementSID
	 ,z.FormOwnerSID
	 ,z.FormOwnerSCD
	 ,z.FormStatusSID
	 ,z.FormStatusSCD
	 ,z.LastStatusChangeTime
	 ,z.LastStatusChangeUser
	 ,z.TotalDue
	 ,z.IsPaid
	 ,z.IsUnPaid
	 ,z.IsReviewRequired
	 ,z.RegistrationSIDTo
	 ,prTo.PracticeRegisterSID	 PracticeRegisterSIDTo
	 ,prTo.PracticeRegisterLabel PracticeRegisterLabelTo
	 ,z.NewRegistrationTime
	 ,p.PersonSID
	 ,au.CultureSID
	 ,z.IsFinal
	from
	(
		select
			reg.RegistrantSID
		 ,cs.RegistrationSID	RegistrationSIDFrom
		 ,cs.PracticeRegisterSectionSIDTo
		 ,cs.ReinstatementSID
		 ,cs.FormOwnerSID
		 ,cs.FormOwnerSCD
		 ,cs.FormStatusSID
		 ,cs.FormStatusSCD
		 ,cs.LastStatusChangeTime
		 ,cs.LastStatusChangeUser
		 ,cs.IsPaid
		 ,cs.IsReviewRequired
		 ,cs.IsUnPaid
		 ,cs.TotalDue
		 ,reg.RegistrationSID RegistrationSIDTo
		 ,reg.CreateTime			NewRegistrationTime
		 ,cs.IsFinal
		from
		(
			select
				x.ReinstatementSID
			 ,x.RegistrationSID
			 ,x.PracticeRegisterSectionSIDTo
			 ,x.FormOwnerSID
			 ,x.FormOwnerSCD
			 ,x.FormStatusSID
			 ,x.FormStatusSCD
			 ,x.LastStatusChangeTime
			 ,x.LastStatusChangeUser
			 ,x.IsReviewRequired
			 ,x.IsPaid
			 ,x.IsUnPaid
			 ,x.TotalDue
			 ,x.IsFinal
			 ,x.RowGUID
			from
				dbo.fReinstatement#CurrentStatus(-1, @RegistrationYear) x -- get statuses of all reinstatements for the year
			where
				x.FormStatusSCD <> 'WITHDRAWN'	-- avoid withdrawn forms (considered the same as "not started")
		)									 cs
		left outer join
			dbo.Registration reg on cs.RowGUID = reg.FormGUID
	)															z
	join
		dbo.Registration						regFr on z.RegistrationSIDFrom						= regFr.RegistrationSID -- get "from" register
	join
		dbo.Registrant							r on regFr.RegistrantSID									= r.RegistrantSID
	join
		sf.Person										p on r.PersonSID													= p.PersonSID -- link to person to obtain name/culture
	join
		dbo.PracticeRegisterSection prsFr on regFr.PracticeRegisterSectionSID = prsFr.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister				prFr on prsFr.PracticeRegisterSID					= prFr.PracticeRegisterSID
	left outer join
		sf.ApplicationUser					au on p.PersonSID													= au.ApplicationUserSID -- to retrieve culture
	left outer join
		dbo.PracticeRegisterSection prsTo on z.PracticeRegisterSectionSIDTo		= prsTo.PracticeRegisterSectionSID
	left outer join
		dbo.PracticeRegister				prTo on prsTo.PracticeRegisterSID					= prTo.PracticeRegisterSID
);
GO
