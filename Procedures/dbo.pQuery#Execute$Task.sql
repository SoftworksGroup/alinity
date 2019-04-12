SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pQuery#Execute$Task
	@QueryCode	varchar(30)							-- code of the sf.Query record to execute query for
 ,@Parameters dbo.Parameter readonly	-- query parameter values assigned to variables in query syntax
 ,@MaxRows		int											-- maximum rows allowed on search
as
/*********************************************************************************************************************************
Sproc    : Query Search - Task
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure executes searches (queries) to support management of Task records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This procedure is a subroutine called from pQuery#Execute. It provides the syntax for executing queries in support of Task
management. In order for query execution to synchronize with queries displayed on the user interface, the content of this procedure
and the query records created through sf.pSetup$SF#Query must be the same.

The @QueryCode value corresponds to the sf.Query.QueryCode column and is used for branching to the query to execute.  Any parameters
entered in the user interface for the query are stored as records in the @Parameters table and must be retrieved into local 
variables prior to execution.  Unless enforced as mandatory in the parameter definition, the parameter values can be null.
Zero-length strings detected in parameter values are converted to NULL's.  See also parent procedure.

Limitations
-----------
Although @MaxRows is passed as a parameter, a returned record limit is only enforced where "select top(@MaxRows)..." syntax is
implemented in the query.  If the enforcement of record limits has been turned off in the UI, the @MaxRows value has been set 
by the caller to a high value to avoid limiting the data set returned.

Example
-------
<TestHarness>
  <Test Name = "All" IsDefault ="true" Description="Executes the procedure to return all forms in a year selected at random">
    <SQLScript>
      <![CDATA[
declare
	@queryCode				varchar(30)	 = 'S!TASK.ALL'
 ,@parameters				dbo.Parameter

if not exists (select 1 from sf.Task)
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pQuery#Execute$Task
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
  <Test Name = "FindByPhone"  Description="Executes the procedure to search for a partial phone number selected at random">
    <SQLScript>
      <![CDATA[
declare
	@queryCode	 varchar(30) = 'S!TASK.FIND.BY.PHONE'
 ,@phoneNumber varchar(4)
 ,@parameters	 dbo.Parameter

select top (1)
	 @phoneNumber = substring(p.MobilePhone, 5, 4)
from
	sf.Person				 p
join
	sf.PersonTask pem on p.PersonSID = pem.PersonSID
where
	len(ltrim(rtrim(substring(p.MobilePhone, 5, 4)))) = 4
order by
	newid();

if @@rowcount = 0 or @phoneNumber is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	insert
		@parameters (ParameterID, ParameterValue, Label)
	values
	(N'PhoneNumber', @phoneNumber, 'Phone');

	exec dbo.pQuery#Execute$Task
		@QueryCode = @queryCode
	 ,@Parameters = @parameters
	 ,@MaxRows = 9999999

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
	 @ObjectName = 'dbo.pQuery#Execute$Task'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int							 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)																						-- message text (for business rule errors)   
	 ,@ON									bit							 = cast(1 as bit)													-- constant for bit comparisons = 1
	 ,@OFF								bit							 = cast(0 as bit)													-- constant for bit comparison = 0
	 ,@recentDateTime			datetimeoffset	 = sf.fRecentAccessCutOff()								-- oldest point considered within the recent access hours
	 ,@userName						nvarchar(75)		 = sf.fApplicationUserSession#UserName()	-- sf.ApplicationUser UserName for the current user
	 ,@applicationUserSID int																												-- application user key or current session
	 ,@startDate					date																											-- query parameter values retrieved for use in SELECTs:
	 ,@endDate						date
	 ,@followUpDate				date
	 ,@cutOffDate					date
	 ,@taskQueueSID				int
	 ,@isUnassigned				bit
	 ,@isOverDue					bit
	 ,@taskContextSID			int
	 ,@startDateTime			datetime
	 ,@endDateTime				datetime
	 ,@cutOffDateTime			datetime
	 ,@startDateDTO				datetimeoffset(7)
	 ,@endDateDTO					datetimeoffset(7)
	 ,@cutOffDateDTO			datetimeoffset(7)
	 ,@phoneNumber				varchar(25)
	 ,@streetAddress			nvarchar(75)
	 ,@citySID						int
	 ,@isUpdatedByMeOnly	bit;

	begin try

		-- retrieve parameter values

		-- SQL Prompt formatting off
		select @recentDateTime				= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'RecentDateTime';
		select @startDate							= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'StartDate';
		select @endDate								= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'EndDate';
		select @followUpDate					= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'FollowUpDate';
		select @cutOffDate						= cast(replace(p.ParameterValue, '-', '') as date)	from	@Parameters p	where	p.ParameterID = 'CutOffDate';
		select @isUnassigned					= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsUnAssigned';
		select @isOverDue							= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsOverDue';
		select @taskQueueSID					= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'TaskQueueSID';
		select @taskContextSID				= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'TaskContextSID';
		select @applicationUserSID		= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'AdminApplicationUserSID';
		select @phoneNumber						= cast(p.ParameterValue as varchar(25))							from	@Parameters p	where	p.ParameterID = 'PhoneNumber';
		select @streetAddress					= cast(p.ParameterValue as nvarchar(75))						from	@Parameters p	where	p.ParameterID = 'StreetAddress';
		select @citySID								= cast(p.ParameterValue as int)											from	@Parameters p	where	p.ParameterID = 'CitySID';
		select @isUpdatedByMeOnly			= cast(p.ParameterValue as bit)											from	@Parameters p	where	p.ParameterID = 'IsUpdatedByMeOnly';
		-- SQL Prompt formatting on

		-- store start/end dates entered on the UI as DTO's to 
		-- enable comparison with server times

		if @recentDateTime is not null
		begin
			set @recentDateTime = cast(convert(varchar(8), @recentDateTime, 112) + ' 23:59:59.99' as datetime);
		end;

		if @startDate is not null
		begin
			set @startDateTime = @startDate;
			set @startDateDTO = sf.fClientDateTimeToDTOffset(@startDateTime); -- convert to server time for comparison
		end;

		if @endDate is not null
		begin
			set @endDateTime = cast(convert(varchar(8), @endDate, 112) + ' 23:59:59.99' as datetime);
			set @endDateDTO = sf.fClientDateTimeToDTOffset(@endDateTime); -- set to end of day
		end;

		if @cutOffDate is not null
		begin
			set @cutOffDateTime = @cutOffDate;
		end;

		if @cutOffDateTime is not null
		begin
			set @cutOffDateDTO = sf.fClientDateTimeToDTOffset(@cutOffDateTime);
		end;

		-- validate for conflicting parameters

		if @startDate > @endDate
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'DateRangeReversed'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" must be before the "%2".'
			 ,@Arg1 = 'Start Date'
			 ,@Arg2 = 'End Date';

			raiserror(@errorText, 16, 1);

		end;

		if @applicationUserSID is not null and @isUnassigned = @ON
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ConflictingParameters'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" and "%2" criteria cannot both be applied.'
			 ,@Arg1 = 'Assigned Administrator'
			 ,@Arg2 = 'Unassigned';

			raiserror(@errorText, 16, 1);

		end;

		-- if a query was saved as a default that has no
		-- data values for it, default them here based on 
		-- the most recent week of task activity

		if @startDate is null or @endDate is null
		begin
			select @endDateDTO = max (t.CreateTime) from sf .Task t;
			set @endDate = sf.fDTOffsetToClientDate(@endDateDTO);
			set @startDateDTO = dateadd(day, -7, @endDateDTO);
			set @startDate = sf.fDTOffsetToClientDate(@startDateDTO);
		end;

		-- execute the query 

		if @QueryCode = 'S!TASK.ALL'
		begin

			select top (@MaxRows)
				ts.TaskSID
			from
				dbo.vTask#Search	ts
			left outer join
				dbo.vTask#Context tc on ts.TaskContextCode = tc.TaskContextCode
			where
				(ts.CreateTime between @startDateDTO and @endDateDTO)
				and (@taskQueueSID is null or ts.TaskQueueSID							= @taskQueueSID)
				and (@applicationUserSID is null or ts.ApplicationUserSID = @applicationUserSID)
				and (@isUnassigned																				= @OFF or ts.ApplicationUserSID is null)
				and (@taskContextSID is null or tc.TaskContextSID					= @taskContextSID)
				and (@isOverDue																						= @OFF or (ts.DaysDueOrLate < 0 and ts.ClosedTime is null))
			order by
				ts.TaskSID;

		end;
		else if @QueryCode = 'S!TASK.ALL.LATEST.WK'
		begin

			select @endDateDTO = max (t.CreateTime) from sf .Task t;
			set @startDateDTO = dateadd(day, -7, @endDateDTO);

			select top (@MaxRows)
				t.TaskSID
			from
				sf.Task t
			where
				(t.CreateTime between @startDateDTO and @endDateDTO)
			order by
				t.TaskSID;

		end;
		else if @QueryCode = 'S!TASK.MINE'
		begin

			set @applicationUserSID = sf.fApplicationUserSessionUserSID(); -- application user key of current session

			select top (@MaxRows)
				ts.TaskSID
			from
				dbo.vTask#Search ts
			where
				(
					ts.ApplicationUserSID											= @applicationUserSID or (ts.ApplicationUserSID is null and @isUnassigned = @ON)
				)
				and (@isOverDue															= @OFF or (ts.DaysDueOrLate < 0 and ts.ClosedTime is null))
				and (ts.ClosedTime is null or ts.ClosedTime >= @cutOffDateDTO)
			order by
				ts.TaskSID;

		end;
		else if @QueryCode = 'S!TASK.DUE'
		begin

			select top (@MaxRows)
				ts.TaskSID
			from
				dbo.vTask#Search	ts
			left outer join
				dbo.vTask#Context tc on ts.TaskContextCode = tc.TaskContextCode
			where
				(ts.NextFollowUpDate															<= @followUpDate or ts.DueDate <= @followUpDate)
				and (@taskQueueSID is null or ts.TaskQueueSID			= @taskQueueSID)
				and (@taskContextSID is null or tc.TaskContextSID = @taskContextSID)
			order by
				ts.TaskSID;

		end;
		else if @QueryCode = 'S!TASK.QUEUE'
		begin

			select top (@MaxRows)
				ts.TaskSID
			from
				dbo.vTask#Search ts
			where
				ts.TaskQueueSID															= @taskQueueSID
				and (@isUnassigned													= @OFF or @applicationUserSID is null)
				and (@isOverDue															= @OFF or (ts.DaysDueOrLate < 0 and ts.ClosedTime is null))
				and (ts.ClosedTime is null or ts.ClosedTime >= @cutOffDateDTO)
			order by
				ts.TaskSID;

		end;
		else if @QueryCode = 'S!TASK.ASSIGNED'
		begin

			select top (@MaxRows)
				t.TaskSID
			from
				sf.Task t
			where
				t.ApplicationUserSID = @applicationUserSID and (t.ClosedTime is null or t.ClosedTime >= @cutOffDateDTO)
			order by
				t.TaskSID;

		end;
		else if @QueryCode = 'S!TASK.UNASSIGNED'
		begin

			select top (@MaxRows)
				t.TaskSID
			from
				sf.Task t
			where
				(@taskQueueSID is null or t.TaskQueueSID = @taskQueueSID) and t.ApplicationUserSID is null
			order by
				t.TaskSID;

		end;
		else if @QueryCode = 'S!TASK.CANCELLED'
		begin

			select
				t.TaskSID
			from
				sf.Task				t
			join
				sf.TaskStatus ts on t.TaskStatusSID = ts.TaskStatusSID
			where
				ts.TaskStatusSCD = 'CANCELLED' and (t.UpdateTime between @startDateDTO and @endDateDTO);

		end;
		else if @QueryCode = 'S!TASK.CONTEXT'
		begin

			select
				ts.TaskSID
			from
				dbo.vTask#Search	ts
			left outer join
				dbo.vTask#Context tc on ts.TaskContextCode = tc.TaskContextCode
			where
				tc.TaskContextSID														= @taskContextSID
				and (@isOverDue															= @OFF or (ts.DaysDueOrLate < 0 and ts.ClosedTime is null))
				and (ts.ClosedTime is null or ts.ClosedTime >= @cutOffDateDTO);

		end;
		else if @QueryCode = 'S!TASK.RENEWAL'
		begin

			select
				ts.TaskSID
			from
				dbo.vTask#Search ts
			where
				ts.TaskContextCode																				= 'RENEWAL'
				and (@applicationUserSID is null or ts.ApplicationUserSID = @applicationUserSID)
				and (@isUnassigned																				= @OFF or ts.ApplicationUserSID is null)
				and (@isOverDue																						= @OFF or (ts.DaysDueOrLate < 0 and ts.ClosedTime is null))
				and (ts.ClosedTime is null or ts.ClosedTime								>= @cutOffDateDTO);

		end;
		else if @QueryCode = 'S!TASK.APPLICATION'
		begin

			select
				ts.TaskSID
			from
				dbo.vTask#Search ts
			where
				ts.TaskContextCode																				= 'APPLICATION'
				and (@applicationUserSID is null or ts.ApplicationUserSID = @applicationUserSID)
				and (@isUnassigned																				= @OFF or ts.ApplicationUserSID is null)
				and (@isOverDue																						= @OFF or (ts.DaysDueOrLate < 0 and ts.ClosedTime is null))
				and (ts.ClosedTime is null or ts.ClosedTime								>= @cutOffDateDTO);

		end;
		else if @QueryCode = 'S!TASK.REINSTATEMENT'
		begin

			select
				ts.TaskSID
			from
				dbo.vTask#Search ts
			where
				ts.TaskContextCode																				= 'REINSTATEMENT'
				and (@applicationUserSID is null or ts.ApplicationUserSID = @applicationUserSID)
				and (@isUnassigned																				= @OFF or ts.ApplicationUserSID is null)
				and (@isOverDue																						= @OFF or (ts.DaysDueOrLate < 0 and ts.ClosedTime is null))
				and (ts.ClosedTime is null or ts.ClosedTime								>= @cutOffDateDTO);

		end;
		else if @QueryCode = 'S!TASK.REG.CHANGE'
		begin

			select
				ts.TaskSID
			from
				dbo.vTask#Search ts
			where
				ts.TaskContextCode																				= 'REG.CHANGE'
				and (@applicationUserSID is null or ts.ApplicationUserSID = @applicationUserSID)
				and (@isUnassigned																				= @OFF or ts.ApplicationUserSID is null)
				and (@isOverDue																						= @OFF or (ts.DaysDueOrLate < 0 and ts.ClosedTime is null))
				and (ts.ClosedTime is null or ts.ClosedTime								>= @cutOffDateDTO);

		end;
		else if @QueryCode = 'S!TASK.PROFILE.UPDATE'
		begin

			select
				ts.TaskSID
			from
				dbo.vTask#Search ts
			where
				ts.TaskContextCode																				= 'PROFILE.UPDATE'
				and (@applicationUserSID is null or ts.ApplicationUserSID = @applicationUserSID)
				and (@isUnassigned																				= @OFF or ts.ApplicationUserSID is null)
				and (@isOverDue																						= @OFF or (ts.DaysDueOrLate < 0 and ts.ClosedTime is null))
				and (ts.ClosedTime is null or ts.ClosedTime								>= @cutOffDateDTO);

		end;
		else if @QueryCode = 'S!TASK.LEARNING.PLAN'
		begin

			select
				ts.TaskSID
			from
				dbo.vTask#Search ts
			where
				ts.TaskContextCode																				= 'LEARNING.PLAN'
				and (@applicationUserSID is null or ts.ApplicationUserSID = @applicationUserSID)
				and (@isUnassigned																				= @OFF or ts.ApplicationUserSID is null)
				and (@isOverDue																						= @OFF or (ts.DaysDueOrLate < 0 and ts.ClosedTime is null))
				and (ts.ClosedTime is null or ts.ClosedTime								>= @cutOffDateDTO);

		end;
		else if @QueryCode = 'S!TASK.AUDIT'
		begin

			select
				ts.TaskSID
			from
				dbo.vTask#Search ts
			where
				ts.TaskContextCode																				= 'AUDIT'
				and (@applicationUserSID is null or ts.ApplicationUserSID = @applicationUserSID)
				and (@isUnassigned																				= @OFF or ts.ApplicationUserSID is null)
				and (@isOverDue																						= @OFF or (ts.DaysDueOrLate < 0 and ts.ClosedTime is null))
				and (ts.ClosedTime is null or ts.ClosedTime								>= @cutOffDateDTO);

		end;
		else if @QueryCode = 'S!TASK.FIND.BY.PHONE'
		begin

			select distinct
				ts.TaskSID
			from
			(
				select distinct
					p.PersonSID
				from
					sf.Person p
				where
					p.HomePhone like '%' + @phoneNumber + '%' or p.MobilePhone like '%' + @phoneNumber + '%'
			)									 x
			join
				dbo.vTask#Search ts on x.PersonSID = ts.PersonSID;

		end;
		else if @QueryCode = 'S!TASK.FIND.BY.ADDRESS'
		begin

			if @streetAddress is null and @citySID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'NoSearchParameters'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'No search criteria was provided. Enter at least one value.';

				raiserror(@errorText, 16, 1);
			end;

			select distinct
				ts.TaskSID
			from
			(
				select distinct
					pma.PersonSID
				from
					dbo.PersonMailingAddress pma
				where
					(
						@streetAddress is null
						or pma.StreetAddress1 like '%' + @streetAddress + '%'
						or pma.StreetAddress2 like '%' + @streetAddress + '%'
						or pma.StreetAddress3 like '%' + @streetAddress + '%'
					)
					and (@citySID is null or pma.CitySID = @citySID)
			)									 x
			join
				dbo.vTask#Search ts on x.PersonSID = ts.PersonSID;

		end;
		else if @QueryCode = 'S!TASK.RECENTLY.UPDATED'
		begin

			select
				t.TaskSID
			from
				sf.Task t
			where
				t.UpdateTime >= @recentDateTime and (@isUpdatedByMeOnly = @OFF or t.UpdateUser = @userName);

		end;
		else
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'Query'
			 ,@Arg2 = @QueryCode;

			raiserror(@errorText, 18, 1);

		end;

	end try
	begin catch
		set noexec off;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
