SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrant#DirectorySearch
	@SearchString					nvarchar(150) = null	-- registrant name, registration# or email to search for (NOT combined with filters)
 ,@SearchLastName				nvarchar(35) = null		-- value of last name entered by user where UI provides explicit last name field
 ,@SearchFirstName			nvarchar(30) = null		-- value of first name entered by user where UI provides explicit last name field
 ,@CardContext					varchar(25) = null		-- context in which the search is being invoked
 ,@PracticeRegisterSID	int = null						-- filter only return registrants current on this register
 ,@CitySID							int = null						-- filter returns only registrant in this city
 ,@EmployerSearchString nvarchar(150) = null	-- filter only registrants that are employed by an organization matching this text is returned
 ,@OrgSID								int = null						-- filters registrants based on whether or not they currently employed by this org
 ,@RecordSID						int = null						-- quick search: returns RENEWAL (not registration) based on system ID
 ,@RecordXID						varchar(150) = null		-- quick search: returns RENEWAL (not registration) based on an external ID
 ,@LegacyKey						nvarchar(50) = null		-- quick search: returns RENEWAL (not registration) based on a legacy key
as
/*********************************************************************************************************************************
Procedure : Registrant - Directory Search
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Searches vRegistrant#DirectoryEntry for the search string and/or other criteria provided
History   : Author(s)						| Month Year | Change Summary
					: --------------------+------------+------------------------------------------------------------------------------------
					: Kris Dawson					| Feb 2018	 | Initial version
          :	Cory Ng							|	Apr 2018	 | Added @PracticeRegisterSID as a filter
					: Taylor N						| Apr 2018	 | Removed two raiserror calls on the text search in order to not alarm the public
					: Cory Ng							| Jul 2018	 | Support for employer directory
          : Cory Ng   					| Dec 2017   | Initial version
					: Tim Edlund					| Aug 2018	 | Implemented support for other name and past email searches (sf.fPerson#SearchNames)
					: Tim Edlund					| Aug 2018	 | Implemented configuration parameters for max rows and inactive practice years
					: Tim Edlund					| Jan 2019	 | Updated logic to disable first name only searches through last name prompt field

Comments
--------
This procedure supports the public, private (member) and employer directories on the client portal. This procedure returns all
columns from either the product DirectoryEntry view or a customized version of the view created in the EXT schema. . Aside from the
mandatory columns outlined below, the columns returned do not need to match the product view since ADO is used in this call instead
of EF.

The procedure supports 2 styles of user interface for searching:

1) A single (Google style) search box where the search criteria is entered into @SearchString.  A subroutine parses out the values
in the string and assigns them to variables for last name, first name, middle name and registration number.

2) Separate search fields in the UI for last name and first name and optionally registration number.  When this style is used the
values entered by the user must be passed in @SearchLastName and @SearchFirstName.  If searching by registration number is supported
that value must be passed in the @SearchString parameter.  When either name-specific parameter is passed the general search
string is ignored.

Return type
---------------
This search procedure CANNOT be imported through EF since the return values of the procedure are customizable by providing an ext
version of the view used. This is to support configuration of the portal features.

Default search
--------------
If no criteria is provided the search returns no rows (fishing prevention).

Row Limit (MaxRows)
-------------------
The number of records returned on any search is limited by a configuration parameter setting "MaxRowsOnSearch" which if not set,
defaults to 200. The maximum is implemented to avoid timeout errors on rendering complex result layouts - particularly on slower
mobile-phone based connections.  The limit can not be turned off the registry feature (fishing prevention).

Sort order
----------
This procedure orders all results by registrant label but other sort orders can be set in the UI.

Custom view requirements
------------------------
The ext view must have at least RowGUID(uniqueidentifier, from person), PersonSID(int), IsOnPublicRegistry(bit)
and RegistrantLabel(nvarchar)

Use of Memory Table
-------------------
The coding standard for search procedures is to retrieve key values of records matching the search into a temporary table,
and then join from that table to create the result set.  This technique, while more complex than direct SELECT's, generally
improves performance since complex columns returned to the UI for display only can be excluded from retrieval logic.

Example:
--------
<TestHarness>
  <Test Name = "FullName" IsDefault ="true" Description="Finds a Person by last name.">
    <SQLScript>
      <![CDATA[

declare
	@randomPerson nvarchar(150)

select top 1
	@randomPerson = substring(c.LastName, 1, 1)
from
	sf.Person c
join
	dbo.Registrant r on c.PersonSID = r.PersonSID
order by
	newid()
				
exec dbo.pRegistrant#DirectorySearch																					
	@SearchString = @randomPerson

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "Registrant no" IsDefault ="false" Description="Finds by registrant #.">
    <SQLScript>
      <![CDATA[

declare
	@registrantNo varchar(50)

select top 1
	@registrantNo = r.RegistrantNo
from
	dbo.Registrant r
order by
	newid()
				
exec dbo.pRegistrant#DirectorySearch																					
	@SearchString = @registrantNo

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:03" ResultSet="1" />
    </Assertions>
  </Test>
	<Test Name = "One letter" IsDefault ="false" Description="Finds by the first letter of a last name.">
    <SQLScript>
      <![CDATA[
				
exec dbo.pRegistrant#DirectorySearch																					
	@SearchString = 'a'

			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:05" ResultSet="1" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.pRegistrant#DirectorySearch'
	,	@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo						int						= 0																		-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)																			-- message text (for business rule errors)
	 ,@ON									bit						= cast(1 as bit)											-- used on bit comparisons to avoid multiple casts
	 ,@OFF								bit						= cast(0 as bit)											-- used on bit comparisons to avoid multiple casts
	 ,@searchType					varchar(25)																					-- type of search; returned in result for debugging
	 ,@registrantNo				varchar(50)																					-- ID of registrant (base of license numbers)	
	 ,@isSearchInitiated	bit						= cast(0 as bit)											-- indicates if at least one search criteria is applied
	 ,@maxRows						int																									-- maximum records to return in a search (configuration parameter)
	 ,@previousYear				int						= dbo.fRegistrationYear#Current() - 1 -- previous registration year
	 ,@yearsInactiveLimit int																									-- used to avoid displaying members inactive > X year (configuration parameter)
	 ,@today							datetime			= sf.fToday()													-- current date in user timezone
	 ,@applicationUserSID int																									-- key of currently logged in user
	 ,@lastName						nvarchar(35)																				-- for name searches, buffer for each name part:
	 ,@firstName					nvarchar(30)
	 ,@middleNames				nvarchar(30);

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

	declare @pinned table -- NOT used, but required to prevent pSearchParam#Check from returning a data table
	(ID int identity(1, 1) not null, EntitySID int not null);

	begin try

		-- call a subroutine to validate and format search parameters

		insert
			@pinned (EntitySID)
		exec sf.pSearchParam#Check -- check parameters and format for searching
			@SearchString = @SearchString output
		 ,@RecordSID = @RecordSID output
		 ,@IDNumber = @registrantNo output
		 ,@LastName = @lastName output
		 ,@FirstName = @firstName output
		 ,@MiddleNames = @middleNames output
		 ,@IDCharacters = '0123456789'
		 ,@ConvertDatesToST = @ON
		 ,@PinnedPropertyName = 'PinnedDirectoryList';

		-- get configuration values

		set @maxRows = cast(isnull(sf.fConfigParam#Value('PublicDirectoryRowLimit'), '50') as int); -- maximum records to return
		set @yearsInactiveLimit = cast(isnull(sf.fConfigParam#Value('YearsInactiveLimit'), '3') as int); -- maximum years to display inactive members

		set @applicationUserSID = sf.fApplicationUserSessionUserSID();

		-- format search parameters and check for validity; open wild card
		-- and single character searches are disabled for public directories

		if @SearchLastName is not null
		begin
			set @SearchLastName = ltrim(rtrim(@SearchLastName));
			if @SearchLastName = '%' set @SearchLastName = null; -- don't allow wild-card only
			if len(@SearchLastName) < 2 set @SearchLastName = null; -- don't allow single character searches
		end;

		if @SearchFirstName is not null
		begin
			set @SearchFirstName = ltrim(rtrim(@SearchFirstName));
			if @SearchFirstName = '%' set @SearchFirstName = null;
			if (len(@SearchFirstName) < 2 and @SearchLastName is null)
				set @SearchFirstName = null;
		end;

		if @SearchString is not null
		begin
			set @SearchString = ltrim(rtrim(@SearchString));
			if @SearchString = '%' set @SearchString = null;
			if len(@SearchString) < 2 set @SearchString = null;
		end;

		-- if a last name or first name were provided explicitly as search
		-- values; use them to overwrite any name values parsed from the general
		-- search string

		if @SearchLastName is not null or @SearchFirstName is not null
		begin
			set @lastName = replace(@SearchLastName, '%', '') + N'%'; -- remove any embedded wild cards and add one at the end only
			set @firstName = replace(@SearchFirstName, '%', '') + N'%';
			set @middleNames = null;
		end;

		-- execute the searches

		if coalesce(@RecordSID, @RecordXID, @LegacyKey) is not null -- specific system ID was passed in search text - filters not applied
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

		end;
		else
		begin

			set @searchType = 'Text';

			if @SearchString is not null or @lastName is not null or @firstName is not null
			begin

				insert
					@selected (EntitySID)
				select
					p.PersonSID
				from
					sf.fPerson#SearchNames(@SearchString, @lastName, @firstName, @middleNames, @OFF) px
				join
					sf.Person																																				 p on px.PersonSID = p.PersonSID;

				set @isSearchInitiated = @ON;

			end;

			if @PracticeRegisterSID is not null
			begin

				set @searchType = isnull(@searchType + ',PracticeRegister', 'PracticeRegister');
				delete @subset;

				insert
					@subset (EntitySID)
				select
					r.PersonSID
				from
					dbo.Registrant																								 r
				cross apply dbo.fRegistrant#RegistrationCurrent(r.RegistrantSID) rc
				where
					rc.PracticeRegisterSID = @PracticeRegisterSID;

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

			if @CitySID is not null
			begin

				set @searchType = isnull(@searchType + ',City', 'City');
				delete @subset;

				insert
					@subset (EntitySID)
				select
					p.PersonSID
				from
					sf.Person																								 p
				cross apply dbo.fPersonMailingAddress#Current(p.PersonSID) pmac
				where
					pmac.CitySID = @CitySID;

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

			if @OrgSID is not null
			begin

				set @searchType = isnull(@searchType + ',OrgSID', 'OrgSID');
				delete @subset;

				insert
					@subset (EntitySID)
				select
					p.PersonSID
				from
					sf.Person																								 p
				cross apply dbo.fRegistrantEmployment#Current(p.PersonSID) rec
				where
					rec.OrgSID = @OrgSID;

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

			if @EmployerSearchString <> '' and @EmployerSearchString is not null
			begin

				set @searchType = isnull(@searchType + ',EmployerText', 'EmployerText');
				set @EmployerSearchString = sf.fSearchString#Format(@EmployerSearchString);

				delete @subset;

				insert
					@subset (EntitySID)
				select
					r.PersonSID
				from
					dbo.RegistrantEmployment re
				join
					dbo.Registrant					 r on re.RegistrantSID = r.RegistrantSID
				join
					dbo.Org									 o on re.OrgSID				 = o.OrgSID
				where
					re.RegistrationYear = @previousYear and
																							(
																								o.OrgLabel like @EmployerSearchString or o.OrgName like @EmployerSearchString
																							);

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

			if @CardContext = 'employer' and sf.fIsGranted('EXTERNAL.EMPLOYER') = @ON
			begin

				set @searchType = isnull(@searchType + ',EmployerContext', 'EmployerContext');
				delete @subset;

				-- only returns people that are currently employed by the logged in employer.
				-- If no search was initiated return all registrants employed by person

				if @isSearchInitiated = @ON
				begin

					insert
						@subset (EntitySID)
					select
						x.EntitySID
					from
						@selected																								 x
					cross apply dbo.fRegistrantEmployment#Current(x.EntitySID) rc
					join
						dbo.OrgContact		 oc on rc.OrgSID		= oc.OrgSID and oc.IsReviewAdmin = @ON
					join
						sf.ApplicationUser au on oc.PersonSID = au.PersonSID
					where
						au.ApplicationUserSID = @applicationUserSID;

				end;
				else
				begin

					insert
						@subset (EntitySID)
					select
						p.PersonSID
					from
						sf.Person																								 p
					cross apply dbo.fRegistrantEmployment#Current(p.PersonSID) rc
					join
						dbo.OrgContact		 oc on rc.OrgSID		= oc.OrgSID and oc.IsReviewAdmin = @ON
					join
						sf.ApplicationUser au on oc.PersonSID = au.PersonSID
					where
						au.ApplicationUserSID = @applicationUserSID;

				end;

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

		end;

		-- return all the columns from the EXT views using *, since the view
		-- may contain additional columns not included in the product view

		if @CardContext = 'public'
		begin

			if exists
			(
				select
					ObjectID
				from
					sf.vView
				where
					SchemaName = 'ext' and ViewName = 'vRegistrant#PublicDirectoryEntry'
			)
			begin

				select top (@maxRows)
					de.*
				 ,@searchType SearchType	-- search type for debugging - ignored by UI
				from
					ext.vRegistrant#PublicDirectoryEntry de
				join
					@selected														 x on de.PersonSID = x.EntitySID
				where
					de.IsOnPublicRegistry = @ON -- ensure they are marked as being on the public registry (controls both portals currently)
					and
					(
						de.IsActivePractice = @ON or datediff(year, de.EffectiveTime, @today) <= @yearsInactiveLimit -- if inactive practice, not past limit for display
					)
				order by
					de.LastName
				 ,de.FirstName;

			end;
			else
			begin

				select top (@maxRows)
					--!<ColumnList DataSource="dbo.vRegistrant#PublicDirectoryEntry" Alias="de">
					 de.PersonSID
					,de.RowGUID
					,de.IsOnPublicRegistry
					,de.GenderSID
					,de.GenderLabel
					,de.NamePrefixSID
					,de.NamePrefixLabel
					,de.FirstName
					,de.CommonName
					,de.MiddleNames
					,de.LastName
					,de.BirthDate
					,de.DeathDate
					,de.HomePhone
					,de.MobilePhone
					,de.CultureLabel
					,de.FullName
					,de.PrimaryEmailAddressSID
					,de.PrimaryEmailAddress
					,de.RegistrantSID
					,de.RegistrantNo
					,de.RegistrantLabel
					,de.FileAsName
					,de.PublicDirectoryComment
					,de.RegistrationNo
					,de.RegistrationSID
					,de.PracticeRegisterSID
					,de.PracticeRegisterName
					,de.PracticeRegisterLabel
					,de.PracticeRegisterSectionSID
					,de.PracticeRegisterSectionLabel
					,de.EffectiveTime
					,de.EffectiveTimeRaw
					,de.ExpiryTime
					,de.ExpiryTimeRaw
					,de.NextRegistrationNo
					,de.NextPracticeRegisterName
					,de.NextPracticeRegisterLabel
					,de.NextEffectiveTime
					,de.NextEffectiveTimeRaw
					,de.NextExpiryTime
					,de.NextExpiryTimeRaw
					,de.IsActivePractice
					,de.PracticingStatus
					,de.LicensingStatus
					,de.SectionIsDisplayedOnLicense
					,de.CurrentDateCTZ
					,de.CurrentDateRaw
					,de.CurrentDateTimeCTZ
					,de.CurrentDateTimeRaw
					,de.FirstRegistrationDateCTZ
					,de.FirstRegistrationDateRaw
					,de.Conditions
					,de.Specializations
					,de.ComplaintOutcomeSummaries
																	--!</ColumnList>
				 ,@searchType SearchType	-- search type for debugging - ignored by UI
				from
					dbo.vRegistrant#PublicDirectoryEntry de
				join
					@selected														 x on de.PersonSID = x.EntitySID
				where
					de.IsOnPublicRegistry = @ON -- enabled for public registrant
					and
					(
						de.IsActivePractice = @ON or datediff(year, de.EffectiveTime, @today) <= @yearsInactiveLimit
					)
				order by
					de.LastName
				 ,de.FirstName
				 ,de.MiddleNames;

			end;

		end;
		else if @CardContext = 'member'
		begin

			if exists
			(
				select
					ObjectID
				from
					sf.vView
				where
					SchemaName = 'ext' and ViewName = 'vRegistrant#MemberDirectoryEntry'
			)
			begin

				select top (@maxRows)
					de.*
				 ,@searchType SearchType	-- search type for debugging - ignored by UI
				from
					ext.vRegistrant#MemberDirectoryEntry de
				join
					@selected														 x on de.PersonSID = x.EntitySID
				where
					de.IsOnPublicRegistry = @ON -- ensure they are marked as being on the public registry (controls both portals currently)
					and
					(
						de.IsActivePractice = @ON or datediff(year, de.EffectiveTime, @today) <= @yearsInactiveLimit -- if inactive practice, not past limit for display
					)
				order by
					de.LastName
				 ,de.FirstName;

			end;
			else
			begin

				select top (@maxRows)
					--!<ColumnList DataSource="dbo.vRegistrant#MemberDirectoryEntry" Alias="de">
					 de.PersonSID
					,de.RowGUID
					,de.IsOnPublicRegistry
					,de.GenderSID
					,de.GenderLabel
					,de.NamePrefixSID
					,de.NamePrefixLabel
					,de.FirstName
					,de.CommonName
					,de.MiddleNames
					,de.LastName
					,de.BirthDate
					,de.DeathDate
					,de.HomePhone
					,de.MobilePhone
					,de.CultureLabel
					,de.FullName
					,de.PrimaryEmailAddressSID
					,de.PrimaryEmailAddress
					,de.RegistrantSID
					,de.RegistrantNo
					,de.RegistrantLabel
					,de.FileAsName
					,de.PublicDirectoryComment
					,de.RegistrationNo
					,de.RegistrationSID
					,de.PracticeRegisterSID
					,de.PracticeRegisterName
					,de.PracticeRegisterLabel
					,de.PracticeRegisterSectionSID
					,de.PracticeRegisterSectionLabel
					,de.EffectiveTime
					,de.EffectiveTimeRaw
					,de.ExpiryTime
					,de.ExpiryTimeRaw
					,de.NextRegistrationNo
					,de.NextPracticeRegisterName
					,de.NextPracticeRegisterLabel
					,de.NextEffectiveTime
					,de.NextEffectiveTimeRaw
					,de.NextExpiryTime
					,de.NextExpiryTimeRaw
					,de.IsActivePractice
					,de.PracticingStatus
					,de.LicensingStatus
					,de.SectionIsDisplayedOnLicense
					,de.CurrentDateCTZ
					,de.CurrentDateRaw
					,de.CurrentDateTimeCTZ
					,de.CurrentDateTimeRaw
					,de.FirstRegistrationDateCTZ
					,de.FirstRegistrationDateRaw
					,de.Conditions
					,de.Specializations
					,de.ComplaintOutcomeSummaries
																	--!</ColumnList>
				 ,@searchType SearchType	-- search type for debugging - ignored by UI
				from
					dbo.vRegistrant#MemberDirectoryEntry de
				join
					@selected														 x on de.PersonSID = x.EntitySID
				where					de.IsOnPublicRegistry = @ON -- enabled for public registrant
					and
					(
						de.IsActivePractice = @ON or datediff(year, de.EffectiveTime, @today) <= @yearsInactiveLimit
					)
				order by
					de.LastName
				 ,de.FirstName
				 ,de.MiddleNames;

			end;

		end;
		else if @CardContext = 'employer'
		begin

			if exists
			(
				select
					ObjectID
				from
					sf.vView
				where
					SchemaName = 'ext' and ViewName = 'vRegistrant#EmployerDirectoryEntry'
			)
			begin

				select
					de.*
				 ,@searchType SearchType	-- search type for debugging - ignored by UI
				from
					ext.vRegistrant#EmployerDirectoryEntry de
				join
					@selected															 x on de.PersonSID = x.EntitySID
				where
					de.IsOnPublicRegistry = @ON -- ensure they are marked as being on the public registry (controls both portals currently)
					and
					(
						de.IsActivePractice = @ON or datediff(year, de.EffectiveTime, @today) <= @yearsInactiveLimit -- if inactive practice, not past limit for display
					)
				order by
					de.LastName
				 ,de.FirstName;

			end;
			else
			begin

				select
					--!<ColumnList DataSource="dbo.vRegistrant#EmployerDirectoryEntry" Alias="de">
					 de.PersonSID
					,de.RowGUID
					,de.IsOnPublicRegistry
					,de.GenderSID
					,de.GenderLabel
					,de.NamePrefixSID
					,de.NamePrefixLabel
					,de.FirstName
					,de.CommonName
					,de.MiddleNames
					,de.LastName
					,de.BirthDate
					,de.DeathDate
					,de.HomePhone
					,de.MobilePhone
					,de.CultureLabel
					,de.FullName
					,de.PrimaryEmailAddressSID
					,de.PrimaryEmailAddress
					,de.RegistrantSID
					,de.RegistrantNo
					,de.RegistrantLabel
					,de.FileAsName
					,de.PublicDirectoryComment
					,de.RegistrationNo
					,de.RegistrationSID
					,de.PracticeRegisterSID
					,de.PracticeRegisterName
					,de.PracticeRegisterLabel
					,de.PracticeRegisterSectionSID
					,de.PracticeRegisterSectionLabel
					,de.EffectiveTime
					,de.EffectiveTimeRaw
					,de.ExpiryTime
					,de.ExpiryTimeRaw
					,de.NextRegistrationNo
					,de.NextPracticeRegisterName
					,de.NextPracticeRegisterLabel
					,de.NextEffectiveTime
					,de.NextEffectiveTimeRaw
					,de.NextExpiryTime
					,de.NextExpiryTimeRaw
					,de.IsActivePractice
					,de.PracticingStatus
					,de.LicensingStatus
					,de.SectionIsDisplayedOnLicense
					,de.CurrentDateCTZ
					,de.CurrentDateRaw
					,de.CurrentDateTimeCTZ
					,de.CurrentDateTimeRaw
					,de.FirstRegistrationDateCTZ
					,de.FirstRegistrationDateRaw
					,de.Conditions
					,de.Specializations
					,de.ComplaintOutcomeSummaries
																	--!</ColumnList>
				 ,@searchType SearchType	-- search type for debugging - ignored by UI
				from
					dbo.vRegistrant#EmployerDirectoryEntry de
				join
					@selected															 x on de.PersonSID = x.EntitySID
				where
					de.IsOnPublicRegistry = @ON -- enabled for public registrant
					and
					(
						de.IsActivePractice = @ON or datediff(year, de.EffectiveTime, @today) <= @yearsInactiveLimit
					)
				order by
					de.LastName
				 ,de.FirstName
				 ,de.MiddleNames;

			end;

		end;
	--else if @CardContext = 'advertise'
	--begin

	--	if exists
	--	(
	--		select
	--			ObjectID
	--		from
	--			sf.vView
	--		where
	--			SchemaName = 'ext' and ViewName = 'vRegistrant#AdvertiseDirectoryEntry'
	--	)
	--	begin

	--		select
	--			de.*
	--		 ,@searchType SearchType	-- search type for debugging - ignored by UI
	--		from
	--			ext.vRegistrant#AdvertiseDirectoryEntry de
	--		join
	--			@selected															 x on de.PersonSID = x.EntitySID
	--		where
	--			de.IsOnPublicRegistry = @ON -- ensure they are marked as being on the public registry (controls both portals currently)
	--			and
	--			(
	--				de.IsActivePractice = @ON or datediff(year, de.EffectiveTime, @today) <= @yearsInactiveLimit -- if inactive practice, not past limit for display
	--			)
	--		order by
	--			de.LastName
	--		 ,de.FirstName

	--	end;
	--	else
	--	begin

	--		set @errorNo = 0 -- TODO Feb 2019 Cory: implement fully once prototype is approved by CDA

	--	end;

	--end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
