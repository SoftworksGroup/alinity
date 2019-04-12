SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJobRun#Fail]
   @JobRunSID										int																				-- primary key of the job run to fail job run
	,@IsReselected								bit								= 0											-- indicates if entity should be returned as data set
as
/*********************************************************************************************************************************
Procedure : Job Run - Fail
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Sets the status of the job run to failed
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris Dawson	| Jul		2013		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This procedure sets the IsFailed bit to on for a particular job run where a cancellation request is still pending. The procedure
is ultimately used in cases where a job has hung or otherwise stopped responding but the job run record is reporting the
run still in process. This update will only be made if the jobStatusSCD is CANCELLATIONPENDING.

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
	jr.JobStatusSCD = 'CANCELLATIONPENDING'
order by
	newid()

exec sf.pJobRun#Fail
	 @JobRunSID			= @jobRunSID

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

  declare
     @errorNo															int = 0                         -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                           nvarchar(4000)                  -- message text (for business rule errors)
		,@ON																	bit = cast(1 as bit)						-- constant for bit comparisons
		,@blankParm														varchar(128)										-- tracks NULL parameters passed into procedure
		,@startTime														datetimeoffset									-- tracks job run start time
		,@cancellationRequestTime							datetimeoffset									-- tracks cancellation request time
		,@jobSID															int															-- PK of the parent job

  begin try

    -- check parameters

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
			 @startTime								= jr.StartTime
			,@cancellationRequestTime = jr.CancellationRequestTime
			,@jobSID									= jr.JobSID
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

		-- job run must be cancellation pending otherwise the request won't be made

		if @cancellationRequestTime is null
		begin

      exec sf.pMessage#Get
         @MessageSCD  = 'JobRunFailStatusInvalid'
        ,@MessageText = @errorText output
        ,@DefaultText = N'The %1 action is only allowed on jobs that have a cancellation request pending.'
        ,@Arg1        = 'fail'

      raiserror(@errorText, 16, 1)

		end

		-- update the job run

		begin transaction

		exec sf.pJobRun#Update
			 @JobRunSID								= @JobRunSID
			,@IsFailed								= @ON

		-- if this is the task trigger job, update the last end time on task triggers
		-- that are marked as being in process (only applies to scheduled triggers)

		if exists
		(
			select
				1
			from
				sf.vJob#Ext j
			where
				j.JobSID = @JobSID
			and
				j.IsTaskTriggerJob = @ON
		)
		begin

			update
				tt
			set
				tt.LastEndTime = sysdatetimeoffset()
			from
				sf.vTaskTrigger tt																								-- update the entity view to cause APIs to be called
			where
				tt.JobScheduleSID		is not null
			and
				tt.LastEndTime			is null
			and
				tt.LastStartTime		is not null

		end

		commit

		-- whenever a job is marked failed, run the utility to end
		-- any orphaned conversations

		exec sf.pJobConversation#CleanUp
			
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
