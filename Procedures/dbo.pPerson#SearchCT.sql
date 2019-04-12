SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPerson#SearchCT
	@SearchString					 nvarchar(150) = null -- registrant name, # or email to search for (NOT combined with filters)
 ,@PracticeRegisterSID	 int = null						-- filter: registrations on this LICENSE practice register 
 ,@PersonGroupSID				 int = null						-- filter: people in selected group
 ,@IsCurrentlyRegistered bit = null						-- filter: has current yr registration = ON, non-current = OFF, either = NULL (3 positions)
 ,@IsUnPaid							 bit = null						-- filter: has unpaid amount = ON (default is OFF) - only 2 positions
 ,@IsPAPSubscriber			 bit = null						-- filter: subscribers = ON, non-subscribers = OFF, either = NULL (3 positions)
 ,@IsReviewRequired			 bit = null						-- filter: review required = ON (default is OFF) only 2 positions
 ,@QuerySID							 int = null						-- key of sf.Query record providing query to execute; or 0 for "no search"
 ,@QueryParameters			 xml = null						-- list of query parameters associated with the query SID
 ,@IsPinnedSearch				 bit = 0							-- quick search: only returns pinned records - not combined
 ,@SIDList							 xml = null						-- quick search: list of pinned records to return (xml contains SID's)
 ,@RecordSID						 int = null						-- quick search: returns RENEWAL (not registration) based on system ID
 ,@RecordXID						 varchar(150) = null	-- quick search: returns RENEWAL (not registration) based on an external ID
 ,@LegacyKey						 nvarchar(50) = null	-- quick search: returns RENEWAL (not registration) based on a legacy key
 ,@IsFilterExcluded			 bit = 0							-- when 1, filters are excluded even when populated (EXCEPT REGISTRATION YEAR)
 ,@IsRowLimitEnforced		 bit = 1							-- when 0, the limit of maximum rows to return is not enforced (see below)
as
/*********************************************************************************************************************************
Procedure : Person Search
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Searches the Person and Registrant entities for the search string and/or other criteria provided
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Cory Ng							| Jul 2017		|	Initial version					
        : Tim Edlund					| Oct 2017    | Added searches by register, current registration, renewed, PAP, Unpaid, Review Required
				: Tim Edlund					| Aug 2018		| Implemented support for other name and past email searches (sf.fPerson#SearchNames)
          
Comments
--------
This procedure supports dashboard displays and general searches of registrants and non-registrants in the system. Various search 
options are supported but the primary method is to select for a search string entered by the end user - typically a name or 
registrant number or email address. 

In order to support searches for non-registrants - like staff members who may only be application users and committee members
who are not necessarily licensed - the base entity of the procedure is sf.Person and an outer join is done to dbo.Registrant.

Complex Type CT
---------------
This search procedure does not return the default entity but rather a complex type. A corresponding view also exists against
which the search is performed.  The complex type is required to improve performance.

Default search
--------------
If no criteria is provided the search returns a set of rows limited by the MaxRows value (default is 200) ordered by last name.

Row Limit (MaxRows)
-------------------
The number of records returned on any search is limited by a configuration parameter setting "MaxRowsOnSearch" which if not set,
defaults to 200. The maximum is implemented to avoid timeout errors on rendering complex result layouts - particularly on slower 
mobile-phone based connections.  The limit can be turned off by passing @IsRowLimitEnforced as 0 (it defaults to ON). 

Filters
-------
Filters are applied in combination but do not apply when a TEXT search, primary key search or query identifier has been 
passed in.  Filters are based on foreign key values on the main entity and/or date ranges (on not null columns) can generally be 
applied without significantly increasing processing time assuming appropriate indexing.  

pSearchParam#Check (SF)
-----------------------
A subroutine in the framework is called to check parameters passed in and to format the text string and retrieve configuration
settings. The procedure is applied by all (current) search procedures and implements  formatting and priority-setting branching
critical to the searching process.  Be sure to review the documentation in that procedure thoroughly in order to debug issues
in search execution.

Text/String search
------------------
The search is performed against the person's full name, registrant number or email address.  Detection of a registration
number (vs name or email address) is based on matching a character string passed into the pSearchParam#Check procedure. For name 
and email components, wild cards are supported within the text entered.  A trailing "%" is always added to the search string but 
a leading "%" is not added in order to preserve use of indexes.  If a user wishes to search for records matching an email domain 
only then, for example, a leading wild card must be entered by them - e.g. "%@softworks.ca". Filters are not applied in combination
with text searches.

Dynamic queries
---------------
When the @QuerySID parameter is passed, then a dynamic query is executed from sf.Query.  The query syntax is retrieved from
and executed through a subroutine. This feature supports configuration-specific (custom) queries to be added to the installation.  
See sf.pQuery#Search for additional details.  Queries are executed independently of the filter criteria (not combined).

System Identifier Searches
--------------------------
@RecordSID search ("SID: 12345")
@RecordXID search ("XID: AB12345")
@LegacyKey search	("LegacyKey: XYZ1111")

The procedure supports searches on 3 possible key values entered explicitly by including a prefix in the search string. These 
searches are intended primarily for debugging (where SID is reported in the error message) and for validating converted 
records. 

The first search is on the primary key of the entity.  It can be invoked by passing the parameter directly, or by entering
the keyword "SID:" followed by a number into the @SearchString - e.g. "SID:1234567". The digits are stripped from the string
and converted into the parameter value by the procedure.  The conversion only takes place if all values following "SID:" are
digits. By allowing system ID's to the be entered into search string, administrators and configurators are able to trouble 
shoot error messages that return SID's using the renewal's user interface.  The other 2 options are similar except that no 
validation occurs for a specific data type.  The search against external ID's (XID) and LegacyKey are wildcard based so passing 
a partial value will result in found records.  For Legacy-Key both the prefix "LegacyKey:" and "LKey:" are supported. 

Sort order
----------
This procedure orders all results by name but other sort orders can be set in the UI.

Use of Memory Table
-------------------
The coding standard for search procedures is to retrieve key values of records matching the search into a temporary table,
and then join from that table to create the result set.  This technique, while more complex than direct SELECT's, generally 
improves performance since complex columns returned to the UI for display only can be excluded from retrieval logic.

Example:
--------
<TestHarness>
	<Test Name = "PersonSID" IsDefault ="true" Description="Finds the Person with the corresponding PersonSID">
    <SQLScript>
      <![CDATA[

declare @RecordSID int;

select top 1
	@RecordSID = c.PersonSID
from
	sf.Person c
order by
	newid();

exec dbo.pPerson#SearchCT @RecordSID = @RecordSID;

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
  <Test Name = "FullName" IsDefault ="false" Description="Finds a Person by last name.">
    <SQLScript>
      <![CDATA[

declare
	@randomPerson nvarchar(150)

select top 1
	@randomPerson = c.LastName
from
	sf.Person c
order by
	newid()
				
exec dbo.pPerson#SearchCT																					
	@SearchString = @randomPerson

select @randomPerson  SearchString

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.pPerson#SearchCT'
	,	@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				 nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON								 bit					 = cast(1 as bit) -- used on bit comparisons to avoid multiple casts
	 ,@OFF							 bit					 = cast(0 as bit) -- used on bit comparisons to avoid multiple casts
	 ,@isSearchInitiated bit					 = cast(0 as bit) -- indicates if at least one search criteria is applied
	 ,@searchType				 varchar(25)										-- type of search; returned in result for debugging
	 ,@maxRows					 int														-- maximum rows allowed on search
	 ,@registrantNo			 varchar(50)										-- ID of registrant (base of registration numbers)	
	 ,@lastName					 nvarchar(35)										-- for name searches, buffer for each name part:
	 ,@firstName				 nvarchar(30)
	 ,@middleNames			 nvarchar(30);

	declare @selected table -- stores primary key values of records found
	(
		ID				int identity(1, 1) not null -- identity to track add order - preserves custom sorts
	 ,EntitySID int not null								-- record ID joined to main entity to return results
	);

	declare @subset table -- stores primary key values of next search subset to process
	(
		ID				int identity(1, 1) not null
	 ,EntitySID int not null index ix_subset clustered -- record ID joined to main entity to return results
	);

	declare @pinned table -- stores primary key value of pinned records
	(ID int identity(1, 1) not null, EntitySID int not null);

	begin try

		-- set defaults for bit filters

		if @IsUnPaid is null set @IsUnPaid = @OFF;
		if @IsReviewRequired is null set @IsReviewRequired = @OFF;

		-- if filters are to be excluded, set them to null 
		-- (passed by the front end in order not to lose values from UI)

		if @IsFilterExcluded = @ON -- exception: do not clear filter on registration year!
		begin
			set @PersonGroupSID = null;
			set @PracticeRegisterSID = null;
			set @IsCurrentlyRegistered = null;
			set @IsUnPaid = @OFF;
			set @IsReviewRequired = @OFF;
			set @IsPAPSubscriber = null;
		end;

		-- call a subroutine to validate and format search parameters and
		-- to return list of pinned records for this user (if any)

		insert
			@pinned (EntitySID)
		exec sf.pSearchParam#Check -- check parameters and format for searching
			@SearchString = @SearchString output
		 ,@RecordSID = @RecordSID output
		 ,@MaxRows = @maxRows output
		 ,@IDNumber = @registrantNo output
		 ,@LastName = @lastName output
		 ,@FirstName = @firstName output
		 ,@MiddleNames = @middleNames output
		 ,@IDCharacters = '0123456789'
		 ,@ConvertDatesToST = @ON
		 ,@PinnedPropertyName = 'PinnedPersonList';

		if @IsRowLimitEnforced = @OFF set @maxRows = 999999999;

		if @PersonGroupSID is not null -- set the query SID if its a smart group
		begin

			select
				@QuerySID = pg.QuerySID
			from
				sf.PersonGroup pg
			where
				pg.PersonGroupSID = @PersonGroupSID;

		end;

		-- execute the searches

		if @QuerySID is not null -- dynamic query search (filters not applied)
		begin

			if @QuerySID = 0
			begin
				set @searchType = 'No Search'; -- avoid executing any search
			end;
			else
			begin
				set @searchType = 'Query';

				insert
					@selected (EntitySID)
				exec sf.pQuery#Execute
					@QuerySID = @QuerySID
				 ,@QueryParameters = @QueryParameters
				 ,@MaxRows = @maxRows;	-- query syntax may support restriction on max rows so pass it

			end
		end;
		else if @SIDList is not null -- set of specific SIDs passed or pinned record search (filters not applied)
		begin

			set @searchType = 'Identifiers';

			insert
				@selected (EntitySID)
			select top (@maxRows) -- parse attributes from the XML parameter document
				EntitySID.r.value('.', 'int') EntitySID -- return rows matching list of SID's passed in XML doc
			from
				@SIDList.nodes('//EntitySID') as EntitySID(r);

		end;
		else if @IsPinnedSearch = @ON -- returned pinned records (retrieved by #Check) - filters not applied
		begin

			set @searchType = 'Pins';

			insert @selected ( EntitySID) select top (@maxRows) p.EntitySID from @pinned p ;

		end;
		else if coalesce(@RecordSID, @RecordXID, @LegacyKey) is not null -- specific system ID was passed in search text - filters not applied
		begin

			if @RecordSID is not null set @searchType = 'SID';
			if @RecordXID is not null set @searchType = 'XID';
			if @LegacyKey is not null set @searchType = 'LegacyKey';

			insert
				@selected (EntitySID)
			select
				p.PersonSID
			from
				sf.Person p
			where
				p.PersonSID = @RecordSID or isnull(p.PersonXID, '!~@') = @RecordXID or isnull(p.LegacyKey, '!~@') = @LegacyKey;

			if @@rowcount = 0 -- failure to find the record is unexpected
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The "%1" record was not found. Record ID = %2. The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'Person'
				 ,@Arg2 = @RecordSID;

				raiserror(@errorText, 16, 1);

			end;

		end;
		else if @registrantNo is not null -- a search on the registrant's # (faster than name searches)
		begin

			set @searchType = 'RegistrantNo';

			insert
				@selected (EntitySID)
			select r .PersonSID from dbo .Registrant r where r.RegistrantNo = @registrantNo;

			if @@rowcount = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'IDNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 "%2" was not found.'
				 ,@Arg1 = 'registrant#'
				 ,@Arg2 = @registrantNo;

				raiserror(@errorText, 16, 1);

			end;

		end;
		else if @SearchString is not null
		begin

			-- text searches are NOT combined
			-- with filters

			set @searchType = 'Text';

			insert
				@selected (EntitySID)
			select
				p.PersonSID
			from
				sf.fPerson#SearchNames(@SearchString, @lastName, @firstName, @middleNames, @ON) p

			if @@rowcount = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'TextNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'No results were found for the search text entered.';

				raiserror(@errorText, 16, 1);

			end;

		end;
		else
		begin

			-- the remaining searches combine filters; this is achieved by
			-- running individual filter results in "@subset" and deleting
			-- from the @selected (result table) where all previous filter
			-- conditions have not been met

			if @IsReviewRequired = @ON
			begin

				set @searchType = 'ReviewRequired';
				delete @subset;

				insert
					@subset (EntitySID)
				select distinct
					pma.PersonSID
				from
					dbo.PersonMailingAddress pma
				where
					pma.IsAdminReviewRequired = @ON;

				if @isSearchInitiated = @OFF
				begin

					insert @selected ( EntitySID) select s .EntitySID from @subset s ;

					set @isSearchInitiated = @ON;
				end;
				else
				begin

					delete
					s
					from
						@selected s
					left outer join
						@subset		ss on s.EntitySID = ss.EntitySID
					where
						ss.EntitySID is null;

				end;

			end;

			if @PracticeRegisterSID is not null and @IsCurrentlyRegistered is null
			begin

				set @searchType = 'PracticeRegister';
				delete @subset;

				insert
					@subset (EntitySID)
				select
					r.PersonSID
				from
					dbo.Registrant																								 r
				cross apply dbo.fRegistrant#LatestRegistration2(r.RegistrantSID) ll
				where
					ll.PracticeRegisterSID = @PracticeRegisterSID;

				if @isSearchInitiated = @OFF
				begin

					insert @selected ( EntitySID) select s .EntitySID from @subset s ;

					set @isSearchInitiated = @ON;
				end;
				else
				begin

					delete
					s
					from
						@selected s
					left outer join
						@subset		ss on s.EntitySID = ss.EntitySID
					where
						ss.EntitySID is null;

				end;

			end;

			if @PersonGroupSID is not null
			begin

				set @searchType = 'PersonGroup';
				delete @subset;

				insert
					@subset (EntitySID)
				select distinct
					pgm.PersonSID
				from
					sf.PersonGroupMember pgm
				where
					pgm.PersonGroupSID = @PersonGroupSID and sf.fIsActive(pgm.EffectiveTime, pgm.ExpiryTime) = @ON;

				if @isSearchInitiated = @OFF
				begin

					insert @selected ( EntitySID) select s .EntitySID from @subset s ;

					set @isSearchInitiated = @ON;
				end;
				else
				begin

					delete
					s
					from
						@selected s
					left outer join
						@subset		ss on s.EntitySID = ss.EntitySID
					where
						ss.EntitySID is null;

				end;

			end;

			if @IsUnPaid = @ON
			begin

				set @searchType = 'UnPaid';
				delete @subset;

				insert
					@subset (EntitySID)
				select distinct
					i.PersonSID
				from
					dbo.Invoice																 i
				cross apply dbo.fInvoice#Total(i.InvoiceSID) it
				where
					it.IsUnPaid = @ON;

				if @isSearchInitiated = @OFF
				begin

					insert @selected ( EntitySID) select s .EntitySID from @subset s ;

					set @isSearchInitiated = @ON;
				end;
				else
				begin

					delete
					s
					from
						@selected s
					left outer join
						@subset		ss on s.EntitySID = ss.EntitySID
					where
						ss.EntitySID is null;

				end;

			end;

			if @IsPAPSubscriber = @ON
			begin

				set @searchType = 'PAPSubscriber';
				delete @subset;

				insert
					@subset (EntitySID)
				select distinct
					paps.PersonSID
				from
					dbo.PAPSubscription paps
				where
					sf.fIsActive(paps.EffectiveTime, paps.CancelledTime) = @ON;

				if @isSearchInitiated = @OFF
				begin

					insert @selected ( EntitySID) select s .EntitySID from @subset s ;

					set @isSearchInitiated = @ON;
				end;
				else
				begin

					delete
					s
					from
						@selected s
					left outer join
						@subset		ss on s.EntitySID = ss.EntitySID
					where
						ss.EntitySID is null;

				end;
			end;

			if @IsCurrentlyRegistered = @ON
			begin

				set @searchType = 'CurrentlyRegistered.On';
				delete @subset;

				insert
					@subset (EntitySID)
				select distinct
					rc.PersonSID
				from
					dbo.fRegistrant#ActiveRegistrationCurrent(null) rc
				where
					rc.PracticeRegisterSID = isnull(@PracticeRegisterSID, rc.PracticeRegisterSID);

				if @isSearchInitiated = @OFF
				begin

					insert @selected ( EntitySID) select s .EntitySID from @subset s ;

					set @isSearchInitiated = @ON;
				end;
				else
				begin

					delete
					s
					from
						@selected s
					left outer join
						@subset		ss on s.EntitySID = ss.EntitySID
					where
						ss.EntitySID is null;

				end;
			end;

			if @IsCurrentlyRegistered = @OFF
			begin

				set @searchType = 'CurrentlyRegistered.Off';
				delete @subset;

				insert
					@subset (EntitySID)
				select distinct
					r.PersonSID
				from
					dbo.Registrant																								 r
				cross apply dbo.fRegistrant#LatestRegistration2(r.RegistrantSID) ll
				where
					ll.PracticeRegisterSID = isnull(@PracticeRegisterSID, ll.PracticeRegisterSID) and sf.fIsActive(ll.EffectiveTime, ll.ExpiryTime) = @OFF;

				if @isSearchInitiated = @OFF
				begin

					insert @selected ( EntitySID) select s .EntitySID from @subset s ;

					set @isSearchInitiated = @ON;
				end;
				else
				begin

					delete
					s
					from
						@selected s
					left outer join
						@subset		ss on s.EntitySID = ss.EntitySID
					where
						ss.EntitySID is null;

				end;
			end;

			if @isSearchInitiated = @OFF
			begin

				-- if no other criteria was specified, run the default search with
				-- only the PAP filter condition since other filters were processed
				-- in separate if blocks above

				set @searchType = 'Default';

				select top (@maxRows)
					p.PersonSID
				 ,p.NameLabel
				 ,p.LastName
				 ,p.FirstName
				 ,p.MiddleNames
				 ,p.EmailAddress
				 ,p.HomePhone
				 ,p.MobilePhone
				 ,p.RegistrantNo
				 ,p.RegistrantSID
				 ,p.HasOpenAudit
				 ,p.OpenAuditReviewCount
				 ,p.OpenAppReviewCount
				 ,p.IsApplicationUser
				 ,p.IsRegistrant
				 ,p.IsApplicant
				 ,p.IsOrgContact
				 ,p.IsAdministrator
				 ,p.IsPAPSubscriber
				 ,cast(isnull(z.EntitySID, 0) as bit) IsPinned		-- if key found in pinned list then @ON else @OFF
				 ,@searchType													SearchType	-- search type for debugging - ignored by UI
				from
					dbo.vPerson#Search p
				left outer join
					@pinned						 z on p.PersonSID = z.EntitySID
				where
					p.IsPAPSubscriber = isnull(@IsPAPSubscriber, p.IsPAPSubscriber) -- include this filter to handle OFF position (3 position bit value)
				order by
					p.LastName
				 ,p.FirstName
				 ,p.MiddleNames;

			end;
		end;

		-- if the default search was not run, return the same select
		-- as the default search but filtering what was returned 
		-- from the earlier search as stored in @selected 

		if @searchType <> 'Default'
		begin

			-- return only the columns required for display joining to the @selected
			-- table to apply found records, and to @pinned to apply pin attribute

			select top (@maxRows)
				p.PersonSID
			 ,p.NameLabel
			 ,p.LastName
			 ,p.FirstName
			 ,p.MiddleNames
			 ,p.EmailAddress
			 ,p.HomePhone
			 ,p.MobilePhone
			 ,p.RegistrantNo
			 ,p.RegistrantSID
			 ,p.HasOpenAudit
			 ,p.OpenAuditReviewCount
			 ,p.OpenAppReviewCount
			 ,p.IsApplicationUser
			 ,p.IsRegistrant
			 ,p.IsApplicant
			 ,p.IsOrgContact
			 ,p.IsAdministrator
			 ,p.IsPAPSubscriber
			 ,cast(isnull(z.EntitySID, 0) as bit) IsPinned		-- if key found in pinned list then @ON else @OFF
			 ,@searchType													SearchType	-- search type for debugging - ignored by UI
			from
				dbo.vPerson#Search p
			join
				@selected					 x on p.PersonSID = x.EntitySID
			left outer join
				@pinned						 z on p.PersonSID = z.EntitySID
			where
				p.IsPAPSubscriber = isnull(@IsPAPSubscriber, p.IsPAPSubscriber) -- include this filter to handle OFF position (3 position bit value)
			order by
				p.LastName
			 ,p.FirstName
			 ,p.MiddleNames;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
