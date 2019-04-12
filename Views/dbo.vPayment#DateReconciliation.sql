SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPayment#DateReconciliation]
/*********************************************************************************************************************************
View		: Payment Date Reconciliation
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns analysis on agreement between entry date, deposit date, GL posting date and verified times
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Oct	2017		|	Initial Version
				: Tim Edlund	| Jan 2018		| Simplified logic returning default deposit and posting dates to rely on table column except 
																			for online payments (payment type = PP.%')
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This view supports a report where date values on payment records do not agree with their default or typical settings. Follow-up
on the discrepancies is required.  In most cases the discrepancies can be resolved with utility procedures recommended in the
"comment" columns returned by the view.

A description of each potential problem scenario identified by the view is provided in the Comment column below.

Call Syntax
-----------

select
	pdr.PaymentTypeLabel
 ,pdr.DepositAccount
 ,pdr.RegistrantLabel
 ,pdr.PaymentID
 ,pdr.TransactionID
 ,pdr.EnteredDate
 ,pdr.GLPostingDate
 ,pdr.DefaultGLPostingDate
 ,pdr.LatestVerifiedTime
 ,pdr.IsPaid
 ,pdr.LatestIsPaid
 ,pdr.AmountPaid
 ,pdr.LatestChargeTotal
 ,ltrim((case when pdr.PaidStatusComment <> 'ok' then pdr.PaidStatusComment else '' end)
	+ (case when pdr.GLPostingDateComment <> 'ok' then char(13) + char(10) + pdr.GLPostingDateComment else '' end)
	+ (case when pdr.DepositDateComment <> 'ok' then char(13) + char(10) + pdr.DepositDateComment else '' end)
	+ (case when pdr.VerifiedTimeComment <> 'ok' then char(13) + char(10) + pdr.VerifiedTimeComment else '' end)) Comments
from
	dbo.vPayment#DateReconciliation pdr
 ------------------------------------------------------------------------------------------------------------------------------- */
as
select
	x.PaymentTypeLabel
 ,x.RegistrantLabel
 ,x.PaymentCard
 ,x.NameOnCard
 ,x.PaymentID
 ,x.TransactionID
 ,x.CreateTime
 ,x.DepositAccount
 ,x.AmountPaid
 ,x.LatestChargeTotal
 ,x.EnteredBy
 ,x.EnteredDate
 ,x.UpdatedBy
 ,x.UpdatedDate
 ,x.GLPostingDate
 ,x.DefaultGLPostingDate
 ,x.DepositDate
 ,x.DefaultDepositDate
 ,x.UpdateTime
 ,x.VerifiedTime
 ,x.LatestVerifiedTime
 ,x.IsPaid
 ,x.LatestIsPaid
 ,x.PaymentTypeSCD
 ,(case
		 when x.IsPaid <> x.LatestIsPaid or (x.IsOnlinePayment = cast(1 as bit) and x.AmountPaid <> x.LatestChargeTotal) then -- paid amount and charge amount don't agree for online payments)then
			 'Paid status or amount paid does not agree with latest status returned from the card processor. Manual update of processor verification information required.'
		 else 'ok'
	 end) PaidStatusComment
 ,(case
		 when x.GLPostingDate is null and x.IsPaid = cast(1 as bit) and x.AmountPaid = 0.00 then 'Payment is approved but $0. Cancel the payment to correct.'
		 when x.GLPostingDate is null and x.IsPaid = cast(1 as bit) then 'No GL transactions found for this approved payment.  Run "GL Repost" to correct.'
		 when x.IsOnlinePayment = cast(1 as bit) and sf.fIsDifferent(x.GLPostingDate, x.DefaultGLPostingDate) = cast(1 as bit) then
			 'GL posting date does not match latest verified time (for card payments) or last update time (for other payments). Run "GL Repost" to correct.'
		 when x.DefaultGLPostingDate <> x.GLPostingDate then 'GL posting date does not match default GL posting date. Run "GL Repost" to correct.'
		 else 'ok'
	 end) GLPostingDateComment
 ,(case
		 when x.DepositDate is null and x.GLPostingDate is not null and x.IsPaid = cast(1 as bit) and x.AmountPaid = 0.00 then
			 'Payment is approved but $0. Cancel the payment to correct.'
		 when x.DepositDate is null and x.GLPostingDate is not null and x.IsPaid = cast(1 as bit) then
			 'No deposit date is assigned for approved payment. Run "GL Repost" to correct.'
		 when left(x.PaymentTypeSCD, 3) = 'PP.' and sf.fIsDifferent(x.DepositDate, x.DefaultDepositDate) = cast(1 as bit) then
			 'Deposit date does not match GL Posting date + lag days for the payment type.  Run "GL Repost" to correct for card payments, edit manually for others.'
		 else 'ok'
	 end) DepositDateComment
 ,(case
		 when left(x.PaymentTypeSCD, 3) = 'PP.' and sf.fIsDifferent(x.VerifiedTime, x.LatestVerifiedTime) = cast(1 as bit) then
			 'Verified time does not match latest verified time returned by the card processor.  Run "GL Repost" to correct.'
		 else 'ok'
	 end) VerifiedTimeComment
from
( select
		pt.PaymentTypeLabel
	 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'REGISTRATION')										RegistrantLabel
	 ,cast(case when left(pt.PaymentTypeSCD, 3) = 'PP.' then 1 else 0 end as bit)																			IsOnlinePayment
	 ,pmt.PaymentCard
	 ,pmt.NameOnCard
	 ,pmt.PaymentSID																																																	PaymentID
	 ,upper(pmt.TransactionID)																																												TransactionID
	 ,pmt.CreateTime
	 ,pmt.GLAccountCode + ' - ' + (isnull(ga.GLAccountLabel, '[Removed]'))																						DepositAccount
	 ,pmt.AmountPaid
	 ,ppr.LatestChargeTotal
	 ,pmt.CreateUser																																																	EnteredBy
	 ,sf.fDTOffsetToClientDate(pmt.CreateTime)																																				EnteredDate
	 ,pmt.UpdateUser																																																	UpdatedBy
	 ,sf.fDTOffsetToClientDate(pmt.UpdateTime)																																				UpdatedDate
	 ,gt.GLPostingDate
	 ,(case
			 when ps.IsPaid = cast(0 as bit) then cast(null as date)
			 when left(pt.PaymentTypeSCD, 3) = 'PP.' then cast(ppr.LatestVerifiedTime as date)
			 else isnull(pmt.GLPostingDate, cast(pmt.CreateTime as date))
		 end)																																																						DefaultGLPostingDate
	 ,pmt.DepositDate																																																	DepositDate
	 ,(case
			 when ps.IsPaid = cast(0 as bit) then cast(null as date)
			 when left(pt.PaymentTypeSCD, 3) = 'PP.' then dateadd(day, pt.DepositDateLagDays, cast(ppr.LatestVerifiedTime as date))
			 else isnull(pmt.DepositDate, dateadd(day, pt.DepositDateLagDays,cast(pmt.CreateTime as date)))
		 end)																																																						DefaultDepositDate
	 ,pmt.UpdateTime
	 ,pmt.VerifiedTime
	 ,(case
			 when ppr.LatestIsPaid = cast(0 as bit) or left(pt.PaymentTypeSCD, 3) <> 'PP.' then cast(null as datetime)
			 else ppr.LatestVerifiedTime
		 end)																																																						LatestVerifiedTime
	 ,ps.IsPaid
	 ,(case when left(pt.PaymentTypeSCD, 3) = 'PP.' then isnull(ppr.LatestIsPaid, cast(0 as bit)) else ps.IsPaid end) LatestIsPaid
	 ,pmt.LastResponseCode
	 ,ppr.LatestResponseCode
	 ,pt.PaymentTypeSCD
	from
		dbo.Payment																										 pmt
	join
		dbo.PaymentStatus																							 ps on pmt.PaymentStatusSID = ps.PaymentStatusSID
	join
		dbo.PaymentType																								 pt on pmt.PaymentTypeSID = pt.PaymentTypeSID
	join
		sf.Person																											 p on pmt.PersonSID = p.PersonSID
	left outer join
		dbo.GLTransaction																							 gt on pmt.PaymentSID = gt.PaymentSID and gt.InvoicePaymentSID is null
	left outer join
		dbo.GLAccount																									 ga on pmt.GLAccountCode = ga.GLAccountCode
	left outer join
		dbo.Registrant																								 r on pmt.PersonSID = r.PersonSID
	outer apply dbo.fPayment#LatestProcessorResponse(pmt.PaymentSID) ppr
	where
		ps.IsPaid = cast(1 as bit) or isnull(ppr.LatestIsPaid, ps.IsPaid ) <> ps.IsPaid) x
where
	x.IsPaid																 <> x.LatestIsPaid -- if payment statuses don't agree include the record
	or (x.IsOnlinePayment										 = cast(1 as bit) and x.AmountPaid <> x.LatestChargeTotal) -- paid amount and charge amount don't agree for online payments
	or ((x.IsOnlinePayment									 = cast(1 as bit) or x.PaymentTypeSCD = 'POS') and sf.fIsDifferent(x.GLPostingDate, x.DefaultGLPostingDate) = cast(1 as bit)) -- default posting date is based on verified time for cards otherwise create time 
	or (x.GLPostingDate is null and x.IsPaid = cast(1 as bit)) -- GL transactions missing for an approved payment
	or (x.IsOnlinePayment										 = cast(1 as bit) and sf.fIsDifferent(x.DepositDate, x.DefaultDepositDate) = cast(1 as bit)) -- deposit date is based on the GL posting date + lag days (date differences ignored for manual payment types)
	or (x.IsOnlinePayment										 = cast(1 as bit) and sf.fIsDifferent(x.VerifiedTime, x.LatestVerifiedTime) = cast(1 as bit)); -- verified time should match latest verified time returned by the processor (date differences ignored for manual payment types
GO
