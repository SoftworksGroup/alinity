SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistration#FormStatus$Renewal
(
	@LatestRegistration dbo.LatestRegistration readonly -- table of registration keys to lookup status for
)
returns table
/*********************************************************************************************************************************
Function	: Registration Form Status - Renewal (current status)
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the latest form status for a set of renewal forms identified by RegistrationSID
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version
				: Cory Ng							| Dec 2018		| Updated IsReviewRequired bit to check if auto approval is blocked and the form
																						| has been validated

Comments	
--------
This table function replicates (exactly) the logic found in the #CurrentStatus function for renewal. It is replicated here 
to allow the fRegistration#FormStatus function to call it with the list of registrations for the selected year as a parameter.
This alternate syntax avoids having to call #CurrentStatus for the entire year or one-by-one (cross/outer apply) for individual
form records which is not fast enough for the main registration search.

Maintenance Note
----------------
Any logic change made to this function must also be made in dbo.fRegistrantRenewal#CurrentStatus.

Example
-------
<TestHarness>
	<Test Name = "ForYear" IsDefault = "true" Description="Selects dataset for all forms in a year selected at random.">
		<SQLScript>
			<![CDATA[
declare
	@registrationYear		smallint
 ,@latestRegistration dbo.LatestRegistration

select top (1)
	@registrationYear = frm.RegistrationYear
from
	dbo.RegistrantRenewal frm
order by
	newid()

insert
	@latestRegistration (RegistrationSID, RegistrantSID)
select
	lReg.RegistrationSID
 ,lReg.RegistrantSID
from
	dbo.fRegistrant#LatestRegistration$SID(-1, @registrationYear - 1) lReg;

select x .* from dbo .fRegistration#FormStatus$Renewal(@latestRegistration) x
option (recompile)

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
			<Assertion Type="ExecutionTime" Value="00:00:15" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistration#FormStatus$Renewal'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		z.RegistrantRenewalSID
	 ,z.RegistrationYear
	 ,z.RegistrationSID
	 ,z.RegistrantRenewalStatusSID
	 ,z.IsFinal
	 ,z.IsInProgress
	 ,fo.FormOwnerSID
	 ,z.FormOwnerSCD
	 ,fo.FormOwnerLabel
	 ,fs.FormStatusSID
	 ,z.FormStatusSCD
	 ,(case
			 when fs.FormStatusSCD = 'APPROVED' and z.IsUnPaid = cast(1 as bit) then fs.FormStatusLabel + ' (not paid)'
			 else fs.FormStatusLabel
		 end
		)																																											 FormStatusLabel
	 ,z.LastStatusChangeUser
	 ,z.LastStatusChangeTime
	 ,z.IsAutoApprovalEnabled
	 ,(case when fs.IsFinal = cast(1 as bit) then cast(0 as bit)else z.IsReviewRequired end) IsReviewRequired -- finalized forms do not require review
	 ,z.NextFollowUp
	 ,z.PracticeRegisterSectionSIDTo
	 ,z.FormVersionSID
	 ,z.RowGUID
	 ,z.InvoiceSID
	 ,z.TotalAfterTax
	 ,z.TotalPaid
	 ,z.TotalDue
	 ,z.IsUnPaid
	 ,z.IsPaid
	 ,z.IsOverPaid
	from
	(
		select
			x.RegistrantRenewalSID
		 ,x.RegistrationYear
		 ,x.RegistrationSID
		 ,x.RegistrantRenewalStatusSID
		 ,fs.IsFinal
		 ,cast((case when fs.IsFinal = cast(1 as bit) then 0 else 1 end) as bit) IsInProgress
		 ,(case
				 when fo.FormOwnerSCD is null then 'REGISTRANT'
				 when fs.FormStatusSCD = 'APPROVED' and it.IsUnPaid = cast(1 as bit) then 'REGISTRANT'
				 when fo.FormOwnerSCD = 'ASSIGNEE' then 'REGISTRANT'
				 else fo.FormOwnerSCD
			 end
			)																																			 FormOwnerSCD
		 ,isnull(fs.FormStatusSCD, 'NEW')																				 FormStatusSCD
		 ,x.LastStatusChangeUser
		 ,x.LastStatusChangeTime
		 ,x.IsAutoApprovalEnabled
		 ,x.IsReviewRequired
		 ,x.NextFollowUp
		 ,x.PracticeRegisterSectionSIDTo
		 ,x.FormVersionSID
		 ,x.RowGUID
		 ,x.InvoiceSID
		 ,it.TotalAfterTax	-- invoice details:
		 ,it.TotalPaid
		 ,it.TotalDue
		 ,it.IsUnPaid
		 ,it.IsPaid
		 ,it.IsOverPaid
		from
		(
			select
				f.RegistrantRenewalSID
			 ,f.RegistrationYear
			 ,f.RegistrationSID
			 ,f.IsAutoApprovalEnabled
			 ,f.IsReviewRequired
			 ,f.NextFollowUp
			 ,f.PracticeRegisterSectionSID				 PracticeRegisterSectionSIDTo
			 ,f.FormVersionSID
			 ,f.RowGUID
			 ,cs.RegistrantRenewalStatusSID
			 ,cs.FormStatusSID
			 ,isnull(cs.UpdateUser, cs.UpdateUser) LastStatusChangeUser -- in case no status recorded, return creator of the record
			 ,isnull(cs.UpdateTime, cs.UpdateTime) LastStatusChangeTime
			 ,f.InvoiceSID
			from
			(
				select
					frm.RegistrantRenewalSID
				 ,frm.RegistrationYear
				 ,frm.RegistrationSID
				 ,case when frm.IsAutoApprovalEnabled = cast(0 as bit) and frm.LastValidateTime is not null then cast(0 as bit) else cast(1 as bit) end				 IsAutoApprovalEnabled
				 ,case when frm.IsAutoApprovalEnabled = cast(0 as bit) and frm.LastValidateTime is not null then cast(1 as bit) else cast(0 as bit) end				 IsReviewRequired
				 ,frm.NextFollowUp
				 ,frm.FormVersionSID
				 ,frm.RowGUID
				 ,frm.InvoiceSID
				 ,frm.PracticeRegisterSectionSID
				from
					@LatestRegistration lReg																										--| Only these lines differ from the #CurrentStatus version
				join																																					--|
					dbo.RegistrantRenewal frm on lreg.RegistrationSID = frm.RegistrationSID			--|
			) f
			outer apply
			(
				select top (1) -- obtain latest status by create time
					fs.RegistrantRenewalStatusSID
				 ,fs.FormStatusSID
				 ,fs.UpdateTime
				 ,fs.UpdateUser
				from
					dbo.RegistrantRenewalStatus fs	-- status records inserted on each status change
				where
					fs.RegistrantRenewalSID = f.RegistrantRenewalSID
				order by
					fs.CreateTime desc
				 ,fs.RegistrantRenewalStatusSID desc
			) cs
		)																						 x
		left outer join
			sf.FormStatus															 fs on x.FormStatusSID = fs.FormStatusSID
		left outer join
			sf.FormOwner															 fo on fs.FormOwnerSID = fo.FormOwnerSID
		outer apply dbo.fInvoice#Total(x.InvoiceSID) it
	)								z
	join
		sf.FormOwner	fo on z.FormOwnerSCD	= fo.FormOwnerSCD
	join
		sf.FormStatus fs on z.FormStatusSCD = fs.FormStatusSCD
);
GO
