SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fQuoteString]
(
	@InString nvarchar(max)																									-- string to quote
) 
returns nvarchar(max)
as
/*********************************************************************************************************************************
ScalarF	: Quote String
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the string provided surrounded by single quotes and with embedded quotes doubled
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | August	2011  |	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used to support quoting of long strings where the built-in QuoteName() function cannot be used because it is
limited to 128 bytes in length.  The function is used most frequently in generating SQL scripts which include data values
which may contain embedded quotes.

Example
-------

select
	 m.MessageSCD
	,sf.fQuoteString(m.DefaultText)	 QuotedString
from
	sf.vMessage m
order by 
	m.MessageSCD

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare 
		 @outString			nvarchar(max)																					-- return value
		,@singleQuote						char(1)																				-- single quote value

	 set @singleQuote = ''''
	 set @outString = replace(@InString, @singleQuote, @singleQuote + @singleQuote)

	 return(@singleQuote + @outString + @singleQuote)

end
GO
