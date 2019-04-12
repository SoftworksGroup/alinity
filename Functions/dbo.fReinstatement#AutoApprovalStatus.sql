SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fReinstatement#AutoApprovalStatus (@RegistrationSID int) -- key of registration to return auto-approval information for
returns table
/*********************************************************************************************************************************
Function	: Reinstatement - Auto Approval Status
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns information necessary to assess auto-approval readiness of renewal records
----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2018		|	Initial version

Comments	
--------
This function calculates whether the current form is blocked from auto-approval and if auto-approval is pending.  Note that if 
the form is ineligible for auto-approval because of its status (e.g. it is CORRECTED, UNLOCKED etc.) or the window of time when
registration can be applied has passed, then the form is not considered blocked but auto-approval is still not pending. It is
possible then, for both the status bit to be OFF. The function returns other columns to provide explanation when auto-approval 
is not enabled.  

In addition to status, time and system reasons, auto-approval may also be blocked by rules built into the client's form design.  
The system rules for blocking auto-approval for Renewal and Reinstatement forms are shared. For example, if a member is 
blocked from automatic approval on their renewal forms, their reinstatement forms are also blocked from auto-approving.

Example
-------
<TestHarness>
	<Test Name="One" Description="returns 1 record at random from the table function">
		<SQLScript>
			<![CDATA[
declare @registrationSID int;

select top (1)
	@registrationSID = rin.RegistrationSID
from
	dbo.Reinstatement rin
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select
		*
	from
		dbo.fReinstatement#AutoApprovalStatus(@registrationSID);

end;


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
				dbo.Reinstatement rin
			cross apply
				dbo.fReinstatement#AutoApprovalStatus(rin.registrationSID);

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
	@ObjectName = 'dbo.fReinstatement#AutoApprovalStatus'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		cast(case when x.IsFinal = cast(1 as bit) then 0 else coalesce(rsnS.ReasonSID, rsnF.ReasonSID, 0) end as bit) IsAutoApprovalBlocked
	 ,case when x.IsFinal = cast(1 as bit) then cast(null as int)else isnull(rsnS.ReasonSID, rsnF.ReasonSID) end		ReasonSID
	 ,case
			when x.IsFinal = cast(1 as bit) then cast(null as varchar(25))
			else isnull(rsnS.ReasonCode, rsnF.ReasonCode)
		end																																																						ReasonCode
	 ,case
			when x.IsFinal = cast(1 as bit) then cast(null as nvarchar(50))
			else isnull(rsnS.ReasonName, rsnF.ReasonName)
		end																																																						ReasonName
	 ,x.HasOpenAudit
	 ,(case
			 when x.SystemReasonCode is not null then 0																					 -- not pending if registrant is blocked
			 when x.FormStatusSCD not in ('SUBMITTED', 'CORRECTED', 'UNLOCKED') then 0					 -- not pending when status is not eligible
			 when x.HasOpenAudit = cast(1 as bit) then 0																				 -- not pending if audit is open
			 when datediff(minute, rsy.ReinstatementEndTime, sf.fNow()) > 30 then cast(0 as bit) -- not pending if more than 30 minutes passed end of reinstatement window
			 else rin.IsAutoApprovalEnabled																											 -- otherwise auto-approval is based on rules within the form
		 end
		)																																																							IsAutoApprovalPending
	from
	(
		select
			rin.ReasonSID
		 ,cs.IsFinal
		 ,cs.FormStatusSCD
		 ,r.RegistrantSID
		 ,rin.ReinstatementSID
		 ,dbo.fRegistrant#HasOpenAudit(r.RegistrantSID) HasOpenAudit
		 ,cast(case
						 when r.IsRenewalAutoApprovalBlocked = cast(1 as bit) then 'RENEWAL.AA.REGISTRANT'					 -- block if registrant is blocked
						 when dbo.fRegistrant#HasOpenAudit(r.RegistrantSID) = cast(1 as bit) then 'RENEWAL.AA.AUDIT' -- block if audit is open
						 else null																																									 -- reason expected to be ON FORM
					 end as varchar(25))											SystemReasonCode
		from
			dbo.Registration rl
		join
			dbo.Registrant				r on rl.RegistrantSID = r.RegistrantSID
		outer apply (
									select top (1)
										rin.ReinstatementSID
									 ,rin.ReasonSID
									from
										dbo.Reinstatement rin
									where
										rin.RegistrationSID = @RegistrationSID
									order by
										rin.CreateTime desc
									 ,rin.ReinstatementSID desc
								)						rin
		outer apply dbo.fReinstatement#CurrentStatus(rin.ReinstatementSID, -1) cs
		where
			rl.RegistrationSID = @RegistrationSID
	)															 x
	join
		dbo.RegistrationSchedule		 rs on rs.IsDefault								 = cast(1 as bit)
	left outer join
		dbo.Reinstatement						 rin on x.ReinstatementSID				 = rin.ReinstatementSID
	left outer join
		dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID = rsy.RegistrationScheduleSID
																				and rsy.RegistrationYear	 = rin.RegistrationYear
	left outer join
		dbo.Reason									 rsnF on x.ReasonSID							 = rsnF.ReasonSID
	left outer join
		dbo.Reason									 rsnS on x.SystemReasonCode				 = rsnS.ReasonCode
);
GO
