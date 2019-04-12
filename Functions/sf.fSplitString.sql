SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fSplitString]
(
	 @String			nvarchar(max)                                             -- items to split into a table on the delimiter
	,@Delimiter		nvarchar(15)                                              -- value of the delimiter - e.g. ','
)
returns @Items	table 
(
	 ID				int							identity(1,1) 
	,Item			nvarchar(1000)	
)
as
/*********************************************************************************************************************************
Function: Split String
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: takes a delimited string and splits it into a table of string values 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| May   2012		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to split a string on the delimiter passed and return the split values as a table. The function uses
a CTE to perform the split.  Note that if 2 delimiters occur in sequence in a string, then a zero-length string is passed
back for that position in the table rather than a null.  See also examples:

Example:
--------

declare
	 @String			nvarchar(max)	= N'CA,CB,ABCDE,CD,CE,CX,CW,CA,CB,CC,CD,CE,CX,CW'
	,@Delimiter		nvarchar(15)		= N',' 
	
select * from sf.fSplitString(@String, @Delimiter)	

set @String	= N'CA,CB,,CD,,CX,CW,CA,CB,CC,CD,CE,CX,CW'                    -- produces 2 zero-length strings in output table
	
select top (1)                                                              -- parses out words based on single space
	@String = x.Paragraph 
from 
	SampleData.dbo.Paragraphs x
order by 
	newid()

set @Delimiter = N' ' 
	
select * from sf.fSplitString(@String, @Delimiter)	

------------------------------------------------------------------------------------------------------------------------------- */

begin

	with rep(Item, Delimiter) as
	(
		select
			rtrim(@String)			Item                                            -- remove space on right - otherwise causes last value strip
		, @Delimiter	        Delimiter																				-- return whole string with delimiter on base select
		union all
		select 
			 left(Item, charindex(Delimiter, Item, 1) - 1) Item									-- recursion: left most item remaining in string
			,Delimiter
		from 
			rep
		where 
			charindex(Delimiter, Item, 1) > 0
		union all
		select 
			 right(item, len(item) - charindex(Delimiter, item, 1)) Item				-- recursion: right most part of string after item
			,Delimiter
		from 
			rep
		where 
			charindex(Delimiter, item, 1) > 0
	)
	insert @Items (Item)																										-- insert in return value table
	select																										
		Item
	from 
		rep
	where 
		charindex(Delimiter, Item, 1) = 0																			-- return all items (without delimiter)
	option (MaxRecursion 0);
	
	return
end
GO
