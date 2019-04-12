SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSyncDataMap#Process]
	@JobRunSID				int = null				-- sf.JobRun record to update on asynchronous calls
 ,@EntityCount			int = null output -- optional output parameter to report count of entities processed
 ,@TotalRecordCount int = null output -- count of rows checked (cumulative - all entities processed)	
 ,@TotalErrorCount	int = null output -- count of errors encountered (cumulative - all entities processed)
 ,@ReturnSelect			bit = 0						-- when 1 output values are returned as a dataset
 ,@DebugLevel				int = 0						-- when 1 or higher debug output is written to console
as
/*********************************************************************************************************************************
Sproc    : Sync Data Map - Process (changes)
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure synchronizes Alinity and legacy databases according to instructions stored in dbo.SyncDataMap
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- + ----------- + --------------------------------------------------------------------------------------
				 : Tim Edlund				| Jan 2018		| Initial version.
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
The dbo.SyncDataMap table is used to specify synchronizations to be carried out.  The setup procedure loads all synchronizations
supported in the current release into the table but leaves them disabled.  A record must be enabled in the table for each
synchronization to be carried out.  

The synchronization process is executed by this procedure.  The procedure is typically set to run in background.  The interval
to run the procedure is set based on one of the job schedules available.  Setting to less than 15 minutes is not recommended
since the views that identify differences between the Alinity and Legacy databases can take a long time to run and the 
procedure must finish between run intervals to be effective.  If the procedure is not complete when the next run is called,
the new run is skipped until the next internal.

The synchronization direction is set on the record as either: PUSH (out from Alinity to the legacy database), or PULL (updates 
the Alinity database from changes in the legacy database).   Note that bi-directional updates are NOT supported.  Either the 
Alinity database or the Legacy database must be established as the authority for an entity area.  Updates on the entities 
being synchronized should not be allowed to occur in both locations.

While the table controls which synchronizations to implement, significant customization is required to finalize the 
synchronization configuration for a client.

Required Customization: ext.v<Entity>#Legacy View
-------------------------------------------------
The design of the synchronization system is based on comparing the Alinity entity view with a view on the Legacy database that 
returns the same columns.  The view must be placed in the extension schema "ext", and must use the entity name followed by #Legacy
to be found by this procedure.  If a view of that name is not found, or if the view fails to include the columns expected then
errors will result and the process will terminate.  The columns to return must match those expected by the Alinity view:  
ext.v<Entity>#Sync.  

The columns returned should also match the data types and general formatting of those in the Alinity entity view.  Format matching
is particularly important for coded columns (those ending with "Code" or "SCD").  For example, Alinity stores gender columns as
"M" and "F" for male and female. If the Legacy system stores them as "Male" and "Female", they must be translated in the view 
logic.

The database project (source code) and Alinity design database include "shell" views for each entity that is supported for 
synchronization. These views provide the column names and data types expected along with some additional documentation on format.

Required Customization (PUSH only): ext.trv<Entity>#Legacy Trigger
------------------------------------------------------------------
Where the synchronization requirements include updating the Legacy database with changes made in Alinity, then a trigger on the 
#Legacy view is also required.  This must be an instead-of trigger created on the insert and update and delete DML actions.  If 
delete is not to be supported, it can be turned off using the Is-Delete-Processed bit in the dbo.SyncDataMap record.

Subroutines: ext.pSyncDataMap#Process$<Entity>
----------------------------------------------
To process the updates required for each entity a subroutine is called.  While the main procedure is stored in the primary schema 
(DBO), each subroutine is deployed in EXT where the required #Legacy view has also been deployed.  Note that customization of this
main routine and the subroutines is NOT required.  The latest product version of these procedures should be deployed whenever the 
#Legacy view is created by the client project post deployment script.  Do not store the creation script for the sub-routines in 
the client project but rather deploy them via a reference to the main Alinity project (:r ..\..\path\<filename> )

Asynchronous Calling
--------------------
This procedure supports being called asynchronously through the built-in job system. Asynchronous processing is invoked by
passing a @JobSID parameter. Running jobs can be monitored with progress updates through the Job Monitor page on the UI.
Cancelling of running jobs is also supported from the UI.  This subroutine should not be invoked with any transaction pending.
If a non-zero @@trancount is detected at startup, an error is returned.

Known Limitations
-----------------
This version of the procedure does not support FULL synchronization where changes can be made in either the Legacy database or
Alinity.  The current design requires that one database or the other be identified as the sole location for changes.  Then 
either the PUSH (out to legacy) or PULL (into Alinity) directions must be configured on the dbo.SyncDataMap table.  Currently a 
"RowVersion" column is included in the view specifications for both the Legacy and Alinity records in the #Sync view however, it 
is not yet applied.  A future release may store this value to detect if changes were made in both databases in which case 
overwrites from concurrent changes could be avoided.

Example
-------
<TestHarness>
  <Test Name = "NonAsynch10" IsDefault ="true" Description="Executes the procedure with a synchronous call and limited to 
	10 records per entity.">
    <SQLScript>
      <![CDATA[
exec dbo.pSyncDataMap#Process @DebugLevel = 3, @ReturnSelect = 1;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="ExecutionTime" Value="00:04:00"/>
    </Assertions>
  </Test>
  <Test Name = "AsynchAll" Description="Executes the procedure with an asynchronous call and processes all available records.">
    <SQLScript>
      <![CDATA[
	exec sf.pJob#Call @JobSCD = 'dbo.pSyncDataMap#Process';

	waitfor delay '00:00:03';

	select
		jr.JobSCD
	 ,jr.CurrentProcessLabel
	 ,jr.JobStatusSCD
	 ,jr.EstimatedMinutesRemaining
	 ,jr.TotalRecords
	 ,jr.RecordsProcessed
	 ,jr.TotalErrors
	 ,jr.RecordsRemaining
	 ,jr.EstimatedMinutesRemaining
	 ,jr.RecordsPerMinute
	 ,jr.DurationMinutes
	 ,jr.ResultMessage
	 ,jr.TraceLog
	from
		sf.vJobRun jr
	where
		jr.JobRunSID =
	(
		select top (1)
			jr.JobRunSID
		from
			sf.vJobRun jr
		where
			jr.JobSCD = 'dbo.pSyncDataMap#Process'
		order by
			jr.JobRunSID desc
	);

	select
		jre.DataSource
	 ,jre.MessageText
	from
		sf.JobRunError jre
	where
		jre.JobRunSID =
	(
		select top (1)
			jr.JobRunSID
		from
			sf.vJobRun jr
		where
			jr.JobSCD = 'dbo.pSyncDataMap#Process'
		order by
			jr.JobRunSID desc
	)
	order by
		jre.JobRunErrorSID;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="3"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="4"/>
      <Assertion Type="ExecutionTime" Value="00:06:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSyncDataMap#Process'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int						= 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)											-- message text for business rule errors
	 ,@tranCount						int						= @@trancount					-- determines whether a wrapping transaction exists
	 ,@procName							nvarchar(128) = object_name(@@procid) -- name of currently executing procedure
	 ,@xState								int																	-- error state detected in catch block	
	 ,@ON										bit						= cast(1 as bit)			-- constant for bit comparisons = 1
	 ,@OFF									bit						= cast(0 as bit)			-- constant for bit comparison = 0
	 ,@CRLF									nchar(2)			= char(13) + char(10) -- carriage return line feed for formatting text blocks
	 ,@resultMessage				nvarchar(4000)											-- summary of job result
	 ,@traceLog							nvarchar(max)												-- text block for detailed results of job
	 ,@isCancelled					bit						= cast(0 as bit)			-- checks for cancellation request on async job calls  
	 ,@entitiesProcessed		int						= 0										-- running total of entities processed 
	 ,@recordsProcessed			int						= 0										-- records processed for a single entity 
	 ,@errorCount						int																	-- running count of errors encountered during processing
	 ,@currentProcessLabel	nvarchar(35)												-- label for stage of work
	 ,@syncDataMapSID				varchar(50)													-- key of next sync record map to process	
	 ,@syncView							nvarchar(257)												-- view that isolates differences between legacy and alinity DB's
	 ,@legacyView						nvarchar(257)												-- legacy DB target view for updates (requires instead-of trigger)
	 ,@applicationEntitySCD nvarchar(50)												-- schema and tablename of the base alinity entity being synchronized
	 ,@syncMode							varchar(4)													-- indicates direction of synchronization:  PULL (into Alinity DB) or PUSH (out to legacy DB)
	 ,@isDeleteProcessed		bit;																-- indicates if deletes are processed on target DB

	declare @work table
	(
		ID						 int not null identity(1, 1)
	 ,SyncDataMapSID int not null
	);

	set @EntityCount = 0; -- ensure output set for all code paths
	set @TotalRecordCount = 0;
	set @TotalErrorCount = 0;

	begin try

		if @DebugLevel is null set @DebugLevel = 0;

		if @tranCount > 0
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

			set @traceLog = sf.fPadR(N'S Y N C H R O N I Z A T I O N   S U M M A R Y', 50) + @CRLF + @CRLF -- format header for trace log
											+ sf.fPadR('Entity', 50) + N' Mode  Records  Errors' + @CRLF -- column headers for the log
											+ replicate('-', 50) + N' ----  -------  ------';
		end;

		-- load the work table with specified entities
		-- and where the configuration is enabled

		insert
			@work (SyncDataMapSID)
		select
			sdm.SyncDataMapSID
		from
			dbo.SyncDataMap			 sdm
		join
			sf.ApplicationEntity ae on sdm.ApplicationEntitySID						= ae.ApplicationEntitySID
		join
			sf.vTableLevel			 tl on tl.SchemaName + '.' + tl.TableName = ae.ApplicationEntitySCD
		where
			sdm.IsEnabled = @ON
		order by
			tl.TableLevel;	-- order so that FK dependency order of processing is followed

		set @EntityCount = @@rowcount;
		set @entitiesProcessed = 0;

		-- process each sync mapping

		while @entitiesProcessed < @EntityCount and @isCancelled = @OFF
		begin

			set @entitiesProcessed += 1;
			select
				@syncDataMapSID = w.SyncDataMapSID
			from
				@work w
			where
				w.ID = @entitiesProcessed;

			select
				@applicationEntitySCD = ae.ApplicationEntitySCD
			 ,@syncMode							= sdm.SyncMode
			 ,@isDeleteProcessed		= sdm.IsDeleteProcessed
			 ,@syncView							= N'ext.v' + sf.fObjectName(ae.ApplicationEntitySCD) + N'#Sync'		-- this view is not customized - but only deployed where required
			 ,@legacyView						= N'ext.v' + sf.fObjectName(ae.ApplicationEntitySCD) + N'#Legacy' -- this is the view onto the legacy system records - customized!
			from
				dbo.SyncDataMap			 sdm
			join
				sf.ApplicationEntity ae on sdm.ApplicationEntitySID = ae.ApplicationEntitySID
			where
				sdm.SyncDataMapSID = @syncDataMapSID;

			-- if an async call update the processing label

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

				set @currentProcessLabel = N'Processing: ' + @applicationEntitySCD + N' (Mode=' + @syncMode + N') ...';

				exec sf.pJobRun#Update
					@JobRunSID = @JobRunSID
				 ,@CurrentProcessLabel = @currentProcessLabel
				 ,@IsCancelled = @isCancelled;

			end;

			if @isCancelled = @OFF
			begin

				if not exists (select 1 from sf.vView v where v.SchemaAndViewName = @syncView) -- ensure required views exist in the schema
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'ObjectNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 "%2" was not found.'
					 ,@Arg1 = 'view'
					 ,@Arg2 = @syncView;

					raiserror(@errorText, 17, 1);
				end;

				if not exists (select 1 from sf.vView v where v.SchemaAndViewName = @legacyView)
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'ObjectNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 "%2" was not found.'
					 ,@Arg1 = 'view'
					 ,@Arg2 = @legacyView;

					raiserror(@errorText, 17, 1);
				end;

				-- reset counters for next entity

				set @recordsProcessed = 0;
				set @errorCount = 0;

				-- call the subroutine that matches the entity
				-- NOTE: keep in alphabetical order by tablename!

				if @applicationEntitySCD = 'dbo.Org'
				begin

					exec ext.pSyncDataMap#Process$Org
						@SyncMode = @syncMode
					 ,@IsDeleteProcessed = @isDeleteProcessed
					 ,@JobRunSID = @JobRunSID
					 ,@RecordsProcessed = @recordsProcessed out
					 ,@ErrorCount = @errorCount out
					 ,@DebugLevel = @DebugLevel;

				end;
				else if @applicationEntitySCD = 'sf.Person'
				begin

					exec ext.pSyncDataMap#Process$Person
						@SyncMode = @syncMode
					 ,@IsDeleteProcessed = @isDeleteProcessed
					 ,@JobRunSID = @JobRunSID
					 ,@RecordsProcessed = @recordsProcessed out
					 ,@ErrorCount = @errorCount out
					 ,@DebugLevel = @DebugLevel;

				end;
				else if @applicationEntitySCD = 'dbo.PersonMailingAddress'
				begin

					exec ext.pSyncDataMap#Process$PersonMailingAddress
						@SyncMode = @syncMode
					 ,@IsDeleteProcessed = @isDeleteProcessed
					 ,@JobRunSID = @JobRunSID
					 ,@RecordsProcessed = @recordsProcessed out
					 ,@ErrorCount = @errorCount out
					 ,@DebugLevel = @DebugLevel;

				end;
				else if @applicationEntitySCD = 'sf.PersonOtherName'
				begin

					exec ext.pSyncDataMap#Process$PersonOtherName
						@SyncMode = @syncMode
					 ,@IsDeleteProcessed = @isDeleteProcessed
					 ,@JobRunSID = @JobRunSID
					 ,@RecordsProcessed = @recordsProcessed out
					 ,@ErrorCount = @errorCount out
					 ,@DebugLevel = @DebugLevel;

				end;
				else if @applicationEntitySCD = 'dbo.RegistrantLanguage'
				begin

					exec ext.pSyncDataMap#Process$RegistrantLanguage
						@SyncMode = @syncMode
					 ,@IsDeleteProcessed = @isDeleteProcessed
					 ,@JobRunSID = @JobRunSID
					 ,@RecordsProcessed = @recordsProcessed out
					 ,@ErrorCount = @errorCount out
					 ,@DebugLevel = @DebugLevel;

				end;
				else if @applicationEntitySCD = 'dbo.RegistrantPracticeRestriction'
				begin

					exec ext.pSyncDataMap#Process$RegistrantPracticeRestriction
						@SyncMode = @syncMode
					 ,@IsDeleteProcessed = @isDeleteProcessed
					 ,@JobRunSID = @JobRunSID
					 ,@RecordsProcessed = @recordsProcessed out
					 ,@ErrorCount = @errorCount out
					 ,@DebugLevel = @DebugLevel;

				end;
				else if @applicationEntitySCD = 'dbo.RegistrantCredential'
				begin

					exec ext.pSyncDataMap#Process$RegistrantCredential
						@SyncMode = @syncMode
					 ,@IsDeleteProcessed = @isDeleteProcessed
					 ,@JobRunSID = @JobRunSID
					 ,@RecordsProcessed = @recordsProcessed out
					 ,@ErrorCount = @errorCount out
					 ,@DebugLevel = @DebugLevel;

				end;
				else if @applicationEntitySCD = 'dbo.Registration'
				begin

					exec ext.pSyncDataMap#Process$Registration
						@SyncMode = @syncMode
					 ,@IsDeleteProcessed = @isDeleteProcessed
					 ,@JobRunSID = @JobRunSID
					 ,@RecordsProcessed = @recordsProcessed out
					 ,@ErrorCount = @errorCount out
					 ,@DebugLevel = @DebugLevel;

				end;
				else if @applicationEntitySCD = 'dbo.PersonNote'
				begin

					exec ext.pSyncDataMap#Process$PersonNote
						@SyncMode = @syncMode
					 ,@IsDeleteProcessed = @isDeleteProcessed
					 ,@JobRunSID = @JobRunSID
					 ,@RecordsProcessed = @recordsProcessed out
					 ,@ErrorCount = @errorCount out
					 ,@DebugLevel = @DebugLevel;

				end;
				else
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'SyncNotSupported'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'Synchronization of the entity "%1" with legacy systems is not supported in this release of Alinity.'
					 ,@Arg1 = @applicationEntitySCD;

					raiserror(@errorText, 17, 1);

				end;

				set @TotalRecordCount += @recordsProcessed;
				set @TotalErrorCount += @errorCount;

				-- update the record count and the result message with 
				-- counts for the table just processed

				if @JobRunSID is not null
				begin

					set @traceLog += @CRLF + sf.fPadR(@applicationEntitySCD, 50) + N' ' + @syncMode + N'  ' + sf.fPadL(@recordsProcessed + @errorCount, 7) + N'  '
													 + sf.fPadL(@errorCount, 6);

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

					set @currentProcessLabel = N'Completed' + @applicationEntitySCD + N' (Mode=' + @syncMode + N') ...';

					exec sf.pJobRun#Update
						@JobRunSID = @JobRunSID
					 ,@RecordsProcessed = @TotalRecordCount
					 ,@TotalRecords = @TotalRecordCount
					 ,@CurrentProcessLabel = @currentProcessLabel
					 ,@IsCancelled = @isCancelled;

				end;

			end;

		end;

		-- update job with final totals for actually records processed
		-- and errors encountered

		if @JobRunSID is not null and @isCancelled = @OFF
		begin

			if @EntityCount = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NoEntitiesToSync'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'Warning: No entities were found to synchronize. Configuration updates are required.';

				set @traceLog = N'(No entities configured for synchronization)';
			end;
			else
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'JobCompletedSucessfully'
				 ,@MessageText = @resultMessage output
				 ,@DefaultText = N'The %1 job was completed successfully.'
				 ,@Arg1 = 'synchronization';

			end;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @TotalRecordCount
			 ,@RecordsProcessed = @TotalRecordCount
			 ,@TotalErrors = @TotalErrorCount
			 ,@TraceLog = @traceLog
			 ,@ResultMessage = @resultMessage;

		end;

		if @ReturnSelect = @ON
		begin

			select
				@EntityCount			EntityCount
			 ,@TotalRecordCount TotalRecordCount
			 ,@TotalErrorCount	TotalErrorCount;

		end;

	end try
	begin catch

		set @xState = xact_state();

		if @trancount = 0 and (@xState = -1 or @xState = 1) 
		begin
			rollback; -- rollback if any transaction is pending (committable or not)
		end;

		if @JobRunSID is not null
		begin

			set @errorText = N'*** JOB FAILED'
			set @errorText += char(13) + char(10) + error_message() + ' at procedure "' + error_procedure() + '" line# ' + ltrim(error_line())

			exec sf.pJobRun#Update
				 @JobRunSID			= @JobRunSID
				,@ResultMessage = @errorText
				,@IsFailed			= @ON

		end

		if @ReturnSelect = @ON
		begin

			set @TotalRecordCount += @TotalErrorCount;

			select
				@EntityCount			EntityCount
			 ,@TotalRecordCount TotalRecordCount
			 ,@TotalErrorCount	TotalErrorCount;

		end;

		exec @errorNo = sf.pErrorRethrow;

	end catch;

	return (@errorNo);
end;
GO
