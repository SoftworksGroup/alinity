SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pJobHistory#Purge
	@JobRunSID		 int = null					-- reference to sf.JobRun for async call updates
 ,@JobSID				 int = null					-- job SID to purge data from (instead of all)
 ,@RecordsPurged int = null output	-- count of records purged
as
/*********************************************************************************************************************************
Procedure	: Job History Purge
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Deletes sf.JobRun and sf.JobScheduleVent records older than the retention period
----------------------------------------------------------------------------------------------------------------------------------
History		: Author							| Month Year	| Change Summary
					: ------------------- + ----------- + ----------------------------------------------------------------------------------
 					: Tim Edlund          | Jul 2013		|	Initial version
					: Russ Poirier				| Mar 2017		| Added @JobSID as a parameter to clear history for individual jobs
					: Tim Edlund					| Aug 2018		| Set maximum retention period to 3 months (default is 1 month)

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
event scheduler data is left for the main job to clear.

Example:
--------

<TestHarness>
	<Test Name="Purge using defaults" IsDefault="true" Description="Runs job purging using default values.">
		<SQLScript>
			<![CDATA[

declare
	 @CRLF								nchar(2) = char(13) + char(10)										-- constant for formatting job syntax script
	,@jobSID							int																								-- key of the sf.Job#Simulate record in sf.Job		
	,@jobSCD							varchar(128)																			-- code for the job to insert
	,@callSyntaxTemplate	nvarchar(max)																			-- syntax for the job with replacement tokens
	,@conversationHandle	uniqueidentifier																	-- ID assigned to each job conversation

-- add the sproc to the job table if not already defined there

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

waitfor delay '00:00:10'

select 
	'OK' Result
	,jr.JobStatusSCD
	,jr.JobSID
	,jr.JobLabel
from
	sf.vJobRun jr
where
	jr.JobSID = @jobSID	
and
	jr.JobStatusSCD <> 'FAILED'
and
	datediff(seconds, jr.UpdateTime, sysdatetime()) < 30

]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="OK"/>
			<Assertion Type="ExecutionTime" Value="00:00:15" ResultSet="1"  />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pJobHistory#Purge'
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo				int						= 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@messageText		nvarchar(4000)												-- message text (for business rule errors)    
	 ,@ON							bit						= cast(1 as bit)				-- used on bit comparisons to avoid multiple casts
	 ,@OFF						bit						= cast(0 as bit)				-- used on bit comparisons to avoid multiple casts
	 ,@eventsPurged		int																		-- counts sf.JobScheduleEvent rows purged
	 ,@runsPurged			int																		-- counts sf.JobRun rows purged
	 ,@monthsToRetain int																		-- retention period in months from sf.ConfigParam
	 ,@isCancelled		bit																		-- tracks whether job was cancelled by user
	 ,@termLabel			nvarchar(35)													-- buffer for configurable label text
	 ,@eventTraceLog	nvarchar(max)													-- text block for detailed results of schedule event purge
	 ,@runTraceLog		nvarchar(max)													-- text block for detailed results of job run purge
	 ,@traceLog				nvarchar(max)													-- trace log combined
	 ,@nextSID				int																		-- next PK value to delete - for error reporting trace
	 ,@CRLF						nchar(2)			= char(13) + char(10);	-- carriage return line feed for formatting text blocks

	set @RecordsPurged = 0;

	begin try

		-- read the configuration parameter to determine retention period

		set @monthsToRetain = cast(isnull(sf.fConfigParam#Value('JobHistoryRetentionMonths'), '1') as int);
		if @monthsToRetain > 3 set @monthsToRetain = 3; -- three months is maximum retention period allowed

		if @JobSID is null
		begin

			exec sf.pJobHistory#Purge$JobScheduleEvent
				@JobRunSID = @JobRunSID
			 ,@MonthsToRetain = @monthsToRetain
			 ,@IsCancelled = @isCancelled output
			 ,@RecordsPurged = @eventsPurged output
			 ,@TraceLog = @eventTraceLog output
			 ,@NextSID = @nextSID output;

		end;

		exec sf.pJobHistory#Purge$JobRun
			@JobRunSID = @JobRunSID
		 ,@JobSID = @JobSID
		 ,@MonthsToRetain = @monthsToRetain
		 ,@IsCancelled = @isCancelled output
		 ,@RecordsPurged = @eventsPurged output
		 ,@TraceLog = @runTraceLog output
		 ,@NextSID = @nextSID output;

		set @RecordsPurged = isnull(@eventsPurged, 0) + isnull(@runsPurged, 0);
		set @traceLog = isnull(@eventTraceLog + @CRLF + @CRLF, N'') + isnull(@runTraceLog, N'');

		-- update job with final totals 

		if @JobRunSID is not null and @isCancelled = @OFF
		begin

			-- get result message based on whether any records
			-- were found for purging

			if @RecordsPurged = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NoRecordsPurged'
				 ,@MessageText = @messageText output
				 ,@DefaultText = N'Processing complete. No records were found that required purging according to the retention criteria of %1 months.'
				 ,@Arg1 = @monthsToRetain;

			end;
			else
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordsPurged'
				 ,@MessageText = @messageText output
				 ,@DefaultText = N'Purging complete. %1 records were removed.'
				 ,@Arg1 = @RecordsPurged;

			end;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @RecordsPurged
			 ,@RecordsProcessed = @RecordsPurged
			 ,@TotalErrors = 0
			 ,@ResultMessage = @messageText;

		end;

	end try
	begin catch

		if @JobRunSID is not null
		begin

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'JOB.FAILED'
			 ,@TermLabel = @termLabel output
			 ,@DefaultLabel = N'*** JOB FAILED'
			 ,@UsageNotes = N'A label reporting failure of jobs (normally accompanied by error report text from the database).';

			set @messageText = @termLabel + isnull(N' AT JobRunSID : ' + ltrim(@nextSID) + @CRLF, N'');
			set @messageText += @CRLF + error_message();

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@ResultMessage = @messageText
			 ,@TraceLog = @traceLog
			 ,@IsFailed = @ON;

		end;

		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw

	end catch;

	return (@errorNo);

end;
GO
