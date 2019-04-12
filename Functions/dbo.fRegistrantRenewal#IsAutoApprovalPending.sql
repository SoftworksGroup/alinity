SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantRenewal#IsAutoApprovalPending
(
	@RegistrantRenewalSID int -- key of record to return status information for or -1 for all
)
returns bit
as
/*********************************************************************************************************************************
Function: Renewal - Is Auto Approval Pending
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns bit indicating whether pending form will be approved without administrator review
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This function calculates the IsAutoApprovalPending bit to identify whether the Renewal can be automatically approved. The 
value is used in the SUBMIT process to avoid duplicate posting (on SUBMITTED and APPROVED) where the submission process will be 
followed immediately by approval.  

Example
-------
<TestHarness>
	<Test Name="AllForYear" Description="Returns the calculated result for all form records in a year selected at random.">
		<SQLScript>
			<![CDATA[

declare @registrationYear smallint;

select top (1)
	@registrationYear = frm.RegistrationYear
from
	dbo.RegistrantRenewal frm
order by
	newid();

if @@rowcount = 0 or @registrationYear is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select
		x.RegistrantRenewalSID
	 ,dbo.fRegistrantRenewal#IsAutoApprovalPending(x.RegistrantRenewalSID) IsAutoApprovalPending
	from
		dbo.RegistrantRenewal x
	where
		x.RegistrationYear = @registrationYear;
end;

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:10"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fRegistrantRenewal#IsAutoApprovalPending'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@isAutoApprovalPending bit				-- return value
	 ,@now									 datetime;	-- current time in user time zone

	select
		@isAutoApprovalPending =
		(case
			 when r.IsRenewalAutoApprovalBlocked = cast(1 as bit) then cast(0 as bit)																												 -- block if registrant is blocked
			 when cs.FormStatusSCD <> 'SUBMITTED' and cs.FormStatusSCD <> 'CORRECTED' and cs.FormStatusSCD <> 'UNLOCKED' then cast(0 as bit) -- block based on form status
			 when dbo.fRegistrant#HasOpenAudit(r.RegistrantSID) = cast(1 as bit) then cast(0 as bit)																				 -- block if audit is open
			 when datediff(minute, rsy.RenewalEndTime, @now) > 30 then cast(0 as bit)																												 -- if more than 30 minutes passed end of renewal - block
			 else frm.IsAutoApprovalEnabled
		 end
		)
	from
		dbo.RegistrantRenewal				 frm
	join
		dbo.Registration						 reg on frm.RegistrationSID = reg.RegistrationSID
	join
		dbo.PracticeRegisterSection	 prs on frm.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister				 pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
	join
		dbo.RegistrationScheduleYear rsy on pr.RegistrationScheduleSID = rsy.RegistrationScheduleSID and rsy.RegistrationYear = frm.RegistrationYear
	join
		dbo.Registrant							 r on reg.RegistrantSID = r.RegistrantSID
	outer apply
	(
		select top (1) -- obtain latest status by create time
			fs.FormStatusSCD
		from
			dbo.RegistrantRenewalStatus frmSt -- status records inserted on each status change
		join
			sf.FormStatus								fs on frmSt.FormStatusSID = fs.FormStatusSID
		where
			frmSt.RegistrantRenewalSID = frm.RegistrantRenewalSID
		order by
			frmSt.CreateTime desc
		 ,frmSt.RegistrantRenewalStatusSID desc
	)															 cs
	where
		frm.RegistrantRenewalSID = @RegistrantRenewalSID;

	return (@isAutoApprovalPending);
end;
GO
