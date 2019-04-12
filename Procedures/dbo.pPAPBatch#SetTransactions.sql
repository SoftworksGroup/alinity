SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPAPBatch#SetTransactions
	@PAPBatchSID			int				-- key of batch to update with changed subscriptions or -1 to create new batch
 ,@WithdrawalDate		date			-- the date the withdrawal(s) should occur		
 ,@MissingOnly			bit = 1		-- unless 0 includes only subscriptions which are not already processed for the month
 ,@ReturnDataSet		bit = 0		-- when 1 a data set summarizing results of process is returned
as
/*********************************************************************************************************************************
Sproc    : PAP Transaction - Set Batch
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure creates a new pre-authorized payment batch or updates an existing batch for changed subscriptions
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year | Change Summary
				 : ---------------- | -----------|----------------------------------------------------------------------------------------
				 : Tim Edlund				| Dec 2017 	 | Initial version.
				 : Kris Dawson			| Mar 2018	 | Added withdrawal date.
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure is called to create new PAP transaction batches and to update existing batches if changes are made in the current
list of PAP subscriptions.  A batch can only be changed before it is locked (or processed).  

To create a new batch, pass "-1" in the @PAPBatchSID parameter.  By default, the system creates a new batch that includes all
subscriptions that are not yet processed or pending for the current month.  If @MissingOnly is passed as 0 (off), the all 
subscribers are included even if already processed. Generating a second batch in the same month for all subscribers is relevant
if 2 batches in the same month are needed.  Otherwise only subscribers who are new or who had their transaction rejected (declined)
in a previous batch for the month will be included. 

If an existing batch SID is provided it is first checked to ensure the batch is not locked.  The batch is then updated with
any new subscribers and any inactive subscribers are removed.  If any records within the existing batch are marked as declined
the value is retained (not modified).

Call Syntax
-----------

exec dbo.pPAPBatch#SetTransactions
	@PAPBatchSID = -1

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int		 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)					-- message text for business rule errors
	 ,@blankParm						varchar(50)							-- tracks name of any required parameter not passed
	 ,@ON										bit		 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF									bit		 = cast(0 as bit) -- constant for bit comparisons = 0
	 ,@batchID							varchar(12)							-- ID of batch to update
	 ,@lockedTime						datetimeoffset(7)				-- time batch was processed or locked
	 ,@createUser						nvarchar(75)						-- user calling the procedure
	 ,@isNewBatch						bit		 = cast(0 as bit) -- tracks whether new batch added
	 ,@yearMonth						varchar(6)							-- current year month
	 ,@recordWithdrawalDate	date										-- the withdrawal date of the pre-existing batch

	begin try

		-- check parameters

		if @WithdrawalDate is null set @blankParm = '@WithdrawalDate';
		if @PAPBatchSID is null set @blankParm = '@PAPBatchSID';

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		-- create a new batch where the parameter is passed as -1
		-- otherwise validate the batch provided and ensure it
		-- can be updated

		if @PAPBatchSID = -1
		begin

			exec dbo.pPAPBatch#Insert
				 @PAPBatchSID			= @PAPBatchSID output
				,@WithdrawalDate	= @WithdrawalDate;

			set @isNewBatch = @ON;

			select
				@batchID = pb.BatchID
			from
				dbo.PAPBatch pb
			where
				pb.PAPBatchSID = @PAPBatchSID;

		end;
		else
		begin

			set @MissingOnly = @OFF; -- when pre-existing batch is passed then missing only is disabled

			select
				@batchID							= pb.BatchID
			 ,@lockedTime						= isnull(pb.ProcessedTime, pb.LockedTime)
			 ,@recordWithdrawalDate = pb.WithdrawalDate
			from
				dbo.PAPBatch pb
			where
				pb.PAPBatchSID = @PAPBatchSID;

			if @batchID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'dbo.PAPBatch'
				 ,@Arg2 = @PAPBatchSID;

				raiserror(@errorText, 18, 1);
			end;

			if @lockedTime is not null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'UpdateNotAllowed'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'Batch %1 cannot be updated because it is locked/processed.'
				 ,@Arg1 = @batchID;

				raiserror(@errorText, 16, 1);

			end
			else if @WithdrawalDate <> @recordWithdrawalDate
			begin

				exec dbo.pPAPBatch#Update
					 @PAPBatchSID			= @PAPBatchSID
					,@WithdrawalDate	= @WithdrawalDate
					,@IsNullApplied		= @OFF;

			end;
		end;

		set @yearMonth = ltrim(year(@WithdrawalDate)) + sf.fZeroPad(ltrim(datepart(month, @WithdrawalDate)), 2);
		set @createUser = sf.fApplicationUserSession#UserName();

		-- select subscriptions or batch to insert/update

		merge dbo.PAPTransaction target
		using (
						select
							@PAPBatchSID PAPBatchSID
						 ,ps.PAPSubscriptionSID
						 ,ps.PersonSID
						 ,ps.InstitutionNo
						 ,ps.TransitNo
						 ,ps.AccountNo
						 ,ps.WithdrawalAmount
						from
							dbo.vPAPSubscription ps
						left outer join
						(
							select distinct -- isolate subscriptions processed or still pending for this month
								ps.PAPSubscriptionSID
							from
								dbo.PAPTransaction	pt
							join
								dbo.PAPSubscription ps on pt.PAPSubscriptionSID = ps.PAPSubscriptionSID
							join
								dbo.PAPBatch				pb on pt.PAPBatchSID				= pb.PAPBatchSID
							where
								pb.BatchID like @yearMonth + '%' and pt.IsRejected = @OFF
						)											 processed on ps.PAPSubscriptionSID = processed.PAPSubscriptionSID
						where
							ps.IsActiveSubscription = @ON -- subscription must be currently active
							and -- all subscriptions are being included or this subscription is not processed or pending
							(
								@MissingOnly					= @OFF or processed.PAPSubscriptionSID is null
							)
					) source
		on target.PAPSubscriptionSID = source.PAPSubscriptionSID and target.PAPBatchSID = source.PAPBatchSID
		when not matched by target then
			insert
			(
				PAPBatchSID
			 ,PAPSubscriptionSID
			 ,AccountNo
			 ,InstitutionNo
			 ,TransitNo
			 ,WithdrawalAmount
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.PAPBatchSID, source.PAPSubscriptionSID, source.AccountNo, source.InstitutionNo, source.TransitNo, source.WithdrawalAmount, @createUser
			 ,@createUser
			)
		when matched then update set
												target.AccountNo = source.AccountNo
											 ,target.InstitutionNo = source.InstitutionNo
											 ,target.TransitNo = source.TransitNo
											 ,target.WithdrawalAmount = source.WithdrawalAmount
											 ,UpdateUser = @createUser
		when not matched by source and exists(select 1 from dbo.PAPTransaction pt where pt.PAPTransactionSID = target.PAPTransactionSID and pt.PAPBatchSID = @PAPBatchSID) then delete;

		if @ReturnDataSet = @ON
		begin

			select
				@PAPBatchSID																																					 PAPBatchSID
			 ,N'Batch ' + @batchID + (case when @isNewBatch = @ON then 'created' else 'updated' end) ResultMessage;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
