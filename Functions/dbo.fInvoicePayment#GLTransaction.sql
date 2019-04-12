SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fInvoicePayment#GLTransaction
(
	@InvoicePaymentSID int						-- key of dbo.InvoicePayment record to post transactions for
 ,@InvoiceSID				 int						-- key of the parent dbo.Invoice record (source of GL coding)
 ,@AmountApplied		 decimal(11, 2) -- amount paid
 ,@PostingDate			 date						-- date to assign to the posting (required)
)
returns @GLTransaction table
(
	ID						 int						not null identity(1, 1)
 ,InvoiceItemSID int						null									-- link to invoice item row posting is based on (null for tax lines)
 ,GLAccountCode	 varchar(50)		not null							-- GL account code to post to
 ,RevenueAmount	 decimal(11, 2) not null default 0.0	-- revenue amount to post from current payment
 ,AmountAfterTax decimal(11, 2) not null default 0.0	-- total amount after all tax types are applied
 ,PostingLevel	 tinyint				not null default 9		-- sequence or priority for posting 
 ,Ratio					 decimal(11, 9) not null default 0.0	-- factor for distributing payments against accounts at the same level
 ,Tax1Rate			 decimal(4, 4)	not null default 0.0	-- tax rate (0.0 if not applied)
 ,Tax2Rate			 decimal(4, 4)	not null default 0.0
 ,Tax3Rate			 decimal(4, 4)	not null default 0.0
 ,PaidToDate		 decimal(11, 2) not null default 0.0	-- previous posted amount for the account
 ,AmountToPost	 decimal(11, 2) not null default 0.0	-- new amount to post (the GL Transaction amount)
 ,Tax1ToPost		 decimal(11, 2) not null default 0.0	-- tax amounts to post (if tax was applied)
 ,Tax2ToPost		 decimal(11, 2) not null default 0.0
 ,Tax3ToPost		 decimal(11, 2) not null default 0.0
)
as
/*********************************************************************************************************************************
Function: Invoice Payment GL Transaction
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns structure of General Ledger posting transactions resulting from a given invoice payment key
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Jan 2018		|	Initial version
				: Tim Edlund					| Feb 2019		| Corrected error in calculation of AmountToPost where tax rates applied

Comments
--------
This function supports the GL posting process.  It returns a table with the GL accounts and amounts for posting to the 
dbo.GLTransaction table to reflect the current status of the given dbo.InvoicePayment record.  These records are inserted into 
dbo.GLTransaction table during the posting process carried out by pGLTransaction#PostInvoicePayment. 

The table structure includes many interim columns required for determining the amount to post however only the "GLAccountCode"
and "AmountToPost" columns are actually required as the end product. 

The records are derived by joining the invoice-payment record to its associated invoice (dbo.Invoice), and then to that invoice's
line items (dbo.InvoiceItem).  The invoice items store the GL codes which are set there when the invoice is created. After all
revenue accounts have been processed, an additional record is inserted into the table for each tax type collected (if any).

The amounts to post are based on first identifying a level or sequence for posting to the accounts found on the invoice-line 
items. In this version there are only 2 levels supported:  normal accounts and accounts associated with "late fees".  The 
system determines which level an account is in automatically based on logic (i.e. the account is or is not associated with a late
fee).  Amounts are applied to accounts at the later levels last.  In this version, available payments are applied to the late-fee
last.  The design will support creation of additional levels with those levels being defined by meta data either in the 
practice-register-fee table or the GL Account table. Both of these tables parent the invoice-item record.

Note that there may be more than 1 account at the same posting level.  For example, an invoice may involved a base fee, admin fee
and potentially a late fee.  Both the base fee and admin fee could be assigned sequence 1 while the late fee gets a sequence of 2.
The amount of the payment is first prorated against the 2 accounts at the base level.  For example, if the base fee is $150 and 
the Admin fee is $50, then 75% of the payment is available to apply against that account.  This amount is reduced by postings
already made to the account if previous payments exist.

Determining the amount from the current payment to apply against each account at each level also requires consideration of 
amounts paid previously against the given invoice.  Since the postings follow a sequence the algorithm must determine if accounts
earlier in the sequence have already had their amount full posted before moving onto apply amounts to the next level of the 
sequence.  The limit of the amount to apply is the total of that line item.  

Tax Components
--------------
Tax settings on each line item are considered in the calculation.  As each revenue posting amount is determined the table
tracks which of the 3-possible tax types are applied and calculates the amount of the payment that must be reserved for
paying tax even where the payment is partial.  The tax amount is ALWAYS taken; the design does not allow not-paying a tax amount 
on a partial payment in favor of paying it later.  The tax proportional amount of the payment is always allocated to the 
tax accounts affected. 

When tax amounts exist for one or more invoice items additional records are inserted into the output table for posting to the 
GL.  One additional record is inserted for each of the 3-possible tax types.  The records only insert if the tax amount is > 0.01
Note that if the amount of the payment is so small that the tax amount on it is <0.01, then no tax amount will be stored.

Limitations
-----------
Currently determination of late fees is only supported from Renewal invoices. If late fees are associated with other registration
form types they are ignored.  The logic can be expanded to search for late fees associated with other form types.

Example
-------
<TestHarness>
	<Test Name="NoLateFee" IsDefault="true" Description="Returns calculated values for an invoice payment selected at random where no late fees
	appear as invoice items">
		<SQLScript>
		<![CDATA[
declare
	@invoiceSID				 int
 ,@invoicePaymentSID int
 ,@amountApplied		 decimal(11, 2)
 ,@postingDate			 date;

select top (1)
	@invoicePaymentSID = ipmt.InvoicePaymentSID
 ,@amountApplied		 = ipmt.AmountApplied
 ,@invoiceSID				 = ipmt.InvoiceSID
 ,@postingDate			 = pmt.GLPostingDate
from
	dbo.InvoicePayment ipmt
join
	dbo.Invoice				 i on ipmt.InvoiceSID				= i.InvoiceSID
join
	dbo.Payment				 pmt on ipmt.PaymentSID			= pmt.PaymentSID
join
	dbo.PaymentStatus	 ps on pmt.PaymentStatusSID = ps.PaymentStatusSID
left outer join
	dbo.vInvoiceItem	 ii on i.InvoiceSID					= ii.InvoiceSID and ii.IsLateFee = 1
where
	ipmt.AmountApplied > 0.0 and ps.IsPaid = 1 and ii.InvoiceItemSID is null -- no late fee
	--and ipmt.InvoiceSID = 1000041	-- uncomment hardcoded invoice reference for explicit test case
order by
	newid();

if @@rowcount = 0 or @postingDate is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		x.*
	 ,ga.GLAccountLabel
	 ,@invoiceSID				 InvoiceSID
	 ,@invoicePaymentSID InvoicePaymentSID
	 ,i.TotalBeforeTax
	 ,i.Tax1Total
	 ,i.Tax2Total
	 ,i.Tax3Total
	 ,i.TotalAfterTax
	from
		dbo.fInvoicePayment#GLTransaction(@invoicePaymentSID, @invoiceSID, @amountApplied, @postingDate) x
	join
		dbo.vInvoice																																										 i on i.InvoiceSID		 = @invoiceSID
	left outer join
		dbo.GLAccount																																										 ga on x.GLAccountCode = ga.GLAccountCode;

	select
		ii.InvoiceItemSID
	 ,ii.InvoiceItemDescription
	 ,ii.IsTaxRate1Applied
	 ,ii.IsTaxRate2Applied
	 ,ii.IsTaxRate3Applied
	 ,ii.GLAccountCode
	 ,ii.AmountBeforeTax
	 ,ii.Tax1Amount
	 ,ii.Tax2Amount
	 ,ii.Tax3Amount
	 ,ii.AmountAfterTax
	 ,ii.IsAdjusted
	from
		dbo.vInvoiceItem ii
	where
		ii.InvoiceSID = @invoiceSID
	order by
		ii.InvoiceItemSID;

	select
		ip.InvoicePaymentSID
	 ,ip.AmountApplied
	 ,ip.AppliedDate
	 ,ip.GLPostingDate
	 ,ip.PaymentGLPostingDate
	 ,(case when ip.InvoicePaymentSID = @invoicePaymentSID then 'Yes' else 'No' end) PaymentToPost
	from
		dbo.vInvoicePayment ip
	where
		ip.InvoiceSID = @invoiceSID
	order by
		ip.InvoicePaymentSID;

end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1" />
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
	<Test Name="WithLateFee" Description="Returns calculated values for an invoice payment selected at random where at least one
	line item is a late fee">
		<SQLScript>
		<![CDATA[
declare
	@invoiceSID				 int
 ,@invoicePaymentSID int
 ,@amountApplied		 decimal(11, 2) 
 ,@postingDate			 date;

select top (1)
	@invoicePaymentSID = ipmt.InvoicePaymentSID
 ,@amountApplied		 = ipmt.AmountApplied
 ,@invoiceSID				 = ipmt.InvoiceSID
 ,@postingDate			 = pmt.GLPostingDate
from
	dbo.InvoicePayment ipmt
join
	dbo.Invoice				 i on ipmt.InvoiceSID				= i.InvoiceSID
join
	dbo.Payment				 pmt on ipmt.PaymentSID			= pmt.PaymentSID
join
	dbo.PaymentStatus	 ps on pmt.PaymentStatusSID = ps.PaymentStatusSID
left outer join
	dbo.vInvoiceItem	 ii on i.InvoiceSID					= ii.InvoiceSID and ii.IsLateFee = 1
where
	ipmt.AmountApplied > 0.0 and ps.IsPaid = 1 and ii.AmountAfterTax > 0 -- to include late fee
	--and ipmt.InvoiceSID = 1000041	-- uncomment hardcoded invoice reference for explicit test case
order by
	newid();

if @@rowcount = 0 or @postingDate is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		x.*
	 ,ga.GLAccountLabel
	 ,@invoiceSID				 InvoiceSID
	 ,@invoicePaymentSID InvoicePaymentSID
	 ,i.TotalBeforeTax
	 ,i.Tax1Total
	 ,i.Tax2Total
	 ,i.Tax3Total
	 ,i.TotalAfterTax
	from
		dbo.fInvoicePayment#GLTransaction(@invoicePaymentSID, @invoiceSID, @amountApplied, @postingDate) x
	join
		dbo.vInvoice																																										 i on i.InvoiceSID		 = @invoiceSID
	left outer join
		dbo.GLAccount																																										 ga on x.GLAccountCode = ga.GLAccountCode;

	select
		ii.InvoiceItemSID
	 ,ii.InvoiceItemDescription
	 ,ii.IsTaxRate1Applied
	 ,ii.IsTaxRate2Applied
	 ,ii.IsTaxRate3Applied
	 ,ii.GLAccountCode
	 ,ii.AmountBeforeTax
	 ,ii.Tax1Amount
	 ,ii.Tax2Amount
	 ,ii.Tax3Amount
	 ,ii.AmountAfterTax
	 ,ii.IsAdjusted
	from
		dbo.vInvoiceItem ii
	where
		ii.InvoiceSID = @invoiceSID
	order by
		ii.InvoiceItemSID;

	select
		ip.InvoicePaymentSID
	 ,ip.AmountApplied
	 ,ip.AppliedDate
	 ,ip.GLPostingDate
	 ,ip.PaymentGLPostingDate
	 ,(case when ip.InvoicePaymentSID = @invoicePaymentSID then 'Yes' else 'No' end) PaymentToPost
	from
		dbo.vInvoicePayment ip
	where
		ip.InvoiceSID = @invoiceSID
	order by
		ip.InvoicePaymentSID;

end;
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1" />
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'fInvoicePayment#GLTransaction'
	,@DefaultTestOnly = 1
 ------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@ON								bit = cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@OFF							bit = cast(0 as bit)	-- constant for bit comparison = 0
	 ,@nextSequence			tinyint								-- next posting sequence to derive totals for
	 ,@remainingPrePaid decimal(11, 2)				-- amount paid prior to this payment
	 ,@remainingToPost	decimal(11, 2)				-- total amount of revenue (excluding tax) remaining to post
	 ,@totalInvoice			decimal(11, 2)				-- tracks total after tax for the full invoice
	 ,@totalTax					decimal(11, 2)				-- tracks tax amount for the full invoice
	 ,@totalRevenue			decimal(11, 2)				-- tracks total revenue at each level (pro-rating denominator)
	 ,@totalPosted			decimal(11, 2);				-- total of amounts posted (used in rounding adj check)

	-- insert the GL accounts associated with the 
	-- line items from the invoice identified

	insert
		@GLTransaction
	(
		InvoiceItemSID
	 ,GLAccountCode
	 ,RevenueAmount
	 ,AmountAfterTax
	 ,Tax1Rate
	 ,Tax2Rate
	 ,Tax3Rate
	 ,PostingLevel
	)
	select
		ii.InvoiceItemSID
	 ,ii.GLAccountCode
	 ,ii.AmountBeforeTax
	 ,ii.AmountAfterTax
	 ,(case when ii.IsTaxRate1Applied = @ON then ii.Tax1Rate else 0.0 end)	-- record tax rates where applied for tax amount 
	 ,(case when ii.IsTaxRate2Applied = @ON then ii.Tax2Rate else 0.0 end)
	 ,(case when ii.IsTaxRate3Applied = @ON then ii.Tax3Rate else 0.0 end)
	 ,(case when isnull(ci.IsLateFee, @OFF) = @ON then 2 else 1 end)				-- defines late fee to post after regular fees
	from
		dbo.vInvoiceItem ii
	left outer join
		dbo.CatalogItem	 ci on ii.CatalogItemSID = ci.CatalogItemSID
	where
		ii.InvoiceSID = @InvoiceSID -- process all line items for the parent invoice
	order by
		ii.InvoiceItemSID;

	-- determine the total amount paid on this invoice prior to the
	-- current record 

	select
		@remainingPrePaid = sum(ip.AmountApplied)
	from
		dbo.InvoicePayment ip
	where
		ip.InvoiceSID				 = @InvoiceSID -- add up all payments for the current invoice where ...
		and ip.CancelledTime is null -- the invoice payment is not cancelled
		and
		(
			ip.GLPostingDate	 < @PostingDate -- either the invoice payment posts before the one being processed or ... 
			or
			(
				ip.GLPostingDate = @PostingDate and ip.InvoicePaymentSID < @InvoicePaymentSID -- it posts the same day but was entered prior to the one being processed
			)
		);

	-- next obtain the total revenue and tax amounts
	-- for the invoice (required in proration)

	select
		@totalTax			= sum(ii.Tax1Amount + ii.Tax2Amount + ii.Tax3Amount)
	 ,@totalInvoice = sum(ii.AmountAfterTax)
	from
		@GLTransaction	 gt
	join
		dbo.vInvoiceItem ii on gt.InvoiceItemSID = ii.InvoiceItemSID;

	-- the prepaid amount must be reduced by the amount that
	-- must be reserved to apply to tax amounts

	set @remainingToPost = @AmountApplied - (@AmountApplied * (@totalTax / @totalInvoice));
	set @remainingPrePaid = @remainingPrePaid - (@remainingPrePaid * (@totalTax / @totalInvoice));

	-- update the records in the memory table on a level-by-level
	-- sequence - prorating available prior and current payment
	-- amounts to arrive at the new posting amount

	set @nextSequence = 0;

	while @nextSequence < 2
	begin

		set @nextSequence += 1;

		-- calculate the ratio of total revenue at this posting level
		-- for each invoice item to establish the proration factor

		select
			@totalRevenue = sum(gl.RevenueAmount)
		from
			@GLTransaction gl
		where
			gl.PostingLevel = @nextSequence;

		if @@rowcount > 0 -- terminate early if no records at this posting level
		begin

			update
				@GLTransaction
			set
				Ratio = (case when @totalRevenue = 0 then 0 else RevenueAmount / @totalRevenue end) -- set prorate factor for this level of posting
			where
				PostingLevel = @nextSequence;

			-- apply the prorate factor to allocate the share of payments
			-- already collected for items at this posting level

			update
				@GLTransaction
			set
				PaidToDate = (case
												when isnull(Ratio * @remainingPrePaid, 0.00) > RevenueAmount then RevenueAmount -- limit to total revenue for item
												else isnull(Ratio * @remainingPrePaid, 0.00)
											end
										 )	-- prorate amount of previous payment yet to apply
			where
				PostingLevel = @nextSequence;

			-- next apply the proration factor to amount remaining to post
			-- for each item at this level; note tax calculation is deferred
			-- to next update because it depends on amount-to-post

			update
				@GLTransaction
			set
				AmountToPost = (case
													when RevenueAmount - PaidToDate - isnull(Ratio * @remainingToPost, 0.00) <= 0 then RevenueAmount - PaidToDate
													else isnull(Ratio * @remainingToPost, 0.00)
												end
											 )
			where
				PostingLevel = @nextSequence;

			-- calculate the tax amounts on the revenue to post
			-- and then reduce that from the revenue post amount

			update
				@GLTransaction
			set
				Tax1ToPost = AmountToPost * Tax1Rate	-- tax rates are 0.00 unless taxes are applied
			 ,Tax2ToPost = AmountToPost * Tax2Rate
			 ,Tax3ToPost = AmountToPost * Tax3Rate
			where
				PostingLevel = @nextSequence;

			-- reduce the amount of prepaid and applied amounts 
			-- for next iteration (lower priority postings)

			set @remainingPrePaid = @remainingPrePaid -
															(
																select
																	sum(PaidToDate)
																from
																	@GLTransaction gl
																where
																	gl.PostingLevel = @nextSequence
															);

			set @remainingToPost = @remainingToPost -
														 (
															 select
																	sum(gl.AmountToPost)
															 from
																	@GLTransaction gl
															 where
																 gl.PostingLevel = @nextSequence
														 );

		end;

	end;

	-- add additional records for tax amounts that have been collected
	-- if any; the tax accounts are looked up from the invoice (header)

	insert
		@GLTransaction (GLAccountCode, AmountToPost)
	select
		i.Tax1GLAccountCode
	 ,gt.TotalTax
	from
	(select sum(Tax1ToPost) TotalTax from @GLTransaction) gt
	join
		dbo.Invoice																					i on i.InvoiceSID = @InvoiceSID
	where
		gt.TotalTax > 0.0;

	insert
		@GLTransaction (GLAccountCode, AmountToPost)
	select
		i.Tax2GLAccountCode
	 ,gt.TotalTax
	from
	(select sum(Tax2ToPost) TotalTax from @GLTransaction) gt
	join
		dbo.Invoice																					i on i.InvoiceSID = @InvoiceSID
	where
		gt.TotalTax > 0.0;

	insert
		@GLTransaction (GLAccountCode, AmountToPost)
	select
		i.Tax3GLAccountCode
	 ,gt.TotalTax
	from
	(select sum(Tax3ToPost) TotalTax from @GLTransaction) gt
	join
		dbo.Invoice																					i on i.InvoiceSID = @InvoiceSID
	where
		gt.TotalTax > 0.0;

	-- check if rounding adjustment is required in order to 
	-- balance with the original amount applied; if required
	-- apply the adjustment to the last revenue trx

	select @totalPosted	 = sum(gt.AmountToPost) from @GLTransaction	 gt;

	if @AmountApplied <> @totalPosted and @@rowcount > 0
	begin

		update
			@GLTransaction
		set
			AmountToPost = AmountToPost + (@AmountApplied - @totalPosted)
		where
			ID = (select max (ID) from @GLTransaction	 gt where gt.InvoiceItemSID is not null);

	end;

	return;
end;
GO
