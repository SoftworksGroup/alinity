SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrant#Search]
   @SearchString        nvarchar(140)   = null    -- name string to search, "last, first middle" or partial or RegistrantNo
  ,@IncludeInactive     bit             = 1       -- name search modifier - when OFF then only records with a active registration
  ,@QuerySID            int             = null    -- dynamic query: SID of sf.Query row providing SQL syntax to execute
	,@QueryParameters			xml							= null		-- dynamic query: list of query parameters associated with the query SID
	,@PracticeRegisterSID	int							= null		-- filter: registrants with the practice register as their current registration
  ,@Identifiers         xml             = null    -- quick search: list of pinned records to return (xml contains SID's)
  ,@RegistrantSID				int             = null    -- quick search: returns a specific Registrant based on system ID
  ,@ExcludeThisSID      int             = null    -- name search modifier: a SID to filter out (to avoid current user record)
as
/*********************************************************************************************************************************
Procedure : Registrant Search
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Searches the Registrant entity for the search string and search options provided
History   : Author(s)   | Month Year  | Change Summary
          : ------------|-------------|-----------------------------------------------------------------------------------------
          : Cory Ng		  | Jun   2016  | Initial version
					: Kris Dawson	| Nov		2016	| Removed commented code, updated to support include inactive and practice register again
					
Comments
--------
This procedure executes various types of searches against the dbo.Registrant entity.

Text search
-----------
The search string is assumed to contain name values. These values are split into first, middle and last name components according
to logic applied by the library procedure:  sf.pSearchName#Split. That procedure assumes that if a comma is included in the
string, then the last name component has been provided to the left of the comma followed the first name a space and a middle name.
If no comma is included but one or more spaces exist within the trimmed string, then the logic assumes the first name is provided
first.  If a second space exists then the middle name is next followed by the last name.  If only 2 words exist within the text
provided then they are assumed to be first and last name components. A single string is assumed to the last name, or the first
name or a registrant number - so all 3 columns are searched.

Wildcard characters: *, %, ?, _ are allowed in string searches.

The @IncludeInactive bit is considered on text searches so that if this bit is passed as OFF, unlike other search procedures this
bit does not look for a IsActive flag on the Registrant record. It looks to see if a current registration is assigned to the registrant.

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

@PracticeRegisterSID filter
---------------------------
The @PracticeRegisterSID is considered on text searches so that if this value is passed it only returns registrants that have
a current registration with this practice register assigned.

@RegistrantSID search
--------------------------
This search returns a specific record based on the system ID.

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

select top 1
  @querySID = q.QuerySID
from
  sf.vQuery q
where
  q.ApplicationEntitySCD = 'dbo.Registrant'
order by
  newid()

exec dbo.pRegistrant#Search
  @QuerySID = @querySID

exec dbo.pRegistrant#Search																								-- string search
  @SearchString = N'Edlund, Tim     e'

exec sf.pRegistrant#Search																								-- with wildcard
  @SearchString = N'E?lund,'

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
      select																															-- parse attributes from the XML parameter document
				 Registrant.p.value('@EntitySID[1]','int')			RegistrantSID					
			from
				@Identifiers.nodes('//Entity') as Registrant(p)

    end
    else if @RegistrantSID is not null																		-- specific SID passed  (1 record)
    begin

      set @searchType   = 'SID'

      insert
        @selected
      (
        EntitySID
      )
      select
        r.RegistrantSID
      from
        dbo.Registrant r
      where
        r.RegistrantSID = @RegistrantSID																	-- perform the search to validate the value passed in

      if @@rowcount = 0
      begin

        exec sf.pMessage#Get
           @MessageSCD  = 'RecordNotFound'
          ,@MessageText = @errorText output
          ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
          ,@Arg1        = 'Registrant'
          ,@Arg2        = @RegistrantSID

        raiserror(@errorText, 18, 1)
      end

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

      set @SearchString = ltrim(rtrim(@searchString))											-- format for RegistrantNo search option

      if @LastName is null set @LastName = N'%'

      insert
        @selected
      (
			  EntitySID
      )
      select distinct top(@maxRows)
         r.RegistrantSID
      from
        dbo.Registrant	r
			join
				sf.Person				p on r.PersonSID = p.PersonSID
			left outer join
				dbo.Registration rl on r.RegistrantSID = rl.RegistrantSID and sf.fIsActive(rl.EffectiveTime, rl.ExpiryTime) = @ON
      where
      (
        (
          p.LastName like @lastName
        and
          (
            @firstName is null																						-- if no first name provided, only needs to match on last name
            or
            p.FirstName like @firstName																		-- or first name is matched
            or
            p.FirstName like @middleNames																	-- or first name matches with middle names component
            or
            isnull(p.MiddleNames, '!') like @middleNames									-- or middle names match
            or
            isnull(p.MiddleNames, '!') like @firstName										-- or middle name matches the first name provided
          )
        )
        or
          r.RegistrantNo like @searchString + N'%'                        -- check if value entered was a RegistrantNo or like a RegistrantNo
        or
          p.FirstName like @SearchString + N'%'														-- or like a first name on its own
      )
			and
				(@IncludeInactive = @ON or rl.RegistrationSID is not null)
      and
        r.RegistrantSID <> @ExcludeThisSID																-- not an excluded SID, (or no excluded SID passed)

			if @PracticeRegisterSID is not null																	-- if filtered by register remove records without a registration
			begin

				delete from sel
				from
					@selected sel
				where
					not exists
					(
						select
							1
						from
							dbo.vRegistration rl
						join
							dbo.vPracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
						where
							rl.RegistrantSID = sel.EntitySID
						and
							(@IncludeInactive = @ON or rl.IsActive = @ON)
						and
							prs.PracticeRegisterSID = @PracticeRegisterSID
					)
					
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

    -- return all columns from the entity for key values stored into the memory table
    -- the same sort order is used by all searches so apply it to the dataset here
    -- (this allows queries above to avoid selecting against the entity in some cases)

    select
      --!<ColumnList DataSource="dbo.vRegistrant" Alias="r">
       r.RegistrantSID
      ,r.PersonSID
      ,r.RegistrantNo
      ,r.YearOfInitialEmployment
      ,r.IsOnPublicRegistry
      ,r.CityNameOfBirth
      ,r.CountrySID
      ,r.DirectedAuditYearCompetence
      ,r.DirectedAuditYearPracticeHours
      ,r.LateFeeExclusionYear
      ,r.IsRenewalAutoApprovalBlocked
      ,r.RenewalExtensionExpiryTime
      ,r.PublicDirectoryComment
      ,r.ArchivedTime
      ,r.UserDefinedColumns
      ,r.RegistrantXID
      ,r.LegacyKey
      ,r.IsDeleted
      ,r.CreateUser
      ,r.CreateTime
      ,r.UpdateUser
      ,r.UpdateTime
      ,r.RowGUID
      ,r.RowStamp
      ,r.GenderSID
      ,r.NamePrefixSID
      ,r.FirstName
      ,r.CommonName
      ,r.MiddleNames
      ,r.LastName
      ,r.BirthDate
      ,r.DeathDate
      ,r.HomePhone
      ,r.MobilePhone
      ,r.IsTextMessagingEnabled
      ,r.ImportBatch
      ,r.PersonRowGUID
      ,r.CountryName
      ,r.ISOA2
      ,r.ISOA3
      ,r.ISONumber
      ,r.IsStateProvinceRequired
      ,r.CountryIsDefault
      ,r.CountryIsActive
      ,r.CountryRowGUID
      ,r.IsDeleteEnabled
      ,r.IsReselected
      ,r.IsNullApplied
      ,r.zContext
      ,r.RegistrantLabel
      ,r.FileAsName
      ,r.DisplayName
      ,r.EmailAddress
      ,r.RegistrationSID
      ,r.RegistrationNo
      ,r.PracticeRegisterSID
      ,r.PracticeRegisterSectionSID
      ,r.EffectiveTime
      ,r.ExpiryTime
      ,r.PracticeRegisterName
      ,r.PracticeRegisterLabel
      ,r.IsActivePractice
      ,r.PracticeRegisterSectionLabel
      ,r.IsSectionDisplayedOnLicense
      ,r.LicenseRegistrationYear
      ,r.RenewalRegistrationYear
      ,r.HasOpenAudit
			--!</ColumnList>
			,@searchType
		from
			dbo.vRegistrant      r
    join
      @selected  x on r.RegistrantSID = x.EntitySID
    order by
      r.FileAsName

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
