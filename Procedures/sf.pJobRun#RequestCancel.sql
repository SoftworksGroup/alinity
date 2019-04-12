SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJobRun#RequestCancel]
   @JobRunSID										int																				-- primary key of the job run to request cancel for
	,@ResultMessage								nvarchar(max)															-- required!  notes to store with the request
	,@IsReselected								bit								= 0											-- indicates if entity should be returned as data set
as
/*********************************************************************************************************************************
Procedure : Job Run - Request cancel
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Sets the cancellation request time of the job run to indicate to the job it should cancel itself
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris Dawson	| Jul		2013		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This procedure sets the cancellation request time of a job run to indicate to the job that it should cancel itself. Note that this
procedure does not actually change the status of the job, the running job is responsible for setting the status and stopping
itself. This request will only be made if the JobStatusSCD is INPROCESS. If the job has crashed and is stuck with a pending cancel
request it can be forced to fail with pJobRun#Fail.

The procedure returns the sf.vJobRun entity to the caller for display in the UI (shows the updated time), where the
@IsReselected bit is passed as ON (which is the default).

Note that checking for access rights to allow the request must be carried out by the UI!

Example
-------

declare
	@jobRunSID		int

select top (1)
	@jobRunSID = jr.JobRunSID
from
	dbo.vJobRun jr
where
	jr.JobStatusSCD = 'INPROCESS'
order by
	newid()

exec sf.pJobRun#RequestCancel
	 @JobRunSID			= @jobRunSID
	,@ResultMessage = N'This is a test change note for a cancellation request.'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

  declare
     @errorNo															int = 0                         -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                           nvarchar(4000)                  -- message text (for business rule errors)
		,@ON																	bit = cast(1 as bit)						-- constant for bit comparisons
		,@OFF																	bit = cast(0 as bit)						-- constant for bit comparisons
		,@blankParm														varchar(128)										-- tracks NULL parameters passed into procedure
		,@startTime														datetimeoffset									-- tracks job run start time
		,@endTime															datetimeoffset									-- tracks job run end time
		,@now																	datetimeoffset = sysdatetimeoffset()											-- the time of the request in the server's timezone

  begin try

    -- check parameters

		if len(ltrim(rtrim(@ResultMessage))) = 0 set @ResultMessage = null				-- ensure blanks are not used to bypass comment requirement!

		if @ResultMessage	is null set @blankParm = '@ResultMessage'
		if @JobRunSID			is null set @blankParm = '@JobRunSID'

    if @blankParm is not null
    begin

      exec sf.pMessage#Get
         @MessageSCD    = 'BlankParameter'
        ,@MessageText   = @errorText output
        ,@DefaultText   = N'A parameter (%1) required by the database procedure was left blank.'
        ,@Arg1          = @blankParm

      raiserror(@errorText, 18, 1)
    end

		select
			 @startTime = jr.StartTime
			,@endTime = jr.EndTime
		from
			sf.JobRun jr
		where
			jr.JobRunSID = @JobRunSID
			
		if @startTime is null
		begin
exec sf.pMessage#Get
         @MessageSCD  = 'RecordNotFound'
        ,@MessageText = @errorText output
        ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
        ,@Arg1        = 'JobRunSID'
        ,@Arg2        = @JobRunSID

      raiserror(@errorText, 18, 1)
		end

		-- job run must be in process otherwise the request won't be made

		if @endTime is not null
		begin

      exec sf.pMessage#Get
         @MessageSCD  = 'JobRunCancelRequestStatusInvalid'
        ,@MessageText = @errorText output
        ,@DefaultText = N'The %1 action is only allowed on jobs that are currently running.'
        ,@Arg1        = 'cancel request'

      raiserror(@errorText, 16, 1)

		end
		
		-- update the job run for the cancel request time

		exec sf.pJobRun#Update
			 @JobRunSID								= @JobRunSID
			,@ResultMessage						= @ResultMessage
			,@CancellationRequestTime = @now

		-- and finally return the entity where requested

		if @IsReselected = @ON
		begin

			select
				--!<ColumnList DataSource="sf.vJobRun" Alias="jr">
				 jr.JobRunSID
				,jr.JobSID
				,jr.ConversationHandle
				,jr.CallSyntax
				,jr.StartTime
				,jr.EndTime
				,jr.TotalRecords
				,jr.TotalErrors
				,jr.RecordsProcessed
				,jr.CurrentProcessLabel
				,jr.IsFailed
				,jr.IsFailureCleared
				,jr.CancellationRequestTime
				,jr.IsCancelled
				,jr.ResultMessage
				,jr.TraceLog
				,jr.UserDefinedColumns
				,jr.JobRunXID
				,jr.LegacyKey
				,jr.IsDeleted
				,jr.CreateUser
				,jr.CreateTime
				,jr.UpdateUser
				,jr.UpdateTime
				,jr.RowGUID
				,jr.RowStamp
				,jr.JobSCD
				,jr.JobLabel
				,jr.IsCancelEnabled
				,jr.IsParallelEnabled
				,jr.IsFullTraceEnabled
				,jr.IsAlertOnSuccessEnabled
				,jr.JobScheduleSID
				,jr.JobScheduleSequence
				,jr.IsRunAfterPredecessorsOnly
				,jr.MaxErrorRate
				,jr.MaxRetriesOnFailure
				,jr.JobIsActive
				,jr.JobRowGUID
				,jr.IsDeleteEnabled
				,jr.IsReselected
				,jr.IsNullApplied
				,jr.zContext
				,jr.JobStatusSCD
				,jr.JobStatusLabel
				,jr.RecordsPerMinute
				,jr.RecordsRemaining
				,jr.EstimatedMinutesRemaining
				,jr.EstimatedEndTime
				,jr.DurationMinutes
				,jr.StartTimeClientTZ
				,jr.EndTimeClientTZ
				,jr.CancellationRequestTimeClientTZ
				 --!</ColumnList>
			from
				sf.vJobRun jr
			where
				jr.JobRunSID = @JobRunSID

		end

  end try

  begin catch
    if @@trancount > 0 rollback
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
