SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pExportFile#SearchCT]
	@SearchString						 nvarchar(150) = null -- group name, label or tag to search
 ,@DataSourceSID					 int = null						-- filter: only exports using this data source
 ,@ApplicationPageSID			 int = null						-- filter: only exports using this page
 ,@ExportJobSID						 int = null						-- filter: only exports using this job
 ,@IsMine									 bit = 1							-- filter: returns only exports for the current user if 1
 ,@QuerySID								 int = null						-- SID of sf.Query row providing SQL syntax to execute - not combined
 ,@QueryParameters				 xml = null						-- list of query parameters associated with the query SID
 ,@IsPinnedSearch					 bit = 0							-- quick search: only returns pinned records - not combined
 ,@SIDList								 xml = null						-- quick search: list of pinned records to return (xml contains SID's)
 ,@RecordSID							 int = null						-- quick search: returns records based on system ID
 ,@RecordXID							 varchar(150) = null	-- quick search: returns records based on an external ID
 ,@LegacyKey							 nvarchar(50) = null	-- quick search: returns records based on a legacy key
 ,@IsFilterExcluded				 bit = 0							-- when 1, then filter values are excluded even when populated
 ,@IsRowLimitEnforced			 bit = 1							-- when 0, the limit of maximum rows to return is not enforced (see below)
as
/*********************************************************************************************************************************
Procedure : Export File Search
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Searches the export file search entity for the search string and/or other search criteria provided
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Kris Dawson	| May 2018		|	Initial version

Comments
--------
This procedure supports dashboard displays and general searches of the "ExportFile" entity from the administrative UI. Various 
search options are supported but the primary method is to SELECT for a search string entered by the end user with various filters 
optionally applied. The string typically contains a group name, label or tag value.

Complex Type CT
---------------
This search procedure does not return the default entity but rather a complex type. A corresponding view also exists against
which the search is performed.  The complex type is used to improve performance.

Default search
--------------
If no search string or custom query is passed to the procedure the default search is executed. The default search returns all
ExportFiles (limited by Max Rows) owned by the current user. 

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
The search is performed against the message text.

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
	<Test Name = "DefaultAdmin" IsDefault ="true" Description="Runs default search for an administrator">
		<SQLScript>
			<![CDATA[
exec sf.pExportFile#SearchCT																				-- default search
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "ApplicationPage" Description="Runs a search by application page">
		<SQLScript>
			<![CDATA[
declare
	@applicationPageSID int = null
begin

	select top 1 @applicationPageSID = ApplicationPageSID from sf.vExportFile#Search where ApplicationPageSID is not null order by newid()

	exec sf.pExportFile#SearchCT @ApplicationPageSID = @applicationPageSID

end
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "DataSource" Description="Runs a search by data source">
		<SQLScript>
			<![CDATA[
declare
	@dataSourceSID int = null
begin

	select top 1 @dataSourceSID = DataSourceSID from sf.vExportFile#Search where DataSourceSID is not null order by newid()

	exec sf.pExportFile#SearchCT @DataSourceSID = @dataSourceSID

end
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "ExportJob" Description="Runs a search by export job">
		<SQLScript>
			<![CDATA[
declare
	@exportJobSID int = null
begin

	select top 1 @exportJobSID = ExportJobSID from sf.vExportFile#Search where ExportJobSID is not null order by newid()

	exec sf.pExportFile#SearchCT @ExportJobSID = @exportJobSID

end
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pExportFile#SearchCT'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo										int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText									nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON													bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@OFF												bit						= cast(0 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@searchType									varchar(25)											-- type of search; returned in result for debugging
	 ,@maxRows										int															-- maximum rows allowed on search
	 ,@currentApplicationUserSID	int															-- the current application user sid
	 ,@currentUser								nvarchar(75);										-- the current user name

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

		-- if filters are to be excluded, set them to null 
		-- (passed by the front end in order not to lose values from UI)

		if @IsFilterExcluded = @ON 
		begin
		
			set @DataSourceSID = null;
			set @ApplicationPageSID = null;
			set @ExportJobSID = null;
			set @IsMine = @OFF;
		
		end;

		-- call a subroutine to validate and format search parameters and
		-- to return list of pinned records for this user (if any)

		insert
			@pinned (EntitySID)
		exec sf.pSearchParam#Check -- check parameters and format for searching
			@SearchString = @SearchString output
		 ,@ApplicationUserSID = @currentApplicationUserSID output
		 ,@RecordSID = @RecordSID output
		 ,@RecordXID = @RecordXID output
		 ,@LegacyKey = @LegacyKey output
		 ,@MaxRows = @maxRows output
		 ,@IDCharacters = '0123456789'
		 ,@ConvertDatesToST = @ON
		 ,@PinnedPropertyName = 'PinnedExportFileList';

		if @IsRowLimitEnforced = @OFF set @maxRows = 999999999; -- if row limit is not being enforced, set max rows to a billion

		select @currentUser = UserName from sf.ApplicationUser where ApplicationUserSID = @currentApplicationUserSID;
		set @isMine = isnull(@isMine, @ON);

		-- execute the searches

		if @QuerySID is not null -- dynamic query search
		begin

			set @searchType = 'Query';

			insert
				@selected (EntitySID)
			exec sf.pQuery#Execute
				@QuerySID = @QuerySID
			 ,@QueryParameters = @QueryParameters
			 ,@MaxRows = @maxRows;	-- query syntax may support restriction on max rows so pass it

		end;
		else if @SIDList is not null -- set of specific SIDs passed or pinned record search
		begin

			set @searchType = 'Identifiers';

			insert
				@selected (EntitySID)
			select -- parse attributes from the XML parameter document
				EntitySID.r.value('.', 'int') EntitySID -- return rows matching list of SID's passed in XML doc
			from
				@SIDList.nodes('//EntitySID') EntitySID(r);

		end;
		else if @IsPinnedSearch = @ON -- returned pinned records (retrieved by#Check)
		begin

			set @searchType = 'Pins';

			insert @selected (EntitySID) select p .EntitySID from @pinned p ;

		end;
		else if coalesce(@RecordSID, @RecordXID, @LegacyKey) is not null -- specific system ID was passed in search text
		begin

			if @RecordSID is not null set @searchType = 'SID';
			if @RecordXID is not null set @searchType = 'XID';
			if @LegacyKey is not null set @searchType = 'LegacyKey';

			insert
				@selected (EntitySID)
			select
				ef.ExportFileSID
			from
				sf.ExportFile ef
			where
				ef.ExportFileSID									 = @RecordSID -- no filters apply on this search
				or isnull(ef.ExportFileXID, '!~@') = @RecordXID or isnull(ef.LegacyKey, '!~@') = @LegacyKey;

			if @@rowcount = 0 -- failure to find the record is unexpected
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The "%1" record was not found. Record ID = %2. The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'Export File'
				 ,@Arg2 = @RecordSID;

				raiserror(@errorText, 16, 1);

			end;

		end;		
		else if @SearchString is not null or @ApplicationPageSID is not null or @DataSourceSID is not null or @ExportJobSID is not null or @IsMine = @OFF
		begin

			set @searchType = 'Text';			

			insert
				@selected (EntitySID)
			select
				ef.ExportFileSID
			from
				sf.vExportFile#Search ef
			where
				isnull(ef.MessageText, 'x') like '%' + isnull(@searchString, '') + '%'
			and
				isnull(ef.DataSourceSID, -1) = isnull(@DataSourceSID, isnull(ef.DataSourceSID, -1))
			and
				isnull(ef.ApplicationPageSID, -1) = isnull(@ApplicationPageSID, isnull(ef.ApplicationPageSID, -1))
			and
				isnull(ef.ExportJobSID, -1) = isnull(@ExportJobSID, isnull(ef.ExportJobSID, -1))
			and
				ef.CreateUser = case when @isMine = @ON then @currentUser else ef.CreateUser end;


		end;
		else -- default search is all the current user's exports
		begin

			set @searchType = 'Default';

			insert
				@selected (EntitySID)
			select
				ef.ExportFileSID
			from
				sf.ExportFile ef
			where 
				ef.CreateUser = @currentUser;

		end;

		-- return only the columns required for display joining to the @selected
		-- table to apply found records, and to @pinned to apply pin attribute

		select top (@maxRows)
			ef.ExportFileSID
		 ,ef.ProcessedTime
		 ,ef.MessageText
		 ,ef.IsFailed
		 ,ef.FileFormatLabel
		 ,ef.FileFormatSCD
		 ,ef.IsComplete
		 ,ef.IsInProcess
		 ,ef.IsDeleteEnabled
		 ,ef.CreateUser
		 ,ef.CreateTime
		 ,ef.UpdateUser
		 ,ef.UpdateTime
		 ,ef.ApplicationPageSID 
		 ,ef.ApplicationPageLabel
		 ,ef.DataSourceSID
		 ,ef.DataSourceLabel
		 ,ef.ExportJobSID
		 ,ef.ExportJobName
		 ,ef.FileLength
		 ,cast(isnull(z.EntitySID, 0) as bit)													 IsPinned		-- if key found in pinned list then @ON else @OFF
		 ,@searchType																									 SearchType -- search type for debugging - ignored by UI
		from
			sf.vExportFile#Search		 ef
		join
			@selected					 x on ef.ExportFileSID			 = x.EntitySID
		left outer join
			@pinned						 z on ef.ExportFileSID			 = z.EntitySID
		order by
			ef.CreateTime desc;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
