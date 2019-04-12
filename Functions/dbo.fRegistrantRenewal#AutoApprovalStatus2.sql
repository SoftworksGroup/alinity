SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantRenewal#AutoApprovalStatus2 (@RegistrationSID int) -- key of renewal to return auto-approval information for
returns table
/*********************************************************************************************************************************
Function: Registrant Renewal - Auto Approval Status
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns information necessary to assess auto-approval readiness of renewal records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Oct 2017			|	Initial Version
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

				declare @registrationSID int;

				select top 1
					@registrationSID = rr.registrationSID
				from
					dbo.RegistrantRenewal rr
				order by
					newid();

				select
					*
				from
					dbo.fRegistrantRenewal#AutoApprovalStatus2(@registrationSID);

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
				dbo.fRegistrantRenewal#AutoApprovalStatus2(rr.registrationSID);

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
	@ObjectName = 'dbo.fRegistrantRenewal#AutoApprovalStatus2'
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
	from
	(
		select
			rr.ReasonSID
		 ,cs.IsFinal
		 ,cast(case
					 when r.IsRenewalAutoApprovalBlocked = cast(1 as bit) then 'RENEWAL.AA.REGISTRANT'					 -- block if registrant is blocked
					 when dbo.fRegistrant#HasOpenAudit(r.RegistrantSID) = cast(1 as bit) then 'RENEWAL.AA.AUDIT' -- block if audit is open
					 else null																																									 -- reason expected to be from form
					 end as varchar(25)) SystemReasonCode
		from
			dbo.Registration rl
		join
			dbo.Registrant																													 r on rl.RegistrantSID = r.RegistrantSID
		outer apply
		(
			select top 1
				rr.RegistrantRenewalSID
			 ,rr.ReasonSID
			from
				dbo.RegistrantRenewal rr
			where
				rr.RegistrationSID = @RegistrationSID
			order by
				rr.CreateTime desc
		)												rr
		outer apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) cs
		where
			rl.RegistrationSID = @RegistrationSID
	)						 x
	left outer join
		dbo.Reason rsnF on x.ReasonSID				= rsnF.ReasonSID
	left outer join
		dbo.Reason rsnS on x.SystemReasonCode = rsnS.ReasonCode
);
GO
