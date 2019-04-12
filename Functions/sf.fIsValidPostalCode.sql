SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsValidPostalCode]
(
	@PostalCode									varchar(10)																	-- postal code to test for validity
) returns bit
/*********************************************************************************************************************************
Function	: Is Valid Postal Code
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns 1 (true) when the string passed is in the form of a valid postal or zip code
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Nov 2012		|	Initial version

Comments	
--------
The validations in this function expect "formatted" postal codes.  The formatting must be consistent with that provided by 
sf.fFormatPostalCode. The formatting function is not applied to the string ahead of the validation check because part of the 
validation desired is to ensure that formatting has already been applied.  Most validation occurs through check constraints
so the value has already been stored to the database when this function is called. If the format is invalid, an error should
be raised. If the string can be transformed to a valid format, the true error is a failure to apply the formatting function 
prior to saving the record.

Only the following patterns are considered valid:

#####				- 5 digits - US zip		: must be all digits
#####-####	- 5 + 4 US zip				: must be all digits
A#A #A#			- Canadian postal code: must match pattern and be uppercase

Any other postal code format is considered invalid.

If NULL is passed in, the 1 (valid) is returned.

These functions check format only.  NO lookup is performed against a postal code/zip database.

Example:
--------

-- valid postal codes

select sf.fIsValidPostalCode('A1B 2C3')			IsValid		-- return 1 if valid
select sf.fIsValidPostalCode('D4E 5F6')			IsValid
select sf.fIsValidPostalCode('12345')				IsValid
select sf.fIsValidPostalCode('12345-1234')	IsValid

-- invalid 

select sf.fIsValidPostalCode('902109')			IsValid		-- too long
select sf.fIsValidPostalCode('90X10')				IsValid		-- not all digits
select sf.fIsValidPostalCode('123451234')		IsValid		-- missing dash for 5 + 4
select sf.fIsValidPostalCode('A11A1A1')			IsValid		-- missing internal space
select sf.fIsValidPostalCode('d4e 5F6')			IsValid		-- mixed case; must be upper
select sf.fIsValidPostalCode('DDE 5F6')			IsValid		-- wrong pattern - A#A #0#
select sf.fIsValidPostalCode('D5E 556')			IsValid		-- wrong pattern - A#A #0#
select sf.fIsValidPostalCode('5D5 D5D')			IsValid		-- wrong pattern - A#A #0#

------------------------------------------------------------------------------------------------------------------------------- */

begin

  declare
		 @isValid						bit																								-- return valid
		,@i									int																								-- loop index
		,@ON								bit = cast(1 as bit)															-- constants for bit comparisons	
		,@OFF								bit = cast(0 as bit)

	if @PostalCode is null
	begin
		set @isValid = @ON
	end
	else
	begin

		if @PostalCode like '_____'	or @PostalCode like '_____-____'						-- US zip
		begin

			set @isValid = @ON
			set @PostalCode = replace(@PostalCode, '-', '')												-- remove the 1 hyphen
			set @i = 0

			while (@i < len(@PostalCode)) and @isValid = @ON											-- check for all digits
			begin
				set @i += 1
				if substring(@PostalCode, @i, 1) not between '0' and '9' 
				begin
					set @isValid = @OFF																																					
				end
			end

		end
		else if @PostalCode like '___ ___'																			-- Canadian
		begin

			set @isValid = @ON
			set @PostalCode = replace(@PostalCode, ' ', '')												-- remove the 1 space
			set @i = 0

			while (@i < 6) and @isValid = @ON																			-- check pattern match																
			begin
				set @i += 1

				if (@i%2 = 1) 
					and charindex(substring(@PostalCode, @i, 1), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' collate Latin1_General_CS_AI) = 0 -- 1,3,5 must be alpha (case sensitive collation)
				or 
					(@i%2 = 0) and substring(@PostalCode, @i, 1) not between '0' and '9' 												-- 2,4,6 must be digits
				begin
					set @isValid = @OFF																																					
				end
			end

		end
		else
		begin
			set @isValid = @OFF
		end

	end

  return(@isValid)

end
GO
