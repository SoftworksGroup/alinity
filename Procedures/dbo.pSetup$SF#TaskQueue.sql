SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#TaskQueue]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.TaskQueue data
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates sf.TaskQueue master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2017		|	Initial version
				: Tim Edlund					| Nov 2018		| Updated to apply task queue codes and new queues for form types

Comments	
--------
This procedure adds task queues required by the product. A queue for System Administrators and another for General Administration
are added as Active.  Other queues are added for each of the major form types, however, they are added in an inactive status. 
These queues tend to be activated only by larger organizations requiring additional break-down of tasks into queues.

The procedure does not remove or otherwise modify non-system required task queues.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. ">
		<SQLScript>
		<![CDATA[

			exec dbo.pSetup$SF#TaskQueue
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.TaskQueue

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#TaskQueue'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON					 bit					 = cast(1 as bit) -- constant for boolean comparisons
	 ,@OFF				 bit					 = cast(0 as bit) -- constant for boolean comparisons
	 ,@sysAdminSID int;														-- key of user to assign as manager of this queue

	begin try

		-- procedure depends on application user grant having established
		-- at least one System Administrator (both TaskQueue and Application
		-- Grant are at same FK level)

		exec dbo.[pSetup$SF#ApplicationGrant] -- ensure records for application grant are in place first
			@SetupUser = @SetupUser
		 ,@Language = @Language
		 ,@Region = @Region;

		-- locate a system administrator record to assign as the owner for
		-- any new queues established

		select top (1)
			@sysAdminSID = au.ApplicationUserSID
		from
			sf.vApplicationUser au
		where
			au.IsSysAdmin = @ON and au.UserName <> 'JobExec'
		order by 
		 (case when au.UserName like 'support@%' then 10 else 0 end) -- only use support count as queue owner if no other sys-admin exists
		 ,au.ApplicationUserSID;

		if @sysAdminSID is null
		begin

			if @@rowcount = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotConfigured'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
				 ,@Arg1 = '"system administrator"';

				raiserror(@errorText, 17, 1);
			end;

		end;

		if not exists (select 1 from sf .TaskQueue tq where tq.TaskQueueCode = 'S!ADMIN.SYSADMIN')
		begin

			insert
				sf.TaskQueue
			(
				TaskQueueLabel
			 ,TaskQueueCode
			 ,ApplicationUserSID
			 ,IsActive
			 ,IsDefault
			 ,CreateUser
			 ,UpdateUser
			 ,UsageNotes
			)
			values
			(
				N'System Administration', 'S!ADMIN.SYSADMIN', @sysAdminSID, @ON, @ON, @SetupUser, @SetupUser
			 ,N'This queue is used to organize and distribute tasks to system administrators.'
			);

		end;

		if not exists (select 1 from sf .TaskQueue tq where tq.TaskQueueCode = 'S!ADMIN.BASE')
		begin

			insert
				sf.TaskQueue
			(
				TaskQueueLabel
			 ,TaskQueueCode
			 ,ApplicationUserSID
			 ,IsActive
			 ,CreateUser
			 ,UpdateUser
			 ,UsageNotes
			)
			values
			(
				N'General Administration', 'S!ADMIN.BASE', @sysAdminSID, @ON, @SetupUser, @SetupUser
			 ,N'This is a general queue to organize and distribute tasks to administrators. Form related tasks are also assigned here if form-related queues are disabled or removed from the configuration.'
			);

		end;

		if not exists (select 1 from sf.TaskQueue tq where tq.TaskQueueCode = 'S!ADMIN.APPLICATION')
		begin

			insert
				sf.TaskQueue
			(
				TaskQueueLabel
			 ,TaskQueueCode
			 ,ApplicationUserSID
			 ,IsActive
			 ,CreateUser
			 ,UpdateUser
			 ,UsageNotes
			)
			values
			(
				N'Application Administration', 'S!ADMIN.APPLICATION', @sysAdminSID, @OFF, @SetupUser, @SetupUser
			 ,N'This queue is used to organize and distribute tasks to application administrators.'
			);

		end;

		if not exists (select 1 from sf .TaskQueue tq where tq.TaskQueueCode = 'S!ADMIN.RENEWAL')
		begin

			insert
				sf.TaskQueue
			(
				TaskQueueLabel
			 ,TaskQueueCode
			 ,ApplicationUserSID
			 ,IsActive
			 ,CreateUser
			 ,UpdateUser
			 ,UsageNotes
			)
			values
			(
				N'Renewal Administration', 'S!ADMIN.RENEWAL', @sysAdminSID, @OFF, @SetupUser, @SetupUser
			 ,N'This queue is used to organize and distribute tasks to renewal administrators.'
			);

		end;

		if not exists (select 1 from sf.TaskQueue tq where tq.TaskQueueCode = 'S!ADMIN.REINSTATEMENT')
		begin

			insert
				sf.TaskQueue
			(
				TaskQueueLabel
			 ,TaskQueueCode
			 ,ApplicationUserSID
			 ,IsActive
			 ,CreateUser
			 ,UpdateUser
			 ,UsageNotes
			)
			values
			(
				N'Reinstatement Administration', 'S!ADMIN.REINSTATEMENT', @sysAdminSID, @OFF, @SetupUser, @SetupUser
			 ,N'This queue is used to organize and distribute tasks to reinstatement administrators.'
			);

		end;

		if not exists (select 1 from sf .TaskQueue tq where tq.TaskQueueCode = 'S!ADMIN.AUDIT')
		begin

			insert
				sf.TaskQueue
			(
				TaskQueueLabel
			 ,TaskQueueCode
			 ,ApplicationUserSID
			 ,IsActive
			 ,CreateUser
			 ,UpdateUser
			 ,UsageNotes
			)
			values
			(
				N'Audit Administration', 'S!ADMIN.AUDIT', @sysAdminSID, @OFF, @SetupUser, @SetupUser
			 ,N'This queue is used to organize and distribute tasks to audit administrators.'
			);

		end;

		if not exists (select 1 from		sf.TaskQueue tq where tq.TaskQueueCode = 'S!ADMIN.COMPETENCE')
		begin

			insert
				sf.TaskQueue
			(
				TaskQueueLabel
			 ,TaskQueueCode
			 ,ApplicationUserSID
			 ,IsActive
			 ,CreateUser
			 ,UpdateUser
			 ,UsageNotes
			)
			values
			(
				N'CE Administration', 'S!ADMIN.COMPETENCE', @sysAdminSID, @OFF, @SetupUser, @SetupUser
			 ,N'This queue is used to organize and distribute tasks to Continuing Education/Competence administrators.'
			);

		end;

		if not exists (select 1 from		sf.TaskQueue tq where tq.TaskQueueCode = 'S!ADMIN.COMPLAINTS')
		begin

			insert
				sf.TaskQueue
			(
				TaskQueueLabel
			 ,TaskQueueCode
			 ,ApplicationUserSID
			 ,IsActive
			 ,CreateUser
			 ,UpdateUser
			 ,UsageNotes
			)
			values
			(
				N'Complaint Administration', 'S!ADMIN.COMPLAINTS', @sysAdminSID, @OFF, @SetupUser, @SetupUser
			 ,N'This queue is used to organize and distribute tasks to Complaint administrators.'
			);

		end;

		if not exists (select 1 from		sf.TaskQueue tq where tq.TaskQueueCode = 'S!ADMIN.ACCOUNTING')
		begin

			insert
				sf.TaskQueue
			(
				TaskQueueLabel
			 ,TaskQueueCode
			 ,ApplicationUserSID
			 ,IsActive
			 ,CreateUser
			 ,UpdateUser
			 ,UsageNotes
			)
			values
			(
				N'Accounting Administration', 'S!ADMIN.ACCOUNTING', @sysAdminSID, @OFF, @SetupUser, @SetupUser
			 ,N'This queue is used to organize and distribute tasks to Accounting administrators.'
			);

		end;

		-- ensure a default queue is set

		if not exists (select 1 from sf .TaskQueue tq where tq.IsDefault = @ON) -- in case no records are set as a default, set one now
		begin

			update
				sf.TaskQueue
			set
				IsDefault = @ON
			 ,UpdateUser = @SetupUser
			 ,UpdateTime = sysdatetimeoffset()
			where
				TaskQueueCode = 'S!ADMIN.BASE' and IsActive = @ON;

			if @@rowcount = 0
			begin

				update
					sf.TaskQueue
				set
					IsDefault = @ON
				 ,UpdateTime = sysdatetimeoffset()
				where
					TaskQueueSID = (select min (x.TaskQueueSID) from sf .TaskQueue x where x.IsActive = @ON);

			end;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
