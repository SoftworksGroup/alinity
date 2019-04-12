SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantEmployment#Supervision
/*********************************************************************************************************************************
View		: Registrant Employment - Supervision
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns consent information for export
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version
				: Tim Edlund					| Oct 2018		| Updated to support configurations where supervisors are not active-members

Comments	
--------
This view provides details of supervisory arrangements on employment.  The view returns active and expired supervisor arrangements.
A status code is derived reporting on whether the agreement is valid. The view includes columns providing the latest registration
information for both the supervisor and employee being supervised.

Note that the application supports a configuration setting indicating whether or not Supervisory relationships must be restricted
to active-members working at the same organization. If that setting is not on, the supervisor relationship is considered valid
as long as it is not expired.

<TestHarness>
  <Test Name = "Random" IsDefault="true" Description="Executes view for registrant selected at random">
    <SQLScript>
    <![CDATA[

declare @registrantSID int;

select top (1)
	@registrantSID = re.RegistrantSID
from
	dbo.EmploymentSupervisor es
join
	dbo.RegistrantEmployment re on es.RegistrantEmploymentSID = re.RegistrantEmploymentSID
order by
	newid();

if @@rowcount = 0 or @registrantSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		x.*
	from
		dbo.vRegistrantEmployment#Supervision x
	where
		x.RegistrantSID = @registrantSID
	order by
		x.EmploymentReportedYear;

end;
    ]]>
    </SQLScript>
    <Assertions>
	    <Assertion Type="ExecutionTime" Value="00:00:02" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vRegistrantEmployment#Supervision'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	rep.RegistrantNo
 ,rep.RegistrantLabel
 ,rep.RegistrationLabel
 ,rep.LatestRegistrationYear
 ,rep.RegistrantIsCurrentlyActive
 ,rep.EmploymentReportedYear
 ,isnull(rlrSup.RegistrantLabel, dbo.fRegistrant#Label(pSup.LastName, pSup.FirstName, pSup.MiddleNames, rSup.RegistrantNo, 'REGISTRANT')) SupervisorRegistrantLabel
 ,es.ExpiryTime																																																														SupervisionExpiryTime
 ,(case
		 when rep.RegistrantIsCurrentlyActive = cast(0 as bit) then 'N/A: Registrant Inactive'
		 when es.ExpiryTime is not null then 'Expired'
		 when cpa.EnforceMemberSupervisors = cast(0 as bit) then 'Valid'
		 when rlrSup.RegistrantIsCurrentlyActive = cast(0 as bit) then 'Invalid: Supervisor Inactive'
		 when reSup.RegistrantEmploymentSID is null then 'Invalid: Different Employers'
		 else 'Valid'
	 end
	)																																																																				AgreementStatus
 ,rep.OrgName
 ,rep.OrgTypeName
 ,rep.OrgTypeCategory
 ,rep.EmployerPracticeHours
 ,rep.EmploymentDirectPhone
 ,rep.EmployerMainPhone
 ,rep.EmployerFaxPhone
 ,rep.EmploymentEffectiveTime
 ,rep.EmploymentExpiryTime
 ,rep.IsEmploymentActive
 ,rlrSup.RegistrantNo																																																											SupervisorRegistrantNo
 ,rlrSup.RegistrantIsCurrentlyActive																																																			SupervisorRegistrantIsCurrentlyActive
	--- standard export columns  -------------------
 ,rep.PracticeRegisterLabel
 ,rep.PracticeRegisterSectionLabel
 ,rep.EmailAddress
 ,rep.FirstName
 ,rep.CommonName
 ,rep.MiddleNames
 ,rep.LastName
 ,rep.PersonLegacyKey
 ,rlrSup.PersonLegacyKey																																																									SupervisorPersonLegacyKey
 ,rep.OrgLegacyKey
 ,rep.RegistrantEmploymentSID
	-- system ID's ---------------------------------
 ,es.EmploymentSupervisorSID
 ,rep.RegistrantSID
 ,rep.RegistrationSID
 ,rep.PersonSID
 ,rep.OrgSID
 ,rlrSup.RegistrantSID																																																										SupervisorRegistrantSID
 ,rlrSup.PersonSID																																																												SupervisorPersonSID
from
	dbo.EmploymentSupervisor					 es
join
	dbo.vRegistrantEmployment#Profile	 rep on es.RegistrantEmploymentSID			 = rep.RegistrantEmploymentSID
join
	sf.Person													 pSup on es.PersonSID										 = pSup.PersonSID
join
	dbo.vConfigParam#Active						 cpa on 1																 = 1
left outer join
	dbo.Registrant										 rSup on es.PersonSID										 = rSup.PersonSID
left outer join
	dbo.vRegistrant#LatestRegistration rlrSup on es.PersonSID									 = rlrSup.PersonSID
left outer join
	dbo.RegistrantEmployment					 reSup on rlrSup.RegistrantSID					 = reSup.RegistrantSID
																							and rep.OrgSID								 = reSup.OrgSID
																							and rep.EmploymentReportedYear = reSup.RegistrationYear;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Provides details on active and expired supervisory agreements. A calculated status code is included showing whether or not the supervisory arrangement is currently valid. |EXPORT+ ^PersonList ^OrgList ^RegistrationList', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantEmployment#Supervision', NULL, NULL
GO
