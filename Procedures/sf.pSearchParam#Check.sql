SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pSearchParam#Check]
	@SearchString				nvarchar(150) = null output -- registrant name, # or email to search for
 ,@DateRangeStart			date					= null output -- earliest date for date range searches - output defaults to 19000101
 ,@DateRangeEnd				date					= null output -- latest date for date range searches - output defaults to 29991231
 ,@RecordSID					int						= null output -- for quick search - primary key value [TableName]SID column
 ,@RecordXID					varchar(150)	= null output -- for quick search - external ID value [TableName]XID column
 ,@LegacyKey					nvarchar(50)	= null output -- for quick search - conversion system ID value "LegacyKey" column
 ,@EntityName					nvarchar(128) = null output -- name of the entity the SID, XID or Legacy Key search applies to
 ,@MaxRows						int						= null output -- maximum rows to return in the search (configuration parameter)
 ,@IDNumber						varchar(50)		= null output -- @SearchString is parsed to this buffer if it matches valid ID content
 ,@LastName						nvarchar(35)	= null output -- @SearchString is split into first, middle and last name components
 ,@FirstName					nvarchar(30)	= null output -- first name parsed from @SearchString
 ,@MiddleNames				nvarchar(30)	= null output -- middle names parsed from @SearchString
 ,@ApplicationUserSID int						= null output -- returns key of the currently logged in user (used for filtering)
 ,@IDCharacters				varchar(50) = '0123456789'	-- valid characters for ID number (otherwise assumed to be last name)
 ,@ConvertDatesToST		bit = 1											-- when 1 date range parameters are converted to server timezone
 ,@PinnedPropertyName varchar(100) = null					-- name of application-user-profile-property containing pinned SID's 
as
/*********************************************************************************************************************************
Procedure : Search Parameter Check
Notice    : Copyright © 2017 Softworks Group Inc.
Summary   : Validates and formats parameters for standard search procedures and returns a data set of "pinned" records - if any
History   : Author(s)   | Month Year  | Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| May 2017		| Initial version
					: Tim Edlund	| Apr 2018		| Added support for @EntityName  
					: Tim Edlund	| Mar 2019		| Changed detection logic for ID number to look for 3 or more digits anywhere in string

Comments
--------
This procedure checks and standardizes the format of standard parameters used in search procedures.  If a @PinnedPropertyName is
passed in, then the procedure returns a record set of the primary key values of pinned record if any. If no @PinnedPropertyName 
is passed in, or there are no pinned records to retrieve, then an empty result set is returned.

Parsing the search string
-------------------------
The search string parameter is formatted and processed in the following ways:

@RecordSID - if the search string starts with "SID:" and all values following are digits (or spaces), the procedure records
the @RecordSID as that value.  The calling procedure can then search for the system ID using that parameter.

@RecordXID - if the search string starts with "XID:" the procedure strips the prefix and colon and stores the rest into the 
@RecordXID output parameter.  This value is then searched against the <TableName>XID column of the table.

@LegacyKey - if the search string starts with "LKEY:" or "LegacyKey:" the procedure strips the prefix and colon and stores the 
rest into the @LegacyKey output parameter.  This value is then searched against the LegacyKey column of the table.

@EntityName - if an entity other than the base entity should be search for the SID, XID or LegacyKey value, then its name can 
be entered in the search string prior to the key column identifier and it will be parsed and stored as the @EntityName. For
example, entering "RegistrationgChangeSID:12345" will return "RegistrationChange" in the @EntityName output value.

@IDNumber - if the string contains no spaces or commas and there are 3 or more digits in the search string then the
procedure returns it as an @IDNumber.

Name component parsing.  If neither of the previous parsing cases applies, then the routine calls a function to parse the search 
string into 1 or more of the 3 name parts returned as output.  If there are no spaces or commas in the search string then only
the @LastName parameter will be populated.  See sf.fSearchName#Split for details of the parsing algorithm.

General formatting
------------------
The procedure ensures leading and trailing spaces are removed from the @SearchString.  A wildcard character is added to the
end of the search string so that "like" operator searches are supported, however, an "%" is not added to the front of the
string in order to ensure available indexes are applied.

Date Ranges
-----------
Date range values provided are assumed to be entered by the end user and, if compared against server-based date columns, must
be converted to the server time zone first.  This procedure performs that conversion by default but if the conversion is not
required (e.g. the column values are stored in the user timezone), then the @ConvertDatestoST must be passed as 0 (OFF).  Note 
also that if the date range values are blank, the procedure returns them as 1990/01/01 to 2999/12/31. This avoids the need for
the search sproc to conduct queries using an OR operator to handle nulls while still not limiting the records returned.

Example:
--------
<TestHarness>
  <Test Name = "XID" IsDefault ="true" Description="Executes the procedure to parse a XID value.">
    <SQLScript>
      <![CDATA[
declare
	@searchString				nvarchar(150) = 'RegistrantRenewalXID:my-test'
 ,@dateRangeStart			date
 ,@dateRangeEnd				date
 ,@recordSID					int
 ,@recordXID					varchar(150)
 ,@legacyKey					nvarchar(50)
 ,@entityName					nvarchar(128)
 ,@maxRows						int
 ,@idNumber						varchar(50)
 ,@lastName						nvarchar(35)
 ,@firstName					nvarchar(30)
 ,@middleNames				nvarchar(30)
 ,@applicationUserSID int
 ,@idCharacters				varchar(50)
 ,@convertDatesToST		bit
 ,@pinnedPropertyName varchar(100);

exec sf.pSearchParam#Check
	@SearchString = @searchString output
 ,@DateRangeStart = @dateRangeStart output
 ,@DateRangeEnd = @dateRangeEnd output
 ,@RecordSID = @recordSID output
 ,@RecordXID = @recordXID output
 ,@LegacyKey = @legacyKey output
 ,@EntityName = @entityName output
 ,@MaxRows = @maxRows output
 ,@IDNumber = @idNumber output
 ,@LastName = @lastName output
 ,@FirstName = @firstName output
 ,@MiddleNames = @middleNames output
 ,@ApplicationUserSID = @applicationUserSID output
 ,@IDCharacters = @idCharacters
 ,@ConvertDatesToST = @convertDatesToST
 ,@PinnedPropertyName = @pinnedPropertyName;

select @searchString SearchString , @recordSID RecordSID, @recordXID RecordXID, @legacyKey LegacyKey, @entityName EntityName;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:01"/>
    </Assertions>
  </Test>
  <Test Name = "SID" IsDefault ="false" Description="Executes the procedure to parse a SID value.">
    <SQLScript>
      <![CDATA[
declare
	@searchString				nvarchar(150) = 'SID:2391060'
 ,@dateRangeStart			date
 ,@dateRangeEnd				date
 ,@recordSID					int
 ,@recordXID					varchar(150)
 ,@legacyKey					nvarchar(50)
 ,@entityName					nvarchar(128)
 ,@maxRows						int
 ,@idNumber						varchar(50)
 ,@lastName						nvarchar(35)
 ,@firstName					nvarchar(30)
 ,@middleNames				nvarchar(30)
 ,@applicationUserSID int
 ,@idCharacters				varchar(50)
 ,@convertDatesToST		bit
 ,@pinnedPropertyName varchar(100);

exec sf.pSearchParam#Check
	@SearchString = @searchString output
 ,@DateRangeStart = @dateRangeStart output
 ,@DateRangeEnd = @dateRangeEnd output
 ,@RecordSID = @recordSID output
 ,@RecordXID = @recordXID output
 ,@LegacyKey = @legacyKey output
 ,@EntityName = @entityName output
 ,@MaxRows = @maxRows output
 ,@IDNumber = @idNumber output
 ,@LastName = @lastName output
 ,@FirstName = @firstName output
 ,@MiddleNames = @middleNames output
 ,@ApplicationUserSID = @applicationUserSID output
 ,@IDCharacters = @idCharacters
 ,@ConvertDatesToST = @convertDatesToST
 ,@PinnedPropertyName = @pinnedPropertyName;

select @searchString SearchString , @recordSID RecordSID, @recordXID RecordXID, @legacyKey LegacyKey, @entityName EntityName;
]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:01"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute 
	 @ObjectName			= 'sf.pSearchParam#Check'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON					bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@pinnedList xml;														-- document of pinned record keys (SID's)

	set @SearchString = @SearchString; -- initialize in/out variables	
	set @DateRangeStart = @DateRangeStart;
	set @DateRangeEnd = @DateRangeEnd;
	set @RecordSID = @RecordSID;
	set @RecordXID = @RecordXID;
	set @LegacyKey = @LegacyKey;
	set @EntityName = @EntityName;
	set @MaxRows = @MaxRows;
	set @IDNumber = @IDNumber;
	set @LastName = @LastName;
	set @FirstName = @FirstName;
	set @MiddleNames = @MiddleNames;
	set @ApplicationUserSID = sf.fApplicationUserSessionUserSID();

	begin try

		set @SearchString = ltrim(rtrim(@SearchString)); -- remove leading and trailing spaces from search string
		if len(@SearchString) = 0 set @SearchString = null; -- when empty string is passed in, set it to null

		-- retrieve configuration setting for maximum records to return
		-- on a search - avoids rendering timeout on non-paged UI's

		if @MaxRows is null
		begin
			set @MaxRows = cast(isnull(sf.fConfigParam#Value('MaxRowsOnSearch'), '200') as int);
		end;

		if @MaxRows = 0 set @MaxRows = 999999999; -- setting of 0 = unlimited (not recommended!)

		-- if a system key identifier is prefixed, then parse the value out and
		-- return it as the @EntityName

		if @RecordSID is null and charindex('SID:', @SearchString) > 0
		begin
			set @EntityName = left(@SearchString, charindex('SID:', @SearchString) - 1);
			set @SearchString = substring(@SearchString, charindex('SID:', @SearchString), 150);
		end;
		else if @RecordXID is null and charindex('XID:', @SearchString) > 0
		begin
			set @EntityName = left(@SearchString, charindex('XID:', @SearchString) - 1);
			set @SearchString = substring(@SearchString, charindex('XID:', @SearchString), 150);
		end;
		else if @LegacyKey is null and charindex('LegacyKey:', @SearchString) > 0
		begin
			set @EntityName = left(@SearchString, charindex('LegacyKey:', @SearchString) - 1);
			set @SearchString = substring(@SearchString, charindex('LegacyKey:', @SearchString), 150);
		end;
		else if @LegacyKey is null and charindex('LKey:', @SearchString) > 0
		begin
			set @EntityName = left(@SearchString, charindex('LKey:', @SearchString) - 1);
			set @SearchString = substring(@SearchString, charindex('LKey:', @SearchString), 150);
		end;

		if len(ltrim(@entityName)) = 0 
		begin
			set @entityName = null
		end

		-- if system ID is provided in search string, parse it out and set parameter
		-- value (ensure it is all digits before attempting cast for SID option)

		if @RecordSID is null and left(ltrim(@SearchString), 4) = N'SID:'
		begin

			set @SearchString = replace(replace(@SearchString, N'SID:', ''), ' ', '');

			if sf.fIsStringContentValid(@SearchString, N'0123456789') = @ON
			begin
				set @RecordSID = cast(replace(replace(@SearchString, N'SID:', ''), ' ', '') as int);
			end;
			else
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'InvalidSIDFormat'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A system ID (SID:) was specified for the search but the value "%1" does not match the required format. Only digits are allowed.'
				 ,@Arg1 = @SearchString;

				raiserror(@errorText, 16, 1);

			end;
		end;
		else if @RecordXID is null and left(ltrim(@SearchString), 4) = N'XID:'
		begin
			set @RecordXID = replace(replace(@SearchString, N'XID:', ''), ' ', '');
		end;
		else if @LegacyKey is null and left(ltrim(@SearchString), 10) = N'LegacyKey:'
		begin
			set @LegacyKey = replace(replace(@SearchString, N'LegacyKey:', ''), ' ', '');
		end;
		else if @LegacyKey is null and left(ltrim(@SearchString), 5) = N'LKEY:'
		begin
			set @LegacyKey = replace(replace(@SearchString, N'LKEY:', ''), ' ', '');
		end;
		else -- only if SID was not specified are other parameters processed
		begin

			-- convert date range parameters to server timezone and/or set
			-- defaults to create a non-restrictive range when blank

			if @DateRangeStart is not null
			begin
				if @ConvertDatesToST = @ON
					set @DateRangeStart = cast(sf.fClientDateToDTOffset(@DateRangeStart) as date);
			end;
			else
			begin
				set @DateRangeStart = cast('19000101' as date);
			end;

			if @DateRangeEnd is not null
			begin
				if @ConvertDatesToST = @ON
					set @DateRangeEnd = cast(sf.fClientDateToDTOffset(@DateRangeEnd) as date);
			end;
			else
			begin
				set @DateRangeEnd = cast('29991231' as date);
			end;

			-- check if search string contains an ID number or
			-- otherwise, name values

			if charindex(N' ', @SearchString) = 0 -- no internal spaces
				 and len(@SearchString) <= 50 -- not longer than max length of identifiers
				 and charindex(',', @SearchString) = 0 -- no comma embedded
				 and sf.fDigitCount(@SearchString) >= 3 -- 3 or more digits found
			begin
				set @IDNumber = @SearchString;
			end;
			else
			begin

				set @SearchString = sf.fSearchString#Format(@SearchString); -- format search string and add trailing % if not there

				select
					@FirstName	 = sn.FirstName -- split into name components
				 ,@LastName		 = sn.LastName	-- any not null component will have a trailing % operator
				 ,@MiddleNames = sn.MiddleNames
				from
					sf.fSearchName#Split(@SearchString) sn;

			end;

		end;

		-- if a parameter name for pinned records was provided, return
		-- the associated record keys if any

		if @PinnedPropertyName is not null
		begin

			select
				@pinnedList = aupp.PropertyValue
			from
				sf.ApplicationUserProfileProperty aupp
			where
				aupp.ApplicationUserSID = @ApplicationUserSID and aupp.PropertyName = @PinnedPropertyName;

		end;

		select
			EntitySID.r.value('.', 'int') EntitySID -- return pinned rows if any, or empty record set					
		from
			@pinnedList.nodes('//EntitySID') as EntitySID(r);

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
