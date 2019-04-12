SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fMatchedLength]
	(
	  @String1					nvarchar(4000)
	 ,@String2					nvarchar(4000)
	)
returns int
as
/*********************************************************************************************************************************
Function: Matched Length
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the number of continuous characters that match between the 2 strings starting at the first position
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Jan	2014		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to determine the extent of match between 2 strings.  The comparison counts matching characters from the
first position and continues until either the last position in the shorter string, or until a character position is not matched.
The function is typically used in searching algorithms in combination with a LIKE operator to show the end user how strong a 
match was found with the criteria entered.

Example:
--------

--<Test>

select 
	'Hello World'																	String1
	,'Hello'																			String2
	,sf.fMatchedLength('Hello World', 'Hello')		MatchedLength

select
	'Hello'																				String1
	,'Hello World'																String2
	,sf.fMatchedLength('Hello', 'Hello World')		MatchedLength

--</Test>
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare	
		 @matchedLength						int									= 0											-- return value - matching characters
		,@i								        int                 = 0                     -- character position index
		,@maxLen									int																					-- length of longer of the 2 strings	

	if len(@String2) > len(@String1 )																				-- store length of longer string
	begin
		set @maxLen = len(@String2)
	end
	else
	begin
		set @maxLen = len(@String1)
	end

	while @i < @maxLen
	begin
		set @i += 1

		if ascii(substring(@String1, @i, 1)) = ascii(substring(@String2, @i, 1))												-- test if next character is the same in both strings
		begin
			set @matchedLength += 1																																				-- increment matched length
		end
		else
		begin
			set @i = @maxLen																																							-- when not matched, terminate loop
		end

	end

	return(@matchedLength)

end
GO
