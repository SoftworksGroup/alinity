SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantRenewal#Withdraw]
	@RegistrantRenewalSID int -- key of the renewal form to withdraw
as
/*********************************************************************************************************************************
Procedure : Registrant Renewal Withdraw
Notice    : Copyright © 2012 Softworks Group Inc.
Summary   : Withdraws a renewal form
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Oct	2017			|	Initial version
				: Taylor/Russ |	Nov 2017			| Also delete the RegistrantPractice record associated with the renewal
				: Cory Ng			| Oct 2018			| Removed deletion of practice and employment records as #Upsert procedures now exists
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure withdraws the renewal form and cancels any pending payments and registrations provided the registration has not yet
gone into effect.  Note that only System Administrators can withdraw a renewal form that has been paid.  Even then, a renewal
form cannot be withdrawn after its associated registration has gone active.  The registration must be terminated manually first.

If the renewal has been approved, registrants (clients) are not allowed to withdraw it.  Renewal Administrators can perform
withdrawal on approved forms but only if no payment has been made against them (or the payment is pending).

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Withdraw a renewal form in submitted status at random">
		<SQLScript>
			<![CDATA[

declare @RegistrantRenewalSID int;

select top (1)
	@RegistrantRenewalSID = rr.RegistrantRenewalSID
from
	dbo.vRegistrantRenewal rr
where
	rr.FormStatusSCD = 'SUBMITTED'
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pRegistrantRenewal#Withdraw
		@RegistrantRenewalSID = @RegistrantRenewalSID;

	select
		x.RegistrantRenewalSID
	 ,x.FormStatusSCD
	from
		dbo.vRegistrantRenewal x
	where
		x.RegistrantRenewalSID = @RegistrantRenewalSID and x.FormStatusSCD = 'WITHDRAWN';

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
	 @ObjectName			= 'dbo.pRegistrantRenewal#Withdraw'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm						varchar(50)												-- tracks if any required parameters are not provided
	 ,@OFF									bit							 = cast(0 as bit) -- constant for bit comparisons
	 ,@now									datetimeoffset(7)									-- current time
	 ,@recordSID						int																-- next invoice/payment record to process
	 ,@registrantSID				int																-- key of registrant renewal is created for
	 ,@registrationYear			smallint													-- year of renewal record
	 ,@invoiceSID						int																-- key invoice associated with the renewal if any
	 ,@totalPaid						decimal(11, 2)										-- total applied on the invoice associated with the form
	 ,@registrationSID int																-- tracks key of registration created by renewal
	 ,@effectiveTime				datetime													-- date registration becomes effective	
	 ,@FormStatusSCD				varchar(25);											-- current status of the record

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @RegistrantRenewalSID is null set @blankParm = '@RegistrantRenewalSID';
-- SQL Prompt formatting on

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
    end

		select
			@invoiceSID						= rr.InvoiceSID
		 ,@FormStatusSCD				= rrs.FormStatusSCD
		 ,@registrationSID = rlNext.RegistrationSID
		 ,@effectiveTime				= rlNext.EffectiveTime
		 ,@registrantSID				= rrs.RegistrantSID
		 ,@registrationYear			= rr.RegistrationYear -- the registration year of the registration being renewed
		from
      dbo.RegistrantRenewal rr
    cross apply
			dbo.fRegistrantRenewal#Search2(rr.RegistrationSID) rrs
		left outer join
			dbo.Registration																 rlNext on rrs.RenewedRegistrationNo = rlNext.RegistrationNo
    where
      rr.RegistrantRenewalSID = @RegistrantRenewalSID
      
		if @FormStatusSCD is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.RegistrantRenewal'
			 ,@Arg2 = @RegistrantRenewalSID;

			raiserror(@errorText, 18, 1);
		end;

		if @FormStatusSCD = 'APPROVED' and sf.fIsGranted('ADMIN.RENEWAL') = @OFF
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'FormIsApproved'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 action cannot be carried out because this form is already approved. Contact registration for assistance.'
			 ,@Arg1 = 'withdraw';

			raiserror(@errorText, 16, 1);
		end;

		if @registrationSID is not null
		begin

			if @effectiveTime <= sf.fNow()
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'LicenseIsActive'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 action cannot be carried out because the registration/registration associated with the form became active.'
				 ,@Arg1 = 'withdraw';

				raiserror(@errorText, 16, 1);

			end;

			-- because the registration has not yet become active, delete it so that another 
			-- registration for the registrant can apply on the same starting date since
			-- duplicate effective times are not allowed for the same registrant

			exec dbo.pRegistration#Delete
				@RegistrationSID = @registrationSID

		end;

		if @invoiceSID is not null
		begin

			select
				@totalPaid = i.TotalPaid
			from
				dbo.vInvoice i -- view does not count payments where paid status is declined or pending
			where
				i.InvoiceSID = @invoiceSID;

			-- block the withdrawal if any amount is paid
			-- on the associated invoice unless an SA
			-- is requesting the action

			if @totalPaid > 0.00 and sf.fIsSysAdmin() = @OFF
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'WithdrawalOnPaid'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 cannot be withdrawn because it is paid. Remove (un-apply) the payment(s) and and try again.'
				 ,@Arg1 = 'renewal';

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
