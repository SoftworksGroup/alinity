SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fMemberPortal#Invoices 
(
@PersonSID int -- key of person to return invoices for
)
returns table
/*********************************************************************************************************************************
Function	: Member Portal - Invoices
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns invoices for display on the Member Portal (for 1 person)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version
				: Russell Poirier			|	Mar 2019		|	Modified where clause to support invoices generated on app submission

Comments	
--------
This table function modularizes the logic required to determine invoices that can be displayed to a user on the Member Portal.

The following invoices are excluded:

	1) Cancelled invoices

	2) Invoices attached to renewals, applications, reinstatements, registration changes where the status is not APPROVED.  This is 
		 necessary to prevent payment of adjusted in advance of the renewal/other form begin completed by the member.

	3) Invoices attached to renewals when the renewal period is not open.  These are "stale" invoices that administrators will 
		 cancel so the application needs to ensure they are not paid after the renewal period has closed.

Note that ad hoc invoices (not related to a registration form) are always considered to be in an APPROVED status.

A sproc override for this function exists as: pMemberPortal#GetInvoices

Limitations
-----------
Although reinstatement also has an open period, the function will include a reinstatement invoice after the period has closed
since business practice allows members to pay that invoice.  Renewal is not possible until the reinstatement has been paid
and the associated registration created.

Example
-------
<TestHarness>
	<Test Name = "Random" IsDefault = "true" Description="Selects dataset for a person with at least one non-cancelled
	invoice selected at random.">
		<SQLScript>
			<![CDATA[
declare @personSID int;

select top (1)
	@personSID = i.PersonSID
from
	dbo.Invoice i
where
	i.CancelledTime is null
order by
	newid();

if @@rowcount = 0 or @personSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin
	select * from		dbo.fMemberPortal#Invoices(@personSID);
end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fMemberPortal#Invoices'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		z.InvoiceSID
	 ,z.CreateTime
	 ,z.InvoiceTypeSCD
	 ,z.FormStatusSCD
	 ,it.TotalAfterTax
	 ,it.TotalDue
	 ,it.IsPaid
	 ,(case
			 when z.IsPAPSubscriber = cast(1 as bit) and z.IsPAPEnabled = cast(1 as bit) then cast(1 as bit)
			 else cast(0 as bit)
		 end
		) IsPADPending
	 ,z.RegistrantAppSID
	 ,z.RegistrantRenewalSID
	 ,z.ReinstatementSID
	 ,z.RegistrationChangeSID
	 ,z.RenewalRegistrationYear
	from
	(
		select
			x.InvoiceSID
		 ,x.CreateTime
		 ,(case
				 when ra.RegistrantAppSID is not null then 'APPLICATION'
				 when rr.RegistrantRenewalSID is not null then 'RENEWAL'
				 when rin.ReinstatementSID is not null then 'REINSTATEMENT'
				 when rc.RegistrationChangeSID is not null then 'REGISTRATION.CHANGE'
				 else 'AD.HOC'
			 end
			)										InvoiceTypeSCD
		 ,(case
				 when ra.RegistrantAppSID is not null then racs.FormStatusSCD
				 when rr.RegistrantRenewalSID is not null then rrcs.FormStatusSCD
				 when rin.ReinstatementSID is not null then rincs.FormStatusSCD
				 when rc.RegistrationChangeSID is not null then rccs.FormStatusSCD
				 else cast('APPROVED' as varchar(25)) -- ad hoc invoices are always considered approved
			 end
			)										FormStatusSCD
		 ,ra.RegistrantAppSID
		 ,rr.RegistrantRenewalSID
		 ,rin.ReinstatementSID
		 ,rc.RegistrationChangeSID
		 ,rr.RegistrationYear RenewalRegistrationYear
		 ,(case
				 when rr.RegistrantRenewalSID is not null then dbo.fRenewalPeriod#IsOpen(r.RegistrantSID, rr.RegistrationYear)
				 else cast(1 as bit)
			 end
			)										IsPayable
		 ,cast((
						 select
								count(1)
						 from
								dbo.PAPSubscription ps
						 where
							 ps.PersonSID = @PersonSID and sf.fIsActive(ps.EffectiveTime, ps.CancelledTime) = cast(1 as bit)
					 ) as bit)			IsPAPSubscriber
		 ,(case
				 when sf.fNow() between rsy.PAPBlockStartTime and rsy.PAPBlockEndTime then cast(0 as bit)
				 else cast(1 as bit)
			 end
			)										IsPAPEnabled	--# Indicates whether use of pre-authorized balances to pay invoices is enabled (based on schedule)
		from
		(
			select
				i.InvoiceSID
			 ,i.CreateTime
			from
				dbo.Invoice i
			where
				i.PersonSID = @PersonSID and i.CancelledTime is null	-- isolate non-cancelled invoices for this person
		)																																	 x
		join
			dbo.RegistrationSchedule																				 rs on rs.IsDefault = cast(1 as bit)
		left outer join
			dbo.RegistrantApp																								 ra on x.InvoiceSID = ra.InvoiceSID
		outer apply dbo.fRegistrantApp#CurrentStatus(ra.RegistrantAppSID, -1) racs
		left outer join
			dbo.RegistrantRenewal																										 rr on x.InvoiceSID = rr.InvoiceSID
		outer apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) rrcs
		left outer join
			dbo.Reinstatement																								 rin on x.InvoiceSID = rin.InvoiceSID
		outer apply dbo.fReinstatement#CurrentStatus(rin.ReinstatementSID, -1) rincs
		left outer join
			dbo.RegistrationChange																										rc on x.InvoiceSID = rc.InvoiceSID
		outer apply dbo.fRegistrationChange#CurrentStatus(rc.RegistrationChangeSID, -1) rccs
		left outer join
			dbo.RegistrationScheduleYear																		 rsy on rs.RegistrationScheduleSID = rsy.RegistrationScheduleSID and rsy.RegistrationYear = rr.RegistrationYear
		left outer join
			dbo.Registrant r on r.PersonSID = @PersonSID
	)																						 z
	outer apply dbo.fInvoice#Total(z.InvoiceSID) it
	where
		(z.FormStatusSCD = 'APPROVED' or (z.FormStatusSCD = 'SUBMITTED' and z.InvoiceTypeSCD = 'APPLICATION')) -- invoice must be approved to be included in the display or if application submitted
		and (it.IsPaid = 1 or z.IsPayable = cast(1 as bit))	-- renewal invoices are only payable within the open renewal period  
);
GO
