SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pSetup$SF#JobSchedule
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.JobSchedule data
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Updates sf.JobSchedule master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Nov	2012			| Initial Version
				 : Kris Dawson	| Jan 2018			| Rewritten in new pattern, added 24h schedules
				 : Tim Edlund		| Jul 2018			| Split every-night schedules into before and after midnight options (added 1 schedule)
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------

This procedure adds or updates job schedules provided as defaults by the product.

This procedure adds some standard job schedules which will typically be useful for all configurations.  Configurators may extend
this table by modifying, adding or deleting job schedules in a client specific setup script.

Minimum Schedule Interval is 15 Minutes and Not Aligned on Hour!
----------------------------------------------------------------
The current version of the scheduler is based on a message broker conversation handle that is checked no more often than
every 15 minutes. The 15 minute check interval is not necessarily aligned on the hour since it will align to whenever the
schedule process was last re-started.  As a result, setting a schedule option to run once at a specific time - e.g. 2:00am
and only 2:00am is likely to result in no jobs being run on that schedule. The schedule's minimum duration must be at least 
15 minutes. This means that a job targeted to run at 2:00am - may not actually run until 2:15am.  A precise time is not
possible in the current Message-Broker based architecture.  Shortening the read interval to 1 minute will cause repeating
events - such as trigger generation - to run that often which will increase contention on key tables and generally reduce
system performance.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Runs setup">
		<SQLScript>
		<![CDATA[
			exec dbo.pSetup$SF#JobSchedule
				 @SetupUser = 'setup@softworksgroup.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.JobSchedule
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#JobSchedule'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)										-- message text (for business rule errors)
	 ,@sourceCount int															-- count of rows in the source table
	 ,@targetCount int															-- count of rows in the target table
	 ,@ON					 bit					 = cast(1 as bit)		-- constant for boolean comparisons
	 ,@OFF				 bit					 = cast(0 as bit);	-- constant for boolean comparisons

	declare @setup table
	(
		ID										int					 identity(1, 1)
	 ,JobScheduleLabel			nvarchar(35) not null
	 ,IsRunMonday						bit					 not null
	 ,IsRunTuesday					bit					 not null
	 ,IsRunWednesday				bit					 not null
	 ,IsRunThursday					bit					 not null
	 ,IsRunFriday						bit					 not null
	 ,IsRunSaturday					bit					 not null
	 ,IsRunSunday						bit					 not null
	 ,RepeatIntervalMinutes smallint		 not null
	 ,StartTime							time(0)			 not null
	 ,EndTime								time(0)			 not null
	);

	begin try

		insert
			@setup
		(
			JobScheduleLabel
		 ,IsRunMonday
		 ,IsRunTuesday
		 ,IsRunWednesday
		 ,IsRunThursday
		 ,IsRunFriday
		 ,IsRunSaturday
		 ,IsRunSunday
		 ,RepeatIntervalMinutes
		 ,StartTime
		 ,EndTime
		)
		values
		(
			N'Every night at midnight', @ON, @ON, @ON, @ON, @ON, @ON, @ON, 30, cast('00:00:00' as time(0)), cast('00:20:00' as time(0))
		)
		 ,(
				N'Every night before midnight', @ON, @ON, @ON, @ON, @ON, @ON, @ON, 30, cast('23:00:00' as time(0)), cast('23:20:00' as time(0))
			)
		 ,(
				N'Every night after midnight', @ON, @ON, @ON, @ON, @ON, @ON, @ON, 30, cast('03:00:00' as time(0)), cast('03:20:00' as time(0))
			)
		 ,(
				N'Every 15 minutes', @ON, @ON, @ON, @ON, @ON, @ON, @ON, 15, cast('00:00:00' as time(0)), cast('23:59:59' as time(0))
			)
		 ,(
				N'Every 60 minutes', @ON, @ON, @ON, @ON, @ON, @ON, @ON, 60, cast('00:00:00' as time(0)), cast('23:59:59' as time(0))
			)
		 ,(
				N'Business hours every 15 minutes', @ON, @ON, @ON, @ON, @ON, @OFF, @OFF, 15, cast('08:00:00' as time(0)), cast('17:30:00' as time(0))
			)
		 ,(
				N'Business hours every 60 minutes', @ON, @ON, @ON, @ON, @ON, @OFF, @OFF, 60, cast('08:00:00' as time(0)), cast('17:30:00' as time(0))
			)
		 ,(
				N'Sunday night before midnight', @OFF, @OFF, @OFF, @OFF, @OFF, @OFF, @ON, 30, cast('20:00:00' as time(0)), cast('20:20:00' as time(0))
			)
		 ,(
				N'Sunday morning 2:00 am', @OFF, @OFF, @OFF, @OFF, @OFF, @OFF, @ON, 30, cast('02:00:00' as time(0)), cast('02:20:00' as time(0))	-- required for Daylight-Savings-Time adjustment job!
			);

		merge sf.JobSchedule target
		using
		(
			select
				x.JobScheduleLabel
			 ,x.IsRunMonday
			 ,x.IsRunTuesday
			 ,x.IsRunWednesday
			 ,x.IsRunThursday
			 ,x.IsRunFriday
			 ,x.IsRunSaturday
			 ,x.IsRunSunday
			 ,x.RepeatIntervalMinutes
			 ,x.StartTime
			 ,x.EndTime
			from
				@setup x
		) source
		on target.JobScheduleLabel = source.JobScheduleLabel
		when not matched by target then
			insert
			(
				JobScheduleLabel
			 ,IsRunMonday
			 ,IsRunTuesday
			 ,IsRunWednesday
			 ,IsRunThursday
			 ,IsRunFriday
			 ,IsRunSaturday
			 ,IsRunSunday
			 ,RepeatIntervalMinutes
			 ,StartTime
			 ,EndTime
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.JobScheduleLabel, source.IsRunMonday, source.IsRunTuesday, source.IsRunWednesday, source.IsRunThursday, source.IsRunFriday, source.IsRunSaturday
			 ,source.IsRunSunday, source.RepeatIntervalMinutes, source.StartTime, source.EndTime, @SetupUser, @SetupUser
			)
		when matched then update set
												target.JobScheduleLabel = source.JobScheduleLabel
											 ,target.IsRunMonday = source.IsRunMonday
											 ,target.IsRunTuesday = source.IsRunTuesday
											 ,target.IsRunWednesday = source.IsRunWednesday
											 ,target.IsRunThursday = source.IsRunThursday
											 ,target.IsRunFriday = source.IsRunFriday
											 ,target.IsRunSaturday = source.IsRunSaturday
											 ,target.IsRunSunday = source.IsRunSunday
											 ,target.RepeatIntervalMinutes = source.RepeatIntervalMinutes
											 ,target.StartTime = source.StartTime
											 ,target.EndTime = source.EndTime
											 ,UpdateUser = @SetupUser
											 ,UpdateTime = sysdatetimeoffset()
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have exactly as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;
		select @targetCount	 = count(1) from sf .JobSchedule;

		if isnull(@targetCount, 0) <> @sourceCount
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.JobSchedule'
			 ,@Arg3 = @targetCount;

			raiserror(@errorText, 18, 1);
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
