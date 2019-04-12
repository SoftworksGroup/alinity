SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pGLTransaction#PostInvoicePayment
	@InvoicePaymentSID int					-- key of dbo.InvoicePayment record to post transactions for
 ,@ActionCode				 varchar(10)	-- action to handle posting for: INSERT or UPDATE
 ,@PostingDate			 date					-- date to assign to the posting (required)
 ,@PreviousCheckSum	 int = null		-- value of check-sum on previous version of record
as
/*********************************************************************************************************************************
Sproc    : Transaction - Post Payment
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure creates dbo.GLTransaction records to record the accounting for new or modified dbo.InvoicePayment records
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Tim Edlund				| Oct 2017 	 | Initial version
				 : Tim Edlund				| Nov 2017	 | Updated to use #Ext view to obtain checksum. 
				 : Tim Edlund				| Jan 2018	 | Updated to handle posting of late fee last (see fInvoicePayment#GLTransaction)
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure is responsible for posting the GL Transactions associated with the records that apply payments against invoices
(dbo.InvoicePayment)  When the procedure is called the inserted or updated invoice-payment records have already been saved to 
the table. 

Deleting/Cancelling an Invoice-Payment
--------------------------------------
Deleting an invoice payment is only possible where no GL Transactions were posted for it.  This can only occur if the parent
record (dbo.Payment) was never in a paid status. As soon as an invoice-payment record is saved where the parent dbo.Payment
is in a PAID status (which occurs immediately for a cheque or cash payment), a GL Transaction is generated for it.  After that, 
to undo or reverse the GL Transaction, the invoice-payment must be cancelled by filling in the Cancelled-Time column.

The UI provides support for users to un-apply dbo.InvoicePayment records individually, or by cancelling the parent payment which 
cancels all applications. In either method the CancelledTime on the dbo.InvoicePayment record is set.

When this procedure sees that the cancelled time is set on the invoice payment, it reverses the previous GL Transaction for it
if one exists.  The previous transaction for the payment key and check-sum passed in is re-inserted with the debit and credit 
codes reversed. The amount is kept the same as on the original transaction and the current date is assigned to the posting.  This 
has the effect of exactly reversing the previous entry - but with a current posting date to keep the GL stable for the prior day.

Updating an Invoice-Payment
---------------------------
When an invoice-payment is updated a new checksum is calculated which is then compared to the previous GL Transaction for the 
record.  The checksum changes when the Invoice being paid, parent Payment key or the Amount Applied change.  If the checksum is 
different than the previous transaction, the previous transaction is reversed using the logic described in the paragraph above.

New transactions are then inserted for the invoice payment as long as the payment is in a PAID status. If the payment is now in a 
non-PAID status, then no new transactions are inserted.

New Payments
------------
No reversing logic is required for new invoice payment records. The procedure inserts the GL Transactions where the parent payment 
is in a PAID status.

Call Syntax
-----------
In order to avoid the risk of duplicate GL entries, this procedure is best tested by inserting a payment record.
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)										-- message text for business rule errors
	 ,@blankParm						varchar(50)												-- tracks name of any required parameter not passed
	 ,@ON										bit							 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF									bit							 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@paymentSID						int																-- key of the parent dbo.Payment record
	 ,@invoiceSID						int																-- key of the parent dbo.Invoice record (source of GL coding)
	 ,@currentCheckSum			int																-- comparison (hash value) value for current transaction
	 ,@paymentCheckSum			int																-- comparison (hash value) value for parent payment transaction
	 ,@isPaid								bit																-- tracks whether payment is now in a "PAID" status
	 ,@amountApplied				decimal(11, 2)										-- amount paid
	 ,@isPAPPayment					bit																-- tracks whether payment is pre-authorized (uses the deferred account)
	 ,@isExcluded						bit																-- indicates if this payment should be excluded from posting to the GL
	 ,@unappliedAccountCode varchar(50)												-- GL code for credit side of payment entry (credit) 
	 ,@isCancelled					bit																-- tracks whether cancelled time column is filled in
	 ,@cancelledTime				datetimeoffset(7)									-- date and time of cancellation
	 ,@lastPostingDate			date															-- date of posting recorded in the applied payment record

	begin try

		-- check parameters

		if @ActionCode = 'UPDATE' and @PreviousCheckSum is null
		begin
			set @blankParm = '@PreviousCheckSum';
		end;

-- SQL Prompt formatting off
		if @ActionCode is null				set @blankParm = '@ActionCode';
		if @InvoicePaymentSID is null	set @blankParm = '@InvoicePaymentSID';
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
			@paymentSID			 = ip.PaymentSID
		 ,@invoiceSID			 = ip.InvoiceSID
		 ,@isPaid					 = ip.IsPaid			-- whether paid or not (from the parent dbo.Payment)
		 ,@currentCheckSum = ip.GLCheckSum	-- always use view to obtain this in case of update to checksum content!
		 ,@paymentCheckSum = px.GLCheckSum	-- check sum of parent must be checked to determine if status has changed
		 ,@amountApplied	 = ip.AmountApplied
		 ,@isCancelled		 = (case when ip.CancelledTime is not null then @ON else @OFF end)
		 ,@cancelledTime	 = ip.CancelledTime
		 ,@lastPostingDate = ip.GLPostingDate
		 ,@isPAPPayment		 = (case when px.PaymentTypeSCD = 'PAP' then @ON else @OFF end)
		 ,@isExcluded			 = (case
														when ip.IsRefund = @ON and px.IsRefundExcludedFromGL = @ON then @ON -- refunds can be configured as excluded
														else @OFF																														-- all other payment scenarios post to the GL
													end
												 )
		from
			dbo.vInvoicePayment ip
		join
			dbo.vPayment#Ext		px on ip.PaymentSID = px.PaymentSID
		where
			ip.InvoicePaymentSID = @InvoicePaymentSID;

		if @paymentSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.InvoicePayment'
			 ,@Arg2 = @InvoicePaymentSID;

			raiserror(@errorText, 18, 1);
		end;

		-- obtain unapplied payment code for the debit
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

		-- if the record was updated and the checksum is now different, or it was 
		-- cancelled or has moved to a non-paid status, then reverse the previous 
		-- GL transactions (if they exist)

		if (
				 @ActionCode = 'UPDATE' and @PreviousCheckSum <> @currentCheckSum
			 ) or @isCancelled = @ON or @isPaid = @OFF
		begin

			if @isCancelled = @ON
			begin
				set @PostingDate = sf.fDTOffsetToClientDate(@cancelledTime); -- if cancelled, use cancelled time for the post
			end;

			insert
				dbo.GLTransaction
			(
				PaymentSID
			 ,InvoicePaymentSID
			 ,PaymentCheckSum
			 ,InvoicePaymentCheckSum
			 ,CreditGLAccountCode
			 ,DebitGLAccountCode				-- insert new records that reverse the credit<->debit from the previous
			 ,Amount
			 ,ReversedGLTransactionSID	-- store key of trx being reversed for reference
			 ,GLPostingDate
			)
			select
				gt.PaymentSID
			 ,gt.InvoicePaymentSID
			 ,gt.PaymentCheckSum
			 ,gt.InvoicePaymentCheckSum
			 ,gt.DebitGLAccountCode
			 ,gt.CreditGLAccountCode
			 ,gt.Amount
			 ,gt.GLTransactionSID
			 ,@PostingDate
			from
				dbo.GLTransaction gt
			left outer join
				dbo.GLTransaction gt2 on gt.GLTransactionSID = gt2.ReversedGLTransactionSID -- if this transaction has already been reversed, don't reverse again
			where
				gt.PaymentSID = @paymentSID and gt.InvoicePaymentCheckSum = @PreviousCheckSum and gt.ReversedGLTransactionSID is null and gt2.GLTransactionSID is null
			order by
				gt.CreateTime
			 ,gt.GLTransactionSID;

		-- if no transactions are found no error is reported because
		-- the previous instance of the record may not have been in 
		-- a paid status and was therefore never posted, or was already cancelled

		end;

		-- a new GL transaction is inserted if the payment (header) is in a PAID status,
		-- and, either 1) we are updating and the checksum is different, or, 2) it is a 
		-- new payment; or 3) the transactions were deleted or not saved due to an error

		if @isPaid = @ON and @isCancelled = @OFF and
										 (
											 (
												 @ActionCode = 'UPDATE' and @PreviousCheckSum <> @currentCheckSum
											 ) -- update impacting GL 
											 or @ActionCode = 'INSERT' -- new application of payment called from #Insert 
											 or not exists
		(
			select
				1
			from
				dbo.GLTransaction trx
			where
				trx.InvoicePaymentSID is not null and isnull(trx.InvoicePaymentSID, -1) = @InvoicePaymentSID -- no postings exist for this record yet
				and trx.PaymentCheckSum																									= @paymentCheckSum
		)
										 )
		begin

			-- the logic for determining the GL codes and amounts to post is
			-- encapsulated in the table function; see 
			-- dbo.fInvoicePayment#GLTransaction for details

			insert
				dbo.GLTransaction
			(
				PaymentSID
			 ,InvoicePaymentSID
			 ,DebitGLAccountCode
			 ,CreditGLAccountCode
			 ,Amount
			 ,GLPostingDate
			 ,InvoicePaymentCheckSum
			 ,PaymentCheckSum
			 ,IsExcluded
			)
			select
				@paymentSID
			 ,@InvoicePaymentSID
			 ,@unappliedAccountCode
			 ,x.GLAccountCode
			 ,x.AmountToPost
			 ,@PostingDate
			 ,@currentCheckSum
			 ,@paymentCheckSum
			 ,@isExcluded
			from
				dbo.fInvoicePayment#GLTransaction(@InvoicePaymentSID, @invoiceSID, @amountApplied, @PostingDate) x
			where
				isnull(x.AmountToPost,0.0) <> 0.0;

			-- if the posting date changed or has not yet been set
			-- then update it on the invoice-payment

			if @lastPostingDate is null or sf.fIsDifferent(@PostingDate, @lastPostingDate) = @ON
			begin

				update
					dbo.InvoicePayment
				set
					GLPostingDate = @PostingDate
				where
					InvoicePaymentSID = @InvoicePaymentSID;

			end;
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
