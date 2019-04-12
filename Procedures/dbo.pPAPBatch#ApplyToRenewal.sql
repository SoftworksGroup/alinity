SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPAPBatch#ApplyToRenewal
	@PAPBatchSID	int = null	-- when passed payment applications are limited to a specific PAP batch
 ,@ReturnSelect bit = 0			-- when 1 output values are returned as a dataset
 ,@DebugLevel		int = 0			-- when 1 or higher debug output is written to console, when >= 3 no updates are performed
as
/*********************************************************************************************************************************
Sproc    : PAP Batch - Apply to Renewal Invoices
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure TODO: Tim Edlund
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Jan 2019		|	Initial version

Comments	
--------
This is a utility procedure designed to correct situations where payments have been created for one or more PAP batches but
the payments were not successfully applied to renewal invoices that are outstanding.  This situation will not occur where
normal processing of batch payments succeed, but may arise when errors occur and in conversion scenarios.

The procedure may be called with a single PAP batch key or left blank to scan all PAP payments which are unapplied. The 
unapplied payments must be associated with a renewal invoice that is unpaid. The association made is based on the renewal
invoice having been created for the same person on the payment. If more than one renewal invoice outstanding, the last 
(latest) renewal invoice is considered.

The procedure applies the payment found in a loop through dbo.pInvoicePayment#Insert. Where a payment results in the renewal
invoice having been fully paid, and where the associated form is APPROVED, the license/permit will also be created (via the
logic in the #insert sproc).

If the process fails, it can be restarted to pick-up remaining transactions.  A DB transaction is not used outside the 
processing loop.  

A debug level can be passed to print results of the process to the console. A value of 3 or more suppresses any changes from
being made to the database.

Example
-------
<TestHarness>
  <Test Name = "Unapplied" IsDefault ="true" Description="Executes the procedure for the first PAP batch with unapplied payments">
    <SQLScript>
      <![CDATA[

declare @papBatchSID int;

select top (1)
	@papBatchSID = x.PAPBatchSID
from
(
	select -- isolate pre-authorized payments that are fully unapplied
		pb.PAPBatchSID
		,pmt.PersonSID
	from
		dbo.Payment																	 pmt
	join
		dbo.PAPTransaction													 pt on pmt.PaymentSID = pt.PaymentSID
	join
		dbo.PAPBatch																 pb on pt.PAPBatchSID = pb.PAPBatchSID
	outer apply dbo.fPayment#Total(pmt.PaymentSID) ptot
	where
		(@papBatchSID is null or pb.PAPBatchSID = @papBatchSID) -- limit to a batch key if provided otherwise scan all batches
		and ptot.TotalApplied										= 0 and ptot.TotalUnapplied > 0 -- must be fully unapplied to qualify

)																							x
join -- look for latest renewal invoice for the person (exclude if no renewal invoice)
(
	select
		i.PersonSID
	 ,max(i.InvoiceSID) InvoiceSID	-- in case more than one renewal invoice, take latest
	from
		dbo.Invoice						i
	join
		dbo.RegistrantRenewal rnw on i.InvoiceSID = rnw.InvoiceSID	-- only renewal invoices considered
	group by
		i.PersonSID
)																							ri on x.PersonSID = ri.PersonSID
outer apply dbo.fInvoice#Total(ri.InvoiceSID) it
where
	it.TotalDue > 0.00
order by 
	x.PAPBatchSID

if @@rowcount = 0 or @papBatchSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	print @papBatchSID

	exec dbo.pPAPBatch#ApplyToRenewal
		@PAPBatchSID = @papBatchSID
	 ,@ReturnSelect = 1
	 ,@DebugLevel = 2;

	select
		pmt.Reference
	 ,pmt.PaymentSID
	 ,pmt.PaymentTypeSCD
	 ,pmt.AmountPaid
	 ,cast(pmt.CreateTime as date) CreateDate
	 ,pmt.GLPostingDate
	 ,ipmt.InvoicePaymentSID
	 ,ipmt.InvoiceSID
	 ,ipmt.AmountApplied
	 ,ipmt.AppliedDate
	 ,ipmt.GLPostingDate
	from
		dbo.InvoicePayment ipmt
	join
		dbo.vPayment			 pmt on ipmt.PaymentSID = pmt.PaymentSID
	where
		pmt.PaymentTypeSCD = 'PAP' and datediff(minute, ipmt.CreateTime, sysdatetimeoffset()) < 2
	order by
		pmt.Reference
	 ,pmt.PaymentSID;

end;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:05:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pPAPBatch#ApplyToRenewal'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				nvarchar(4000)										-- message text for business rule errors
	 ,@tranCount				int							 = @@trancount		-- determines whether a wrapping transaction exists
	 ,@ON								bit							 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@maxRow						int																-- loop limit
	 ,@i								int																-- loop index counter
	 ,@paymentSID				int																-- values for next invoice payment to insert:
	 ,@invoiceSID				int
	 ,@amountPaid				decimal(11, 2)
	 ,@amountApplied		decimal(11, 2)
	 ,@appliedDate			date
	 ,@glPostingDate		date
	 ,@timeCheck				datetimeoffset(7)									-- timing interval buffer (for debugging performance issues)
	 ,@debugString			varchar(100)											-- debug info to print to console
	 ,@recordsProcessed int							 = 0;							-- records processed for a single entity 

	declare @work table
	(
		ID						int						 not null identity(1, 1)
	 ,PaymentSID		int						 not null -- payment to apply
	 ,InvoiceSID		int						 not null -- renewal invoice to apply payment to
	 ,AmountPaid		decimal(11, 2) not null
	 ,AppliedDate		date					 not null
	 ,GLPostingDate date					 not null
	);

	begin try

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = N'start'
			 ,@TimeCheck = @timeCheck output;

		end;

		if @tranCount > 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'TransactionPending'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The procedure cannot start because a database transaction is already pending.';

			raiserror(@errorText, 18, 1);
		end;

		-- validate parameters

		if @PAPBatchSID is not null
		begin

			if not exists (select 1 from dbo.PAPBatch pb where pb.PAPBatchSID = @PAPBatchSID)
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'dbo.PAPBatch'
				 ,@Arg2 = @PAPBatchSID;

				raiserror(@errorText, 18, 1);
			end;

		end;

		-- load the work table with records to process

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = N'loading work table'
			 ,@TimeCheck = @timeCheck output;

		end;

		insert
			@work (PaymentSID, InvoiceSID, AmountPaid, AppliedDate, GLPostingDate)
		select
			x.PaymentSID
		 ,ri.InvoiceSID
		 ,x.AmountPaid
		 ,sf.fDTOffsetToClientDate(x.CreateTime)
		 ,x.GLPostingDate
		from
		(
			select -- isolate pre-authorized payments that are fully unapplied
				pb.BatchID
			 ,pmt.PaymentSID
			 ,pmt.AmountPaid
			 ,ptot.TotalUnapplied
			 ,pmt.PersonSID
			 ,pmt.CreateTime
			 ,pmt.GLPostingDate
			from
				dbo.Payment																	 pmt
			join
				dbo.PAPTransaction													 pt on pmt.PaymentSID = pt.PaymentSID
			join
				dbo.PAPBatch																 pb on pt.PAPBatchSID = pb.PAPBatchSID
			outer apply dbo.fPayment#Total(pmt.PaymentSID) ptot
			where
				(@PAPBatchSID is null or pb.PAPBatchSID = @PAPBatchSID) -- limit to a batch key if provided otherwise scan all batches
				and ptot.TotalApplied										= 0 and ptot.TotalUnapplied > 0 -- must be fully unapplied to qualify

		)																							x
		join -- look for latest renewal invoice for the person (exclude if no renewal invoice)
		(
			select
				i.PersonSID
			 ,max(i.InvoiceSID) InvoiceSID	-- in case more than one renewal invoice, take latest
			from
				dbo.Invoice						i
			join
				dbo.RegistrantRenewal rnw on i.InvoiceSID = rnw.InvoiceSID	-- only renewal invoices considered
			group by
				i.PersonSID
		)																							ri on x.PersonSID = ri.PersonSID
		outer apply dbo.fInvoice#Total(ri.InvoiceSID) it
		where
			it.TotalDue > 0.00	-- exclude if no amount is owing
		order by
			x.BatchID
		 ,x.PaymentSID
		 ,x.PersonSID;

		set @maxRow = @@rowcount;
		set @i = 0;

		-- process each record

		if @DebugLevel > 1
		begin
			set @debugString = 'records to process: ' + ltrim(@maxRow);

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;
		end;
		else if @DebugLevel = 1
		begin

			exec sf.pDebugPrint
				@DebugString = N'processing loop (start)'
			 ,@TimeCheck = @timeCheck output;

		end;

		while @i < @maxRow
		begin

			set @i += 1;

			select
				@paymentSID		 = w.PaymentSID
			 ,@invoiceSID		 = w.InvoiceSID
			 ,@amountPaid		 = w.AmountPaid
			 ,@appliedDate	 = w.AppliedDate
			 ,@glPostingDate = w.GLPostingDate
			from
				@work w
			where
				w.ID = @i;

			-- before applying the payment, verify that an
			-- amount remains owing on the renewal invoice

			set @amountApplied = 0.0;

			select
				@amountApplied = (case when it.TotalDue < @amountPaid then it.TotalDue else @amountPaid end)	-- amount to apply is the lesser of the paid amount or due amount
			from
				dbo.fInvoice#Total(@invoiceSID) it
			where
				it.TotalDue > 0.0;

			if isnull(@amountApplied, 0.0) > 0.0
			begin

				if @DebugLevel > 1
				begin

					set @debugString = 'processing payment#: ' + ltrim(@paymentSID) + ' $' + ltrim(@amountApplied);

					exec sf.pDebugPrint
						@DebugString = @debugString
					 ,@TimeCheck = @timeCheck output;

				end;

				if @DebugLevel < 3
				begin

					exec dbo.pInvoicePayment#Insert
						@InvoiceSID = @invoiceSID
					 ,@PaymentSID = @paymentSID
					 ,@AmountApplied = @amountApplied
					 ,@AppliedDate = @appliedDate
					 ,@GLPostingDate = @glPostingDate;

				end;

				set @recordsProcessed += 1;

			end;

		end;

		if @DebugLevel = 1
		begin

			exec sf.pDebugPrint
				@DebugString = N'processing loop (complete)'
			 ,@TimeCheck = @timeCheck output;

		end;

		if @ReturnSelect = @ON -- return record count when requested
		begin

			select
				ltrim(@recordsProcessed) + ' Payment(s) applied '
				+ (case when @DebugLevel >= 3 then ' [DebugLevel = ' + ltrim(@DebugLevel) + ' | No updates made to database] ' else '' end) ResultMessage;

		end;

		if @DebugLevel = 1
		begin

			exec sf.pDebugPrint
				@DebugString = N'done'
			 ,@TimeCheck = @timeCheck output;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
