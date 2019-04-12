SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fEscapeForSQL]
	(
	 @StringToEscape			nvarchar(max)																			-- string to escape for SQL
	)
returns nvarchar(max)
as
/*********************************************************************************************************************************
Function: Escape for SQL
Notice  : Copyright © 2016 Softworks Group Inc.
Summary	: Returns the string passed in with characters that break XML formatting escaped with appropriate values
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Kris Dawson	| Dec	2016		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used in generating SQL snippets.  Characters like ' embedded in text values break SQL syntax and therefore
need to be escaped.  This function adds the required escaping values.

Example:
--------

select sf.fEscapeForSQL( N'My computer''s SSD is faster than Cory''s')								

------------------------------------------------------------------------------------------------------------------------------- */

begin

  set @StringToEscape = replace(@StringToEscape, '''', '''''' )           -- escape common characters that would cause problems

	return(@StringtoEscape)

end
GO
