SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pEmailTrigger#Execute
	@JobRunSID								int = null	-- reference to sf.JobRun for async call updates
 ,@EmailTriggerSIDImmediate int = null	-- to force 1 trigger to be called immediately (testing scenarios)
as
/*********************************************************************************************************************************
Procedure	: Email Trigger Generation
Notice		: Copyright © 2013 Softworks Group Inc. 
Summary		: Reads the job schedule and calls jobs that are due to run then resets the schedule to be read at next check interval
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Cory Ng			| Jun	2016		|	Initial version 
					: Tim Edlund	| Aug 2018		| Added support for @SelectionTime in trigger queries (renamed from @LastStartTime)
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This procedure is a component of the email system.  The procedure generates email records (sf.PersonEmailMessage) according to 
query criteria and other details defined in Email Trigger definitions (sf.EmailTrigger). The procedure is designed to be called 
at regular intervals during business hours to create new emails as conditions in the database change. The queries typically 
locate records meeting certain conditions and then send out emails to the associated people.  The back-ground calling of the
procedure is accomplished through the Job and Job-Schedule system.

For example, a built-in Email Trigger provided with the products is "Password must be changed".  A query is defined in 
sf.Query  to identify application user profiles who have not changed their password in over X months. This procedure runs the 
query to find records that meet the criteria and then generates email message records for each of them.  Logic within this procedure 
avoids creating duplicate emails.  If an email has already been created for the record then the record is skipped for email 
creation.

The Email Trigger columns "Subject" and "Body" may contain column name symbols which are replaced with values from the
associated entity. This logic is done at when the email message is queued.

Example
-------
<TestHarness>
  <Test Name = "Synchronous" IsDefault ="true" Description="Stops scheduler and runs email trigger process once sychronously
        then restarts scheduler.">
    <SQLScript>
      <![CDATA[
exec sf.pJobSchedule#Stop; -- stop job schedule to prevent conflicts when testing

exec sf.pEmailTrigger#Execute;

waitfor delay '00:00:03'; -- wait for job to start

select * from		sf.vPersonEmailMessage order by CreateTime desc;	-- review emails created

exec sf.pJobSchedule#Start; -- restart job schedule when test is complete
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:05:00"/>
    </Assertions>
  </Test>
  <Test Name = "Asynch"  Description="Calls the email trigger process asynchronnously but not using the job scehduler.">
    <SQLScript>
      <![CDATA[

declare
  @jobSID							int															-- key of the sf.Job#Simulate record in sf.Job		
 ,@jobSCD							varchar(128)										-- code for the job to insert
 ,@parameters					xml;														-- buffer to record parameters for the call syntax

set @jobSCD = 'sf.pEmailTrigger#Execute'; -- add the job syntax if not already established 

select @jobSID = j .JobSID from sf.Job j where j.JobSCD = @jobSCD;

if @jobSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec sf.pJob#Call
		@JobSCD = @jobSCD
	 ,@Parameters = @parameters;

	waitfor delay '00:00:03'; -- wait for job to start

	select top (3) -- use this select to monitor the job
		*
	from
		sf.vJobRun jr
	order by
		jr.UpdateTime desc;


end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pEmailTrigger#Execute"
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo									 int							= 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText								 nvarchar(4000)													-- message text (for business rule errors)    
	 ,@ON												 bit							= cast(1 as bit)			-- used on bit comparisons to avoid multiple casts
	 ,@OFF											 bit							= cast(0 as bit)			-- used on bit comparisons to avoid multiple casts
	 ,@progressTrace						 nvarchar(max)													-- content for tracing progress to point of error
	 ,@readTime									 datetimeoffset(7)											-- time at start of procedure 
	 ,@emailTriggerSID					 int							= -1									-- next email trigger SID to process
	 ,@queryParameters					 xml																		-- passes column values from the parent email trigger row to the query
	 ,@querySID									 int																		-- ID of query that gets source rows for the emails
	 ,@applicationEntitySID			 int																		-- identifies table that is source of rows for emails
	 ,@rowStamp									 timestamp															-- row stamp of next trigger - to avoid overwrites
	 ,@createdEmailCount				 int																		-- counts email actually created (for each type)
	 ,@i												 int																		-- loop index - emails
	 ,@maxRow										 int																		-- loop limiter - email of one type to insert
	 ,@subject									 nvarchar(120)													-- subject of email with replacements
	 ,@body											 varbinary(max)													-- body binary of email with replacements
	 ,@recordSID								 int																		-- SID to use to lookup entity record for replacements
	 ,@linkExpiryHours					 int																		-- indicates when the email link expires
	 ,@isApplicationUserRequired bit																		-- indicates if a application user is required
	 ,@priorityLevel						 tinyint																-- priority level of the email
	 ,@CRLF											 nchar(2)					= char(13) + char(10) -- carriage return line feed for formatting text blocks
	 ,@TAB											 nchar(1)					= char(9)							-- tab character for formatting text blocks
	 ,@emailTriggerLabel				 nvarchar(35)														-- label of the trigger being processed
	 ,@termLabel								 nvarchar(35)														-- buffer for configurable label text
	 ,@isCancelled							 bit							= 0										-- checks for cancellation request on async job calls  
	 ,@recordsProcessed					 int							= 0										-- running total of entities processed   		
	 ,@resultMessage						 nvarchar(4000)													-- summary of job result
	 ,@traceLog									 nvarchar(max)													-- text block for detailed results of job
	 ,@isDuplicate							 bit																		-- indicates if the email is a duplicate
	 ,@personSID								 int																		-- person to send the email to
	 ,@emailMessageSID					 int																		-- the email message identifier
	 ,@targetEmailAddress				 varchar(150)														-- email address of the target person
	 ,@minDaysToRepeat					 int;																		-- number of days before a regen is allowed on "duplicates"

	declare @work table
	(
		ID					int identity(1, 1)
	 ,RecordSID		int not null
	 ,PersonSID		int not null
	 ,IsDuplicate bit not null default cast(0 as bit)
	);

	begin try

		-- if a specific trigger is passed, ensure it is valid

		if @EmailTriggerSIDImmediate is not null
		begin

			if not exists
			(
				select
					1
				from
					sf.EmailTrigger x
				where
					x.EmailTriggerSID = @EmailTriggerSIDImmediate
			)
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'sf.EmailTrigger'
				 ,@Arg2 = @EmailTriggerSIDImmediate;

				raiserror(@errorText, 18, 1);

			end;

		end;

		if @JobRunSID is not null -- if call is async, update the job run record
		begin

			set @traceLog = sf.fPadR(N'E M A I L   C R E A T I O N   S U M M A R Y', 45) -- format header for trace log
											+ @TAB + N'Created' + @CRLF + sf.fPadR('-----------------------------------------------------', 53);

		end;

		set @progressTrace = N'JobRunSID = ' + isnull(ltrim(@JobRunSID), 'None');

		while @emailTriggerSID is not null and @isCancelled = @OFF -- @emailTriggerSID initialized to -1 in declare above
		begin

			if @JobRunSID is not null
			begin

				exec sf.pTermLabel#Get
					@TermLabelSCD = 'SELECTING.EMAIL.TRIGGER'
				 ,@TermLabel = @termLabel output
				 ,@DefaultLabel = N'Selecting email trigger ...'
				 ,@UsageNotes = N'A label reporting processing status when email triggers are being selected for processing.';

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@CurrentProcessLabel = @termLabel;

			end;

			set @emailTriggerSID = null;
			set @readTime = sysdatetimeoffset();
			set @createdEmailCount = 0;
			set @queryParameters = null;

			-- if an explicit trigger was passed and is in a running 
			-- status, set its end time to allow a restart

			if exists
			(
				select
					1
				from
					sf.EmailTrigger x
				where
					x.EmailTriggerSID = @EmailTriggerSIDImmediate and x.LastStartTime is not null and x.LastEndTime is null
			)
			begin

				exec sf.pEmailTrigger#Update
					@EmailTriggerSID = @EmailTriggerSIDImmediate
				 ,@LastEndTime = @readTime;

			end;

			-- get the next trigger until no more are due to be processed; multiple calls to this 
			-- procedure run concurrently so avoid triggers that are running (already being processed)

			select top (1)
				@emailTriggerSID					 = et.EmailTriggerSID
			 ,@minDaysToRepeat					 = et.MinDaysToRepeat
			 ,@querySID									 = et.QuerySID
			 ,@applicationEntitySID			 = ae.ApplicationEntitySID
			 ,@rowStamp									 = et.RowStamp
			 ,@emailTriggerLabel				 = et.EmailTriggerLabel
			 ,@priorityLevel						 = e.PriorityLevel
			 ,@subject									 = e.Subject
			 ,@body											 = e.Body
			 ,@isApplicationUserRequired = e.IsApplicationUserRequired
			 ,@linkExpiryHours					 = e.LinkExpiryHours
			 ,@queryParameters					 =
					cast(N'<Parameters>
	<Parameter ID="SelectionTime" Type="DatePicker" Value="'
							 + format( (case
														when et.EarliestSelectionDate is null then et.LastStartTime
														when sf.fClientDateToDTOffset(et.EarliestSelectionDate) > et.LastStartTime then sf.fClientDateToDTOffset(et.EarliestSelectionDate)
														else et.LastStartTime
													end -- the selection date is set to the LATER OF of the earliest selection date entered in the UI and the last time the trigger ran
												 )
												,'yyyyMMdd HH:mm:ss'
											 ) + '"/>
	</Parameters>' as xml)	-- last start and end times to provide to the query
			from
				sf.EmailTrigger																		 et
			cross apply sf.fEmailTrigger#Ext(et.EmailTriggerSID) etx
			join
				sf.Query						 q on et.QuerySID							= q.QuerySID
			join
				sf.EmailTemplate		 e on et.EmailTemplateSID			= e.EmailTemplateSID
			left outer join
				sf.ApplicationEntity ae on e.ApplicationEntitySID = ae.ApplicationEntitySID
			where
				etx.IsRunning																														= @OFF
				and et.IsActive																													= @ON
				and
				(
					(
						@EmailTriggerSIDImmediate is null and etx.NextScheduledTimeServerTZ <= @readTime
					) or et.EmailTriggerSID																								= @EmailTriggerSIDImmediate
				)
			order by
				etx.NextScheduledTimeServerTZ;

			if @emailTriggerSID is not null
			begin

				set @progressTrace += @CRLF + N'EmailTriggerSID = ' + isnull(ltrim(@emailTriggerSID), 'NULL');

				-- mark this email trigger as running to prevent other instances of the sproc
				-- from processing it at the same time

				exec sf.pEmailTrigger#Update
					@EmailTriggerSID = @emailTriggerSID
				 ,@LastStartTime = @readTime
				 ,@RowStamp = @rowStamp;	-- to check for overwrites

				set @recordsProcessed += 1;

				if @JobRunSID is not null
				begin

					exec sf.pJobRun#Update
						@JobRunSID = @JobRunSID
					 ,@CurrentProcessLabel = @emailTriggerLabel
					 ,@RecordsProcessed = @recordsProcessed;

					set @progressTrace += @CRLF + N'EmailTrigger start update OK';

				end;

				-- remove records from the work table that were processed in the
				-- last query; NOTE: this does not reset identity!

				delete @work;

				set @progressTrace += @CRLF + N'Variable reset OK';

				-- execute the query to return SID values for records
				-- that meet the criteria for email creation along
				-- with the person SID to send the email to

				insert
					@work (RecordSID, PersonSID)
				exec sf.pQuery#Execute
					@QuerySID = @querySID
				 ,@QueryParameters = @queryParameters;

				set @progressTrace += @CRLF + N'Query execute OK';

				-- mark duplicates where records already have emails created for them
				-- for this email trigger;

				update
					w
				set
					w.IsDuplicate = @ON
				from
					@work									w
				join
					sf.PersonEmailMessage pem on w.RecordSID = pem.MergeKey and w.PersonSID = pem.PersonSID and pem.EmailTriggerSID = @emailTriggerSID
				where
					@minDaysToRepeat is null or sf.fDTOffsetToClientDateTime(dateadd(dd, @minDaysToRepeat, pem.CreateTime)) >= sf.fNow();

				set @progressTrace += @CRLF + N'Duplicate update OK';

				-- identity on memory table is not reset so must be max ID
				-- based on query

				select @maxRow = max (w.ID), @i = 0 from @work w ;

				set @progressTrace += @CRLF + N'Email insert to memory (max ID = ' + isnull(ltrim(@maxRow), 'NULL') + N') OK';

				while @i < @maxRow
				begin

					set @recordSID = null;
					set @personSID = null;

					select
						@i = min(w.ID)	-- identity was not reset, so must query for next ID
					from
						@work w
					where
						w.ID > @i;

					select
						@recordSID					= w.RecordSID
					 ,@personSID					= w.PersonSID
					 ,@isDuplicate				= w.IsDuplicate
					 ,@targetEmailAddress = isnull(pea.EmailAddress, au.UserName)
					from
						@work											 w
					left outer join
						sf.ApplicationUser				 au on w.PersonSID									 = au.PersonSID
					join
						sf.AuthenticationAuthority aa on au.AuthenticationAuthoritySID = aa.AuthenticationAuthoritySID and aa.AuthenticationAuthoritySCD = 'EMAIL.TS'
					left outer join
						sf.PersonEmailAddress			 pea on au.PersonSID								 = pea.PersonSID and pea.IsPrimary = @ON and pea.IsActive = @ON
					where
						w.ID = @i;

					if @personSID is null
					begin
						set @progressTrace += @CRLF + N'Person (ID = ' + isnull(ltrim(@i), 'NULL') + N') not specified';
					end;
					else
					begin
						set @progressTrace += @CRLF + N'Email (ID = ' + isnull(ltrim(@i), 'NULL') + N') retrieved OK';
					end;

					if @isDuplicate = @OFF and @personSID is not null
					begin

						set @progressTrace += @CRLF + N'Email (ID = ' + isnull(ltrim(@i), 'NULL') + N') replacements OK';

						exec sf.pEmailMessage#Insert
							@EmailMessageSID = @emailMessageSID output
						 ,@PriorityLevel = @priorityLevel
						 ,@Subject = @subject
						 ,@Body = @body
						 ,@IsApplicationUserRequired = @isApplicationUserRequired
						 ,@LinkExpiryHours = @linkExpiryHours
						 ,@ApplicationEntitySID = @applicationEntitySID;

						exec sf.pPersonEmailMessage#Insert
							@PersonSID = @personSID
						 ,@EmailMessageSID = @emailMessageSID
						 ,@EmailAddress = @targetEmailAddress
						 ,@MergeKey = @recordSID
						 ,@EmailTriggerSID = @emailTriggerSID;

						exec sf.pEmailMessage#Queue
							@EmailMessageSID = @emailMessageSID;

						set @createdEmailCount += 1;

					end;

				end;

				-- mark the end time to mark the trigger complete

				set @readTime = sysdatetimeoffset();

				exec sf.pEmailTrigger#Update
					@EmailTriggerSID = @emailTriggerSID
				 ,@LastEndTime = @readTime;

				set @progressTrace += @CRLF + N'EmailTrigger end update OK';

				-- update the record count and the result message with 
				-- counts for the email trigger just processed

				if @JobRunSID is not null
				begin

					set @recordsProcessed += 1;

					set @traceLog += @CRLF + sf.fPadR(@emailTriggerLabel, 40) + sf.fPadL(ltrim(@createdEmailCount), 7);

					if exists
					(
						select
							1
						from
							sf.JobRun jr
						where
							jr.CancellationRequestTime is not null and jr.JobRunSID = @JobRunSID
					)
					begin
						set @isCancelled = @ON;
					end;

					exec sf.pJobRun#Update
						@JobRunSID = @JobRunSID
					 ,@RecordsProcessed = @recordsProcessed
					 ,@CurrentProcessLabel = @termLabel -- reset label for selecting next trigger
					 ,@IsCancelled = @isCancelled;

					set @progressTrace += @CRLF + N'Job cancel check OK';

				end;

			end;

			if @EmailTriggerSIDImmediate is not null
			begin
				set @emailTriggerSID = null; -- terminate loop if a trigger was called immediately
			end

		end;

		-- update job with final totals for actually records processed
		-- and errors encountered

		if @JobRunSID is not null and @isCancelled = @OFF
		begin

			if @recordsProcessed = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NoEmailTriggersScheduled'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'No email triggers were scheduled to be processed at this time.  (This is not an error.)';

				set @traceLog = N'(No email triggers to process.)';
			end;
			else
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'JobCompletedSucessfully'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'The %1 job was completed successfully.'
				 ,@Arg1 = 'email creation';

			end;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @recordsProcessed
			 ,@RecordsProcessed = @recordsProcessed
			 ,@TotalErrors = 0
			 ,@TraceLog = @traceLog -- post detailed summary report to trace log
			 ,@ResultMessage = @resultMessage;

			set @progressTrace += @CRLF + N'Job final update OK';

		end;

	end try
	begin catch

		-- errors occurring here will be logged by the job executor
		-- that calls this

		if @@trancount > 0 rollback;

		-- if a failure occurs, ensure the trigger is not marked as still being running

		if exists
		(
			select
				1
			from
				sf.vEmailTrigger et
			where
				et.EmailTriggerSID = @emailTriggerSID and et.IsRunning = @ON
		)
		begin

			set @readTime = sysdatetimeoffset();

			exec sf.pEmailTrigger#Update
				@EmailTriggerSID = @emailTriggerSID
			 ,@LastEndTime = @readTime;

		end;

		if @JobRunSID is not null
		begin

			set @traceLog += @CRLF + @CRLF + N'PROGRESS TRACE' + @CRLF + N'--------------' + @CRLF + error_message() + N' at procedure "' + error_procedure()
											 + N'" line# ' + ltrim(error_line());

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'JOB.FAILED'
			 ,@TermLabel = @termLabel output
			 ,@DefaultLabel = N'*** JOB FAILED'
			 ,@UsageNotes = N'A label reporting failure of jobs (normally accompanied by error report text from the database).';

			set @errorText = @termLabel + isnull(N' AT : ' + @emailTriggerLabel + @CRLF, N'');
			set @errorText += @CRLF + error_message() + N' at procedure "' + error_procedure() + N'" line# ' + ltrim(error_line());

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@ResultMessage = @errorText
			 ,@TraceLog = @traceLog -- post interim result message to trace log for debugging
			 ,@IsFailed = @ON;

		end;
		else 
		begin
			print @progressTrace;
		end;

		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw

	end catch;

	return (@errorNo);

end;
GO
