SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pComplaint#SetProcess
	@ComplaintSID				 int					-- key of the complaint to add process events to
 ,@ComplaintProcessSID int					-- key identifying the process (event set) to add
 ,@StartDate					 date = null	-- optional starting date for new events (defaults to today)
 ,@ReturnSelect				 bit = 0			-- when 1 returns a data set indicating the count of events added
as
/*********************************************************************************************************************************
Sproc    : Complaint - Set Process
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure adds one or more events defined as a templated process to the complaint
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Jan 2019		|	Initial version

Comments	
--------
This procedure supports adding a series of events defined in the Complaint-Process table, to an existing complaint.  The key of 
the complaint and the process must both be passed. Optionally an existing complaint-event key can be passed to direct the 
procedure to insert the new events at that point (AFTER the value provided) in the sequence of events. If an existing event key
is not passed then the new events are added at the end of the sequence.

When called from the UI, the @ReturnSelect parameter can be passed as ON to return the count of events inserted.  

Known Limitations
-----------------
The procedure does not avoid duplication.  It is possible to add the same event(s) more than once to the existing list of 
events.  The user can, however, delete duplicated or extraneous events through the application UI.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the procedure for a complaint and process selected at random">
    <SQLScript>
      <![CDATA[

declare
	@complaintSID				 int
 ,@complaintProcessSID int;

select top (1)
	@complaintSID = c.ComplaintSID
from
	dbo.Complaint c
where
	c.ClosedDate is null
order by
	newid();

select top (1)
	@complaintProcessSID = cp.ComplaintProcessSID
from
	dbo.ComplaintProcess cp
order by
	newid();

if @complaintSID is null or @complaintProcessSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction

	exec dbo.pComplaint#SetProcess
		@ComplaintSID = @complaintSID
	 ,@ComplaintProcessSID = @complaintProcessSID
	 ,@ReturnSelect = 1;

	rollback

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:05:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pComplaint#SetProcess'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							 int					 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						 nvarchar(4000)													-- message text for business rule errors
	 ,@blankParm						 nvarchar(128)													-- tracks blank parameters (for error message)
	 ,@tranCount						 int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@procName							 nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState								 int																		-- error state detected in catch block	
	 ,@ON										 bit					 = cast(1 as bit)					-- constant for bit comparisons = 1
	 ,@maxRow								 int																		-- loop limit
	 ,@i										 int																		-- loop index counter
	 ,@complaintEventTypeSID int																		-- key of type of next event to add
	 ,@dueDate							 date																		-- target due date to set for next event to add
	 ,@description					 nvarchar(500);													-- buffer for description of next event to add

	declare @work table (ID int not null identity(1, 1), ComplaintProcessEventSID int not null);

	begin try

		-- if a wrapping transaction exists set a save point to rollback to on a local error

		if @tranCount = 0 -- no outer transaction
		begin
			begin transaction;
		end;
		else -- outer transaction so create save point
		begin
			save transaction @procName;
		end;

		-- validate parameters

-- SQL Prompt formatting off
		if @ComplaintProcessSID is null set @blankParm = N'@ComplaintProcessSID';
		if @ComplaintSID				is null set @blankParm = N'@ComplaintSID';
-- SQL Prompt formatting on

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = 'Parameter';

			raiserror(@errorText, 18, 1);
		end;

		if not exists (select 1 from dbo .Complaint x where x.ComplaintSID = @ComplaintSID)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.Complaint'
			 ,@Arg2 = @ComplaintSID;

			raiserror(@errorText, 18, 1);
		end;

		if not exists
		(
			select
				1
			from
				dbo.ComplaintProcess x
			where
				x.ComplaintProcessSID = @ComplaintProcessSID
		)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.ComplaintProcess'
			 ,@Arg2 = @ComplaintProcessSID;

			raiserror(@errorText, 18, 1);
		end;

		-- establishing "last" due date to insert new events after 
		-- based on value provided by user or set to today

		if @StartDate is not null
		begin
			set @dueDate = @StartDate;
		end;
		else
		begin
			set @dueDate = sf.fToday(); -- use current date as start point if no events		
		end;

		-- load the work table with event records to add

		insert
			@work (ComplaintProcessEventSID)
		select
			x.ComplaintProcessEventSID
		from
			dbo.ComplaintProcessEvent x
		where
			x.ComplaintProcessSID = @ComplaintProcessSID
		order by
			x.Sequence;

		set @maxRow = @@rowcount;
		set @i = 0;

		-- add each record

		while @i < @maxRow
		begin

			set @i += 1;

			select
				@complaintEventTypeSID = cpe.ComplaintEventTypeSID
			 ,@description					 = cpe.Description
			 ,@dueDate							 = dateadd(day, cpe.TargetDurationDays, @dueDate)
			from
				@work											w
			join
				dbo.ComplaintProcessEvent cpe on w.ComplaintProcessEventSID = cpe.ComplaintProcessEventSID
			where
				w.ID = @i;

			exec dbo.pComplaintEvent#Insert -- setting of target dates is handled within sproc
				@ComplaintSID = @ComplaintSID
			 ,@ComplaintEventTypeSID = @complaintEventTypeSID
			 ,@Description = @description
			 ,@DueDate = @dueDate;

		end;

		if @tranCount = 0 and xact_state() = 1 -- if no wrapping transaction and committable
		begin
			commit;
		end;

		if @ReturnSelect = @ON
		begin
			select ltrim (@i) + ' Event(s) added';
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
