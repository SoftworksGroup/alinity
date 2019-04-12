SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.[pJobHistory#Purge$JobRun]
	@JobRunSID			int = null									-- reference to sf.JobRun for async call updates
 ,@JobSID					int = null									-- job SID to purge data from (instead of all)
 ,@MonthsToRetain int = null									-- retention period in months from sf.ConfigParam
 ,@IsCancelled		bit						= null output -- tracks whether job was cancelled by user
 ,@RecordsPurged	int						= null output -- count of records purged
 ,@TraceLog				nvarchar(max) = null output -- text block for detailed results of job
 ,@NextSID				int						= null output -- next PK value to delete (for error tracing)
as
/*********************************************************************************************************************************
Procedure	: Job Run Purge
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Deletes sf.JobRun records older than the retention period
----------------------------------------------------------------------------------------------------------------------------------
History		: Author							| Month Year	| Change Summary
					: ------------------- + ----------- + ----------------------------------------------------------------------------------
 					: Tim Edlund          | Jul 2013		|	Initial version
					: Russ Poirier				| Mar 2017		| Added @JobSID as a parameter to clear history for individual jobs
					: Tim Edlund					| Aug 2018		| Set maximum retention period to 3 months (default is 1 month)
					: Tim Edlund					| Mar	2019		| Implemented logic to ignore and step around FK errors arising from deletion

Comments	
--------

This procedure is a component of the framework's job management system.  As jobs are executed, a record of each job call is made
in the sf.JobRun table.  In order to prevent the table from becoming too large and slowing down job execution, it is purged 
periodically by this procedure.  The system retains job run records within the value specified in the configuration parameter 
"JobHistoryRetentionMonths" (sf.ConfigParam).  

The procedure selects records for purging and places them in a work table for one-by-one processing.  The table's #Delete
sproc is called to remove each record.  Because this procedure is most typically called asynchronously, the procedure 
is structured to update its sf.JobRun record if the @JobRunSID parameter is provided.

Both this procedure and pJobSchedule#Purge (which deletes old records from the sf.JobScheduleEvent table) are called one after
the other by the parent procedure sf.pJobHistory#Purge.

This procedure also allows for individual job history deletes if the @JobSID is filled in. This will delete all job history
(based off the timeframe entered for the "JobHistoryRetentionMonths" (sf.ConfigParam) value, and only the history as the
event scheduler data is not delete when a specific job is identified. 

Example:
--------

declare
	 @CRLF								nchar(2) = char(13) + char(10)										-- constant for formatting job syntax script
	,@jobSID							int																								-- key of the sf.Job#Simulate record in sf.Job		
	,@jobSCD							varchar(128)																			-- code for the job to insert
	,@callSyntaxTemplate	nvarchar(max)																			-- syntax for the job with replacement tokens
	,@conversationHandle	uniqueidentifier																	-- ID assigned to each job conversation

-- add the CONTROL sproc to the job table if not already defined there

set @jobSCD = 'sf.pJobHistory#Purge'

select
	@jobSID = j.JobSID
from
	sf.Job j
where
	j.JobSCD = @jobSCD

if @jobSID is null
begin

	set @callSyntaxTemplate = 
		'exec ' + @jobSCD
		+ @CRLF + '  @JobRunSID = {JobRunSID}'

	exec sf.pJob#Insert
		 @JobSID							= @jobSID		output
		,@JobSCD							= @jobSCD
		,@JobLabel						= N'Job history purge'
		,@JobDescription			= N'Removes (deletes) job run and job schedule event history records that are older than the retention period specified for the configuration.'
		,@CallSyntaxTemplate	= @callSyntaxTemplate

end

exec sf.pJob#Call
	 @JobSCD							= @jobSCD
	,@ConversationHandle	= @conversationHandle output

waitfor delay '00:00:03'

select @conversationHandle ConversationHandle

select top 3
	*
from
	sf.vJobRun jr
order by
	jr.UpdateTime desc

------------------------------------------------------------------------------------------------------------------------------- */
begin

	set nocount on;

	declare
		@errorNo		int								= 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@ON					bit								= cast(1 as bit)			-- used on bit comparisons to avoid multiple casts
	 ,@OFF				bit								= cast(0 as bit)			-- used on bit comparisons to avoid multiple casts
	 ,@now				datetimeoffset(7) = sysdatetimeoffset() -- current time for date comparison (server times)
	 ,@termLabel	nvarchar(35)														-- buffer for configurable label text
	 ,@i					int																			-- loop index counter
	 ,@maxRow			int																			-- loop limit
	 ,@expiryDate datetimeoffset(7);											-- calculating expiry date to compare end date for performance and bypass table lock

	declare @work table (ID int identity(1, 1), NextSID int not null);

	set @RecordsPurged = 0;
	set @IsCancelled = @OFF;
	set @TraceLog = null;
	set @NextSID = null;

	begin try

		if @JobRunSID is not null -- if call is async, update the job run record with stage of work
		begin

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'SELECTING.RECORDS'
			 ,@TermLabel = @termLabel output
			 ,@DefaultLabel = N'Selecting records ...'
			 ,@UsageNotes = N'A label reporting processing status when records are being selected for the operation.';

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@CurrentProcessLabel = @termLabel;

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'PURGING.JOBRUN.HISTORY'
			 ,@TermLabel = @termLabel output
			 ,@DefaultLabel = N'Purging job run history ...'
			 ,@UsageNotes = N'A label reporting processing status when job run records are being purged (deleted).';

		end;

		-- read the configuration parameter to set retention period; if not provided

		set @MonthsToRetain = cast(isnull(sf.fConfigParam#Value('JobHistoryRetentionMonths'), '1') as int);
		if @MonthsToRetain > 3 set @MonthsToRetain = 3; -- three months is maximum retention period allowed

		set @expiryDate = dateadd(month, (0 - @MonthsToRetain), @now); -- calculate the cutoff - records before this are deleted

		insert
			@work (NextSID)
		select
			jr.JobRunSID
		from
			sf.vJobRun jr
		where
			isnull(jr.EndTime, jr.UpdateTime) <= @expiryDate and jr.JobSID = isnull(@JobSID, jr.JobSID) -- filter to a specific job if purge of 1 job only was specified
		order by
			jr.EndTime desc;	-- order desc to process oldest first

		set @maxRow = @@rowcount;
		set @i = 0;

		while @i < @maxRow and @IsCancelled = @OFF
		begin

			set @i += 1;

			select @NextSID	 = w.NextSID from @work w where w.ID = @i;

			-- as a framework procedure references to this key that
			-- might exist in other tables cannot be inspected so
			-- FK violation errors are handled and row is skipped

			begin try
				delete sf .JobRun where JobRunSID = @NextSID;
				set @RecordsPurged += 1;
			end try
			begin catch

				if error_number() <> 547 -- ignore and skip the record if FK violation results from deletion
				begin
					exec @errorNo = sf.pErrorRethrow; -- otherwise throw the error to main catch
				end;

			end catch;

			if @JobRunSID is not null and (@i = 0 or @i % 10 = 0) -- update the job status every 10 rows
			begin

				if exists
				(
					select
						1
					from
						sf.JobRun jr
					where
						jr.CancellationRequestTime is not null -- check for cancellation request
						and jr.JobRunSID = @JobRunSID
				)
				begin
					set @IsCancelled = @ON;
				end;

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@CurrentProcessLabel = @termLabel
				 ,@TotalRecords = @maxRow
				 ,@RecordsProcessed = @RecordsPurged
				 ,@IsCancelled = @IsCancelled;

			end;

		end;

	-- the parent sproc handles updating of final totals for the job

	end try
	begin catch

		-- error logging for jobs is handled by the caller

		if @@trancount > 0 rollback; -- roll back any pending trx so that update can succeed
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw

	end catch;

	return (@errorNo);

end;
GO
