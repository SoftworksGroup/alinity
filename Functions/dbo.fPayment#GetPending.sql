SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fPayment#GetPending
(
	@PersonSID	int								-- limit pending payments to a specific person -1 for all
 ,@CutOffTime datetimeoffset(7) -- time to avoid payments still in progress (2 minutes offset recommended)
)
returns table
as
/*********************************************************************************************************************************
Function : Payment - Get Pending
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns credit card payment records where response is received but not applied to the record 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version
				: Cory Ng							| Feb 2019		| Returned payment type SCD, used in determining how to reapply the payment

Comments	
--------
This function is called to return any credit card payments have been left in a pending state where "verification" information has 
been received for it from the credit card processor.  When this scenario occurs, the payment will not be applied and generation of 
registration records may be blocked.  

The @PersonSID parameter is provided to allow results to be limited to a specific person. If all pending payments are to 
be returned pass "-1" into this parameter. In order to provide time for currently in-process payments to be updated for information
returned from the credit card processor, a @CutOffTime should be passed set 1 or 2 minutes in the past. This will avoid payments
currently in process.

Example
-------
<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Executes the function to return pending records (all users).
	Data set returned may be blank.">
    <SQLScript>
      <![CDATA[

select * from dbo.fPayment#GetPending(-1, sysdatetimeoffset())

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
  <Test Name = "DataSet" Description="Executes the function for an person selected at random. Data set
	returned may be blank.">
<SQLScript>
      <![CDATA[
declare @personSID int;

select top (1)
	@personSID = p.PersonSID
from
	dbo.RegistrantRenewal rnw
join
	dbo.Invoice						i on rnw.InvoiceSID		 = i.InvoiceSID
join
	dbo.InvoicePayment		ipmt on rnw.InvoiceSID = ipmt.InvoiceSID
join
	sf.Person							p on i.PersonSID			 = p.PersonSID
order by
	newid();

if @@rowcount = 0 or @personSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select * from dbo.fPayment#GetPending(@personSID, sysdatetimeoffset())

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fPayment#GetPending'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

return
(
	select
		pmt.PaymentSID
	 ,ppr.PaymentProcessorResponseSID
	 ,ppr.ResponseTime
	 ,ppr.TransactionID
	 ,ppr.ResponseSource
	 ,ppr.ResponseDetails
	 ,pt.PaymentTypeSCD
	from
		dbo.Payment				pmt
	join
		dbo.PaymentStatus ps on pmt.PaymentStatusSID = ps.PaymentStatusSID and ps.PaymentStatusSCD = 'PENDING' -- pending payments only
	join
		dbo.PaymentType		pt on pmt.PaymentTypeSID = pt.PaymentTypeSID and left(pt.PaymentTypeSCD, 3) = 'PP.' -- payment processor type (credit card) only
	outer apply
	(
		select top (1)
			ppr.PaymentProcessorResponseSID
		from
			dbo.PaymentProcessorResponse ppr
		where
			ppr.PaymentSID = pmt.PaymentSID
		order by
			ppr.ResponseTime desc
		 ,ppr.PaymentProcessorResponseSID desc
	)										pprl
	join
		dbo.PaymentProcessorResponse ppr on pprl.PaymentProcessorResponseSID = ppr.PaymentProcessorResponseSID	-- avoid record if no response is received
	where
		pmt.CancelledTime is null and (@PersonSID = -1 or pmt.PersonSID = @PersonSID) -- filter result set to specific user where passed
		and pmt.UpdateTime												<= @CutOffTime
);
GO
