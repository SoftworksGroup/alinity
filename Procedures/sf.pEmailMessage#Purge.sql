SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pEmailMessage#Purge
	@EmailMessages			xml										-- keys of email message records to purge (1 to N keys supported)
 ,@UpdateUser					nvarchar(75) = null		-- optional update user to write to the records when running in a job
 ,@TotalRecordCount		int = null output			-- count of parent (EmailMessage) records processed (includes errors)
 ,@TotalErrorCount		int = null output			-- count of errors encountered
 ,@TotalDocumentCount int = null output			-- count of email documents purged
 ,@JobRunSID					int = null						-- sf.JobRun record to update on asynchronous calls
 ,@ReturnSelect				bit = 0								-- when 1 output values are returned as a dataset
 ,@DebugLevel					int = 0								-- when 1 or higher debug output is written to console
as
/*********************************************************************************************************************************
Sproc    : Person Email Message - Purge
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure trims (sets to NULL) the  the Email-Document column of Person-Email-Message record where archived
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This procedure is used to remove the PDF documents of person-email-message records where the ArchivedTime has been set. By 
removing the document, space is freed up in the database.  As space beyond certain thresholds is charged to clients, this feature
provides clients control over managing their most-disk-space intensive data and associated costs. 

The expected work-flow is for users to mark selected PDFs as archived as a precursor to using this procedure. Marking messages
as archived set the Archived-Time column on the sf.EmailMessage (parent) record.  With this value set, the message appears in 
the "Archived" tab on the UI.  To find the records they to archive the users executes product or custom queries - typically
finding emails that are older and/or sent to large numbers of recipients.

The next step in the UI to purge records is to select records from the Archived tab.  The record keys are passed to this
procedure for processing.  The procedure is normally run in background to avoid timing out on very large record sets. The
procedure moves through each key value provided and first checks that the message (sf.EmailMessage) has been marked for
archiving. If the archived time is not set an error is raise: to the log or UI depending on whether it is being run as a job.
If the archived time has been set the procedure then set the EmailDocument column on the (child) sf.PersonEmailMessage to null. 
The Body column is also set to NULL in case this trimming did not occur earlier.

Multiple email message keys will normally be provided in this process but a single key may also be passed. The keys must be 
passed in the XML parameter using the following format:

<EmailMessages>
		<EmailMessage SID="1003170" />
		<EmailMessage SID="1000011" />
		<EmailMessage SID="1000123" />
</EmailMessages> 
 
Asynchronous Calling
--------------------
This procedure supports being called asynchronously through the built-in job system. Asynchronous processing is invoked by
passing a @JobSID parameter. Running jobs can be monitored with progress updates through the Job Monitor page on the UI.
Cancelling of running jobs is also supported from the UI.  This subroutine should not be invoked with any transaction pending.
If a non-zero @@trancount is detected at startup, an error is returned.

Known Limitations
-----------------
Purging does NOT eliminate the Person-Email-Message record. A "purge-delete" option is not offered. The person-email-message 
record remains in place as a long-term index of who the message was distributed, the time and date sent, receiving 
email address, and whether or not the message was opened.  

Example
-------
<TestHarness>
  <Test Name = "Sync" IsDefault ="true" Description="Executes the procedure with a synchronous call limited to 3 records 
	processed.">
    <SQLScript>
      <![CDATA[

declare @emailMessages xml;

if not exists (select 1 from sf .EmailMessage em where em.ArchivedTime is not null)
begin

	-- create some archived message if none exist

	update
		em
	set
		em.ArchivedTime = sysdatetimeoffset()
	 ,em.UpdateTime = sysdatetimeoffset()
	 ,em.UpdateUser = 'UnitTest@softworksgroup.com'
	from
	(
		select top (3)
			em.EmailMessageSID
		from
			sf.vEmailMessage em
		where
			em.PurgedTime is null and em.CancelledTime is null and em.RecipientCount = em.SentCount and em.SentCount > 0
		order by
			newid()
	)									x
	join
		sf.EmailMessage em on x.EmailMessageSID = em.EmailMessageSID
	where
		em.PurgedTime is null;

end;

select
	@emailMessages =
(
	select top (3)
		EmailMessage.EmailMessageSID SID
	from
		sf.EmailMessage EmailMessage
	where
		EmailMessage.ArchivedTime is not null
	and
		EmailMessage.PurgedTime is null
	order by
		EmailMessage.ArchivedTime
	for xml auto, type, root('EmailMessages')
);

exec sf.pEmailMessage#Purge
	@EmailMessages = @emailMessages
 ,@ReturnSelect = 1
 ,@DebugLevel = 2;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:01:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pEmailMessage#Purge'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						 int					 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					 nvarchar(4000)																					-- message text for business rule errors
	 ,@procName						 nvarchar(128) = object_name(@@procid)									-- name of currently executing procedure
	 ,@ON									 bit					 = cast(1 as bit)													-- constant for bit comparisons = 1
	 ,@OFF								 bit					 = cast(0 as bit)													-- constant for bit comparison = 0
	 ,@resultMessage			 nvarchar(4000)																					-- summary of job result
	 ,@isCancelled				 bit					 = cast(0 as bit)													-- checks for cancellation request on async job calls  
	 ,@maxRow							 int																										-- loop limit
	 ,@i									 int																										-- loop index counter
	 ,@emailMessageSID		 int																										-- identifies next record to be processed
	 ,@currentProcessLabel nvarchar(35);																					-- label for stage of work

	set @UpdateUser = isnull(@UpdateUser, sf.fApplicationUserSession#UserName());
	declare @work table (ID int not null identity(1, 1), EmailMessageSID int not null);

	-- ensure output parameters are set for all code paths

	set @TotalRecordCount = 0;
	set @TotalErrorCount = 0;
	set @TotalDocumentCount = 0;

	begin try

		if @DebugLevel is null set @DebugLevel = 0;

		if @@trancount > 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'TransactionPending'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A transaction was started prior to calling this procedure. Procedure "%1" does not allow nested transactions.'
			 ,@Arg1 = @procName;

			raiserror(@errorText, 18, 1);

		end;

		if @JobRunSID is not null -- if call is async, update the job run record
		begin

			set @ReturnSelect = 0;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@CurrentProcessLabel = N'Retrieving configuration ...';

		end;

		-- parse XML key values into table for processing
		
		insert
			@work (EmailMessageSID)
		select
			EmailMessage.p.value('@SID', 'int')
		from
			@EmailMessages.nodes('//EmailMessage') EmailMessage(p);

		set @maxRow = @@rowcount;
		set @i = 0;

		if @maxRow = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NoRecordsSelected'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'No %1 are selected for processing.  Click check-boxes on left-hand-side of records to select.'
			 ,@Arg1 = 'Email Messages';

			raiserror(@errorText, 16, 1);

		end;

		-- process each record

		while @i < @maxRow and @isCancelled = @OFF
		begin

			set @i += 1;

			select @emailMessageSID	 = w.EmailMessageSID from @work w where w.ID = @i;

			set @currentProcessLabel = N'Processing: ' + ltrim(@emailMessageSID) + N' ...';

			-- if an async call update the processing label

			if @JobRunSID is not null and (@i = 1 or @i % 50 = 0)
			begin

				-- check if a cancellation request occurred
				-- where job is running in async mode

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
				 ,@CurrentProcessLabel = @currentProcessLabel
				 ,@IsCancelled = @isCancelled;

			end;

			if @isCancelled = @OFF
			begin

				if @DebugLevel > 1 -- show process label if debugging
				begin
					print @currentProcessLabel;
				end;

				begin try

					if exists
					(
						select
							1
						from
							sf.EmailMessage em
						where
							em.EmailMessageSID = @emailMessageSID and em.ArchivedTime is null
					)
					begin

						exec sf.pMessage#Get
							@MessageSCD = 'EmailNotArchived'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'Email message (SID: %1) is not marked as archived. The purging operation cannot be performed on this record.'
						 ,@Arg1 = @emailMessageSID;

						raiserror(@errorText, 18, 1);
					end;

					begin transaction;

					update
						sf.PersonEmailMessage
					set
						Body = null
					 ,EmailDocument = null
					 ,UpdateTime = sysdatetimeoffset()
					 ,UpdateUser = @updateUser
					where
						EmailMessageSID = @emailMessageSID and EmailDocument is not null;

					set @TotalDocumentCount += @@rowcount;

					update
						sf.EmailMessage
					set
						PurgedTime = sysdatetimeoffset()
					 ,UpdateTime = sysdatetimeoffset()
					 ,UpdateUser = @updateUser
					where
						EmailMessageSID = @emailMessageSID;

					set @TotalRecordCount += 1;

					commit;

				end try
				begin catch

					set @TotalErrorCount += 1;
					set @TotalRecordCount += 1;

					if @@trancount > 0 rollback; -- rollback the last transaction to allow the error to be logged

					if isnull(@JobRunSID, 0) = 0 and @DebugLevel > 0
					begin
						if @DebugLevel = 1 print @currentProcessLabel;
						print (error_message());
					end;

					-- if the procedure is running asynchronously record the
					-- error, else re-throw it to end processing

					if isnull(@JobRunSID, 0) > 0
					begin

						insert
							sf.JobRunError (JobRunSID, MessageText, DataSource, RecordKey)
						select
							@JobRunSID
						 ,N'* ERROR: ' + error_message()
						 ,'EmailMessage'
						 ,isnull(ltrim(@emailMessageSID), 'NULL');

					end;

					if isnull(@JobRunSID, 0) = 0 -- exit unless running async
					begin
						exec @errorNo = sf.pErrorRethrow;
					end;

				end catch;

			end;

		end;

		-- update job with final totals for actually records processed
		-- and errors encountered

		if @JobRunSID is not null and @isCancelled = @OFF
		begin

			if @maxRow = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NoRecordsToProcess'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'Warning: No records were found to process. Configuration updates may be required.';

			end;
			else
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'JobCompletedSucessfully'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'The %1 job was completed successfully.'
				 ,@Arg1 = 'Email Document Purge';

			end;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @TotalRecordCount
			 ,@RecordsProcessed = @TotalRecordCount
			 ,@TotalErrors = @TotalErrorCount
			 ,@ResultMessage = @resultMessage;

		end;

		if @ReturnSelect = @ON
		begin

			select
				@TotalRecordCount		ParentMessageCount
			 ,@TotalErrorCount		TotalErrorCount
			 ,@TotalDocumentCount PurgedDocuments;

		end;

	end try
	begin catch

		if @@trancount > 0 -- rollback pending transaction
		begin
			rollback;
		end;

		if @ReturnSelect = @ON
		begin

			set @TotalRecordCount += @TotalErrorCount;

			select @TotalRecordCount TotalRecordCount , @TotalErrorCount TotalErrorCount;

		end;

		exec @errorNo = sf.pErrorRethrow;

	end catch;

	return (@errorNo);
end;
GO
