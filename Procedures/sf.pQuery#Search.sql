SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pQuery#Search]
   @SearchString							nvarchar(150) = null	-- name string to search against the QueryLabel
  ,@DynamicQuerySID           int           = null	-- dynamic query: SID of sf.Query row providing SQL syntax to execute
	,@DynamicQueryParameters		xml						= null	-- dynamic query: list of query parameters associated with the query SID
  ,@Identifiers								xml           = null	-- quick search: list of pinned records to return (xml contains SID's)
  ,@QuerySID									int           = null	-- quick search: returns a specific State/Province based on system ID
	,@QueryCategorySID					int						= null	-- quick search: returns Queries with assignments to the category
  ,@ApplicationEntitySID			int           = null	-- quick search: returns Queries with assignments to the application entity
as
/*********************************************************************************************************************************
Procedure : State/Province Search
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Searches the Query entity for the search string and search options provided
History   : Author(s)   | Month Year  | Change Summary
          : ------------|-------------|-------------------------------------------------------------------------------------------
          : Art Lucas		| Jul 2011		| Initial version
					: Tim Edlund	| Mar	2013    | Updated to current standard for search procedures.  Moved entity search to quick search.
																				Added quick search by query category.
					: Relan C.		| May 2013    | Add parameter support for custom query searches
					: Tyson Schulz| Dec 2014		| Add base select limit to take configuration parameter "MaxRowsOnSearch" into account.
																				Modify test harness for successful output.

Comments
--------
This procedure executes various types of searches against the sf.Query entity.

Text search
-----------
The search is performed against the query label and tool tip columns.   A substring search is performed so rows matching any part
of the search string are returned. Wildcard characters: *, %, ?, _ are allowed within string searches.  For example, if the user
enters "%in use" then "Countries in use" and "State/Provinces in use" are returned.  If "in" is entered on its own, those same
queries (and possibly others) are returned since the procedure puts wildcards on both ends of the string if not already provided.

Dynamic queries
---------------
When the @DynamicQuerySID parameter is passed as not null, then a dynamic query is executed.  The query syntax is retrieved from
sf.Query and executed through a subroutine. This feature supports configuration-specific (custom) queries to be added
to the installation.  See sf.pQuery#Search for additional details.

Pinned record search
--------------------
The @Identifiers parameter returns "pinned" records.  The user can pin records through the user interface and then retrieve
them afterward through this search.  The system ID's of the pinned records are assembled into an XML value and passed to
this routine which parses the XML and joins on the key value to the entity record. This is a quick search that does not
consider any other criteria.

@QuerySID search ("SID: 12345")
---------------------------------------
This is a search on the primary key of the entity.  It can be invoked by passing the parameter directly, or by entering the
keyword "SID:" followed by a number into the @SearchString - e.g. "SID:1234567". The digits are stripped from the string and
converted into the parameter value by the procedure.  The conversion only takes place if all values following "SID:" are digits
(or spaces).  By allowing system ID's to the be entered into search string, administrators and configurators are able to
trouble shoot error messages that return SID's using the application's user interface.

Other quick searches
--------------------
The @ApplicationEntitySID is represented as drop-down in the search UI.  When a value is provided, the queries returned are
limited to those which are assigned to the given application entity.  A similar drop-down and process is applied to the
@QueryCategorySID parameter.

Quick searches do not combine with any other criteria.

Sort order
----------
This procedure orders all results by the Query label.

Result limiting
---------------
This procedure will only return the maximum amount of rows to return as configured in the "MaxRowsOnSearch". When an open search
is called, then the only the amount of rows configured in the "MaxRowsForAutoSearch" will be returned.

Use of Memory Table
-------------------
The application standard for entity search procedures is to implement branch logic to execute a SELECT statement for each
search scenario. The initial SELECT then populates a memory table with the primary key value of the entity - in this case
the QuerySID. The memory table keys are then joined to the entity view to return the data set at the end of the case
logic.  This technique, while slightly less efficient than direct selects against the entity view in some cases, reduces
code volume substantially since the columns from the entity only need be included once. A second advantage is that it allows
some JOIN and WHERE logic to be performed against tables rather than the entity view; which itself may be quite complex. This
leads to improved performance in some cases.  The final SELECT is a simple join against primary key values so performance is
the fastest possible on the entity view.

Example:
--------

<TestHarness>
  <Test Name = "SIDSearch" IsDefault ="true" Description="Finds the query with the corresponding QuerySID">
    <SQLScript>
      <![CDATA[

				declare
					@querySID    int

				select top (1)
					@querySID = q.QuerySID
				from
					sf.Query q
				order by
					newid()

				if @@ROWCOUNT = 0
				begin

					select 'no queries was found.'

				end
				else
				begin

					exec sf.pQuery#Search
						@QuerySID = @querySID

				end

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "FullName" IsDefault ="false" Description="Finds a query by searching by a name.">
    <SQLScript>
      <![CDATA[

				declare @searchstring nvarchar(150)

				select top (1)
					@searchstring = QueryLabel
				from
					sf.Query q
				where
					q.QueryParameters is null
				order by
					newid()

				if @@rowcount <= 0
				begin
				
					select 'no queries found'

				end
				else
				begin
				
					exec sf.pQuery#Search
						@SearchString = @searchstring

				end

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "PartialName" IsDefault ="false" Description="Finds a query by searching by a partial name.">
    <SQLScript>
      <![CDATA[

				declare
					 @randomQuery nvarchar(150)
					,@randomQueryPartial nvarchar(150)

				select top (1)
					@randomQuery = QueryLabel
				from
					sf.Query q
				where
					q.QueryParameters is null
				order by
					newid()

				if @@rowcount <= 0
				begin
				
					select 'no queries found'

				end
				else
				begin

					select @randomQueryPartial = substring(@randomQuery, 2, 5)
				
					exec sf.pQuery#Search
						@SearchString = @randomQueryPartial

				end

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "Wildcard" IsDefault ="false" Description="Finds a query by searching by a partial name.">
    <SQLScript>
      <![CDATA[

				declare
					 @randomQuery nvarchar(150)
					,@randomQueryPartial nvarchar(150)

				select top (1)
					@randomQuery = QueryLabel
				from
					sf.Query q
				where
					q.QueryParameters is null
				order by
					newid()

				if @@rowcount <= 0
				begin
				
					select 'no queries found'

				end
				else
				begin

					select @randomQueryPartial = substring(@randomQuery, 2, 5)

					select @randomQueryPartial = replace(@randomQueryPartial, substring(@randomQueryPartial,2,1), '_')
				
					exec sf.pQuery#Search
						@SearchString = @randomQueryPartial

				end

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "QuerySearch" IsDefault ="false" Description="Finds queries by executing a query.">
    <SQLScript>
      <![CDATA[

				declare
					@querySID      int

				select top (1)
					@querySID = q.QuerySID
				from
					sf.vQuery q
				where
					q.ApplicationEntitySCD = 'sf.Query'
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
	
						exec sf.pQuery#Search
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
      <Assertion Type="ExecutionTime" Value="00:00:10" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "OpenSearch" IsDefault ="false" Description="Finds all queries available, unless too many queries exist.">
    <SQLScript>
      <![CDATA[

				exec sf.pQuery#Search
					@SearchString = ''

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pQuery#Search'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

  declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)
    ,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
    ,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
    ,@searchType                      varchar(25)                         -- type of search; returned with entity for debugging
    ,@maxRows                         int                                 -- maximum rows allowed on search
		,@maxAutoRows											int																	-- max rows allowed to be queried through open search
		,@recordCount											int																	-- in order to open search table, need to ensure record count is less than config param('MaxRowsForAutoSearch')

  begin try

    declare
      @selected                         table                             -- stores results of query - SID only
      (
         ID                             int identity(1, 1)  not null      -- identity to track add order - preserves custom sorts
        ,EntitySID                      int                 not null      -- record ID joined to main entity to return results
      )

    -- retrieve max rows for string searches and set other defaults

    set @maxRows      = cast(isnull(sf.fConfigParam#Value('MaxRowsOnSearch'), '100')  as int)
		set @maxAutoRows	= cast(isnull(sf.fConfigParam#Value('MaxRowsForAutoSearch'),	'20')	as int)

		-- get a count of records in the base table. If the user is attempting
		-- to perform an open search, the results will only return if the count
		-- in the table is less than the config param('MaxRowsForAutoSearch')

		select
			@recordCount = count(1)
		from
			sf.Query

		-- if SID is provided in search string, parse it out and set parameter
		-- value (ensure it is all digits before attempting cast)

		if left(ltrim(@SearchString), 4) = N'SID:' and sf.fIsStringContentValid(replace(replace(@SearchString, N'SID:', ''), ' ', ''), N'0123456789' ) = @ON
		begin

			set @DynamicQuerySID	= cast(replace(replace(@SearchString, N'SID:', ''), ' ', '') as int)

		end

    -- execute the searches

    if @DynamicQuerySID is not null																				-- dynamic query search
    begin

      set @searchType   = 'Query'

      insert
        @selected
      (
        EntitySID
      )
			exec sf.pQuery#Execute
				 @QuerySID = @DynamicQuerySID
				,@QueryParameters = @DynamicQueryParameters

    end
    else if @Identifiers is not null																			-- set of specific SIDs passed  (pinned records)
    begin

      set @searchType   = 'Identifiers'

      insert
        @selected
      (
        EntitySID
      )
      select																															-- no "TOP" limit on quick searches
        q.QuerySID
      from
        sf.Query q
      join
        @Identifiers.nodes('/Identifiers/SID') as Identifiers(ID)
        on
        q.QuerySID  = Identifiers.ID.value('.','int')											-- join to XML document on the SID to apply filtering

    end
    else if @QuerySID is not null																					-- specific SID passed  (1 record)
    begin

      set @searchType   = 'SID'

      insert
        @selected
      (
        EntitySID
      )
      select
        q.QuerySID
      from
        sf.Query q
      where
        q.QuerySID = @QuerySID

      if @@rowcount = 0
      begin

        exec sf.pMessage#Get
           @MessageSCD  = 'RecordNotFound'
          ,@MessageText = @errorText output
          ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
          ,@Arg1        = 'State/Province'
          ,@Arg2        = @QuerySID

        raiserror(@errorText, 18, 1)

      end

    end
    else if @QueryCategorySID is not null
    begin

      set @searchType = 'QueryCategory'

      insert
        @selected
      (
        EntitySID
      )
      select distinct
         q.QuerySID
      from
				sf.QueryCategory ae
			join
        sf.Query q on ae.QueryCategorySID = q.QueryCategorySID
      where
        ae.QueryCategorySID = @QueryCategorySID

    end
    else if @ApplicationEntitySID is not null
    begin

      set @searchType = 'ApplicationEntity'

      insert
        @selected
      (
        EntitySID
      )
      select distinct
         q.QuerySID
      from
				sf.ApplicationPage ap
			join
        sf.Query q on ap.ApplicationPageSID = q.ApplicationPageSID
      where
        ap.ApplicationEntitySID = @ApplicationEntitySID

    end
    else if @SearchString is not null
    begin

      set @searchType = 'QueryLabel'

			if @SearchString = ''
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
					 q.QuerySID
				from
					sf.Query q

			end
			else if @SearchString <> ''
			begin

				set @SearchString = sf.fSearchString#Format(@SearchString)        -- format search string and add leading % if not there

				if left(@SearchString,1) <> '%'
				begin

					set @SearchString = cast(N'%' + @SearchString as nvarchar(150))

				end

				insert
					@selected
				(
					EntitySID
				)
				select
					 q.QuerySID
				from
					sf.Query q
				where
					q.QueryLabel like @SearchString																	-- search against name and tool-tip
				or
					isnull(q.ToolTip, '~!@#') like @SearchString
				
			end

    end
    else
    begin

      exec sf.pMessage#Get
         @MessageSCD    = 'SearchOptionSetNotValid'
        ,@MessageText   = @errorText output
        ,@DefaultText   = N'A recognized search option set was not selected.  You must either enter search text, click a quick search button, or select a query from the drop down.'

      raiserror(@errorText, 16, 1)

    end

    -- return all columns from the entity joined to the PK value from the memory table
    -- the XML column is excluded with the tag so that it's content can be returned
    -- from the variable

    select top(@maxRows)																									-- return the entity for selected key values
      --!<ColumnList DataSource="sf.vQuery" Alias="q">
       q.QuerySID
      ,q.QueryCategorySID
      ,q.ApplicationPageSID
      ,q.QueryLabel
      ,q.ToolTip
      ,q.LastExecuteTime
      ,q.LastExecuteUser
      ,q.ExecuteCount
      ,q.QuerySQL
      ,q.QueryParameters
      ,q.QueryCode
      ,q.IsActive
      ,q.IsApplicationPageDefault
      ,q.UserDefinedColumns
      ,q.QueryXID
      ,q.LegacyKey
      ,q.IsDeleted
      ,q.CreateUser
      ,q.CreateTime
      ,q.UpdateUser
      ,q.UpdateTime
      ,q.RowGUID
      ,q.RowStamp
      ,q.ApplicationPageLabel
      ,q.ApplicationPageURI
      ,q.ApplicationRoute
      ,q.IsSearchPage
      ,q.ApplicationEntitySID
      ,q.ApplicationPageRowGUID
      ,q.QueryCategoryLabel
      ,q.QueryCategoryCode
      ,q.DisplayOrder
      ,q.QueryCategoryIsActive
      ,q.QueryCategoryIsDefault
      ,q.QueryCategoryRowGUID
      ,q.IsDeleteEnabled
      ,q.IsReselected
      ,q.IsNullApplied
      ,q.zContext
      ,q.ApplicationEntitySCD
      ,q.ApplicationEntityName
        --!</ColumnList>
      ,@searchType                SearchType                              -- added to support debugging (ignored by UI)
    from
      sf.vQuery   q
    join
      @selected   x on q.QuerySID = x.EntitySID
    order by
      q.QueryLabel

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
