SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pJob#Call
	@JobSCD							varchar(132)
 ,@Parameters					xml							 = null
 ,@ConversationHandle uniqueidentifier = null output	-- handle identifying job conversation on the queue
as
/*********************************************************************************************************************************
Procedure	: Job Call
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Accepts call syntax for asynchronous job execution
History		: Author(s)  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Jun	2013		|	Initial version 
					: Tim Edlund	| Feb 2018		| Added support for trace of call syntax prior to entry into broker (conversation handle)
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure is a component of the framework's job management system.  The procedure is the starting point for calling jobs.
The procedure may be called directly from the UI when a user selects a job to run manually, and, the procedure is also called
by the scheduling process pJob#CheckSchedule for jobs that are set to run at predefined intervals.

No syntax is passed into the procedure for the job because syntax must be defined in the sf.Job record itself.  The @JobSCD is
used to identify the sf.Job record to retrieve values.  The sf.Job.JobSCD value is normally set to the name of the stored 
procedure with the schema prefix.  (See sf.Job for examples).

The @Parameters value is an XML document that defines parameter values to use in the call.  The parameter values are used as
replacement for "p#" tokens in the call syntax defined in the sf.Job record.  For example, the framework provides a testing
procedure for the job system called pJob#Simulate.  In the sf.Job table its syntax is defined as follows:

	exec sf.pJob#Simulate
		 @JobRunSID         = {JobRunSID}
		,@RecordsToSimulate = {p1}
		,@UpdateInterval    = {p2}

The {JobRunSID} parameter is replaced automatically when the job is called.  That value can be used by the procedure called to
update the sf.JobRun record (created when the job starts).  This allows progress of the procedure to provide updates to the
interface (via changes to the sf.JobRun record) as processing moves along.

The other 2 parameter values - tokenized in this example as "{p1}" and "{p2}" must be replaced with the actual values to be 
used in the call.  Those values are passed through @Parameters.  Supposing the appropriate value for those parameters was 500 and 
10, the format of the XML would be: 

	<Parameters p1="500" p2="10"/>

If any parameter tokens are left un-replaced, they are replaced with the value NULL.  NOTE!! - This results in an explicit pass of 
the NULL value for the parameter.  As a result setting a default in the call signature for the parameter will NOT be successful.  
Ensure the sproc is written to check for NULL explicitly passed and replace with the default within the main body of the procedure.

Example:   (for a more comprehensive example see pJob#Simulate)
--------

declare
	 @CRLF								nchar(2) = char(13) + char(10)										-- constant for formatting job syntax script
	,@jobSID							int																								-- key of the sf.Job#Simulate record in sf.Job		
	,@jobSCD							varchar(128)																			-- code for the job to insert
	,@callSyntaxTemplate	nvarchar(max)																			-- syntax for the job with replacement tokens
	,@parameters					xml																								-- buffer to record parameters for the call syntax
	,@conversationHandle	uniqueidentifier																	-- ID assigned to each job conversation

set @jobSCD = 'sf.pEntitySetVerify'

-- add the entity set verification job if not already established

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
		+ @CRLF + '   @JobRunSID            = {JobRunSID}'
		+ @CRLF + '  ,@VerifyMode           = ''{p1}'''
		+ @CRLF + '  ,@ApplicationEntitySID = {p2}'

	exec sf.pJob#Insert
		 @JobSID							= @jobSID		output
		,@JobSCD							= @jobSCD
		,@JobLabel						= N'Business rule verification'
		,@CallSyntaxTemplate	= @callSyntaxTemplate

end

set @parameters = cast(N'<Parameters p1="p" />' as xml)						-- process p-ending verifications

exec sf.pJob#Call
	 @JobSCD							= @jobSCD
	,@Parameters					= @parameters
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
		@errorNo					 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				 nvarchar(4000)									-- message text (for business rule errors)    
	 ,@ON								 bit					 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF							 bit					 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@jobSID						 int														-- key of the job to run
	 ,@callSyntax				 nvarchar(max)
	 ,@isParallelEnabled bit														-- indicates if multiple copies of jobs can run concurrently
	 ,@i								 int														-- parameter counter
	 ,@nextParmValue		 nvarchar(4000)
	 ,@messageBody			 xml
	 ,@traceLog					 nvarchar(max);									-- debugging trace;

	set @ConversationHandle = null; -- initialize output parameter

	begin try

		-- check parameters

		select
			@jobSID						 = j.JobSID
		 ,@callSyntax				 = j.CallSyntaxTemplate
		 ,@isParallelEnabled = j.IsParallelEnabled
		from
			sf.Job j
		where
			j.JobSCD = @JobSCD;

		if @jobSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.Job'
			 ,@Arg2 = @JobSCD;

			raiserror(@errorText, 18, 1);

		end;

		-- don't allow the job to be called if already running unless parallel calls are supported

		if @isParallelEnabled = @OFF
		begin

			if exists
			(
				select
					1
				from
					sf.vJobRun jr
				where
					jr.JobSCD = @JobSCD and jr.JobStatusSCD = 'INPROCESS'
			)
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'JobAlreadyRunning'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The job (%1) is already running!  Multiple copies of this job cannot run concurrently. Wait for the current job to finish or, if the job is stalled, mark it FAILED.'
				 ,@Arg1 = @JobSCD;

				raiserror(@errorText, 16, 1);

			end;

		end;

		-- replace the parameter values in the call syntax template
		-- note: the {JobRunSID} parameter placeholder is replaced by sf.pJob#Execute (not here)

		set @i = 0;

		while @i < 9
		begin

			set @i += 1;
			set @nextParmValue = null;

			if @Parameters is not null
			begin

				if @i = 1
				begin
					select
						@nextParmValue = ltrim(rtrim(Context.ID.value('@p1[1]', 'nvarchar(4000)')))
					from
						@Parameters.nodes('Parameters') as Context(ID); -- only string literals are supported by SQL XML parse so 9 statements required
				end;
				else if @i = 2
				begin
					select
						@nextParmValue = ltrim(rtrim(Context.ID.value('@p2[1]', 'nvarchar(4000)')))
					from
						@Parameters.nodes('Parameters') as Context(ID);
				end;
				else if @i = 3
				begin
					select
						@nextParmValue = ltrim(rtrim(Context.ID.value('@p3[1]', 'nvarchar(4000)')))
					from
						@Parameters.nodes('Parameters') as Context(ID);
				end;
				else if @i = 4
				begin
					select
						@nextParmValue = ltrim(rtrim(Context.ID.value('@p4[1]', 'nvarchar(4000)')))
					from
						@Parameters.nodes('Parameters') as Context(ID);
				end;
				else if @i = 5
				begin
					select
						@nextParmValue = ltrim(rtrim(Context.ID.value('@p5[1]', 'nvarchar(4000)')))
					from
						@Parameters.nodes('Parameters') as Context(ID);
				end;
				else if @i = 6
				begin
					select
						@nextParmValue = ltrim(rtrim(Context.ID.value('@p6[1]', 'nvarchar(4000)')))
					from
						@Parameters.nodes('Parameters') as Context(ID);
				end;
				else if @i = 7
				begin
					select
						@nextParmValue = ltrim(rtrim(Context.ID.value('@p7[1]', 'nvarchar(4000)')))
					from
						@Parameters.nodes('Parameters') as Context(ID);
				end;
				else if @i = 8
				begin
					select
						@nextParmValue = ltrim(rtrim(Context.ID.value('@p8[1]', 'nvarchar(4000)')))
					from
						@Parameters.nodes('Parameters') as Context(ID);
				end;
				else if @i = 9
				begin
					select
						@nextParmValue = ltrim(rtrim(Context.ID.value('@p9[1]', 'nvarchar(4000)')))
					from
						@Parameters.nodes('Parameters') as Context(ID);
				end;

			end;

			if len(ltrim(rtrim(@nextParmValue))) = 0
				set @nextParmValue = null;

			if @nextParmValue is null and charindex(N'{p' + ltrim(@i) + '}', @callSyntax) > 0
			begin
				set @nextParmValue = N'null';
			end;

			if @nextParmValue is not null
			begin
				set @callSyntax = replace(@callSyntax, '{p' + ltrim(@i) + '}', @nextParmValue);
				set @callSyntax = replace(@callSyntax, 'N''null''', 'null'); -- convert string N'NULL' to literal NULL
				set @callSyntax = replace(@callSyntax, '''null''', 'null');
			end;

		end;

		-- build the message as an XML value: include the job SID and the call syntax

		if @nextParmValue not like '<%>' set @nextParmValue = replace(@nextParmValue, '"', '''')	-- exclude XML parameters from this replacement, it creates invalid XML
		set @messageBody =
		(
			select 
				 @jobSID			JobSID
				,@callSyntax	CallSyntax
			for xml raw('Job')
		)

		if exists
		(
			select 1 from		sf.Job j where j.JobSID = @jobSID and j.IsFullTraceEnabled = @ON
		)
		begin

			update
				sf.Job
			set
				TraceLog = left('Call: ' + sf.fApplicationUserSession#UserName() + ' | ' + cast(sysdatetime() as nvarchar(22)) + ' ' + char(13) + char(10) + @callSyntax
									 + isnull(char(13) + char(10) + char(13) + char(10) + TraceLog, N''), 1000) 
			where
				JobSID = @jobSID;

		end;

		-- send the message

		begin dialog conversation @ConversationHandle
		from service JobRequest -- send a message from the JobRequest to JobProcess
		to service 'JobProcess'
		on contract JobContract
		with
			encryption = off;

		send on conversation
			@ConversationHandle -- the message is the job syntax; read by sf.pJobReceive
		message type JobRequest
		(@messageBody);

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
