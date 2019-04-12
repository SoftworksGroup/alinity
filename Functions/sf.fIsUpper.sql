SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsUpper]
	(
	@String         nvarchar(max)
	)
returns  bit
as
/*********************************************************************************************************************************
Function: Is Upper(case)
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns 1/true if the first character in the string passed is upper case
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| March   2012		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used in string manipulation. The first position in the string is compared to the upper case value and if it
is the same, then true/1 is returned.  If the value is not uppercase, then false/0 is returned.  If NULL is passed in, then 
NULL is returned.  

Example:
--------

select sf.fIsUpper('Tim') --> 1
select sf.fIsUpper('tim') --> 0
select sf.fIsUpper('x')   --> 0
select sf.fIsUpper('X')   --> 1

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare	
		@isUpper				bit                                                   -- return value    
	
	if @String is not null and unicode(substring(@String, 1, 1)) = unicode(upper(substring(@String, 1, 1))) 
  begin
    set @isUpper = 1
  end
  else if @String is null
  begin
    set @isUpper = null
  end
  else
  begin
    set @isUpper = 0
  end

	return( @isUpper )

end
GO
