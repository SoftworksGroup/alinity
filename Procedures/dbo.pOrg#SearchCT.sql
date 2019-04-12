SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pOrg#SearchCT]
	 @SearchString                nvarchar(150) = null	-- organization name, label or tag to search
	,@CitySID											int           = null  -- filter: returns only organizations with this city assigned
	,@RegionSID										int           = null  -- filter: returns only organizations with this region assigned
	,@IsEmployer									bit						= null	-- filter: returns both employers and non-employers when passed as null
	,@IsCredentialAuthority				bit						= null	-- filter: returns both credentialing authorities non-CAs when passed as null
	,@IsAdminReviewRequired				bit						= null	-- filter: returns both records where admin review is and is-not required when null
	,@IsActive										bit						= 1			-- filter: returns both active and inactive organizations when passed as null
	,@LastUpdateStart							date 					= null	-- earliest update date for which to bring back records - combined
	,@LastUpdateEnd								date					= null	-- last update date for which to bring back records - combined
	,@QuerySID                    int           = null	-- SID of sf.Query row providing SQL syntax to execute - not combined
	,@QueryParameters			        xml						= null	-- list of query parameters associated with the query SID
	,@IsPinnedSearch							bit						= 0			-- quick search: only returns pinned records - not combined
	,@SIDList											xml           = null	-- quick search: list of pinned records to return (xml contains SID's)
	,@RecordSID										int						= null	-- quick search: returns records based on system ID
	,@RecordXID										varchar(150)	= null	-- quick search: returns records based on an external ID
	,@LegacyKey										nvarchar(50)	= null	-- quick search: returns records based on a legacy key
	,@IsFilterExcluded						bit						= 0			-- when 1, then filter values are excluded even when populated
	,@IsRowLimitEnforced					bit						= 1			-- when 0, the limit of maximum rows to return is not enforced (see below)
as
/*********************************************************************************************************************************
Procedure : Organization Search
Notice    : Copyright © 2017 Softworks organization Inc.
Summary   : Searches the Organization entity for the search string and/or other search criteria provided
History   : Author(s)   | Month Year  | Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Jul 2017		| Initial version
					: Robin Payne	| July 2017		| Added o.FullOrgLabel	o.CredentialCount	o.EmploymentCount	o.IsActive	o.IsNextReviewDue	o.CityName
					:							|							| Updated to order by Org Label

Comments
--------
This procedure supports dashboard displays and general searches of the "Organization" entity from the UI. Various search
options are supported but the primary method is to SELECT for a search string entered by the end user with various filters
optionally applied. The string typically contains a organization name, label or tag value.

The procedure detects if the user accessing the search is an Administrator by testing for existence of the "ADMIN.BASE" grant.
If that grant is not detected, then the procedure assumes the current user only has access to the organizations to which they
have been assigned as an owner or as a Review Administrator.  (The IsReviewAdmin bit in dbo.OrgContact). The search results then,
are filtered for this criteria at the end of the procedure.

Complex Type CT
---------------
This search procedure does not return the default entity but rather a complex type. A corresponding view also exists against
which the search is performed.  The complex type is used to improve performance.

Default search
--------------
If no search string or custom query is passed to the procedure the default search is executed. The default search returns all
Organizations (limited by Max Rows).

Row Limit (MaxRows)
---------
The number of records returned on any search is limited by a configuration parameter setting "MaxRowsOnSearch" which if not set,
defaults to 200. The maximum is implemented to avoid timeout errors on rendering complex result layouts - particularly on slower
mobile-phone based connections.  The limit can be turned off by passing @IsRowLimitEnforced as 0 (it defaults to ON).

Filters
-------
Filters are applied in combination with text searches but do not apply when a query identifier has been passed in.  Filters are
based on foreign key or bit values on the main entity and can generally be applied without significantly increasing processing
time assuming appropriate indexing.

pSearchParam#Check (SF)
-----------------------
A subroutine in the framework is called to check parameters passed in and to format the text string and retrieve configuration
settings. The procedure is applied by all (current) search procedures and implements  formatting and priority-setting branching
critical to the searching process.  Be sure to review the documentation in that procedure thoroughly in order to debug issues
in search execution.

Text/String search
------------------
The search is performed against the organization's full name or tag value. For name and tag components, wild cards are supported within
the text entered.  A trailing "%" is always added to the search string but a leading "%" is not added in order to preserve use
of indexes.  If a user wishes to search for records matching a tag ending, a leading wildcard must be entered - e.g. "%committee".

Dynamic queries
---------------
When the @QuerySID parameter is passed, then a dynamic query is executed from sf.Query.  The query syntax is retrieved from
and executed through a subroutine. This feature supports configuration-specific (custom) queries to be added to the installation.
See sf.pQuery#Search for additional details.  Queries are executed independently of the Filter criteria (not combined) but the
removal of records not accessible to users is applied within the procedure when a non-group administrator user is detected.

System Identifier Searches
--------------------------

@RecordSID search ("SID: 12345")
@RecordXID search ("XID: AB12345")
@LegacyKey search	("LegacyKey: XYZ1111")

The procedure supports searches on 3 possible key values entered explicitly by including a prefix in the search string.  The
first is a search on the primary key of the entity.  It can be invoked by passing the parameter directly, or by entering the
keyword "SID:" followed by a number into the @SearchString - e.g. "SID:1234567". The digits are stripped from the string and
converted into the parameter value by the procedure.  The conversion only takes place if all values following "SID:" are digits.
By allowing system ID's to the be entered into search string, administrators and configurators are able to trouble shoot error
messages that return SID's using the application's user interface.  The other 2 options are similar except that no validation
occurs for a specific data type.  The search against external ID's (XID) and LegacyKey are wildcard based so passing a partial
value will result in found records.  For Legacy-Key both the prefix "LegacyKey:" and "LKey:" are supported.

Sort order
----------
This procedure orders all results by name but other sort orders can be set in the UI.

Use of Memory Table
-------------------
The application standard for search procedures is to retrieve key values of records matching the search into a temporary table,
and then join from that table to create the result set.  This technique, while more complex than direct SELECT's, generally
improves performance since complex columns returned to the UI for display only can be excluded from retrieval logic.

Example:
--------
<TestHarness>
	<Test Name = "OrgSID" IsDefault ="true" Description="Finds the Org with the corresponding OrgSID">
    <SQLScript>
      <![CDATA[

			declare
				@OrgSID    int

			select top 1
				@OrgSID = c.OrgSID
			from
				dbo.Org c
			order by
				newid()

			exec dbo.pOrg#SearchCT
				@SearchString = 'TODO: was -> exec dbo.pOrg#Search @OrgSID = @OrgSID'

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
  <Test Name = "FullName" IsDefault ="false" Description="Finds a Org by it's full name.">
    <SQLScript>
      <![CDATA[

				declare
					@randomOrg nvarchar(150)

				select top 1
					@randomOrg = c.OrgName
				from
					dbo.Org c
				order by
					newid()

				exec dbo.pOrg#Search
					@SearchString = @randomOrg

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "PartialName" IsDefault ="false" Description="Finds Org by partial name.">
    <SQLScript>
      <![CDATA[

			declare
			 @randomOrg nvarchar(150)
			,@randomOrgPartial nvarchar(150)

			select top 1
				@randomOrg = OrgName
			from
				dbo.Org
			order by
				newid()

			select @randomOrgPartial = substring(@randomOrg, 2, 3)

			exec dbo.pOrg#SearchCT
			@SearchString = @randomOrgPartial

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
		<Test Name = "OrgQuery" IsDefault ="false" Description="Finds countries by passing in a query">
    <SQLScript>
      <![CDATA[

				declare
					@querySID      int

				select top 1
					@querySID = q.QuerySID
				from
					sf.vQuery q
				where
					q.ApplicationEntitySCD = 'dbo.Org'
				and
					q.QueryParameters is null
				order by
					newid()

				exec dbo.pOrg#SearchCT
					@QuerySID = @querySID

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "WildCard" IsDefault ="false" Description="Finds Org by a partial name with wildcard tokens.">
    <SQLScript>
      <![CDATA[

				declare
				 @randomOrg nvarchar(150)
				,@randomOrgPartial nvarchar(150)

				select top 1
					@randomOrg = OrgName
				from
					dbo.Org
				order by
					newid()

				set @randomOrgPartial = substring(@randomOrg, 2, 3)
				set @randomOrgPartial = replace(@randomOrgPartial, substring(@randomOrgPartial, 2,1), '_')

				exec dbo.pOrg#SearchCT
				@SearchString = @randomOrgPartial

			]]>
    </SQLScript>
		<Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'sf.pOrg#SearchCT'
	,	@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
			@errorNo													int = 0                           -- 0 no error, <50000 SQL error, else business rule
		,	@errorText												nvarchar(4000)                    -- message text (for business rule errors)
		,	@ON																bit = cast(1 as bit)              -- used on bit comparisons to avoid multiple casts
		,	@OFF															bit = cast(0 as bit)              -- used on bit comparisons to avoid multiple casts
		,	@searchType												varchar(25)                       -- type of search; returned in result for debugging
		,	@maxRows													int                               -- maximum rows allowed on search
		, @queryMaxRows											int																-- maximum rows allowed on preliminary query
		,	@isAdmin													bit																-- indicates user is an administrator and can see all records
		, @applicationUserSID								int																-- key of logged in user in sf.ApplicationUser
		,	@personSID												int	= -1													-- key of logged in user in the sf.Person table

	declare
		@selected													table																-- stores primary key values of records found
		(
				ID                            int identity(1, 1)  not null				-- identity to track add order - preserves custom sorts
			,	EntitySID                     int                 not null				-- record ID joined to main entity to return results
			, OrgLabel											nvarchar(100)				null					-- column required only to comply with rules for "select distinct" not used
		)

	declare
		@pinned														table																-- stores primary key value of pinned records
		(
				ID                            int identity(1, 1)  not null
			,	EntitySID                     int                 not null
		)

	begin try

		-- if filters are to be excluded, set them to null
		-- (passed by the front end in order not to lose values from UI)

		if @IsFilterExcluded = @ON
		begin
			set @ApplicationUserSID      = null
			set @IsActive								 = null
		end

		-- call a subroutine to validate and format search parameters and
		-- to return list of pinned records for this user (if any)

		insert
			@pinned
		(
			EntitySID
		)
		exec sf.pSearchParam#Check																						-- check parameters and format for searching
				@SearchString				= @SearchString						output
			,	@DateRangeStart			= @LastUpdateStart				output
			,	@DateRangeEnd				= @LastUpdateEnd					output
			,	@RecordSID					= @RecordSID							output
			,	@RecordXID					= @RecordXID							output
			, @LegacyKey					= @LegacyKey							output
			,	@MaxRows						= @maxRows								output
			,	@ApplicationUserSID	= @applicationUserSID			output
			,	@ConvertDatesToST		= @ON
			,	@PinnedPropertyName	= 'PinnedOrgList'

		set @isAdmin = sf.fIsGranted('ADMIN.BASE')														-- if not an admin, records returned are restricted

		if @IsRowLimitEnforced = @OFF set @maxRows = 999999999								-- if row limit is not being enforced, set max rows to a billion

		if @isAdmin = @OFF
		begin

			select																															-- look up person key of current user for access filtering below
				@personSID = au.PersonSID
			from
				sf.ApplicationUser au
			where
				au.ApplicationUserSID = @applicationUserSID

			-- for reviewers the query limit is turned off so that filtering
			-- to assigned records at end of sproc can consider all eligible rows

			set @queryMaxRows = 999999999

		end
		else
		begin
			set @queryMaxRows = @maxRows
		end

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
				 @QuerySID				= @QuerySID
				,@QueryParameters = @QueryParameters
				,@MaxRows					= @queryMaxRows																	-- query syntax may support restriction on max rows so pass it

		end
		else if @SIDList is not null																					-- set of specific SIDs passed or pinned record search
		begin

			set @searchType   = 'Identifiers'

			insert
				@selected
			(
				EntitySID
			)
			select top (@queryMaxRows)																					-- parse attributes from the XML parameter document
				EntitySID.r.value('.','int')	EntitySID														-- return rows matching list of SID's passed in XML doc
			from
				@SIDList.nodes('//EntitySID') as EntitySID(r)

		end
		else if @IsPinnedSearch = @ON																					-- returned pinned records (retrieved by#Check)
		begin

			set @searchType   = 'Pins'

			insert
				@selected
			(
				EntitySID
			)
			select top (@maxRows)
				p.EntitySID
			from
				@pinned p

		end
		else if coalesce(@RecordSID, @RecordXID, @LegacyKey) is not null			-- specific system ID was passed in search text
		begin

			if @RecordSID is not null set @searchType = 'SID'
			if @RecordXID is not null set @searchType = 'XID'
			if @LegacyKey is not null set @searchType = 'LegacyKey'

			insert
				@selected
			(
				EntitySID
			)
			select
				o.OrgSID
			from
				dbo.Org o
			where
				o.OrgSID = @RecordSID																							-- no filters apply on this search
			or
				isnull(o.OrgXID, '!~@') = @RecordXID
			or
				isnull(o.LegacyKey, '!~@') = @LegacyKey

			if @@rowcount = 0																										-- failure to find the record is unexpected in this scenario!
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The "%1" record was not found. Record ID = %2. The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'Organization'
					,@Arg2        = @RecordSID

				raiserror(@errorText, 16, 1)

			end

		end
		else if @SearchString is not null or @CitySID is not null or @RegionSID is not null or @IsEmployer is not null or @IsCredentialAuthority is not null or @IsAdminReviewRequired is not null or @IsActive is not null
		begin
			
			if @SearchString is not null and left(@SearchString, 1) <> N'%' 
			begin
				set @SearchString = cast(N'%' + @SearchString as nvarchar(150))     -- add % to start of string if not already there
			end

			set @searchType = 'Text'

			insert
				@selected
			(
					EntitySID
				,	OrgLabel
			)
			select distinct top (@queryMaxRows)																	-- multi-rows for tag list so select distinct!
					otd.OrgSID
				,	otd.OrgLabel
			from
				dbo.vOrg#TagDetail otd
			where
			(
				@SearchString is null
				or
				otd.OrgName like @SearchString																		-- search against organization name
				or
				otd.OrgLabel like @SearchString																		-- and organization label
				or
				otd.FullOrgLabel like @SearchString																-- and against org label that includes parent name
				or
				otd.Tag like @SearchString																				-- and tag list
			)
			and																																	-- and then apply all filters
				otd.CitySID = isnull(@CitySID, otd.CitySID)
			and
				otd.RegionSID = isnull(@RegionSID, otd.RegionSID)
			and
				otd.IsEmployer = isnull(@IsEmployer, otd.IsEmployer)
			and
				otd.IsCredentialAuthority = isnull(@IsCredentialAuthority, otd.IsCredentialAuthority)
			and
				otd.IsAdminReviewRequired = isnull(@IsAdminReviewRequired, otd.IsAdminReviewRequired)
			and
				otd.IsActive = isnull(@IsActive, otd.IsActive)
			and
				otd.UpdateTime >= @LastUpdateStart
			and
				otd.UpdateTime <= @LastUpdateEnd
			order by
				otd.OrgLabel

		end
		else																																	-- default search is all organizations to limit
		begin

			set @searchType = 'Default'

			insert
				@selected
			(
				EntitySID
			)
			select top (@queryMaxRows)
				o.OrgSID
			from
				dbo.Org o
			where
				o.IsActive = isnull(@IsActive, o.IsActive)
			and
				o.UpdateTime >= @LastUpdateStart
			and
				o.UpdateTime <= @LastUpdateEnd
			order by
				o.OrgLabel

		end

		-- return only the columns required for display joining to the @selected
		-- table to apply found records, and to @pinned to apply pin attribute

		select top (@maxRows)
				o.OrgSID
			,	o.OrgLabel
			, o.CityName
			,	o.OrgName
			,	o.FullOrgLabel
			,	o.CredentialCount
			,	o.EmploymentCount
			,	o.IsActive
			,	o.IsNextReviewDue
			,	o.IsAdminReviewRequired
			,	o.IsCredentialAuthority
			,	o.IsEmployer
			, o.HtmlAddress
			, o.Phone
			, o.Comments
			, o.TagList
			,	cast(isnull(z.EntitySID,0) as bit)		IsPinned										-- if key found in pinned list then @ON else @OFF
			,	@searchType														SearchType                  -- search type for debugging - ignored by UI
		from
			dbo.vOrg#Search	o
		join
			@selected				x		on o.OrgSID = x.EntitySID
		left outer join
			@pinned					z		on o.OrgSID = z.EntitySID
		left outer join
			dbo.OrgContact	oc	on o.OrgSID = oc.OrgSID and oc.PersonSID = @personSID and oc.IsReviewAdmin = @ON and sf.fIsActive(oc.EffectiveTime, oc.ExpiryTime) = @ON
		where
		(
			@isAdmin = @ON																											-- administrators have full access
		or
		 oc.OrgContactSID is not null																					-- or the user is a reviewer for this organization
		)
		order by
			 o.OrgLabel

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
