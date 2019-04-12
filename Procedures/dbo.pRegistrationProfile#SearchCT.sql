SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrationProfile#SearchCT]
	@RegistrationSnapshotSID int = null						-- required: snapshot to look for the profiles under
 ,@SearchString						 nvarchar(150) = null -- registrant name, # or email to search for (NOT combined with filters)
 ,@SearchMessageText			 bit = 0							-- search modifier: also searches the message text column
 ,@IsInvalid							 bit = null						-- quick search: returns all invalid profiles
 ,@IsModified							 bit = null						-- quick search: returns all modified profiled
 ,@QuerySID								 int = null						-- SID of sf.Query row providing SQL syntax to execute - not combined
 ,@QueryParameters				 xml = null						-- list of query parameters associated with the query SID
 ,@IsPinnedSearch					 bit = 0							-- quick search: only returns pinned records - not combined
 ,@SIDList								 xml = null						-- quick search: list of pinned records to return (xml contains SID's)
 ,@RecordSID							 int = null						-- quick search: returns RegistrationProfile based on system ID
 ,@RecordXID							 varchar(150) = null	-- quick search: returns RegistrationProfile based on an external ID
 ,@LegacyKey							 nvarchar(50) = null	-- quick search: returns RegistrationProfile based on a legacy key
 ,@IsFilterExcluded				 bit = 0							-- when 1, filters are excluded even when populated (EXCEPT REGISTRATION SNAPSHOT)
 ,@IsRowLimitEnforced			 bit = 1							-- when 0, the limit of maximum rows to return is not enforced (see below)
as
/*********************************************************************************************************************************
Procedure : Registration Profile Search
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Searches the RegistrationProfile entity for the search string and/or query provided
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Cory Ng   	| Jul 2018		|	Initial version

Comments	
--------
This procedure supports searches on registration profiles within a snapshot. The default search will return all invalid profiles
for the snapshot. The procedure does not support searching for profiles in multiple snapshots.

Text/String search
------------------
The string search is performed against the person's full name, registrant number or email address.  Detection of a registration
number (vs name or email address) is based on matching a character string passed into the pSearchParam#Check procedure. For name
and email components, wild cards are supported within the text entered.  A trailing "%" is always added to the search string but
a leading "%" is not in order to preserve use of indexes.  If a user wishes to search for records matching an email domain
only then, for example, a leading wild-card must be entered by them - e.g. "%@softworks.ca". Filters are not applied in combination
with text searches.

A subroutine in the framework (sf.pSearchParam#Check) is called to check parameters passed in and to format the text string and
retrieve configuration settings. The procedure is applied by all (current) search procedures and implements formatting and
priority-setting branching critical to the searching process.  Be sure to review the documentation in that procedure thoroughly in
order to debug issues in search execution.

Queries
-------
When the @QuerySID parameter is passed, then a dynamic query is executed from sf.Query.  Product queries are created to support
typical work-flows such as emailing a Renewal Notice at the start of the renewal cycle, selecting forms requiring administrative
follow-up, or querying for a specific block reason, etc..  Queries may also be created unique for a given client configuration.
All queries are ready by the UI dynamically from the sf.Query table.  Queries are executed independently of the filter criteria
(not combined).

System Identifier Searches
--------------------------
The procedure supports searches on "key values" to support debugging.  On various low-level error messages the application will
return the primary key value of the record experiencing the error. Searching for that key value is possible through the search
routine.

	dbo.RegistrationProfile @RecordSID search ("SID: 12345")
	dbo.RegistrationProfile @RecordXID search ("XID: AB12345")
	dbo.RegistrationProfile @LegacyKey search	("LegacyKey: XYZ1111")

The first search is on the primary key of the entity.  It can be invoked by passing the parameter directly, or by entering
the keyword "SID:" followed by a number into the @SearchString - e.g. "SID:1234567". The digits are stripped from the string
and converted into the parameter value by the procedure.  The conversion only takes place if all values following "SID:" are
digits. By allowing system ID's to the be entered into search string, administrators and configurators are able to trouble
shoot error messages that return SID's through the application.  The other 2 options are similar except that no validation occurs
for a specific data type.  The search against external ID's (XID) and LegacyKey are wildcard based so passing a partial value will
result in found records.  For Legacy-Key both the prefix "LegacyKey:" and "LKey:" are supported.

Complex Type CT
---------------
This search procedure does not return the default entity but rather a complex type. A corresponding view exists against which the
search is performed.

Default search
--------------
If no search string or custom query is passed to the procedure the default search is executed. The default search applies the
filter conditions and returns rows up to the @MaxRows limit.  The limit can be turned off (see below).

Row Limit (MaxRows)
-------------------
The number of records returned on any search is limited by a configuration parameter setting "MaxRowsOnSearch" which if not set,
defaults to 200. The maximum is implemented to avoid timeout errors on rendering complex result layouts - particularly on slower
mobile-phone based connections.  The limit can be turned off by passing @IsRowLimitEnforced as 0 (it defaults to ON).

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
  <Test Name = "SID" IsDefault ="true" Description="Executes the procedure to return a SID at random using 2 different parameters.">
    <SQLScript>
      <![CDATA[
declare
	@searchString								nvarchar(150)
 ,@recordSID									int
 ,@registrationSnapshotSID    int;

select top (1)
	@searchString             = N'SID:' + ltrim(reg.RegistrationProfileSID)
 ,@recordSID		            = reg.RegistrationProfileSID
 ,@registrationSnapshotSID  = reg.RegistrationSnapshotSID
from
	dbo.RegistrationProfile reg
order by
	newid();

if @@rowcount = 0 or @recordSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistrationProfile#SearchCT
     @RegistrationSnapshotSID = @registrationSnapshotSID
		,@RecordSID = @recordSID;

	exec dbo.pRegistrationProfile#SearchCT
     @RegistrationSnapshotSID = @registrationSnapshotSID
		,@SearchString = @searchString;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.pRegistrationProfile#SearchCT'
	,	@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON						bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@OFF					bit						= cast(0 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@searchType		varchar(150)										-- type of search; returned in result for debugging
	 ,@rowsFound		int															-- counter for records found
	 ,@maxRows			int															-- maximum rows allowed on search
	 ,@registrantNo varchar(50)											-- ID of registrant (base of registration numbers)	
	 ,@lastName			nvarchar(35)										-- for name searches, buffer for each name part:
	 ,@firstName		nvarchar(30)
	 ,@middleNames	nvarchar(30);

	declare @selected table -- stores primary key values of records found
	(
		ID				int identity(1, 1) not null -- identity to track add order - preserves custom sorts
	 ,EntitySID int not null index SelectedEntitySID nonclustered
	);

	declare @pinned table -- stores primary key value of pinned records
	(
		ID				int identity(1, 1) not null
	 ,EntitySID int not null index PinnedEntitySID nonclustered
	);

	begin try

-- SQL Prompt formatting off

    if @RegistrationSnapshotSID is null
    begin

      exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = 'RegistrationSnapshotSID';

			raiserror(@errorText, 18, 1);

    end

		if @IsPinnedSearch			is null set @IsPinnedSearch = @OFF
		if @IsFilterExcluded		is null set @IsFilterExcluded = @OFF
		if @IsRowLimitEnforced	is null set @IsRowLimitEnforced = @ON
		if @IsInvalid		        is null	set @IsInvalid = @OFF
    if @IsModified		      is null	set @IsModified = @OFF

		-- ensure blank text criteria are reset to null

		if len(ltrim(rtrim(@SearchString)))	= 0	set @SearchString = null;
		if len(ltrim(rtrim(@LegacyKey)))		= 0 set @LegacyKey = null
		if len(ltrim(rtrim(@RecordXID)))		= 0 set @RecordXID = null
-- SQL Prompt formatting on

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
		 ,@PinnedPropertyName = 'PinnedRegistrationProfileList';

		if @IsRowLimitEnforced = @OFF
		begin
			set @maxRows = 999999999;
		end;
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
			select top (@maxRows) -- parse attributes from the XML parameter document
				EntitySID.r.value('.', 'int') EntitySID -- return rows matching list of SID's passed in XML doc
			from
				@SIDList.nodes('//EntitySID') EntitySID(r)
			order by
				EntitySID;

		end;
		else if @IsPinnedSearch = @ON -- returned pinned records (retrieved by #Check) - filters not applied
		begin

			set @searchType = 'Pins';

			insert
				@selected (EntitySID)
			select top (@maxRows) p.EntitySID from @pinned p order by	 p.EntitySID;

		end;
		else if coalesce(@RecordSID, @RecordXID, @LegacyKey) is not null -- specific system ID was passed in search text - filters not applied
		begin

			-- This search is against a system ID value. In addition to searching
			-- dbo.Registration, form entities may be search as specified in the
			-- @EntityName parameter parsed by sf.pSearchParam#Check above. In all
			-- cases only a single Registration row will be returned so this
			-- search ignores the @RegistrationYear filter.

-- SQL Prompt formatting off
			if @RecordSID is not null set @searchType = 'SID';
			if @RecordXID is not null set @searchType = 'XID';
			if @LegacyKey is not null set @searchType = 'LegacyKey';
-- SQL Prompt formatting on

			insert
				@selected (EntitySID)
			select
				rp.RegistrationProfileSID
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationSnapshotSID																= @RegistrationSnapshotSID
				and
				((@RecordSID is not null and rp.RegistrationProfileSID		= @RecordSID)
				 or (@RecordXID is not null and rp.RegistrationProfileSID = @RecordXID)
				 or (@LegacyKey is not null and rp.RegistrationProfileSID = @LegacyKey)
				);

			set @rowsFound = @@rowcount;

			if @rowsFound = 0 -- failure to find the record is unexpected
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The "%1" record was not found. Record ID = %2. The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'Registration Profile'
				 ,@Arg2 = @RecordSID;

				raiserror(@errorText, 16, 1);

			end;

		end;
		else if @registrantNo is not null -- a search on the registrant's # (faster than name searches)
		begin

			set @searchType = 'RegistrantNo';

			insert
				@selected (EntitySID)
			select
				rp.RegistrationProfileSID
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationSnapshotSID = @RegistrationSnapshotSID and rp.RegistrantNo = @registrantNo;

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
		else if @IsInvalid = @ON
		begin

			set @searchType = 'Invalid';

			insert
				@selected (EntitySID)
			select
				rp.RegistrationProfileSID
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationSnapshotSID = @RegistrationSnapshotSID and rp.IsInvalid = @ON;

		end;
		else if @IsModified = @ON
		begin

			set @searchType = 'Modified';

			insert
				@selected (EntitySID)
			select
				rp.RegistrationProfileSID
			from
				dbo.vRegistrationProfile rp
			where
				rp.RegistrationSnapshotSID = @RegistrationSnapshotSID and rp.IsModified = @ON;

		end;
		else if @SearchString is not null
		begin

			set @searchType = 'Text';

			insert
				@selected (EntitySID)
			select
				rp.RegistrationProfileSID
			from
				sf.fPerson#SearchNames(@SearchString, @lastName, @firstName, @middleNames, @ON) px
			join
				dbo.Registrant																																	r on px.PersonSID			= r.PersonSID
			join
				dbo.RegistrationProfile																													rp on r.RegistrantSID = rp.RegistrantSID
			where
				rp.RegistrationSnapshotSID = @RegistrationSnapshotSID;

			if @SearchMessageText = @ON		-- text search on error messages is executed separately
			begin

				insert
					@selected (EntitySID)
				select
					rp.RegistrationProfileSID
				from
					dbo.RegistrationProfile rp
				left outer join
					@selected								s on rp.RegistrationProfileSID = s.EntitySID
				where
					rp.RegistrationSnapshotSID = @RegistrationSnapshotSID and rp.MessageText like '%' + @SearchString and s.EntitySID is null;
			end;

		end;
		else
		begin

			-- Defaults to returning invalid profiles if no  
			-- other search option is selected

			set @searchType = 'Invalid';

			insert
				@selected (EntitySID)
			select
				rp.RegistrationProfileSID
			from
				dbo.RegistrationProfile rp
			where
				rp.RegistrationSnapshotSID = @RegistrationSnapshotSID and rp.IsInvalid = @ON;

		end;

		-- all searches are based on results stored into
		-- the memory table

		select top (@maxRows)
			rp.RegistrationProfileSID
		 ,rp.RegistrantLabel
		 ,rp.PersonSID
		 ,rp.IsInvalid
		 ,rp.IsModified
		 ,rp.MessageText
		 ,rp.IsDeleteEnabled
		 ,cast(isnull(z.EntitySID, 0) as bit) IsPinned		-- if key found in pinned list then @ON else @OFF
		 ,@searchType													SearchType	-- search type for debugging - ignored by UI
		from
			@selected												x
		join
			dbo.vRegistrationProfile#Search rp on x.EntitySID							 = rp.RegistrationProfileSID
		left outer join
			@pinned													z on rp.RegistrationProfileSID = z.EntitySID
		order by
			rp.RegistrantLabel;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
