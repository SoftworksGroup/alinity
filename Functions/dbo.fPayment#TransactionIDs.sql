SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fPayment#TransactionIDs]
(
	@PaymentSID int -- the invoice to get payment transaction IDs for
)
returns nvarchar(150)
/*********************************************************************************************************************************
Function	: Payment - Transaction IDs
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns a string of transaction IDs
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	|	Oct 2017		| Initial version

Comments	
--------
This function returns a comma delimited string of processor transaction ID's associated with the given payment key. If the payment
is not an on-line type, or no responses were reported from the card processor then NULL is returned.

Example:
--------
<TestHarness>
  <Test Name="TransactionIDs1" IsDefault="true" Description="Returns a total combined tax per item decimal value">
    <SQLScript>
      <![CDATA[
      
				select
				 top 100
					dbo.fPayment#TransactionIDs(PaymentSID)  TransactionIDs
				from
					dbo.InvoicePayment ip
				order by
					newid()
 
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:02" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fPayment#TransactionIDs'
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare @trxIDs nvarchar(150); -- return value

	select
		@trxIDs = (case
								 when charindex(ppr.TransactionID, @trxIDs) > 0 then @trxIDs			 -- don't duplicate any repeated IDs
								 else isnull(@trxIDs + ',' + ppr.TransactionID, ppr.TransactionID) -- add onto return string
							 end)
	from
		dbo.PaymentProcessorResponse ppr 
	where
		ppr.PaymentSID = @PaymentSID
	order by
		ppr.CreateTime desc;

	return (@trxIDs);

end;
GO
