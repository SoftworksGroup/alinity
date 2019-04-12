SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#Search]
   @SearchString        nvarchar(140)   = null    -- name string to search, "last, first middle" or partial or UserName
  ,@IncludeInactive     bit             = 1       -- name search modifier - when OFF then only records where IsInactive = 0
  ,@QuerySID            int             = null    -- dynamic query: SID of sf.Query row providing SQL syntax to execute
	,@QueryParameters			xml							= null		-- dynamic query: list of query parameters associated with the query SID
	,@ModuleSCD						varchar(25)			= null		-- filter: restricts the text search to providers assigned to this module
  ,@Identifiers         xml             = null    -- quick search: list of pinned records to return (xml contains SID's)
  ,@ApplicationUserSID  int             = null    -- quick search: returns a specific Application User based on system ID
  ,@TemplateOnly        bit             = 0       -- quick search: only records marked as templates
  ,@AccessingNowOnly    bit             = 0       -- quick search: only records of user who appear to actively using the DB
  ,@ExcludeThisSID      int             = null    -- name search modifier: a SID to filter out (to avoid current user record)
as
/*********************************************************************************************************************************
Procedure : Application User Search
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Searches the Application User entity for the search string and search options provided
History   : Author(s)   | Month Year  | Change Summary
          : ------------|-------------|-----------------------------------------------------------------------------------------
          : Tim Edlund  | Jul   2012  | Initial version
          : Tim Edlund  | Nov   2012  | Re-architected procedure to use memory table.  Updated to accept QuerySID to allow
                                        searches to use custom queries defined in sf.Query meta data.  Quick searches updated.
                                        Single word in search string now searches last, first and username columns.
					: Relan C.		| May 2013    | Add parameter support for custom query searches.
					: Cory Ng			| Sep 2014		| Added module as parameter that can filter the text search.
					: Cory Ng			| Aug 2015		| Excluded IsDeleteEnabled from select list to improve performance

Comments
--------
This procedure executes various types of searches against the sf.ApplicationUser entity.

Text search
-----------
The search string is assumed to contain name values. These values are split into first, middle and last name components according
to logic applied by the library procedure:  sf.pSearchName#Split. That procedure assumes that if a comma is included in the
string, then the last name component has been provided to the left of the comma followed the first name a space and a middle name.
If no comma is included but one or more spaces exist within the trimmed string, then the logic assumes the first name is provided
first.  If a second space exists then the middle name is next followed by the last name.  If only 2 words exist within the text
provided then they are assumed to be first and last name components. A single string is assumed to the last name, or the first
name or a USERNAME - so all 3 columns are searched.

Wildcard characters: *, %, ?, _ are allowed in string searches.


The @IncludeInactive bit is considered on text searches so that if this bit is passed as OFF, then only records which have
an IsActive = 1 (ON) will be returned.  String searches are also limited by the current setting of @maxRows which is a
configuration parameter limiting the number of records allowed to be returned on a search.  If that value is set in the
configuration as 0, then no restriction is applied.

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

@ApplicationUserSID search
--------------------------
This search returns a specific record based on the system ID.

Other quick searches
--------------------
The other quick searches supported are invoked through the @TemplateOnly and @AccessingNowOnly (see parameter definition
above).  These searches are typically invoked through dedicated buttons on the user interface. Quick searches do not
combine with any other criteria.

@ExcludeThisSID
---------------
The @ExcludeThisSID parameter is provided to support copy (and similar) operations where rows for the currently selected
record should not be included in the search result.

Sort order
----------
This procedure orders all results by the "FileAsName".

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

declare                                                                    -- dynamic query search
  @querySID      int

select top (1)
  @querySID = q.QuerySID
from
  sf.vQuery q
where
  q.ApplicationEntitySCD = 'sf.ApplicationUser'
order by
  newid()

exec sf.pApplicationUser#Search
  @QuerySID = @querySID

exec sf.pApplicationUser#Search                                            -- string search
  @SearchString = N'Edlund, Tim     e'

exec sf.pApplicationUser#Search                                            -- with wildcard
  @SearchString = N'E?lund,'

exec sf.pApplicationUser#Search                                            -- with wildcard
  @AccessingNowOnly = 1

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
    ,@lastName                        nvarchar(35)                        -- for name searches, buffer for each name part:
    ,@firstName                       nvarchar(30)
    ,@middleNames                     nvarchar(30)

  begin try

    declare
      @selected                         table                             -- stores results of query - SID only
      (
         ID                   int identity(1, 1)  not null								-- identity to track add order - preserves custom sorts
        ,EntitySID						int                 not null								-- record ID joined to main entity to return results
      )

    -- retrieve max rows for string searches and set other defaults

    set @maxRows  = cast(isnull(sf.fConfigParam#Value('MaxRowsOnSearch'), '100')  as int)

    if @ExcludeThisSID is null set @ExcludeThisSID = -1                   -- ensure no rows are excluded when passed as null

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
          @QuerySID        = @QuerySID
				 ,@QueryParameters = @QueryParameters
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
        au.ApplicationUserSID
      from
        sf.ApplicationUser au
      join
        @Identifiers.nodes('/Identifiers/SID') as Identifiers(ID)
        on
        au.ApplicationUserSID  = Identifiers.ID.value('.','int')          -- join to XML document on the SID to apply filtering

    end
    else if @ApplicationUserSID is not null                               -- specific SID passed  (1 record)
    begin

      set @searchType   = 'SID'

      insert
        @selected
      (
        EntitySID
      )
      select
        au.ApplicationUserSID
      from
        sf.ApplicationUser au
      where
        au.ApplicationUserSID = @ApplicationUserSID                        -- perform the search to validate the value passed in

      if @@rowcount = 0
      begin

        exec sf.pMessage#Get
           @MessageSCD  = 'RecordNotFound'
          ,@MessageText = @errorText output
          ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
          ,@Arg1        = 'Application User'
          ,@Arg2        = @ApplicationUserSID

        raiserror(@errorText, 18, 1)
      end

    end
    else if @TemplateOnly = @ON                                           -- user records marked as templates
    begin

      set @searchType = 'Template'

      insert
        @selected
      (
        EntitySID
      )
      select
         au.ApplicationUserSID
      from
        sf.vApplicationUser au
      where
        au.IsTemplate = @ON
      order by
        au.FileAsName

    end
    else if @AccessingNowOnly = @ON
    begin

      set @searchType = 'ActiveNow'

      insert
        @selected
      (
        EntitySID
      )
      select
         au.ApplicationUserSID
      from
        sf.vApplicationUser#Ext au
      where
        au.IsAccessingNow = @ON
      order by
        au.FileAsName

    end
    else if @SearchString is not null
    begin

      set @searchType = 'Name'

     -- the logic for determining what name components have been entered into the search string is encapsulated in the
      -- library sproc; note that if a name component is null, then a '%' is returned to avoid filtering on the null

      exec sf.pSearchName#Split
        @SearchName   = @SearchString
       ,@LastName     = @lastName       output
   ,@FirstName    = @firstName      output
       ,@MiddleNames  = @middleNames    output

      set @SearchString = ltrim(rtrim(@searchString))											-- format for UserName search option

			set @ModuleSCD = isnull(@ModuleSCD, '~')

      if @LastName is null set @LastName = N'%'

      insert
        @selected
      (
			  EntitySID
      )
      select top(@maxRows)
         au.ApplicationUserSID
      from
        sf.vApplicationUser au
			left outer join
			(
				select
					 aug.ApplicationUserSID
					,aug.ModuleSCD
				from
					sf.vApplicationUserGrant aug
				where
					aug.ModuleSCD = @ModuleSCD
				group by
					 aug.ApplicationUserSID
					,aug.ModuleSCD
			) module on au.ApplicationUserSID = module.ApplicationUserSID
      where
      (
        (
          au.LastName like @lastName
        and
          (
            @firstName is null																						-- if no first name provided, only needs to match on last name
            or
            au.FirstName like @firstName                                  -- or first name is matched
            or
            au.FirstName like @middleNames                                -- or first name matches with middle names component
            or
            au.MiddleNames like @middleNames                              -- or middle names match
            or
            au.MiddleNames like @firstName                                -- or middle name matches the first name provided
          )
        )
        or
          au.UserName like @searchString + N'%'                           -- check if value entered was a UserName or like a username
        or
          au.FirstName like @SearchString + N'%'													-- or like a first name on its own
      )
      and
				(au.IsActive = @ON or @IncludeInactive = @ON)
			and
				(@ModuleSCD = '~' or module.ModuleSCD is not null)							-- if module is provided ensure the user has a grant in the module
      and
        au.ApplicationUserSID <> @ExcludeThisSID                          -- not an excluded SID, (or no excluded SID passed)
      order by
        au.FileAsName

    end
    else
    begin

      exec sf.pMessage#Get
         @MessageSCD    = 'SearchOptionSetNotValid'
        ,@MessageText   = @errorText output
        ,@DefaultText   = N'A recognized search option set was not selected.  You must either enter search text, click a quick search button, or select a query from the drop down.'

      raiserror(@errorText, 16, 1)

    end

    -- return all columns from the entity for key values stored into the memory table
    -- the same sort order is used by all searches so apply it to the dataset here
    -- (this allows queries above to avoid selecting against the entity in some cases)

    select
      --!<ColumnList DataSource="sf.vApplicationUser" Alias="au" Exclude="IsDeleteEnabled">
       au.ApplicationUserSID
      ,au.PersonSID
      ,au.CultureSID
      ,au.AuthenticationAuthoritySID
      ,au.UserName
      ,au.LastReviewTime
      ,au.LastReviewUser
      ,au.IsPotentialDuplicate
      ,au.IsTemplate
      ,au.GlassBreakPassword
      ,au.LastGlassBreakPasswordChangeTime
      ,au.Comments
      ,au.IsActive
      ,au.AuthenticationSystemID
      ,au.ChangeAudit
      ,au.UserDefinedColumns
      ,au.ApplicationUserXID
      ,au.LegacyKey
      ,au.IsDeleted
      ,au.CreateUser
      ,au.CreateTime
      ,au.UpdateUser
      ,au.UpdateTime
      ,au.RowGUID
      ,au.RowStamp
      ,au.AuthenticationAuthoritySCD
      ,au.AuthenticationAuthorityLabel
      ,au.AuthenticationAuthorityIsActive
      ,au.AuthenticationAuthorityIsDefault
      ,au.AuthenticationAuthorityRowGUID
      ,au.CultureSCD
      ,au.CultureLabel
      ,au.CultureIsDefault
      ,au.CultureIsActive
      ,au.CultureRowGUID
      ,au.GenderSID
      ,au.NamePrefixSID
      ,au.FirstName
      ,au.CommonName
      ,au.MiddleNames
      ,au.LastName
      ,au.BirthDate
      ,au.DeathDate
      ,au.HomePhone
      ,au.MobilePhone
      ,au.IsTextMessagingEnabled
      ,au.ImportBatch
      ,au.PersonRowGUID
      ,au.ChangeReason
      ,au.IsReselected
      ,au.IsNullApplied
      ,au.zContext
      ,au.ApplicationUserSessionSID
      ,au.SessionGUID
      ,au.FileAsName
      ,au.FullName
      ,au.DisplayName
      ,au.PrimaryEmailAddress
      ,au.PrimaryEmailAddressSID
      ,au.PreferredPhone
      ,au.LoginCount
      ,au.NextProfileReviewDueDate
      ,au.IsNextProfileReviewOverdue
      ,au.NextGlassBreakPasswordChangeDueDate
      ,au.IsNextGlassBreakPasswordOverdue
      ,au.GlassBreakCountInLast24Hours
      ,au.License
      ,au.IsSysAdmin
      ,au.LastDBAccessTime
      ,au.DaysSinceLastDBAccess
      ,au.IsAccessingNow
      ,au.IsUnused
      ,au.TemplateApplicationUserSID
      ,au.LatestUpdateTime
      ,au.LatestUpdateUser
      ,au.DatabaseName
      ,au.IsConfirmed
      ,au.AutoSaveInterval
      ,au.IsFederatedLogin
      ,au.DatabaseDisplayName
      ,au.DatabaseStatusColor
      ,au.ApplicationGrantXML
      ,au.Password
      --!</ColumnList>
			,cast(0 as bit)					IsDeleteEnabled
      ,@searchType            SearchType
    from
      sf.vApplicationUser au
    join
      @selected  x on au.ApplicationUserSID = x.EntitySID
    order by
      au.FileAsName

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
