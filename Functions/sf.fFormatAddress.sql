SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFormatAddress]
(
	@Name						nvarchar(150) -- addressee name										[any parameter may be passed as null]
 ,@StreetAddress1 nvarchar(75)	-- 1st line of street address 
 ,@StreetAddress2 nvarchar(75)	-- 2nd line of street address
 ,@StreetAddress3 nvarchar(75)	-- 3rd line of street address
 ,@CityName				nvarchar(30)	-- name of city 
 ,@StateProvince	nvarchar(30)	-- name or code of state or province
 ,@PostalCode			varchar(10)		-- postal or zip code
 ,@CountryName		nvarchar(50)	-- name of country
)
returns nvarchar(512)
as
/*********************************************************************************************************************************
Function: Format Address
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: takes the individual components of an address and formats them into a mailing address block
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ----------- + ----------- + --------------------------------------------------------------------------------------------
				: ChristianT	| Aug	2012		|	Initial version
				: Tim Edlund	| Nov	2012		| Updated to allow any parameter to be passed as null
				: Tim Edlund	| Jan 2018		| Reduced return length from max to 512 for consistency with #ForHTML version of function
				: Tim Edlund	| Jul 2018		| Suppressed display of NO ADDRESS and X0X 0X0 (postal code) placeholders set on conversion
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function accepts all the components of an address and formats them into an address block suitable for printing on a label
or envelope. Any parameter may be passed as null and the function will attempt to format the content that is provided according
to general formatting rules.  If all parameters are NULL then NULL is returned.

The @StateProvince parameter is declared as a nvarchar(30) so that full state/province names can be provided. 2-character state
and province codes are also supported and are preferred by Canadian and US postal services for mail delivery.  

Note that function does not accept multiple components for the address name.  Formatting of first, middle, last name and
salutation (if any) must be reflected in the @Name parameter value passed in.

The format for a full address is:

John Jones
Apt 10
123 Any Street
Edmonton, AB  T5R 4T1
Canada

other formats returned, depending on values passed include:

John Jones
Apt 10
123 Any Street
Edmonton

and ...

John Jones
Edmonton

... etc.

Example:
--------

print (sf.fFormatAddress 
		(
		'Jon Jones'
		,'Apt 10' 
		,'123 Any Street'
		,null
		,'Edmonton'
		,'AB'
		,'t5r4t1'
		,'Canada'
		))
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@formattedAddress nvarchar(512)												-- return value
	 ,@CRLF							varchar(10) = char(13) + char(10);	-- carriage return line feed (constant)

	set @Name = ltrim(rtrim(@Name)); -- remove leading and trailing spaces			
	set @StreetAddress1 = ltrim(rtrim(@StreetAddress1));
	set @StreetAddress2 = ltrim(rtrim(@StreetAddress2));
	set @StreetAddress3 = ltrim(rtrim(@StreetAddress3));
	set @CityName = ltrim(rtrim(@CityName));
	set @StateProvince = ltrim(rtrim(@StateProvince));
	set @PostalCode = ltrim(rtrim(@PostalCode));
	set @CountryName = ltrim(rtrim(@CountryName));

	set @PostalCode = sf.fFormatPostalCode(@PostalCode); -- formats for zip or postal code

	-- overrides for conversion placeholders in address:

	if @StreetAddress1 = '[NO ADDRESS]' or @StreetAddress1 = 'NO ADDRESS'
	begin
		set @StreetAddress1 = null;
		set @StreetAddress2 = null;
		set @StreetAddress3 = null;
	end;

	if replace(@PostalCode, ' ', '') = 'X0X0X0'
	begin
		set @PostalCode = null;
		set @StateProvince = null;
		set @CountryName = null;
	end;

	set @formattedAddress = N''; -- initialize string for concatenation operations

	-- name and address parameters are optional; a CRLF is added only where a value 
	-- is provided to avoid blank lines

-- SQL Prompt formatting off
	if @Name is not null 						set @formattedAddress = cast(@formattedAddress + @Name + @CRLF as nvarchar(512));
	if @StreetAddress1 is not null 	set @formattedAddress = cast(@formattedAddress + @StreetAddress1 + @CRLF as nvarchar(512));
	if @StreetAddress2 is not null 	set @formattedAddress = cast(@formattedAddress + @StreetAddress2 + @CRLF as nvarchar(512));
	if @StreetAddress3 is not null 	set @formattedAddress = cast(@formattedAddress + @StreetAddress3 + @CRLF as nvarchar(512));
-- SQL Prompt formatting on

	-- if both city and state/province are provided then concatenate them on the same 
	-- line with a comma separator; if only 1 is provided no commas is included

	if @CityName is not null and @StateProvince is not null
	begin
		set @formattedAddress = cast(@formattedAddress + @CityName + N', ' + @StateProvince as nvarchar(512));
	end;
	else if @CityName is not null or @StateProvince is not null
	begin
		set @formattedAddress = cast(@formattedAddress + isnull(@CityName, N'') + isnull(@StateProvince, N'') as nvarchar(512));
	end;

	-- the postal code is placed after the city and/or province if provided and
	-- then a CRLF terminates the line; the else is for an edge case of postal
	-- code without a city or province

	if @CityName is not null or @StateProvince is not null
	begin
		set @formattedAddress = cast(@formattedAddress + isnull(N'     ' + @PostalCode, N'') + @CRLF as nvarchar(512));
	end;
	else if @PostalCode is not null
	begin
		set @formattedAddress = cast(@formattedAddress + @PostalCode + @CRLF as nvarchar(512));
	end;

	if @CountryName is not null
	begin
		set @formattedAddress = cast(@formattedAddress + @CountryName as nvarchar(512));
	end;

	-- if no content was provided, reset the return value back to a null

	if len(@formattedAddress) = 0
	begin
		set @formattedAddress = null;
	end;

	return @formattedAddress;

end;
GO
