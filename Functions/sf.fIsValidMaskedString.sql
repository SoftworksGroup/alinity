SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsValidMaskedString]
(
	 @String				nvarchar(4000)																					-- string to check
	,@Mask					nvarchar(4000)																					-- edit mask to check against
)
returns bit
as
/*********************************************************************************************************************************
Function	: Is Valid Masked String
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns 1 (true) when the string passed matches the edit mask provided
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Dec 2012		|	Initial version

Comments	
--------
Validates a string value passed in against a masking string.  The masking string supports the following symbols:

	! - alphabet character
	# - digit
	^ - alphabet character or digit
	? - any character
	* - supported only at the end of the string - indicates no further checking required

If the @Mask contains only an "*", then no checking is performed (same as passing @Mask as NULL).

The string length must be at least as long as the @Mask up to the position of the wildcard character (*).  

The @string is NOT trimmed so any formatting on the string must be applied before calls to this function.

If the @String contains more characters than the mask (even if trailing spaces) then the function will return 0 (invalid).

NULL handing:
1. If the @String passed in is null, then 1 (valid) is returned.  
2. If both the @mask and the @string are passed as NULL then 1 (valid) is returned.  
3. If the @String passed is not null but @Mask is null, then 0 (invalid) is returned.

Note - to provide a mask that all strings will be considered valid for - use '*'.

See also examples below.

Example:
--------

select
	 sf.fIsValidMaskedString( '123456789'						,'#########'				)	T1_Ok 
	,sf.fIsValidMaskedString( '12345678X'						,'#########'				) T2_Fail
	,sf.fIsValidMaskedString( '12345678X'						,'########?'				) T3_Ok
	,sf.fIsValidMaskedString( '429-7462' 						,'###-####'					)	T4_Ok
	,sf.fIsValidMaskedString( '429.7462' 						,'###-####'					)	T5_Fail
	,sf.fIsValidMaskedString( '(780)429-7462'				,'(###)###-####'		)	T6_Ok
	,sf.fIsValidMaskedString( '(780)429-7462  '			,'(###)###-####'		)	T7_Fail			-- spaces NOT trimmed
	,sf.fIsValidMaskedString( '(780)429A7462'				,'(###)###-####'		)	T8_Fail
	,sf.fIsValidMaskedString( '(780)429HelloWorld'	,'(###)###*'				)	T9_Ok				-- stop character used
	,sf.fIsValidMaskedString( '(780)42'							,'(###)###*'				)	T10_Fail		-- string is too short
	,sf.fIsValidMaskedString( '429-7462'						,'###-####x##'			)	T11_Fail
	,sf.fIsValidMaskedString( null									,'###-####x##'			)	T13_Ok
	,sf.fIsValidMaskedString( null									,null								)	T14_Ok
	,sf.fIsValidMaskedString( 'Hello'								,null								)	T15_Fail
	,sf.fIsValidMaskedString( 'Hello'								,'*'								)	T16_Ok

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @isValid						bit																								-- return valid
		,@i									int																								-- loop index
		,@maskLen						int				= 0																			-- length of mask up to Stop character - if used
		,@stringLen					int				= 0																			-- loop limiter
		,@nextChar					nchar(1)																					-- next string character to process
		,@nextMask					nchar(1)																					-- next mask character to process
		,@ON								bit = cast(1 as bit)															-- constants for bit comparisons	
		,@OFF								bit = cast(0 as bit)

	declare																																	-- CONSTANTS for bit comparisons:
		 @ALPHA							nchar(1) = N'!'																		-- alpha character mask
		,@NUM								nchar(1) = N'#'																		-- digit character mask
		,@ALPHANUM					nchar(1) = N'^'																		-- alpha-numeric
		,@ANY								nchar(1) = N'?'																		-- any character
		,@STOP							nchar(1) = N'*'																		-- indicates no more checking required in remainder or string

	-- set initial pass/fail status based on NULL
	-- handling rules

	if @String is null and @Mask is null or @Mask = N'*'
	begin
		set @isValid = @ON
	end
	else if @String is null 
	begin
		set @isValid = @ON
	end
	else if @Mask is null
	begin
		set @isValid = @OFF
	end
	else
	begin																																		-- neither parameter is NULL
		set @isValid = @ON

		set @stringLen = cast(datalength(@String)/2 as int)
		set @maskLen =																												-- look for stop character in mask
			case 
				when charindex(@STOP, @Mask)	= 0 then cast(datalength(@Mask)/2 as int)
				else charindex(@STOP, @Mask) - 1																	-- found * so set required for @string 1 less 
			end

		if	@stringLen < @maskLen set @isValid = @OFF													-- string must be at least as long as non-* mask

	end
																																					-- up to stop character position
	set @nextMask = '!'
	set @i = 0

	-- process each character in the @String while valid until
	-- the end of the string or the stop mask symbol is encountered

	while @i < @stringLen and @isValid = @ON and @nextMask <> @STOP
	begin

		set @i += 1

		if cast(datalength(@Mask)/2 as int) < @i set @isValid = @OFF					-- string is longer than mask - and no @STOP char

		set @nextChar = substring(@String, @i, 1) 
		set @nextMask	= substring(@Mask, @i, 1)

		if @nextMask <> @ANY and @nextMask <> @STOP and @isValid = @ON
		begin

			if @nextMask = @ALPHA 
			begin
				set @isValid = cast(charindex(@nextChar, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') as bit)
			end
			else if @nextMask = @NUM
			begin
				set @isValid = cast(charindex(@nextChar, '0123456789') as bit)
			end
			else if @nextMask = @ALPHANUM
			begin
				set @isValid = cast(charindex(@nextChar, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789') as bit)
			end
			else
			begin
				if @nextChar <> @nextMask set @isValid = @OFF
			end

		end

	end

	return(@isValid)

end
GO
