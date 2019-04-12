SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFormatPhone]
(
@PhoneNumber varchar(25) -- phone number string to format
)
returns varchar(25)
as
/*********************************************************************************************************************************
ScalarF		: Format Phone Number
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns phone number formatted to match Softworks standards
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2012		|	Initial version
				: Tim Edlund					| Mar 2019		| Revised logic to remove "9," and 1-" prefixes

Comments
--------
This function is used for formatting phone number for display in the UI and for storage in the database.  The function is designed
to tbe called in #Insert and #Update procedures to format phone numbers before they are inserted or updated into the database.
Once the phone number is saved it should be redisplayed to the UI to show the user the revised format. 

North American Numbers:
----------------------
The formatting standard supported by this function uses dashes between the area code and the main number.  Parentheses
around area codes are not supported in order to keep the number shorter.  Extensions are separated with " Ext " if there
is room in the resulting string, otherwise a "," is used if the length would exceed 25.  

International Numbers:
----------------------
International numbers are recognized if the international dialing exit code "011" starts the number.  After that the 
number is formatted with or without a city code, followed by 7 digits of the main number.  Note that extensions are NOT
supported for international number formatting.  The last 7 digits in the string are always considered the main number and
any remaining numbers after the 2 character country code are assumed to be part of the city code. Spaces are used instead
of dashes when formatting international numbers.

Except where the number starts with 011 (international number), the function identifies "components" of the phone number 
based on pattern matching; primarily on the length of the number and existence, or non-existence, of certain prefixes 
(e.g. "1" for North American long distance). If no pattern match is found, the number is returned unaltered.  

If NULL is passed in, NULL is returned.

The maximum Extension length supported is 6 digits.

The best way to understand the formatting standard is through examples.  See the Example block below for details.

Limitations
-----------
This function is designed to work with phone column data types of "varchar(25)" only!  You must set the phone columns to
this type and length to use this function.  

Example
-------
<TestHarness>
	<Test Name = "Random" IsDefault ="true" Description="Calls the function to format a random list of phone number inputs.">
		<SQLScript>
			<![CDATA[
select
	sf.fFormatPhone('1 780 429-7462')					Result1
 ,sf.fFormatPhone('17804297462')						Result2
 ,sf.fFormatPhone('178 HI 042 THERE 97462') Result3
 ,sf.fFormatPhone('(780)429-7462 xyz x99')	Result4
 ,sf.fFormatPhone('78012371807804999999')		Result5
 ,sf.fFormatPhone('12  31  234')						Result6
 ,sf.fFormatPhone('011444297462')						Result7 -- international - no city code
 ,sf.fFormatPhone('01144 12 42974')					Result8 -- international with 2 digit city code
 ,sf.fFormatPhone('9,011 4297462')					Result9 -- no country code (invalid)
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.fFormatPhone'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@phoneNumberOut varchar(25) -- return value
	 ,@phoneNumberIn	varchar(25) -- original phone number format
	 ,@allComponents	varchar(50) -- test value for full formatting of all components
	 ,@i							int					-- index counter
	 ,@maxLen					int					-- loop limit - length of string
	 ,@nextChar				char(1)			-- next character to process
	 ,@international	varchar(3)	-- '011' for international calling exit code
	 ,@countryCode		varchar(4)	-- International country code - must start +##
	 ,@areaCode				varchar(4)	-- remaining components of the phone number:
	 ,@mainNo					varchar(8)
	 ,@extension			varchar(6);

	if @PhoneNumber is not null
	begin

		set @phoneNumberIn = @PhoneNumber; -- store original in case format is not matched
		set @PhoneNumber = replace(replace(ltrim(rtrim(@PhoneNumber)), ',', ''), '-', '');

		-- look specifically for outside line indicator or the Canada/US "exit" code of 011
		-- for international dialog

		set @i = 0;

		if @PhoneNumber like '9%' and len(@PhoneNumber) not in (10, 7)
		begin
			set @i = 1;
		end;

		if substring(@PhoneNumber, @i + 1, 3) = '011'
		begin
			set @international = '011';
			set @i += 3;
		end;

		-- remove all remaining parts of the phone number except for digits

		set @phoneNumberOut = '';
		set @maxLen = len(@PhoneNumber);

		while @i < @maxLen
		begin
			set @i += 1;
			set @nextChar = substring(@PhoneNumber, @i, 1);
			if charindex(@nextChar, '0123456789') > 0
				set @phoneNumberOut = cast(@phoneNumberOut + @nextChar as varchar(25));
		end;

		-- apply a format based on total number of digits and whether or not
		-- a long distance "1" appears as the first digit

		if @international = '011' -- international dialing
		begin
			if len(@phoneNumberOut) >= 9 -- if <9 no country code - return it as passed in
			begin
				set @countryCode = left(@phoneNumberOut, 2); -- country code is always 2 digits
				set @phoneNumberOut = substring(@phoneNumberOut, 3, 23);
				set @mainNo = right(@phoneNumberOut, 7); -- main number is 7	
				set @phoneNumberOut = replace(@phoneNumberOut, @mainNo, '');
				set @mainNo = left(@mainNo, 3) + '-' + right(@mainNo, 4);
				if len(@phoneNumberOut) > 0
					set @areaCode = cast(@phoneNumberOut as varchar(4)); -- city code is variable length from 0 to 4
			end;
		end;
		else if len(@phoneNumberOut) > 11 and left(@phoneNumberOut, 1) = 1 -- appears to be "1" as long distance prefix with number + extension
		begin
			set @areaCode = substring(@phoneNumberOut, 2, 3);
			set @mainNo = substring(@phoneNumberOut, 5, 3) + '-' + substring(@phoneNumberOut, 8, 4);
			set @extension = substring(@phoneNumberOut, 12, 6);
		end;
		else if len(@phoneNumberOut) = 11 and left(@phoneNumberOut, 1) = '1' -- appears to be "1" as long distance prefix with number
		begin
			set @areaCode = substring(@phoneNumberOut, 2, 3);
			set @mainNo = substring(@phoneNumberOut, 5, 3) + '-' + substring(@phoneNumberOut, 8, 4);
		end;
		else if len(@phoneNumberOut) > 10 -- appears to be full number + extension (no long distance)
		begin
			set @areaCode = substring(@phoneNumberOut, 1, 3);
			set @mainNo = substring(@phoneNumberOut, 4, 3) + '-' + substring(@phoneNumberOut, 7, 4);
			set @extension = substring(@phoneNumberOut, 11, 6);
		end;
		else if len(@phoneNumberOut) = 10 -- appears to be area code + and number
		begin
			set @areaCode = substring(@phoneNumberOut, 1, 3);
			set @mainNo = substring(@phoneNumberOut, 4, 3) + '-' + substring(@phoneNumberOut, 7, 4);
		end;
		else if len(@phoneNumberOut) > 7 -- appears to be number (no area code) + extension
		begin
			set @mainNo = substring(@phoneNumberOut, 1, 3) + '-' + substring(@phoneNumberOut, 4, 4);
			set @extension = substring(@phoneNumberOut, 8, 6);
		end;
		else if len(@phoneNumberOut) = 7 -- appears to be number only
		begin
			set @mainNo = substring(@phoneNumberOut, 1, 3) + '-' + substring(@phoneNumberOut, 4, 4);
		end;
		else if len(@phoneNumberOut) <= 5 -- if < 6 assume extension (but don't assume for len = 6!)
		begin
			set @extension = cast(@phoneNumberOut as varchar(6));
		end;
		else
		begin
			set @phoneNumberOut = @phoneNumberIn; -- otherwise no specific format is recognized and the original 
		end; -- value passed in is returned without any changes

		-- combine all the components into an output value but before
		-- returning it, check the length to ensure it does not exceed max

		set @allComponents =
			isnull(@international + ' ', '') + isnull(@countryCode + ' ', '') + isnull(@areaCode + (case when @international is null then '-' else ' ' end), '')
			+ isnull(@mainNo, '') + isnull(' Ext ' + @extension, '');

		if len(@allComponents) > 25 -- max length is exceeded, try removing "Ext" text 
		begin

			set @allComponents =
				isnull(@international + ' ', '') + isnull(@countryCode + ' ', '') + isnull(@areaCode + (case when @international is null then '-' else ' ' end), '')
				+ isnull(@mainNo, '') + isnull(',' + @extension, '');

		end;

		if len(@allComponents) not between 7 and 25 -- if the length is exceeded, or components could not 
		begin -- be isolated, return the original value
			set @phoneNumberOut = @phoneNumberIn;
		end;
		else
		begin
			set @phoneNumberOut = cast(@allComponents as varchar(25));
		end;

	end;

	return (@phoneNumberOut);

end;
GO
