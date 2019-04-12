SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vGLTransaction#Detail
as
/*********************************************************************************************************************************
View		: GL Transaction - Detail 
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns detailed data on general ledger transactions
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This view provides details of general ledger transactions.  The view is based on the dbo.GLTransaction table which stores a single
record including both a debit and credit account, however, this view parses the record into a separate line for the debit and
another for the credit to support uses where a traditional Journal Entry format is required. The view is designed primarily for
exporting to off-line reporting systems such as Excel. 

Maintenance Note: columns down to "LastResponse" have common logic and structure in dbo.fGLTransaction#DetailForDay. If logic
changes are required here, also make them in the table function.

<TestHarness>
  <Test Name = "Random" IsDefault="true" Description="Executes view for a date range selected at random">
    <SQLScript>
    <![CDATA[
declare
	@startDate datetime
 ,@endDate	 datetime;

select top (1)
	@startDate = pmt.DepositDate
from
	dbo.Payment pmt
order by
	newid();

if @@rowcount = 0 or @startDate is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	set @startDate = dateadd(day, -3, @startDate);
	set @endDate = dateadd(day, 7, @startDate);

	select
		gtd.*
	from
		dbo.vGLTransaction#Detail gtd
	where
		gtd.DepositDate between @startDate and @endDate
	order by
		gtd.GLPostingDate;

end;
    ]]>
    </SQLScript>
    <Assertions>
	    <Assertion Type="ExecutionTime" Value="00:00:05" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vGLTransaction#Detail'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

select
	x.GLPostingDate
 ,x.GLAccountCode
 ,isnull(ga.GLAccountLabel, isnull(gaDf.GLAccountLabel + N' (Df)', N'[Removed]'))												 AccountName
 ,x.TrxSign
 ,(case when x.TrxSign = 'DB' then x.Amount else cast(null as decimal(11, 2))end)												 DebitAmount
 ,(case when x.TrxSign = 'CR' then x.Amount else cast(null as decimal(11, 2))end)												 CreditAmount
 ,pt.PaymentTypeLabel
 ,pmt.DepositDate
 ,dbo.fRegistrant#Label(ps.LastName, ps.FirstName, ps.MiddleNames, r.RegistrantNo, 'REGISTRATION')			 RegistrantLabel
 ,pmt.PaymentCard
 ,pmt.NameOnCard
 ,pmt.PaymentSID
 ,upper(pmt.TransactionID)																																							 TransactionID
 ,pmt.VerifiedTime
 ,pmt.UpdateTime
 ,pmt.LastResponseCode + ' - ' + replace(replace(pmt.LastResponseMessage, ' ', ''), '*=', '')						 LastResponse
 ,r.RegistrantNo
 ,ps.CommonName
 ,ps.MiddleNames
 ,ps.LastName
 ,pmt.AmountPaid																																												 TotalPayment
 ,x.Amount																																															 TransactionAmount
 ,case when isnull(ga.IsBankAccount, gaDf.IsBankAccount) = cast(1 as bit) then 'yes' else 'no' end			 IsBankAccount
 ,case when isnull(ga.IsRevenueAccount, gaDf.IsRevenueAccount) = cast(1 as bit) then 'yes' else 'no' end IsRevenueAccount
 ,case when isnull(ga.IsTaxAccount, gaDf.IsTaxAccount) = cast(1 as bit) then 'yes' else 'no' end				 IsTaxAccount
 ,case when isnull(ga.IsPAPAccount, gaDf.IsPAPAccount) = cast(1 as bit) then 'yes' else 'no' end				 IsPAPAccount
 ,case
		when isnull(ga.IsUnappliedPaymentAccount, gaDf.IsUnappliedPaymentAccount) = cast(1 as bit) then 'yes'
		else 'no'
	end																																																		 IsUnappliedPaymentAccount
 ,ii.InvoiceItemDescription
 ,ii.RegistrationSID
 ,ii.RegistrationYear
 ,ii.RegistrationLabel
from
(
	select
		gt.GLPostingDate
	 ,gt.DebitGLAccountCode GLAccountCode
	 ,'DB'									TrxSign
	 ,gt.Amount
	 ,gt.PaymentSID
	from
		dbo.GLTransaction gt
	left outer join
		dbo.GLAccount			gaDB on gt.DebitGLAccountCode		= gaDB.GLAccountCode
	left outer join
		dbo.GLAccount			gaDBDf on gt.DebitGLAccountCode = gaDBDf.DeferredGLAccountCode
	where
		gt.IsExcluded = cast(0 as bit)
	union all
	select
		gt.GLPostingDate
	 ,gt.CreditGLAccountCode GLAccountCode
	 ,'CR'									 TrxSign
	 ,gt.Amount
	 ,gt.PaymentSID
	from
		dbo.GLTransaction gt
	left outer join
		dbo.GLAccount			gaCR on gt.CreditGLAccountCode	 = gaCR.GLAccountCode
	left outer join
		dbo.GLAccount			gaCRDf on gt.CreditGLAccountCode = gaCRDf.DeferredGLAccountCode
	where
		gt.IsExcluded = cast(0 as bit)
)									x
join
	dbo.Payment			pmt on x.PaymentSID			 = pmt.PaymentSID
join
	dbo.PaymentType pt on pmt.PaymentTypeSID = pt.PaymentTypeSID
join
	sf.Person				ps on pmt.PersonSID			 = ps.PersonSID
left outer join
	dbo.Registrant	r on pmt.PersonSID			 = r.PersonSID
left outer join
	dbo.GLAccount		ga on x.GLAccountCode		 = ga.GLAccountCode
left outer join
	dbo.GLAccount		gaDf on x.GLAccountCode	 = gaDf.DeferredGLAccountCode
left outer join
(
	select
		ipmt.PaymentSID
	 ,ii.InvoiceItemDescription
	 ,reg.RegistrationSID
	 ,reg.RegistrationYear
	 ,pr.PracticeRegisterLabel + (case when prs.IsDefault = cast(1 as bit) then '' else ' - ' + prs.PracticeRegisterSectionLabel end) RegistrationLabel
	 ,row_number() over (partition by ipmt.PaymentSID order by ipmt.CreateTime, ii.InvoiceItemSID)																		RowNo
	from
		dbo.InvoicePayment					ipmt
	join
		dbo.InvoiceItem							ii on ipmt.InvoiceSID									= ii.InvoiceSID
	left outer join
		dbo.Registration						reg on ipmt.InvoiceSID								= reg.InvoiceSID
	left join
		dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
	left join
		dbo.PracticeRegister				pr on prs.PracticeRegisterSID					= pr.PracticeRegisterSID
)									ii on pmt.PaymentSID		 = ii.PaymentSID and ii.RowNo = 1;

GO
EXEC sp_addextendedproperty N'MS_Description', N'Provides detailed data on general ledger transactions |EXPORT+ ^PaymentList', 'SCHEMA', N'dbo', 'VIEW', N'vGLTransaction#Detail', NULL, NULL
GO
