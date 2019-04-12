SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pInvoicePayment#GetGLPostingDate
	@PaymentSID		 int					-- key of parent payment 
 ,@UpdateUser		 nvarchar(75) -- user inserting/update the invoice payment record
 ,@GLPostingDate date output	-- date entered in UI for GL Posting (if any) - also output value for date to use for GL Posting
as
/*********************************************************************************************************************************
Sproc    : Invoice Payment - Get GL Posting Date
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns date to use for GL Posting for an invoice payment transaction (also updates un-posted Verified Time values)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version
				: Taylor Napier				| Nov	2018		| If the verified time of a credit card payment is already set, use the current date as the posting date

Comments	
--------
This procedure is designed to be called from the dbo.pInvoicePayment#Insert and #Update procedures.  It modularizes the logic 
required which is the same in both contexts.

The posting date for applied payments (dbo.InvoicePayment) is the same as the posting date on the parent (dbo.Payment) provided
both are entered at the same time.  While that is normally the case, it is possible for a parent payment to be entered first and
remain "unapplied" (or partially unapplied) for a period of time after which the balance remaining is applied.  In that scenario 
the posting date for the invoice-payment record(s) will be different than for the parent.  The data model provides GL Posting date
columns in both dbo.Payment and dbo.InvoicePaymen to handle that scenario.

This procedure is concerned with determining the GL Posting date for the child (dbo.InvoicePayment) record.  The date used is 
dependent on the type of payment but there are several overriding rules - including support of GL dates entered directly
through the UI and passed in the @GLPostingDate parameter. The key of the parent payment must be provided.  

If the parent payment is not in a paid status (e.g. it is a credit card payment for which no response has been received, or the
payment has been CANCELLED), the procedure returns NULL for the posting date since non-paid statuses do not generate GL 
transactions.

Credit card payments get their posting time from the VerifiedTime column on the parent since there should not be any significant
delay between the payment and its application.  This procedure checks for a condition where the VerifiedTime has been received for 
the credit card transaction but is not set on the dbo.Payment record.  This is an error condition that is not fully diagnosed at
the time of this writing.  This procedure recovers from the error condition by making the update on the dbo.Payment record. The
procedure does not diagnose why the error occurred but does log the fact the update was made for further diagnosis by the help
desk.

Point-of-Sale payments always use the creation date on the parent payment for posting since, like credit card payments, the
time the payment is applied cannot vary from the time the payment is created. 

The remaining logic in the procedure applied to other payment types and is concerned with correcting - without raising an 
error - settings of the @GLPostingDate provided through the UI that would otherwise be invalid (e.g. future dated, back dated
prior to the parent payment etc. - see below).  For other payment types (not credit card, not POS) where no date is provided
from the UI the current date is applied.

Example
-------
<TestHarness>
  <Test Name = "All" IsDefault ="true" Description="Returns all content from the view">
    <SQLScript>
      <![CDATA[
declare
	@paymentSID		 int
 ,@glPostingDate date = dateadd(day, 1, sf.fToday()); -- future date; sproc will correct to current date (if not otherwise overridden)

select top (1)
	@paymentSID = p.PaymentSID
from
	dbo.vPayment p
where
	p.TotalUnapplied > 0.00 and p.IsPaid = 1
order by
	newid();

if @paymentSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pInvoicePayment#GetGLPostingDate
		@PaymentSID = @paymentSID
	 ,@UpdateUser = 'system@softworksgroup.com'
	 ,@GLPostingDate = @glPostingDate output;

	select
		pmt.PaymentSID
	 ,pmt.GLPostingDate
	 ,pmt.IsPaid
	 ,pmt.PaymentTypeSCD
	 ,pmt.CreateTime
	 ,pmt.VerifiedTime
	 ,@glPostingDate InvoicePaymentGLPostingDate
	from
		dbo.vPayment pmt
	where
		pmt.PaymentSID = @paymentSID;

	rollback;
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
	 @ObjectName = 'dbo.pInvoicePayment#GetGLPostingDate'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int						= 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)												-- message text for business rule errors
	 ,@blankParm					varchar(50)														-- name of required parameter left blank
	 ,@ON									bit						= cast(1 as bit)				-- constant for bit comparisons = 1
	 ,@OFF								bit						= cast(0 as bit)				-- constant for bit comparison = 0
	 ,@today							date					= sf.fToday()						-- the current date in the user timezone
	 ,@isPaid							bit																		-- indicates if the parent payment is in a paid status
	 ,@verifiedTime				datetime															-- time credit card transaction was verified
	 ,@createDate					date																	-- date payment was created
	 ,@paymentPostingDate date																	-- posting date used by the parent payment
	 ,@sprocName					nvarchar(128) = object_name(@@procid) -- name of currently executing procedure
	 ,@paymentTypeSCD			varchar(15);													-- tracks type of the parent payment 

	set @GLPostingDate = @GLPostingDate; -- initialize output parameter in all code paths

	begin try

		-- SQL Prompt formatting off
		if @UpdateUser		is null set @blankParm = '@UpdateUser'
		if @PaymentSID		is null	set @blankParm = '@PaymentSID'
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

		-- get status and type of parent payment

		select
			@isPaid							= ps.IsPaid
		 ,@paymentTypeSCD			= pt.PaymentTypeSCD
		 ,@verifiedTime				= pmt.VerifiedTime
		 ,@createDate					= sf.fDTOffsetToClientDate(pmt.CreateTime)
		 ,@paymentPostingDate = pmt.GLPostingDate
		from
			dbo.Payment				pmt
		join
			dbo.PaymentStatus ps on pmt.PaymentStatusSID = ps.PaymentStatusSID
		join
			dbo.PaymentType		pt on pmt.PaymentTypeSID	 = pt.PaymentTypeSID
		where
			pmt.PaymentSID = @PaymentSID;

		if @paymentTypeSCD is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.Payment'
			 ,@Arg2 = @PaymentSID;

			raiserror(@errorText, 18, 1);
		end;

		if @isPaid = @OFF
		begin
			set @GLPostingDate = null; -- if payment is not in a paid status GL Posting should not occur
		end;
		else if left(@paymentTypeSCD, 3) = 'PP.' and @verifiedTime is null
		begin

			-- if this is a credit card transaction and a verified time exists
			-- but is not applied to the parent record, update it now

			update -- MAINTENANCE NOTE: same update logic applied in pGLTransaction#Repost | Keep consistent when updating
				pmt
			set
				pmt.VerifiedTime = pdr.LatestVerifiedTime
			 ,pmt.GLPostingDate = pdr.DefaultGLPostingDate	-- see the view for details on default date calculations
			 ,pmt.DepositDate = pdr.DefaultDepositDate			-- other dates are updated which vary based on "verified time"
			 ,pmt.UpdateUser = @UpdateUser
			 ,pmt.UpdateTime = sysdatetimeoffset()
			from
				dbo.Payment											pmt
			join
				dbo.vPayment#DateReconciliation pdr on pmt.PaymentSID = pdr.PaymentID
			where
				pmt.PaymentSID																										= @PaymentSID
				and
				(
					sf.fIsDifferent(pmt.VerifiedTime, pdr.LatestVerifiedTime)				= @ON
					or sf.fIsDifferent(pmt.DepositDate, pdr.DefaultDepositDate)			= @ON
					or sf.fIsDifferent(pmt.GLPostingDate, pdr.DefaultGLPostingDate) = @ON
				);

			if @@rowcount = 1
			begin

				select
					@GLPostingDate = pmt.VerifiedTime -- return verified date just set
				from
					dbo.Payment pmt
				where
					pmt.PaymentSID = @PaymentSID;

				-- where an update is made, log a message for follow-up 
				-- but do not raise an error 

				exec sf.pMessage#Get
					@MessageSCD = 'VerifiedTimeNotSet'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The Verified Time was not set on a payment even though a response was received.  Record ID = "%1". The application recovered from the condition by updating the value.'
				 ,@Arg1 = @PaymentSID;

				exec sf.pErrorRethrow$Log
					@ErrorNo = 50001
				 ,@ErrorProc = @sprocName
				 ,@ErrorLine = 0
				 ,@ErrorSeverity = 10
				 ,@ErrorState = 1
				 ,@MessageSCD = 'VerifiedTimeNotSet'
				 ,@MessageText = @errorText;

			end;

		end;
		else if @paymentTypeSCD = 'POS' -- point of sale payments use creation date for posting
		begin
			set @GLPostingDate = @createDate;
		end;
		else if @GLPostingDate is null or @GLPostingDate > @today -- if future dated or no date provided through UI, set to current date
		begin
			set @GLPostingDate = @today;
		end;
		else if @GLPostingDate < @paymentPostingDate -- if value provided through UI is before the parent posting date, correct it to payment date
		begin
			set @GLPostingDate = @paymentPostingDate;
		end;

	-- if no cases apply then date returned is the posting 
	-- date provided through the UI

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
