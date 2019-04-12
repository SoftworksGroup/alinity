SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPayment#Refund
	@Payments		 xml								-- keys of payment records to refund (1 to N keys supported)
 ,@ReasonSID	 int								-- key of dbo.Reason to code category of refund
 ,@Explanation nvarchar(500)			-- narrative text to display to registrant explaining the refund
 ,@InvoiceSID	 int = null output	-- optional - output value of (last) new refund invoice created
as

/*********************************************************************************************************************************
Sproc    : Payment Refund
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure records a refund for an unapplied payment amount by creating an invoice
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2017		|	Initial version
				: Tim Edlund					| Oct 2018		| Query tuning to improve performance (no logic changes).

Comments	
-------- 
This procedure is called from the UI to process refunds.  The procedure requires one or more payment keys, a reason for the
refund and an explanation for the refund.  Refunds are only allowed where an unapplied amount exists on the payment. The
explanation text provided is inserted as the description on the credit invoice. If a refund check is being issued, 
including the reference number in the description is recommended. Tax is never assessed on refund amounts.

More than one payment key may be passed but the reason and explanation values for all refunds must be the same. The keys must be 
passed in the XML parameter using the following format:

<Payments>
		<Payment SID="1003170" />
		<Payment SID="1000011" />
		<Payment SID="1000123" />
</Payments> 

DB transaction applied
----------------------
To process the refund an invoice must be inserted along with a line item, and an invoice-payment record.  All 3 records are
added as a single transaction (begin/commit).  If more than one payment is selected for refund processing, it is possible for
the first to succeed and be committed while a later refund fails validation. The first refund is saved.  No additional 
refunds are processed if an error is hit.

Known Limitations
-----------------
This version of the routine does not support partial refunds. The amount of the refund is set to the total unapplied
amount on the payment.  This limitation is implemented to simplify the process for the end user and is not a technical
limitation.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes a refund on an un-applied payment selected at random (changes rolled back).">
    <SQLScript>
      <![CDATA[
      
declare
	@paymentSID	 int
 ,@payments		 xml
 ,@reasonSID	 int
 ,@invoiceSID	 int
 ,@explanation nvarchar(500) = N'This is a test of the refund procedure.';

select top (1)
	@paymentSID = p.PaymentSID
from
	dbo.vPayment p
where
	p.TotalUnapplied > 0.00
order by
	newid();

set @payments = N'<Payments><Payment SID="' + ltrim(@paymentSID) + '" /></Payments>';

select top (1)
	@reasonSID = r.ReasonSID
from
	dbo.Reason r
where
	r.ReasonCode like 'PAYMENT.REFUND.%'
order by
	newid();

if @paymentSID is null or @reasonSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pPayment#Refund
		@Payments = @payments
	 ,@ReasonSID = @reasonSID
	 ,@Explanation = @explanation
	 ,@InvoiceSID = @invoiceSID output;

	select
		ii.InvoiceSID
	 ,ii.InvoiceItemDescription
	 ,ii.Price
	 ,ii.Quantity
	 ,ii.GLAccountCode ItemGLAccountCode
	 ,ii.IsRefund
	from
		dbo.vInvoiceItem ii
	where
		ii.InvoiceSID = @invoiceSID;

	rollback
end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pPayment#Refund'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				 nvarchar(4000)									-- message text for business rule errors
	 ,@blankParm				 varchar(50)										-- tracks name of any required parameter not passed
	 ,@ON								 bit					 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF							 bit					 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@paymentSID				 int														-- next payment to process
	 ,@personSID				 int														-- individual to apply refund for (the payer)
	 ,@creditAccountCode varchar(50)										-- GL code to be credited in the refund (bank account)
	 ,@amountToRefund		 decimal(11, 2)									-- unapplied amount on the invoice
	 ,@i								 int														-- loop iteration counter
	 ,@maxrow						 int;														-- loop limit

	declare @work table (ID int identity(1, 1), PaymentSID int not null);

	set @InvoiceSID = null;

	begin try

		-- check parameters

		-- SQL Prompt formatting off
		if @Explanation is null	set @blankParm = '@Explanation';
		if @ReasonSID		is null	set @blankParm = '@ReasonSID';
		if @Payments		is null	set @blankParm = '@Payments';
		-- SQL Prompt formatting on

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		-- parse XML key values into table for processing

		insert
			@work (PaymentSID)
		select
			Payment.p.value('@SID', 'int')
		from
			@Payments.nodes('//Payment') Payment(p);

		set @maxrow = @@rowcount;
		set @i = 0;

		while @i < @maxrow
		begin

			set @i += 1;

			select @paymentSID = w .PaymentSID from @work w where w.ID = @i;

			select
				@amountToRefund		 = pt.TotalUnapplied
			 ,@personSID				 = p.PersonSID
			 ,@creditAccountCode = p.GLAccountCode
			from
				dbo.Payment																 p
			outer apply dbo.fPayment#Total(p.PaymentSID) pt
			join
				dbo.GLAccount ga on ga.IsUnappliedPaymentAccount = @ON
			where
				p.PaymentSID = @paymentSID;

			-- validate each refund before processing it

			if @personSID is null or @creditAccountCode is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'dbo.Payment'
				 ,@Arg2 = @paymentSID;

				raiserror(@errorText, 18, 1);
			end;

			if isnull(@amountToRefund, 0.00) <= 0.00
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NothingToRefund'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'There is no unapplied amount to refund on this payment (%1).'
				 ,@Arg1 = @paymentSID;

				raiserror(@errorText, 16, 1);
			end;

			begin transaction; -- treat each refund as a separate transaction

			exec dbo.pInvoice#Insert
				@InvoiceSID = @InvoiceSID output
			 ,@PersonSID = @personSID
			 ,@IsRefund = @ON
			 ,@ReasonSID = @ReasonSID;

			exec dbo.pInvoiceItem#Insert
				@InvoiceSID = @InvoiceSID
			 ,@InvoiceItemDescription = @Explanation
			 ,@Price = @amountToRefund
			 ,@IsTaxRate1Applied = @OFF
			 ,@IsTaxRate2Applied = @OFF
			 ,@IsTaxRate3Applied = @OFF
			 ,@Quantity = 1
			 ,@GLAccountCode = @creditAccountCode;

			exec dbo.pInvoicePayment#Insert
				@InvoiceSID = @InvoiceSID
			 ,@PaymentSID = @paymentSID
			 ,@AmountApplied = @amountToRefund;

			commit;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
