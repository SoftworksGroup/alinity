SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fReplaceAll]
(
	 @StringToSearch          nvarchar(max)                                 -- string to search for replacement values
	,@SearchReplaceList       nvarchar(max)                                 -- list of replacement pairs: SearchString,ReplacementString
	,@Delimiter		            nvarchar(15)                                  -- value of the delimiter - e.g. ','
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
ScalarF		: Replace All
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: returns the string passed in with replacements made based on SearchString, Replacement pairs provided
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| June  2012	|	Initial version

Comments	
--------
This function simplifies syntax where a sequence of replacements must be made. It takes a string to search and make replacements
in as the first parameter.  The second parameter is a list of SearchString,ReplacementString values that are processed sequentially
from left to right.

Consider for example, a requirement to replace common abbreviations in address strings.  Using the built-in replace function the 
syntax might appear as follows:

set @myAddress = replace(replace(replace(replace(@myAddress, 'Cr.', 'Crescent'),'Ave.','Avenue'),'Ave ','Avenue'),'St ', 'Street'))

Alternate syntax using this function is shown in the example below. The function can be applied to reduce the complexity of the 
syntax required and makes completing sequential replacements less error prone.

Note that to eliminate a value in the string, you must include 2 delimiters beside each other with no space in-between.  (See
also examples below.)

Example
-------

declare
	@searchReplacePairs   nvarchar(1000)    -- note that periods are eliminated by first pairing (replace '.' with '')

set @searchReplacePairs =  N'.,, nw , NW , ne , NE , sw , SW , se , SE , st , Street , ave , Avenue , Dr , Drive , rd , Road '
set @searchReplacePairs += N',po box,PO Box, stn , Station , ctr , Centre '

set @searchReplacePairs = N'.,, x , CD , st , Street ,CX,CW,CA,CB'        -- produces 2 zero-length strings in output table
	
select * from sf.fSplitString(@searchReplacePairs, N',')	

set @searchReplacePairs = N'.,,nw,NW '
select * from sf.fSplitString(@SearchReplacePairs, N',')

select sf.fReplaceAll('8923 95 Ave. SE', @searchReplacePairs, N',')
select sf.fReplaceAll('9513 89th st ',  @searchReplacePairs, N',')
------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @replacedString                  nvarchar(max)                       -- return value - string passed in with replacements made
		,@errorNo                         int = 0															-- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)											-- message text (for business rule errors)
		,@maxRow                          int																	-- loop limit
		,@i                               int																	-- loop index
		,@searchString                    nvarchar(1000)                      -- search value (part 1 of pair)
		,@replacement                     nvarchar(1000)                      -- value to replace if search is found (part 2 of pair)
		 
	declare
		@searchReplace            table
		(
		 ID				                int               not null
		,Item                     nvarchar(1000)    not null
		)  
		
	insert
		@searchReplace
	select
		 x.ID
		,x.Item
	from
		sf.fSplitString(@SearchReplaceList, @Delimiter) x
		
	set @maxRow         = @@rowcount
	set @i              = -1
	set @replacedString = @StringToSearch
	
	while @i < @maxRow
	begin
	
		set @i += 2
		select @searchString  = sr.Item from @searchReplace sr where sr.ID = @i
		select @replacement   = sr.Item from @searchReplace sr where sr.ID = @i + 1
		
		set @replacedString = replace(@replacedString, @searchString, @replacement)
		
	end

	return(@replacedString)

end
GO
