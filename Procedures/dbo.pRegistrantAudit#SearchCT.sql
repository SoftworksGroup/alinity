SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantAudit#SearchCT
	@SearchString				 nvarchar(150) = null -- registrant name, # or email to search for (NOT combined with filters)
 ,@AuditTypeSID				 int = null						-- filter: returns only audits of this type - combined 
 ,@RegistrationYear		 int = null						-- filter: returns only audits in this registration year - combined
 ,@IsFollowUpDue			 bit = null						-- filter: returns only applications where follow-up date has been reached
 ,@FormStatusSID			 int = null						-- filter: returns only audits in this status - combined
 ,@RecommendationLabel nvarchar(20) = null	-- filter: returns only audits with this recommendation - combined
 ,@PersonSID					 int = null						-- filter: returns only audits assigned to this reviewer - combined
 ,@ExcludeWithdrawn		 bit = null						-- filter: excludes forms that have been withdrawn 
 ,@QuerySID						 int = null						-- SID of sf.Query row providing SQL syntax to execute - not combined
 ,@QueryParameters		 xml = null						-- list of query parameters associated with the query SID
 ,@IsPinnedSearch			 bit = 0							-- quick search: only returns pinned records - not combined
 ,@SIDList						 xml = null						-- quick search: list of pinned records to return (xml contains SID's)
 ,@RecordSID					 int = null						-- quick search: returns records based on system ID
 ,@RecordXID					 varchar(150) = null	-- quick search: returns records based on an external ID
 ,@LegacyKey					 nvarchar(50) = null	-- quick search: returns records based on a legacy key
 ,@IsFilterExcluded		 bit = 0							-- when 1, then filter values are excluded even when populated
 ,@IsRowLimitEnforced	 bit = 1							-- when 0, the limit of maximum rows to return is not enforced (see below)
as
/*********************************************************************************************************************************
Procedure : Registrant Audit Search
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Searches the registrant audit entity for the search string and/or other search criteria provided
History   : Author(s)						| Month Year  | Change Summary
					: --------------------+-------------+-----------------------------------------------------------------------------------
					: Tim Edlund					| May 2017		| Initial version
					: Cory Ng							| Jun 2017		| Added recommendation filter
					: Tim Edlund					| Oct 2017		| Updated for conformance with updated standard (renewals and applications).
					: Cory Ng							| Jan 2018		| Added filter to exclude withdrawn forms
					: Tim Edlund					| Aug 2018		| Implemented support for other name and past email searches (sf.fPerson#SearchNames)
					: Russell Poirier			| Mar 2019		|	Added where clause to filter on registration year

Comments
--------
This procedure supports dashboard displays and general searches of the "Registrant-Audit" entity from the UI. The procedure is
only expected to be called by Administrators.  All records are accessible.

Various search options are supported but the primary method is to SELECT for a search string entered by the end user. The string 
typically contains a registrant name, registrant number or email address. The other primary method is to search for work items by 
using the filters provided - for example to find all audits requiring administrator review.

The procedure detects if the user accessing the search is an Administrator by testing for existence of the "ADMIN.AUDIT" grant.
If that grant is not detected, then the procedure assumes the current user is a "Reviewer".  Reviewers only have access to 
records to which they have been assigned.  The search results then, are filtered for this criteria at the end of the procedure - 
and also for the Default Search (see below).

Complex Type CT
---------------
This search procedure does not return the default entity but rather a complex type. A corresponding view also exists against
which the search is performed.  The complex type is required to improve performance.

Default search
--------------
If no critieria is provided the search returns a set of rows limited by the MaxRows value (default is 200) ordered by last name.

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
See sf.pQuery#Search for additional details.  Queries are executed independently of the Filter criteria (not combined) but the
removal of records not assigned to Reviewers is applied within the procedure when a non-admin user is detected.

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

exec dbo.pRegistrantAudit#SearchCT																				-- default search
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "RegistrantAdmin" Description="Runs a registrant# search for an administrator">
		<SQLScript>
			<![CDATA[
declare
	 @userName						nvarchar(75)
	,@searchString				nvarchar(150)

select top 1
	@userName	= au.UserName
from
	sf.ApplicationUser au
where
	sf.fIsGrantedToUserSID('SYSADMIN', au.ApplicationUserSID) = 1						-- login as an SA 
and
	au.IsActive = 1
order by
	newid()

exec sf.pApplicationUser#Authorize
	@UserName   = @userName
 ,@IPAddress = '10.0.0.1'

select top 1
	@searchString = ltrim(x.RegistrantNo)
from
	dbo.vRegistrantAudit#Search x
order by 
	newid()

exec dbo.pRegistrantAudit#SearchCT																				-- search for registrant#
	@SearchString = @searchString
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "RegistrantName" Description="Runs a partial last name search for an administrator">
		<SQLScript>
			<![CDATA[
declare
	 @userName						nvarchar(75)
	,@searchString				nvarchar(150)

select top 1
	@userName	= au.UserName
from
	sf.ApplicationUser au
where
	sf.fIsGrantedToUserSID('SYSADMIN', au.ApplicationUserSID) = 1						-- login as an SA 
and
	au.IsActive = 1
order by
	newid()

exec sf.pApplicationUser#Authorize
	@UserName   = @userName
 ,@IPAddress = '10.0.0.1'

select top 1
	@searchString = left(x.LastName, 5)
from
	dbo.vRegistrantAudit#Search x
order by 
	newid()

exec dbo.pRegistrantAudit#SearchCT																				-- search for partial last name
	@SearchString = @searchString
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
	<Test Name = "EmailAddress" Description="Runs an email address search for an administrator">
		<SQLScript>
			<![CDATA[
declare
	 @userName						nvarchar(75)
	,@searchString				nvarchar(150)

select top 1
	@userName	= au.UserName
from
	sf.ApplicationUser au
where
	sf.fIsGrantedToUserSID('SYSADMIN', au.ApplicationUserSID) = 1						-- login as an SA 
and
	au.IsActive = 1
order by
	newid()

exec sf.pApplicationUser#Authorize
	@UserName   = @userName
 ,@IPAddress = '10.0.0.1'

select top 1
	@searchString = x.EmailAddress
from
	dbo.vRegistrantAudit#Search x
order by 
	newid()

exec dbo.pRegistrantAudit#SearchCT																				-- search for email address
	@SearchString = @searchString
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="2"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.pRegistrantAudit#SearchCT'
	,	@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON						bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@OFF					bit						= cast(0 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@searchType		varchar(25)											-- type of search; returned in result for debugging
	 ,@maxRows			int															-- maximum rows allowed on search
	 ,@queryMaxRows int															-- maximum rows allowed on preliminary query
	 ,@registrantNo varchar(50)											-- ID of registrant (base of registration numbers)	
	 ,@lastName			nvarchar(35)										-- for name searches, buffer for each name part:
	 ,@firstName		nvarchar(30)
	 ,@middleNames	nvarchar(30);

	declare @selected table -- stores primary key values of records found
	(
		ID				int identity(1, 1) not null -- identity to track add order - preserves custom sorts
	 ,EntitySID int not null								-- record ID joined to main entity to return results
	);

	declare @pinned table -- stores primary key value of pinned records
	(ID int identity(1, 1) not null, EntitySID int not null);

	begin try

-- SQL Prompt formatting off
		if @IsFollowUpDue is null	set @IsFollowUpDue = @OFF
-- SQL Prompt formatting on

		-- if filters are to be excluded, set them to null 
		-- (passed by the front end in order not to lose values from UI)

		if @IsFilterExcluded = @ON
		begin
			set @AuditTypeSID = null;
			set @RegistrationYear = null;
			set @FormStatusSID = null;
			set @PersonSID = null;
			set @RecommendationLabel = null;
			set @IsFollowUpDue = @OFF;
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
		 ,@PinnedPropertyName = 'PinnedRegistrantAuditList';

-- SQL Prompt formatting off
		if @IsRowLimitEnforced = @OFF		set @maxRows = 999999999; -- if row limit is not being enforced, set max rows to a billion
		set @queryMaxRows = @maxRows;
-- SQL Prompt formatting on

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

			insert @selected ( EntitySID) select top (@maxRows) p.EntitySID from @pinned p ;

		end;
		else if coalesce(@RecordSID, @RecordXID, @LegacyKey) is not null -- specific system ID was passed in search text
		begin

-- SQL Prompt formatting off
			if @RecordSID is not null set @searchType = 'SID';
			if @RecordXID is not null set @searchType = 'XID';
			if @LegacyKey is not null set @searchType = 'LegacyKey';
-- SQL Prompt formatting on

			insert
				@selected (EntitySID)
			select
				ra.RegistrantAuditSID
			from
				dbo.RegistrantAudit ra
			where
				ra.RegistrantAuditSID										= @RecordSID -- no filters apply on this search
				or isnull(ra.RegistrantAuditXID, '!~@') = @RecordXID or isnull(ra.LegacyKey, '!~@') = @LegacyKey;

			if @@rowcount = 0 -- failure to find the record is unexpected
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The "%1" record was not found. Record ID = %2. The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'Registrant Audit'
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
				ra.RegistrantAuditSID
			from
				dbo.Registrant			r
			join
				dbo.RegistrantAudit ra on r.RegistrantSID = ra.RegistrantSID
			where
				r.RegistrantNo = @registrantNo; -- match the ID value entered

			if @@rowcount = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'IDNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 "%2" was not found. If filters were active, try disabling them.'
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
				ra.RegistrantAuditSID
			from
				sf.fPerson#SearchNames(@SearchString, @lastName, @firstName, @middleNames, @ON) px
			join
				dbo.Registrant																														 r on px.PersonSID			 = r.PersonSID
			join
				dbo.RegistrantAudit																												 ra on r.RegistrantSID = ra.RegistrantSID;

			if @@rowcount = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'TextNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'No results were found for the search text entered.';

				raiserror(@errorText, 16, 1);

			end;

		end;
		else -- default search is open audits limited by max rows
		begin

			set @searchType = 'Default';

			insert
				@selected (EntitySID)
			select top (@maxRows) -- limit to standard max rows but apply filtering for reviewers in this select!
				ras.RegistrantAuditSID
			from
				dbo.vRegistrantAudit#Search ras
			where
				ras.IsFinal									= @OFF
				and ras.AuditTypeSID				= isnull(@AuditTypeSID, ras.AuditTypeSID)
				and ras.FormStatusSID				= isnull(@FormStatusSID, ras.FormStatusSID)
				and ras.RegistrationYear		= isnull(@RegistrationYear, ras.RegistrationYear)
				and (@IsFollowUpDue					= @OFF or ras.IsFollowUpDue = @ON)
				and ras.RecommendationLabel = isnull(@RecommendationLabel, ras.RecommendationLabel)
			order by
				ras.RegistrantAuditSID desc;

			insert
				@selected (EntitySID)
			select top (@maxRows)
				ras.RegistrantAuditSID
			from
				dbo.vRegistrantAudit#Search ras
			where
				ras.IsFinal									= @ON
				and ras.AuditTypeSID				= isnull(@AuditTypeSID, ras.AuditTypeSID)
				and ras.FormStatusSID				= isnull(@FormStatusSID, ras.FormStatusSID)
				and ras.RegistrationYear		= isnull(@RegistrationYear, ras.RegistrationYear)
				and (@IsFollowUpDue					= @OFF or ras.IsFollowUpDue = @ON)
				and ras.RecommendationLabel = isnull(@RecommendationLabel, ras.RecommendationLabel)
			order by
				ras.RegistrantAuditSID desc;

		end;

		-- return only the columns required for display joining to the @selected
		-- table to apply found records, and to @pinned to apply pin attribute

		select top (@maxRows)
			ras.RegistrantAuditSID
		 ,ras.PersonSID
		 ,ras.RegistrantLabel
		 ,ras.RegistrantNo
		 ,ras.EmailAddress
		 ,ras.RegistrantAuditStatusLabel
		 ,ras.RecommendationLabel
		 ,ras.IsFollowUpDue
		 ,ras.FormOwnerSCD
		 ,ras.FormOwnerLabel
		 ,ras.AuditTypeLabel
		 ,ras.LastStatusChangeTime
		 ,ras.LastStatusChangeUser
		 ,cast(isnull(z.EntitySID, 0) as bit) IsPinned		-- if key found in pinned list then @ON else @OFF
		 ,@searchType													SearchType	-- search type for debugging - ignored by UI
		from
			dbo.vRegistrantAudit#Search ras
		join
			@selected										x on ras.RegistrantAuditSID		= x.EntitySID
		left outer join
			@pinned											z on ras.RegistrantAuditSID		= z.EntitySID
		left outer join
			dbo.RegistrantAuditReview		rar on ras.RegistrantAuditSID = rar.RegistrantAuditSID and rar.PersonSID = @PersonSID
		where
			isnull(rar.PersonSID, -1) = isnull(@PersonSID, isnull(rar.PersonSID, -1)) 
		and 
			(@ExcludeWithdrawn = @OFF or ras.RegistrantAuditStatusSCD <> 'WITHDRAWN')
		and
			ras.RegistrationYear		= isnull(@RegistrationYear, ras.RegistrationYear)
		order by
			ras.FileAsName;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
