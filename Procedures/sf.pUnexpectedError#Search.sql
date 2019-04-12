SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pUnexpectedError#Search]
	@SearchString				nvarchar(150) = null	-- error title or tag to search - not combined
 ,@SearchMessage			bit						= 0			-- indicates whether to search the message with the search string
 ,@IsHandledException bit						= 1			-- when 1 handle exceptions are included - combined
 ,@IsUnexpectedError	bit						= 1			-- when 1 unexpected errors (SQL errors) are included - combined
 ,@StartDate					date					= null	-- earliest error occurence date to include - combined
 ,@EndDate						date					= null	-- last update date for which to bring back records - combined
 ,@QuerySID						int						= null	-- SID of sf.Query row providing SQL syntax to execute - not combined
 ,@QueryParameters		xml						= null	-- list of query parameters associated with the query SID
 ,@IsPinnedSearch			bit						= 0			-- quick search: only returns pinned records - not combined
 ,@SIDList						xml						= null	-- quick search: list of pinned records to return (xml contains SID's)
 ,@RecordSID					int						= null	-- quick search: returns records based on system ID
 ,@RecordXID					varchar(150)	= null	-- quick search: returns records based on an external ID
 ,@LegacyKey					nvarchar(50)	= null	-- quick search: returns records based on a legacy key
 ,@IsFilterExcluded		bit						= 0			-- when 1, then filter values are excluded even when populated
 ,@IsRowLimitEnforced bit						= 1			-- when 0, the limit of maximum rows to return is not enforced (see below)
as
/*********************************************************************************************************************************
Procedure : Unexpected Error Search
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Searches the Unexpected Error entity for the search string and/or other search criteria provided
History   : Author(s)   | Month Year  | Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Oct 2017		| Initial version

Comments
--------
This procedure supports dashboard displays and general searches of the "UnexpectedError" entity from the UI. Various search
options are supported but the primary method is to SELECT for a search string.  When a search string is entered no filters
are combined with it.  If the search string is blank, then multiple filters will apply to return the result set, or, if no
search string or filters are applied then the default search is returned (see below).

Text search strings expected are:  error number, procedure name or, words or phrases from the message text.  For searching
the message text the "@SearchMessage" parameter must be passed as ON (1).

Returns Entity
--------------
This search procedure returns the full entity for sf.vUnexpectedError.

Default search
--------------
If no search string or custom query is passed to the procedure the default search is executed. The default search returns the
most recent UnexpectedErrors (limited by Max Rows).

Row Limit (MaxRows)
-------------------
The number of records returned on any search is limited by a configuration parameter setting "MaxRowsOnSearch" which if not set,
defaults to 200. The maximum is implemented to avoid timeout errors on rendering complex result layouts - particularly on slower
mobile-phone based connections.  The limit can be turned off by passing @IsRowLimitEnforced as 0 (it defaults to ON).

Filters
-------
Filters are NOT applied in combination with text searches or when a query identifier has been passed in.  Filters are
based on foreign key or bit values on the main entity and can generally be applied without significantly increasing processing
time assuming appropriate indexing.

pSearchParam#Check (SF)
-----------------------
A subroutine in the framework is called to check parameters passed in and to format the text string and retrieve configuration
settings. The procedure is applied by all (current) search procedures and implements  formatting and priority-setting branching
critical to the searching process.  Be sure to review the details of that that procedure to debug issues related to search
string failures.

Text/String search
------------------
The search is performed against the message code, error number and procedure name.  If the bit to search the content of the
message is passed ON, then a full text search of that content is also incorporated.  For searches on the message code and
procedure name, wild cards are supported within the text entered.  A trailing "%" is always added to the search string but
a leading "%" is not added in order to preserve use of indexes.

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
This procedure orders all results by create time but other sort orders can be set in the UI.

Use of Memory Table
-------------------
The application standard for search procedures is to retrieve key values of records matching the search into a temporary table,
and then join from that table to create the result set.  This technique, while more complex than direct SELECT's, generally
improves performance since complex columns returned to the UI for display only can be excluded from retrieval logic.

Example:
--------
<TestHarness>
	<Test Name = "UnexpectedErrorSID" IsDefault ="true" Description="Finds the anouncement with the corresponding UnexpectedErrorSID">
    <SQLScript>
      <![CDATA[

			declare
				@recordSID    int

			select top (1)
				@recordSID = x.UnexpectedErrorSID
			from
				sf.UnexpectedError x
			order by
				newid()

			exec sf.pUnexpectedError#Search
				@RecordSID = @recordSID

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'sf.pUnexpectedError#Search'
	,	@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo			int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON						bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@OFF					bit						= cast(0 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@searchType		varchar(25)											-- type of search; returned in result for debugging
	 ,@errorNumber	varchar(5)											-- buffer for searches on error number
	 ,@maxRows			int															-- maximum rows allowed on search
	 ,@queryMaxRows int;														-- maximum rows allowed on preliminary query

	declare @selected table -- stores primary key values of records found
	(
		ID				int identity(1, 1) not null -- identity to track add order - preserves custom sorts
	 ,EntitySID int not null								-- record ID joined to main entity to return results
	);

	declare @pinned table -- stores primary key value of pinned records
	(
		ID				int identity(1, 1) not null
	 ,EntitySID int not null
	);

	begin try

		-- if filters are to be excluded, set them to default values
		-- (passed by the front end in order not to lose values from UI)

		if @IsFilterExcluded = @ON
		begin
			set @SearchMessage = @OFF;
			set @IsHandledException = @ON;
			set @IsUnexpectedError = @ON;
			set @StartDate = null;
			set @EndDate = null;
		end;

		-- call a subroutine to validate and format search parameters and
		-- to return list of pinned records for this user (if any)

		insert
			@pinned (EntitySID)
		exec sf.pSearchParam#Check -- check parameters and format for searching
			@SearchString = @SearchString output
		 ,@DateRangeStart = @StartDate output -- default output when null is 1900-01-01
		 ,@DateRangeEnd = @EndDate output			-- default output when null is 2999-12-31
		 ,@RecordSID = @RecordSID output
		 ,@RecordXID = @RecordXID output
		 ,@LegacyKey = @LegacyKey output
		 ,@MaxRows = @maxRows output
		 ,@ConvertDatesToST = @ON
		 ,@IDNumber = @errorNumber output
		 ,@IDCharacters = '0123456789'
		 ,@PinnedPropertyName = 'PinnedUnexpectedErrorList';

		if @IsRowLimitEnforced = @OFF
		begin
			set @maxRows = 999999999; -- if row limit is not being enforced, set max rows to a billion
		end;

		set @queryMaxRows = @maxRows;

		-- execute the searches

		if @QuerySID is not null -- dynamic query search
		begin

			set @searchType = 'Query';

			insert
				@selected (EntitySID)
			exec sf.pQuery#Execute
				@QuerySID = @QuerySID
			 ,@QueryParameters = @QueryParameters
			 ,@MaxRows = @queryMaxRows; -- query syntax may support restriction on max rows so pass it

		end;
		else if @SIDList is not null -- set of specific SIDs passed or pinned record search
		begin

			set @searchType = 'Identifiers';

			insert
				@selected (EntitySID)
			select top (@queryMaxRows) -- parse attributes from the XML parameter document
				EntitySID.r.value('.', 'int') EntitySID -- return rows matching list of SID's passed in XML doc
			from
				@SIDList.nodes('//EntitySID') as EntitySID(r);

		end;
		else if @IsPinnedSearch = @ON -- returned pinned records (retrieved by#Check)
		begin

			set @searchType = 'Pins';

			insert
				@selected (EntitySID)
			select top (@maxRows) p.EntitySID from	@pinned p;

		end;
		else if coalesce(@RecordSID, @RecordXID, @LegacyKey) is not null -- specific system ID was passed in search text
		begin
			set @searchType = 'Key';
			print @searchType;
			print @RecordSID;
			if @RecordSID is not null
				set @searchType = 'SID';
			if @RecordXID is not null
				set @searchType = 'XID';
			if @LegacyKey is not null
				set @searchType = 'LegacyKey';

			insert
				@selected (EntitySID)
			select
				ue.UnexpectedErrorSID
			from
				sf.UnexpectedError ue
			where
				ue.UnexpectedErrorSID										= @RecordSID -- no filters apply on this search
				or isnull(ue.UnexpectedErrorXID, '!~@') = @RecordXID or isnull(ue.LegacyKey, '!~@') = @LegacyKey;

			if @@rowcount = 0 -- failure to find the record is unexpected in this scenario!
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The "%1" record was not found. Record ID = %2. The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'UnexpectedError'
				 ,@Arg2 = @RecordSID;

				raiserror(@errorText, 16, 1);

			end;

		end;
		else if @errorNumber is not null
		begin

			set @searchType = 'ErrorNo';
			set @errorNo = cast(@errorNumber as int);

			insert
				@selected (EntitySID)
			select
				ue.UnexpectedErrorSID
			from
				sf.UnexpectedError ue
			where
				isnull(ue.ErrorNumber, -1) = @errorNo;

			set @errorNo = 0;

		end;
		else if @SearchString is not null
		begin

			set @searchType = 'Text';

			insert
				@selected (EntitySID)
			select top (@maxRows)
				ue.UnexpectedErrorSID
			from
				sf.UnexpectedError ue
			where (ue.MessageSCD like @SearchString) or (ue.ProcName like @SearchString) or (
																																												@SearchMessage = @ON and ue.MessageText like N'%' + @SearchString
																																											)
			order by
				ue.CreateTime desc;

		end;
		else -- default search is all error s to limit
		begin

			set @searchType = 'Default';

			insert
				@selected (EntitySID)
			select top (@maxRows)
				ue.UnexpectedErrorSID
			from
				sf.UnexpectedError ue
			order by
				ue.CreateTime desc;

		end;

		-- return only the columns required for display joining to the @selected
		-- table to apply found records, and to @pinned to apply pin attribute

		select top (@maxRows)
			--!<ColumnList DataSource="sf.vUnexpectedError" Alias="ue">
			 ue.UnexpectedErrorSID
			,ue.MessageSCD
			,ue.ProcName
			,ue.LineNumber
			,ue.ErrorNumber
			,ue.MessageText
			,ue.ErrorSeverity
			,ue.ErrorState
			,ue.SPIDNo
			,ue.MachineName
			,ue.DBUser
			,ue.CallEvent
			,ue.CallParameter
			,ue.CallSyntax
			,ue.UserDefinedColumns
			,ue.UnexpectedErrorXID
			,ue.LegacyKey
			,ue.IsDeleted
			,ue.CreateUser
			,ue.CreateTime
			,ue.UpdateUser
			,ue.UpdateTime
			,ue.RowGUID
			,ue.RowStamp
			,ue.IsDeleteEnabled
			,ue.IsReselected
			,ue.IsNullApplied
			,ue.zContext
		--!</ColumnList>
		 ,@searchType SearchType	-- added to support debugging (ignored by UI)
		from
			sf.vUnexpectedError ue
		join
			@selected						x on ue.UnexpectedErrorSID = x.EntitySID
		where
			ue.CreateTime							>= @StartDate
			and ue.CreateTime					<= @EndDate
			and (
						@IsHandledException = @ON or ue.ErrorNumber <> 50000
					)
			and (
						@IsUnexpectedError	= @ON or ue.ErrorNumber = 50000
					);

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
