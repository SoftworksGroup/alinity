SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fPayment#LatestProcessorResponse
(
	@PaymentSID int -- key of payment record to return latest processor response for
)
returns table
/*********************************************************************************************************************************
Function	: Payment - Latest Processor Response
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns latest payment processor response record for a given payment
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Oct 2017    |	Initial version
					: Tim Edlund	| Dec 2017		| Examining of "IsPaid" status changed from parse of XML to explicit column on response
					: Tim Edlund	| Nov 2018		| Updated parsing logic to pull cast to decimal as separate operation
					: Cory Ng			| Feb 2019		| Updated to support Bambora response details

Comments	
--------
This table function modularizes the logic required to determine the status of the latest response record for a given payment. 
This function also supports analysis of verification status and time stored on the dbo.Payment record as compared to those
values are returned by the processor in their latest response.  

To obtain the response values the XML returned by the payment processor is extracted to date and time and the status codes
are evaluated to determine whether the transaction was processed as paid.  The verification time and paid status can be
compared with those values as stored on the payment record.  Discrepancies can arise due to errors in processing records
should always be investigated and corrected.

MONERIS ONLY: This view is created for a specific payment processor - MONERIS. Because the response format from each payment
processor is unique, a separate function is required for each.  A configuration cannot support more than one processor at the
same time so the function for the processor-implemented in a configuration is saved "dbo.fPayment#LatestProcessorResponse.  
Other versions may exist in the schema as part of the product deployment which exist with a $[PROCESSOR] extension.

CAUTION ! If a payment type is passed that does not use the dbo.PaymentProcessorResponse table then NULL is returned. This is 
done to maximize performance of the function.  Where this function is being used in situations where all Payment records must be 
included in the result, an outer apply is required.

Maintenance Note:  The view dbo.vPaymentProcessResponse#Detail uses the same parsing logic as this function so any changes
made here should be evaluated for the view as well.  (It is not advised to modularize the view into the function as doing
so has shown to materially impact performance).

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the function.">
<SQLScript>
<![CDATA[
	select top 100
		 p.PaymentSID
		,x.*
	from
		dbo.Payment p
	outer apply
		dbo.fPayment#LatestProcessorResponse(p.PaymentSID) x
	order by
		p.PaymentSID
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:02" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fPayment#LatestProcessorResponse'

-------------------------------------------------------------------------------------------------------------------------------- */

return
(
	select
		z.PaymentSID
	 ,z.TransactionID																 LatestTransactionID
	 ,z.PaymentProcessorResponseSID
	 ,z.NameOnCard																	 LatestNameOnCard
	 ,z.PaymentCard																	 LatestPaymentCard
	 ,z.ChargeTotal																	 LatestChargeTotal
	 ,z.ChargeTotalString
	 ,z.ResponseCode																 LatestResponseCode
	 ,z.ApprovalCode																 LatestApprovalCode
	 ,replace(replace(z.Message, ' ', ''), '*=', '') LatestMessage
	 ,z.IsPaid																			 LatestIsPaid
	 ,z.ResponseTime																 LatestVerifiedTime
	from
	(
		select
			p.PaymentSID
		 ,pprl.PaymentProcessorResponseSID
		 ,ppr.ResponseTime
		 ,ppr.TransactionID
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
			when pt.PaymentTypeSCD = 'PP.BAMBORA' then ppr.ResponseDetails.value('response[1]/messageId[1]', 'int')
			else null end																																												ResponseCode
		 ,case 
			when pt.PaymentTypeSCD = 'PP.MONERIS' then ppr.ResponseDetails.value('response[1]/message[1]', 'varchar(250)')
			when pt.PaymentTypeSCD = 'PP.BAMBORA' then ppr.ResponseDetails.value('response[1]/messageText[1]', 'varchar(250)')
			else null end																																												Message
		 ,case 
			when pt.PaymentTypeSCD = 'PP.MONERIS' then ppr.ResponseDetails.value('response[1]/bank_approval_code[1]', 'varchar(25)')
			else null end																																												ApprovalCode
		from
			dbo.Payment p
		join
			dbo.PaymentType pt on p.PaymentTypeSID = pt.PaymentTypeSID
		cross apply
		(
			select top (1)
				ppr.PaymentProcessorResponseSID
			from
				dbo.PaymentProcessorResponse ppr
			where
				ppr.PaymentSID = @PaymentSID
			order by
				ppr.ResponseTime desc
			 ,ppr.PaymentProcessorResponseSID desc
		)							pprl
		join
			dbo.PaymentProcessorResponse ppr on pprl.PaymentProcessorResponseSID = ppr.PaymentProcessorResponseSID
		where
			p.PaymentSID = @PaymentSID
	) z
);
GO
