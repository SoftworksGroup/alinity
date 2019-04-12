SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsLower]
	(
	@String         nvarchar(max)																						-- string to check position 1 for lower case value
	)
returns  bit
as
/*********************************************************************************************************************************
Function: Is lower(case)
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns 1/true if the first character in the string passed is lower case
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| March   2012		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used in string manipulation. The first position in the string is compared to the lower case value and if it
is the same, then true/1 is returned.  If the value is not lowercase, then false/0 is returned.  If NULL is passed in, then 
NULL is returned.  

Example:
--------

select sf.fIsLower('Tim') --> 0
select sf.fIsLower('tim') --> 1
select sf.fIsLower('x')   --> 1
select sf.fIsLower('X')   --> 0

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare	
		@isLower				bit                                                   -- return value    
	
	if @String is not null and unicode(substring(@String, 1, 1)) = unicode(lower(substring(@String, 1, 1))) 
  begin
    set @isLower = 1
  end
  else if @String is null
  begin
    set @isLower = null
  end
  else
  begin
    set @isLower = 0
  end

	return( @isLower )

end
GO
