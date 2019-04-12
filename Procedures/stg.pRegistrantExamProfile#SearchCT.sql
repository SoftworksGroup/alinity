SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE stg.pRegistrantExamProfile#SearchCT
	@SearchString				nvarchar(150) = null	-- name, registrant# or email to search for 
 ,@IsContentSearch		bit = 0								-- when 1 then the Processing Comments are searched
 ,@QuerySID						int = null						-- key of sf.Query record providing query to execute; or 0 for "no search"
 ,@QueryParameters		xml = null						-- query parameter values, if any, for execution in the query
 ,@SIDList						xml = null						-- list of primary keys to return (selected by front end for processing)
 ,@IsPinnedSearch			bit = 0								-- when 1 returns only records pinned by the logged in user
 ,@IsRowLimitEnforced bit = 1								-- when 0, the limit of maximum rows to return is not enforced (see below)
 ,@DebugLevel					smallint = 0					-- when > 1 timing marks for debugging performance are sent to the console
as
/*********************************************************************************************************************************
Procedure: RegistrantExamProfile Search 
Notice   : Copyright © 2019 Softworks Group Inc.
Summary  : Searches the RegistrantExamProfile entity for the search string and/or other criteria provided
----------------------------------------------------------------------------------------------------------------------------------
History	 : Author							| Month Year	| Change Summary
				 : ------------------ + ----------- + ------------------------------------------------------------------------------------
 				 : Tim Edlund					| Apr 2019		|	Initial version					
          
Comments
--------
This procedure supports searches on the (stg) RegistrantExamProfile entity. Searches are supported via the @SearchString parameter
against name columns, registration# and email address.  Other searches are executed through queries.

Maximum Records
---------------
A limit to the number of records returned may be enforced.  This value is set in a configuration parameter "MaxRowsOnSearch".  
The limit can be turned off by administrators through a checkbox on the UI which set the value of @IsRowLimitEnforced. For 
pinned and SID-List searches no row limit is enforced by this procedure however, queries may be structured to enforce the 
row limit which is provided to queries as a parameter.

Default Search
--------------
No default system search is included by the procedure by design.  The page comes up without any records displayed and the user is 
required to enter search criteria or select a query. Where the user has saved a default query, that query will run when the screen
first opens.  

Text searches
-------------
Where a value is entered in @SearchString, the procedure examines it to first determine if a Registration number or record key
was entered. See procedure "sf.pSearchString#Parse" for details on how values are detected by format. 

If the string is not an identifier, then it is assumed to be a name or email address and is searched in the name and email address 
columns. 

Queries 
-------
Queries are executed through a separate sub-procedure and must be structured specifically to return a RegistrantExamProfileSID. 
Queries may include parameter values provided to the syntax of the SQL expression, or may be non-parameterized where the query 
executes without user input. The @QuerySID value is used to lookup details of the query in the sf.Query table. The SID is used
to lookup the QueryCode value which is used within the query #Execute subroutine to branch to the specific query to be called.  
Standard queries are included in all client configurations and custom, client-specific, queries may also be added to the table. 

Pinned Search
-------------
The user interface supports users marking one or more records on each search screen for later recall. The process is known
as pinning and the keys of the pinned records are stored in the user profile. When the @IsPinnedSearch parameter is passed
as ON (1) the keys of the pinned records are retrieved.

Complex Type CT
---------------
This search procedure does not return the default entity but rather a complex type. The data set returned is a sub-set of all
columns of the entity. The data set returned should be kept as small and fast as possible to generate in order to ensure the
UI is responsive for large record volumes.

System Identifier Searches
--------------------------
@recordSID search ("SID: 12345")
@recordXID search ("XID: AB12345")
@legacyKey search	("LegacyKey: XYZ1111") or "LKey:"

An override is available for string searches that include the 4 prefixes above (2 for Legacy Key) to search on system
identifiers. For example, to search on the system identifier of the main entity enter the keyword "SID:" followed by a number 
into the @SearchString - e.g. "SID:1234567". The digits are stripped from the string and converted for searching against the 
primary key. The conversion only takes place if all values following "SID:" are digits. By allowing system ID's to the be entered
into search string, administrators and configurators are able to trouble shoot error messages that return SID's using the 
user interface. The other 2 options are similar except that no validation occurs for a specific data type. The search against 
external ID's (XID) and LegacyKey are wildcard based so passing a partial value will result in found records. For Legacy-Key both 
the prefix "LegacyKey:" and "LKey:" are supported. 

Use of Temporary Table
----------------------
The coding standard for search procedures is to retrieve key values of records matching the search into a temporary table,
and then join from that table to create the result set. This technique, while more complex than direct SELECT's, generally 
improves performance since complex columns returned to the UI for display can be excluded from the core search logic. A
temporary table is used instead of a memory variable so that the query subroutine can write directly (faster than "insert ...
exe..." syntax)

Limitations
-----------
A "@IsExtendedSearch" parameter is NOT included in this procedure.  This parameter is used in other search procedures to query
historical names and email addresses, however, no such history exists for staged records.  

Example:
--------
<TestHarness>
	<Test Name = "Name" IsDefault ="true" Description="Searches on name selected at random">
		<SQLScript>
			<![CDATA[
declare @searchString nvarchar(150);

select top (1)
	@searchString = left(rxp.LastName, 3) 
from
	stg.RegistrantExamProfile rxp
where
	rxp.LastName is not null 
order by
	newid();

if @@rowcount = 0 or @searchString is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	print 'Search string = "' +  @searchString + '"'

	exec stg.pRegistrantExamProfile#SearchCT
		@SearchString = @searchString
	 ,@IsRowLimitEnforced = 0;

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "RegNo" Description="Runs the search for a Registrant number selected at random">
		<SQLScript>
			<![CDATA[  
declare
	@searchString			nvarchar(150)

select top (1)
	@searchString = rxp.RegistrantNo
from
	stg.RegistrantExamProfile rxp
order by
	newid();

if @@rowcount = 0 or @searchString is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistrantExamProfile#SearchCT
	 @SearchString = @searchString;

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "UnProcessed" Description="Runs unprocessed query for an import file selected at random (requires at least 1 unprocessed record)">
		<SQLScript>
			<![CDATA[  
declare
	@queryCode			 varchar(30) = 'S!REGXP.UNPROCESSED'
 ,@querySID				 int
 ,@importFileSID	 int
 ,@queryParameters xml;

select @querySID = q .QuerySID from sf.Query q where q.QueryCode = @queryCode;

select top (1)
	@importFileSID = rxp.ImportFileSID
from
	stg.RegistrantExamProfile rxp
join
	sf.ProcessingStatus		ps on rxp.ProcessingStatusSID = ps.ProcessingStatusSID and ps.IsClosedStatus = 0
order by
	newid();

if @querySID is null or @importFileSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	set @queryParameters =
		cast(N'<Parameters>' + N'<Parameter ID="PracticeRegisterSID" Label="Register" Value="" />' + N'<Parameter ID="ImportFileSID" Label="Import file" Value="'
				 + ltrim(@importFileSID) + '" />' + N'</Parameters>' as xml);

	exec stg.pRegistrantExamProfile#SearchCT
		@QuerySID = @querySID
	 ,@QueryParameters = @queryParameters
	 ,@IsRowLimitEnforced = 0
	 ,@DebugLevel = 1;

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:15"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'stg.pRegistrantExamProfile#SearchCT'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
begin
	set nocount on;

	declare
		@errorNo						int = 0									-- 0 no error, <50000 SQL error, else business rule
	 ,@ON									bit = cast(1 as bit)		-- used on bit comparisons to avoid multiple casts
	 ,@OFF								bit = cast(0 as bit)		-- used on bit comparisons to avoid multiple casts
	 ,@searchType					varchar(150)						-- type of search; returned in result for debugging
	 ,@maxRows						int											-- maximum rows allowed on search
	 ,@entityName					nvarchar(128)						-- name of entity parsed from search string where supported in SID/XID/LegacyKey
	 ,@recordSID					int											-- quick search: returns a profile update based on system ID
	 ,@recordXID					varchar(150)						-- quick search: returns a profile update based on an external ID
	 ,@legacyKey					nvarchar(50)						-- quick search: returns a profile update based on a legacy key
	 ,@latestRegistration dbo.LatestRegistration	-- not used but required for pass to query execution subroutine
	 ,@lastName						nvarchar(35)						-- for name searches, buffer for each name part:
	 ,@firstName					nvarchar(30)
	 ,@registrantNo				varchar(50)							-- ID number search against rxp# and other identifiers
	 ,@pinned							dbo.EntityKey						-- table storing primary key values of pinned records
	 ,@timeCheck					datetimeoffset(7);			-- timing interval buffer (for debugging performance issues)

	create table #selected (EntitySID int not null); -- stores keys of records found - target of query subroutine

	begin try
		if @DebugLevel > 0
		begin
			exec sf.pDebugPrint
				@DebugString = N'start'
			 ,@TimeCheck = @timeCheck output;
		end;

		set @SearchString = ltrim(rtrim(@SearchString));

		-- remove surrounding spaces

		-- SQL Prompt formatting off: set defaults for null parameters
		if len(@SearchString)						= 0	set @SearchString = null;
		if @IsPinnedSearch							is null set @IsPinnedSearch = @OFF
		if @IsRowLimitEnforced					is null set @IsRowLimitEnforced = @ON
		-- SQL Prompt formatting on

		-- retrieve pinned records to include "pin" visual indicators on the UI
		insert
			@pinned (EntitySID)
		exec sf.pPinnedList#Get
			@PropertyName = 'PinnedRegistrantExamProfileList';

		-- retrieve max rows; configuration setting 
		-- a setting of "0" is unlimited
		set @maxRows = cast(isnull(sf.fConfigParam#Value('MaxRowsOnSearch'), '200') as int);

		if @maxRows = 0 or @IsRowLimitEnforced = @OFF
		begin
			set @maxRows = 999999999;
		end;

		if @DebugLevel > 0
		begin
			exec sf.pDebugPrint
				@DebugString = N'parameters loaded'
			 ,@TimeCheck = @timeCheck output;
		end;

		-- process each search type
		if @IsPinnedSearch = @ON
		begin
			set @searchType = 'Pins';

			insert #selected ( EntitySID) select rxp .EntitySID from @pinned rxp ;
		end;
		else if @QuerySID is not null
		begin
			if @QuerySID = 0
			begin
				set @searchType = 'No Search'; -- avoid executing any search
			end;
			else
			begin
				set @searchType = 'Query';

				exec dbo.pQuery#Execute
					@QuerySID = @QuerySID
				 ,@ApplicationPageURI = 'RegistrantExamProfileList'
				 ,@QueryParameters = @QueryParameters
				 ,@IsRowLimitEnforced = @IsRowLimitEnforced
				 ,@LatestRegistration = @latestRegistration;

				if @DebugLevel > 0
				begin
					exec sf.pDebugPrint
						@DebugString = N'query results loaded'
					 ,@TimeCheck = @timeCheck output;
				end;
			end;
		end;
		else if @SIDList is not null
		begin
			set @searchType = 'Identifiers';

			insert
				#selected (EntitySID)
			select
				EntitySID.r.value('.', 'int') EntitySID -- return rows matching list of SID's passed in XML doc
			from
				@SIDList.nodes('//EntitySID') as EntitySID(r);
		end;
		else if @SearchString is null
		begin
			set @searchType = 'Default';

			exec dbo.pQuery#Execute
				@QuerySID = -1	-- executes the default search
			 ,@ApplicationPageURI = 'RegistrantExamProfileList'
			 ,@IsRowLimitEnforced = @IsRowLimitEnforced
			 ,@LatestRegistration = @latestRegistration;
		end;
		else -- remaining searches are based on content of search string
		begin
			exec sf.pSearchString#Parse
				@SearchString = @SearchString output
			 ,@RecordSID = @recordSID output
			 ,@RecordXID = @recordXID output
			 ,@LegacyKey = @legacyKey output
			 ,@EntityName = @entityName output
			 ,@LastName = @lastName output
			 ,@FirstName = @firstName output
			 ,@IDNumber = @registrantNo output;

			if coalesce(ltrim(@recordSID), @recordXID, @legacyKey) is not null -- system key search
			begin

				-- SQL Prompt formatting off
				if @RecordSID is not null set @searchType = 'SID';
				if @RecordXID is not null set @searchType = 'XID';
				if @LegacyKey is not null set @searchType = 'LegacyKey';
				-- SQL Prompt formatting on
				insert
					#selected (EntitySID)
				select
					rxp.RegistrantExamProfileSID
				from
					stg.RegistrantExamProfile rxp
				where
					(
						rxp.RegistrantExamProfileSID = @recordSID or rxp.RegistrantExamProfileXID = @recordXID or rxp.LegacyKey = @legacyKey
					);
			end;
			else if @registrantNo is not null
			begin
				set @searchType = 'Reg#';

				insert
					#selected (EntitySID)
				select top (@maxRows)
					rxp.RegistrantExamProfileSID
				from
					stg.RegistrantExamProfile rxp
				left outer join
					dbo.Registrant						r on rxp.RegistrantSID = r.RegistrantSID
				where
					rxp.RegistrantNo like @SearchString or r.RegistrantNo like @SearchString
				order by
					rxp.RegistrantExamProfileSID;
			end;
			else
			begin
				set @searchType = 'Text';

				if right(@SearchString, 1) <> '%'
				begin
					set @SearchString += '%';
				end;

				if @SearchString is null -- set search string to a value to avoid null scan 
				begin
					set @SearchString = '~';
				end;

				insert
					#selected (EntitySID)
				select top (@maxRows)
					rxp.RegistrantExamProfileSID
				from
					stg.RegistrantExamProfile rxp
				where
					(
						rxp.LastName like @lastName -- last name must match with last if provided													
						and
						(
							@firstName is null -- if no first name provided, only needs to match on last name
							or rxp.FirstName like @firstName -- or first name is matched
						)
					) or
						(
							@lastName is null -- last name must match with last if provided													
							and (rxp.FirstName like @firstName -- or first name is matched
									)
						) or rxp.LastName like @SearchString -- or last name matches full search string (e.g. "Van Der Hook")
					or rxp.FirstName like @SearchString -- or first name matches the search string on its own - e.g. "Tim"
				order by
					rxp.RegistrantExamProfileSID;

				set @maxRows = @maxRows - @@rowcount;

				if @IsContentSearch = @ON and @SearchString <> '~'
				begin
					if left(@SearchString, 1) <> '%'
					begin
						set @SearchString = '%' + @SearchString;
					end;

					insert
						#selected (EntitySID)
					select top (@maxRows)
						rxp.RegistrantExamProfileSID
					from
						stg.RegistrantExamProfile rxp
					left outer join
						#selected									x on rxp.RegistrantExamProfileSID = x.EntitySID
					where
						x.EntitySID is null and rxp.ProcessingComments like @SearchString;
				end;
			end;
		end;

		-- index the selected temp table to improve
		-- performance of the join in the final select
		create clustered index uk_selected_entitySID
		on #selected (EntitySID);

		-- return only the columns required for display joining to the #selected
		-- table to apply found records, and to @pinned to apply pin attribute
		select top (@maxRows)
			rxp.RegistrantExamProfileSID
		 ,rxp.RegistrantLabel
		 ,rxp.EmailAddress
		 ,rxp.ExamIdentifier
		 ,rxp.ExamDate
		 ,rxp.Score
		 ,rxp.ExamReference
		 ,rxp.ProcessingStatusLabel
		 ,rxp.FileName
		 ,rxp.LoadedTime
		 ,rxp.ProcessingComments
		 ,rxp.IsClosedStatus
		 ,rxp.ImportFileSID
		 ,rxp.ProcessingStatusSCD
		 ,rxp.IsDeleteEnabled
		 ,cast(isnull(z.EntitySID, 0) as bit) IsPinned		-- if key found in pinned list then @ON else @OFF
		 ,@searchType													SearchType	-- search type for debugging - ignored by UI
		from
			stg.vRegistrantExamProfile#Search rxp
		join
			#selected													x on rxp.RegistrantExamProfileSID = x.EntitySID
		left outer join
			@pinned														z on rxp.RegistrantExamProfileSID = z.EntitySID
		order by
			rxp.LastName
		 ,rxp.FirstName
		 ,rxp.ImportFileSID
		option (recompile); -- required due to use of memory table in order to get accurate cardinality estimate
	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	if @DebugLevel > 0
	begin
		exec sf.pDebugPrint
			@DebugString = N'done'
		 ,@TimeCheck = @timeCheck output;
	end;

	return (@errorNo);
end;
GO
