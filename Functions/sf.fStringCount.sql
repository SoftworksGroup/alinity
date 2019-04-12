SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fStringCount]
( 
	 @StringToSearch      nvarchar(max)                   -- string to search for the criteria in
	,@SearchCriteria      nvarchar(4000)                  -- the criteria string to search for
)
returns int
as
/*********************************************************************************************************************************
Function: String Count
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the count of @SearchCriteria in the string passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| November 2011		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This is a utility function used to count the number of times one string pattern occurs within another string.  The algorithm 
replaces the string pattern found with a zero-length string and then compares the length of the old and modified string
passed in to determine the count.

Example:
--------

select sf.fStringCount( 'Hello world hello', 'world')
select sf.fStringCount( 'Hello world hello', 'hello')

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@stringCount          int
		
	set @stringCount = (len(@StringToSearch) - len(replace(@StringToSearch, @SearchCriteria, ''))) / len(@SearchCriteria)
	return(@stringCount)

end
GO
