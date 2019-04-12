SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pPayment#ReApply]
	@PaymentSID	 int								-- payment record to re-apply 
 ,@Adjustments int = null output	-- count of invoice payment records adjusted
as
/*********************************************************************************************************************************
Sproc    : Payment - Reapply (to invoices)
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure checks application of payment to invoice payment records and adjusts totals where necessary
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Tim Edlund				| Nov 2017 	 | Initial version
				 : Tim Edlund				| Jan 2018	 | Set audit user to currently logged in user rather than dbo.Payment update user
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure is most frequently called from dbo.pPayment#Update in the "post" event.  The payment record has been updated and
it is possible the amount on the payment has been edited.  These scenarios arise most often through split payments where the
original amount inserted with the payment is changed.  The update changes the value on the parent payment but the child 
dbo.InvoicePayment record must also be updated.

For example:

Suppose an individual chooses to split pay a $350 invoice by first processing $200 on their first credit card.  The payment
of $200 is entered which causes an invoice-payment with an applied amount of $200 to be entered.  They then back away from
that process and change their amount to $350 before going to the credit card page.  The $200 amount is still on the invoice
payment and requires updating.

A similar scenario can occur in the other direction where the original amount is $350 but the user decides to split the 
payment afterward - reducing the amount to $200.  In that case the invoice-payment will have $350 on it and will again
require adjustment.

Both of these examples are assuming a single invoice is being paid but the similar adjustments are required when the record 
is paying multiple invoices.

This procedure compares the total on the payment header record (dbo.Payment) with the sum of all applied amounts on related
invoice-payment records (dbo.InvoicePayment).  If the totals do not agree the applied amounts may need editing.  The procedure
only updates the invoice-payment records when amounts actually require changing. It is possible the payment does not agree
with the applied amounts because the invoice(s) is/are fully paid and the payment amount is great so some of it remains
unapplied. It is also possible NO invoices have been targeted for the payment (no related dbo.InvoicePayment) records
in which case no action is taken. 

@Adjustments
------------
The output variable is provided to advise the caller about the count of adjustment to invoice payment records actually 
made.  If the value is 0, no changes were made.  If the value is > 0 the caller will need to call the GL Repost action.
The call should be made to dbo.GLTransaction#PostPayment so that the parent payment row changes are also captured for 
General Ledger reporting.

Call Syntax
-----------
declare
	@paymentSID				 int
 ,@adjustments			 int
 ,@invoicePaymentSID int;

select top 1 -- find a payment record at random
	@paymentSID				 = p.PaymentSID
 ,@invoicePaymentSID = ip.InvoicePaymentSID
from
	dbo.Payment				 p
join
	dbo.InvoicePayment ip on p.PaymentSID = ip.PaymentSID
where
	p.CancelledTime is null and ip.AmountApplied > 0.00 -- not cancelled, has an application
order by
	newid();

update
	dbo.InvoicePayment -- create test by changing applied amount +/- $1 with some $0 adjustments (no change)
set
	AmountApplied = AmountApplied + (case when InvoicePaymentSID % 4 = 0 then 0 else (case when InvoicePaymentSID % 2 = 0 then 1.00 else -1.00 end) end)
where
	InvoicePaymentSID = @invoicePaymentSID;

select
	ip.InvoicePaymentSID
 ,ip.InvoiceSID
 ,ip.PaymentSID
 ,ip.AmountApplied
from
	dbo.InvoicePayment ip
where
	ip.InvoicePaymentSID = @invoicePaymentSID; -- show record before adjustment

exec dbo.pPayment#ReApply -- call procedure
	@PaymentSID = @paymentSID
 ,@Adjustments = @adjustments output;

select -- show record after adjustment
	ip.InvoicePaymentSID
 ,ip.InvoiceSID
 ,ip.PaymentSID
 ,ip.AmountApplied
from
	dbo.InvoicePayment ip
where
	ip.InvoicePaymentSID = @invoicePaymentSID;

print 'ok - ' + ltrim(@adjustments) + ' adjustments applied';

------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo					 int					 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				 nvarchar(4000)																					-- message text for business rule errors
	 ,@blankParm				 varchar(50)																						-- tracks name of any required parameter not passed
	 ,@amountPaid				 decimal(11, 2)																					-- amount of the payment
	 ,@totalApplied			 decimal(11, 2)																					-- total of existing applications of the payment
	 ,@amountApplied		 decimal(11, 2)																					-- amount to apply on current invoice (adjusted amount)
	 ,@previousAmount		 decimal(11, 2)																					-- amount applied on current invoice (before adjustment)
	 ,@appliedCount			 int																										-- count of invoices paid by the payment
	 ,@paymentStatusSCD	 varchar(25)																						-- status of payment 
	 ,@invoicePaymentSID int																										-- next applied payment to process
	 ,@updateUser				 nvarchar(75)	 = sf.fApplicationUserSession#UserName(); -- user making the changes

	set @Adjustments = 0;

	begin try

		-- check parameters

		if @PaymentSID is null set @blankParm = '@PaymentSID';

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		select
			@amountPaid				= p.AmountPaid
		 ,@paymentStatusSCD = ps.PaymentStatusSCD
		from
			dbo.Payment				p
		join
			dbo.PaymentStatus ps on p.PaymentStatusSID = ps.PaymentStatusSID
		where
			p.PaymentSID = @PaymentSID;

		if @amountPaid is null or @paymentStatusSCD is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.Payment'
			 ,@Arg2 = @PaymentSID;

			raiserror(@errorText, 18, 1);
		end;

		-- if the payment is cancelled or declined, ensure all
		-- applied amounts for the payments are set to 0

		if @paymentStatusSCD in ('DECLINED', 'CANCELLED')
		begin

			update
				dbo.InvoicePayment
			set
				AmountApplied = 0.00
			 ,UpdateUser = @updateUser
			 ,UpdateTime = sysdatetimeoffset()
			where
				PaymentSID = @PaymentSID and AmountApplied <> 0.00;

			set @Adjustments = @@rowcount;

		end;
		else
		begin

			-- sum existing applications of the payment

			select
				@totalApplied			 = cast(sum(ip.AmountApplied) as decimal(11, 2))
			 ,@appliedCount			 = count(1)
			 ,@invoicePaymentSID = max(ip.InvoicePaymentSID)
			from
				dbo.InvoicePayment ip
			where
				ip.PaymentSID = @PaymentSID and ip.CancelledTime is null;

			-- if the total applied is not the same as the
			-- total paid, then adjustments may be required

			if @amountPaid <> @totalApplied and @appliedCount > 0
			begin

				-- more than once invoice may be the target of this payment
				-- so loop through all related invoice payments in order of
				-- their primary key value and adjust amounts where required

				set @invoicePaymentSID = -1;

				while @invoicePaymentSID is not null
				begin

					set @amountApplied = 0.00;

					-- the amount to apply will be the lesser of the amount of the
					-- total payment to distribute and the amount owing on each invoice
					-- (with previous applied payment added back onto total due) 

					select top (1)
						@invoicePaymentSID = ip.InvoicePaymentSID
					 ,@previousAmount		 = ip.AmountApplied
					 ,@amountApplied		 = (case
																		when @amountPaid = 0.00 then 0.00
																		when @amountPaid > (it.TotalDue + ip.AmountApplied) then (it.TotalDue + ip.AmountApplied)
																		else @amountPaid
																	end
																 )
					from
						dbo.InvoicePayment													ip
					cross apply dbo.fInvoice#Total(ip.InvoiceSID) it
					where
						ip.PaymentSID = @PaymentSID and ip.CancelledTime is null and ip.InvoicePaymentSID > @invoicePaymentSID
					order by
						ip.InvoicePaymentSID;

					if @@rowcount = 0
					begin
						set @invoicePaymentSID = null; -- exit loop - no more found
					end;
					else if @previousAmount <> @amountApplied
					begin

						-- update the applied amount if the new calculated
						-- amount is different (otherwise row is not modified)

						update
							dbo.InvoicePayment
						set
							AmountApplied = @amountApplied
						 ,UpdateUser = @updateUser
						 ,UpdateTime = sysdatetimeoffset()
						where
							InvoicePaymentSID = @invoicePaymentSID and AmountApplied <> @amountApplied;

						set @Adjustments += @@rowcount; -- update should only find row when amount applied is changing to avoid unnecessary GL Posting by caller!

					end;

					set @amountPaid -= @amountApplied; -- reduce the amount remaining to distribute

				end;
			end;
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
