SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pLogin#GetWarnings
	@ErrorRateThreshold decimal(2, 1) = 1.0 -- percentage above which a warning is generated for errors in last day
as
/*********************************************************************************************************************************
Sproc    : Login - Get Warnings
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure is called at login to advise SA's about situations (warnings and errors) requiring follow-up
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This procedure is called after login to check for key warning and error situations in the database and/or configuration.  The
first scenario checked is for low disk space remaining for the database. Several other error/warning scenarios are evaluated
and the system returns a record set with a single row describing the issue if any are found.  Even if multiple warning 
conditions are present, only the first warning is returned.  If no warning conditions exist, an empty data set is returned.

The final warning scenario checked is for an error rate over the threshold provided/defaulted as a parameter.

All warnings must be followed-up by the SA as they may impact core functionality of the application.

Known Limitations
-----------------
Where activity is very low - e.g. only a handful of sessions - and 1 error does happen to occur; an alert will be triggered. The
alert may not actually require follow-up even though it is significant as a percentage of total sessions.

Example
-------
<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Executes the procedure for the current DB">
    <SQLScript>
      <![CDATA[

exec sf.pLogin#GetWarnings

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
  <Test Name = "NoScheduler" Description="Disables the job schedule and calls procedure. (Re-enables job scheduler)">
    <SQLScript>
      <![CDATA[

exec sf.pJobSchedule#Stop
exec sf.pLogin#GetWarnings
exec sf.pJobSchedule#Start

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pLogin#GetWarnings'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@OFF		 bit							 = cast(0 as bit) -- constant for bit comparison = 0 
	 ,@endDate date							 = sf.fToday()
	 ,@endTime datetimeoffset(7) = dateadd(hour, -24, sysdatetimeoffset())
	 ,@errorCount int;

	begin try

		if db_name() = 'devv6' and @ErrorRateThreshold = 1.0 -- override error rate default for the DEV db
		begin
			set @ErrorRateThreshold = 5.0;
		end;

		-- check warning/error conditions

		select @errorCount = count (1) from sf.UnexpectedError ue where ue.CreateTime >= @endTime

		if @errorCount > 100
		begin

			select
				'Error count is high: ' + ltrim(@errorCount) + ' errors encountered in last 24 hours. Review Utilities->Errors and contact help desk.' MessageText
			 ,'fa-exclamation-square'																																											 MessageIcon
			from
				sf.UnexpectedError ue
			where
				ue.CreateTime >= @endTime;

		end;
		else if exists (select 1 from		sf.vDBSpace#Warning dsw) -- disk space
		begin
			select dsw.MessageText, dsw.MessageIcon from sf.vDBSpace#Warning dsw;
		end;
		else if sf.fJobSchedule#IsStarted() = @OFF
		begin

			select
				'Job scheduler is not running (automated emails and other background tasks are paused). Check Utilities->Jobs.' MessageText
			 ,'fa-exclamation-square'																																													MessageIcon;

		end;
		else if exists
		(
			select
				1
			from
				sf.vBackup#LatestFull blf
			where
				blf.DBName = db_name() and blf.BackupStatusCode <> 'OK'
		)
		begin -- no recent full backup

			select
				'Your database is missing a recent full backup! Most recent full backup taken ' + ltrim(blf.BackUpAgeInHours) + ' hours ago. Please contact help desk' MessageText
			 ,(case when right(blf.DBName, 4) <> 'Test' then 'fa-exclamation-square' else 'fa-exclamation-triangle' end)																						 MessageIcon
			from
				sf.vBackup#LatestFull blf
			where
				blf.DBName = db_name();

		end;
		else if exists
		(
			select
				1
			from
				sf.vJobRun jr
			where
				JobStatusSCD = 'INPROCESS' and datediff(hour, jr.StartTime, sysdatetimeoffset()) > 4
		)
		begin -- stuck job

			select top (1)
				'Job is stuck: ' + jr.JobLabel + ' has been in-process for ' + ltrim(datediff(hour, jr.StartTime, sysdatetimeoffset()))
				+ 'hours. Check Utilities->Jobs for details.' MessageText
			 ,(case
					 when datediff(hour, jr.StartTime, sysdatetimeoffset()) > 8 then 'fa-exclamation-square'
					 else 'fa-exclamation-triangle'
				 end
				)																							MessageIcon
			from
				sf.vJobRun jr
			where
				JobStatusSCD = 'INPROCESS' and datediff(hour, jr.StartTime, sysdatetimeoffset()) > 4
			order by
				jr.StartTime;

		end;
		else
		begin -- high error rate

			select
				'Error rate is high: ' + ltrim(ues.ErrorsPer100Users) + ' errors per 100 user sessions.  Check Utilities->Errors for details.' MessageText
			 ,(case when ues.ErrorsPer100Users > 5 then 'fa-exclamation-square' else 'fa-exclamation-triangle' end)															MessageIcon
			from
				sf.fUnexpectedError#Rate(@endDate, @endDate) ues
			where
				ues.ErrorsPer100Users > @ErrorRateThreshold;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
