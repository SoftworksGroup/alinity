SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fSplitDictionary]
(
	 @String					nvarchar(max)                                         -- item pair(s) to split into a table
	,@PairDelimiter		nvarchar(15) = '|'                                    -- value of the delimiter between item pairs - e.g. '|'
	,@ItemDelimiter		nvarchar(15) = ','																		-- value of the delimiter between key and value - e.g. ','
)
returns @Items	table 
(
	 ID							int							identity(1,1) 
	,ItemKey				nvarchar(1000)																					-- the key, or value on the left of a pair	
	,ItemValue			nvarchar(1000)																					-- the value, or value on the right of pair
)
as
/*********************************************************************************************************************************
Function: Split Dictionary String
Notice  : Copyright © 2016 Softworks Group Inc.
Summary	: takes a string and splits out pairs on the pair delimiter filling the table with the key/value
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Kris Dawson	| Nov   2016			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to split a string into a series of key-value rows in a table. Pairs are split out on the pair delimiter
and then within the resulting string the key and value is split using the item delimiter.

Example:
--------

-- default

select * from sf.fSplitDictionary('abc,def|ghi,jkl|mno,pqr', default, default)

-- null string

select * from sf.fSplitDictionary(null, default, default)

-- empty string

select * from sf.fSplitDictionary('', default, default)

-- one key, no value

select * from sf.fSplitDictionary('abc', default, default)

-- one pair only

select * from sf.fSplitDictionary('abc,def', default, default)

-- last pair has empty string value

select * from sf.fSplitDictionary('abc,def|ghi,jkl|mno,', default, default)

-- last pair has no value

select * from sf.fSplitDictionary('abc,def|ghi,jkl|mno', default, default)

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @ON															bit = cast(1 as bit)								-- constant for true bit
		,@OFF															bit = cast(0 as bit)								-- constant for false bit
		,@currentPair											nvarchar(2001) = null								-- hold the current pair (1000 for key and value + 1 for delimiter)
		,@isLastPair											bit = cast(0 as bit)								-- indicates if the last pair is being worked on
		,@pairIsValid											bit = cast(0 as bit)								-- indicates if the current pair is valid (item delimiter is present)
		,@pairDelimiterIndex							int = null													-- pair delimiter index of the current value for @String
		,@itemDelimiterIndex							int = null													-- item delimiter index for the current pair

	while (@String is not null and @String <> '')
	begin
		
		set @pairDelimiterIndex = charindex(@PairDelimiter, @String)

		if @pairDelimiterIndex = 0																						-- not found, so last pair in the string
		begin
			
			set @pairDelimiterIndex = len(@String)
			set @isLastPair = @ON

		end
		
		-- get the string for the pair being worked on and strip it from @String

		set @currentPair = substring(@String, 1, @pairDelimiterIndex - (case when @isLastPair = @ON then 0 else 1 end))
		set @String = substring(@String, @pairDelimiterIndex + 1, len(@String) - @pairDelimiterIndex)

		-- determine the validity of the pair and get the delimiter index

		set @itemDelimiterIndex = charindex(@ItemDelimiter, @currentPair)

		if @itemDelimiterIndex = 0																						-- not found so invalid (no value)
		begin

			set @itemDelimiterIndex = len(@currentPair)
			set @pairIsValid = @OFF
		
		end
		else
		begin
			set @pairIsValid = @ON
		end

		-- insert the key and value of the pair

		insert
			@Items
		(
			 ItemKey
			,ItemValue
		)
		values
		(
			 substring(@currentPair, 1, @itemDelimiterIndex - (case when @pairIsValid = @OFF then 0 else 1 end)) 
			,case
				when @pairIsValid = @ON then substring(@currentPair, @itemDelimiterIndex + 1, len(@currentPair) - @itemDelimiterIndex) 
				else null
			end
		)

	end

	return

end
GO
