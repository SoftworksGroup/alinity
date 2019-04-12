SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pOrgContact#Search]
   @SearchString        nvarchar(140)   = null    -- name string to search, "last, first middle" or partial
  ,@IncludeInactive     bit             = 1       -- name search modifier - when OFF then only records where IsInactive = 0
  ,@QuerySID            int             = null    -- dynamic query: SID of sf.Query row providing SQL syntax to execute
	,@QueryParameters			xml							= null		-- dynamic query: list of query parameters associated with the query SID
	,@IsReviewAdmin		bit							= null		-- filter: employers that can verify applications
  ,@Identifiers         xml             = null    -- quick search: list of pinned records to return (xml contains SID's)
  ,@OrgContactSID				int             = null    -- quick search: returns a specific OrgContact based on system ID
  ,@ExcludeThisSID      int             = null    -- name search modifier: a SID to filter out (to avoid current user record)
as
/*********************************************************************************************************************************
Procedure : Org Contact Search
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Searches the OrgContact entity for the search string and search options provided
History   : Author(s)   | Month Year  | Change Summary
          : ------------|-------------|-----------------------------------------------------------------------------------------
          : Cory Ng		  | Jun   2016  | Initial version
					
Comments
--------
This procedure executes various types of searches against the dbo.OrgContact entity.

Text search
-----------
The search string is assumed to contain name values. These values are split into first, middle and last name components according
to logic applied by the library procedure:  sf.pSearchName#Split. That procedure assumes that if a comma is included in the
string, then the last name component has been provided to the left of the comma followed the first name a space and a middle name.
If no comma is included but one or more spaces exist within the trimmed string, then the logic assumes the first name is provided
first.  If a second space exists then the middle name is next followed by the last name.  If only 2 words exist within the text
provided then they are assumed to be first and last name components. A single string is assumed to the last name, or the first
name or a OrgContact number - so all 3 columns are searched.

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

@IsReviewAdmin filter
---------------------------
The @IsReviewAdmin is consided on text searches so that if this value is passed it only returns employers
that have the authority to verify applications.


@OrgContactSID search
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
  q.ApplicationEntitySCD = 'dbo.OrgContact'
order by
  newid()

exec dbo.pOrgContact#Search
  @QuerySID = @querySID

exec dbo.pOrgContact#Search																								-- string search
  @SearchString = N'Edlund, Tim     e'

exec sf.pOrgContact#Search																								-- with wildcard
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
)      exec sf.pQuery#Execute
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
				 OrgContact.p.value('@EntitySID[1]','int')			OrgContactSID					
			from
				@Identifiers.nodes('//Entity') as OrgContact(p)

    end
    else if @OrgContactSID is not null																		-- specific SID passed  (1 record)
    begin

      set @searchType   = 'SID'

      insert
        @selected
      (
        EntitySID
      )
      select
        r.OrgContactSID
      from
        dbo.OrgContact r
      where
        r.OrgContactSID = @OrgContactSID																	-- perform the search to validate the value passed in

      if @@rowcount = 0
      begin

        exec sf.pMessage#Get
           @MessageSCD  = 'RecordNotFound'
          ,@MessageText = @errorText output
          ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
          ,@Arg1        = 'OrgContact'
          ,@Arg2        = @OrgContactSID

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

      set @SearchString = ltrim(rtrim(@searchString))											-- format for OrgContactNo search option

      if @LastName is null set @LastName = N'%'

      insert
        @selected
      (
			  EntitySID
      )
      select top(@maxRows)
         oc.OrgContactSID
      from
        dbo.vOrgContact oc
			join
				sf.vPerson p on oc.PersonSID = p.PersonSID
      where
      (
        (
          oc.LastName like @lastName
        and
          (
            @firstName is null																						-- if no first name provided, only needs to match on last name
            or
            oc.FirstName like @firstName																	-- or first name is matched
            or
            oc.FirstName like @middleNames																-- or first name matches with middle names component
            or
            oc.MiddleNames like @middleNames															-- or middle names match
            or
            oc.MiddleNames like @firstName																-- or middle name matches the first name provided
          )
        )
        or
          oc.FirstName like @SearchString + N'%'													-- or like a first name on its own
      )
      and
				(@IncludeInactive = @ON or oc.IsActive = @ON)
			and
				(@IsReviewAdmin = @OFF or oc.IsReviewAdmin = @ON)
      and
        oc.OrgContactSID <> @ExcludeThisSID																-- not an excluded SID, (or no excluded SID passed)
      order by
        p.FileAsName

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
      --!<ColumnList DataSource="dbo.vOrgContact" Alias="oc">
       oc.OrgContactSID
      ,oc.OrgSID
      ,oc.PersonSID
      ,oc.EffectiveTime
      ,oc.ExpiryTime
      ,oc.IsReviewAdmin
      ,oc.Title
      ,oc.DirectPhone
      ,oc.IsAdminContact
      ,oc.OwnershipPercentage
      ,oc.TagList
      ,oc.ChangeLog
      ,oc.UserDefinedColumns
      ,oc.OrgContactXID
      ,oc.LegacyKey
      ,oc.IsDeleted
      ,oc.CreateUser
      ,oc.CreateTime
      ,oc.UpdateUser
      ,oc.UpdateTime
      ,oc.RowGUID
      ,oc.RowStamp
      ,oc.ParentOrgSID
      ,oc.OrgTypeSID
      ,oc.OrgName
      ,oc.OrgLabel
      ,oc.StreetAddress1
      ,oc.StreetAddress2
      ,oc.StreetAddress3
      ,oc.CitySID
      ,oc.PostalCode
      ,oc.RegionSID
      ,oc.Phone
      ,oc.Fax
      ,oc.WebSite
      ,oc.EmailAddress
      ,oc.InsuranceOrgSID
      ,oc.InsurancePolicyNo
      ,oc.InsuranceAmount
      ,oc.IsEmployer
      ,oc.IsCredentialAuthority
      ,oc.IsInsurer
      ,oc.IsInsuranceCertificateRequired
      ,oc.IsPublic
      ,oc.OrgIsActive
      ,oc.IsAdminReviewRequired
      ,oc.LastVerifiedTime
      ,oc.OrgRowGUID
      ,oc.GenderSID
      ,oc.NamePrefixSID
      ,oc.FirstName
      ,oc.CommonName
      ,oc.MiddleNames
      ,oc.LastName
      ,oc.BirthDate
      ,oc.DeathDate
      ,oc.HomePhone
      ,oc.MobilePhone
      ,oc.IsTextMessagingEnabled
      ,oc.ImportBatch
      ,oc.PersonRowGUID
      ,oc.IsActive
      ,oc.IsPending
      ,oc.IsDeleteEnabled
      ,oc.IsReselected
      ,oc.IsNullApplied
      ,oc.zContext
      ,oc.IsOwner
      ,oc.RegistrantEmploymentSID
			--!</ColumnList>
			,@searchType
		from
			dbo.vOrgContact      oc
		join
			sf.vPerson					 p on oc.PersonSID = p.PersonSID
    join
      @selected  x on oc.OrgContactSID = x.EntitySID
    order by
      p.FileAsName

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch

  return(@errorNo)

end
GO
