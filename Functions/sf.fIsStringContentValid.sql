SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsStringContentValid]
(			
	 @StringToCheck						nvarchar(max)																	-- string to check content for
	,@ValidCharacters					nvarchar(100)																	-- a list of valid characters (no delimiter)
)
returns bit
as
/*********************************************************************************************************************************
ScalarF	: Is String Content Valid
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns 1 if each character in the string passed in is found in the list of valid characters
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year | Change Summary
				: ------------|------------|----------------------------------------------------------------------------------------------
				: Tim Edlund  | Nov		2012 |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used in validations on strings.  It processes each character position in the string to check that it can be 
found in the list of valid characters passed in.  If any character is not found then 0 is returned.  Do not use a delimiter 
in the list of @ValidCharacters.  The @StringToCheck is not trimmed prior to the evaluation. The check is not case sensitive
unless the collation of the database is case sensitive.

If either parameter is passed in as NULL, then NULL is returned.

Example
-------
select sf.fIsStringContentValid('tim.e@softworks.ca', 'abcdefghijklmnopqrstuvwxyz')			-- alpha-numeric's
select sf.fIsStringContentValid('tim.e@softworks.ca', 'abcdefghijklmnopqrstuvwxyz@.')		-- characters allowed in User ID's
select sf.fIsStringContentValid('7801231234', '0123456789')															-- phone number (all digits)
select sf.fIsStringContentValid('78O1231234', '0123456789')															-- phone number (all digits)
select sf.fIsStringContentValid('(780)123-1234','0123456789()-')												-- phone number with formatting	
select sf.fIsStringContentValid('(780) 123-1234','0123456789()-')												-- phone number with formatting	

select sf.fIsStringContentValid('tim.e@softworks.ca', NULL)															-- null parameters
select sf.fIsStringContentValid(NULL, 'abcdefghijklmnopqrstuvwxyz@.')


------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare 
		 @isValid									bit 																				-- return value:  1 = valid, 0 = invalid
		,@i												int																					-- loop index
		,@charCount								int																					-- loop limit - characters to process
		,@ON											bit 					= cast(1 as bit)							-- constant to reduce repetitive casting
		,@OFF											bit 					= cast(0 as bit)							-- constant to reduce repetitive casting

	if @StringToCheck is not null and @ValidCharacters is not null
	begin

		set @isValid		= @ON
		set @charCount	= len(@StringToCheck)
		set @i					= 0

		while @i < @charCount and @isValid = @ON
		begin
			set @i += 1
			if charindex(substring(@StringToCheck,@i,1),@ValidCharacters) = 0 set @isValid = @OFF
		end
	end

	return(@isValid)

end
GO
