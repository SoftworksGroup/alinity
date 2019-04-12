SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pCity#Search]
   @SearchString        nvarchar(150)     = null	-- name string to search against the CityName
  ,@QuerySID            int               = null	-- dynamic query: SID of sf.Query row providing SQL syntax to execute
	,@QueryParameters			xml								= null	-- dynamic query: list of query parameters associated with the query SID
  ,@Identifiers         xml               = null	-- quick search: list of pinned records to return (xml contains SID's)
  ,@CitySID							int               = null	-- quick search: returns a specific City based on system ID
  ,@StateProvinceSID    int               = null	-- quick search: returns Cities with assignments to the state/province
  ,@CountrySID					int               = null	-- quick search: returns Cities with assignments to the country
as
/*********************************************************************************************************************************
Procedure : City Search
Notice    : Copyright © 2012 Softworks Group Inc.
Summary   : Searches the City entity for the search string and search options provided
History   : Author(s)   | Month Year  | Change Summary
          : ------------|-------------|-----------------------------------------------------------------------------------------
          : Tim Edlund	| Feb	2013    | Initial version
					: Relan C.		| May 2013    | Add parameter support for custom query searches
					: Tyson Schulz| Nov 2014		| Add base select limit to take configuration parameter "MaxRowsOnSearch" into account.
																				Create test harness.

Comments
--------
This procedure executes various types of searches against the dbo.City entity.

Text search
-----------
The search is performed against the CityName column.   A substring search is performed so rows matching any part of the search
string are returned. Wildcard characters: *, %, ?, _ are allowed within string searches.  For example, if the user enters
"cal" then "calgary" and "calmar" are returned.  If "gary" is entered, then "Calgary" is also returned as the procedure puts
wildcards on both ends of the string if not already provided.

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

@CitySID search ("SID: 12345")
---------------------------------
This is a search on the primary key of the entity.  It can be invoked by passing the parameter directly, or by entering the
keyword "SID:" followed by a number into the @SearchString - e.g. "SID:1234567". The digits are stripped from the string and
converted into the parameter value by the procedure.  The conversion only takes place if all values following "SID:" are digits
(or spaces).  By allowing system ID's to the be entered into search string, administrators and configurators are able to
trouble shoot error messages that return SID's using the application's user interface.

Other quick searches
--------------------
The @StateProvinceSID is represented as drop-down in the search UI.  When a value is provided, the Cities returned are
limited to those which are assigned to the given state/province. The @CountrySID search works the same way - returning
cities associated with the given country value.

Quick searches do not combine with any other criteria.

Sort order
----------
This procedure orders all results by the City label.

Result limiting
---------------
This procedure will only return the maximum amount of rows to return as configured in the "MaxRowsOnSearch". When an open search
is called, then the only the amount of rows configured in the "MaxRowsForAutoSearch" will be returned.

Use of Memory Table
-------------------
The application standard for entity search procedures is to implement branch logic to execute a SELECT statement for each
search scenario. The initial SELECT then populates a memory table with the primary key value of the entity - in this case
the CitySID. The memory table keys are then joined to the entity view to return the data set at the end of the case
logic.  This technique, while slightly less efficient than direct selects against the entity view in some cases, reduces
code volume substantially since the columns from the entity only need be included once. A second advantage is that it allows
some JOIN and WHERE logic to be performed against tables rather than the entity view; which itself may be quite complex. This
leads to improved performance in some cases.  The final SELECT is a simple join against primary key values so performance is
the fastest possible on the entity view.

Example:
--------

<TestHarness>
	<Test Name = "CitySID" IsDefault ="true" Description="Finds the city with the corresponding CitySID">
    <SQLScript>
      <![CDATA[

			declare
				@citySID    int

			select top 1
				@CitySID = c.CitySID
			from
				dbo.City c
			order by
				newid()

			exec dbo.pCity#Search
				@CitySID = @citySID	

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
  <Test Name = "CityFullName" IsDefault ="false" Description="Finds cities with the name N'calgary'.">
    <SQLScript>
      <![CDATA[

			declare
				@randomCity nvarchar(150)

			select top 1
				@randomCity = c.CityName
			from
				dbo.City c
			order by
				newid()

			exec dbo.pCity#Search
				@SearchString = @randomCity

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "CityPartialName" IsDefault ="false" Description="Finds cities with the partial name N'cal'.">
    <SQLScript>
      <![CDATA[

				declare
					@randomCity					nvarchar(150)
					,@randomCityPartial nvarchar(150)

				select top 1
					@randomCity = c.CityName
				from
					dbo.City c
				order by
					newid()

				set @randomCityPartial = substring(@randomCity, 2, 3)

				exec dbo.pCity#Search
					@SearchString = @randomCityPartial

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "CityQuery" IsDefault ="false" Description="Finds cities by passing in a query">
    <SQLScript>
      <![CDATA[

				declare
					@querySID      int

				select top 1
					@querySID = q.QuerySID
				from
					sf.vQuery q
				where
					q.ApplicationEntitySCD = 'dbo.City'
				and
					q.QueryParameters is null
				order by
					newid()
	
				exec dbo.pCity#Search
					@QuerySID = @querySID

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "CityWildcard" IsDefault ="false" Description="Finds cities by passing in a cityname with wildcard replacment fields">
    <SQLScript>
      <![CDATA[

				declare
					@randomCity					nvarchar(150)
					,@randomCityPartial nvarchar(150)

				select top 1
					@randomCity = c.CityName
				from
					dbo.City c
				order by
					newid()

				set @randomCityPartial = substring(@randomCity, 2, 3)
				set @randomCityPartial = replace(@randomCityPartial, substring(@randomCityPartial, 2,1), '_')

				exec dbo.pCity#Search
					@SearchString = @randomCityPartial

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pCity#Search'

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
		,@maxAutoRows											int																	-- maximum amount of records allowed in the table in order to perform an open search
		,@recordCount											int																	-- in order to perform an open search on table, need to ensure table record count is less than @maxAutoRows

  begin try

    declare
      @selected                         table                             -- stores results of query - SID only
      (
         ID                             int identity(1, 1)  not null      -- identity to track add order - preserves custom sorts
        ,EntitySID                      int                 not null      -- record ID joined to main entity to return results
      )

		set @SearchString = ltrim(rtrim(@SearchString))												-- remove leading and trailing spaces from character type columns
		if len(@SearchString) = 0 set @SearchString = null										-- when empty string is passed in, set it to null

    -- retrieve max rows for string searches and set other defaults

    set @maxRows      = cast(isnull(sf.fConfigParam#Value('MaxRowsOnSearch'), '100')  as int)
		set @maxAutoRows	= cast(isnull(sf.fConfigParam#Value('MaxRowsForAutoSearch'),	'20')	as int)

		-- get a count of records in the base table. If the user is attempting
		-- to perform an open search, the select will only be performed if the
		-- record count in the table is less than the @maxAutoRows

		select																																
			@recordCount = count(1)
		from
			dbo.City c

		-- if SID is provided in search string, parse it out and set parameter
		-- value (ensure it is all digits before attempting cast)

		if left(ltrim(@SearchString), 4) = N'SID:' and sf.fIsStringContentValid(replace(replace(@SearchString, N'SID:', ''), ' ', ''), N'0123456789' ) = @ON
		begin

			set @CitySID	= cast(replace(replace(@SearchString, N'SID:', ''), ' ', '') as int)

		end

    -- execute the searches

    if @QuerySID is not null                                              -- dynamic query search
    begin

      set @searchType   = 'Query'

      insert        @selected
      (
        EntitySID
      )
      exec sf.pQuery#Execute
         @QuerySID = @QuerySID
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
        c.CitySID
      from
        dbo.City c
      join
        @Identifiers.nodes('/Identifiers/SID') as Identifiers(ID)
        on
        c.CitySID  = Identifiers.ID.value('.','int')											-- join to XML document on the SID to apply filtering

    end
    else if @CitySID is not null																					-- specific SID passed  (1 record)
    begin

      set @searchType   = 'SID'

      insert
        @selected
      (
        EntitySID
      )
      select
        c.CitySID
      from
        dbo.City c
      where
        c.CitySID = @CitySID

      if @@rowcount = 0
      begin

        exec sf.pMessage#Get
           @MessageSCD  = 'RecordNotFound'
          ,@MessageText = @errorText output
          ,@DefaultText = N'The "%1" record was not found. Record ID = %2. The record may have been deleted or the identifier is invalid.'
          ,@Arg1        = 'City'
          ,@Arg2        = @CitySID

        raiserror(@errorText, 18, 1)
      end

    end
    else if @StateProvinceSID is not null
    begin

      set @searchType = 'StateProvince'

      insert
        @selected
      (
        EntitySID
      )
      select distinct
         c.CitySID
      from
        dbo.StateProvince sp
      join
        dbo.City          c    on sp.StateProvinceSID = c.StateProvinceSID
      where
        sp.StateProvinceSID = @StateProvinceSID

    end
    else if @CountrySID is not null
    begin

      set @searchType = 'Country'

      insert
        @selected
      (
        EntitySID
      )
      select distinct
         c.CitySID
      from
				dbo.Country				ctr
			join
        dbo.StateProvince sp	 on ctr.CountrySID = sp.CountrySID
      join
        dbo.City          c    on sp.StateProvinceSID = c.StateProvinceSID
      where
        ctr.CountrySID = @CountrySID

    end
    else if @SearchString is not null
    begin

      set @searchType = 'CityName'

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
					c.CitySID
			from
				dbo.City c
			where
				c.CityName like @SearchString																			-- search against name

    end
    else
    begin
			
			-- if search string is empty, then an open search is being attempted.
			-- Only perform open search if the table has less records in the
			-- table than is configured. Else return message

			if @recordCount <= @maxAutoRows
			begin

				set @searchType   = 'OpenSearch'

				insert
					@selected
				(
					EntitySID
				)
				select
					 c.CitySID
				from
					dbo.City c

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
      --!<ColumnList DataSource="dbo.vCity" Alias="c">
       c.CitySID
      ,c.CityName
      ,c.StateProvinceSID
      ,c.IsDefault
      ,c.IsActive
      ,c.IsAdminReviewRequired
      ,c.ChangeLog
      ,c.UserDefinedColumns
      ,c.CityXID
      ,c.LegacyKey
      ,c.IsDeleted
      ,c.CreateUser
      ,c.CreateTime
      ,c.UpdateUser
      ,c.UpdateTime
      ,c.RowGUID
      ,c.RowStamp
      ,c.StateProvinceName
      ,c.StateProvinceCode
      ,c.CountrySID
      ,c.ISONumber
      ,c.IsDisplayed
      ,c.StateProvinceIsDefault
      ,c.StateProvinceIsActive
      ,c.StateProvinceIsAdminReviewRequired
      ,c.StateProvinceRowGUID
      ,c.IsDeleteEnabled
      ,c.IsReselected
      ,c.IsNullApplied
      ,c.zContext
      ,c.CitySearch
			--!</ColumnList>
      ,@searchType                SearchType                              -- added to support debugging (ignored by UI)
    from
      dbo.vCity   c
    join
      @selected   x on c.CitySID = x.EntitySID
    order by
      c.CityName

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
