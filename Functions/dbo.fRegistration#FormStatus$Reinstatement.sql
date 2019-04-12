SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistration#FormStatus$Reinstatement
(
	@LatestRegistration dbo.LatestRegistration readonly -- table of registration keys to lookup status for
)
returns table
/*********************************************************************************************************************************
Function	: Registration Form Status - Reinstatement (current status)
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns the latest form status for a set of reinstatement forms identified by RegistrationSID
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version

Comments	
--------
This table function replicates (exactly) the logic found in the #CurrentStatus function for reinstatement. It is replicated here 
to allow the fRegistration#FormStatus function to call it with the list of registrations for the selected year as a parameter.
This alternate syntax avoids having to call #CurrentStatus for the entire year or one-by-one (cross/outer apply) for individual
form records which is not fast enough for the main registration search.

Maintenance Note
----------------
Any logic change made to this function must also be made in dbo.fReinstatement#CurrentStatus.

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
	dbo.Reinstatement frm
order by
	newid()

insert
	@latestRegistration (RegistrationSID, RegistrantSID)
select
	lReg.RegistrationSID
 ,lReg.RegistrantSID
from
	dbo.fRegistrant#LatestRegistration$SID(-1, @registrationYear) lReg;

select x .* from dbo .fRegistration#FormStatus$Reinstatement(@latestRegistration) x

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
	 @ObjectName = 'dbo.fRegistration#FormStatus$Reinstatement'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		z.ReinstatementSID
	 ,z.RegistrationYear
	 ,z.RegistrationSID
	 ,z.ReinstatementStatusSID
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
			x.ReinstatementSID
		 ,x.RegistrationYear
		 ,x.RegistrationSID
		 ,x.ReinstatementStatusSID
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
				f.ReinstatementSID
			 ,f.RegistrationYear
			 ,f.RegistrationSID
			 ,f.IsAutoApprovalEnabled
			 ,f.IsReviewRequired
			 ,f.NextFollowUp
			 ,f.PracticeRegisterSectionSID				 PracticeRegisterSectionSIDTo
			 ,f.FormVersionSID
			 ,f.RowGUID
			 ,cs.ReinstatementStatusSID
			 ,cs.FormStatusSID
			 ,isnull(cs.UpdateUser, cs.UpdateUser) LastStatusChangeUser -- in case no status recorded, return creator of the record
			 ,isnull(cs.UpdateTime, cs.UpdateTime) LastStatusChangeTime
			 ,f.InvoiceSID
			from
			(
				select
					frm.ReinstatementSID
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
					dbo.Reinstatement frm on lreg.RegistrationSID = frm.RegistrationSID					--|
			) f
			outer apply
			(
				select top (1) -- obtain latest status by create time
					fs.ReinstatementStatusSID
				 ,fs.FormStatusSID
				 ,fs.UpdateTime
				 ,fs.UpdateUser
				from
					dbo.ReinstatementStatus fs	-- status records inserted on each status change
				where
					fs.ReinstatementSID = f.ReinstatementSID
				order by
					fs.CreateTime desc
				 ,fs.ReinstatementStatusSID desc
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
