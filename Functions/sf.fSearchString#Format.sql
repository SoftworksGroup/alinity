SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fSearchString#Format]
(
	@SearchString                           nvarchar(150)                   -- the search string to format
)
returns nvarchar(150)
as
/*********************************************************************************************************************************
ScalarF		: Search String Format
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns string with wild-cards replaced and ready for searching with LIKE predicate - adds trailing "%"
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| June 2012		|	Initial version

Comments	
--------
This is a helper function used by search routines to carryout basic formatting on the string to be searched.  The logic is
encapsulated in a function for consistency.  The procedure trims leading and trailing spaces and replaces file system wildcards
"?" and "*" with the SQL wildcards "_" and "%".  The resulting string is ready for searching with a LIKE predicate.

Example
-------

select sf.fSearchString#Format( '  hello world')
select sf.fSearchString#Format( '  hello world%')
select sf.fSearchString#Format( 'hello% world  ')
select sf.fSearchString#Format( '%h%world  ')

------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @string              nvarchar(150)                                   -- return value - formatted search string

	set @string  = ltrim(rtrim(@SearchString))                              -- remove leading and trailing spaces
	set @string = replace(@string,'?', '_')                                 -- replace ? and * with SQL wildcards
	set @string = replace(@string,'*', '%')

	if right(@string, 1) <> N'%' 
	begin
		set @string = cast( @string + N'%' as nvarchar(150))                  -- add % to end of string if not already there
	end

	return(@string)

end
GO
