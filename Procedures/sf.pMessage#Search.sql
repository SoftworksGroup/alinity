SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pMessage#Search]
   @SearchString        nvarchar(150)     = null    -- name string to search against message name
  ,@QuerySID            int               = null    -- dynamic query: SID of sf.Query row providing SQL syntax to execute
	,@QueryParameters			xml								= null		-- dynamic query: list of query parameters associated with the query SID
as
/*********************************************************************************************************************************
Procedure : Message Search
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Searches the Message entity for the search string and search options provided
History   : Author(s)   | Month Year  | Change Summary
          : ------------|-------------|-----------------------------------------------------------------------------------------
          : Kevin Lau	  | July 2015   | Initial version
Comments
--------
This procedure executes various types of searches against the sf.Message entity.

Text search
-----------
The search string is applied as a search against the message name or the message text. A substring search is performed so rows
matching any part of the search string are returned.

Wildcard characters: *, %, ?, _ are allowed within string searches.

Dynamic queries
---------------
When the @QuerySID parameter is passed as not null, then a dynamic query is executed.  The query syntax is retrieved from
sf.Query and executed through a subroutine. This feature supports configuration-specific (custom) queries to be added
to the installation.  See sf.pQuery#Search for additional details.

Sort order
----------
This procedure orders all results by the Message name.

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
	<Test Name = "OpenSearch" IsDefault ="false" Description="Finds all Messages">
    <SQLScript>
      <![CDATA[

			if (select
						count(1)
					from
						sf.Message m) <= 0
			begin

				select 'no messages exist'
			
			end
			else
			begin

				exec sf.pMessage#Search
					@SearchString = N''
			
			end

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "PartialName" IsDefault ="false" Description="Finds any messages that contain a parital name">
    <SQLScript>
      <![CDATA[

			declare
				 @randomMessage nvarchar(150)
				,@randomMessagePartial nvarchar(150)

			select top (1)
				@randomMessage = m.MessageName
			from
				sf.Message m
			order by
				newid()

			set @randomMessagePartial = substring(@randomMessage, 2, 3)

			exec sf.pMessage#Search
				@SearchString = @randomMessagePartial
			
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "Query" IsDefault ="false" Description="Finds Messages by passing in a query">
    <SQLScript>
      <![CDATA[
			declare
				@querySID      int

			select top (1)
				@querySID = q.QuerySID
			from
				sf.vQuery q
			where
				q.ApplicationEntitySCD = 'sf.Message'
			and
				q.QueryParameters is null
			order by
				newid()

			if @@rowcount <= 0
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
	
					exec sf.pMessage#Search
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
	<Test Name = "Wildcard" IsDefault ="false" Description="Finds messages by passing in a message name with wildcard replacment fields">
    <SQLScript>
      <![CDATA[

				declare
					 @randomMessage nvarchar(150)
					,@randomMessagePartial nvarchar(150)

				select top (1)
					@randomMessage = m.MessageName
				from
					sf.Message m
				order by
					newid()

				set @randomMessagePartial = substring(@randomMessage, 2, 3)
				set @randomMessagePartial = replace(@randomMessagePartial, substring(@randomMessagePartial, 2, 1), '_')

				exec sf.pMessage#Search
					@SearchString = @randomMessagePartial

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pMessage#Search'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

  declare
     @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)
    ,@searchType                      varchar(25)                         -- type of search; returned with entity for debugging
		,@recordCount											int																	-- in order to open search table, need to ensure record count is less than message('MaxRowsForAutoSearch')

  begin try

    declare
      @selected                         table                             -- stores results of query - SID only
      (
         ID                             int identity(1, 1)  not null      -- identity to track add order - preserves custom sorts
        ,EntitySID                      int                 not null      -- record ID joined to main entity to return results
      )

		set @SearchString = ltrim(rtrim(@SearchString))												-- remove leading and trailing spaces from character type columns

		-- get a count of records in the base table. If the user is attempting
		-- to perform an open search, the results will only return if the count
		-- in the table is less than the config param('MaxRowsForAutoSearch')

		select
			@recordCount = count(1)
		from
			sf.Message

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
    else if @SearchString is not null
    begin

			set @searchType = 'MessageNameOrDescription'

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
					m.MessageSID
			from
				sf.Message m
			where
				m.MessageName like @SearchString																	-- search against name
			or
			isnull(m.MessageText, m.DefaultText) like @SearchString

		end
    else
    begin
			
			-- if search string is empty, then an open search is being attempted.
			-- Only perform open search if the table has less records in the
			-- table than is configured. Else return message
							
			set @searchType   = 'OpenSearch'

			insert
				@selected
			(
				EntitySID
			)
			select
					m.MessageSID
			from
				sf.Message m

    end

    -- return all columns from the entity joined to the PK value from the memory table
    -- the XML column is excluded with the tag so that it's content can be returned
    -- from the variable

    select
      --!<ColumnList DataSource="sf.vMessage" Alias="m">
       m.MessageSID
      ,m.MessageSCD
      ,m.MessageName
      ,m.MessageText
      ,m.MessageTextUpdateTime
      ,m.DefaultText
      ,m.DefaultTextUpdateTime
      ,m.UserDefinedColumns
      ,m.MessageXID
      ,m.LegacyKey
      ,m.IsDeleted
      ,m.CreateUser
      ,m.CreateTime
      ,m.UpdateUser
      ,m.UpdateTime
      ,m.RowGUID
      ,m.RowStamp
      ,m.IsDeleteEnabled
      ,m.IsReselected
      ,m.IsNullApplied
      ,m.zContext
        --!</ColumnList>
      ,@searchType             SearchType                                 -- added to support debugging (ignored by UI)
    from
      sf.vMessage m
    join
      @selected         x  on m.MessageSID = x.EntitySID
		order by
      m.MessageName

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
