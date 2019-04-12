SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrationChange#Withdraw
	@RegistrationChangeSID int	-- key of the change form to withdraw
as
/*********************************************************************************************************************************
Procedure : RegistrationChange - Withdraw
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Withdraws a registration change (registration change) form
----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version

Comments	
--------
This procedure withdraws the registration change form and cancels any pending invoices, payments and registration if it has not 
yet gone into effect. Note that only System Administrators can withdraw a change form that has been paid.  Even then, a 
registration change form cannot be withdrawn after its associated registration has gone active. The registration must be terminated 
manually first.

If the change has been approved, registrants (clients) are not allowed to withdraw it.  "REGCHANGE" admin's can perform
withdrawal on approved forms but only if no payment has been made against them (or the payment is pending).

Example
-------
<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Withdraw a change form in submitted status at random">
		<SQLScript>
			<![CDATA[

declare @RegistrationChangeSID int;

select top (1)
	@RegistrationChangeSID = rc.RegistrationChangeSID
from
	dbo.vRegistrationChange rc
where
	rc.RegistrationChangeStatusSCD = 'SUBMITTED'
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pRegistrationChange#Withdraw
		@RegistrationChangeSID = @RegistrationChangeSID;

	select
		x.RegistrationChangeSID
	 ,x.RegistrationChangeStatusSCD
	from
		dbo.vRegistrationChange x
	where
		x.RegistrationChangeSID = @RegistrationChangeSID and x.RegistrationChangeStatusSCD = 'WITHDRAWN';

	if @@trancount > 0 rollback; -- rollback transaction to avoid permanent data change
end;			

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pRegistrationChange#Withdraw'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)										-- message text (for business rule errors)
	 ,@OFF									bit							 = cast(0 as bit) -- constant for bit comparisons
	 ,@now									datetimeoffset(7)									-- current time
	 ,@recordSID						int																-- next invoice/payment record to process
	 ,@registrantSID				int																-- key of registrant change is created for
	 ,@invoiceSID						int																-- key invoice associated with the change if any
	 ,@totalPaid						decimal(11, 2)										-- total applied on the invoice associated with the form
	 ,@registrationSID int																-- tracks key of registration created by change
	 ,@effectiveTime				datetime													-- date registration becomes effective	
	 ,@FormStatusSCD				varchar(25);											-- current status of the record

	begin try

		-- check parameters

		if @RegistrationChangeSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@RegistrationChangeSID';

			raiserror(@errorText, 18, 1);
		end;

		select
			@invoiceSID						= rc.InvoiceSID
		 ,@FormStatusSCD				= isnull(cs.FormStatusSCD, 'NEW')
		 ,@registrationSID = rlNext.RegistrationSID
		 ,@effectiveTime				= rlNext.EffectiveTime
		 ,@registrantSID				= rl.RegistrantSID
		from
			dbo.RegistrationChange																											rc
		join
			dbo.Registration																														rl on rc.RegistrationSID = rl.RegistrationSID
		left outer join
			dbo.Registration																														rlNext on rc.RowGUID = rlNext.FormGUID
		outer apply dbo.fRegistrationChange#CurrentStatus(@RegistrationChangeSID, -1) cs
		where
			rc.RegistrationChangeSID = @RegistrationChangeSID;

		if @registrantSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.RegistrationChange'
			 ,@Arg2 = @RegistrationChangeSID;

			raiserror(@errorText, 18, 1);
		end;

		if @registrationSID is not null
		begin

			if @effectiveTime <= sf.fNow()
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'RegistrationIsActive'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 action cannot be carried out because the registration associated with the form became active.'
				 ,@Arg1 = 'withdraw';

				raiserror(@errorText, 16, 1);

			end;

			-- because the registration has not yet become active, delete it so that another 
			-- registration for the registrant can apply on the same starting date since
			-- duplicate effective times are not allowed

			exec dbo.pRegistration#Delete
				@RegistrationSID = @registrationSID;

		end;

		if @FormStatusSCD = 'APPROVED' and sf.fIsGranted('ADMIN.BASE') = @OFF
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'FormIsApproved'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 action cannot be carried out because this form is already approved. Contact a "%2" to perform this action.'
			 ,@Arg1 = 'withdraw';

			raiserror(@errorText, 16, 1);
		end;

		-- look for invoice and payments that may have been
		-- created for the registration change

		if @invoiceSID is not null
		begin

			select @totalPaid	 = i.TotalPaid from dbo.fInvoice#Total(@invoiceSID) i;	--  the function avoids including payments where paid status is declined or pending

			-- block the withdrawal if any amount is paid unless 
			-- an SA is requesting the action

			if @totalPaid > 0.00 and sf.fIsSysAdmin() = @OFF
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'WithdrawalOnPaid'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 cannot be withdrawn because it is paid. Remove (un-apply) the payment(s) and and try again (or ask System Administrator to perform the action).'
				 ,@Arg1 = 'change';

				raiserror(@errorText, 16, 1);

			end;

			set @now = sysdatetimeoffset();

			-- cancel the invoice - first setting quantity on line items to zero

			set @recordSID = -1;

			while @recordSID is not null
			begin

				set @recordSID = null;

				select
					@recordSID = ii.InvoiceItemSID
				from
					dbo.InvoiceItem ii
				where
					ii.InvoiceSID = @invoiceSID and ii.Quantity <> 0;

				if @recordSID is not null
				begin

					exec dbo.pInvoiceItem#Update
						@InvoiceItemSID = @recordSID
					 ,@Quantity = 0;

				end;

			end;

			-- if any payments exist they must already be in a non-paid
			-- status (e.g. pending or rejected) based on check above
			-- set them to 0 to unapply

			set @recordSID = -1;

			while @recordSID is not null
			begin

				set @recordSID = null;

				select
					@recordSID = ip.InvoicePaymentSID
				from
					dbo.InvoicePayment ip
				where
					ip.InvoiceSID = @invoiceSID and ip.AmountApplied <> 0.00;

				if @recordSID is not null
				begin

					exec dbo.pInvoicePayment#Update
						@InvoicePaymentSID = @recordSID
					 ,@AmountApplied = 0.00
					 ,@CancelledTime = @now;

				end;
			end;

			exec dbo.pInvoice#Update
				@InvoiceSID = @invoiceSID
			 ,@CancelledTime = @now;

			-- and cancel the parent payment(s) if it is in a pending state
			-- otherwise leave it (a refund will be required)

			set @recordSID = -1;

			while @recordSID is not null
			begin

				set @recordSID = null;

				select
					@recordSID = ip.PaymentSID
				from
					dbo.InvoicePayment ip
				join
					dbo.Payment				 p on ip.PaymentSID				= p.PaymentSID
				join
					dbo.PaymentStatus	 ps on p.PaymentStatusSID = ps.PaymentStatusSID
				where
					ip.InvoiceSID = @invoiceSID and ps.IsPaid = @OFF and p.CancelledTime is null;

				if @recordSID is not null
				begin

					exec dbo.pPayment#Update
						@PaymentSID = @recordSID
					 ,@AmountPaid = 0.00
					 ,@CancelledTime = @now;

				end;
			end;
		end;

	end try
	begin catch
		if @@trancount > 0 rollback;

		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
