SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pJobSchedule#Reset
as
/*********************************************************************************************************************************
Sproc    : Job Schedule - Reset
Notice   : Copyright © 2019 Softworks Group Inc.
Summary  : Re-establishes message queue broker with a new identifier
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments	
--------
This is a utility procedure used to solve issues with jobs not executing through the scheduler. It recreates the message
broker where the current broker has become corrupted, or, the ID of the current broker is from a database restored from 
another machine and therefore invalid on the new location of the database.

Job scheduling does not use SQL Agent. Rather, the SQL Service Broker queue technology is used.  A single queue is used,  
"JobScheduleQ", which manages a single conversation that, except in the case of errors, is never ended.  

The procedure will not have negative impacts on jobs already running in background.  Resetting the queue only impacts
the process that reads the schedule and the procedure stops the schedule before 

Example
-------
<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Executes the procedure to reset the message broker">
    <SQLScript>
      <![CDATA[
exec sf.pJobSchedule#Reset
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:05:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pJobSchedule#Reset'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int					 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)													-- message text for business rule errors
	 ,@procName	 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@ON				 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@OFF			 bit					 = cast(0 as bit)					-- constant for bit comparison = 0
	 ,@alterSQL	 nvarchar(500);													-- buffer for dynamic SQL 

	begin try

		if @@trancount > 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'TransactionPending'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A transaction was started prior to calling this procedure. Procedure "%1" does not allow nested transactions.'
			 ,@Arg1 = @procName;

			raiserror(@errorText, 18, 1);

		end;

		if sf.fJobSchedule#IsStarted() = @ON -- show current status of schedule
		begin
			exec sf.pJobSchedule#Stop;
		end;

		set @alterSQL = N'alter database ' + db_name() + N' set new_broker with rollback immediate;';

		exec sp_executesql @stmt = @alterSQL;

		exec sf.pJobSchedule#Start;

		if sf.fJobSchedule#IsStarted() = @OFF
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SchedulerFailedToStart'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The message queue was reset but the job schedule was not restarted successfully.'
			 ,@Arg1 = @procName;

			raiserror(@errorText, 18, 1);

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
