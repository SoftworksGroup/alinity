SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pGLTransaction#PostPayment]
	@PaymentSID				int					-- key of dbo.Payment record to post transactions for
 ,@ActionCode				varchar(10) -- action to handle posting for: INSERT or UPDATE
 ,@PostingDate			date				-- date to assign to the posting (required!)
 ,@PreviousCheckSum int = null	-- value of check-sum on previous version of record
as
/*********************************************************************************************************************************
Sproc    : Transaction - Post Payment
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure creates dbo.GLTransaction records to record the accounting for new or modified dbo.Payment records
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- + ---------- + ---------------------------------------------------------------------------------------
				 : Tim Edlund				| Oct 2017 	 | Initial version
				 : Tim Edlund				| Nov 2017	 | Updated to use #Ext view to obtain checksum. Added call to #PostInvoicePayment
				 : Tim Edlund				| Jan 2018	 | Added check to avoid duplicate GL trx on race condition when verified CC payment
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure is responsible for posting the GL transaction for the dbo.Payment record and calls #PostInvoicePayment to process
the revenue GL transactions for the applied payment.  When the procedure is called the inserted or updated payment records have
already been saved to the dbo.Payment table. If no invoice payments have been entered yet, the call to #PostInvoicePayment is
avoided.  

The procedure creates a record in the dbo.GLTransaction table.  If a previous posting exists - and changes have occurred to the 
source transaction - then the previous entry is reversed before the new one is inserted.

The posting action takes the GL account code associated with the payment type and applies it as the debit code (bank account). The 
credit code is always the "Unapplied Payment" account. This is an interim account where, as soon as the payment is applied against 
one or more invoices, the Unapplied Payment is debited and the funds applied against revenue and tax accounts as specified on the 
Invoice. This typically happens within the same overall transaction but if an invoice is not immediately identified for payment 
then the amount sits i the unapplied account in the interim.

For details of the accounts used in postings for the invoice payment (revenue and tax accounts), see #PostInvoicePayment.

Cancelling a Payment
--------------------
As soon as a payment is saved in a PAID status (which occurs immediately for a cheque or cash payment), a GL Transaction is 
generated for it.  Payments cannot be deleted through the user interface once a GL account is created for them.  They can, 
however, be cancelled.

When this procedure sees that the cancelled time is set on the payment, it reverses the previous GL Transaction for it. This is 
achieved by entering a new transaction which reverses the GL accounts on the previous ones.  The amount is kept the same as on 
the original transaction and the current date is assigned to the posting.  This has the effect of exactly reversing 
the previous entry.

Updating a Payment
------------------
When a payment is updated a new checksum is calculated which is then compared to the previous GL Transaction for the payment.  The 
checksum changes when then GL Posting Date, Status, GL account code (debit side/bank), or the amount has changed.  If the checksum 
is different than the previous transaction, the previous transaction is reversed using the logic described in the paragraph above. 
While this procedure avoids reversing and reposting an entry if the checksum has not changed, the call to this procedure is 
avoided altogether when the payment is changed through #Update procedures since the checksums are compared there before calling.

Note that if a payment changes from a paid status to a non-paid status - e.g. a check is returned NSF - then the original GL
entry is reversed and no new entry is created.

Posting called on related Invoice Payments on UPDATE (only)
-----------------------------------------------------------
When a payment changes paid status - e.g. check is recorded as NSF, or a credit card payment is verified - any Invoice-Payment
records associated with the payment also need posting. This procedure makes the call to handle these posts as well.  Note
that the pInvoicePayment#Insert/#Update sprocs must still call the invoice payment posting logic directly since it is possible
for the status of the applied-payment to change independently of the payment header.  For example, this occurs if an amount
applied against an invoice is unapplied so that it can be moved to a different invoice.  

The procedure avoids making unnecessary calls to the invoice-payment posting routine by comparing checksums and only making
the call if changes have occurred that require GL adjustments.

Call Syntax
-----------
In order to avoid the risk of duplicate GL entries, this procedure is best tested by inserting a payment record.
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo										int							 = 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText									nvarchar(4000)											-- message text for business rule errors
	 ,@blankParm									varchar(50)													-- tracks name of any required parameter not passed
	 ,@currentCheckSum						int																	-- comparison (hash value) value for current transaction
	 ,@isPaid											bit																	-- tracks whether payment is now in a "PAID" status
	 ,@amountPaid									decimal(11, 2)											-- amount paid (from payment)
	 ,@amountApplied							decimal(11, 2)											-- amount applied (from invoice payment)
	 ,@isCancelled								bit																	-- tracks whether cancelled time column is filled in
	 ,@cancelledTime							datetimeoffset(7)										-- date and time of cancellation
	 ,@lastPostingDate						date																-- date of posting recorded in the payment record
	 ,@bankAccountCode						varchar(50)													-- GL code for account receiving the funds (debit)
	 ,@unappliedAccountCode				varchar(50)													-- GL code for credit side of payment entry (credit)
	 ,@isPosted										bit																	-- tracks whether posting action occurred
	 ,@isPAPPayment								bit																	-- tracks whether payment is pre-authorized (uses the deferred account)
	 ,@isExcluded									bit																	-- indicates if this payment should be excluded from posting to the GL
	 ,@nextInvoicePaymentSID			int																	-- key of next invoice payment to post
	 ,@nextInvoicePaymentCheckSum int																	-- checksum of the next IP record to process
	 ,@ON													bit							 = cast(1 as bit)		-- constant for bit comparisons = 1
	 ,@OFF												bit							 = cast(0 as bit);	-- constant for bit comparison = 0

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @ActionCode = 'UPDATE' and @PreviousCheckSum is null set @blankParm = '@PreviousCheckSum';
		if @ActionCode is null set @blankParm = '@ActionCode';
		if @PaymentSID is null set @blankParm = '@PaymentSID';
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

		if @ActionCode not in ('INSERT', 'UPDATE')
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NotInList'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 provided "%2" is not valid. It must be one of: %3'
			 ,@Arg1 = 'payment posting action'
			 ,@Arg2 = @ActionCode
			 ,@Arg3 = '"INSERT", "UPDATE"';

			raiserror(@errorText, 18, 1);
		end;

		-- lookup the payment to obtain values for
		-- processing logic

		select
			@isPaid					 = p.IsPaid
		 ,@currentCheckSum = p.GLCheckSum -- always use view to obtain this in case of update to checksum content!
		 ,@amountPaid			 = p.AmountPaid
		 ,@lastPostingDate = p.GLPostingDate
		 ,@bankAccountCode = p.GLAccountCode
		 ,@isCancelled		 = (case when p.CancelledTime is not null then @ON else @OFF end)
		 ,@cancelledTime	 = p.CancelledTime
		 ,@isPAPPayment		 = (case when p.PaymentTypeSCD = 'PAP' then @ON else @OFF end)
		 ,@isExcluded			 =
		 (case
				when p.PaymentTypeSCD = 'PAP' and @PostingDate < p.ExcludeDepositFromGLBefore then @ON -- PAP deposits can be configured as non-posting to a conversion point
				else @OFF																																							 -- all other payment scenarios post to the GL
			end
		 )
		from
			dbo.vPayment p
		where
			p.PaymentSID = @PaymentSID;

		if @isPaid is null or @currentCheckSum is null or @bankAccountCode is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.Payment'
			 ,@Arg2 = @PaymentSID;

			raiserror(@errorText, 18, 1);
		end;

		-- obtain unapplied payment code for the credit
		-- side of the entry; for PAP use deferred if configured

		select
			@unappliedAccountCode = (case when @isPAPPayment = @ON then isnull(ga.DeferredGLAccountCode, ga.GLAccountCode) else ga.GLAccountCode end)
		from
			dbo.GLAccount ga
		where
			ga.IsUnappliedPaymentAccount = @ON;

		if @unappliedAccountCode is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'InvalidGLConfiguration'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The GL Account configuration is incomplete: the "%1" is missing.'
			 ,@Arg1 = 'Unapplied Payment Account';

			raiserror(@errorText, 17, 1);

		end;

		-- if the record was updated and the checksum is now
		-- different, or, if cancelling - reverse the previous
		-- GL transactions for the payment and old check sum

		if (
				 @ActionCode = 'UPDATE' and @PreviousCheckSum <> @currentCheckSum
			 ) or @isCancelled = @ON
		begin

			if @isCancelled = @ON
				set @PostingDate = sf.fDTOffsetToClientDate(@cancelledTime); -- if cancelled, use cancelled time for the post

			insert
				dbo.GLTransaction
			(
				PaymentSID
			 ,PaymentCheckSum
			 ,CreditGLAccountCode				-- insert new records that reverse the credit<->debit from the previous
			 ,DebitGLAccountCode
			 ,Amount
			 ,ReversedGLTransactionSID	-- store key of trx being reversed for reference
			 ,GLPostingDate
			)
			select
				gt.PaymentSID
			 ,gt.PaymentCheckSum
			 ,gt.DebitGLAccountCode
			 ,gt.CreditGLAccountCode
			 ,gt.Amount
			 ,gt.GLTransactionSID
			 ,@PostingDate
			from
				dbo.GLTransaction gt -- if the transaction is already reversing avoid it (reversing an already reversed entry is NOT allowed)
			left outer join
				dbo.GLTransaction gt2 on gt.GLTransactionSID = gt2.ReversedGLTransactionSID -- if this transaction has already been reversed, don't reverse it again
			where
				gt.PaymentSID = @PaymentSID and gt.PaymentCheckSum = @PreviousCheckSum and gt.ReversedGLTransactionSID is null and gt2.GLTransactionSID is null
			order by
				gt.CreateTime
			 ,gt.GLTransactionSID;

		-- if no transactions are found no error is reported because the
		-- previous instance of the record may not have been in a paid status
		-- and was therefore never posted, or was already cancelled

		end;

		-- a new GL transaction is inserted if the payment is in a PAID status
		-- and, when updating if the previous check sum changed, or, if a new payment 

		if @isPaid = @ON and @isCancelled = @OFF and
										 (
											 (
												 @ActionCode = 'UPDATE' and @PreviousCheckSum <> @currentCheckSum
											 ) or @ActionCode = 'INSERT'
										 )
		begin

			if @amountPaid <> 0.00 and not exists
			(
				select
					1
				from
					dbo.GLTransaction trx
				where
					trx.PaymentSID = @PaymentSID and trx.InvoicePaymentSID is null and trx.PaymentCheckSum = @currentCheckSum -- perform final check to ensure record does not already exist
			)
			begin

				insert
					dbo.GLTransaction
				(
					PaymentSID
				 ,DebitGLAccountCode
				 ,CreditGLAccountCode
				 ,Amount
				 ,GLPostingDate
				 ,PaymentCheckSum
				 ,IsExcluded
				)
				values
				(
					@PaymentSID, @bankAccountCode, @unappliedAccountCode, @amountPaid, @PostingDate, @currentCheckSum, @isExcluded
				);

			end;

			set @isPosted = @ON;

			-- if the posting date changed or has not yet been set
			-- then update it on the payment

			if @lastPostingDate is null or sf.fIsDifferent(@PostingDate, @lastPostingDate) = @ON
			begin

				update
					dbo.Payment
				set
					GLPostingDate = @PostingDate
				where
					PaymentSID = @PaymentSID;

			end;

		end;

		-- if a posting action occurred then look for associated
		-- invoice-payments that will require posting updates

		if @isPosted = @ON
		begin

			set @nextInvoicePaymentSID = -1;
			set @nextInvoicePaymentCheckSum = -1;

			while @nextInvoicePaymentCheckSum is not null
			begin

				set @nextInvoicePaymentCheckSum = null;
				set @isCancelled = @OFF;

				select top (1)
					@nextInvoicePaymentSID			= ip.InvoicePaymentSID
				 ,@nextInvoicePaymentCheckSum = ip.GLCheckSum
				 ,@isCancelled								= (case when ip.CancelledTime is not null then @ON else @OFF end)
				 ,@amountApplied							= ip.AmountApplied
				from
					dbo.vInvoicePayment ip
				where
					ip.PaymentSID						 = @PaymentSID
					and ip.InvoicePaymentSID > @nextInvoicePaymentSID
					and not exists
				(
					select
						1
					from
						dbo.GLTransaction trx
					where
						trx.PaymentSID = @PaymentSID and isnull(trx.InvoicePaymentSID, 0) = ip.InvoicePaymentSID and trx.PaymentCheckSum = @currentCheckSum -- no GL transactions exist for this record for the current status of the parent payment 
				)
				order by
					ip.InvoicePaymentSID;

				if @nextInvoicePaymentCheckSum is not null and isnull(@isCancelled, @OFF) = @OFF and isnull(@amountApplied, 0.00) <> 0.00 -- if the payment application was unapplied (cancelled) or 0 don't repost it
				begin

					exec dbo.pGLTransaction#PostInvoicePayment
						@InvoicePaymentSID = @nextInvoicePaymentSID
					 ,@ActionCode = 'UPDATE'
					 ,@PreviousCheckSum = @nextInvoicePaymentCheckSum
					 ,@PostingDate = @PostingDate;

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
