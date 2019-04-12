SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsValidPhone]
(
	@PhoneNumber									varchar(25)																	-- phone number to test for validity
)
returns bit
/*********************************************************************************************************************************
Function	: Is Valid Phone Number
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns 1 (true) when the string passed is in the form of a valid phone number
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Nov 2012		|	Initial version

Comments	
--------
The validations in this function expect "formatted" phone numbers.  The formatting must be consistent with that provided by 
sf.fFormatPhone(). The formatting function is not applied to the string ahead of the validation check because part of the 
check desired is to ensure that formatting has already been applied.  Most validation occurs through check constraints
so the value has already been stored to the database when this function is called.  If the format is invalid, an error should
be raised. If the string can be transformed to a valid format, the true error is a failure to apply the formatting function 
prior to saving the record in the <table>#Insert and/or <table>#Update procedure (between the "pre" action tags).

Note that while the sf.fFormatPhone() function correctly formats numbers without area codes - including with extensions,
any phone number without an area code (that is not an international number) fails validation.  For example, "429-7462" fails
while "780-429-7462" passes.

If NULL is passed into the function, 1 (valid) is returned.

The valid formats are identified in the main IF block in the code below - see also sf.fFormatPhoneNumber().

If a valid format is detected, a second level of validation occurs to ensure all non-format characters are digits.

Example:
--------

-- valid phone numbers

select sf.fIsValidPhone('780-429-7462')							IsValid		-- return 1 if valid
select sf.fIsValidPhone('1-780-429-7462')						IsValid
select sf.fIsValidPhone('1-780-429-7462 Ext 21')		IsValid
select sf.fIsValidPhone('1-780-429-7462,123')				IsValid
select sf.fIsValidPhone('9,1-780-429-7462 Ext 21')	IsValid
select sf.fIsValidPhone('780-429-7462')							IsValid
select sf.fIsValidPhone('011 44 660 429-7462')			IsValid
select sf.fIsValidPhone('011 44 429-7462')					IsValid
select sf.fIsValidPhone('9,011 66 27 429-7462')			IsValid
select sf.fIsValidPhone(null)												IsValid

-- invalid 

select sf.fIsValidPhone('780 429-7462')							IsValid		-- return 0 if invalid
select sf.fIsValidPhone('1-780-4297462')						IsValid
select sf.fIsValidPhone('8,1-780-429-7462')					IsValid
select sf.fIsValidPhone('1-780-429-7462 Ext. 21')		IsValid		-- period after Ext.
select sf.fIsValidPhone('1-780-429-7462x123')				IsValid
select sf.fIsValidPhone('429-7462')									IsValid		-- FAILS - missing area code
select sf.fIsValidPhone('8,1-780-429-7462 Ext 21')	IsValid		-- invalid outside line code
select sf.fIsValidPhone('0-780-429-7462')						IsValid
select sf.fIsValidPhone('44 780-429-7462')					IsValid		-- missing 011
select sf.fIsValidPhone('9,44 780-429-7462')				IsValid		-- missing 011


------------------------------------------------------------------------------------------------------------------------------- */
	
begin

	declare
		 @isValid						bit																								-- return valid
		,@maxLen						int																								-- loop limiter - string length
		,@i									int																								-- loop index
		,@ON								bit = cast(1 as bit)															-- constants for bit comparisons	
		,@OFF								bit = cast(0 as bit)

	if @PhoneNumber is null
	begin
		set @isValid = @ON
	end
	else
	begin
		set @isValid = @OFF

		if @PhoneNumber like '9,1-___-___-____'																-- when a long distance prefix exists, area code is required
		or @PhoneNumber like '9,1-___-___-____ Ext %' 
		or @PhoneNumber like '9,1-___-___-____,%' 
		or @PhoneNumber like '9,011 __ %___-____'															-- area code also required when country code "+##" is used	
		or @PhoneNumber like '9,011 __ %___-____ Ext %' 
		or @PhoneNumber like '9,+__ ___-___-____,%' 
		or @PhoneNumber like '1-___-___-____' 
		or @PhoneNumber like '1-___-___-____ Ext %' 
		or @PhoneNumber like '1-___-___-____,%' 
		or @PhoneNumber like '011 __ %___-____' 
		or @PhoneNumber like '011 __ %___-____ Ext %' 
		or @PhoneNumber like '011 __ ___-___-____,%' 
		or @PhoneNumber like '1-___-___-____' 
		or @PhoneNumber like '1-___-___-____ Ext %' 
		or @PhoneNumber like '1-___-___-____,%' 
		or @PhoneNumber like '9,___-___-____'																	-- 9 can prefix any format to get an outside line
		or @PhoneNumber like '9,___-___-____ Ext %' 
		or @PhoneNumber like '9,___-___-____,%' 
		or @PhoneNumber like '___-___-____' 
		or @PhoneNumber like '___-___-____ Ext %' 
		or @PhoneNumber like '___-___-____,%' 
		begin
			set @isValid = @ON
		end

		if @isValid = @ON
		begin

			-- remove the non numeric's expected, then check for digits

			set @PhoneNumber	= replace(replace(replace(replace(@PhoneNumber, ' ', ''), '-', ''), ',', ''), 'Ext', '')
			set @i						= 0
			set @maxLen				= len(@PhoneNumber)

			while (@i < @maxLen) and @isValid = @ON
			begin
				set @i += 1
				if substring(@PhoneNumber, @i, 1) not between '0' and '9' 
				begin
					set @isValid = @OFF	
				end
			end
		end
	end

	return(@isValid)

end
GO
