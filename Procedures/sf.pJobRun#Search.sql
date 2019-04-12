SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pJobRun#Search]
   @SearchString					nvarchar(150)	= null    -- name string to search, "last, first middle" or partial or patient ID
	,@JobSID								int						= null    -- search filter: job runs belonging to the specified job
	,@StartDate							date					= null    -- search filter: job runs >= StartDate
	,@SearchTraceLog				bit						=	0				-- search filter: include trace log in string search
  ,@QuerySID							int						= null    -- dynamic query: SID of sf.Query row providing SQL syntax to execute
	,@QueryParameters				xml						= null		-- dynamic query: list of query parameters associated with the query SID
  ,@Identifiers						xml						= null    -- quick search: list of pinned records to return (xml contains SID's)
  ,@LastJobRuns						bit						= 0       -- quick search: only the most recent JobRun for each active Job (should be default on UI)
  ,@UnclearedErrors				bit						= 0       -- quick search: only JobRun entities that haven't had errors cleared
	,@JobRunSID							int						= null    -- quick search: returns a specific JobRun based on system ID
as
/*********************************************************************************************************************************
Procedure : Job Run Search
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Searches the JobRun entity for the search string and search options provided
History   : Author(s)   | Month Year  | Change Summary
          : ------------|-------------|-------------------------------------------------------------------------------------------
          : Kris Dawson | Jun 2013    | Initial version
					: Tyson Schulz| Nov 2014		| Add base select limit to take configuration parameter "MaxRowsOnSearch" into account.
																				Create test harness.

Comments
--------
This procedure executes various types of searches against the sf.JobRun entity.


Text search
-----------
The search string is applied as a search against the result message.

When the @SearchTraceLog bit is ON the text content of TraceLog is searched as well and related job runs returned.

Wildcard characters: *, %, ?, _ are allowed within string searches.

@JobSID filters text results
----------------------------------
The @JobSID is considered on text searches so that if it is passed in only job runs for the specified job will be
returned by the text search

@StartDate filters text results
----------------------------------
The @StartDate is considered on text searches so that if it is passed in only job runs that have a start date greater than
or equal to the provided date will be returned by the text search

Dynamic queries
---------------
When the @QuerySID parameter is passed as not null, then a dynamic query is executed.  The query syntax is retrieved from
sf.Query and executed through a subroutine. This feature supports configuration-specific (custom) queries to be added
to the installation.  See sf.pQuery#Search for additional details.

Pinned record search
--------------------
The @Identifiers parameter returns "pinned" records.  The user can pin records through the user interface and then retrieve
them afterward through this search.  The system ID's of the pinned records are assembled into an XML value and passed to
this routine which parses the XML and joins on the key value to the entity record. This is a quick search that does not
consider any other criteria.

@JobRunSID	 search ("SID: 12345")
---------------------------------
This is a search on the primary key of the entity.  It can be invoked by passing the parameter directly, or by entering the
keyword "SID:" followed by a number into the @SearchString - e.g. "SID:1234567". The digits are stripped from the string and
converted into the parameter value by the procedure.  The conversion only takes place if all values following "SID:" are digits
(or spaces).  By allowing system ID's to the be entered into search string, administrators and configurators are able to
trouble shoot error messages that return SID's using the application's user interface.

@LastJobRuns
------------
This quick search will return the last job run for each job in the system

@UnclearedErrors
-------------
This quick search will return all job runs that have errors that have not been cleared

Sort order
----------
This procedure orders all results by the "JobLabel" of the job associated with the job run.

Result limiting
---------------
This procedure will only return the maximum amount of rows to return as configured in the "MaxRowsOnSearch". When an open search
is called, then the only the amount of rows configured in the "MaxRowsForAutoSearch" will be returned.

Use of Memory Table
-------------------
The application standard for entity search procedures is to implement branch logic to execute a SELECT statement for each
search scenario. The initial SELECT then populates a memory table with the primary key value of the entity - in this case
the ProviderSID. The memory table keys are then joined to the entity view to return the data set at the end of the case
logic.  This technique, while slightly less efficient than direct selects against the entity view in some cases, reduces
code volume substantially since the columns from the entity only need be included once. A second advantage is that it allows
some JOIN and WHERE logic to be performed against tables rather than the entity view; which itself may be quite complex. This
leads to improved performance in some cases.  The final SELECT is a simple join against primary key values so performance is
the fastest possible on the entity view.

Example:
--------

<TestHarness>
  <Test Name = "SID" IsDefault ="true" Description="Finds a job by JobRunSID">
    <SQLScript>
      <![CDATA[
				
				declare
				@JobRunSID      int

			select top (1)
				@JobRunSID = jr.JobRunSID
			from
				sf.JobRun jr
			order by
				newid()

			if @@ROWCOUNT <= 0
			begin
				
				select 'no ran jobs found'

			end
			else
			begin

				exec sf.pJobRun#Search
					@JobRunSID = @JobRunSID

			end

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "Query" IsDefault ="false" Description="Finds jobs by query execution">
    <SQLScript>
      <![CDATA[
				
				declare
					@querySID      int

				select top (1)
					@querySID = q.QuerySID
				from
					sf.vQuery q
				where
					q.ApplicationEntitySCD = 'sf.JobRun'
				and
					q.QueryParameters is null
				order by
					newid()

				if @@ROWCOUNT <= 0
				begin
				
					select 'no queries available'

				end
				else
				begin

					declare
						@test	table
					(
						EntitySID int
					)

					insert
						@test
					exec sf.pQuery#Execute
						@QuerySID

					if(select count(1) from @test) > 0
					begin
	
						exec sf.pJobRun#Search
							@QuerySID = @querySID

					end
					else
					begin

						select 'query did not find any records'

					end

				end

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "LastRanJob" IsDefault ="false" Description="Finds the last job ran">
    <SQLScript>
      <![CDATA[

			if (select
						count(1)
					from
						sf.vJobRun
					where
						JobStatusSCD = 'COMPLETE') <= 0
			begin
				
				select 'no jobs have been ran and completed before'

			end
			else
			begin

				exec sf.pJobRun#Search
					@LastJobRuns = 1

			end

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "UnclearedErrors" IsDefault ="false" Description="Finds jobs that encountered errors, and not had them cleared">
    <SQLScript>
      <![CDATA[

			if (select
						count(1)
					from
						sf.JobRun
					where
						IsFailed = cast(1 as bit)
					and
						IsFailureCleared = cast(0 as bit)) <= 0
			begin
				
				select 'no jobs have failed and had errors cleared before'

			end
			else
			begin

				exec sf.pJobRun#Search
					@UnclearedErrors = 1

			end

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "MessageSearch" IsDefault ="false" Description="Finds jobs that have the searchstring in either the ResultMessage or Tracelog fields">
    <SQLScript>
      <![CDATA[

			declare
				@randomJob nvarchar(150)
				,@randomJobPartial nvarchar(150)

			select top (1)
				@randomJob = jr.ResultMessage
			from
				sf.JobRun jr
			order by
				newid()

			set @randomJobPartial = substring(@randomJob, 2,5)

			exec sf.pJobRun#Search
				@SearchString = @randomJobPartial

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "SearchOnJob" IsDefault ="false" Description="Find jobs ran with message or tracelog on a specific job type">
    <SQLScript>
      <![CDATA[

			declare
				 @JobSID int
				,@randomJob nvarchar(150)
				,@randomJobPartial nvarchar(150)

			select top (1)
				@JobSID = j.JobSID
			from
				sf.Job j
			join
				sf.JobRun jr on j.JobSID = jr.JobSID
			where
				j.IsActive = cast(1 as bit)
			group by
				j.JobSID
			having
				count(jr.JobRunSID) > 0
			order by
				newid()

			select top (1)
				@randomJob = jr.ResultMessage
			from
				sf.JobRun jr
			where
				jr.JobSID = @JobSID
			order by
				newid()

			set @randomJobPartial = substring(@randomJob, 2,5)
	
			exec sf.pJobRun#Search
				@SearchString  = @randomJobPartial
				,@JobSID        = @JobSID

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "SearchOnTime" IsDefault ="false" Description="Find jobs ran with message starting by the time supplied to now">
    <SQLScript>
      <![CDATA[

			declare
				 @randomJob					nvarchar(150)
				,@randomJobPartial	nvarchar(150)
				,@StartDate					Datetime			= GetDate() -7

			select top (1)
				@randomJob = jr.ResultMessage
			from
				sf.JobRun jr
			where
				jr.StartTime >= isnull(sf.fClientDateToDTOffset(GetDate() -7), jr.StartTime)
			order by
				newid()

			set @randomJobPartial = substring(@randomJob, 2,5)

			exec sf.pJobRun#Search
			@SearchString  = @randomJobPartial
			,@StartDate = @StartDate

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pJobRun#Search'


-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
begin
  declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)
    ,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
    ,@OFF         bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
    ,@searchType                      varchar(25)                         -- type of search; returned with entity for debugging
    ,@maxRows                         int																	-- maximum rows allowed on search
		,@maxAutoRows											int																	-- maximum rows allowed on open search
    ,@lastName                        nvarchar(35)                        -- for name searches, buffer for each name part:
    ,@firstName                       nvarchar(30)
    ,@middleNames											nvarchar(30)
    ,@caseCompletionTargetDays        decimal(6,1)                        -- threshold for cases to be considered overdue
    ,@nullDatePlaceholder             date                                -- used as replacement for nullable date comparisons
		,@applicationUserSID							int																	-- reference to the current user
		,@recordCount											int																	-- in order to open search table, need to ensure record count is less than config param('MaxRowsForAutoSearch')

  begin try

    declare
      @selected                       table                               -- stores results of query - SID only
      (
         ID                           int identity(1, 1)  not null        -- identity to track add order - preserves custom sorts
        ,EntitySID                    int                 not null        -- record ID joined to main entity to return results
      )

		set @SearchString = ltrim(rtrim(@SearchString))												-- remove leading and trailing spaces from character type columns

    -- retrieve max rows for string searches and set other defaults

    set @maxRows      = cast(isnull(sf.fConfigParam#Value('MaxRowsOnSearch'), '100')  as int)
		set @maxAutoRows	= cast(isnull(sf.fConfigParam#Value('MaxRowsForAutoSearch'),	'20')	as int)

		-- get a count of records in the base table. If the user is attempting
		-- to perform an open search, the results will only return if the count
		-- in the table is less than the config param('MaxRowsForAutoSearch')

		select
			@recordCount = count(1)
		from
			sf.JobRun jr
		where
			jr.JobSID = isnull(@JobSID, jr.JobSID)
		and
			jr.StartTime >= isnull(sf.fClientDateToDTOffset(@StartDate), jr.StartTime)

		-- if SID is provided in search string, parse it out and set parameter
		-- value (ensure it is all digits before attempting cast)

		if left(ltrim(@SearchString), 4) = N'SID:' and sf.fIsStringContentValid(replace(replace(@SearchString, N'SID:', ''), ' ', ''), N'0123456789' ) = @ON
		begin
			set @JobRunSID	= cast(replace(replace(@SearchString, N'SID:', ''), ' ', '') as int)
		end

    -- execute the searches

    if @QuerySID is not null                                              -- dynamic query search
    begin

      set @searchType   = 'Query'

      insert
        @selected
      (
        EntitySID
      )
      exec sf.pQuery#Execute
          @QuerySID         = @QuerySID
				 ,@QueryParameters	= @QueryParameters

    end
    else if @Identifiers is not null                                      -- set of specific SIDs passed  (pinned records)
    begin

      set @searchType   = 'Identifiers'

      insert
        @selected
      (
        EntitySID
      )
      select                                                              -- no "TOP" limit on quick searches
        jr.JobRunSID
      from
        sf.JobRun jr
      join
        @Identifiers.nodes('/Identifiers/SID') as Identifiers(ID)
       on
        jr.JobRunSID  = Identifiers.ID.value('.','int')                   -- join to XML document on the SID to apply filtering

    end
    else if @JobRunSID is not null                                       -- specific SID passed  (1 record)
    begin

      set @searchType   = 'SID'

      insert
        @selected
      (
        EntitySID
)
      select
        jr.JobRunSID
      from
        sf.JobRun jr
      where
        jr.JobRunSID = @jobRunSID

      if @@rowcount = 0                                                   -- perform the search to validate the value passed in
      begin

        exec sf.pMessage#Get
           @MessageSCD  = 'RecordNotFound'
          ,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
          ,@Arg1        = 'Episode'
          ,@Arg2        = @JobRunSID

        raiserror(@errorText, 18, 1)
      end

    end
    else if @LastJobRuns = @ON
    begin

      set @searchType = 'LastJobRuns'

			insert
				@selected
			(
				EntitySID
			)
			select
				max(jr.JobRunSID)
			from
				sf.JobRun jr
			group by
				jr.JobSID				

    end
    else if @UnclearedErrors = @ON
    begin

      set @searchType = 'UnclearedErrors'

      insert
        @selected
			(
				EntitySID
			)
      select
         jr.JobRunSID
      from
        sf.JobRun			jr
      where
        jr.IsFailed = @ON
      and
        jr.IsFailureCleared = @OFF

    end
    else if @SearchString is not null
    begin

			if @SearchString = ''																								-- open search is only allowed to return the auto select limit
			and
				@recordCount <= @maxAutoRows
			begin
				
				set @maxRows = @maxAutoRows

				insert
					@selected
				(
					EntitySID
				)
				select
					jr.JobRunSID
				from
					sf.JobRun jr
				where
					jr.JobSID = isnull(@JobSID, jr.JobSID)
				and
					jr.StartTime >= isnull(sf.fClientDateToDTOffset(@StartDate), jr.StartTime)

			end
			else if @SearchString <> ''
			begin

				set @searchType   = 'JobRuns'

				set @SearchString = sf.fSearchString#Format(@SearchString)

				if left(@SearchString, 1) <> N'%' set @SearchString = cast(N'%' + @SearchString as nvarchar(150))

				insert
					@selected
				(
					EntitySID
				)
				select
					 jr.JobRunSID
				from
					sf.JobRun jr
				where
					(
						isnull(jr.ResultMessage, N'~!#') like @SearchString
						or
						(
							@SearchTraceLog = @ON
							and
							isnull(jr.TraceLog, N'~!#') like @SearchString
						)
					)
				and
					jr.JobSID = isnull(@JobSID, jr.JobSID)
				and
					jr.StartTime >= isnull(sf.fClientDateToDTOffset(@StartDate), jr.StartTime)

			end

    end
    else
    begin

      exec sf.pMessage#Get
         @MessageSCD    = 'SearchOptionSetNotValid'
        ,@MessageText   = @errorText output
        ,@DefaultText   = N'A recognized search option set was not selected.  You must either enter search text, click a quick search button, or select a query from the drop down.'

      raiserror(@errorText, 18, 1)

    end

    -- return all columns from the entity for key values stored into the memory table
		-- the same sort order is used by all searches so apply it to the dataset here
    -- (this allows queries above to avoid selecting against the entity in some cases)

    select top(@maxRows)																									-- return the entity for selected key values
      --!<ColumnList DataSource="sf.vJobRun" Alias="e">
       e.JobRunSID
      ,e.JobSID
      ,e.ConversationHandle
      ,e.CallSyntax
      ,e.StartTime
      ,e.EndTime
      ,e.TotalRecords
      ,e.TotalErrors
      ,e.RecordsProcessed
      ,e.CurrentProcessLabel
      ,e.IsFailed
      ,e.IsFailureCleared
      ,e.CancellationRequestTime
      ,e.IsCancelled
      ,e.ResultMessage
      ,e.TraceLog
      ,e.UserDefinedColumns
      ,e.JobRunXID
      ,e.LegacyKey
      ,e.IsDeleted
      ,e.CreateUser
      ,e.CreateTime
      ,e.UpdateUser
      ,e.UpdateTime
      ,e.RowGUID
      ,e.RowStamp
      ,e.JobSCD
      ,e.JobLabel
      ,e.IsCancelEnabled
      ,e.IsParallelEnabled
      ,e.IsFullTraceEnabled
      ,e.IsAlertOnSuccessEnabled
      ,e.JobScheduleSID
      ,e.JobScheduleSequence
      ,e.IsRunAfterPredecessorsOnly
      ,e.MaxErrorRate
      ,e.MaxRetriesOnFailure
      ,e.JobIsActive
      ,e.JobRowGUID
      ,e.IsDeleteEnabled
      ,e.IsReselected
      ,e.IsNullApplied
      ,e.zContext
      ,e.JobStatusSCD
      ,e.JobStatusLabel
      ,e.RecordsPerMinute
      ,e.RecordsRemaining
      ,e.EstimatedMinutesRemaining
      ,e.EstimatedEndTime
      ,e.DurationMinutes
      ,e.StartTimeClientTZ
      ,e.EndTimeClientTZ
      ,e.CancellationRequestTimeClientTZ
      --!</ColumnList>
      ,@searchType            SearchType                                  -- added to support debugging (ignored by UI)
    from
      sf.vJobRun  e
    join
      @selected      x on e.JobRunSID = x.EntitySID
    order by
      e.JobLabel

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
