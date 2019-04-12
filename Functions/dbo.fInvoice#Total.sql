SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fInvoice#Total] (@InvoiceSID int) -- key of invoice to return totals for
returns table
/*********************************************************************************************************************************
Function: Invoice - Total
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns totals for 1 given invoice including line item totals, taxes, and payments
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Aug		2017	|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function calculates all totals for an invoice including tax amounts, payment and resulting amount due.

Example
-------
<TestHarness>
	<Test Name="Simple" Description="A basic test of the functionality">
		<SQLScript>
		<![CDATA[
		declare
				@personSID				int
			,	@paymentSID				int
			,	@paymentTypeSID		int
			,	@paymentStatusSID	int
			, @invoiceSID				int
			,	@GLAccountCode		int
			,	@now							datetime2 = sf.fNow()
			
		begin tran

			select 
				@personSID = p.PersonSID
			from
				sf.Person p
			order by
				newid()

			select
				@GLAccountCode = gl.GLAccountCode
			from
				dbo.GLAccount gl
			where
				gl.GLAccountCode = '201'

			
			insert into dbo.Invoice
			(
					PersonSID
				,	InvoiceDate
				, RegistrationYear
			)
			select
					@personSID
				,	@now
				, year(@now)

			set @invoiceSID = scope_identity()

			insert into dbo.InvoiceItem
			(
				InvoiceSID
				,InvoiceItemDescription
				,Price
				,Quantity
				,GLAccountCode
				,SourceGUID
			)
			select
					@invoiceSID
				,	'*** TEST INVOICE ITEM ***'
				,	1.01
				,	1
				,	@GLAccountCode
				, newid()
			
			select
				@paymentStatusSID =  ps.PaymentStatusSID
			from
				dbo.PaymentStatus ps
			where
				ps.PaymentStatusSCD = 'approved'

		select
			@paymentTypeSID = pt.PaymentTypeSID
		from
			dbo.PaymentType pt
		where
			pt.PaymentTypeSCD = 'CASH'

		insert into dbo.Payment
		(
				PersonSID
			,	PaymentTypeSID
			,	PaymentStatusSID
			, GLAccountCode
			,	GLPostingDate
			,	DepositDate
			,	AmountPaid
			,	NameOnCard
		)
		select
				@personSID
			,	@paymentTypeSID
			,	@PaymentStatusSID
			, '201'
			,	sf.fNow()
			,	sf.fNow()
			,	1.01
			,	'*** TEST ***'


		set @paymentSID = scope_identity()


		insert into dbo.InvoicePayment
		(
			InvoiceSID
			,PaymentSID
			,AmountApplied
			,GLPostingDate
		)
		select
				@invoiceSID
			,	@paymentSID
			,	1.01
			,	@now

		select 
				TotalBeforeTax
			,	TotalPaid
			,	TotalDue
			,	IsPaid
		from 
			dbo.fInvoice#Total(@InvoiceSID) 
		
		if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
		if @@TRANCOUNT > 0 rollback


	]]>
	</SQLScript>
	<Assertions>

		<Assertion Type="NotEmptyResultSet" ResultSet="1" />
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="1.01" /> 
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="1.01" /> 
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="0" /> 
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="4" Value="True" />
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName				= 'dbo.fInvoice#Total'
	,	@DefaultTestOnly	=	1

------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		cast(isnull(i.TotalBeforeTax, 0.00) as decimal(11, 2))																									 TotalBeforeTax
	 ,cast(isnull(i.Tax1Total, 0.00) as decimal(11, 2))																												 Tax1Total
	 ,cast(isnull(i.Tax2Total, 0.00) as decimal(11, 2))																												 Tax2Total
	 ,cast(isnull(i.Tax3Total, 0.00) as decimal(11, 2))																												 Tax3Total
	 ,cast(isnull(i.TotalAdjustment, 0.00) as decimal(11, 2))																									 TotalAdjustment
	 ,cast(isnull(i.TotalAfterTax, 0.00) as decimal(11, 2))																										 TotalAfterTax
	 ,cast(isnull(p.TotalPaid, 0.00) as decimal(11, 2))																												 TotalPaid
	 ,cast((isnull(i.TotalAfterTax, 0.00) - isnull(p.TotalPaid, 0.00)) as decimal(11, 2))											 TotalDue
	 ,case when (i.TotalAfterTax > isnull(p.TotalPaid, 0.00)) then cast(1 as bit)else cast(0 as bit)end				 IsUnPaid
	 ,case when (i.TotalAfterTax - isnull(p.TotalPaid, 0.00)) = 0.00 then cast(1 as bit)else cast(0 as bit)end IsPaid
	 ,case when (isnull(p.TotalPaid, 0.00) > i.TotalAfterTax) then cast(1 as bit)else cast(0 as bit)end				 IsOverPaid
	from
	(
		select
			cast(isnull(sum(cast(ii.Price * cast(ii.Quantity as decimal(11, 2)) + ii.Adjustment as decimal(11, 2))), 0) as decimal(11, 2)) TotalBeforeTax
		 ,sum(cast(isnull(
											 (((ii.Price * cast(ii.Quantity as decimal(11, 2))) + ii.Adjustment) * cast(ii.IsTaxRate1Applied as decimal(11, 2))
												* cast(i.Tax1Rate as decimal(11, 2))
											 )
											,0.00
										 ) as decimal(11, 2))
				 )																																																													 Tax1Total
		 ,sum(cast(isnull(
											 (((ii.Price * cast(ii.Quantity as decimal(11, 2))) + ii.Adjustment) * cast(ii.IsTaxRate2Applied as decimal(11, 2))
												* cast(i.Tax2Rate as decimal(11, 2))
											 )
											,0.00
										 ) as decimal(11, 2))
				 )																																																													 Tax2Total
		 ,sum(cast(isnull(
											 (((ii.Price * cast(ii.Quantity as decimal(11, 2))) + ii.Adjustment) * cast(ii.IsTaxRate3Applied as decimal(11, 2))
												* cast(i.Tax3Rate as decimal(11, 2))
											 )
											,0.00
										 ) as decimal(11, 2))
				 )																																																													 Tax3Total
		 ,cast(isnull(sum(ii.Adjustment), 0) as decimal(11, 2))																																					 TotalAdjustment
			-- add total and tax components to produce total for all line items
		 ,cast(isnull(sum(cast((ii.Price * cast(ii.Quantity as decimal(11, 2))) + ii.Adjustment as decimal(11, 2))), 0) as decimal(11, 2))
			+ sum(cast(isnull(
												 (((ii.Price * cast(ii.Quantity as decimal(11, 2))) + ii.Adjustment) * cast(ii.IsTaxRate1Applied as decimal(11, 2))
													* cast(i.Tax1Rate as decimal(11, 2))
												 )
												,0.00
											 ) as decimal(11, 2))
					 )
			+ sum(cast(isnull(
												 (((ii.Price * cast(ii.Quantity as decimal(11, 2))) + ii.Adjustment) * cast(ii.IsTaxRate2Applied as decimal(11, 2))
													* cast(i.Tax2Rate as decimal(11, 2))
												 )
												,0.00
											 ) as decimal(11, 2))
					 )
			+ sum(cast(isnull(
												 (((ii.Price * cast(ii.Quantity as decimal(11, 2))) + ii.Adjustment) * cast(ii.IsTaxRate3Applied as decimal(11, 2))
													* cast(i.Tax3Rate as decimal(11, 2))
												 )
												,0.00
											 ) as decimal(11, 2))
					 )																																																												 TotalAfterTax
		from
			dbo.Invoice			i
		left outer join
			dbo.InvoiceItem ii on i.InvoiceSID = ii.InvoiceSID
		where
			i.InvoiceSID = @InvoiceSID and i.CancelledTime is null -- all amounts resolve to zero if invoice is cancelled
	) i
	outer apply
	(
		select
			cast(isnull(sum(ip.AmountApplied), 0) as decimal(11, 2)) TotalPaid -- total of all "IsPaid" status payments on the invoice
		from
			dbo.InvoicePayment ip
		join
			dbo.Payment				 p on ip.PaymentSID				= p.PaymentSID
		join
			dbo.PaymentStatus	 ps on p.PaymentStatusSID = ps.PaymentStatusSID and ps.IsPaid = cast(1 as bit)
		where
			ip.InvoiceSID = @InvoiceSID and ip.CancelledTime is null -- do not include cancelled payments in the total
			and p.CancelledTime is null
	) p
);
GO
