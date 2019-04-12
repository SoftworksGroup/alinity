SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#TaskStatus]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.TaskStatus data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.TaskStatus master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Christian T	| April	2012		| Initial Version         
				 : Christian T	| May 2014			| Added test harness
				 : Richard K		| April 2015		| Updated to avoid overwriting user changes to TaskStatusLabel, UsageNotes
				 : Tim Edlund		| Aug 2017			| Added PLANNED status, IsDerived bit, and corrected error in bit settings on OVERDUE
				 : Tim Edlund		| Jul 2018			| Added logic to ensure a default is created.
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the dbo.TaskStatus table with the settings required by the current version of the application. If
a record is missing it is added. Where the record exists, it is set to current values. TaskStatuss no longer used are
deleted from the table. One MERGE statement is used to carryout all operations.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			if	not exists (select 1 from sf.Task where TaskStatusSID is not null)
			begin
				delete from sf.TaskStatus
				dbcc checkident( 'sf.TaskStatus', reseed, 1000000) with NO_INFOMSGS
			end

			exec dbo.pSetup$SF#TaskStatus
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.TaskStatus

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#TaskStatus'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON					 bit					 = cast(1 as bit) -- constant for boolean comparisons
	 ,@OFF				 bit					 = cast(0 as bit) -- constant for boolean comparisons
	 ,@sourceCount int														-- count of rows in the source table
	 ,@targetCount int														-- count of rows in the target table
	 ,@defaultSCD	 varchar(10);										-- code of current default record if any

	declare @setup table
	(
		ID								 int					 not null identity(1, 1)
	 ,TaskStatusSCD			 varchar(10)	 not null
	 ,TaskStatusLabel		 nvarchar(50)	 not null
	 ,UsageNotes				 nvarchar(max) null
	 ,IsClosedStatus		 bit					 not null
	 ,IsDefault					 bit					 not null
	 ,IsDerived					 bit					 not null
	 ,TaskStatusSequence smallint			 not null
	 ,CreateUser				 nvarchar(75)	 null
	 ,UpdateUser				 nvarchar(75)	 null
	);

	begin try

		insert
			@setup
		(
			TaskStatusSCD
		 ,TaskStatusLabel
		 ,UsageNotes
		 ,IsClosedStatus
		 ,IsDefault
		 ,IsDerived
		 ,TaskStatusSequence
		)
		values
		 (
				'OPEN', 'Open', 'This status indicates the task is underway but not yet complete.', @OFF, @OFF, @OFF, 10
			)
		 ,(
				'CANCELLED', 'Canceled', 'This status indicates that this task has been canceled and no action was taken.', @ON, @OFF, @OFF, 15
			)
		 ,(
				'CLOSED', 'Closed', 'This status indicates the task has been completed.  A separate status is available to indicate if the task was canceled.', @ON, @OFF, @OFF, 20
			)

		-- ensure default is established

		select
			@defaultSCD = x.TaskStatusSCD
		from
			sf.TaskStatus x
		join
			@setup				s on x.TaskStatusSCD = s.TaskStatusSCD
		where
			x.IsDefault = @ON and x.IsActive = @ON;

		if @defaultSCD is null
		begin -- if none in table set to OPEN
			set @defaultSCD = 'OPEN';
		end;

		update @setup	 set IsDefault = @ON where TaskStatusSCD = @defaultSCD;

		merge sf.TaskStatus target
		using
		(
			select
				x.TaskStatusSCD
			 ,x.TaskStatusLabel
			 ,x.UsageNotes
			 ,x.IsClosedStatus
			 ,x.IsDefault
			 ,x.IsDerived
			 ,x.TaskStatusSequence
			 ,@SetupUser CreateUser
			 ,@SetupUser UpdateUser
			from
				@setup x
		) source
		on target.TaskStatusSCD = source.TaskStatusSCD
		when not matched by target then
			insert
			(
				TaskStatusSCD
			 ,TaskStatusLabel
			 ,UsageNotes
			 ,IsClosedStatus
			 ,IsDefault
			 ,IsDerived
			 ,TaskStatusSequence
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.TaskStatusSCD, source.TaskStatusLabel, source.UsageNotes, source.IsClosedStatus, source.IsDefault, source.IsDerived, source.TaskStatusSequence
			 ,@SetupUser, @SetupUser
			)
		when matched then update set
												IsClosedStatus = source.IsClosedStatus
											 ,IsDefault = source.IsDefault
											 ,IsDerived = source.IsDerived
											 ,TaskStatusSequence = source.TaskStatusSequence
											 ,UsageNotes = source.UsageNotes
											 ,UpdateUser = @SetupUser
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;
		select @targetCount	 = count(1) from sf .TaskStatus;

		if isnull(@targetCount, 0) < @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupCountTooLow'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Insert of some setup records failed. Source table count is %1 but target table (%2) count is only %3. Check "JOIN" conditions.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.TaskStatus'
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
