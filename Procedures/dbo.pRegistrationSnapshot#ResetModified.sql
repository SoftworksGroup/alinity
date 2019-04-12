SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationSnapshot#ResetModified]
	@RegistrationSnapshotSID int				-- identifies the snapshot to be updated
 ,@JobRunSID							 int = null -- sf.JobRun record to update on asynchronous calls
as
/*********************************************************************************************************************************
Sproc    : Registration Snapshot - Reset Modified
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure updates the row-version-on-last-export with the current rowversion (timestamp) setting
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund          | Jul 2018		|	Initial version

Comments	
--------
This procedure is called from the user interface after an export file has been finalized.  The procedure must be called 
explicitly by the end user and not automatically invoked after an export since even where an export is created successfully,
the user may wish to make further changes before generating the export file.  Resetting the modified status will prevent
unchanged records from being included in the export if the "changed-records-only" export option is being used.

This procedure should be called in background to avoid time outs for larger data sets. No output or data set is returned.

Limitations
-----------
When the procedure is called asychronously (@JobRunSID passed), cancellation actions from the UI are not supported.  Only the 
start up of the job and end of job are updated.  The job is relatively short running - generally less than 5 minutes.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the procedure for a snapshot selected at random">
    <SQLScript>
      <![CDATA[

declare
	@registrationSnapshotSID		 int

select top (1)
	@registrationSnapshotSID = rs.RegistrationSnapshotSID
from
	dbo.vRegistrationSnapshot rs
where
	rs.LockedTime is null
and
	rs.ProfileCount > 0
order by
	newid()

if @registrationSnapshotSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistrationSnapshot#ResetModified
		@RegistrationSnapshotSID = @registrationSnapshotSID

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:10:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistrationSnapshot#ResetModified'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			 int					 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		 nvarchar(4000)													-- message text for business rule errors
	 ,@tranCount		 int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName			 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@resultMessage nvarchar(4000)													-- summary of job result
	 ,@totalRecords	 int																		-- total count of records to report to job processing
	 ,@progressLabel nvarchar(257);													-- tracks locaion in logic for debugging

	begin try

		set @progressLabel = N'startup';

		if @JobRunSID is not null -- if call is async, update the job run record 
		begin

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@CurrentProcessLabel = 'Resetting ...';

			select
				@totalRecords = count(1)
			from
				dbo.RegistrationProfile
			where
				RegistrationSnapshotSID = @RegistrationSnapshotSID; -- limit to the given snapshot

		end;

		-- validate parameters and startup values

		if @tranCount > 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'TransactionPending'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A transaction was started prior to calling this procedure. Procedure "%1" does not allow nested transactions.'
			 ,@Arg1 = @procName;

			raiserror(@errorText, 18, 1);

		end;

		if not exists
		(
			select
				1
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationSnapshotSID = @RegistrationSnapshotSID
		)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NoRecordsToUpdate'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'No records exist %1 for this %2. Record ID = "%3".'
			 ,@Arg1 = 'to update'
			 ,@Arg2 = 'snapshot'
			 ,@Arg3 = @RegistrationSnapshotSID;

			raiserror(@errorText, 18, 1);

		end;
		else if exists
		(
			select
				1
			from
				dbo.RegistrationSnapshot rs
			where
				rs.RegistrationSnapshotSID = @RegistrationSnapshotSID and rs.LockedTime is not null
		)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'LockedNoUpdate'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'This %1 is locked.  %2 not allowed.'
			 ,@Arg1 = 'snapshot'
			 ,@Arg2 = 'Update';

			raiserror(@errorText, 16, 1);

		end;

		-- update the check sum values on the associated profiles

		set @progressLabel = N'registration profile';

		update
			rp
		set
			rp.CheckSumOnLastExport = rpx.CurrentCheckSum
		from
			dbo.RegistrationProfile																						rp
		cross apply dbo.fRegistrationProfile#Ext(rp.RegistrationProfileSID) rpx
		where
			rp.RegistrationSnapshotSID = @RegistrationSnapshotSID -- restrict to selected snapshot
			and
			(
				rp.CheckSumOnLastExport	 <> rpx.CurrentCheckSum or rp.CheckSumOnLastExport is null
			);	-- row version has changed or is null (new snapshot)

		if @JobRunSID is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'JobCompletedSucessfully'
			 ,@MessageText = @resultMessage output
			 ,@DefaultText = N'The %1 job was completed successfully.'
			 ,@Arg1 = 'Snapshot Reset Modified';

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @totalRecords
			 ,@RecordsProcessed = @totalRecords
			 ,@TotalErrors = 0
			 ,@ResultMessage = @resultMessage;

		end;

	end try
	begin catch

		if @JobRunSID is not null
		begin

			set @errorText = N'*** JOB FAILED' + isnull(N' AT : ' + @progressLabel + char(13) + char(10), N'');
			set @errorText += char(13) + char(10) + error_message() + N' at procedure "' + error_procedure() + N'" line# ' + ltrim(error_line());

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@ResultMessage = @errorText
			 ,@IsFailed = 1;

		end;

		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
