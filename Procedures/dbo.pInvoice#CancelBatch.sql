SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pInvoice#CancelBatch
	@Invoices	 xml				-- list of InvoiceSID's to cancel
 ,@ReasonSID int = null -- optional reason why the invoice was cancelled
as
/*********************************************************************************************************************************
Procedure : Invoice - Cancel Batch
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Sets batch of invoices provided to a cancelled status
----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Sep 2018		|	Initial version

Comments	
--------
This procedure calls dbo.pInvoice#Update with the @IsCancelled bit set ON for the primary keys passed in the XML parameter.  The 
procedure supports the multi-select mode in the UI where records are pinned and then the CANCEL action is applied against the set.

The procedure is applied most often to cancel renewal invoices which remain unpaid at the end of the renewal cycle.

Note that only invoices without payments applied to them can be cancelled.  If an invoice is provided where payments have been
applied, the procedure raises an error and no cancellations are processed.

This list of records to process is identified using xml in the following format:

<Invoices>
		<Invoice SID="1000001" />
		<Invoice SID="1000011" />
		<Invoice SID="1000123" />
</Invoices>

If a single invoice is being processed, the pInvoice#Update procedure can be used passing the IsCancelled = @ON (1)

@ReasonSID
----------
The @ReasonSID parameter is optional and may be passed by the caller to fill-in the ReasonSID on the resulting dbo.Invoice
record. This value is optional.

Example
-------
Test from user interface or test-harness in #Cancel sproc.
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	nvarchar(4000)									-- message text (for business rule errors)
	 ,@blankParm	nvarchar(100)										-- error checking buffer for required parameters
	 ,@ON					bit						= cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@i					int															-- loop index
	 ,@maxRows		int															-- loop limit
	 ,@totalPaid	decimal(11, 2)									-- tracks amount paid on the invoice
	 ,@invoiceSID int;														-- key of next invoice record to assign

	declare @work table -- table of keys to process
	(ID int identity(1, 1), InvoiceSID int not null);

	begin try

		-- check parameters

		if @Invoices is null set @blankParm = N'@Invoices';

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);

		end;

		insert
			@work -- parse XML key values into table for processing
		(InvoiceSID)
		select
			Invoice.rc.value('@SID', 'int')
		from
			@Invoices.nodes('//Invoice') Invoice(rc);

		set @maxRows = @@rowcount;
		set @i = 0;

		if @maxRows = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@Invoices';

			raiserror(@errorText, 16, 1);

		end;

		-- commit all cancellations as a single transaction
		-- (succeeds or all rollback)

		begin transaction;

		while @i < @maxRows -- first proceed through each invoice in the list passed
		begin

			set @i += 1;
			set @totalPaid = 0.00;

			select @invoiceSID = w .InvoiceSID from @work w where w.ID = @i;

			select
				@invoiceSID = i.InvoiceSID
			 ,@totalPaid	= it.TotalPaid
			from
				@work																			 w
			join
				dbo.Invoice																 i on w.InvoiceSID = i.InvoiceSID
			cross apply dbo.fInvoice#Total(w.InvoiceSID) it
			where
				w.ID = @i;

			if @@rowcount = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'dbo.Invoice'
				 ,@Arg2 = @invoiceSID;

				raiserror(@errorText, 18, 1);

			end;
			else if @totalPaid > 0.00
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'PaidInvoiceCancel'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The invoice (#%1) cannot be cancelled while payments are applied to it. Un-apply payments first.'
				 ,@Arg1 = @invoiceSID;

				raiserror(@errorText, 16, 1);

			end;

			exec dbo.pInvoice#Update
				@InvoiceSID = @invoiceSID
			 ,@ReasonSID = @ReasonSID
			 ,@IsCancelled = @ON;

		end;

		commit; -- process succeeded, so commit all assignments

	end try
	begin catch

		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw

	end catch;

	return (@errorNo);

end;
GO
