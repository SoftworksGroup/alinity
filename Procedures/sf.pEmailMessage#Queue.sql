SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pEmailMessage#Queue
	@EmailMessageSID int											-- email message key to queue
 ,@QueuedTime			 datetimeoffset(7) = null -- time message should be queued for sending 
 ,@JobRunSID			 int = null								-- job run id used for logging
 ,@DebugLevel			 tinyint = 0							-- when > 0 sends timing marks and progress labels to console
as
/*********************************************************************************************************************************
Procedure : Email Message - Queue
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Checks recipient eligibility and prepared email including replacement of merge fields with personalized content
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ---------- + ------------ + --------------------------------------------------------------------------------------------
				: Tim Edlund	| Apr	2015		| Initial Version
				: Tim Edlund	| May 2018		| Converted queued time to DB time zone.  Rollback made conditional on error.
				: Tim Edlund	| Oct 2018		| Updated to call #SetRecipients if person-email-message not populated by caller

Comments	
--------
This procedure is called when the user executes the "send" option on an email message.  The email content must already be saved
at the time of the call but the recipient list - stored in (sf) Person Email Message - will be populated automatically by 
this routine if it is empty at the time of the call.

This procedure checks the eligibility of each recipient and deletes the Person Email Message if they are not eligible. The
same eligibility subroutine is called that is provided to show eligibility to the user on the UI.  

The procedure is also responsible for recording the email address that the message will be sent to for each recipient. Freezing 
this value at the moment the message is queued preserves audit information since email addresses may be updated afterward. (That
action is carried out in the #Merge routine.) Note that the email address is NOT validated in the check constraint since it
is derived from an already validated source (sf.PersonEmailAddress) and the check is time consuming.

The procedure also calls the #Merge routine to store the Subject and Body content from the Email Message parent record, into 
the individual Subject and Body columns of child Person Email Message records. This operation supports replacement of merge fields
(e.g. [@Lastname]) with values retrieved from data sources for that recipient.  Note that whether or not the email content 
(subject and body values) in the parent email message contain merge fields, a recipient-specific copy of the email message is 
still saved. This approach supports: a) editing of individual message post-merge if offered by the application and b) inclusion of 
"un-subscribe" links that are customized for the recipient email address/profile.

The job sf.EmailMessage#Queue must be setup before this will run as a job.  There is a check in the EmailMessage#Update and
EmailMessage#Insert sprocs for this job.

Debug monitor (timing marks)
----------------------------
In order to get timing marks printed to the console (to debug performance problems), the @DebugLevel parameter must be set to a 
value greater than 0. Where the value is 1, only timing marks from the parent procedure are included.  A value of 2 causes
timing marks from the first subroutine level to be printed as well and so on to deeper levels of subroutine calls. Do not call
the procedure asynchronously when using the debug level parameter. If @JobRunSID is passed in then the debug level is
automatically set to 0.

Example
-------
<TestHarness>
	<Test Name="TestQueue" Description="Inserts an email message and then checks that it gets properly queued.">
		<SQLScript>
			<![CDATA[
declare @emailMessageSID int;

select top (1)
	@emailMessageSID = em.EmailMessageSID
from
	sf.vEmailMessage em
where
	em.RecipientCount > 1 -- find existing email message to copy with multiple recipients
order by
	newid();

if @@rowcount = 0 or @emailMessageSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	print 'Old EmailMessageSID: ' + ltrim(@emailMessageSID);

	insert
		sf.EmailMessage -- copy the email
	(
		SenderEmailAddress
	 ,SenderDisplayName
	 ,PriorityLevel
	 ,Subject
	 ,Body
	 ,RecipientList
	 ,IsApplicationUserRequired
	 ,ApplicationUserSID
	 ,MessageLinkSID
	 ,LinkExpiryHours
	 ,ApplicationEntitySID
	)
	select
		SenderEmailAddress
	 ,SenderDisplayName
	 ,PriorityLevel
	 ,Subject + ' TEST'
	 ,Body
	 ,RecipientList
	 ,IsApplicationUserRequired
	 ,ApplicationUserSID
	 ,MessageLinkSID
	 ,LinkExpiryHours
	 ,ApplicationEntitySID
	from
		sf.EmailMessage em
	where
		em.EmailMessageSID = @emailMessageSID;

	set @emailMessageSID = ident_current('sf.EmailMessage');

	print 'New EmailMessageSID: ' + ltrim(@emailMessageSID);

	exec sf.pEmailMessage#Queue
		@EmailMessageSID = @emailMessageSID
	 ,@DebugLevel = 3;

	select
		pem.PersonSID
	 ,pem.Subject
	 ,em.MergedTime
	 ,em.QueuedTime
	from
		sf.PersonEmailMessage pem
	join
		sf.EmailMessage				em on pem.EmailMessageSID = em.EmailMessageSID
	where
		pem.EmailMessageSID = @emailMessageSID;

	if @@trancount > 0 and xact_state() = 1
	begin
		rollback; -- don't retain the test result
	end;

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="NotEmptyResultSet" ResultSet="2" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="test@softworksgroup.com" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="2" Value="*** TEST ***" />
			<Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="6" Value="*** TEST SUBJECT ***" />
			<Assertion Type="ExecutionTime" Value="00:00:04"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'sf.pEmailMessage#Queue'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					int							 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				nvarchar(4000)														-- message text (for business rule errors)
	 ,@tranCount				int							 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName					nvarchar(128)		 = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState						int																				-- error state detected in catch block
	 ,@ON								bit							 = cast(1 as bit)					-- used on bit comparisons to avoid multiple casts
	 ,@OFF							bit							 = cast(0 as bit)					-- used on bit comparisons to avoid multiple casts   
	 ,@CRLF							nchar(2)				 = char(13) + char(10)		-- carriage return line feed for formatting text blocks
	 ,@serverTime				datetimeoffset(7)													-- current time at database server
	 ,@updateUser				nvarchar(75)															-- user who is sending the email
	 ,@totalRecords			int							 = 0											-- total records expected to process
	 ,@totalErrors			int							 = 0											-- total errors encountered
	 ,@recordsProcessed int							 = 0											-- total records processed
	 ,@isCancelled			bit							 = 0											-- checks for cancellation request on async job calls  
	 ,@timeCheck				datetimeoffset(7)													-- used to debug time elapsed between subroutines
	 ,@debugString			nvarchar(70)															-- string to track progress through procedure
	 ,@resultMessage		nvarchar(4000);														-- summary of job result

	begin try

		if @tranCount > 0 and @DebugLevel < 3 -- debug level = 3 is reserved for the test case to step around this error
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'TransactionPending'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A transaction was started prior to calling this procedure. Procedure "%1" does not allow nested transactions.'
			 ,@Arg1 = @procName;

			raiserror(@errorText, 18, 1);

		end;

-- SQL Prompt formatting off
		if isnull(@JobRunSID, 0) > 0 set @DebugLevel = 0;
		if @DebugLevel > 0 set @debugString = N'Checking parameters (' + object_name(@@procid) + ')';
		if @DebugLevel > 0 exec sf.pDebugPrint @DebugString = @debugString, @TimeCheck = @timeCheck output;
-- SQL Prompt formatting on

		if @JobRunSID is not null -- if call is async, update the job run record
		begin

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@CurrentProcessLabel = N'In Process';

		end;

		-- check parameters

		if @EmailMessageSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@EmailMessageSID';

			raiserror(@errorText, 18, 1);

		end;

		if not exists
		(
			select 1 from		sf.EmailMessage em where em.EmailMessageSID = @EmailMessageSID
		)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'Email Message'
			 ,@Arg2 = @EmailMessageSID;

			raiserror(@errorText, 18, 1);

		end;

		-- if recipients for the message have not yet been loaded
		-- to person-email-message, load them now by parsing them
		-- from the RecipientList column on parent

		if not exists
		(
			select
				1
			from
				sf.PersonEmailMessage pem
			where
				pem.EmailMessageSID = @EmailMessageSID
		)
		begin

			if @DebugLevel > 0
			begin

				exec sf.pDebugPrint
					@DebugString = N'Calling #SetRecipients'
				 ,@TimeCheck = @timeCheck output;

			end;

			if @JobRunSID is not null
			begin

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@CurrentProcessLabel = N'Loading recipients ...'; -- note that there is no cancellation possible at this step

			end;

			exec sf.pEmailMessage#SetRecipients
				@EmailMessageSID = @EmailMessageSID;

		end;

		-- call a subroutine to store the Subject and Body
		-- content for each recipient and to set the email address

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = N'Calling #Merge'
			 ,@TimeCheck = @timeCheck output;

		end;

		exec sf.pEmailMessage#Merge
			@EmailMessageSID = @EmailMessageSID
		 ,@JobRunSID = @JobRunSID
		 ,@DebugLevel = @DebugLevel
		 ,@TotalRowCount = @totalRecords output
		 ,@TotalErrorCount = @totalErrors output
		 ,@TotalProcessedCount = @recordsProcessed output;

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = N'Updating queued time'
			 ,@TimeCheck = @timeCheck output;

		end;

		-- if queued time is passed convert
		-- to the DB server time zone offset

		set @serverTime = sysdatetimeoffset();

		if @QueuedTime is not null
		begin
			set @QueuedTime = sf.fClientDateToDTOffset(cast(@QueuedTime as date)); -- convert users' queued time as date, then to database time zone
		end;
		else
		begin
			set @QueuedTime = @serverTime; -- otherwise use the server time
		end;

		-- finally update the queued time on the parent row and 
		-- update audit information 

		if isnull(@updateUser, 'x') = N'SystemUser'
		begin
			set @updateUser = left(sf.fConfigParam#Value('SystemUser'), 75); -- override for "SystemUser"
		end;

		if isnull(@updateUser, 'x') <> N'SystemUser'
		begin
			set @updateUser = sf.fApplicationUserSession#UserName(); -- application user or DB user if no application session set
		end;

		if @JobRunSID is not null -- running asynchronously
		begin

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

			if @isCancelled = @OFF
			begin

				update
					sf.EmailMessage -- avoid EF sproc call (which would be recursive)						
				set
					QueuedTime = @QueuedTime
				 ,UpdateTime = @serverTime
				 ,UpdateUser = @updateUser
				where
					EmailMessageSID = @EmailMessageSID;

				exec sf.pMessage#Get
					@MessageSCD = 'JobCompletedSucessfully'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'The %1 job was completed successfully.'
				 ,@Arg1 = 'queue email message';

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@TotalRecords = @totalRecords
				 ,@TotalErrors = @totalErrors
				 ,@RecordsProcessed = @recordsProcessed
				 ,@ResultMessage = @resultMessage;

			end;
			else
			begin

				update -- job cancelled, set merged time back to null
					sf.EmailMessage
				set
					MergedTime = null
				 ,UpdateTime = @serverTime
				 ,UpdateUser = @updateUser
				where
					EmailMessageSID = @EmailMessageSID;

			end;

		end;
		else
		begin

			update
				sf.EmailMessage -- avoid EF sproc call (which would be recursive)						
			set
				QueuedTime = @QueuedTime
			 ,UpdateTime = @serverTime
			 ,UpdateUser = @updateUser
			where
				EmailMessageSID = @EmailMessageSID;

		end;

		if @DebugLevel > 0
		begin
			set @debugString = object_name(@@procid) + N' Complete!';
		end;

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;
		end;

	end try
	begin catch

		set @xState = xact_state();

		if @tranCount = 0 and (@xState = -1 or @xState = 1)
		begin
			rollback; -- rollback if any transaction is pending (committable or not)
		end;

		if @JobRunSID is not null
		begin

			update -- job failed, set merged time back to null
				sf.EmailMessage
			set
				MergedTime = null
			 ,UpdateTime = sysdatetimeoffset()
			 ,UpdateUser = @updateUser
			where
				EmailMessageSID = @EmailMessageSID;

			set @errorText = N'*** JOB FAILED' + @CRLF + error_message();

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@ResultMessage = @errorText
			 ,@IsFailed = @ON;

		end;

		exec @errorNo = sf.pErrorRethrow;

	end catch;

	return (@errorNo);

end;
GO
