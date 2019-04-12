SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pProfileUpdate#SearchCT
	@SearchString				nvarchar(150) = null	-- name, registrant# or email to search for 
 ,@RegistrationYear		smallint = null				-- registration year selected in the UI (should be provided unless executing default query)
 ,@IsExtendedSearch		bit = 1								-- when 1 then other names, other identifiers and past email addresses also searched
 ,@QuerySID						int = null						-- key of sf.Query record providing query to execute
 ,@QueryParameters		xml = null						-- query parameter values, if any, for execution in the query
 ,@SIDList						xml = null						-- list of primary keys to return (selected by front end for processing)
 ,@IsPinnedSearch			bit = 0								-- when 1 returns only records pinned by the logged in user
 ,@IsRowLimitEnforced bit = 1								-- when 0, the limit of maximum rows to return is not enforced (see below)
as
/*********************************************************************************************************************************
Procedure : Profile Update Search 
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Searches the Person and Profile Update entities for the search string and/or other criteria provided
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
				: Tim Edlund					| Aug 2018		| Initial version (rewrite from previous version allowing filters)
				: Tim Edlund					| Sep 2018		| Remove error raise when no records found for specific identifiers
				: Cory Ng							| Nov 2018		| Fixed Cartesian on join to person doc context
				: Cory Ng							| Dec 2018		| Updated IsAutoApprovalBlocked bit to check if form already validated
				: Tim Edlund					| Apr 2019		| Ensured all searches filter on the registration year provided.
          
Comments
--------
This procedure supports searches against the dbo.ProfileUpdate entity and related Person records. Tabs and totals are provided in
the user interface separating records based on who is Next-To-Act for open Profile Updates. 

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
the RegistrantNo column, and in other registrant identifiers if an extended search is being applied.

If the string is not an identifier, then it is assumed to be a name or email address and is searched in the current name 
(sf.Person) and current email address (sf.PersonEmailAddress primary) tables. When the @IsExtendedSearch parameter is passed as 
ON (1), then the string is searched against sf.PersonOtherName and previous email address (sf.PersonEmailAddress non-primary) as 
well.  The extended search will also find the criteria characters mid-word in name and email address values.

Queries 
-------
These are queries designed for the application page the search results are returned to.  Queries may include parameter values
provided to the syntax of the SQL expression, or may be non-parameterized where the query executes without user input. The 
@QuerySID value is used to lookup details of the query in the sf.Query table. Standard queries are included in all client 
configurations and custom, client-specific, queries may also be added to the table. 

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
into the @SearchString - e.g. "SID:1234567". The digits are stripped from the string and converted for searching agains the 
primary key. The conversion only takes place if all values following "SID:" are digits. By allowing system ID's to the be entered
into search string, administrators and configurators are able to trouble shoot error messages that return SID's using the 
user interface. The other 2 options are similar except that no validation occurs for a specific data type. The search against 
external ID's (XID) and LegacyKey are wildcard based so passing a partial value will result in found records. For Legacy-Key both 
the prefix "LegacyKey:" and "LKey:" are supported. 

Use of Memory Table
-------------------
The coding standard for search procedures is to retrieve key values of records matching the search into a temporary table,
and then join from that table to create the result set. This technique, while more complex than direct SELECT's, generally 
improves performance since complex columns returned to the UI for display can be excluded from the core search logic.

Example:
--------
<TestHarness>
	<Test Name = "DefaultAdmin" IsDefault ="true" Description="Runs default search with max row limit off">
		<SQLScript>
			<![CDATA[
declare 
	@registrationYear smallint = dbo.fRegistrationYear#Current() - 1;

exec dbo.pProfileUpdate#SearchCT
	@RegistrationYear = @registrationYear
 ,@IsRowLimitEnforced = 0;

if @@rowcount = 0 
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
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
	dbo.ProfileUpdate pu
join
	dbo.Registrant		r on pu.PersonSID = r.PersonSID
order by
	newid();

if @@rowcount = 0 or @searchString is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pProfileUpdate#SearchCT
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
	dbo.ProfileUpdate pu
join
	sf.Person					p on pu.PersonSID = p.PersonSID
order by
	newid();

if @@rowcount = 0 or @searchString is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pProfileUpdate#SearchCT
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
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pProfileUpdate#SearchCT'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
begin
	set nocount on;

	declare
		@errorNo							int = 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@ON										bit = cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@OFF									bit = cast(0 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@searchType						varchar(150)					-- type of search; returned in result for debugging
	 ,@maxRows							int										-- maximum rows allowed on search
	 ,@entityName						nvarchar(128)					-- name of entity parsed from search string where supported in SID/XID/LegacyKey
	 ,@recordSID						int										-- quick search: returns a profile update based on system ID
	 ,@recordXID						varchar(150)					-- quick search: returns a profile update based on an external ID
	 ,@legacyKey						nvarchar(50)					-- quick search: returns a profile update based on a legacy key
	 ,@lastName							nvarchar(35)					-- for name searches, buffer for each name part:
	 ,@firstName						nvarchar(30)
	 ,@middleNames					nvarchar(30)
	 ,@registrantNo					varchar(50)						-- ID number search against reg# and other identifiers
	 ,@applicationEntitySID int;									-- key of the primary entity (used in retrieval of generated form PDF)

	declare @selected table -- stores primary key values of records to return
	(EntitySID int not null primary key);

	declare @pinned table -- stores primary key values of pinned records
	(EntitySID int not null primary key);

	begin try

		-- a registration year is required for default queries
		-- so use the current year
		if @RegistrationYear is null
		begin
			set @RegistrationYear = dbo.fRegistrationYear#Current();
		end;

		set @SearchString = ltrim(rtrim(@SearchString));

		-- remove surrounding spaces

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
			@PropertyName = 'PinnedProfileUpdateList';

		-- retrieve max rows; configuration setting 
		-- a setting of "0" is unlimited
		set @maxRows = cast(isnull(sf.fConfigParam#Value('MaxRowsOnSearch'), '200') as int);

		if @maxRows = 0 or @IsRowLimitEnforced = @OFF
		begin
			set @maxRows = 999999999;
		end;

		-- process each search type
		if @IsPinnedSearch = @ON
		begin
			set @searchType = 'Pins';

			insert
				@selected (EntitySID)
			select
				p.EntitySID
			from
				@pinned						p
			join
				dbo.ProfileUpdate pu on p.EntitySID = pu.ProfileUpdateSID and pu.RegistrationYear = @RegistrationYear;
		end;
		else if @QuerySID is not null
		begin
			set @searchType = 'Query';

			insert
				@selected (EntitySID)
			exec dbo.pQuery#Execute
				@QuerySID = @QuerySID
			 ,@ApplicationPageURI = 'ProfileUpdateList'
			 ,@QueryParameters = @QueryParameters
			 ,@IsRowLimitEnforced = @IsRowLimitEnforced
			 ,@RegistrationYear = @RegistrationYear;
		end;
		else if @SIDList is not null
		begin
			set @searchType = 'Identifiers';

			insert
				@selected (EntitySID)
			select
				EntitySID.r.value('.', 'int') EntitySID -- return rows matching list of SID's passed in XML doc
			from
				@SIDList.nodes('//EntitySID') as EntitySID(r);	-- do not filter by registration year as caller could be non-UI
		end;
		else if @SearchString is null
		begin
			set @searchType = 'Default';

			insert
				@selected (EntitySID)
			exec dbo.pQuery#Execute
				@QuerySID = -1	-- executes the default search
			 ,@ApplicationPageURI = 'ProfileUpdateList'
			 ,@IsRowLimitEnforced = @IsRowLimitEnforced
			 ,@RegistrationYear = @RegistrationYear;
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
					@selected (EntitySID)
				select
					pu.ProfileUpdateSID
				from
					dbo.ProfileUpdate pu
				where
					pu.RegistrationYear																						= @RegistrationYear and
																																														(
																																															pu.ProfileUpdateSID = @recordSID or pu.ProfileUpdateXID = @recordXID or pu.LegacyKey = @legacyKey
																																														);
			end;
			else if @registrantNo is not null
			begin
				set @searchType = 'Reg#';

				if @IsExtendedSearch = @OFF
				begin
					insert
						@selected (EntitySID)
					select top (@maxRows)
						pu.ProfileUpdateSID
					from
						dbo.Registrant		r
					join
						dbo.ProfileUpdate pu on r.PersonSID = pu.PersonSID
					where
						r.RegistrantNo like @SearchString + '%' and pu.RegistrationYear = @RegistrationYear
					order by
						pu.ProfileUpdateSID;
				end;
				else
				begin
					insert
						@selected (EntitySID)
					select top (@maxRows)
						pu.ProfileUpdateSID
					from
						dbo.Registrant					 r
					join
						dbo.ProfileUpdate				 pu on r.PersonSID		 = pu.PersonSID
					left outer join
						dbo.RegistrantIdentifier ri on r.RegistrantSID = ri.RegistrantSID
					where
						pu.RegistrationYear = @RegistrationYear and
																										(
																											r.RegistrantNo like '%' + @SearchString + '%' or ri.IdentifierValue like '%' + @SearchString + '%'
																										)
					order by
						pu.ProfileUpdateSID;
				end;
			end;
			else
			begin
				set @searchType = 'Text';

				insert
					@selected (EntitySID)
				select top (@maxRows)
					pu.ProfileUpdateSID
				from
					sf.fPerson#SearchNames(@SearchString, @lastName, @firstName, @middleNames, @IsExtendedSearch) px
				join
					dbo.ProfileUpdate																																							pu on px.PersonSID = pu.PersonSID and pu.RegistrationYear = @RegistrationYear
				order by
					pu.ProfileUpdateSID;
			end;
		end;

		select -- retrieve entity SID to speed up SELECT for generated PDF
			@applicationEntitySID = ae.ApplicationEntitySID
		from
			sf.ApplicationEntity ae
		where
			ae.ApplicationEntitySCD = 'dbo.ProfileUpdate';

		-- all searches are based on results stored into
		-- the memory table 
		select
			pu.ProfileUpdateSID
		 ,pu.PersonSID
		 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'PROFILEUPDATE')												 RegistrantLabel
		 ,cs.FormStatusLabel
		 ,cs.NextFollowUp
		 ,cs.FormOwnerSCD
		 ,cs.FormOwnerLabel
		 ,pea.EmailAddress
		 ,cast(case when pu.IsAutoApprovalEnabled = cast(0 as bit) and pu.LastValidateTime is not null then 1 else 0 end as bit) IsAutoApprovalBlocked
		 ,re.ReasonName																																																					 AutoApprovalInfo -- show on UI as info button only when auto-approval is blocked
		 ,pu.ReasonSID
		 ,cast(isnull(aud.RegistrantSID, 0) as bit)																																							 HasOpenAudit
		 ,pdc.PersonDocSID
		 ,cs.LastStatusChangeUser
		 ,cs.LastStatusChangeTime
		 ,cast(isnull(z.EntitySID, 0) as bit)																																										 IsPinned					-- if key found in pinned list then @ON else @OFF
		 ,@searchType																																																						 SearchType				-- search type for debugging - ignored by UI
		from
			@selected																														x
		join
			dbo.ProfileUpdate																										pu on x.EntitySID = pu.ProfileUpdateSID
		join
			sf.Person																														p on pu.PersonSID = p.PersonSID
		cross apply dbo.fProfileUpdate#CurrentStatus(pu.ProfileUpdateSID, -1) cs
		left outer join
			dbo.Registrant				r on p.PersonSID								= r.PersonSID -- person updating profile may not be a registrant (committee members)
		left outer join
			sf.PersonEmailAddress pea on p.PersonSID							= pea.PersonSID and pea.IsActive = @ON and pea.IsPrimary = @ON
		left outer join
			dbo.Reason						re on pu.ReasonSID							= re.ReasonSID
		left outer join
			dbo.PersonDocContext	pdc on pdc.ApplicationEntitySID = @applicationEntitySID and pu.ProfileUpdateSID = pdc.EntitySID and pdc.IsPrimary = @ON
		left outer join
		(
			select distinct
				x.RegistrantSID
			from
				dbo.fRegistrantAudit#CurrentStatus(-1, @RegistrationYear) x
			where
				x.IsInProgress = 1
		)												aud on r.RegistrantSID					= aud.RegistrantSID
		left outer join
			@pinned								z on pu.ProfileUpdateSID				= z.EntitySID
		where
			cs.FormStatusSCD <> 'WITHDRAWN'
		order by
			p.LastName
		 ,p.FirstName
		 ,p.MiddleNames
		option (recompile); -- required due to use of memory table
	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
