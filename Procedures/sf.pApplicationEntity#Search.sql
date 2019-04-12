SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationEntity#Search]
   @SearchString							nvarchar(150)     = null										-- name string to search against ApplicationEntity name
	,@SchemaSCD									nvarchar(128)			= null										-- return all entities in a schema: DBO, STG, SF
	,@IsDboIncluded							bit								= 1												-- indicates entities from the dbo schema is included
	,@IsSfIncluded							bit								= 1												-- indicates entities from the sf schema is included
	,@IsStgIncluded							bit								= 1												-- indicates entities from the stg schema is included
	,@IsRptIncluded							bit								= 0												-- indicates entities from the rpt schema is included
  ,@QuerySID									int               = null										-- dynamic query: SID of sf.Query row providing SQL syntax to execute
	,@QueryParameters						xml								= null										-- dynamic query: list of query parameters associated with the query SID
  ,@Identifiers								xml               = null										-- quick search: list of pinned records to return (xml contains SID's)
  ,@ApplicationEntitySID			int								= null										-- quick search: returns a specific Application Entity based on system ID
as
/*********************************************************************************************************************************
Procedure : ApplicationEntity Search
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Searches the Application Entity table for the search string and search options provided
History   : Author(s)   | Month Year  | Change Summary
          : ------------|-------------|-----------------------------------------------------------------------------------------
          : Tim Edlund  | Mar 2013    | Initial version
					: Relan C.		| May 2013    | Add parameter support for custom query searches
					: Cory Ng			| Jul 2015		| Add schema filter bits
Comments
--------
This procedure executes various types of searches against the sf.ApplicationEntity entity.

Text search
-----------
The search string is applied as a search against the Application Entity name and table name - including schema. A substring search
is performed so rows matching any part of the search string are returned.

Wildcard characters: *, %, ?, _ are allowed within string searches.

Schema
------
To limit the tables returned to a schema, the @SchemaSCD parameter must be passed.  This value may not be combined with any
other value in the search.

Dynamic queries
---------------
When the @QuerySID parameter is passed as not null, then a dynamic query is executed.  The query syntax is retrieved from
sf.Query and executed through a subroutine. This feature supports configuration-specific (custom) queries to be added
to the installation.  See sf.pQuery#Setup for additional details.

Pinned record search
--------------------
The @Identifiers parameter returns "pinned" records.  The user can pin records through the user interface and then retrieve
them afterward through this search.  The system ID's of the pinned records are assembled into an XML value and passed to
this routine which parses the XML and joins on the key value to the entity record. This is a quick search that does not
consider any other criteria.

@ApplicationEntitySID
----------------
When a @ApplicationEntitySID is provided, a single record is returned. If the SID is not found, an error is raised.

Sort order
----------
This procedure orders all results by the Application Entity name.

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

declare                                                                   -- dynamic query search
  @querySID      int

select top (1)
  @querySID = q.QuerySID
from
  sf.vQuery q
where
  q.ApplicationEntitySCD = 'sf.ApplicationEntity'
order by
  newid()

exec sf.pApplicationEntity#Search
  @QuerySID = @querySID

exec sf.pApplicationEntity#Search																					-- string search
  @SearchString = N'provider'

exec sf.pApplicationEntity#Search																					-- with wildcard
  @SearchString = N'%provider'

declare
  @applicationEntitySID    int

select top (1)
  @applicationEntitySID = ent.ApplicationEntitySID
from
  sf.ApplicationEntity ent
order by
  newid()

exec sf.pApplicationEntity#Search                                         -- for SID
  @ApplicationEntitySID = @applicationEntitySID

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

  declare
     @errorNo                         int							= 0                 -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)
    ,@searchType                      varchar(25)                         -- type of search; returned with entity for debugging
		,@ON															bit							= cast(1 as bit)		-- constant to eliminate repetitive casting syntax
		,@OFF															bit							= cast(0 as bit)		-- constant to eliminate repetitive casting syntax

  begin try

    declare
      @selected                         table                             -- stores results of query - SID only
      (
         ID                             int identity(1, 1)  not null      -- identity to track add order - preserves custom sorts
        ,EntitySID                      int                 not null      -- record ID joined to main entity to return results
      )

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
        ent.ApplicationEntitySID
      from
        sf.ApplicationEntity ent
      join
        @Identifiers.nodes('/Identifiers/SID') as Identifiers(ID)
        on
        ent.ApplicationEntitySID  = Identifiers.ID.value('.','int')				-- join to XML document on the SID to apply filtering

    end
    else if @ApplicationEntitySID is not null															-- specific SID passed  (1 record)
    begin

      set @searchType   = 'SID'

    insert
        @selected
      (
        EntitySID
      )
      select
        ent.ApplicationEntitySID
      from
        sf.ApplicationEntity ent
      where
        ent.ApplicationEntitySID = @ApplicationEntitySID

      if @@rowcount = 0
      begin

        exec sf.pMessage#Get
           @MessageSCD  = 'RecordNotFound'
          ,@MessageText = @errorText output
          ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
          ,@Arg1        = 'ApplicationEntity'
          ,@Arg2        = @ApplicationEntitySID

        raiserror(@errorText, 18, 1)
      end

    end
    else if @SchemaSCD is not null
    begin

      set @searchType = 'Schema'

      insert
        @selected
      (
        EntitySID
      )
      select
         ent.ApplicationEntitySID
      from
        sf.ApplicationEntity ent
      where
        ent.ApplicationEntitySCD like @SchemaSCD +  '.%'

		end
    else if @SearchString is not null
    begin

			set @searchType = 'ApplicationEntityName'

      set @SearchString = sf.fSearchString#Format(@SearchString)          -- format search string and add leading % if not there

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
         ent.ApplicationEntitySID
      from
        sf.ApplicationEntity ent
      where
			(
        ent.ApplicationEntityName like @SearchString											-- search against name
				or
				ent.ApplicationEntitySCD like @SearchString
			)
			and
			(
				(@IsDboIncluded = @ON and ent.ApplicationEntitySCD like 'dbo.%')
			or
				(@IsSfIncluded	= @ON and ent.ApplicationEntitySCD like 'sf.%')
			or
				(@IsStgIncluded	= @ON and ent.ApplicationEntitySCD like 'stg.%')
			or
				(@IsRptIncluded	= @ON and ent.ApplicationEntitySCD like 'rpt.%')
			)

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

    select      -- return the entity for selected key values
      --!<ColumnList DataSource="sf.vApplicationEntity" Alias="ent">
       ent.ApplicationEntitySID
      ,ent.ApplicationEntitySCD
      ,ent.ApplicationEntityName
      ,ent.UsageNotes
      ,ent.IsMergeDataSource
      ,ent.UserDefinedColumns
      ,ent.ApplicationEntityXID
      ,ent.LegacyKey
      ,ent.IsDeleted
      ,ent.CreateUser
      ,ent.CreateTime
      ,ent.UpdateUser
      ,ent.UpdateTime
      ,ent.RowGUID
      ,ent.RowStamp
      ,ent.IsDeleteEnabled
      ,ent.IsReselected
      ,ent.IsNullApplied
      ,ent.zContext
      ,ent.BaseTableSchemaName
      ,ent.BaseTableName
      ,ent.BaseTableObjectID
      ,ent.BaseTableDescription
      ,ent.TotalRows
      ,ent.BusinessRuleErrorCount
      ,ent.PendingBusinessRuleCount
      ,ent.ClientBusinessRuleCount
      ,ent.MandatoryBusinessRuleCount
      ,ent.OptionalBusinessRuleCount
      ,ent.BusinessRuleCount
      ,ent.IsConstraintEnabled
      ,ent.IsCheckFunctionDeployed
      ,ent.IsExtCheckFunctionDeployed
      ,ent.ExtendedFunctionName
      ,ent.DataStatus
      ,ent.DataStatusLabel
      ,ent.DataStatusNote
      ,ent.ReflectionApplicationEntitySCD
      --!</ColumnList>
      ,@searchType             SearchType                                 -- added to support debugging (ignored by UI)
    from
      sf.vApplicationEntity ent
    join
      @selected         x  on ent.ApplicationEntitySID = x.EntitySID
    order by
      ent.ApplicationEntityName

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
