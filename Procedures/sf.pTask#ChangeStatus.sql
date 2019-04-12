SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pTask#ChangeStatus
	@Tasks		           xml				-- keys of task records to refund (1 to N keys supported)
 ,@TaskStatusSCD	     varchar(25)-- status code to change tasks to
as

/*********************************************************************************************************************************
Sproc    : Task - Change status
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure changes the status of one or more tasks
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Cory Ng             | Nov 2018		|	Initial version

Comments	
-------- 
This procedure is called from the UI to set the status of multiple tasks. The procedure requires one or more task keys, and the
status code to change to.

The keys must be passed in the XML parameter using the following format:

<Tasks>
		<Task SID="1003170" />
		<Task SID="1000011" />
		<Task SID="1000123" />
</Tasks> 

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Reassign a random task to a random admin">
    <SQLScript>
      <![CDATA[
      
declare
	@taskSID	          int
 ,@tasks		          xml

select top (1)
	@taskSID = t.TaskSID
from
	sf.vTask t
where
  t.TaskStatusSCD = 'OPEN'
order by
	newid();

set @tasks = N'<Tasks><Task SID="' + ltrim(@taskSID) + '" /></Tasks>';

if @taskSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pTask#ChangeStatus
		@Tasks = @tasks
	 ,@TaskStatusSCD = 'CLOSED';

	select
		 t.TaskSID
    ,t.TaskStatusSCD
	from
		sf.vTask t
	where
		t.TaskSID = @taskSID;

	rollback
end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pTask#ChangeStatus'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				 nvarchar(4000)									-- message text for business rule errors
	 ,@blankParm				 varchar(50)										-- tracks name of any required parameter not passed
	 ,@taskSID				   int														-- next task to process
	 ,@i								 int														-- loop iteration counter
	 ,@maxrow						 int;														-- loop limit

	declare @work table (ID int identity(1, 1), TaskSID int not null);

	begin try

		-- check parameters

		-- SQL Prompt formatting off
		if @TaskStatusSCD		is null	set @blankParm = '@TaskStatusSCD';
		if @Tasks		is null	set @blankParm = '@Tasks';
		-- SQL Prompt formatting on

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		-- parse XML key values into table for processing

		insert
			@work (TaskSID)
		select
			Task.p.value('@SID', 'int')
		from
			@Tasks.nodes('//Task') Task(p);

		set @maxrow = @@rowcount;
		set @i = 0;

		while @i < @maxrow
		begin

			set @i += 1;

			select 
        @taskSID = t.TaskSID 
      from 
        @work w 
      join
        sf.Task t on w.TaskSID = t.TaskSID
      where 
        w.ID = @i;

			if @taskSID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'sf.Task'
				 ,@Arg2 = @taskSID;

				raiserror(@errorText, 18, 1);
			end;

			begin transaction; -- treat each status change as a separate transaction

			exec sf.pTask#Update
				@TaskSID = @taskSID
			 ,@TaskStatusSCD = @TaskStatusSCD
			
			commit;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
