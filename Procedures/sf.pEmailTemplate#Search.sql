SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pEmailTemplate#Search]
   @SearchString        nvarchar(150)     = null	-- name string to search against the EmailTemplate Subject
  ,@QuerySID            int               = null	-- dynamic query: SID of sf.Query row providing SQL syntax to execute
	,@QueryParameters			xml								= null	-- dynamic query: list of query parameters associated with the query SID
  ,@Identifiers         xml               = null	-- quick search: list of pinned records to return (xml contains SID's)
  ,@EmailTemplateSID		int								= null	-- quick search: returns a specific EmailTemplate based on system ID
as
/*********************************************************************************************************************************
Procedure : Email Template Search
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Searches the Email Template entity for the search string and search options provided
History   : Author(s)   | Month Year  | Change Summary
          : ------------|-------------|-----------------------------------------------------------------------------------------
          : Richard K		| May 2015		| Initial version
					: Richard K		| Jan 2016		| Updated open search logic to return no rows if total rows exceed @MaxAutoRows

Comments
--------
This procedure executes various types of searches against the sf.EmailTemplate entity.

Text search
-----------
The search is performed against the EmailTemplateLabel and Body columns.   A substring search is performed so rows matching any
part of the search string are returned. Wildcard characters: *, %, ?, _ are allowed within string searches.  The procedure puts
wildcards on both ends of the string if not already provided.

Dynamic queries
---------------
When the @QuerySID parameter is passed as not null, then a dynamic query is executed.  The query syntax is retrieved from
sf.Query and executed through a subroutine. This feature supports configuration-specific (custom) queries to be added
to the installation.  See sf.pQuery#Search for additional details.

@EmailTemplateSID search ("SID: 12345")
---------------------------------------
This is a search on the primary key of the entity.  It can be invoked by passing the parameter directly, or by entering the
keyword "SID:" followed by a number into the @SearchString - e.g. "SID:1234567". The digits are stripped from the string and
converted into the parameter value by the procedure.  The conversion only takes place if all values following "SID:" are digits
(or spaces).  By allowing system ID's to the be entered into search string, administrators and configurators are able to
trouble shoot error messages that return SID's using the application's user interface.

Sort order
----------
This procedure orders all results by the EmailTemplateLabel name.

Result limiting
---------------
This procedure will only return the maximum amount of rows to return as configured in the "MaxRowsOnSearch". When an open search
is called, then only the amount of rows configured in the "MaxRowsForAutoSearch" will be returned.

Use of Memory Table
-------------------
The application standard for entity search procedures is to implement branch logic to execute a SELECT statement for each
search scenario. The initial SELECT then populates a memory table with the primary key value of the entity - in this case
the EmailTemplateSID. The memory table keys are then joined to the entity view to return the data set at the end of the case
logic.  This technique, while slightly less efficient than direct selects against the entity view in some cases, reduces
code volume substantially since the columns from the entity only need be included once. A second advantage is that it allows
some JOIN and WHERE logic to be performed against tables rather than the entity view; which itself may be quite complex. This
leads to improved performance in some cases.  The final SELECT is a simple join against primary key values so performance is
the fastest possible on the entity view.

Example:
--------
<TestHarness>
	<Test Name = "EmailTemplateSID" IsDefault ="true" Description="Finds the EmailTemplate with the corresponding EmailTemplateSID">
    <SQLScript>
      <![CDATA[

			declare
				@emailTemplateSID    int

			select top (1)
				@emailTemplateSID = et.EmailTemplateSID
			from
				sf.EmailTemplate et
			order by
				newid()

			exec sf.pEmailTemplate#Search
				@EmailTemplateSID = @emailTemplateSID

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
  <Test Name = "FullName" IsDefault ="false" Description="Finds an EmailTemplate by it's full name.">
    <SQLScript>
      <![CDATA[

				declare
					@randomEmailTemplate nvarchar(150)

				select top (1)
					@randomEmailTemplate = et.EmailTemplateLabel
				from
					sf.EmailTemplate et
				order by
					newid()
				
				exec sf.pEmailTemplate#Search																					
					@SearchString = @randomEmailTemplate

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "PartialName" IsDefault ="false" Description="Finds an EmailTemplate by partial name.">
    <SQLScript>
      <![CDATA[

			declare
			 @randomEmailTemplate nvarchar(150)
			,@randomEmailTemplatePartial nvarchar(150)

			select top (1)
					@randomEmailTemplate = et.EmailTemplateLabel
				from
					sf.EmailTemplate et
				order by
					newid()

			select @randomEmailTemplatePartial = substring(@randomEmailTemplate, 2, 3)

			exec sf.pEmailTemplate#Search																				
			@SearchString = @randomEmailTemplatePartial

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
		<Test Name = "EmailTemplateQuery" IsDefault ="false" Description="Finds Email Templates by passing in a query">
    <SQLScript>
      <![CDATA[

				declare
					@querySID      int

				select top (1)
					@querySID = q.QuerySID
				from
					sf.vQuery q
				where
					q.ApplicationEntitySCD = 'sf.EmailTemplate'
				and
					q.QueryParameters is null
				order by
					newid()
	
				exec sf.pEmailTemplate#Search	
					@QuerySID = @querySID

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "WildCard" IsDefault ="false" Description="Finds Email Template by a partial name with wildcard tokens.">
    <SQLScript>
      <![CDATA[

			declare
			 @randomEmailTemplate nvarchar(150)
			,@randomEmailTemplatePartial nvarchar(150)

			select top (1)
					@randomEmailTemplate = et.EmailTemplateLabel
				from
					sf.EmailTemplate et
				order by
					newid()

				set @randomEmailTemplatePartial = substring(@randomEmailTemplate, 2, 3)
				set @randomEmailTemplatePartial = replace(@randomEmailTemplatePartial, substring(@randomEmailTemplatePartial, 2,1), '_')

				exec sf.pEmailTemplate#Search																					
				@SearchString = @randomEmailTemplatePartial

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pEmailTemplate#Search'
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
			sf.EmailTemplate

		-- if SID is provided in search string, parse it out and set parameter
		-- value (ensure it is all digits before attempting cast)

		if left(ltrim(@SearchString), 4) = N'SID:' and sf.fIsStringContentValid(replace(replace(@SearchString, N'SID:', ''), ' ', ''), N'0123456789' ) = @ON
		begin

			set @EmailTemplateSID	= cast(replace(replace(@SearchString, N'SID:', ''), ' ', '') as int)

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
        et.EmailTemplateSID
      from
        sf.EmailTemplate et
      join
        @Identifiers.nodes('/Identifiers/SID') as Identifiers(ID)
        on
        et.EmailTemplateSID  = Identifiers.ID.value('.','int')						-- join to XML document on the SID to apply filtering

    end
    else if @EmailTemplateSID is not null																	-- specific SID passed (1 record)
    begin

      set @searchType   = 'SID'

      insert
        @selected
      (
        EntitySID
      )
      select
        et.EmailTemplateSID
      from
        sf.EmailTemplate et
      where
        et.EmailTemplateSID = @EmailTemplateSID

      if @@rowcount = 0
 begin

        exec sf.pMessage#Get
           @MessageSCD  = 'RecordNotFound'
          ,@MessageText = @errorText output
          ,@DefaultText = N'The "%1" record was not found. Record ID = %2. The record may have been deleted or the identifier is invalid.'
          ,@Arg1        = 'State/Province'
          ,@Arg2        = @EmailTemplateSID

        raiserror(@errorText, 18, 1)

      end

    end
    else if @SearchString is not null
    begin

      set @searchType = 'EmailTemplateLabelAndBody'

			set @SearchString = sf.fSearchString#Format(@SearchString)					-- format search string and add leading % if not there

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
					et.EmailTemplateSID
				from
					sf.EmailTemplate et
				where
					et.EmailTemplateLabel like @SearchString
				or
					cast(et.Body as nvarchar(max)) like @SearchString

    end
    else
    begin

				-- if search string is empty, then an open search is being attempted.
				-- limit the record count returned to the maxAutoRows ParamConfig value
				set @searchType   = 'OpenSearch'
				if @recordCount <= @maxAutoRows
				begin

					insert
					@selected
					(
						EntitySID
					)
					select
						 et.EmailTemplateSID
					from
						sf.EmailTemplate et

				end

    end

    -- return all columns from the entity joined to the PK value from the memory table
    -- the XML column is excluded with the tag so that it's content can be returned
    -- from the variable

    select top (@maxRows)
      --!<ColumnList DataSource="sf.vEmailTemplate" Alias="et">
       et.EmailTemplateSID
      ,et.EmailTemplateLabel
      ,et.PriorityLevel
      ,et.Subject
      ,et.Body
      ,et.ChangeLogSummary
      ,et.IsApplicationUserRequired
      ,et.LinkExpiryHours
      ,et.ApplicationEntitySID
      ,et.ApplicationGrantSID
      ,et.UsageNotes
      ,et.UserDefinedColumns
      ,et.EmailTemplateXID
      ,et.LegacyKey
      ,et.IsDeleted
      ,et.CreateUser
      ,et.CreateTime
      ,et.UpdateUser
      ,et.UpdateTime
      ,et.RowGUID
      ,et.RowStamp
      ,et.ApplicationEntitySCD
      ,et.ApplicationEntityName
      ,et.IsMergeDataSource
      ,et.ApplicationEntityRowGUID
      ,et.ApplicationGrantSCD
      ,et.ApplicationGrantName
      ,et.ApplicationGrantIsDefault
      ,et.ApplicationGrantRowGUID
      ,et.IsDeleteEnabled
      ,et.IsReselected
      ,et.IsNullApplied
      ,et.zContext
      ,et.IsDefaultEmailTemplate
        --!</ColumnList>
      ,@searchType                SearchType                              -- added to support debugging (ignored by UI)
    from
      sf.vEmailTemplate  et
    join
      @selected			x on et.EmailTemplateSID = x.EntitySID
    order by
      et.[Subject]

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
