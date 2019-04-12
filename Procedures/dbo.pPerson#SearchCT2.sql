SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pPerson#SearchCT2
	@SearchString				nvarchar(150) = null	-- name, registrant# or email to search for 
 ,@IsExtendedSearch		bit = 1								-- when 1 then other names, other identifiers and past email addresses also searched
 ,@QuerySID						int = null						-- key of sf.Query record providing query to execute; or 0 for "no search"
 ,@QueryParameters		xml = null						-- query parameter values, if any, for execution in the query
 ,@SIDList						xml = null						-- list of primary keys to return (selected by front end for processing)
 ,@IsPinnedSearch			bit = 0								-- when 1 returns only records pinned by the logged in user
 ,@IsRowLimitEnforced bit = 1								-- when 0, the limit of maximum rows to return is not enforced (see below)
 ,@DebugLevel					smallint = 0					-- when > 1 timing marks for debugging performance are sent to the console
as
/*********************************************************************************************************************************
Procedure : Person Search 
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Searches the Person and Person entities for the search string and/or other criteria provided
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Cory Ng							| Jul 2017		|	Initial version					
				: Tim Edlund					| Aug 2018		| Implemented support for other name and past email searches (sf.fPerson#SearchNames)
				: Tim Edlund					| Feb 2019		| Revised to replace filters with queries (update to latest search standard)
          
Comments
--------
This procedure supports searches against the (sf) Person entity with support for searching against other registrant/profile 
related entities through queries.  Note that Person records in Alinity include both registrants, non-registrants (e.g. vendors)
and past-registrants.  

The Person page is not the location designed for following up on registration forms (renewals, applications, registration
changes, audits, etc). The Registration page has query categories designed to support those work-flows.

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
Where a value is entered in @SearchString, the procedure examines it to first determine if a person number was entered.
If the string contains no spaces and ends in 3 digits (after wildcards are removed), the procedure searches for the string in
the RegistratNo column, and in other registrant identifiers if an extended search is being applied.

If the string is not an identifier, then it is assumed to be a name or email address and is searched in the current name 
(sf.Person) and current email address (sf.PersonEmailAddress primary) tables. When the @IsExtendedSearch parameter is passed as 
ON (1), then the string is searched against sf.PersonOtherName and previous email address (sf.PersonEmailAddress non-primary) as 
well.  The extended search will also find the criteria characters mid-word in name and email address values.

Queries 
-------
These are queries designed for the person page the search results are returned to; a PersonSID must be returned. Queries may 
include parameter values provided to the syntax of the SQL expression, or may be non-parameterized where the query executes 
without user input. The @QuerySID value is used to lookup details of the query in the sf.Query table. Where the query 
includes a QueryCode value, then a separate subroutine is called to execute the query.  Standard queries are included in all
client configurations and custom, client-specific, queries may also be added to the table. 

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

Example:
--------
<TestHarness>
	<Test Name = "DefaultAdmin" IsDefault ="true" Description="Runs default search with max row limit off">
		<SQLScript>
			<![CDATA[
declare 
	@?

exec dbo.pPerson#SearchCT


			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "RegNo" Description="Runs the search for a person number selected at random">
		<SQLScript>
			<![CDATA[  
declare
	@searchString			nvarchar(150)

select top (1)
	@searchString = r.RegistrantNo
from
	sf.Person p
join
	dbo.Registrant	 r on p.RegistrantSID = r.RegistrantSID
order by
	newid();

if @@rowcount = 0 or @searchString is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pPerson#SearchCT
	 @SearchString = @searchString;

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "NameExtended" Description="Runs the search for a name selected a random with extended
	search (other name search) enabled">
		<SQLScript>
			<![CDATA[  
declare
	@searchString			nvarchar(150)

select top (1)
	@searchString = p.FirstName + N' ' + p.LastName
from
	sf.Person p
join
	dbo.Registrant	 r on p.RegistrantSID = r.RegistrantSID
join
	sf.Person				 p on r.PersonSID				= p.PersonSID
order by
	newid();

if @@rowcount = 0 or @searchString is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pPerson#SearchCT
	  @SearchString = @searchString
	 ,@IsExtendedSearch = 1;

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "RegisterQuery" Description="Runs the search for a register selected at random (no record limit)">
		<SQLScript>
			<![CDATA[  
declare
	@queryCode							varchar(30) = 'S!REG.BY.REGISTER'
 ,@querySID								int
 ,@practiceRegisterSID		int
 ,@practiceRegisterLabel	nvarchar(35)
 ,@queryParameters				xml;

select top (1)
	@practiceRegisterSID = prs.PracticeRegisterSID
	,@practiceRegisterLabel = pr.PracticeRegisterLabel
from
	sf.Person						p
join
	dbo.PracticeRegisterSection prs on p.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
join
	dbo.PracticeRegister pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
order by
	newid();

select @querySID = q .QuerySID from sf.Query q where q.QueryCode = @queryCode;

if @practiceRegisterSID is null or @querySID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	print @practiceRegisterlabel
	print @practiceRegisterSID

	set @queryParameters =
		cast(replace(
									N'<Parameters>' + N'<Parameter ID="PracticeRegisterSID" Label="Register" Value="%1" />'
									+ N'<Parameter ID="CultureSID" Label="Culture" Value="" />' + N'</Parameters>'
								 ,'%1'
								 ,ltrim(@practiceRegisterSID)
								) as xml);

	exec dbo.pPerson#SearchCT
	  @QuerySID = @querySID
	 ,@QueryParameters = @queryParameters
	 ,@IsRowLimitEnforced = 0
	 ,@DebugLevel = 1;

end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:15"/>
		</Assertions>
	</Test>
	</Test>
	<Test Name = "ApprovedNotPaid" Description="Runs approved-not-paid renewa query for prior person year">
		<SQLScript>
			<![CDATA[  
declare
	@queryCode				varchar(30) = 'S!REG.RENEWAL.NOT.PAID'
 ,@querySID					int
 ,@queryParameters	xml;

select @querySID = q .QuerySID from sf.Query q where q.QueryCode = @queryCode;

if @querySID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	set @queryParameters =
		cast(N'<Parameters>' + N'<Parameter ID="PracticeRegisterSID" Label="Register" Value="" />'
				 + N'<Parameter ID="IsPADSubscriber" Label="PAD Subscriber" Value="false" />'
				 + N'<Parameter ID="IsNotPADSubscriber" Label="Not PAD Subscriber" Value="false" />' + N'<Parameter ID="CultureSID" Label="Culture" Value="" />'
				 + N'</Parameters>' as xml);

	exec dbo.pPerson#SearchCT
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
	<Test Name = "NotRenewed" Description="Runs not renewed query for prior person year">
		<SQLScript>
			<![CDATA[  
declare
	@queryCode				varchar(30) = 'S!REG.NOT.RENEWED'
 ,@querySID					int
 ,@queryParameters	xml;

select @querySID = q .QuerySID from sf.Query q where q.QueryCode = @queryCode;

if @querySID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	set @queryParameters =
		cast(N'<Parameters>' + N'<Parameter ID="PracticeRegisterSID" Label="Register" Value="" />'
				 + N'<Parameter ID="IsPADSubscriber" Label="PAD Subscriber" Value="false" />'
				 + N'<Parameter ID="IsNotPADSubscriber" Label="Not PAD Subscriber" Value="false" />' 
				 + N'<Parameter ID="IsNotPaid" Label="Not paid" Value="false" />' 
				 + N'<Parameter ID="IsNotStarted" Label="Not started" Value="false" />' 
				 + N'<Parameter ID="FormStatusSID" Label="Status" Value="" />' 
				 + N'<Parameter ID="CultureSID" Label="Culture" Value="" />'
				 + N'</Parameters>' as xml);

	exec dbo.pPerson#SearchCT
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
	 @ObjectName = 'dbo.pPerson#SearchCT'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo								int										= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@ON											bit										= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@OFF										bit										= cast(0 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@searchType							varchar(150)														-- type of search; returned in result for debugging
	 ,@maxRows								int																			-- maximum rows allowed on search
	 ,@entityName							nvarchar(128)														-- name of entity parsed from search string where supported in SID/XID/LegacyKey
	 ,@recordSID							int																			-- quick search: returns a profile update based on system ID
	 ,@recordXID							varchar(150)														-- quick search: returns a profile update based on an external ID
	 ,@legacyKey							nvarchar(50)														-- quick search: returns a profile update based on a legacy key
	 ,@lastName								nvarchar(35)														-- for name searches, buffer for each name part:
	 ,@firstName							nvarchar(30)
	 ,@middleNames						nvarchar(30)
	 ,@registrantNo						varchar(50)															-- ID number search against p# and other identifiers
	 ,@pinned									dbo.EntityKey														-- table storing primary key values of pinned records
	 ,@timeCheck							datetimeoffset(7)												-- timing interval buffer (for debugging performance issues)

	create table #selected(EntitySID int not null)										-- stores keys of records found - target of query subroutine

	begin try

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = N'start'
			 ,@TimeCheck = @timeCheck output;

		end;

		set @SearchString = ltrim(rtrim(@SearchString)); -- remove surrounding spaces

		-- SQL Prompt formatting off: set defaults for null parameters
		if len(@SearchString)						= 0	set @SearchString = null;
		if @IsExtendedSearch						is null set @IsExtendedSearch = @ON
		if @IsPinnedSearch							is null set @IsPinnedSearch = @OFF
		if @IsRowLimitEnforced					is null set @IsRowLimitEnforced = @ON
		-- SQL Prompt formatting on

		-- retrieve pinned records to include "pin" visual indicator on the UI

		insert
			@pinned (EntitySID)
		exec sf.pPinnedList#Get
			@PropertyName = 'PinnedPersonList';

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
			insert #selected (EntitySID) select p .EntitySID from @pinned p ;
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
				 ,@ApplicationPageURI = 'PersonList'
				 ,@QueryParameters = @QueryParameters
				 ,@IsRowLimitEnforced = @IsRowLimitEnforced

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
			 ,@ApplicationPageURI = 'PersonList'
			 ,@IsRowLimitEnforced = @IsRowLimitEnforced

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
			 ,@MiddleNames = @middleNames output
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
					p.PersonSID
				from
					sf.Person p
				where
					(
						p.PersonSID			 = @recordSID or p.PersonXID = @recordXID or p.LegacyKey = @legacyKey
					) 

			end;
			else if @registrantNo is not null
			begin

				set @searchType = 'Reg#';

				if @IsExtendedSearch = @OFF
				begin

					insert
						#selected (EntitySID)
					select top (@maxRows)
						p.PersonSID
					from
						dbo.Registrant	 r
					join
						sf.Person p on r.PersonSID = p.PersonSID
					where
						r.RegistrantNo like @SearchString + '%' 
					order by
						p.PersonSID;

				end;
				else
				begin

					insert
						#selected (EntitySID)
					select top (@maxRows)
						p.PersonSID
					from
						dbo.Registrant					 r
					join
						sf.Person				 p on r.PersonSID = p.PersonSID
					left outer join
						dbo.RegistrantIdentifier ri on r.RegistrantSID	= ri.RegistrantSID
					where
						(
							r.RegistrantNo like '%' + @SearchString + '%' or ri.IdentifierValue like '%' + @SearchString + '%'
						) 
					order by
						p.PersonSID;

				end;

			end;
			else
			begin

				set @searchType = 'Text';

				insert
					#selected (EntitySID)
				select top (@maxRows)
					p.PersonSID
				from
					sf.fPerson#SearchNames(@SearchString, @lastName, @firstName, @middleNames, @IsExtendedSearch) px
				join
					dbo.Registrant																																								r on px.PersonSID			 = r.PersonSID
				join
					sf.Person																																							p on r.PersonSID = p.PersonSID
				order by
					p.PersonSID;

			end;
		end;

		-- index the selected temp table to improve
		-- performance of the join in the final select

		create clustered index uk_selected_entitySID on #selected (EntitySID)

			-- return only the columns required for display joining to the #selected
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
				#selected					 x on p.PersonSID = x.EntitySID
			left outer join
				@pinned						 z on p.PersonSID = z.EntitySID
			order by
				p.LastName
			 ,p.FirstName
			 ,p.MiddleNames
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
