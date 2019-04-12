SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fInvoicePayment#PaymentDates]
(
	@InvoiceSID									int																	-- the invoice to get payment transaction ids for
)
returns nvarchar(1000)
/*********************************************************************************************************************************
Function	: Invoice Payment dates
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns a string of payment dates for an invoice
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Richard K		| Oct 2015		|	Initial version

Comments	
--------

Returns a comma delimited string of payment dates for display in the UI.

Example:
--------

<TestHarness>
  <Test Name="InvoicePayments1" IsDefault="true" Description="Returns a total combined tax per item decimal value">
    <SQLScript>
      <![CDATA[
      
				select
				 top 1
					dbo.fInvoicePayment#PaymentDates(InvoiceSID)
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
	@ObjectName = 'dbo.fInvoicePayment#PaymentDates'

------------------------------------------------------------------------------------------------------------------------------- */
	
begin

  declare
		 @paymentDates					nvarchar(1000)																-- return value
		,@i											int																						-- loop index
		,@maxRow								int																						-- loop max count
		,@ON										bit = cast(1 as bit)													-- constants for bit comparisons	
		,@OFF										bit = cast(0 as bit)

	
	select 
		@paymentDates = STUFF(
		( select 
			', '+ cast (sf.fDTOffsetToClientDateTime(p.CreateTime) as nvarchar(50))
			from 
				dbo.InvoicePayment ip
			join
				dbo.Payment p on ip.PaymentSID = p.PaymentSID
			where
				ip.InvoiceSID = @InvoiceSID
			for xml path('')
		), 1, 1,'')

  return(@paymentDates)

end
GO
