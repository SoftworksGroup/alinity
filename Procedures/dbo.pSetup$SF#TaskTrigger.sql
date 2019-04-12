SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#TaskTrigger]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.TaskTrigger data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Updates sf.TaskTrigger master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Jul	2013			| Initial Version
				 : Christian T	| May 2014			| Added test harness
				 : Richard K		| Aug 2015			| Updated where clause when selecting a querySID, to ensure only one value is returned
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------

This procedure adds task triggers provided with the product.  Task triggers CAN be added by configurators so the content of the 
table provided by this procedure is simply a starting point; configurators may add, delete or update the triggers defined here. A
UI is provided to allow the task triggers to be updated.  The procedure adds missing Task Triggers matching on the "QuerySID" 
and "TaskQueueSID" column values.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			if	not exists (select 1 from sf.Task where TaskTriggerSID is not null)
			begin
				delete from sf.TaskTrigger
				dbcc checkident( 'sf.TaskTrigger', reseed, 1000000) with NO_INFOMSGS
			end

			exec dbo.pSetup$SF#TaskTrigger
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.TaskTrigger

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#TaskTrigger'
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
			,TaskTriggerLabel					nvarchar(35)			not null
			,TaskTitleTemplate				nvarchar(65)			not null
			,TaskNotesTemplate				nvarchar(max)			not null
			,QuerySID									int								not null
			,TaskQueueSID							int								not null
			,TargetCompletionDays			smallint					not null
			,OpenTaskLimit						int								not null
			,IsAlert									bit								not null
			,JobScheduleSID						int								null
			)

		-- all triggers for setup are placed into the default queue

		select
			@taskQueueSID = tq.TaskQueueSID
		from
			sf.TaskQueue tq
		where
			tq.IsDefault = @ON

		if isnull(@taskQueueSID,0) = 0
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'RequiredDataMissingForSetup'
				,@MessageText = @errorText output
				,@DefaultText = N'Data required for setup of "%1" records is missing: "%2".'
				,@Arg1        = 'TaskTrigger (sf.TaskTrigger)'
				,@Arg2        = 'Default Task Queue (sf.TaskQueue)'
			
			raiserror(@errorText, 18, 1)
			
		end

		--insert
		--	@setup
		--(
		--	 TaskTriggerLabel		
		--	,TaskTitleTemplate		
		--	,TaskNotesTemplate		
		--	,QuerySID							
		--	,TaskQueueSID					
		--	,TargetCompletionDays	
		--	,OpenTaskLimit				
		--	,IsAlert
		--	,JobScheduleSID				
		--)
		--select
		--	 N'Review inactive accounts'
		--	,N'User account "{UserName}" appears inactive'
		--	,N'The account for {DisplayName} has not been used in the last {DaysSinceLastDBAccess} days. Review the account to determine if it should be closed or removed from the system.'
		--	,(select top 1 x.QuerySID from sf.Query	x where charindex(N'Account unused', x.QueryLabel ) > 0)
		--	,@taskQueueSID
		--	,7
		--	,50
		--	,@OFF
		--	,(select x.JobScheduleSID  from sf.JobSchedule x where charindex(N'Sunday', x.JobScheduleLabel ) > 0)

		--insert
		--	@setup
		--(
		--	 TaskTriggerLabel		
		--	,TaskTitleTemplate		
		--	,TaskNotesTemplate		
		--	,QuerySID							
		--	,TaskQueueSID					
		--	,TargetCompletionDays	
		--	,OpenTaskLimit				
		--	,IsAlert
		--	,JobScheduleSID				
		--)
		--select
		--	 N'Review accounts'
		--	,N'User account "{UserName}" requires review'
		--	,N'The account for {DisplayName} was due for review on {NextProfileReviewDueDate}.  Organization policy requires that accounts be reviewed periodically to ensure they are still required and access grants are appropriate.'
		--	,(select top 1 x.QuerySID from sf.Query	x where charindex(N'Account review overdue', x.QueryLabel ) > 0 and ApplicationPageSID = (select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI = 'ContactManagement'))
		--	,@taskQueueSID
		--	,7
		--	,50
		--	,@OFF
		--	,(select x.JobScheduleSID  from sf.JobSchedule x where charindex(N'Sunday', x.JobScheduleLabel ) > 0)


		-- insert the rows into the target table where the Task Trigger does not exist
		-- perform the match using the label column

		insert
			sf.TaskTrigger
		(
			 TaskTriggerLabel		
			,TaskTitleTemplate		
			,TaskDescriptionTemplate		
			,QuerySID							
			,TaskQueueSID					
			,TargetCompletionDays	
			,OpenTaskLimit				
			,JobScheduleSID				
		) 
		select
			 s.TaskTriggerLabel		
			,s.TaskTitleTemplate		
			,s.TaskNotesTemplate		
			,s.QuerySID							
			,s.TaskQueueSID					
			,s.TargetCompletionDays	
			,s.OpenTaskLimit				
			,s.JobScheduleSID			
		from
			@setup					s
		left outer join
			sf.TaskTrigger	tt		on s.TaskQueueSID = tt.TaskQueueSID and s.QuerySID = tt.QuerySID																			-- avoid violating UK on queue + query SID
		where
			tt.TaskTriggerSID	is null
		and
		 (
			tt.TaskTriggerLabel <> s.TaskTriggerLabel														-- avoid violating the unique label business rule.
			or
			tt.TaskTriggerLabel is null
			)

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from  @setup            
		select @targetCount = count(1) from  sf.TaskTrigger

		if isnull(@targetCount,0) < @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupCountTooLow'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Insert of some setup records failed. Source table count is %1 but target table (%2) count is only %3. Check "JOIN" conditions.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'sf.TaskTrigger'
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
