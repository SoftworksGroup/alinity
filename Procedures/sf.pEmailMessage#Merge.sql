SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pEmailMessage#Merge
	@EmailMessageSID		 int								-- email message key to merge
 ,@JobRunSID					 int = null					-- Job run id used for logging (optional)
 ,@TotalRowCount			 int = null output	-- count of rows (optional)
 ,@TotalErrorCount		 int = null output	-- count of errors (optional)
 ,@TotalProcessedCount int = null output	-- count of rows processed (optional)
 ,@DebugLevel					 tinyint = 0				-- when > 0 sends generated SQL to console without executing
as
/*********************************************************************************************************************************
Procedure : Email Message - Merge
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Saves email message content for each recipient with merge field replacements (if any)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ----------- + ----------- + --------------------------------------------------------------------------------------------
				: Tim Edlund	| Apr	2015		| Initial Version
				: Cory Ng			| Mar	2017		| Merged person email message before secondary source to ensure [@RowGUID] tags are replaced.
				: Tim Edlund	| Oct	2017		| Introduced mapping table (@tokenMap) so that template is only parsed once.
				: Tim Edlund	| May 2018		| Added support for partial rollback where transaction initiated prior to call.

Comments	
--------
This procedure is part of the email queuing process invoked when the user "sends" the message.  The project stores the Subject and 
Body content from the Email Message parent record, into the individual Subject and Body columns of child Person Email Message 
records. This operation supports replacement of merge fields (e.g. [@Lastname]) with values retrieved from data sources for that 
recipient.  

Whether or not the email content, subject and body, in the parent email message contain merge fields a recipient-specific copy of 
the email message is still saved. This approach supports: a) editing of individual message post-merge if offered by the 
application and b) inclusion of "un-subscribe" links that are customized for the recipient email address/profile.

Example
-------
<TestHarness>
	<Test Name="TestQueue" Description="Inserts an email message and then checks that it gets properly queued.">
		<SQLScript>
			<![CDATA[
declare
	@emailMessageSID int
 ,@recipientList	 xml
 ,@personSID			 int;

select top (1)
	@personSID = p.PersonSID
from
	sf.vPerson					p
join
	sf.vApplicationUser au on p.PersonSID = au.PersonSID
where
	au.UserName like '%@softworks.ca' and au.IsActive = 1 and p.PrimaryEmailAddressSID is not null
order by
	newid();

set @recipientList =
(
	select
		Entity.PersonSID
	from
		sf.Person Entity
	where
		Entity.PersonSID = @personSID
	for xml auto, root('Recipients')
);

if @personSID is null or @recipientList is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	insert into
		sf.EmailMessage
	(
		SenderEmailAddress
	 ,SenderDisplayName
	 ,PriorityLevel
	 ,Subject
	 ,Body
	 ,RecipientList
	 ,IsApplicationUserRequired
	)
	select
		'test@softworksgroup.com'
	 ,'*** TEST ***'
	 ,1
	 ,'*** TEST SUBJECT ***'
	 ,cast(N'Here is some test text to include in the email.  And this is today''s date from a merge field: [@@Date]' as varbinary(max))
	 ,@recipientList
	 ,cast(1 as bit);

	set @emailMessageSID = scope_identity();

	exec sf.pEmailMessage#SetRecipients
		@EmailMessageSID = @emailMessageSID;

	exec sf.pEmailMessage#Queue -- this procedure calls pEmailMessage#Merge
		@EmailMessageSID = @emailMessageSID;

	select
		em.EmailMessageSID
	 ,pea.EmailAddress
	 ,em.SenderEmailAddress
	 ,em.SenderDisplayName
	 ,em.PriorityLevel
	 ,em.Subject
	 ,cast(em.Body as nvarchar(max)) Body
	 ,em.RecipientList
	from
		sf.EmailMessage														em
	cross apply RecipientList.nodes('//Entity') r(n)
	join
		sf.Person							p on p.PersonSID	 = r.n.value('@PersonSID', 'int')
	join
		sf.PersonEmailAddress pea on p.PersonSID = pea.PersonSID
	where
		em.EmailMessageSID = @emailMessageSID;

	select
		PersonSID
	 ,EmailMessageSID
	 ,EmailAddress
	 ,SelectedTime
	 ,SentTime
	 ,Subject
	 ,Body
	from
		sf.PersonEmailMessage pem
	where
		pem.EmailMessageSID = @emailMessageSID;

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
  @ObjectName = 'sf.pEmailMessage#Merge'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo									 int							 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText								 nvarchar(4000)															-- message text (for business rule errors)
	 ,@tranCount								 int							 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName									 nvarchar(128)		 = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState										 int																				-- error state detected in catch block
	 ,@ON												 bit							 = cast(1 as bit)					-- used on bit comparisons to avoid multiple casts
	 ,@OFF											 bit							 = cast(0 as bit)					-- used on bit comparisons to avoid multiple casts 
	 ,@serverTime								 datetimeoffset(7) = sysdatetimeoffset()		-- current time at database server
	 ,@maxRow										 int																				-- loop limit - rows to process
	 ,@i												 int																				-- loop index
	 ,@j												 int																				-- string parser index position
	 ,@isQueued									 bit																				-- tracks whether email has already been queued
	 ,@updateUser								 nvarchar(75)																-- user who is sending the email
	 ,@personEmailMessageSID		 int																				-- record key to lookup for field replacements 
	 ,@personEmailMessageRowGUID uniqueidentifier														-- reference key to email used in page links
	 ,@emailAddress							 varchar(150)																-- current email address for next recipient
	 ,@applicationEntitySCD			 varchar(50)																-- schema.tablename for primary data source (if any)
	 ,@mergeKey									 int																				-- record key to lookup in primary data source (if any)
	 ,@subjectTemplate					 nvarchar(65)																-- email subject template (as text)
	 ,@bodyTemplate							 nvarchar(max)															-- email body template (as text)
	 ,@subjectText							 nvarchar(65)																-- merged subject text to store in next message (as text)
	 ,@bodyText									 nvarchar(max)															-- merged body text to store in next message (as text)
	 ,@tokenMap									 sf.TokenMap																-- table of names and positions of merge replacements in template
	 ,@replacementSQL1					 nvarchar(max)															-- dynamic SQL statement used to retrieve replacement values
	 ,@replacementSQL2					 nvarchar(max)															-- dynamic SQL statement used to retrieve replacement values
	 ,@isCancelled							 bit							 = 0											-- checks for cancellation request on async job calls 
	 ,@timeCheck								 datetimeoffset(7)													-- used to debug time elapsed between subroutines
	 ,@debugString							 nvarchar(70)																-- string to track progress through procedure
	 ,@currentProcessLabel			 nvarchar(35);															-- label for stage of work

	declare @recipient table -- recipients for the email message with eligibility info
	(
		ID												int							 not null identity(1, 1)
	 ,PersonEmailMessageSID			int							 not null
	 ,PersonEmailMessageRowGUID uniqueidentifier not null
	 ,EmailAddress							varchar(150)		 not null
	 ,ApplicationEntitySCD			varchar(50)			 null
	 ,MergeKey									int							 null
	);

	set @TotalRowCount = @TotalRowCount;
	set @TotalErrorCount = @TotalErrorCount;
	set @TotalProcessedCount = @TotalProcessedCount;

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

		if @DebugLevel > 1
		begin

			set @debugString = N'Checking parameters (' + object_name(@@procid) + N')';

			exec sf.pDebugPrint
				@DebugString = @debugString
			 ,@TimeCheck = @timeCheck output;

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

		-- in order to prevent editing and changes
		-- while process proceeds, set merged time

		set @updateUser = sf.fApplicationUserSession#UserName();

		update
			sf.EmailMessage -- note: avoid EF #Update for performance!
		set
			MergedTime = @serverTime
		 ,UpdateTime = @serverTime
		 ,UpdateUser = @updateUser
		where
			EmailMessageSID = @EmailMessageSID;

		if @@rowcount = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'Email Message'
			 ,@Arg2 = @EmailMessageSID;

			raiserror(@errorText, 18, 1);

		end;

		-- get content for the merge

		if @DebugLevel > 1
		begin

			exec sf.pDebugPrint
				@DebugString = 'Getting merge content'
			 ,@TimeCheck = @timeCheck output;

		end;

		select
			@subjectTemplate = em.Subject
		 ,@bodyTemplate		 = cast(em.Body as nvarchar(max))
		 ,@isQueued				 = cast(case when em.QueuedTime is not null then 1 else 0 end as bit)
		from
			sf.EmailMessage em
		where
			em.EmailMessageSID = @EmailMessageSID;

		if @isQueued = @ON
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'AlreadyQueuedNoMerge'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Content for this email message cannot be updated because it has already been queued for sending.';

			raiserror(@errorText, 18, 1);

		end;

		set @bodyText = @subjectTemplate + N'!|!' + @bodyTemplate; -- combine subject and body for merge replacements

		-- parse the template merge fields into a table to
		-- pass to the merge procedure

		insert
			@tokenMap (StartPosition, EndPosition, MergeToken)
		exec sf.pTextTemplate#GetMap
			@TextTemplate = @bodyText;

		-- load work table with recipients to process

		if @DebugLevel > 1
		begin

			exec sf.pDebugPrint
				@DebugString = 'Loading recipients'
			 ,@TimeCheck = @timeCheck output;

		end

		insert
			@recipient
		(
			PersonEmailMessageSID
		 ,PersonEmailMessageRowGUID
		 ,EmailAddress
		 ,ApplicationEntitySCD
		 ,MergeKey
		)
		select
			pem.PersonEmailMessageSID
		 ,pem.RowGUID
		 ,pea.EmailAddress
		 ,ae.ApplicationEntitySCD
		 ,pem.MergeKey
		from
			sf.PersonEmailMessage pem
		join
			sf.EmailMessage				em on pem.EmailMessageSID			= em.EmailMessageSID
		join
			sf.PersonEmailAddress pea on pem.PersonSID					= pea.PersonSID and pea.IsPrimary = @ON and pea.IsActive = @ON
		left outer join
			sf.ApplicationEntity	ae on em.ApplicationEntitySID = ae.ApplicationEntitySID
		where
			pem.EmailMessageSID = @EmailMessageSID and pem.SentTime is null -- checked to allow re-start of failed process
		order by
			pem.PersonEmailMessageSID;

		set @maxRow = @@rowcount;
		set @i = 0;

		if @DebugLevel > 1
			exec sf.pDebugPrint
				@DebugString = 'Starting recipient processing'
			 ,@TimeCheck = @timeCheck output;

		while @i < @maxRow and @isCancelled = @OFF
		begin

			set @i += 1;

			if @DebugLevel > 1 and (@i = 1 or @i % 100 = 0)
			begin
				set @debugString = N'Selecting record# ' + ltrim(@i);
				exec sf.pDebugPrint
					@DebugString = @debugString
				 ,@TimeCheck = @timeCheck output;
			end;

			set @currentProcessLabel = N'retrieving next record';

			select
				@personEmailMessageSID		 = r.PersonEmailMessageSID
			 ,@personEmailMessageRowGUID = r.PersonEmailMessageRowGUID
			 ,@emailAddress							 = r.EmailAddress
			 ,@applicationEntitySCD			 = r.ApplicationEntitySCD
			 ,@mergeKey									 = r.MergeKey
			from
				@recipient r
			where
				r.ID = @i;

			set @bodyText = @subjectTemplate + N'!|!' + @bodyTemplate; -- reinitialize the template for the current record

			if exists (select 1 from @tokenMap tm ) -- avoid merge call if no merge fields
			begin

				if @DebugLevel > 1 and (@i = 1 or @i % 100 = 0)
				begin

					set @debugString = N'Merging primary record# ' + ltrim(@i);

					exec sf.pDebugPrint
						@DebugString = @debugString
					 ,@TimeCheck = @timeCheck output;

				end;

				set @currentProcessLabel = N'merging primary source';

				exec sf.pTextTemplate#MergeWithMap
					@TextTemplate = @bodyText output
				 ,@TokenMap = @tokenMap
				 ,@ApplicationEntitySCD = 'sf.PersonEmailMessage'
				 ,@RecordSID = @personEmailMessageSID
				 ,@PersonEmailMessageRowGUID = @personEmailMessageRowGUID -- link references may exist so pass GUID on this call
				 ,@ReplacementSQL = @replacementSQL1 output;							-- once called once, pass back the dynamic SQL string for replacement retrieval

			end;

			if @applicationEntitySCD is not null and @mergeKey is not null -- replace merge fields for secondary source if identified
			begin

				if exists (select 1 from @tokenMap tm )
				begin

					if @DebugLevel > 1 and (@i = 1 or @i % 100 = 0)
					begin
						set @debugString = N'Merging secondary record# ' + ltrim(@i);

						exec sf.pDebugPrint
							@DebugString = @debugString
						 ,@TimeCheck = @timeCheck output;

					end;

					set @currentProcessLabel = N'merging secondary source';

					exec sf.pTextTemplate#MergeWithMap
						@TextTemplate = @bodyText output
					 ,@TokenMap = @tokenMap
					 ,@ApplicationEntitySCD = @applicationEntitySCD
					 ,@RecordSID = @mergeKey
					 ,@ReplacementSQL = @replacementSQL2 output;	-- once called once, pass back the dynamic SQL string for replacement retrieval

				end;

			end;

			if @DebugLevel > 1 and (@i = 1 or @i % 100 = 0)
			begin
				set @debugString = N'Updating record# ' + ltrim(@i);

				exec sf.pDebugPrint
					@DebugString = @debugString
				 ,@TimeCheck = @timeCheck output;

			end;

			set @j = charindex(N'!|!', @bodyText); -- extract subject and body to their own variables 

			if @j > 0
			begin
				set @subjectText = left(@bodyText, @j - 1);
				set @bodyText = substring(@bodyText, @j + 3, len(@bodyText));
			end;

			-- store the populated subject and body into the message body
			-- continue on any errors arising from check constraints

			begin try

				begin transaction;

				set @currentProcessLabel = N'updating person email message';

				update
					sf.PersonEmailMessage -- note: avoid EF #Update for performance!
				set
					Subject = @subjectText
				 ,Body = cast(@bodyText as varbinary(max))
				 ,EmailAddress = @emailAddress
				 ,UpdateTime = sysdatetimeoffset()
				 ,UpdateUser = @updateUser
				 ,ChangeAudit = sf.fChangeAudit#Comment(N'Queued for sending', ChangeAudit)
				where
					PersonEmailMessageSID = @personEmailMessageSID;

				commit;

			end try
			begin catch

				-- if an error occurs on the update roll it back and report the
				-- error on the email message record and then proceed to next record

				set @xState = xact_state();

				if (@xState = -1 or @xState = 1)
				begin
					rollback; -- rollback record with error
				end;

				update
					sf.PersonEmailMessage
				set
					ChangeAudit = sf.fChangeAudit#Comment(N'ERROR: ' + error_message(), ChangeAudit)
				 ,CancelledTime = sysdatetimeoffset()
				where
					PersonEmailMessageSID = @personEmailMessageSID;

				set @TotalErrorCount += 1;

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@RecordsProcessed = @i
				 ,@TotalErrors = @TotalErrorCount
				 ,@TotalRecords = @maxRow
				 ,@CurrentProcessLabel = @currentProcessLabel
				 ,@IsCancelled = @isCancelled;

			end catch;

			if @JobRunSID is not null
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

				if @isCancelled = @ON or @i % 5 = 0
				begin

					set @currentProcessLabel = cast(left(@emailAddress, 35) as nvarchar(35)); -- PersonEmailMessage record being processed

					exec sf.pJobRun#Update
						@JobRunSID = @JobRunSID
					 ,@RecordsProcessed = @i
					 ,@TotalRecords = @maxRow
					 ,@CurrentProcessLabel = @currentProcessLabel
					 ,@IsCancelled = @isCancelled;

				end;

			end;

			if @DebugLevel > 1 and (@i = 1 or @i % 100 = 0)
			begin
				set @debugString = N'Completed record# ' + ltrim(@i);

				exec sf.pDebugPrint
					@DebugString = @debugString
				 ,@TimeCheck = @timeCheck output;

			end;

		end;

		set @TotalProcessedCount = @i;
		set @TotalRowCount = @maxRow;

	end try
	begin catch

		set @xState = xact_state();

		if @tranCount > 0 and @xState = 1
		begin
			rollback;
		end;

		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
