SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vPaymentProcessorResponse#Detail]
/*********************************************************************************************************************************
View			: Payment Processor Response - Details
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns details of payment process response messages
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Nov 2017    |	Initial version
					: Tim Edlund	| Dec 2017		| Examining of "IsPaid" status changed from parse of XML to explicit column on response
					: Cory Ng			| Feb 2019		| Updated to support Bambora response details

Comments	
--------
This view modularizes the logic required to parse response messages received from the MONERIS card processor service. If a
different card processing service is being used, a different version of this view must be compiled into the schema. 

If a payment is queried that does not have any dbo.PaymentProcessorResponse records then no records are returned.

MONERIS ONLY: This view is created for a specific payment processor - MONERIS. Because the response format from each payment 
processor is unique, a separate view is required for each.  A configuration cannot support more than one processor at the same 
time so the function for the processor-implemented in a configuration is saved as this function.  Other versions may exist in 
the schema as part of the product deployment which exist with a $[PROCESSOR] extension.

Maintenance Note:  The function dbo.fPayment#LatestProcessorResponse uses the same parsing logic as this view so any changes
made here should be evaluated for the function as well.  (It is not advised to modularize the view into the function as doing
so has shown to materially impact performance).

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the view.">
<SQLScript>
<![CDATA[
	select top 100
		 x.*
	from
		dbo.vPaymentProcessorResponse#Detail x
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:02" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vPaymentProcessorResponse#Detail'

-------------------------------------------------------------------------------------------------------------------------------- */

as
select
	z.PaymentSID
 ,z.PaymentProcessorResponseSID
 ,z.ResponseTime
 ,z.TransactionID
 ,z.ResponseSource
 ,z.NameOnCard
 ,z.PaymentCard
 ,z.ChargeTotal
 ,z.Result
 ,z.ResponseCode
 ,replace(replace(z.Message, ' ', ''), '*=', '')																Message
 ,z.ApprovalCode
 ,z.IsPaid
from
( select
		p.PaymentSID
	 ,ppr.PaymentProcessorResponseSID
	 ,ppr.ResponseTime
	 ,ppr.TransactionID
	 ,ppr.ResponseSource
	 ,ppr.IsPaid
	 ,case 
		when pt.PaymentTypeSCD = 'PP.MONERIS' then ppr.ResponseDetails.value('response[1]/cardholder[1]', 'nvarchar(75)')
		when pt.PaymentTypeSCD = 'PP.BAMBORA' then ppr.ResponseDetails.value('response[1]/trnCustomerName[1]', 'nvarchar(75)')
		else null end																																												NameOnCard
	 ,case 
		when pt.PaymentTypeSCD = 'PP.MONERIS' then ppr.ResponseDetails.value('response[1]/card_num[1]', 'varchar(20)')
		else null end																																												PaymentCard
	 ,case 
		when pt.PaymentTypeSCD = 'PP.MONERIS' then try_cast(ppr.ResponseDetails.value('response[1]/charge_total[1]', 'varchar(15)') as decimal(11, 2))
		when pt.PaymentTypeSCD = 'PP.BAMBORA' then try_cast(ppr.ResponseDetails.value('response[1]/trnAmount[1]', 'varchar(15)') as decimal(11, 2))
		else null end																																												ChargeTotal				-- conversion to decimal may fail if format invalid 			
	 ,case 
		when pt.PaymentTypeSCD = 'PP.MONERIS' then ppr.ResponseDetails.value('response[1]/charge_total[1]', 'varchar(15)')
		when pt.PaymentTypeSCD = 'PP.BAMBORA' then ppr.ResponseDetails.value('response[1]/trnAmount[1]', 'varchar(15)')
		else null end																																												ChargeTotalString
	 ,case 
		when pt.PaymentTypeSCD = 'PP.MONERIS' then ppr.ResponseDetails.value('response[1]/response_code[1]', 'int')
		when pt.PaymentTypeSCD = 'PP.BAMBORA' then ppr.ResponseDetails.value('response[1]/trnApproved[1]', 'int')
		else null end																																												ResponseCode
	 ,case 
		when pt.PaymentTypeSCD = 'PP.MONERIS' then ppr.ResponseDetails.value('response[1]/result[1]', 'bit')
		when pt.PaymentTypeSCD = 'PP.BAMBORA' then ppr.ResponseDetails.value('response[1]/messageId[1]', 'bit')
		else null end																																												Result
	 ,case 
		when pt.PaymentTypeSCD = 'PP.MONERIS' then ppr.ResponseDetails.value('response[1]/message[1]', 'varchar(250)')
		when pt.PaymentTypeSCD = 'PP.BAMBORA' then ppr.ResponseDetails.value('response[1]/messageText[1]', 'varchar(250)')
		else null end																																												Message
	 ,case 
		when pt.PaymentTypeSCD = 'PP.MONERIS' then ppr.ResponseDetails.value('response[1]/bank_approval_code[1]', 'varchar(25)')
		else null end																																												ApprovalCode
	from
		dbo.Payment									 p
	join
		dbo.PaymentType pt on p.PaymentTypeSID = pt.PaymentTypeSID
	join
		dbo.PaymentProcessorResponse ppr on p.PaymentSID = ppr.PaymentSID
) z;
GO
