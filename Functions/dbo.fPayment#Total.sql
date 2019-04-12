SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPayment#Total] (@PaymentSID int) -- payment to calculate total applied for
returns table
/*********************************************************************************************************************************
Function: Payment - Total (applied and unapplied)
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns the total amount applied and unapplied for a payment
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-----------------------------------------------------------------------------------------------------------
				: Tim Edlund	| Sep	2017		|	Initial Version
				: Tim Edlund	| Jan	2018		| Modified return 0 on most columns when payment is pending or canceled/declined
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function calculates the total amount applied for a Payment.  Note that applied amount is calculated without regard to
the status of the payment. If the payment is PENDING or even DECLINED the total amounts applied to invoices from the payment are 
included in the total calculated here. This is done so that the total can be used to track the amount applied from a payment and 
avoid over-applying it.  The fInvoice#Total table-function does NOT consider the invoice paid unless a PAID status is in effect.

The function does avoid including payments in the total where the applied-amount has been cancelled (the Cancelled-Time column
is filled in).

The Unapplied amount returned, is the difference between the applied total and the original amount of the payment.

Example
-------
<TestHarness>
	<Test Name="Simple" Description="A basic test of the functionality">
		<SQLScript>
		<![CDATA[
		declare
				@personSID					int
			,	@paymentSID					int
			,	@paymentTypeSID			int
			,	@paymentStatusSID		int
			, @invoiceSID					int
			,	@GLAccountCode			varchar(10) = '201'
			,	@invoicePaymentSID	int
			,	@amount							decimal(11,2) = 1.01
			,	@now								datetime2 = sf.fNow()
			
		begin tran

			select 
				@personSID = p.PersonSID
			from
				sf.Person p
			order by
				newid()

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
				,	@amount
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
			,	@amount
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
			,	@amount
			,	@now

		set @invoicePaymentSID = scope_identity()

		select
			*
		from 
			dbo.fPayment#Total(@PaymentSID)
		
		if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
		if @@TRANCOUNT > 0 rollback


	]]>
	</SQLScript>
	<Assertions>

		<Assertion Type="NotEmptyResultSet" ResultSet="1" />
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="1.01" /> 
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="0.00" /> 
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="True"/> 
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="4" Value="False" />
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="5" Value="False" />
		<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="6" Value="False" />
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.fInvoicePayment#GLTransaction'
	,	@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		case when ps.IsPaid = 1 then x.TotalApplied else 0.00 end																																							TotalApplied
	 ,case when ps.IsPaid = 1 then cast(isnull(p.AmountPaid - x.TotalApplied, 0.00) as decimal(11, 2))else 0.00 end													TotalUnapplied
	 ,cast(isnull(case when ps.IsPaid = 0 then 0 when p.AmountPaid = x.TotalApplied then 1 else 0 end, 0) as bit)														IsFullyApplied
	 ,cast(isnull(case when ps.IsPaid = 0 then 0 when x.TotalApplied = 0.00 then 1 else 0 end, 0) as bit)																		IsNotApplied
	 ,cast(isnull(case when ps.IsPaid = 0 then 0 when p.AmountPaid > x.TotalApplied and x.TotalApplied > 0.00 then 1 else 0 end, 0) as bit) IsPartiallyApplied
	 ,cast(isnull(case when ps.IsPaid = 0 then 0 when p.AmountPaid < x.TotalApplied then 1 else 0 end, 0) as bit)														IsOverApplied -- this is an error condition
	from
	(
		select
			cast(isnull(sum(ip.AmountApplied), 0.00) as decimal(11, 2)) TotalApplied
		from
			dbo.InvoicePayment ip
		where
			ip.PaymentSID = @PaymentSID and ip.CancelledTime is null -- do not include cancelled payments in the total applied
	)										x
	join
		dbo.Payment				p on p.PaymentSID				 = @PaymentSID
	join
		dbo.PaymentStatus ps on p.PaymentStatusSID = ps.PaymentStatusSID
);
GO
