SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPayment#SetDepositDates
	@Payments				xml			-- keys of payment records to refund (1 to N keys supported)
 ,@NewDepositDate date		-- deposit date to update the payment-set with
 ,@ReturnDataSet	bit = 0 -- when 1 a data set with the count of payments updated is returned
as
/*********************************************************************************************************************************
Sproc    : Payment Set Deposit Date
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure updates Deposit dates on one or more payment records 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
-------- 
This procedure is called from the UI to reset one or more Deposit dates to on (dbo) Payment to a new value.  The user must first 
select the payments to be updated in the user interface. The set of payments selected is passed to this procedure in the XML 
parameter.  

The procedure checks that the new deposit date provided is not more than 1 year in the past or greater than 2 weeks into the 
future. The procedure also checks the new date is not BEFORE any of the GL Posting Dates on the payments selected.  

More than one payment key may be passed but the same @NewDepositDate is applied to all transaction in the set.  The keys must be 
passed in the XML parameter using the following format:

<Payments>
		<Payment SID="1003170" />
		<Payment SID="1000011" />
		<Payment SID="1000123" />
</Payments> 

Batch Update is Applied
-----------------------
The procedure updates the payments in the group as a single transaction.  All updates succeed or fail together. The pPayment#Update
procedure is not called to improve performance.  The update-user and update-time columns are set to the current values. 

Known Limitations
-----------------
This version of the routine does not support changes to GL Posting Dates.  Similar functionality may be required for updates to 
GL Posting dates in the long-term.

The procedure expects that the record sets passed in are small enough that no timeout (30 seconds) will occur to complete the
update statement.  This seems reasonable given all transactions in the set are being set to exactly the same Deposit Date.
Several thousand records can be updated within the timeout comfortably with average system performance.

The configuration parameter "AcctgTrxLockedDate" used to prevent changes to transactions in locked accounting periods is NOT
applied by this procedure.  Because only the Deposit Date is impacted by this procedure the Locked Date is not a implemented
in business rules.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Resets deposit date on a payment selected at random. (Transaction is then rolled back)">
    <SQLScript>
      <![CDATA[
declare
	@paymentSID			int
 ,@payments				xml
 ,@newDepositDate date;

select top (1)
	@paymentSID			= p.PaymentSID
 ,@newDepositDate = dateadd(day, 1, p.DepositDate)
from
	dbo.Payment p
where
	p.DepositDate is not null and p.GLPostingDate is not null and p.CancelledTime is null and p.AmountPaid > 0.0 and p.GLPostingDate <= p.DepositDate
order by
	newid();

set @payments = N'<Payments><Payment SID="' + ltrim(@paymentSID) + '" /></Payments>';

if @paymentSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		pmt.PaymentSID
	 ,pmt.DepositDate
	from
		dbo.Payment pmt
	where
		pmt.PaymentSID = @paymentSID; -- show deposit date before

	begin transaction;

	exec dbo.pPayment#SetDepositDates
		@Payments = @payments
	 ,@NewDepositDate = @newDepositDate
	 ,@ReturnDataSet = 1; -- return count of updates

	select
		pmt.PaymentSID
	 ,pmt.DepositDate
	from
		dbo.Payment pmt
	where
		pmt.PaymentSID = @paymentSID; -- show deposit date after update

	rollback;
end;      

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="3"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pPayment#SetDepositDates'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			 int					 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		 nvarchar(4000)																					-- message text for business rule errors
	 ,@blankParm		 varchar(50)																						-- tracks name of any required parameter not passed
	 ,@paymentSID		 int																										-- next payment to process
	 ,@glPostingDate date																										-- posting date on existing payment
	 ,@amountPaid		 decimal(11, 2)																					-- amount of the payment
	 ,@updateUser		 nvarchar(75)	 = sf.fApplicationUserSession#UserName()	-- user running the procedure
	 ,@today				 date					 = sf.fToday()														-- current date in client timezone used for parameter checking
	 ,@i						 int;																										-- loop iteration counter

	declare @work table (ID int identity(1, 1), PaymentSID int not null);

	begin try

		-- check parameters

		-- SQL Prompt formatting off
		if @NewDepositDate is null	set @blankParm = '@NewDepositDate';
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

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NoRecordsSelected'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'No %1 are selected for processing.  Click check-boxes on left-hand-side of records to select.'
			 ,@Arg1 = 'payments';

			raiserror(@errorText, 16, 1);

		end;

		if @NewDepositDate not between dateadd(day, -365, @today) and dateadd(day, 14, @today)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'DepositDateInvalid'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The deposit date "%1" is invalid.  The deposit date cannot be more than 2 weeks in the future or more than 1 year in past.  If adjustments to older deposits are required, please contact the help desk for assistance.'
			 ,@Arg1 = @NewDepositDate
			 ,@Arg2 = @paymentSID
			 ,@Arg3 = @glPostingDate
			 ,@Arg4 = @amountPaid;

			raiserror(@errorText, 16, 1);
		end;

		-- validate the set of payments before updating

		select top (1)
			@paymentSID		 = pmt.PaymentSID
		 ,@glPostingDate = pmt.GLPostingDate
		 ,@amountPaid		 = pmt.AmountPaid
		from
			@work				w
		join
			dbo.Payment pmt on w.PaymentSID = pmt.PaymentSID
		where
			pmt.GLPostingDate > @NewDepositDate
		order by
			pmt.PaymentSID;

		if @@rowcount > 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'DepositBeforeGLDate'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The deposit date "%1" is invalid because one or more transactions have GL Posting dates after the supplied date. Example: Payment# %2, GL Posting Date %3, Amount %4.  Update GL Posting date first or choose another deposit date.'
			 ,@Arg1 = @NewDepositDate
			 ,@Arg2 = @paymentSID
			 ,@Arg3 = @glPostingDate
			 ,@Arg4 = @amountPaid;

			raiserror(@errorText, 16, 1);
		end;

		-- process the changes outside the EF
		-- sproc as a single transaction

		update
			pmt
		set
			DepositDate = @NewDepositDate
		 ,UpdateTime = sysdatetimeoffset()
		 ,UpdateUser = @updateUser
		from
			@work				w
		join
			dbo.Payment pmt on w.PaymentSID = pmt.PaymentSID
		where
			pmt.DepositDate <> @NewDepositDate or pmt.DepositDate is null;

		set @i = @@rowcount;

		if @ReturnDataSet = 1 -- return the count of payments updated where requested
		begin
			select @i	 RecordsUpdated;
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
