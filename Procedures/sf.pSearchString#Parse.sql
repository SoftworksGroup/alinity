SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pSearchString#Parse
	@SearchString nvarchar(150) = null output -- registrant name, # or email to search for
 ,@RecordSID		int						= null output -- for quick search - primary key value [TableName]SID column
 ,@RecordXID		varchar(150)	= null output -- for quick search - external ID value [TableName]XID column
 ,@LegacyKey		nvarchar(50)	= null output -- for quick search - conversion system ID value "LegacyKey" column
 ,@EntityName		nvarchar(128) = null output -- name of the entity the SID, XID or Legacy Key search applies to
 ,@LastName			nvarchar(35)	= null output -- @SearchString is split into first, middle and last name components
 ,@FirstName		nvarchar(30)	= null output -- first name parsed from @SearchString
 ,@MiddleNames	nvarchar(30)	= null output -- middle names parsed from @SearchString
 ,@IDNumber			varchar(50)		= null output -- identification number parsed from search string
as
/*********************************************************************************************************************************
Procedure: Search String - Parse
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure parses the search string into name and system identifier components with applied formatting
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version (rewrite based on sf.pSearchParam#Check)
				: Tim Edlund					| Feb 2019		| Changed detection logic for ID number to look for 3 or more digits anywhere in string

Comments	
--------
This is a support procedure for searches. It accepts a @SearchString parameter and parses it into components parts which are 
then returned as output parameters and used by the calling search routine. The search string parameter is formatted and 
processed in the following ways:

@RecordSID - if the search string starts with "SID:" and all values following are digits (or spaces), the procedure records
the @RecordSID as that value. The calling procedure can then search for the system ID using that parameter.

@RecordXID - if the search string starts with "XID:" the procedure strips the prefix and colon and stores the rest into the 
@RecordXID output parameter. This value is then searched against the <TableName>XID column of the table.

@LegacyKey - if the search string starts with "LKEY:" or "LegacyKey:" the procedure strips the prefix and colon and stores the 
rest into the @LegacyKey output parameter. This value is then searched against the LegacyKey column of the table.

@EntityName - if an entity other than the base entity should be searched for the SID, XID or LegacyKey value, then its name can 
be entered in the search string prior to the key column identifier and it will be parsed and stored as the @EntityName. For
example, entering "RegistrationgChangeSID:12345" will return "RegistrationChange" in the @EntityName output value.

ID number parsing.  If the string contains no spaces or commas and the last 3 characters are digits or the first 3 characters
are number (after wildcards are removed), the procedure returns the search string as an @IDNumber.

Name component parsing. If none of the previous parsing cases apply, then the routine calls a function to parse the search 
string into 1 or more of the 3 name parts returned as output. If there are no space or commas in the search string then only
the @LastName parameter will be populated. See sf.fSearchName#Split for details of the parsing algorithm.

General Formatting
------------------
The procedure ensures leading and trailing spaces are removed from the @SearchString. A wildcard "%" character is added to the
end of name components and to the end of the @SearchString itself so that "like" operator searches are supported. An "%" is not 
added to the front of the strings in order to ensure available indexes are applied. 

Known Limitations
-----------------
The property name cannot be validated by the procedure. No sort order is provided in the record set returned.

Example:
--------
<TestHarness>
  <Test Name = "NameParse" IsDefault ="true" Description="Executes the procedure to parse a first and last
	name from the string.">
    <SQLScript>
      <![CDATA[
declare
	@searchString nvarchar(150) = '  Tim Edlund           '
 ,@recordSID		int
 ,@recordXID		varchar(150)
 ,@legacyKey		nvarchar(50)
 ,@entityName		nvarchar(128)
 ,@lastName			nvarchar(35)
 ,@firstName		nvarchar(30)
 ,@middleNames	nvarchar(30);

exec sf.pSearchString#Parse
	@SearchString = @searchString output
 ,@RecordSID = @recordSID output
 ,@RecordXID = @recordXID output
 ,@LegacyKey = @legacyKey output
 ,@EntityName = @entityName output
 ,@LastName = @lastName output
 ,@FirstName = @firstName output
 ,@MiddleNames = @middleNames output;

select
	@searchString SearchString
 ,@recordSID		RecordSID
 ,@recordXID		RecordXID
 ,@legacyKey		LegacyKey
 ,@entityName		EntityName
 ,@lastName			LastName
 ,@firstName		FirstName
 ,@middleNames	MiddleNames;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
  <Test Name = "MultiPartLast" Description="Executes the procedure for a multi part last name with 
	leading spaces to the first initial">
    <SQLScript>
      <![CDATA[
declare
	@searchString nvarchar(150) = 'van der Hoff,      j'
 ,@recordSID		int
 ,@recordXID		varchar(150)
 ,@legacyKey		nvarchar(50)
 ,@entityName		nvarchar(128)
 ,@lastName			nvarchar(35)
 ,@firstName		nvarchar(30)
 ,@middleNames	nvarchar(30);

exec sf.pSearchString#Parse
	@SearchString = @searchString output
 ,@RecordSID = @recordSID output
 ,@RecordXID = @recordXID output
 ,@LegacyKey = @legacyKey output
 ,@EntityName = @entityName output
 ,@LastName = @lastName output
 ,@FirstName = @firstName output
 ,@MiddleNames = @middleNames output;

select
	@searchString SearchString
 ,@recordSID		RecordSID
 ,@recordXID		RecordXID
 ,@legacyKey		LegacyKey
 ,@entityName		EntityName
 ,@lastName			LastName
 ,@firstName		FirstName
 ,@middleNames	MiddleNames;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
  <Test Name = "EntitySID" Description="Executes the procedure to parse a SID value with Entity Name.">
    <SQLScript>
      <![CDATA[
declare
	@searchString nvarchar(150) = 'ProfileUpdate SID:12345'
 ,@recordSID		int
 ,@recordXID		varchar(150)
 ,@legacyKey		nvarchar(50)
 ,@entityName		nvarchar(128)
 ,@lastName			nvarchar(35)
 ,@firstName		nvarchar(30)
 ,@middleNames	nvarchar(30);

exec sf.pSearchString#Parse
	@SearchString = @searchString output
 ,@RecordSID = @recordSID output
 ,@RecordXID = @recordXID output
 ,@LegacyKey = @legacyKey output
 ,@EntityName = @entityName output
 ,@LastName = @lastName output
 ,@FirstName = @firstName output
 ,@MiddleNames = @middleNames output;

select
	@searchString SearchString
 ,@recordSID		RecordSID
 ,@recordXID		RecordXID
 ,@legacyKey		LegacyKey
 ,@entityName		EntityName
 ,@lastName			LastName
 ,@firstName		FirstName
 ,@middleNames	MiddleNames;
]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:01"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute 
	 @ObjectName			= 'sf.pSearchString#Parse'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)										-- message text (for business rule errors)
	 ,@isSystemKey bit					 = 0								-- indicates if a SID, XID or Legacy Key was found in search string
	 ,@ON					 bit					 = cast(1 as bit)		-- constant for bit comparisons = 1
	 ,@OFF				 bit					 = cast(0 as bit);	-- constant for bit comparison = 0

	set @SearchString = @SearchString; -- initialize in/out variables	
	set @RecordSID = @RecordSID;
	set @RecordXID = @RecordXID;
	set @LegacyKey = @LegacyKey;
	set @EntityName = @EntityName;
	set @LastName = @LastName;
	set @FirstName = @FirstName;
	set @MiddleNames = @MiddleNames;

	begin try

		-- remove spaces from search string and add trailing "%"
		-- if not already included; set to NULL if blank

		set @SearchString = sf.fSearchString#Format(@SearchString);
		if len(@SearchString) = 0 set @SearchString = null;

		-- search the string for system identifiers: SID, XID and legacy key
		-- first parsing out any prefix as an Entity Name

		if charindex(':', @SearchString) > 0 -- avoid these parses if no colon found in the string
		begin

			if right(@SearchString, 1) = '%'
			begin
				set @SearchString = left(@SearchString, len(@SearchString) - 1);
			end;

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

			set @EntityName = ltrim(rtrim(@EntityName));

			if len(@EntityName) = 0 -- if the parsed value is blank set it to NULL
			begin
				set @EntityName = null;
			end;

			-- next parse out the ID portion of the SID, XID or Legacy Key
			-- where included in the search string

			if @RecordSID is null and left(ltrim(@SearchString), 4) = N'SID:'
			begin

				set @SearchString = replace(replace(@SearchString, N'SID:', ''), ' ', '');

				if sf.fIsStringContentValid(@SearchString, N'0123456789') = @ON -- SID's must be all numeric
				begin
					set @RecordSID = cast(replace(replace(@SearchString, N'SID:', ''), ' ', '') as int);
					set @isSystemKey = @ON;
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
				set @isSystemKey = @ON;
			end;
			else if @LegacyKey is null and left(ltrim(@SearchString), 10) = N'LegacyKey:'
			begin
				set @LegacyKey = replace(replace(@SearchString, N'LegacyKey:', ''), ' ', '');
				set @isSystemKey = @ON;
			end;
			else if @LegacyKey is null and left(ltrim(@SearchString), 5) = N'LKEY:'
			begin
				set @LegacyKey = replace(replace(@SearchString, N'LKEY:', ''), ' ', '');
				set @isSystemKey = @ON;
			end;
		end;

		if @isSystemKey = @OFF
		begin

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

				select
					@FirstName	 = sn.FirstName -- split into name components
				 ,@LastName		 = sn.LastName	-- any not null component will have a trailing % operator
				 ,@MiddleNames = sn.MiddleNames
				from
					sf.fSearchName#Split(@SearchString) sn;

			end;

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
