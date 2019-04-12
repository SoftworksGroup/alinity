SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fStripXML]
(
	@string			nvarchar(max) 
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
ScalarF	: Strip XML symbols
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the string blocked passed in with XML values stripped and replaced with ascii equivalents
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | July	2011    |	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used in formatting strings obtained through XML manipulations.  Standard XML escaped values - e.g. &gt; and &lt; 
are replaced with their ascii equivalents:  > and <.  The function simplifies syntax.

Example
-------

select sf.fStripXML( 'this is a greater than sign: &gt' )
------------------------------------------------------------------------------------------------------------------------------- */
begin
	return(
		replace(replace(replace(replace(replace(replace( @string, '&lt;', '<'), '&gt;', '>'), '&quot;', '"'), '&apos;', ''''), '&amp;', '&'), '&#x0D;', char(13) + char(10))
		)
end
GO
