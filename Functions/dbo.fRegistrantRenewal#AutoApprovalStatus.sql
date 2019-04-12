SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantRenewal#AutoApprovalStatus (@RegistrantRenewalSID int) -- key of renewal to return auto-approval information for
returns table
/*********************************************************************************************************************************
Function: Registrant Renewal - Auto Approval Status
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns information necessary to assess auto-approval readiness of renewal records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Sep 2017			|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function calculates the IsAutoApprovalPending bit to identify whether a renewal record can be automatically approved. Other
columns are returned in the function to support explanation when auto-approval is not enabled.  The function is used instead of 
the main vRegistrantRenewal when processing auto-approval operations. 

Example
-------
<TestHarness>
	<Test Name="One" Description="returns 1 record at random from the view">
		<SQLScript>
			<![CDATA[

				declare @registrantRenewalSID int;

				select top 1
					@registrantRenewalSID = rr.RegistrantRenewalSID
				from
					dbo.RegistrantRenewal rr
				order by
					newid();

				select
					*
				from
					dbo.fRegistrantRenewal#AutoApprovalStatus(@registrantRenewalSID);

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
				*
			from
				dbo.RegistrantRenewal rr
			cross apply
				dbo.fRegistrantRenewal#AutoApprovalStatus(rr.RegistrantRenewalSID);

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
  @ObjectName = 'dbo.fRegistrantRenewal#AutoApprovalStatus'
 ,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		x.RegistrantRenewalSID
	 ,x.RegistrantSID
	 ,x.RegistrationYear
	 ,x.FormStatusSID
	 ,x.FormStatusSCD
	 ,x.FormStatusLabel
	 ,x.FormOwnerSCD
	 ,x.FormOwnerLabel
	 ,x.FormIsFinal
	 ,x.LastStatusChangeUser CreateUser
	 ,x.LastStatusChangeTime CreateTime
	 ,x.InvoiceSID
	 ,x.IsRenewalAutoApprovalBlocked
	 ,x.IsAutoApprovalEnabled
	 ,x.HasOpenAudit
	 ,x.RenewalEndTime
	 ,isnull(rsnS.ReasonSID, x.ReasonSID)		ReasonSID
	 ,isnull(rsnS.ReasonCode, x.ReasonCode) ReasonCode
	 ,isnull(rsnS.ReasonName, x.ReasonName) ReasonName
	 ,x.SystemReasonCode
	 ,x.IsAutoApprovalPending
	from
	(
		select
			rr.RegistrantRenewalSID
		 ,rl.RegistrantSID
		 ,rr.RegistrationYear
		 ,rrcs.FormStatusSID
		 ,rrcs.FormStatusSCD
		 ,rrcs.FormStatusLabel
		 ,rrcs.FormOwnerSCD
		 ,rrcs.FormOwnerLabel
		 ,rrcs.IsFinal																	FormIsFinal
		 ,rrcs.LastStatusChangeUser
		 ,rrcs.LastStatusChangeTime
		 ,rr.InvoiceSID
		 ,r.IsRenewalAutoApprovalBlocked
		 ,rr.IsAutoApprovalEnabled
		 ,dbo.fRegistrant#HasOpenAudit(r.RegistrantSID) HasOpenAudit
		 ,rsy.RenewalEndTime
		 ,rsnF.ReasonSID
		 ,rsnF.ReasonCode
		 ,rsnF.ReasonName
		 ,cast(case
						 when r.IsRenewalAutoApprovalBlocked = cast(1 as bit) then 'RENEWAL.AA.REGISTRANT'					 -- block if registrant is blocked
						 when dbo.fRegistrant#HasOpenAudit(r.RegistrantSID) = cast(1 as bit) then 'RENEWAL.AA.AUDIT' -- block if audit is open
						 when datediff(minute, rsy.RenewalEndTime, sf.fNow()) > 30 then 'RENEWAL.AA.LATE'						 -- if more than 30 minutes passed end of renewal - block
						 when rr.IsAutoApprovalEnabled = cast(0 as bit) and rsnF.ReasonSID is null and rrcs.LastStatusChangeTime < rsy.RenewalGeneralOpenTime then
							 'RENEWAL.AA.TOO.EARLY'																																		 -- if time changed to move the renewal start later - edge case
						 else null																																									 -- reason expected to be from form
					 end as varchar(25))											SystemReasonCode
		 ,(case
				 when r.IsRenewalAutoApprovalBlocked = cast(1 as bit) then cast(0 as bit)																															 -- block if registrant is blocked
				 when rrcs.FormStatusSCD <> 'SUBMITTED' and rrcs.FormStatusSCD <> 'CORRECTED' and rrcs.FormStatusSCD <> 'UNLOCKED' then cast(0 as bit) -- block based on form status
				 when dbo.fRegistrant#HasOpenAudit(r.RegistrantSID) = cast(1 as bit) then cast(0 as bit)																							 -- block if audit is open
				 when datediff(minute, rsy.RenewalEndTime, sf.fNow()) > 30 then cast(0 as bit)																												 -- if more than 30 minutes passed end of renewal - block
				 else rr.IsAutoApprovalEnabled
			 end
			)																							IsAutoApprovalPending
		from
			dbo.RegistrantRenewal																																	 rr
		join
			dbo.Registration																																	 rl on rr.RegistrationSID = rl.RegistrationSID
		join
			dbo.PracticeRegisterSection																														 prs on rr.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
		join
			dbo.PracticeRegister																																	 pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
		join
			dbo.RegistrationScheduleYear																													 rsy on pr.RegistrationScheduleSID = rsy.RegistrationScheduleSID and rsy.RegistrationYear = rr.RegistrationYear
		join
			dbo.Registrant																																				 r on rl.RegistrantSID = r.RegistrantSID
		join
			sf.FormVersion																																				 fv on rr.FormVersionSID = fv.FormVersionSID
		join
			sf.Form																																								 f on fv.FormSID = f.FormSID
		cross apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) rrcs
		left outer join
			dbo.Reason rsnF on rr.ReasonSID = rsnF.ReasonSID
		where
			rr.RegistrantRenewalSID = @RegistrantRenewalSID
	)						 x
	left outer join
		dbo.Reason rsnS on x.SystemReasonCode = rsnS.ReasonCode
);

GO
