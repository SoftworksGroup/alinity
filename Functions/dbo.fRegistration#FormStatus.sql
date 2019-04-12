SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistration#FormStatus
(
	@LatestRegistration dbo.LatestRegistration readonly -- table of registration keys to lookup status for
)
returns table
/*********************************************************************************************************************************
Function : Registration - Form Status
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Returns a status record for latest registration-form type for the given registration record
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- + ----------- + --------------------------------------------------------------------------------------
				 : Tim Edlund				| Oct 2018		| Initial version (redeveloped from Apr 2018 version)
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This table function modularizes the logic required to determine the status of Registration Forms related to each (dbo) 
Registration record in the given year.  The function can be called to retrieve records for a single year only.  Multiple years are 
not supported. The function is intended to support the Registration (List) search page primarily although may also be used for 
reporting statistics related to that page.

Registration forms related to dbo.Registration records include: Application, Renewal, Reinstatement and Registration-Change.  
These record types result in a new registration record after approval and payment.  Each of these form-type records includes a 
foreign key to the Registration in effect at the time the form record is created.  This function searches for each possible type 
of form-record related to the registration and returns status information for it. 

The registration record used as the basis for the result set is the "latest" registration record in the given year. If a member 
went from applicant to active member in the year for example - only their active registration is returned.

Only 1 of the 4 form types can be associated with a Registration at any point in time.  When one of the form types is open,
business rules in the application and database prevent another form from being created for the same record until the first form
is finalized. For example, the system does not allow a Registration-Change record to be added for the Registration record that also 
has a Renewal open. 

WITHDRAWN forms not returned
----------------------------
The logic avoids returning content for any form with a WITHDRAWN status.  This is done to meet the requirements of the #search 
procedure which relies on the function where WITHDRAWN forms are to be ignored.

Finding the related form record
-------------------------------
A unique key exists on RegistrationSID in each of the Renewal, Reinstatement and Application form types.  As a result only 1 
form record can exist for each given registration record. These form types can be "WITHDRAWN" but if the member comes into 
start a new form after the withdrawal, then the WITHDRAWN form is removed.  

The Registration Change table is different than the other 3 form types in that it is possible for the administrator to create 
multiple change forms against the same base registration record.  The latest (last) registration change record is selected.
Multiple registration change records for the same base registration is allowed to support auditing of registration changes
that are initiated but never approved.  An alternate means of supporting such auditing may be developed in later releases
and a unique key on the RegistrationSID column in Registration Change will be implemented as well.

Maintenance Note
----------------
Ensure the codes returned by this view are consistent with codes returned by dbo.vRegFormType.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the function to return status information for all registration
	from a year selected at random.">
    <SQLScript>
      <![CDATA[

declare
	@registrationYear		smallint
 ,@latestRegistration dbo.LatestRegistration

select top (1)
	@registrationYear = reg.RegistrationYear
from
	dbo.Registration reg
order by
	newid()

insert
	@latestRegistration (RegistrationSID, RegistrantSID)
select
	lReg.RegistrationSID
 ,lReg.RegistrantSID
from
	dbo.fRegistrant#LatestRegistration$SID(-1, @registrationYear) lReg;

select x.* from dbo.fRegistration#FormStatus(@latestRegistration) x 
option (recompile)

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistration#FormStatus'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		z.RegistrantSID
	 ,z.RegistrationSID
	 ,z.RegFormRecordSID
	 ,z.RegFormTypeCode
	 ,z.RegFormIsInProgress
	 ,z.RegFormIsFinal
	 ,z.RegFormOwnerSID
	 ,z.RegFormOwnerSCD
	 ,z.RegFormOwnerLabel
	 ,z.RegFormStatusSID
	 ,z.RegFormStatusSCD
	 ,z.RegFormStatusLabel
	 ,z.RegFormStatusTime
	 ,z.RegFormStatusUser
	 ,z.RegFormIsReviewRequired
	 ,z.RegFormInvoiceSID
	 ,z.RegFormTotalDue
	 ,z.RegFormTotalPaid
	 ,z.NextFollowUp
	 ,z.PracticeRegisterSectionSIDTo
	from
	(
		select
			lreg.RegistrantSID
		 ,lreg.RegistrationSID
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.RegistrantRenewalSID
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.ReinstatementSID
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.RegistrationChangeSID
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.RegistrantAppSID
				 else cast(null as int)
			 end
			) RegFormRecordSID
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then 'RENEWAL' -- MAINTENANCE NOTE: changes in these codes must be made in dbo.vRegFormType
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then 'REINSTATEMENT'
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then 'REGCHANGE'
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then 'APPLICATION'
				 else 'NONE'
			 end
			) RegFormTypeCode
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.IsInProgress
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.IsInProgress
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.IsInProgress
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.IsInProgress
				 else cast(0 as bit)
			 end
			) RegFormIsInProgress
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.IsFinal
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.IsFinal
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.IsFinal
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.IsFinal
				 else cast(0 as bit)
			 end
			) RegFormIsFinal
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.FormOwnerSID
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.FormOwnerSID
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.FormOwnerSID
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.FormOwnerSID
				 else cast(null as int)
			 end
			) RegFormOwnerSID
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.FormOwnerSCD
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.FormOwnerSCD
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.FormOwnerSCD
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.FormOwnerSCD
				 else cast('NONE' as varchar(25))
			 end
			) RegFormOwnerSCD
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.FormOwnerLabel
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.FormOwnerLabel
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.FormOwnerLabel
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.FormOwnerLabel
				 else cast('None' as nvarchar(35))
			 end
			) RegFormOwnerLabel
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.FormStatusSID
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.FormStatusSID
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.FormStatusSID
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.FormStatusSID
				 else cast(null as int)
			 end
			) RegFormStatusSID
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.FormStatusSCD
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.FormStatusSCD
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.FormStatusSCD
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.FormStatusSCD
				 else cast(null as varchar(25))
			 end
			) RegFormStatusSCD
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.FormStatusLabel
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.FormStatusLabel
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.FormStatusLabel
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.FormStatusLabel
				 else cast(null as nvarchar(35))
			 end
			) RegFormStatusLabel
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.LastStatusChangeTime
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.LastStatusChangeTime
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.LastStatusChangeTime
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.LastStatusChangeTime
				 else cast(null as datetimeoffset(7))
			 end
			) RegFormStatusTime
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.LastStatusChangeUser
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.LastStatusChangeUser
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.LastStatusChangeUser
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.LastStatusChangeUser
				 else cast(null as nvarchar(75))
			 end
			) RegFormStatusUser
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.IsReviewRequired
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.IsReviewRequired
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.IsReviewRequired
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.IsReviewRequired
				 else cast(0 as bit)
			 end
			) RegFormIsReviewRequired
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.InvoiceSID
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.InvoiceSID
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.InvoiceSID
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.InvoiceSID
				 else cast(null as int)
			 end
			) RegFormInvoiceSID
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.TotalDue
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.TotalDue
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.TotalDue
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.TotalDue
				 else cast(0.00 as decimal(11, 2))
			 end
			) RegFormTotalDue
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.TotalPaid
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.TotalPaid
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.TotalPaid
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.TotalPaid
				 else cast(0.00 as decimal(11, 2))
			 end
			) RegFormTotalPaid
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.NextFollowUp
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.NextFollowUp
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.NextFollowUp
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.NextFollowUp
				 else cast(null as date)
			 end
			) NextFollowUp
		 ,(case
				 when rnwCS.RegistrantRenewalSID is not null and rnwCS.FormStatusSCD <> 'WITHDRAWN' then rnwCS.PracticeRegisterSectionSIDTo
				 when rinCS.ReinstatementSID is not null and rinCS.FormStatusSCD <> 'WITHDRAWN' then rinCS.PracticeRegisterSectionSIDTo
				 when rcCS.RegistrationChangeSID is not null and rcCS.FormStatusSCD <> 'WITHDRAWN' then rcCS.PracticeRegisterSectionSIDTo
				 when appCS.RegistrantAppSID is not null and appCS.FormStatusSCD <> 'WITHDRAWN' then appCS.PracticeRegisterSectionSIDTo
				 else cast(null as int)
			 end
			) PracticeRegisterSectionSIDTo
		from
			@LatestRegistration lreg
		left outer join
		(
			select
				cs.RegistrationSID
			 ,cs.RegistrantRenewalSID
			 ,cs.IsFinal
			 ,cs.IsInProgress
			 ,cs.FormOwnerSID
			 ,cs.FormOwnerSCD
			 ,cs.FormOwnerLabel
			 ,cs.FormStatusSID
			 ,cs.FormStatusSCD
			 ,cs.FormStatusLabel
			 ,cs.LastStatusChangeUser
			 ,cs.LastStatusChangeTime
			 ,cs.IsReviewRequired
			 ,cs.NextFollowUp
			 ,cs.PracticeRegisterSectionSIDTo
			 ,cs.InvoiceSID
			 ,cs.TotalPaid
			 ,cs.TotalDue
			from
				dbo.fRegistration#FormStatus$Renewal(@LatestRegistration) cs
		)											rnwCS on lreg.RegistrationSID = rnwCS.RegistrationSID
		left outer join
		(
			select
				cs.RegistrationSID
			 ,cs.ReinstatementSID
			 ,cs.IsFinal
			 ,cs.IsInProgress
			 ,cs.FormOwnerSID
			 ,cs.FormOwnerSCD
			 ,cs.FormOwnerLabel
			 ,cs.FormStatusSID
			 ,cs.FormStatusSCD
			 ,cs.FormStatusLabel
			 ,cs.LastStatusChangeUser
			 ,cs.LastStatusChangeTime
			 ,cs.IsReviewRequired
			 ,cs.NextFollowUp
			 ,cs.PracticeRegisterSectionSIDTo
			 ,cs.InvoiceSID
			 ,cs.TotalPaid
			 ,cs.TotalDue
			from
				dbo.fRegistration#FormStatus$Reinstatement(@LatestRegistration) cs
		)											rinCS on lreg.RegistrationSID = rinCS.RegistrationSID
		left outer join
		(
			select
				cs.RegistrationSID
			 ,cs.RegistrationChangeSID
			 ,cs.IsFinal
			 ,cs.IsInProgress
			 ,cs.FormOwnerSID
			 ,cs.FormOwnerSCD
			 ,cs.FormOwnerLabel
			 ,cs.FormStatusSID
			 ,cs.FormStatusSCD
			 ,cs.FormStatusLabel
			 ,cs.LastStatusChangeUser
			 ,cs.LastStatusChangeTime
			 ,cast(0 as bit) IsReviewRequired
			 ,cs.NextFollowUp
			 ,cs.PracticeRegisterSectionSIDTo
			 ,cs.InvoiceSID
			 ,cs.TotalPaid
			 ,cs.TotalDue
			from
				dbo.fRegistration#FormStatus$RegistrationChange(@LatestRegistration) cs
		)											rcCS on lreg.RegistrationSID	= rcCS.RegistrationSID
		left outer join
		(
			select
				cs.RegistrationSID
			 ,cs.RegistrantAppSID
			 ,cs.IsFinal
			 ,cs.IsInProgress
			 ,cs.FormOwnerSID
			 ,cs.FormOwnerSCD
			 ,cs.FormOwnerLabel
			 ,cs.FormStatusSID
			 ,cs.FormStatusSCD
			 ,cs.FormStatusLabel
			 ,cs.LastStatusChangeUser
			 ,cs.LastStatusChangeTime
			 ,cs.IsReviewRequired
			 ,cs.NextFollowUp
			 ,cs.PracticeRegisterSectionSIDTo
			 ,cs.InvoiceSID
			 ,cs.TotalPaid
			 ,cs.TotalDue
			from
				dbo.fRegistration#FormStatus$Application(@LatestRegistration) cs
		)											appCS on lreg.RegistrationSID = appCS.RegistrationSID
	) z
);
GO
