SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantLearningPlan#SearchCT]
	@SearchString					 nvarchar(150) = null -- registrant name, # or email to search for (NOT combined with filters)
 ,@RegistrationYear			 int					 = null -- filter: learning plans in this registration year (defaults if not set!)
 ,@PracticeRegisterSID	 int					 = null -- filter: registrants on this practice register 
 ,@IsFollowUpDue				 bit					 = null -- filter: returns only learning plans where follow-up date has been reached
 ,@IsNotStarted					 bit					 = null -- filter: returns only registrants where no learning plans has been started
 ,@FormStatusSID				 int					 = null -- filter: learning plans in this status
 ,@IsPDFRequired				 bit					 = null -- filter: learning plans where form is approved but no PDF exists
 ,@ExcludeWithdrawn			 bit					 = null -- filter: excludes forms that have been withdrawn 
 ,@LastNameStart				 nvarchar(35)	 = null -- filter: learning plans where registrant lastname is within alphabetical range
 ,@LastNameEnd					 nvarchar(35)	 = null -- filter: learning plans where registrant lastname is within alphabetical range
 ,@QuerySID							 int					 = null -- SID of sf.Query row providing SQL syntax to execute - not combined
 ,@QueryParameters			 xml					 = null -- list of query parameters associated with the query SID
 ,@IsPinnedSearch				 bit					 = 0		-- quick search: only returns pinned records - not combined
 ,@SIDList							 xml					 = null -- quick search: list of pinned records to return (xml contains SID's)
 ,@RecordSID						 int					 = null -- quick search: returns a learning plan based on system ID
 ,@RecordXID						 varchar(150)	 = null -- quick search: returns a learning plan based on an external ID
 ,@LegacyKey						 nvarchar(50)	 = null -- quick search: returns a learning plan based on a legacy key
 ,@IsFilterExcluded			 bit					 = 0		-- when 1, filters are excluded even when populated (EXCEPT REGISTRATION YEAR)
 ,@IsRowLimitEnforced		 bit					 = 1		-- when 0, the limit of maximum rows to return is not enforced (see below)
as
/*********************************************************************************************************************************
Procedure : Registrant Learning Plan Search
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Searches the Registrant and Registrant Learning Plan entities for the search string and/or other criteria provided
History   : Author(s)						| Month Year  | Change Summary
					: --------------------+-------------+-----------------------------------------------------------------------------------
          : Cory Ng   					| Dec 2017    | Initial version
					: Tim Edlund					| Aug 2018		| Implemented support for other name and past email searches (sf.fPerson#SearchNames)

Comments
--------
This procedure supports dashboard displays and general searches of the "Registrant-Learning-Plan" entity from the UI. Various 
search options are supported but the primary method is to SELECT for a search string entered by the end user. The string 
typically contains a registrant name, registrant number or email address. The other primary method is to search for work items 
by using the filters provided - for example to find all learning plans which aren't started or requires PDF generation.

This procedure is unlike other search procedures as the base entity is registrant and not "RegistrantLearningPlan" as the
name of the procedure might imply. The registrant entity is the starting point so that a registrant who did not start their 
learning plan for the registration year will be included as "not started". This is important on for administrators to be able 
to see who is eligible for learning plan entry but has not completed it.

Unlike other form based search procedures learning plan does not support reviews, so this procedure will never be executed as a
reviewer only as an administrator.

Note that a RegistrationYear is always required.  If none is passed the current registration year is set as the default
value.  The procedure uses a table function rather than a view to take advantage of the inline filtering on year.

Complex Type CT
---------------
This search procedure does not return the default entity but rather a complex type. A corresponding table function exists 
against which the search is performed.  The complex type is required to improve performance.

Default search
--------------
If no search string or custom query is passed to the procedure the default search is executed. The default search applies the
filter conditions and returns rows up to the @MaxRows limit.  The limit can be turned off (see below).

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
only then, for example, a leading wildcard must be entered by them - e.g. "%@softworks.ca". Filters are not applied in combination
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

The procedure supports searches on 3 possible key values entered explicitly by including a prefix in the search string. For 
this procedure the searches are run against both the dbo.Registrant and dbo.RegistrantLearningPlan tables. If plan has 
not been started by the registrant, then no Registrant-LearningPlan record will exist and the record cannot be located. By 
searching against both entities, the values from either table will be found.  These searches are intended primarily for 
debugging (where SID is reported in the error message) and for validating converted records. 

The first search is on the primary key of the entity.  It can be invoked by passing the parameter directly, or by entering
the keyword "SID:" followed by a number into the @SearchString - e.g. "SID:1234567". The digits are stripped from the string
and converted into the parameter value by the procedure.  The conversion only takes place if all values following "SID:" are
digits. By allowing system ID's to the be entered into search string, administrators and configurators are able to trouble 
shoot error messages that return SID's using the learning plan's user interface.  The other 2 options are similar except that 
no validation occurs for a specific data type.  The search against external ID's (XID) and LegacyKey are wildcard based so 
passing a partial value will result in found records.  For Legacy-Key both the prefix "LegacyKey:" and "LKey:" are supported. 

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
	<Test Name = "DefaultAdmin" IsDefault ="true" Description="Runs default search for current registration year">
		<SQLScript>
			<![CDATA[
exec dbo.pRegistrantLearningPlan#SearchCT
	@isRowLimitEnforced = 1
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "RegistrantNo" Description="Runs a registrant# search for an administrator">
		<SQLScript>
			<![CDATA[
      
declare
  @registrantNo nvarchar(50)

select
  @registrantNo = r.RegistrantNo
from
  dbo.Registrant r

exec dbo.pRegistrantLearningPlan#SearchCT																			-- search for registrant# (all years)
	@SearchString = @registrantNo

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "RegistrantName" Description="Runs a partial last name search">
		<SQLScript>
			<![CDATA[

exec dbo.pRegistrantLearningPlan#SearchCT																			-- search for partial last name
	 @SearchString = N'bow'
	,@RegistrationYear = 2017

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.pRegistrantLearningPlan#SearchCT'
	,	@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo					 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				 nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON								 bit					 = cast(1 as bit) -- used on bit comparisons to avoid multiple casts
	 ,@OFF							 bit					 = cast(0 as bit) -- used on bit comparisons to avoid multiple casts
	 ,@isSearchInitiated bit					 = cast(0 as bit) -- indicates if at least one search criteria is applied
	 ,@searchType				 varchar(150)										-- type of search; returned in result for debugging
	 ,@maxRows					 int														-- maximum rows allowed on search
	 ,@registrantNo			 varchar(50)										-- ID of registrant (base of registration numbers)	
	 ,@today						 date					 = sf.fToday()		-- current date in client timezone for due follow-up search
	 ,@lastName					 nvarchar(35)										-- for name searches, buffer for each name part:
	 ,@firstName				 nvarchar(30)
	 ,@middleNames			 nvarchar(30);

	declare @selected table -- stores primary key values of records found
	(
		ID				int identity(1, 1) not null -- identity to track add order - preserves custom sorts
	 ,EntitySID int not null
	);

	declare @subset table -- stores primary key values of next search subset to process
	(
		ID				int identity(1, 1) not null
	 ,EntitySID int not null index ix_subset clustered -- record ID joined to main entity to return results
	);

	declare @pinned table -- stores primary key value of pinned records
	(
		ID				int identity(1, 1) not null
	 ,EntitySID int not null
	);

	begin try

    -- set defaults for bit filters

-- SQL Prompt formatting off
		if @IsFollowUpDue					is null	set @IsFollowUpDue = @OFF
		if @IsNotStarted					is null set @IsNotStarted = @OFF
		if @IsPDFRequired					is null	set @IsPDFRequired = @OFF;
		if @RegistrationYear			is null	set @RegistrationYear = dbo.fRegistrationYear#Current(); -- registration year is required - default to current year if not passed
-- SQL Prompt formatting on

		-- ensure blank text criteria are reset to null

-- SQL Prompt formatting off
		if len(ltrim(rtrim(@LastNameStart)))	= 0 	set @LastNameStart = null;
		if len(ltrim(rtrim(@LastNameEnd)))		= 0		set @LastNameEnd = null;
		if len(ltrim(rtrim(@SearchString)))		= 0		set @SearchString = null;
-- SQL Prompt formatting on

		-- if filters are to be excluded, set them to null 
		-- (passed by the front end in order not to lose values from UI)

		if @IsFilterExcluded = @ON -- exception: do not clear filter on registration year!
		begin
			set @PracticeRegisterSID = null;
			set @IsFollowUpDue = @OFF;
			set @IsNotStarted = @OFF;
			set @FormStatusSID = null;
			set @IsPDFRequired = @OFF;
		end;

		-- call a subroutine to validate and format search parameters and
		-- to return list of pinned records for this user (if any)

		insert
			@pinned (EntitySID)
		exec sf.pSearchParam#Check -- check parameters and format for searching
			@SearchString = @SearchString output
		 ,@RecordSID = @RecordSID output
		 ,@RecordXID = @RecordXID output
		 ,@LegacyKey = @LegacyKey output
		 ,@MaxRows = @maxRows output
		 ,@IDNumber = @registrantNo output
		 ,@LastName = @lastName output
		 ,@FirstName = @firstName output
		 ,@MiddleNames = @middleNames output
		 ,@IDCharacters = '0123456789'
		 ,@ConvertDatesToST = @ON
		 ,@PinnedPropertyName = 'PinnedRegistrantLearningPlanList';

-- SQL Prompt formatting off
		if @IsRowLimitEnforced = @OFF set @maxRows = 999999999;
-- SQL Prompt formatting on

		-- execute the searches

		if @QuerySID is not null -- dynamic query search (filters not applied)
		begin

			set @searchType = 'Query'; 

			insert
				@selected (EntitySID)
			exec sf.pQuery#Execute
				@QuerySID = @QuerySID
			 ,@QueryParameters = @QueryParameters
			 ,@MaxRows = @maxRows;	-- query syntax may support restriction on max rows so pass it

		end;
		else if @SIDList is not null -- set of specific SIDs passed or pinned record search (filters not applied)
		begin

			set @searchType = 'Identifiers';

			insert
				@selected (EntitySID)
			select
				EntitySID.r.value('.', 'int') EntitySID -- return rows matching list of SID's passed in XML doc
			from
				@SIDList.nodes('//EntitySID') as EntitySID(r);

		end;
		else if @IsPinnedSearch = @ON -- returned pinned records (retrieved by #Check) - filters not applied
		begin

			set @searchType = 'Pins';

			insert
				@selected (EntitySID)
			select p.EntitySID from	@pinned p;

		end;
		else if coalesce(@RecordSID, @RecordXID, @LegacyKey) is not null -- specific system ID was passed in search text - filters not applied
		begin

-- SQL Prompt formatting off
			if @RecordSID is not null set @searchType = 'SID';
			if @RecordXID is not null set @searchType = 'XID';
			if @LegacyKey is not null set @searchType = 'LegacyKey';
-- SQL Prompt formatting on

			-- search for learning plans based on it's keys if nothing is 
      -- found search for the registrant based on it's keys

			insert
				@selected (EntitySID)
			select
				rlp.RegistrantSID
			from
				dbo.RegistrantLearningPlan						rlp
			where
				rlp.RegistrantLearningPlanSID								    = @RecordSID
				or isnull(rlp.RegistrantLearningPlanXID, '!~@') = @RecordXID
				or isnull(rlp.LegacyKey, '!~@')						      = @LegacyKey;

      if @@rowcount = 0
      begin

        insert
				  @selected (EntitySID)
			  select
				  r.RegistrantSID
			  from
				  dbo.Registrant r
			  where
				  r.RegistrantSID       										      = @RecordSID
				  or isnull(r.RegistrantXID, '!~@')               = @RecordXID
				  or isnull(r.LegacyKey, '!~@')						        = @LegacyKey

				if @@rowcount = 0 -- failure to find the record is unexpected
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'RecordNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The "%1" record was not found. Record ID = %2. The record may have been deleted or the identifier is invalid.'
					 ,@Arg1 = 'Registrant Learning Plan'
					 ,@Arg2 = @RecordSID;

					raiserror(@errorText, 16, 1);

				end;

      end

			

		end;
		else if @registrantNo is not null -- a search on the registrant's # (faster than name searches)
		begin

			set @searchType = 'RegistrantNo';

			insert
				@selected (EntitySID)
			select
				r.RegistrantSID
			from
				dbo.Registrant r
			where
				r.RegistrantNo = @registrantNo;

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

			set @searchType = 'Text';

			insert
				@selected (EntitySID)
			select
				r.RegistrantSID
			from
				sf.fPerson#SearchNames(@SearchString, @lastName, @firstName, @middleNames,@ON) px
			join
				dbo.Registrant																				r on px.PersonSID = r.PersonSID

      if @@rowcount = 0
      begin

        insert                                                            -- perform partial first name search if not found using criteria above
				@selected (EntitySID)
			  select
				  r.RegistrantSID
			  from
				  dbo.Registrant																				r
			  join
				  sf.Person																							p on r.PersonSID			= p.PersonSID
			  where
				  p.FirstName like @firstName

				if @@rowcount = 0
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'TextNotFound'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'No results were found for the search text entered.';

					raiserror(@errorText, 16, 1);

				end;

      end

		end;
		else
		begin

			-- the remaining searches combine filters; this is achieved by
			-- running individual filter results into "@subset" and then
			-- deleting from the final result table (@selected) where all 
			-- previous filter conditions have not been met

			if @PracticeRegisterSID is not null
			begin
				set @searchType = isnull(@searchType + ',PracticeRegister', 'PracticeRegister');
				delete @subset;

				insert
					@subset (EntitySID)
				select
					rl.RegistrantSID
				from 
					dbo.Registration rl
				join
					dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
				where
					rl.RegistrationYear = @RegistrationYear
				and
					prs.PracticeRegisterSID = @PracticeRegisterSID

				if @isSearchInitiated = @OFF
				begin
					insert @selected (EntitySID) select	s.EntitySID from	@subset s;
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

			if @IsFollowUpDue = @ON
			begin
				set @searchType = isnull(@searchType + ',FollowUpDue', 'FollowUpDue');
				delete @subset;

				insert
					@subset (EntitySID)
				select
					rlp.RegistrantSID
				from
					dbo.RegistrantLearningPlan rlp
				join
					dbo.LearningModel		 lm on rlp.LearningModelSID			= lm.LearningModelSID
				where
          @RegistrationYear between rlp.RegistrationYear and (rlp.RegistrationYear + lm.CycleLengthYears - 1)
        and
					rlp.NextFollowUp <= @today

				if @isSearchInitiated = @OFF
				begin
					insert @selected (EntitySID) select	s.EntitySID from	@subset s;
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

			if @IsNotStarted = @ON
			begin
				set @searchType = isnull(@searchType + ',NotStarted', 'NotStarted');
				delete @subset;

				insert
					@subset (EntitySID)
				select
					r.RegistrantSID
				from
					dbo.Registrant                    r
				left outer join
					dbo.vRegistrantLearningPlan				rlp on r.RegistrantSID = rlp.RegistrantSID and @RegistrationYear between rlp.RegistrationYear and rlp.CycleEndRegistrationYear
				where
					rlp.RegistrantLearningPlanSID is null;

				if @isSearchInitiated = @OFF
				begin
          insert @selected (EntitySID) select	s.EntitySID from	@subset s;
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

			if @FormStatusSID is not null
			begin

				set @searchType = isnull(@searchType + ',FormStatus', 'FormStatus');
				delete @subset;

				insert
					@subset (EntitySID)
				select
					rlp.RegistrantSID
				from
					dbo.RegistrantLearningPlan					rlp
				cross apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
				join
					dbo.LearningModel		 lm on rlp.LearningModelSID			= lm.LearningModelSID
				where
          @RegistrationYear between rlp.RegistrationYear and (rlp.RegistrationYear + lm.CycleLengthYears - 1)
        and
					cs.FormStatusSID = @FormStatusSID;

				if @isSearchInitiated = @OFF
				begin
          insert @selected (EntitySID) select	s.EntitySID from	@subset s;
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

			if @IsPDFRequired = @ON
			begin
				set @searchType = isnull(@searchType + ',PDFRequired', 'PDFRequired');
				delete @subset;

				insert
					@subset (EntitySID)
				select
					rlp.RegistrantSID
				from
					dbo.RegistrantLearningPlan	rlp
				cross apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
				join
					dbo.LearningModel		 lm on rlp.LearningModelSID			= lm.LearningModelSID
				where
          @RegistrationYear between rlp.RegistrationYear and (rlp.RegistrationYear + lm.CycleLengthYears - 1)
					and cs.FormStatusSCD = 'APPROVED'
					and dbo.fPersonDocContext#HasPrimary(rlp.RegistrantLearningPlanSID, 'dbo.RegistrantLearningPlan') = @OFF;

				if @isSearchInitiated = @OFF
				begin
          insert @selected (EntitySID) select	s.EntitySID from	@subset s;
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

			if @LastNameStart is not null and @LastNameEnd is not null
			begin
				set @searchType = isnull(@searchType + ',NameRange', 'NameRange');
				delete @subset;

				if right(@LastNameEnd, 3) <> N'ZZZ' and len(@LastNameEnd) <= 32
				begin
					set @LastNameEnd = cast(@LastNameEnd + N'ZZZ' as nvarchar(35));
				end;

				insert
					@subset (EntitySID)
				select
					r.RegistrantSID
				from
					sf.Person																							p
				join
					dbo.Registrant																				r on p.PersonSID			= r.PersonSID
				where
					(p.LastName between @LastNameStart and @LastNameEnd); -- in name range

				if @isSearchInitiated = @OFF
				begin
          insert @selected (EntitySID) select	s.EntitySID from	@subset s;
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

		end;

		-- all searches are based on results stored into
		-- the memory table 

		select top (@maxRows)
      rlp.RegistrantSID
		 ,rlp.RegistrantNo
		 ,rlp.RegistrantLearningPlanSID
		 ,rlp.PersonSID
		 ,rlp.RegistrantLabel
		 ,rlp.PracticeRegisterLabel
		 ,rlp.FormStatusLabel
		 ,rlp.IsFollowUpDue
		 ,rlp.FormOwnerSCD
		 ,rlp.FormOwnerLabel
		 ,rlp.EmailAddress
		 ,rlp.PersonDocSID
		 ,rlp.LastStatusChangeUser
		 ,rlp.LastStatusChangeTime
		 ,cast(isnull(z.EntitySID, 0) as bit) IsPinned		-- if key found in pinned list then @ON else @OFF
		 ,@searchType													SearchType	-- search type for debugging - ignored by UI
		from
			@selected																							x
		cross apply dbo.fRegistrantLearningPlan#Search(x.EntitySID, @RegistrationYear) rlp
		left outer join 
			@pinned z on rlp.RegistrantSID = z.EntitySID
		where
      @ExcludeWithdrawn = @OFF
    or
      rlp.FormStatusSCD <> 'WITHDRAWN'
		order by
			rlp.LastName
		 ,rlp.FirstName;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
