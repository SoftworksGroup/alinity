SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pTimeZoneOffset#Adjust
	@JobRunSID		 int = null -- sf.JobRun record to update on asynchronous calls
 ,@ReturnDataSet bit = 0		-- when 1 a single record data set is returned summarizing results of process
as
/*********************************************************************************************************************************
Sproc    : Time Zone Offset - Adjust
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure adjusts the client-time-zone parameter for entry/exit from the Daylight Savings period (Mar and Nov)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This procedure is designed to be called called nightly at 2:00am to check if an adjustment to the client's time zone offset
is required.  The time zone offset must be adjusted for configurations applying Daylight Savings Time each March and November.
The procedure calls a framework function to determine if the current time (in the user time zone) is now in the DST period
and checks if the adjustment has already been made.  

Two configuration parameters (sf.ConfigParam) are retrieved to make the determination if an adjustment is required:

		DSTStatus - records ACTIVE, INACTIVE or N/A to indicate if the DST adjustment has been made or is not used (N/A) 
		ClientTimeZoneOffset - e.g. "-07:00" the adjustment from UTC to establish current time for the client system

If the DST status indicates no adjustment is applied (INACTIVE) but the current time is in the DST period then the
offset is adjusted +1 (spring ahead).  Similarly in November the -1 adjustment is applied (fall back).  The DST Status
setting is updated to reflect the adjustment made.

If the configuration does not use DST then the "N/A" value (or any value other than ACTIVE/INACTIVE) directs the procedure
to avoid any adjustment.  

A result message can be returned to report on the action taken if any.

Limitations
-----------
This procedure must be run as close to 2:00am as possible and ideally only once per day.  While it is overkill to run 
this procedure each night, doing so ensure it will run as soon as possible to apply the adjustment and execution time is
only about 1 second so does not add substantially to the evening batch processes.

Example
-------
<TestHarness>
  <Test Name = "Sync" IsDefault ="true" Description="Executes the procedure to adjust time (change is rolled back).">
    <SQLScript>
      <![CDATA[

declare @isDSTActive bit = sf.fDST#IsActive();

begin transaction;

select
	isnull(cp.ParamValue, cp.DefaultParamValue) ClientTimeZoneOffset
from
	sf.ConfigParam cp
where
	cp.ConfigParamSCD = 'ClientTimeZoneOffset'

update
	sf.ConfigParam
set
	ParamValue = (case when @isDSTActive = 1 then 'INACTIVE' else 'ACTIVE' end)
where
	ConfigParamSCD = 'DSTStatus'; -- set to wrong setting to force adjustment

exec sf.pTimeZoneOffset#Adjust
	@ReturnDataSet = 1;

rollback;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:05:00"/>
    </Assertions>
  </Test>
  <Test Name = "ASync" Description="Executes the procedure with an asynchronous call">    
		<SQLScript>
      <![CDATA[
	exec sf.pJob#Call @JobSCD = 'sf.pTimeZoneOffset#Adjust';

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
			jr.JobSCD = 'sf.pTimeZoneOffset#Adjust'
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
			jr.JobSCD = 'sf.pTimeZoneOffset#Adjust'
		order by
			jr.JobRunSID desc
	)
	order by
		jre.JobRunErrorSID;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:10:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pTimeZoneOffset#Adjust'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			 int					 = 0									-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		 nvarchar(4000)											-- message text for business rule errors
	 ,@ON						 bit					 = cast(1 as bit)			-- constant for bit comparisons = 1
	 ,@OFF					 bit					 = cast(0 as bit)			-- constant for bit comparison = 0
	 ,@dstStatus		 varchar(10)												-- currently setting of Daylight Savings Time status
	 ,@ctzOffset		 varchar(10)												-- client time zone offset - e.g. "-08:00"
	 ,@isDSTActive	 bit					 = sf.fDST#IsActive() -- tracks whether currently in the DST period
	 ,@resultMessage nvarchar(250);											-- job result message (optionally returned as DS)

	begin try

		if @JobRunSID is not null -- if call is async, update the job run record
		begin

			set @ReturnDataSet = 0;

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@CurrentProcessLabel = N'Executing ...';

		end;

-- SQL Prompt formatting off
		if @ReturnDataSet is null set @ReturnDataSet = @OFF
-- SQL Prompt formatting on

		-- check the configuration to determine  if DST
		-- is currently on - raise error if value is missing

		set @dstStatus = cast(sf.fConfigParam#Value('DSTStatus') as varchar(10));
		set @ctzOffset = cast(sf.fConfigParam#Value('ClientTimeZoneOffset') as varchar(10));

		if @dstStatus is null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotConfigured'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
			 ,@Arg1 = 'Daylight-Savings-Time';

			raiserror(@errorText, 17, 1);
		end;

		if @ctzOffset is null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotConfigured'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
			 ,@Arg1 = 'Time-Zone-Offset';

			raiserror(@errorText, 17, 1);
		end;

		if @dstStatus not in ('ACTIVE', 'INACTIVE') -- DST is not used - e.g. setting is "N/A"
		begin
			set @resultMessage = N'Daylight Savings Time is not applied in this configuration (Setting: ' + isnull(@dstStatus, '(blank)') + N')';
		end;
		else if @isDSTActive = @ON and @dstStatus = 'INACTIVE' -- DST period is underway and adjustment not made; spring ahead
		begin

			set @ctzOffset = left(@ctzOffset, 1) + sf.fZeroPad(ltrim(cast(substring(@ctzOffset, 2, 2) as int) - 1), 2) + substring(@ctzOffset, 4, 3);

			update
				sf.ConfigParam
			set
				ParamValue = @ctzOffset
			where
				ConfigParamSCD = 'ClientTimeZoneOffset';

			update
				sf.ConfigParam
			set
				ParamValue = 'ACTIVE'
			where
				ConfigParamSCD = 'DSTStatus';

			set @resultMessage = N'Timezone offset adjusted to ' + @ctzOffset + N' for start of Daylight Savings Time';

		end;
		else if @isDSTActive = @OFF and @dstStatus = 'ACTIVE' -- DST period has ended and adjustment not reset; fall back
		begin

			set @ctzOffset = left(@ctzOffset, 1) + sf.fZeroPad(ltrim(cast(substring(@ctzOffset, 2, 2) as int) + 1), 2) + substring(@ctzOffset, 4, 3);

			update
				sf.ConfigParam
			set
				ParamValue = @ctzOffset
			where
				ConfigParamSCD = 'ClientTimeZoneOffset';

			update
				sf.ConfigParam
			set
				ParamValue = 'INACTIVE'
			where
				ConfigParamSCD = 'DSTStatus';

			set @resultMessage = N'Timezone offset adjusted to ' + @ctzOffset + N' for end of Daylight Savings Time';
		end;
		else -- otherwise DST setting is correct for current time; no change
		begin
			set @resultMessage = N'Timezone offset adjustment not required. Daylight Savings Time is: ' + @dstStatus;
		end;

		-- update job with final totals for actually records processed
		-- and errors encountered

		if @JobRunSID is not null
		begin

			set @resultMessage = 'Job completed successfully. ' + @resultMessage

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = 1
			 ,@RecordsProcessed = 1
			 ,@TotalErrors = 0
			 ,@ResultMessage = @resultMessage;

		end;

		if @ReturnDataSet = @ON 
		begin -- return data set to caller where requested
			select @resultMessage ;
		end;

	end try
	begin catch

		if isnull(@JobRunSID, 0) = 0
		begin
			print (error_message());
		end;

		-- if the procedure is running asynchronously record the
		-- error, else re-throw it to end processing

		if isnull(@JobRunSID, 0) > 0
		begin

			set @resultMessage = N'JOB FAILED: ' + error_message();

			insert
				sf.JobRunError (JobRunSID, MessageText, DataSource, RecordKey)
			select
				@JobRunSID
			 ,N'* ERROR: ' + error_message()
			 ,'Payment'
			 ,'ClientTimeZoneOffset';

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = 1
			 ,@RecordsProcessed = 0
			 ,@TotalErrors = 1
			 ,@IsFailed = @ON
			 ,@ResultMessage = @resultMessage;

		end;

		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
