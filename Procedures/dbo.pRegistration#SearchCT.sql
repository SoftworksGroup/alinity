SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistration#SearchCT
	@SearchString				nvarchar(150) = null	-- name, registrant# or email to search for 
 ,@RegistrationYear		smallint = null				-- registration year selected in the UI (should be provided unless executing default query)
 ,@IsExtendedSearch		bit = 1								-- when 1 then other names, other identifiers and past email addresses also searched
 ,@QuerySID						int = null						-- key of sf.Query record providing query to execute; or 0 for "no search"
 ,@QueryParameters		xml = null						-- query parameter values, if any, for execution in the query
 ,@SIDList						xml = null						-- list of primary keys to return (selected by front end for processing)
 ,@IsPinnedSearch			bit = 0								-- when 1 returns only records pinned by the logged in user
 ,@IsRowLimitEnforced bit = 1								-- when 0, the limit of maximum rows to return is not enforced (see below)
 ,@DebugLevel					smallint = 0					-- when > 1 timing marks for debugging performance are sent to the console
as
/*********************************************************************************************************************************
Procedure : Registration Search 
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Searches the Person and Registration entities for the search string and/or other criteria provided
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund					| Sep 2018		| Initial version (rewrite from previous version allowing filters)
				: Tim Edlund					| Jan 2019		| Replaced scalar function calls with SELECTs and minimized calc of @latestRegistration
				: Tim Edlund					| Jan 2019		| Modified to use #selected rather than @selected for direct loading in query subroutine
          
Comments
--------
This procedure supports searches against the (dbo) Registration and (sf) Person entities. The Registrations search page 
shows the most recent registration record for the given @RegistrationYear. The registration year defaults to the current year. If 
there are multiple registrations in the same year, only the last appears on the search page. It is possible to select a previous 
registration year to see the last active registration in that year. It is not possible to show multiple registration years on the 
search results page.

As of this writing, Alinity does not support multiple concurrent registrations. A person may have a non-expired registration on
only 1 practice-register(section) at the same time.

Base Registration and Related Forms
-----------------------------------
The registration record returned is joined to member-service forms related to the registration.  Member-service forms include: 
Application, Renewal, Reinstatement and Registration-Change.  Each of these forms results in a new registration record being
created after the form is approved and paid for when fees are required. Each of these form-type records includes a foreign key to 
the Registration in effect at the time they are created.  

The most typical example is showing a registration which has a renewal. Assuming the @RegistrationYear is the current one, the
screen will show a registration that has not expired so it is the registration in effect but, during the renewal period, the search
result will show a link to the renewal form if one has been started by the registrant.  If one has not been started then "None"
is displayed as the associated form.

The Application record follows the same pattern as the other 3 registration forms in having a Registration-SID as a foreign
key.  This occurs because when an applicant is first created a dbo.Registration record is created for them that puts them on the
"Applicant" register. That registration record is then the base for the dbo.RegistrantApp record.

Only 1 of the form-type records can be created for any Registration since, until a form is finalized, creating a second
registration-form on the same base registration is not allowed.  For example, the system does not allow a Registration-Change
record to be added for the Registration record that also has a Renewal pending. The search joins out to look for the existence
of registration-form records and returns their status.

Tabs and totals are provided in the user interface separating records based on who is Next-To-Act for open forms associated with 
the Registration. Open forms can include: Applications, Renewals, Reinstatements and Registration changes. Note that Learning 
Plans and Profile Updates are managed in separate screens and have their own search procedures.  Learning Plans and Profile
Updates may also be child-forms of renewal and their details can be accessed through the Renewal via these search results. 

Next-to-Act (FormOwnerSCD)
--------------------------
In order to make it easier for administrators to identify who is required to take the next action, the user interface
presents the returned data set on different tabs:  Applicant/Member, Reviewer, Admin and Done (no further action 
required).  Where a member is on a register that requires renewal, and the renewal period for that year has opened, 
and they have not yet started a renewal (or started one that is now WITHDRAWN), then the current form will be listed as 
NONE but their Registration record is included in the "Member" next-to-act classification.  

Maximum Records
---------------
A limit to the number of records returned may be enforced.  This value is set in a configuration parameter "MaxRowsOnSearch".  
The limit can be turned off by administrators through a checkbox on the UI which set the value of @IsRowLimitEnforced. For 
pinned and SID-List searches no row limit is enforced by this procedure however, queries may be structured to enforce the 
row limit which is provided to queries as a parameter.

Default Search
--------------
If no criteria is provided to the procedure the default search is executed. The default search is a query with the 
"IsApplicationPageDefault" value to ON (1).  If no registration year is passed then the current registration year is
used as default.

Text searches
-------------
Where a value is entered in @SearchString, the procedure examines it to first determine if a registration number was entered.
If the string contains no spaces and ends in 3 digits (after wildcards are removed), the procedure searches for the string in
the RegistratNo column, and in other registrant identifiers if an extended search is being applied.

If the string is not an identifier, then it is assumed to be a name or email address and is searched in the current name 
(sf.Person) and current email address (sf.PersonEmailAddress primary) tables. When the @IsExtendedSearch parameter is passed as 
ON (1), then the string is searched against sf.PersonOtherName and previous email address (sf.PersonEmailAddress non-primary) as 
well.  The extended search will also find the criteria characters mid-word in name and email address values.

Queries 
-------
These are queries designed for the registration page the search results are returned to.  Queries may include parameter 
values provided to the syntax of the SQL expression, or may be non-parameterized where the query executes without user
input. The @QuerySID value is used to lookup details of the query in the sf.Query table. Standard queries are included in all
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
	@registrationYear smallint = dbo.fRegistrationYear#Current();

exec dbo.pRegistration#SearchCT
	@RegistrationYear = @registrationYear
 ,@SearchString = 'test'
 ,@IsRowLimitEnforced = 0;

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "RegNo" Description="Runs the search for a registration number selected at random">
		<SQLScript>
			<![CDATA[  
declare
	@searchString			nvarchar(150)
 ,@registrationYear smallint = dbo.fRegistrationYear#Current() - 1;

select top (1)
	@searchString = r.RegistrantNo
from
	dbo.Registration reg
join
	dbo.Registrant	 r on reg.RegistrantSID = r.RegistrantSID
where
	reg.RegistrationYear = @registrationYear
order by
	newid();

if @@rowcount = 0 or @searchString is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistration#SearchCT
		@RegistrationYear = @registrationYear
	 ,@SearchString = @searchString;

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
 ,@registrationYear smallint = dbo.fRegistrationYear#Current() - 1;

select top (1)
	@searchString = p.FirstName + N' ' + p.LastName
from
	dbo.Registration reg
join
	dbo.Registrant	 r on reg.RegistrantSID = r.RegistrantSID
join
	sf.Person				 p on r.PersonSID				= p.PersonSID
where
	reg.RegistrationYear = @registrationYear
order by
	newid();

if @@rowcount = 0 or @searchString is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistration#SearchCT
		@RegistrationYear = @registrationYear
	 ,@SearchString = @searchString
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
 ,@registrationYear				int				 = dbo.fRegistrationYear#Current()
 ,@practiceRegisterSID		int
 ,@practiceRegisterLabel	nvarchar(35)
 ,@queryParameters				xml;

select top (1)
	@practiceRegisterSID = prs.PracticeRegisterSID
	,@practiceRegisterLabel = pr.PracticeRegisterLabel
from
	dbo.Registration						reg
join
	dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
join
	dbo.PracticeRegister pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
where
	reg.RegistrationYear = @registrationYear
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

	exec dbo.pRegistration#SearchCT
		@RegistrationYear = @registrationYear
	 ,@QuerySID = @querySID
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
	<Test Name = "ApprovedNotPaid" Description="Runs approved-not-paid renewa query for prior registration year">
		<SQLScript>
			<![CDATA[  
declare
	@queryCode				varchar(30) = 'S!REG.RENEWAL.NOT.PAID'
 ,@querySID					int
 ,@registrationYear int					= dbo.fRegistrationYear#Current() - 1
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

	exec dbo.pRegistration#SearchCT
		@RegistrationYear = @registrationYear
	 ,@QuerySID = @querySID
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
	<Test Name = "NotRenewed" Description="Runs not renewed query for prior registration year">
		<SQLScript>
			<![CDATA[  
declare
	@queryCode				varchar(30) = 'S!REG.NOT.RENEWED'
 ,@querySID					int
 ,@registrationYear int					= dbo.fRegistrationYear#Current() - 1
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

	exec dbo.pRegistration#SearchCT
		@RegistrationYear = @registrationYear
	 ,@QuerySID = @querySID
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
	 @ObjectName = 'dbo.pRegistration#SearchCT'
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
	 ,@registrantNo						varchar(50)															-- ID number search against reg# and other identifiers
	 ,@renewalGeneralOpenTime datetime																-- time when general renewal is open for the following year
	 ,@renewalGeneralEndTime	datetime																-- time when the general renewal for the year has closed
	 ,@isRenewalOpen					bit										= cast(0 as bit)	-- tracks whether renewal is open for the following year
	 ,@pinned									dbo.EntityKey														-- table storing primary key values of pinned records
	 ,@latestRegistration			dbo.LatestRegistration									-- table storing keys of registration record for selected year 
	 ,@timeCheck							datetimeoffset(7)												-- timing interval buffer (for debugging performance issues)
	 ,@filterMode							varchar(10)						= 'delete';				-- setting for how filtering of memory table will be processed

	create table #selected(EntitySID int not null)										-- stores keys of records found - target of query subroutine

	begin try

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = N'start'
			 ,@TimeCheck = @timeCheck output;

		end;

		-- a registration year is required for default queries
		-- so use the current year

		if @RegistrationYear is null
		begin
			set @RegistrationYear = dbo.fRegistrationYear#Current();
		end;

		-- determine whether the renewal period for the year following
		-- the selected one is open (impacts form-owner setting)
		-- where no forms pending and renewal is not started

		select
			@renewalGeneralOpenTime = rsy.RenewalGeneralOpenTime
		 ,@renewalGeneralEndTime	= rsy.RenewalEndTime
		from
			dbo.RegistrationScheduleYear rsy
		where
			rsy.RegistrationYear = (@RegistrationYear + 1);

		if sf.fNow() between @renewalGeneralOpenTime and @renewalGeneralEndTime
		begin
			set @isRenewalOpen = @ON;
		end;

		set @SearchString = ltrim(rtrim(@SearchString)); -- remove surrounding spaces

		-- SQL Prompt formatting off: set defaults for null parameters
		if len(@SearchString)						= 0	set @SearchString = null;
		if @IsExtendedSearch						is null set @IsExtendedSearch = @ON
		if @IsPinnedSearch							is null set @IsPinnedSearch = @OFF
		if @IsRowLimitEnforced					is null set @IsRowLimitEnforced = @ON
		if @RegistrationYear						is null set @RegistrationYear = dbo.fRegistrationYear#Current()
		-- SQL Prompt formatting on

		-- retrieve pinned records to include "pin" visual indicator on the UI

		insert
			@pinned (EntitySID)
		exec sf.pPinnedList#Get
			@PropertyName = 'PinnedRegistrationList';

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

		-- this search always requires the current registration
		-- list to produce the data set but for some queries it
		-- is faster to have query isolate the latest registration

		if @QuerySID is null or not exists
		(
			select
				1
			from
				sf.Query q
			where
				q.QuerySID = @QuerySID and q.QueryCode like 'S!REG.RENEWAL.%'
		)
		begin

			insert
				@latestRegistration (RegistrationSID, RegistrantSID)
			select
				lReg.RegistrationSID
			 ,lReg.RegistrantSID
			from
				dbo.fRegistrant#LatestRegistration$SID(-1, @RegistrationYear) lReg;

			if @DebugLevel > 0
			begin

				exec sf.pDebugPrint
					@DebugString = N'latest reg loaded'
				 ,@TimeCheck = @timeCheck output;

			end;

		end;
		else -- where the latest registrations are not loaded here, final filtering mode must be "insert"
		begin
			set @filterMode = 'insert';
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
				 ,@ApplicationPageURI = 'RegistrationList'
				 ,@QueryParameters = @QueryParameters
				 ,@IsRowLimitEnforced = @IsRowLimitEnforced
				 ,@RegistrationYear = @RegistrationYear
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
			 ,@ApplicationPageURI = 'RegistrationList'
			 ,@IsRowLimitEnforced = @IsRowLimitEnforced
			 ,@RegistrationYear = @RegistrationYear
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
					reg.RegistrationSID
				from
					dbo.Registration reg
				where
					(
						reg.RegistrationSID			 = @recordSID or reg.RegistrationXID = @recordXID or reg.LegacyKey = @legacyKey
					) and reg.RegistrationYear = @RegistrationYear;

			end;
			else if @registrantNo is not null
			begin

				set @searchType = 'Reg#';

				if @IsExtendedSearch = @OFF
				begin

					insert
						#selected (EntitySID)
					select top (@maxRows)
						reg.RegistrationSID
					from
						dbo.Registrant	 r
					join
						dbo.Registration reg on r.RegistrantSID = reg.RegistrantSID
					where
						r.RegistrantNo like @SearchString + '%' and reg.RegistrationYear = @RegistrationYear
					order by
						reg.RegistrationSID;

				end;
				else
				begin

					insert
						#selected (EntitySID)
					select top (@maxRows)
						reg.RegistrationSID
					from
						dbo.Registrant					 r
					join
						dbo.Registration				 reg on r.RegistrantSID = reg.RegistrantSID
					left outer join
						dbo.RegistrantIdentifier ri on r.RegistrantSID	= ri.RegistrantSID
					where
						(
							r.RegistrantNo like '%' + @SearchString + '%' or ri.IdentifierValue like '%' + @SearchString + '%'
						) and reg.RegistrationYear = @RegistrationYear
					order by
						reg.RegistrationSID;

				end;

			end;
			else
			begin

				set @searchType = 'Text';

				insert
					#selected (EntitySID)
				select top (@maxRows)
					reg.RegistrationSID
				from
					sf.fPerson#SearchNames(@SearchString, @lastName, @firstName, @middleNames, @IsExtendedSearch) px
				join
					dbo.Registrant																																								r on px.PersonSID			 = r.PersonSID
				join
					dbo.Registration																																							reg on r.RegistrantSID = reg.RegistrantSID
				where
					reg.RegistrationYear = @RegistrationYear
				order by
					reg.RegistrationSID;

			end;
		end;

		-- index the selected temp table to improve
		-- performance of joins back to @latestRegistration

		create clustered index uk_selected_entitySID on #selected (EntitySID)

		-- the result filter is the @latestRegistration table which will either
		-- be trimmed or added to depending on whether a query was used

		if @filterMode = 'delete'
		begin

			if @DebugLevel > 0
			begin

				exec sf.pDebugPrint
					@DebugString = N'filter delete mode'
				 ,@TimeCheck = @timeCheck output;

			end;

			delete
			lr
			from
				@latestRegistration lr
			left outer join
				#selected						s on lr.RegistrationSID = s.EntitySID
			where
				s.EntitySID is null
			option (recompile);

		end;
		else
		begin

			if @DebugLevel > 0
			begin

				exec sf.pDebugPrint
					@DebugString = N'filter insert mode'
				 ,@TimeCheck = @timeCheck output;

			end;

			insert
				@latestRegistration (RegistrationSID, RegistrantSID)
			select
				s.EntitySID
			 ,reg.RegistrantSID
			from
				#selected				 s
			join
				dbo.Registration reg on s.EntitySID = reg.RegistrationSID
			option (recompile);

		end;

		if @DebugLevel > 0
		begin

			exec sf.pDebugPrint
				@DebugString = N'filter applied'
			 ,@TimeCheck = @timeCheck output;

		end;

		-- all searches are based on results stored into
		-- the @latestRegistration memory table 

		select
			x.RegistrationSID
		 ,x.RegistrantSID
		 ,x.PersonSID
		 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, x.RegistrantNo, 'REGISTRATION') RegistrantLabel
		 ,x.RegistrationYear
		 ,x.PracticeRegisterLabel
		 ,x.PracticeRegisterSectionLabel
		 ,x.PracticeRegisterSectionIsDefault
		 ,p.LastName
		 ,p.FirstName
		 ,p.MiddleNames
		 ,pea.EmailAddress
		 ,x.RegistrantNo
		 ,x.IsRenewalAutoApprovalBlocked
		 ,x.HasOpenAudit
		 ,x.HasConditionsOnPractice
		 ,x.PracticeRegisterSectionSID
		 ,x.InvoiceSID
		 ,x.RegFormTypeCode
		 ,x.RegFormRecordSID
		 ,x.RegFormIsInProgress
		 ,x.RegFormIsFinal
		 ,x.RegFormIsDefault
		 ,x.RegFormStatusSID
		 ,x.RegFormStatusSCD
		 ,(case
				 when x.RegFormOwnerSCD = 'NONE' and x.RegFormRecordSID is null and @isRenewalOpen = @ON and x.IsRenewalEnabled = @ON then '(No Renewal)'
				 else x.RegFormStatusLabel
			 end
			)																																															RegFormStatusLabel
		 ,x.RegFormOwnerSID
		 ,(case
				 when x.RegFormOwnerSCD = 'NONE' and x.RegFormRecordSID is null and @isRenewalOpen = @ON and x.IsRenewalEnabled = @ON then 'REGISTRANT'
				 when x.RegFormOwnerSCD = 'ASSIGNEE' then 'REGISTRANT' -- should already be eliminated in #CurrentStatus functions
				 else x.RegFormOwnerSCD
			 end
			)																																															RegFormOwnerSCD
		 ,(case
				 when x.RegFormOwnerSCD = 'NONE' and x.RegFormRecordSID is null and @isRenewalOpen = @ON and x.IsRenewalEnabled = @ON then 'Member'
				 else x.RegFormOwnerLabel
			 end
			)																																															RegFormOwnerLabel
		 ,x.RegFormStatusTime
		 ,x.RegFormStatusUser
		 ,x.NextFollowUp
		 ,x.RegFormInvoiceSID
		 ,x.RegFormTotalDue
		 ,x.RegFormTotalPaid
		 ,case
				when x.RegFormTypeCode is null then cast(0 as bit)
				when x.RegFormIsFinal = 1 then cast(0 as bit)
				when x.RegFormTypeCode = 'RENEWAL' and x.IsRenewalAutoApprovalBlocked = @ON then @ON
				when x.RegFormIsReviewRequired = 1 then cast(1 as bit)
				else x.HasOpenAudit
			end																																														IsRegFormBlocked
		 ,pr.PracticeRegisterLabel																																			ToPracticeRegisterLabel
		 ,prs.PracticeRegisterSectionLabel																															ToPracticeRegisterSectionLabel
		 ,isnull(prs.IsDefault, cast(0 as bit))																													ToPracticeRegisterSectionIsDefault
		 ,cast(isnull(z.EntitySID, 0) as bit)																														IsPinned
		 ,@searchType																																										SearchType	-- search type for debugging - ignored by UI
		from
		(
			select
				reg.RegistrationSID
			 ,r.RegistrantSID
			 ,r.PersonSID
			 ,reg.RegistrationYear
			 ,pr.PracticeRegisterLabel
			 ,prs.PracticeRegisterSectionLabel
			 ,prs.IsDefault																												 PracticeRegisterSectionIsDefault
			 ,pr.IsRenewalEnabled
			 ,r.RegistrantNo
			 ,r.IsRenewalAutoApprovalBlocked
			 ,cast(isnull(aud.RegistrantSID, 0) as bit)														 HasOpenAudit
			 ,cast(isnull(cnd.RegistrantSID, 0) as bit)														 HasConditionsOnPractice
			 ,reg.PracticeRegisterSectionSID
			 ,fs.PracticeRegisterSectionSIDTo
			 ,reg.InvoiceSID
			 ,fs.RegFormTypeCode
			 ,fs.RegFormRecordSID
			 ,fs.RegFormIsInProgress
			 ,fs.RegFormIsFinal
			 ,cast(case when fs.RegFormStatusSCD = 'NEW' then 1 else 0 end as bit) RegFormIsDefault
			 ,fs.RegFormStatusSID
			 ,fs.RegFormStatusSCD
			 ,fs.RegFormStatusLabel
			 ,fs.RegFormOwnerSID
			 ,fs.RegFormOwnerSCD
			 ,fs.RegFormOwnerLabel
			 ,fs.RegFormStatusTime
			 ,fs.RegFormStatusUser
			 ,fs.RegFormIsReviewRequired
			 ,fs.NextFollowUp
			 ,fs.RegFormInvoiceSID
			 ,fs.RegFormTotalDue
			 ,fs.RegFormTotalPaid
			from
				dbo.fRegistration#FormStatus(@latestRegistration) fs
			join
				dbo.Registration																	reg on fs.RegistrationSID							= reg.RegistrationSID
			join
				dbo.PracticeRegisterSection												prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			join
				dbo.PracticeRegister															pr on prs.PracticeRegisterSID					= pr.PracticeRegisterSID
			join
				dbo.Registrant																		r on reg.RegistrantSID								= r.RegistrantSID
			left outer join
			(
				select distinct
					x.RegistrantSID
				from
					dbo.fRegistrantAudit#CurrentStatus(-1, @RegistrationYear) x
				where
					x.IsInProgress = 1
			)																										aud on r.RegistrantSID								= aud.RegistrantSID
			left outer join
			(
				select distinct
					rpr.RegistrantSID
				from
					dbo.RegistrantPracticeRestriction rpr
				where
					sf.fIsActive(rpr.EffectiveTime, rpr.ExpiryTime) = @ON
			)																										cnd on r.RegistrantSID								= cnd.RegistrantSID
		)															x
		join
			sf.Person										p on x.PersonSID											= p.PersonSID
		left outer join
			sf.PersonEmailAddress				pea on x.PersonSID										= pea.PersonSID and pea.IsPrimary = @ON
		left outer join
			@pinned											z on x.RegistrationSID								= z.EntitySID
		left outer join
			dbo.PracticeRegisterSection prs on x.PracticeRegisterSectionSIDTo = prs.PracticeRegisterSectionSID
		left outer join
			dbo.PracticeRegister				pr on prs.PracticeRegisterSID					= pr.PracticeRegisterSID
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
