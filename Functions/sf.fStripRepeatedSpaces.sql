SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fStripRepeatedSpaces]
(
	 @String			nvarchar(max)                                             -- string to strip repeated space characters from
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
Function: Strip Repeated Spaces
Notice  : Copyright © 2016 Softworks Group Inc.
Summary	: takes a string and strips any repeated (double, triple etc) spaces
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Kris Dawson	| Nov   2016			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to strip extra spaces out of the provided string. This is used instead of the noise character replacement
as running '    '(4) through and replacing '  '(2) with ' '(1) gives you '  '(2); not ideal. NOTE though this method won't trim
the left and right edges, it only replaces repeated spaces so you'll need to use ltrim and rtrim

Example:
--------

-- default

select [sf].[fStripRepeatedSpaces]('Hello   world    4')

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @doubleSpace											nchar(2) = '  '											-- constant for double spaces (to replace)
		,@singleSpace											nchar(1) = ' '											-- constant for single space (to replace with)

	while (@String is not null and charindex(@doubleSpace, @String) <> 0)
	begin
		set @String = replace(@String, @doubleSpace, @singleSpace)
	end

	return @String

end
GO
