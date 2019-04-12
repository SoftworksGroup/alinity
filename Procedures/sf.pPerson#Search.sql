SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPerson#Search]
		@SearchString					nvarchar(150)		= null													-- name text (SID) to search for
	,	@PersonGroupSID				int							= null													-- returns only (ACTIVE) people in this group (cannot be combined)
	,	@QuerySID							int							=	null													-- reference to query to run (in sf.Query)
	,	@QueryParameters			xml							= null													-- list of query parameters associated with the query SID
	,	@Identifiers					xml							= null													-- list of specific SID's to return
	,	@PersonSID						int             = null													-- quick search: returns a specific Person based on system ID
	,	@ImportBatch					nvarchar(92)		= null													-- filters person records by the import batch
	,	@ReturnSIDsOnly				bit							= 0															-- when 1 indicates only key values are to be returned
	,	@IsRowLimitEnforced		bit							= 1															-- when 0, the limit of maximum rows to return is not enforced (see below)
	,	@PreFilter						sf.RecordSID		readonly												-- table of eligible keys to restrict search results to (optional)
as
/*********************************************************************************************************************************
Procedure : Person Search
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Searches the person entity for the search string and search options provided
History   : Author(s)			| Month Year	| Change Summary
					: --------------|-------------|-----------------------------------------------------------------------------------------
					: Tyson Schulz	| Jul 2014		| Initial version
					: Tim Edlund		| Jul 2014		| Added "PersonSID" parameter.  Updated code to achieve compliance with corporate standards.
					: Tim Edlund		| Apr	2015		| Increased @MaxRows to 1000 for query and pinned record based searches
					: Tim Edlund		| Jun 2015		| Added @PreFilter parameter to support searches where a set of PersonSID's to apply
																					search against has already been defined. Note cannot be combined with all search
																					types! See doc below.
					: Tim Edlund		|	Jun 2017		| Added @IsRowLimitEnforced to enable row limit to be turned off by caller.  For queries
																					and explicit list of SID's this value should normally be passed as ON except when
																					being called from a mobile device where data limits may apply.	Also added support for
																					filtering by person group (@PersonGroupSID). Note returns ACTIVE group members only.
																					Added wildcard search on last name to support finding names like "Van der Hook".
																					Added temporary support for searching by primary ID like a patient or registration no
																					based on searching in the AuthenticationSystemID column in application-user.  NOTE:
																					this value must be moved into sf.Person.  A trigger is required in the product code to
																					keep the value updated - on dbo.Registrant in Alinity, on dbo.Episode in Synoptec.

Comments
--------
This procedure executes various types of searches against the sf.Person entity.

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

@PreFilter (limiting based records to search)
---------------------------------------------
This parameter is a table of Person SID (PK values) that can be passed to set a pre-filter on the rows in the sf.Person table
that other filtering logic in this procedure operates against.  This is an optional parameter (declaring tables as "read only"
automatically makes them optional in TSQL).  This parameter supports running a search using this procedure against a known
subset of person records such as a person group, type of patients, etc.  This allows the filtering logic - e.g. on search
strings - to be applied from this procedure without the need to duplicate it in similar routines. The @PreFilter parameter will
often be used in combination with the @ReturnSIDsOnly parameter so that the entity type returned need not be vPerson.

This parameter cannot be used in combination with all other searches supported by this procedure. Only the following search
types are supported:

	Open searches (no other filter)
	Text criteria searches
	Search for email address

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

@PersonSID search ("SID: 12345")
---------------------------------
This is a search on the primary key of the entity.  It can be invoked by passing the parameter directly, or by entering the
keyword "SID:" followed by a number into the @SearchString - e.g. "SID:1234567". The digits are stripped from the string and
converted into the parameter value by the procedure.  The conversion only takes place if all values following "SID:" are digits
(or spaces).  By allowing system ID's to the be entered into search string, administrators and configurators are able to
trouble shoot error messages that return SID's using the application's user interface.

Sort order
----------
This procedure orders all results by the "FileAsName".
Result limiting
---------------
This procedure will only return the maximum amount of rows to return as configured in the "MaxRowsOnSearch". When an open search
is called, then the only the amount of rows configured in the "MaxRowsForAutoSearch" will be returned.

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
--------

<TestHarness>
	<Test Name = "SID" IsDefault="true" Description="Finds a person record based on their system ID. Should return exactly one row.">
		<SQLScript>
			<![CDATA[
				declare
					@personSID int

				select top (1)
					@personSID = p.PersonSID
				from
					sf.Person p
				order by
					newid()

				if @@rowcount <= 0
				begin

					select 'no people found'

				end
				else
				begin
				
					exec sf.pPerson#Search
						@PersonSID = @personSID

				end

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" RowSet="1" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02" ResultSet="1" />
		</Assertions>
	</Test>
	<Test Name = "LastAndFirstName" IsDefault ="false" Description="Finds a first and last name at random and then uses procedure
	to search for them.">
		<SQLScript>
			<![CDATA[

				declare
					@searchString nvarchar(100)

				select top (1)
					 @searchString = p.LastName + ',' + p.FirstName
				from
					sf.Person p
				order by
					newid()

				if @@rowcount <= 0
				begin
					select 'no people found'
				end
				else
				begin
				
					exec sf.pPerson#Search
						@SearchString = @searchString

				end

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
		</Assertions>
	</Test>
	<Test Name = "DynamicQuery" IsDefault ="false" Description="Finds a dynamic query at random and executes it.  May or may not return rows in a
	dataset.">
		<SQLScript>
			<![CDATA[

				declare
					@querySID      int

				select top (1)
					@querySID = q.QuerySID
				from
					sf.vQuery q
				where
					q.ApplicationEntitySCD = 'sf.Person'
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
	
						exec sf.pPerson#Search
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
			<Assertion Type="ExecutionTime" Value="00:00:10" ResultSet="1" />
		</Assertions>
	</Test>
	<Test Name = "LastWildCard" IsDefault ="false" Description="Finds a person record based on a portion of their lastname plus a wildcard character.">
		<SQLScript>
			<![CDATA[

				declare
					@randomPerson nvarchar(150)
					,@randomPersonPartial nvarchar(150)

				select top (1)
						@randomPerson = p.LastName
				from
					sf.Person p
				order by
					newid()

				set @randomPersonPartial = substring(@randomPerson, 1, len(@randomPerson)-3)
				set @randomPersonPartial = replace(@randomPersonPartial, substring(@randomPersonPartial, 2,1), '_')

				exec sf.pPerson#Search
						@SearchString = @randomPersonPartial
				
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" ResultSet="1" />
		</Assertions>
	</Test>
	<Test Name = "EmailAddress" IsDefault ="false" Description="Finds a person record based on their email address. Should return exactly one row.">
		<SQLScript>
			<![CDATA[
				declare
					@searchString nvarchar(100)

				if(select count(1) from sf.PersonEmailAddress) <= 0
				begin

					select 'no people found with email addresses'

				end
				else
				begin
				
					select top (1)
						 @searchString = pea.EmailAddress
					from
						sf.PersonEmailAddress pea
					order by
						newid()

					exec sf.pPerson#Search
						@SearchString = @searchString

				end

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" RowSet="1" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02" ResultSet="1" />
		</Assertions>
	</Test>
	<Test Name = "ImportBatch" IsDefault ="false" Description="Finds person records based on an import batch string">
		<SQLScript>
			<![CDATA[

				declare
					@importBatch nvarchar(92)

				select
					@importBatch = a.ImportBatch
				from
				(
					select
						distinct  p.ImportBatch
					from
						sf.Person p	
					where
						p.ImportBatch is not null	
				) a		
				order by
					newid()
				
				if @@rowcount <= 0
				begin

					select 'no people have been imported before.'

				end
				else
				begin
				
					exec sf.pPerson#Search
						@ImportBatch = @importBatch

				end
	
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" ResultSet="1" />
		</Assertions>
	</Test>
	<Test Name="OpenSearch" IsDefault="false" Description="Finds all people, unless results exceed limit.">
		<SQLScript>
			<![CDATA[

				if(select
						count(1)
					from
						sf.Person) <= 0
				begin

					select 'no people found'

				end				else
				begin
				
					exec sf.pPerson#Search
						@SearchString = ''

				end

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pPerson#Search'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo				int = 0																								-- 0 no error, <50000 SQL error, else business rule
		,@errorText			nvarchar(4000)																				-- message text (for business rule errors)
		,@ON						bit = cast(1 as bit)																	-- used on bit comparisons to avoid multiple casts
		,@OFF						bit = cast(0 as bit)																	-- used on bit comparisons to avoid multiple casts
		,@searchType		varchar(25)																						-- type of search; returned with entity for debugging
		,@maxRows				int																										-- maximum rows allowed on search
		,@maxAutoRows		int																										-- maximum rows allowed on open search
		,@lastName			nvarchar(35)																					-- for name searches, buffer for each name part:
		,@firstName			nvarchar(30)
		,@middleNames		nvarchar(30)
		,@isValidEmail	bit
		,@recordCount		int																										-- in order to open search table, need to ensure record count is less than config param('MaxRowsForAutoSearch')
		,@IsPrefiltered bit = cast(0 as bit)																	-- indicates whether pre-filtered table was passed to limit search results	

	declare
		@selected		table																											-- stores results of query - SID only
	(
		 ID					int identity(1,1)	not null																-- identity to track add order - preserves custom sorts
		,EntitySID	int								not null																-- record ID joined to main entity to return results
	)

	begin try

		if exists( select 1 from @PreFilter ) set @IsPrefiltered = @ON

		set @SearchString = ltrim(rtrim(@SearchString))												-- remove leading and trailing spaces from character type columns

		-- retrieve max rows for string searches and set other defaults

		set @maxRows      = cast(isnull(sf.fConfigParam#Value('MaxRowsOnSearch'), '100')  as int)
		set @maxAutoRows	= cast(isnull(sf.fConfigParam#Value('MaxRowsForAutoSearch'),	'20')	as int)

		if @IsRowLimitEnforced = @OFF set @maxRows = 999999999								-- if row limit is not being enforced, set max rows to a billion

		-- get a count of records in the base table. If the user is attempting
		-- to perform an open search, the results will only return if the count
		-- in the table is less than the config param('MaxRowsForAutoSearch')

		select
			@recordCount = count(1)
		from
			sf.Person p

		-- if SID is provided in search string, parse it out and set parameter
		-- value (ensure it is all digits before attempting cast)

		if left(ltrim(@SearchString), 4) = N'SID:' and sf.fIsStringContentValid(replace(replace(@SearchString, N'SID:', ''), ' ', ''), N'0123456789' ) = @ON
		begin
			
			set @PersonSID	= cast(replace(replace(@SearchString, N'SID:', ''), ' ', '') as int)
		
		end

		if @PersonGroupSID is not null																				-- set the query SID if its a smart group
		begin

			select
				@QuerySID = pg.QuerySID
			from
				sf.PersonGroup pg
			where
				pg.PersonGroupSID = @PersonGroupSID

		end

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

			if @maxRows < 1000 set @maxRows = 1000															-- allow higher limit for queries, but avoid timeout; mobile problems etc.

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
				 Person.p.value('@EntitySID[1]','int')			PersonSID					
			from
				@Identifiers.nodes('//Entity') as Person(p)

			if @maxRows < 1000 set @maxRows = 1000															-- allow higher limit for queries, but avoid timeout; mobile problems etc.

		end
		else if @PersonSID is not null																				-- specific SID passed  (1 record)
		begin

			set @searchType   = 'SID'

			insert
				@selected
			(
				EntitySID
			)
			select
				p.PersonSID
			from
				sf.Person p
			where
				p.PersonSID = @PersonSID

			if @@rowcount = 0
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'Person'
					,@Arg2        = @PersonSID

				raiserror(@errorText, 18, 1)

			end

		end
		else if @PersonGroupSID is not null
		begin

			set @searchType = 'PersonGroup'

			insert
				@selected
			(
				EntitySID
			)
			select
				pgm.PersonSID
			from
				sf.PersonGroup pg
			join
				sf.PersonGroupMember pgm on pg.PersonGroupSID = pgm.PersonGroupSID and sf.fIsActive(pgm.EffectiveTime, pgm.ExpiryTime) = @ON
			where
				pg.PersonGroupSID = @PersonGroupSID

		end
		else if @SearchString is not null and sf.fIsValidEmail(cast(@SearchString as varchar(150))) = @ON
		begin

			set @searchType = 'Email'

			insert
				@selected
			(
				EntitySID
			)
			select
				p.PersonSID
			from
				sf.Person p
			join
				sf.PersonEmailAddress pea on p.PersonSID = pea.PersonSID
			left outer join
				@PreFilter pf on p.PersonSID = pf.RecordSID
			where
				pea.EmailAddress = @SearchString
			and
				(pf.RecordSID is not null or @IsPrefiltered = @OFF)

		end
		else if @ImportBatch is not null																			-- specific ImportBatch passed
		begin		

			insert
				@selected
			(
				EntitySID
			)
			select
				p.PersonSID
			from
				sf.Person p
			where 			
				isnull(p.ImportBatch, '?') = @ImportBatch
			
		end
		else if @SearchString is not null
		begin

			if @SearchString = '' and	@recordCount <= @maxAutoRows
			begin

				set @maxRows = @maxAutoRows

				insert
				@selected
				(
					EntitySID
				)
				select
					p.PersonSID
				from
					sf.Person p
				left outer join
					@PreFilter pf on p.PersonSID = pf.RecordSID
				where
					(pf.RecordSID is not null or @IsPrefiltered = @OFF)

			end
			else
			begin

				select
					 @FirstName		= sn.FirstName
					,@LastName		= sn.LastName
					,@MiddleNames	= sn.MiddleNames
				from
					sf.fSearchName#Split(@SearchString) sn

				insert
					@selected
				(
					EntitySID
				)
				select
					p.PersonSID
				from
					sf.Person p
				left outer join
					sf.PersonEmailAddress pea on p.PersonSID = pea.PersonSID and pea.IsPrimary = @ON
				left outer join
					sf.ApplicationUser au on p.PersonSID = au.PersonSID
				left outer join
					@PreFilter pf on p.PersonSID = pf.RecordSID
				where
				(
					(
						p.LastName like (@LastName)
					and
						(
							@FirstName is null
						or
							p.FirstName like @FirstName
						or
							p.FirstName like @MiddleNames
						or
							isnull(p.MiddleNames, '!') like @MiddleNames
						or
							isnull(p.MiddleNames, '!') like @FirstName
						)
					)
					or
						p.FirstName like @SearchString + N'%'
					or
						p.LastName like @SearchString																	-- or last name matches full search string (e.g. "Van Der Hook")
					or
						pea.EmailAddress like @SearchString														-- or matches any portion of the email address
					or
						au.AuthenticationSystemID like @SearchString									-- or matches any portion of primary ID number (TODO: Jun 2017 Tim move to sf.Person record!)
				)
				and
					(pf.RecordSID is not null or @IsPrefiltered = @OFF)

			end

		end		

		-- calling sprocs may request SID value only - to allow join to different output result

		if @ReturnSIDsOnly = @ON																							
		begin

			select top (@maxRows)
				s.EntitySID
			from	
				@selected s

		end
		else
		begin

			-- return all columns from the entity for key values stored into the memory table
			-- the same sort order is used by all searches so apply it to the dataset here
			-- (this allows queries above to avoid selecting against the entity in some cases)
																																					
			select top (@maxRows)		
				--!<ColumnList DataSource="sf.vPerson" Alias="p">																													
				 p.PersonSID
				,p.GenderSID
				,p.NamePrefixSID
				,p.FirstName
				,p.CommonName
				,p.MiddleNames
				,p.LastName
				,p.BirthDate
				,p.DeathDate
				,p.HomePhone
				,p.MobilePhone
				,p.IsTextMessagingEnabled
				,p.SignatureImage
				,p.IdentityPhoto
				,p.ImportBatch
				,p.UserDefinedColumns
				,p.PersonXID
				,p.LegacyKey
				,p.IsDeleted
				,p.CreateUser
				,p.CreateTime
				,p.UpdateUser
				,p.UpdateTime
				,p.RowGUID
				,p.RowStamp
				,p.GenderSCD
				,p.GenderLabel
				,p.GenderIsActive
				,p.GenderRowGUID
				,p.NamePrefixLabel
				,p.NamePrefixIsActive
				,p.NamePrefixRowGUID
				,p.IsDeleteEnabled
				,p.IsReselected
				,p.IsNullApplied
				,p.zContext
				,p.FileAsName
				,p.FullName
				,p.DisplayName
				,p.AgeInYears
				,p.PrimaryEmailAddressSID
				,p.PrimaryEmailAddress
				,p.Initials
				,p.IsEmailUsedForLogin
				--!</ColumnList>
			from
				sf.vPerson p
		 join
				@selected x on p.PersonSID = x.EntitySID
			order by
				p.FileAsName

		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)
end
GO
