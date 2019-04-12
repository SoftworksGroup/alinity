SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fInvoicePayment#AmountApplied]
(
	@InvoiceSID									int																	-- the invoice to tally for
)
returns decimal(11,2)
/*********************************************************************************************************************************
Function	: Invoice Payment Amount Applied
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns a decimal(11,2) of the total amount applied towards the invoice
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Richard K		| Oct 2015		|	Initial version

Comments	
--------

Returns the total invoice payments applied to the invoice.

Example
-------

<TestHarness>
  <Test Name="TaxAmount1" IsDefault="true" Description="Returns a total combined tax per item decimal value">
    <SQLScript>
      <![CDATA[
      
				select
				 top 1
					dbo.fInvoicePayment#AmountApplied(InvoiceSID)
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
	@ObjectName = 'dbo.fInvoicePayment#AmountApplied'

------------------------------------------------------------------------------------------------------------------------------- */
	
begin

  declare
		@amountPaid					decimal(11,2)																			-- return value
		,@i									int																								-- loop index
		,@maxRow						int																								-- loop max count
		,@ON								bit = cast(1 as bit)															-- constants for bit comparisons	
		,@OFF								bit = cast(0 as bit)

	
	select
		@amountPaid = cast (sum(AmountApplied) as decimal(11,2))
	from
		dbo.InvoicePayment ip
	where
		ip.InvoiceSID = @InvoiceSID

  return(@amountPaid)

end
GO
