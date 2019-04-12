SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pConfigParam#Search]
   @SearchString        nvarchar(150)     = null    -- name string to search against ConfigParam name
  ,@QuerySID            int               = null    -- dynamic query: SID of sf.Query row providing SQL syntax to execute
	,@QueryParameters			xml								= null		-- dynamic query: list of query parameters associated with the query SID
  ,@Identifiers         xml               = null    -- quick search: list of pinned records to return (xml contains SID's)
  ,@ConfigParamSID			int								= null		-- quick search: returns a specific Configuration Parameter based on system ID
as
/*********************************************************************************************************************************
Procedure : ConfigParam Search
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Searches the Configuration Parameter entity for the search string and search options provided
History   : Author(s)   | Month Year  | Change Summary
          : ------------|-------------|-----------------------------------------------------------------------------------------
          : Cory Ng		  | Dec 2012    | Initial version
					: Relan C.		| May 2013    | Add parameter support for custom query searches
					: Tyson Schulz| Dec 2014		| Add base select limit to take configuration parameter "MaxRowsOnSearch" into account.
																				Create test harness.
					: Kevin Lau		|	June 2015		| Change specifications to not return objects with maxlength of 8192 (vs > 4k)
Comments
--------
This procedure executes various types of searches against the sf.ConfigParam entity.

Text search
-----------
The search string is applied as a search against the Configuration Parameter name. A substring search is performed so rows
matching any part of the search string are returned.

Wildcard characters: *, %, ?, _ are allowed within string searches.

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

@ConfigParamSID
----------------
When a @ConfigParamSID is provided, a single record is returned. If the SID is not found, an error is raised.

Sort order
----------
This procedure orders all results by the Configuration Parameter name.

Result limiting
---------------
This procedure will only return the maximum amount of rows to return as configured in the "MaxRowsOnSearch". When an open search
is called, then the only the amount of rows configured in the "MaxRowsForAutoSearch" will be returned.

Use of Memory Table
-------------------
The application standard for entity search procedures is to implement branch logic to execute a SELECT statement for each
search scenario. The initial SELECT then populates a memory table with the primary key value of the entity. The memory table keys
are then joined to the entity view to return the data set at the end of the case logic.  This technique, while slightly less
efficient than direct selects against the entity view in some cases, reduces code volume substantially since the columns from the
entity only need be included once. A second advantage is that it allows some JOIN and WHERE logic to be performed against tables
rather than the entity view; which itself may be quite complex. This leads to improved performance in some cases.  The final
SELECT is a simple join against primary key values so performance is the fastest possible on the entity view.

Example:
--------

<TestHarness>
  <Test Name = "ConfigParamSID" IsDefault ="true" Description="Finds the configuration parameter with the corresponding ConfigParamSID">
    <SQLScript>
      <![CDATA[

			declare
				@ConfigParamSID    int

			select top (1)
				@ConfigParamSID = c.ConfigParamSID
			from
				sf.ConfigParam c
			order by
				newid()

			if @@ROWCOUNT = 0
			begin

				select 'no configuration parameter was found.'

			end
			else
			begin

				exec sf.pConfigParam#Search
					@ConfigParamSID = @ConfigParamSID

			end


			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "OpenSearch" IsDefault ="false" Description="Finds all configuration parameters">
    <SQLScript>
      <![CDATA[

			if (select
						count(1)
					from
						sf.ConfigParam c) <= 0
			begin

				select 'no configurations exist'
			
			end
			else
			begin

				exec sf.pConfigParam#Search
					@SearchString = N''
			
			end

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "PartialName" IsDefault ="false" Description="Finds any configurations that contain a parital name in">
    <SQLScript>
      <![CDATA[

			declare
				 @randomConfig nvarchar(150)
				,@randomConfigPartial nvarchar(150)

			select top (1)
				@randomConfig = cp.ConfigParamName
			from
				sf.ConfigParam cp
			order by
				newid()

			set @randomConfigPartial = substring(@randomConfig, 2, 3)

			exec sf.pConfigParam#Search
				@SearchString = @randomConfigPartial
			
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "Query" IsDefault ="false" Description="Finds configuration parameters by passing in a query">
    <SQLScript>
      <![CDATA[

			declare
				@querySID      int

			select top (1)
				@querySID = q.QuerySID
			from
				sf.vQuery q
			where
				q.ApplicationEntitySCD = 'sf.ConfigParam'
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
	
					exec sf.pConfigParam#Search
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
	<Test Name = "Wildcard" IsDefault ="false" Description="Finds configuration parameters by passing in a config param name with wildcard replacment fields">
    <SQLScript>
      <![CDATA[

				declare
					 @randomConfig nvarchar(150)
					,@randomConfigPartial nvarchar(150)

				select top (1)
					@randomConfig = cp.ConfigParamName
				from
					sf.ConfigParam cp
				order by
					newid()

				set @randomConfigPartial = substring(@randomConfig, 2, 3)
				set @randomConfigPartial = replace(@randomConfigPartial, substring(@randomConfigPartial, 2, 1), '_')

				exec sf.pConfigParam#Search
					@SearchString = @randomConfigPartial

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pConfigParam#Search'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

  declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)
    ,@searchType                      varchar(25)                         -- type of search; returned with entity for debugging
		,@maxRows													int																	-- maximum rows allowed on search
		,@maxAutoRows											int																	-- maximum rows allowed on open search
		,@recordCount											int																	-- in order to open search table, need to ensure record count is less than config param('MaxRowsForAutoSearch')

  begin try

    declare
      @selected                         table                             -- stores results of query - SID only
      (
         ID                             int identity(1, 1)  not null      -- identity to track add order - preserves custom sorts
        ,EntitySID                      int                 not null      -- record ID joined to main entity to return results
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
			sf.ConfigParam

    -- execute the searches

    if @QuerySID is not null																							-- dynamic query search
    begin

      set @searchType   = 'Query'

      insert
        @selected
      (
        EntitySID
      )
      exec sf.pQuery#Execute
         @QuerySID        = @QuerySID
				,@QueryParameters = @QueryParameters

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
        cp.ConfigParamSID
      from
        sf.ConfigParam cp
      join
        @Identifiers.nodes('/Identifiers/SID') as Identifiers(ID)
        on
        cp.ConfigParamSID  = Identifiers.ID.value('.','int')							-- join to XML document on the SID to apply filtering

    end
    else if @ConfigParamSID is not null																		-- specific SID passed  (1 record)
    begin

      set @searchType   = 'SID'

    insert
        @selected
      (
        EntitySID
      )
      select
        cp.ConfigParamSID
      from
        sf.ConfigParam cp
      where
        cp.ConfigParamSID = @ConfigParamSID

      if @@rowcount = 0
      begin

        exec sf.pMessage#Get
           @MessageSCD  = 'RecordNotFound'
          ,@MessageText = @errorText output
          ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
          ,@Arg1        = 'ConfigParam'
          ,@Arg2        = @ConfigParamSID

        raiserror(@errorText, 18, 1)
      end

    end
    else if @SearchString is not null
    begin

			set @searchType = 'ConfigParamName'

			set @SearchString = sf.fSearchString#Format(@SearchString)					-- format search string and add leading % if not there

			if left(@SearchString,1) <> '%'
			begin

				set @SearchString = cast(N'%' + @SearchString as nvarchar(35))

			end

			insert
				@selected
			(
				EntitySID
			)
			select
					cp.ConfigParamSID
			from
				sf.ConfigParam cp
			where
				cp.ConfigParamName like @SearchString															-- search against name

		end
    else
    begin
			
			-- if search string is empty, then an open search is being attempted.
			-- Only perform open search if the table has less records in the
			-- table than is configured. Else return message

			if @recordCount <= @maxAutoRows
			begin
				
				set @maxRows = @maxAutoRows
				
				set @searchType   = 'OpenSearch'

				insert
					@selected
				(
					EntitySID
				)
				select
						cp.ConfigParamSID
				from
					sf.ConfigParam cp

			end
			else
			begin

				exec sf.pMessage#Get
					 @MessageSCD    = 'SearchOptionSetNotValid'
					,@MessageText   = @errorText output
					,@DefaultText   = N'A recognized search option set was not selected.  You must either enter search text, click a quick search button, or select a query from the drop down.'

				raiserror(@errorText, 16, 1)
			
			end

    end

    -- return all columns from the entity joined to the PK value from the memory table
    -- the XML column is excluded with the tag so that it's content can be returned
    -- from the variable

    select top (@maxRows)
      --!<ColumnList DataSource="sf.vConfigParam" Alias="cp">
       cp.ConfigParamSID
      ,cp.ConfigParamSCD
      ,cp.ConfigParamName
      ,cp.ParamValue
      ,cp.DefaultParamValue
      ,cp.DataType
      ,cp.MaxLength
      ,cp.IsReadOnly
      ,cp.UsageNotes
      ,cp.UserDefinedColumns
      ,cp.ConfigParamXID
      ,cp.LegacyKey
      ,cp.IsDeleted
      ,cp.CreateUser
      ,cp.CreateTime
      ,cp.UpdateUser
      ,cp.UpdateTime
      ,cp.RowGUID
      ,cp.RowStamp
      ,cp.IsDeleteEnabled
      ,cp.IsReselected
      ,cp.IsNullApplied
      ,cp.zContext
      ,cp.ActiveParamValue
      ,cp.IsUpdateEnabled
        --!</ColumnList>
      ,@searchType             SearchType                                 -- added to support debugging (ignored by UI)
    from
      sf.vConfigParam cp
    join
      @selected         x  on cp.ConfigParamSID = x.EntitySID
		where
			isnull(cp.[MaxLength], 1) <> 8192																		-- avoid image based configuration values with lengths = 8192!
    order by
      cp.ConfigParamName

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
