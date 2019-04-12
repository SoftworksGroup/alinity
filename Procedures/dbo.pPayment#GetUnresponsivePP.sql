SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPayment#GetUnresponsivePP
	@CutoffMinutes int = -2	-- limits records to only those that have been created before the current time minus this value
as
/*********************************************************************************************************************************
Sproc    : Payment - Get Unresponsive PP (Payment Processor) payments
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns on-line payment records where no response from the processor is recorded
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Kris Dawson         | Oct 2018		|	Initial version

Comments	
--------
This procedure is called by a dashboard widget to retrieve a list of on-line payment records where no response from
the processor has been recorded within a certain cutoff period (to avoid returning records that are pending user
input on the processor form). These records may be abandoned payments, payments where the user has yet to enter their
credit card information or where somehow neither the user browser nor the credit card processor server (e.g. Moneris)
managed to send a response to the Alinity web server.

Example
-------
<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Executes the procedure to return unresponsive records.
	Data set returned may be blank.">
    <SQLScript>
      <![CDATA[

exec dbo.pPayment#GetUnresponsivePP

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pPayment#GetUnresponsivePP'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		int								= 0						-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	nvarchar(4000)									-- message text for business rule errors
	 ,@personSID	int															-- person to search for pending payments
	 ,@cutoffTime datetimeoffset(7);

	begin try

		-- if the value is not negative multiply by -1, if the value is null set to -2

		set @CutoffMinutes = (case when @CutoffMinutes > 0 then @CutoffMinutes * -1 when @CutoffMinutes is null then -2 else @CutoffMinutes end)
		set @cutoffTime = dateadd(minute, @CutoffMinutes, sysdatetimeoffset());	-- calculated cut off from current (server) time

		select
			pmt.PaymentSID
		 ,pmt.UpdateTime
		 ,pmt.PersonSID
		 ,r.RegistrantNo
		 ,dbo.fRegistrant#Label(person.LastName, person.FirstName, person.MiddleNames, r.RegistrantNo, 'REGISTRANT') + ' '
			+ ' ' + format(pmt.AmountPaid, 'C')																				PaymentLabel
		from
			dbo.Payment				pmt
		join
			sf.Person					person on pmt.PersonSID = person.PersonSID
		join
			dbo.PaymentStatus ps on pmt.PaymentStatusSID = ps.PaymentStatusSID and ps.PaymentStatusSCD = 'PENDING' -- pending payments only
		join
			dbo.PaymentType		pt on pmt.PaymentTypeSID = pt.PaymentTypeSID and left(pt.PaymentTypeSCD, 3) = 'PP.' -- payment processor type (credit card) only
		join
			dbo.vPayment#Ext	pe on pmt.PaymentSID = pe.PaymentSID
		left outer join
			dbo.PaymentProcessorResponse ppr on pmt.PaymentSID = ppr.PaymentSID 
		left outer join
			dbo.Registrant r on pmt.PersonSID = r.PersonSID
		where
			pmt.UpdateTime <= @cutoffTime
		and 
			ppr.PaymentProcessorResponseSID is null

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
