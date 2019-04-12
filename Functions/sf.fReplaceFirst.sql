SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fReplaceFirst]
(
	 @String				nvarchar(4000)																					-- base string to modify
	,@Find					nvarchar(4000)																					-- string to find for replacement
	,@Replacement		nvarchar(4000)																					-- value to replace 
)
returns nvarchar(4000)
as
/*********************************************************************************************************************************
ScalarF		: Replace First
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: returns a string with only the first occurrence of the find value replaced
History		: Author(s)  	| Month Year			| Change Summary
					: ------------|-----------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Feb		2013			|	Initial version

Comments	
--------
This function is used for string manipulation to replace values within strings. It is similar to the built-in "replace()" function
except that it only replaces the first occurrence - the left-most - of the string to be found.

Example
-------
select sf.fReplaceFirst('PeterPiperPickedAPeck', 'P', '!')
select sf.fReplaceFirst('PeterPiperPickedAPeck', 'i', 'eye')
------------------------------------------------------------------------------------------------------------------------------- */

begin
	return(stuff(@String, charindex(@Find, @String), len(@Find), @Replacement))
end
GO
