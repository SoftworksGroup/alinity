SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#TaskQueueSubscriber]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.TaskQueueSubscriber data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Updates sf.TaskQueueSubscriber master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Jul	2013			| Initial Version
				 : Christian T	| May 2014			| Added test harness
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------

This procedure adds subscribers to the default task queue (only). Task queue subscribers are maintained by the application user
so the setup procedure only ensures that all System Administrators are assigned to the default task queue.  Other setup sprocs 
that create task triggers always assign the tasks to the default queue so this ensures at least one end user will see alerts
or have access to non-alert tasks.

Example:
--------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			delete from sf.TaskQueueSubscriber
			dbcc checkident( 'sf.TaskQueueSubscriber', reseed, 1000000) with NO_INFOMSGS

			exec dbo.pSetup$SF#TaskQueueSubscriber
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.TaskQueueSubscriber

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#TaskQueueSubscriber'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table
		,@ON																bit = cast(1 as bit)							-- constant for boolean comparisons
		,@OFF																bit = cast(0 as bit)							-- constant for boolean comparisons
		,@taskQueueSID											int																-- tracks default task queue

	begin try

		declare
			@setup						        table																			-- setup data for staging rows to be inserted
			(
			 ID												int								identity(1,1)
			,TaskQueueSID							int								not null
			,ApplicationUserSID				int								not null
			,ChangeAudit							nvarchar(max)			not null
			)

		-- get default queue PK or raise error

		select
			@taskQueueSID = tq.TaskQueueSID
		from
			sf.TaskQueue tq
		where
			tq.IsDefault = @ON

		if isnull(@taskQueueSID, 0) = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotConfigured'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
			 ,@Arg1 = '"Default Task Queue"';

			raiserror(@errorText, 17, 1);

		end;
		
		insert
			@setup
		(
			 TaskQueueSID
			,ApplicationUserSID
			,ChangeAudit
		)
		select
			 @taskQueueSID
			,au.ApplicationUserSID
      ,convert(nvarchar(19), sf.fNow(), 0) + ' Assigned by: ' + @SetupUser
		from
			sf.vApplicationUser au
		where
			au.IsSysAdmin = @ON
		and
			au.IsActive = @ON
		order by
			au.CreateTime

		-- insert the rows into the target table where the subscription does not exist
		-- perform the match using the queue and user SID values

		insert
			sf.TaskQueueSubscriber
		(
			 TaskQueueSID
			,ApplicationUserSID
			,ChangeAudit
			,CreateUser
			,UpdateUser
		) 
		select
			 s.TaskQueueSID
			,s.ApplicationUserSID	
			,s.ChangeAudit	
			,@SetupUser
			,@SetupUser
		from
			@setup		s
		left outer join
			sf.TaskQueueSubscriber	tqs	on s.TaskQueueSID = tqs.TaskQueueSID and s.ApplicationUserSID = tqs.ApplicationUserSID
		where
			tqs.TaskQueueSubscriberSID is null

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from  @setup            
		select @targetCount = count(1) from  sf.TaskQueueSubscriber

		if isnull(@targetCount,0) < @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupCountTooLow'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Insert of some setup records failed. Source table count is %1 but target table (%2) count is only %3. Check "JOIN" conditions.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'sf.TaskQueueSubscriber'
				,@Arg3          = @targetCount

			raiserror(@errorText, 18, 1)
		end
			
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
