SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistration#RenewalStatus
(
	@RegistrationYear int -- the base "FROM" registration year to use as basis for returning status of renewals
)
returns table
/*********************************************************************************************************************************
Function : Registration - Renewal Status
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns status of renewals for all registrations where renewal is enabled for the given year (query data source)
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- + ----------- + --------------------------------------------------------------------------------------
				 : Tim Edlund				| Sep 2018		| Initial version
				 : Tim Edlund				| Jan 2019		| Logic for Is-Non-Renewal-Registration updated to handle non-linking RowGUID
 
Comments
--------
This table function is used as a source for queries on the Registration Management screen.  Only those columns required for 
querying are included.  The function operates on a base year of registrations and then looks forward into the following
year renewals records to see the status of each, and which have resulted in new registration records (completed renewals).
A renewal is complete when it has resulted in a new registration record - including where the new registration record
is an inactive-type register (e.g. member goes to "Cancelled" register).  

The @RegistrationYear parameter is required.

Renewals in a status of WITHDRAWN are ignored by the returned data set.  When a renewal is WITHDRAWN the registrant is 
considered to be in the same status of not having started their renewal (No Form).

Normalization 
-------------
A maximum of 1 registration row is returned for each registrant and a registrant will be included if their latest 
registration in the given year is on a Register where renewal is enabled.

Example
-------
<TestHarness>
  <Test Name = "AllForYear" IsDefault ="true" Description="Executes the function to return registration and renewal
	data for a year selected at random.">
    <SQLScript>
      <![CDATA[

declare @registrationYear smallint;

select top (1)
	@registrationYear = reg.RegistrationYear
from
	dbo.Registration				 reg
join
	dbo.RegistrationScheduleYear rsy on reg.RegistrationYear = rsy.RegistrationYear
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
		dbo.fRegistration#RenewalStatus(@registrationYear) x;

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
	@ObjectName = 'dbo.fRegistration#RenewalStatus'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		z.RegistrantSID
	 ,z.RegistrantNo
	 ,z.RegistrationSIDFrom
	 ,prFr.PracticeRegisterSID	 PracticeRegisterSIDFrom
	 ,prFr.PracticeRegisterLabel PracticeRegisterLabelFrom
	 ,z.RegistrantRenewalSID
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
	 ,cast(case
					 when z.FormStatusSCD = 'APPROVED' and z.TotalDue = 0.0 then 0
					 when z.RegistrationSIDTo is null and reg.RegistrationSID is not null then 1
					 else 0
				 end as bit)					 IsNonRenewalRegistration -- if next registration not related to renewal
	 ,p.PersonSID
	 ,pad.PAPSubscriptionSID
	 ,au.CultureSID
	 ,z.IsFinal
	from
	(
		select
			lReg.RegistrantSID
		 ,lReg.RegistrationSID RegistrationSIDFrom
		 ,cs.PracticeRegisterSectionSIDTo
		 ,r.RegistrantNo
		 ,r.PersonSID
		 ,cs.RegistrantRenewalSID
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
		 ,reg.RegistrationSID	 RegistrationSIDTo
		 ,reg.CreateTime			 NewRegistrationTime
		 ,cs.IsFinal
		from
			dbo.[fRegistrant#LatestRegistration$SID](-1, @RegistrationYear) lReg -- start with all registrations for the year 
		join
			dbo.Registrant																									r on lReg.RegistrantSID		 = r.RegistrantSID
		left outer join
		(
			select
				x.RegistrantRenewalSID
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
				dbo.fRegistrantRenewal#CurrentStatus(-1, (@RegistrationYear + 1)) x -- get statuses of all renewals for next registration year
			where
				x.FormStatusSCD <> 'WITHDRAWN'	-- avoid withdrawn forms (considered the same as "not started")
		)																																	cs on lReg.RegistrationSID = cs.RegistrationSID
		left outer join
			dbo.Registration																								reg on cs.RowGUID					 = reg.FormGUID
	)															z
	join
		sf.Person										p on z.PersonSID													= p.PersonSID -- link to person to obtain name/culture
	join
		dbo.Registration						regFr on z.RegistrationSIDFrom						= regFr.RegistrationSID -- get "from" register
	join
		dbo.PracticeRegisterSection prsFr on regFr.PracticeRegisterSectionSID = prsFr.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister				prFr on prsFr.PracticeRegisterSID					= prFr.PracticeRegisterSID and prFr.IsRenewalEnabled = cast(1 as bit) -- filter on registers enabling renewal only
	left outer join
	(
		select
				ps.PAPSubscriptionSID
			,	ps.PersonSID
			,	row_number() over (partition by ps.PersonSID order by ps.EffectiveTime desc) RowNo
		from
			dbo.PAPSubscription ps
		join
			RegistrationScheduleYear rsy on rsy.RegistrationYear = @RegistrationYear
		where
			sf.fIsDateOverlap(rsy.PAPBlockStartTime, rsy.PAPBlockEndTime, ps.EffectiveTime, ps.CancelledTime) = 1
	)															pad on p.PersonSID												= pad.PersonSID and pad.RowNo = 1
	left outer join
		sf.ApplicationUser					au on p.PersonSID													= au.ApplicationUserSID -- to retrieve culture
	left outer join
		dbo.PracticeRegisterSection prsTo on z.PracticeRegisterSectionSIDTo		= prsTo.PracticeRegisterSectionSID
	left outer join
		dbo.PracticeRegister				prTo on prsTo.PracticeRegisterSID					= prTo.PracticeRegisterSID
	left outer join
	(
		select
			regX.RegistrantSID
		 ,min(regX.RegistrationSID) RegistrationSID
		from
			dbo.Registration regX
		where
			regX.RegistrationYear = @RegistrationYear + 1
		group by
			regX.RegistrantSID
	)															reg on z.RegistrantSID										= reg.RegistrantSID
);
GO
