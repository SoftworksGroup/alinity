SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$ExamStatus]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup Exam Result values
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Updates the (dbo) Exam Result master table with the values expected by the application
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| May 2018		|	Initial version

Comments	
--------
This procedure synchronizes the dbo.ExamStatus table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, it is set to current values. Exam Results no longer used are
deleted from the table. One MERGE statement is used to carryout all operations.

Example:
--------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$ExamStatus
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from dbo.ExamStatus order by Sequence

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$ExamStatus'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0											-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)													-- message text (for business rule errors)
	 ,@ON					 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@OFF				 bit					 = cast(0 as bit)					-- constant for bit comparison = 0
	 ,@tranCount	 int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName		 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState			 int																		-- error state detected in catch block
	 ,@sourceCount int																		-- count of rows in the source table
	 ,@targetCount int;																		-- count of rows in the target table

	declare @setup table
	(
		ID							int					 identity(1, 1)
	 ,ExamStatusSCD		varchar(25)	 not null
	 ,ExamStatusLabel nvarchar(35) not null
	 ,Sequence				int					 not null
	 ,IsDefault				bit					 not null
	);

	begin try

		-- process DB changes as a transaction
		-- to enable partial rollback on error

		if @tranCount = 0
		begin
			begin transaction; -- no wrapping transaction
		end;
		else
		begin
			save transaction @procName; -- previous trx pending - create save point
		end;

		insert
			@setup (ExamStatusSCD, ExamStatusLabel, Sequence, IsDefault)
		values
		 ('PENDING', N'Pending', 5, @ON)
		 ,('PASSED', N'Passed', 10, @OFF)
		 ,('FAILED', N'Failed', 15, @OFF)
		 ,('NOT.TAKEN', N'Not Taken (missed)', 99, @OFF);

		merge dbo.ExamStatus target
		using
		(
			select
				x.ExamStatusSCD
			 ,x.ExamStatusLabel
			 ,x.Sequence
			 ,x.IsDefault
			 ,@SetupUser CreateUser
			 ,@SetupUser UpdateUser
			from
				@setup x
		) source
		on target.ExamStatusSCD = source.ExamStatusSCD
		when not matched by target then insert
																		(
																			ExamStatusSCD
																		 ,ExamStatusLabel
																		 ,Sequence
																		 ,IsDefault
																		 ,CreateUser
																		 ,UpdateUser
																		)
																		values
																		(
																			source.ExamStatusSCD, source.ExamStatusLabel, source.Sequence, source.IsDefault, @SetupUser, @SetupUser
																		)
		when matched then update set
												IsDefault = source.IsDefault
											 ,Sequence = source.Sequence
											 ,UpdateUser = @SetupUser
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;
		select @targetCount	 = count(1) from dbo.ExamStatus;

		if isnull(@targetCount, 0) <> @sourceCount
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'dbo.ExamStatus'
			 ,@Arg3 = @targetCount;

			raiserror(@errorText, 18, 1);
		end;

		if @tranCount = 0 and xact_state() = 1 -- if no wrapping transaction and committable
		begin
			commit;
		end;

	end try
	begin catch

		-- if a transaction was pending at start of routine 
		-- perform partial rollback to save point

		set @xState = xact_state();

		if @tranCount > 0 and (@xState = -1 or @xState = 1)
		begin
			rollback transaction @procName; -- rollback to save point
		end;
		else if (@xState = -1 or @xState = 1) -- full rollback since no previous trx was pending
		begin
			rollback;
		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error

	end catch;

	return (@errorNo);
end;
GO
