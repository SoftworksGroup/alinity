SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJob#Simulate]
	 @JobRunSID										int																				-- key of sf.JobRun record to update with progress
	,@RecordsToSimulate						int	 = 250																-- count of records to simulate = runtime in seconds
	,@UpdateInterval							int	 = 10																	-- reporting interval in records, to update sf.JobRun
	,@ErrorFrequency							int	 = 100																-- error simulation every X records 
as
/*********************************************************************************************************************************
Procedure	: Job Simulate
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Simulates job activity for testing
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Jun	2013		|	Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is used in testing the Job sub-system.  The procedure is not required in PRODuction deployments, however, it does
not update the database so it does not pose a risk in production deployments.  The procedure accepts a key of an existing 
sf.JobRun record to post updates to.  The @RecordsToSimulate parameter is used as a total runtime duration in seconds for the 
simulation.  The procedure waits 1 second for record to simulate and every @UpdateInterval seconds it writes an update of 
"records" processed to the sf.JobRun record.  The progress of the job can be observed on the user interface.

Note that for error simulating, the value of @ErrorFrequency must be a multiple of @UpdateInterval.

In addition to providing a basis for testing the Job sub-system, the sproc also provides a example to follow when creating 
application-specific stored procedures for use with asynchronous calling.  For example, in addition to updating progress
periodically, procedures using the job system need to check for cancellation requests and terminate early when required. (Jobs
can also be defined as non-cancellable in the sf.Job record).  

Example:
--------

declare
	 @JOBCOUNT						int	 = 5																					-- controls the number of concurrent jobs simulated
	,@CRLF								nchar(2) = char(13) + char(10)										-- constant for formatting job syntax script
	,@jobSID							int																								-- key of the sf.Job#Simulate record in sf.Job		
	,@recordsToSimulate		int																								-- set to random value of records to simulate in job
	,@updateInterval			int = 10																					-- update interval to use (change as required)
	,@i										int	 = 0																					-- loop index
	,@callSyntaxTemplate	nvarchar(max)																			-- syntax for the job with replacement tokens
	,@parameters					xml																								-- buffer to record parameters for the call syntax
	,@conversationHandle	uniqueidentifier																	-- ID assigned to each job conversation

-- add the job simulation job record if not already established

select
	@jobSID = j.JobSID
from
	sf.Job j
where
	j.JobSCD = 'sf.pJob#Simulate'

if @jobSID is null
begin

	set @callSyntaxTemplate = 
		'exec sf.pJob#Simulate' 
		+ @CRLF + '   @JobRunSID         = {JobRunSID}'
		+ @CRLF + '  ,@RecordsToSimulate = {p1}'
		+ @CRLF	+ '  ,@UpdateInterval    = {p2}'

	exec sf.pJob#Insert
		 @JobSID							= @jobSID		output
		,@JobSCD							= 'sf.pJob#Simulate'
		,@JobLabel						= N'Job Activity Simulator (Test)'
		,@CallSyntaxTemplate	= @callSyntaxTemplate
		,@IsParallelEnabled   = 1

end

-- start the requested number of jobs

while @i < @JOBCOUNT
begin

	set @i += 1
	set @recordsToSimulate = round(((5000 - 5 - 1) * rand() + 5), 0)				-- generate random number of records to simulate between 5 and 5000 (85 minutes runtime)

	set @parameters = cast(N'<Parameters p1="' + ltrim(@recordsToSimulate) + '" p2="' + ltrim(@updateInterval) + '"/>' as xml)

	exec sf.pJob#Call
		 @JobSCD								= 'sf.pJob#Simulate'
		,@Parameters						= @parameters
		,@ConversationHandle		= @conversationHandle output

	print (ltrim(@i) + ' ' + cast(@conversationHandle as nvarchar(100)))

end
----------------------- Run Section above first --------------------------

----------------------- To Monitor the jobs ------------------------------
select top (1) 
	* 
from 
	sf.vJobRun 
order by 
	UpdateTime desc

----------------------- To cancel a job ----------------------------------
declare
	 @jobRunSID			int
	,@now						datetimeoffset(7)

select top (1)																															-- cancels the last job updated
	@jobRunSID = jr.JobRunSID
from
	sf.JobRun jr
order by
	jr.UpdateTime desc

set @now = sysdatetimeoffset()

exec sf.pJobRun#Update
	 @JobRunSID								= @JobRunSID
	,@CancellationRequestTime = @now


------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
		,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
		,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
		,@blankParm												varchar(128)												-- name of required parameter left blank
		,@recordsProcessed								int = 0
		,@delayLength											char(8)
		,@totalRecords										int
		,@totalErrors											int	= 0
		,@isCancelled											bit = cast(0 as bit)
		
	begin try

		-- reset defaults where passed as null

		if @RecordsToSimulate	is null set @RecordsToSimulate	= 250						
		if @UpdateInterval		is null set @UpdateInterval			= 10
		if @ErrorFrequency		is null set	@ErrorFrequency			= 100

		-- check parameters

		if @JobRunSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= '@JobRunSID'

			raiserror(@errorText, 18, 1)
		end

		if not exists (select 1 from sf.JobRun x where x.JobRunSID = @JobRunSID)
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RecordNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1        = 'sf.JobRun'
				,@Arg2        = @JobRunSID
				
			raiserror(@errorText, 18, 1)

		end			

		if @ErrorFrequency%@UpdateInterval <> 0
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'ErrorFrequencyInvalid'
				,@MessageText = @errorText output
				,@DefaultText = N'The Error Frequency value (%1) must be a multiple of the Update Interval (%2) in order for errors to be simulated.'
				,@Arg1        = @ErrorFrequency
				,@Arg2        = @UpdateInterval
				
			raiserror(@errorText, 16, 1)

		end
			
		-- update the job run record with the total number of records (simulated as seconds)

		exec sf.pJobRun#Update
			 @JobRunSID						= @JobRunSID
			,@TotalRecords				= @RecordsToSimulate
			,@CurrentProcessLabel = 'Initiating simulation ...'

		-- process as many intervals as fit within the total record count
		-- the "waitfor delay ..." syntax is used to simulate the work load

		while @recordsProcessed < @RecordsToSimulate and @isCancelled = cast(0 as bit)
		begin

			-- if more records (seconds) remain than the size of the update interval
			-- wait for another interval duration; otherwise wait for the number of
			-- seconds remaining in the total duration (seconds = records)

			if @RecordsToSimulate - @recordsProcessed > @UpdateInterval																													
			begin
				set @delayLength = cast('00:00:' + right('0' + ltrim(@UpdateInterval), 2) as char(8))
				set @recordsProcessed += @UpdateInterval
			end
			else
			begin
				set @delayLength = cast('00:00:' + right('0' + ltrim(@RecordsToSimulate - @recordsProcessed), 2) as char(8))
				set @recordsProcessed += (@RecordsToSimulate - @recordsProcessed)
			end

			waitfor delay @delayLength

			-- call a library routine to check for cancellation requests, too many errors and
			-- to update the record count

			if @recordsProcessed = 0 or @recordsProcessed%@UpdateInterval = 0
			begin

				-- check if a cancellation request occurred

				if exists
				(
					select
						1
					from
						sf.JobRun jr
					where
						jr.CancellationRequestTime is not null
					and
						jr.JobRunSID = @JobRunSID
				)
				begin
					set @isCancelled = @ON
				end

				exec sf.pJobRun#Update
					 @JobRunSID						= @JobRunSID
					,@RecordsProcessed		= @recordsProcessed
					,@CurrentProcessLabel = 'Simulating job activity ...'
					,@IsCancelled					= @isCancelled

			end

			-- simulate an error on the prescribed frequency; log the error
			-- into the trace log

			if @recordsProcessed%@ErrorFrequency = 0 and @isCancelled = @OFF
			begin

				set @totalErrors += 1

				exec sf.pJobRun#Update
					 @JobRunSID						= @JobRunSID
					,@TotalErrors					= @totalErrors

			end

		end

		-- mark the job if not already marked complete by cancellation or
		-- a too-many-errors scenario

		if @isCancelled = @OFF
		begin

			exec sf.pJobRun#Update
				 @JobRunSID						= @JobRunSID
				,@RecordsProcessed		= @recordsProcessed
				,@ResultMessage				= N'Processing complete'

		end

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
