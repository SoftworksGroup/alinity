SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fEscapeForXML]
	(
	 @StringToEscape			nvarchar(512)																			-- string to escape for XML
	)
returns nvarchar(512)
as
/*********************************************************************************************************************************
Function: Escape for XML
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the string passed in with characters that break XML formatting escaped with appropriate values
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Jan	2014		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is in generating XML snippets.  Characters like <, >, &  embedded in text values break XML syntax and therefore
need to be escaped.  This function adds the required escaping values.

Example:
--------

select sf.fEscapeForXML( N'10 is > 9 but < 11')						-> 10 is &gt; 9 but &lt; 11										

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set @StringToEscape = replace(@StringToEscape, '&', '&amp;' )           -- escape common characters that would cause problems
	set @StringToEscape = replace(@StringToEscape, '<', '&lt;'  )   
	set @StringToEscape = replace(@StringToEscape, '>', '&gt;'  )
	set @StringToEscape = replace(@StringToEscape, '"', '&quot;')

	return(@StringtoEscape)

end
GO
