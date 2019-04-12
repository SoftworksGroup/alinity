SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fInvoicePayment#AmountAppliedToInvoice]
(
	@InvoiceSID									int												-- the invoice to tally for
)
returns decimal(11,2)
/*********************************************************************************************************************************
Function	: Contact Invoice Payment Amount Applied to Invoice
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns a decimal(11,2) of the total amount applied towards an invoice
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Richard K		| Oct 2015		|	Initial version

Comments	
--------

Returns the total invoice payments applied to an invoice as a decimal (11,2)

Example
-------

<TestHarness>
  <Test Name="TaxAmount1" IsDefault="true" Description="Returns a total combined tax per item decimal value">
    <SQLScript>
      <![CDATA[
      
				select
				 top 1
					dbo.fInvoicePayment#AmountAppliedToInvoice(InvoiceSID)
				from
					InvoicePayment
 
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fInvoicePayment#AmountAppliedToInvoice'

------------------------------------------------------------------------------------------------------------------------------- */
	
begin

  declare
		@amountPaid					decimal(11,2)																			-- return value

	select
		@amountPaid = cast(sum(cip.AmountApplied) as decimal(11,2))
	from
		dbo.InvoicePayment cip
	where
		cip.InvoiceSID = @InvoiceSID

  return(@amountPaid)

end
GO
