SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fWordWrapString]
(
	 @String			nvarchar(max)                                             -- string to split into lines on words
	,@LineLength	int	
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
Function: Word Wrap - return STRING
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Takes a string containing words and returns it word-wrapped as a string with CR-LF's to specified line length
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| May   2012		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to format strings of text that must fit within a maximum line length.  This version of the function returns
a string of text with embedded carriage-return linefeed pairs marking the end of each line.  An alternate form of the function - 
fWordWrapLines - returns the same content but as a table function returning one or more lines as separate rows.

The wrapping algorithm is simple: words are divided based on space characters. Any existing line breaks in the text are preserved
so that any paragraphs defined in the text block are preserved.  Line breaks in the text must be defined using either a 
carriage-return linefeed pair, or a linefeed character on its own. If any word in the text exceeds the @LineLength, then the word 
is returned in multiple lines. 

A CRLF pair is not added to the final line (but is preserved if one existed there in the original string).

Note that line lengths longer than 1000 are NOT supported.  If a line length is less than 1 or longer than 1000, then a blank
table is returned.

This version of the function is essentially an alternate call syntax for sf.fWordWrapLines.  The lines are returned and 
concatenated into a string with CRLF pairs.  See sf.fWordWrapLines for details of the main formatting logic.

Maintenance Note
----------------
Changes to this function or its documentation must remain consistent with sf.fWordWrapLines. Ensure that function is updated with
relevant changes made here!

Example:
--------

declare
	 @string			nvarchar(max)	= N'This is a really long line that we need to have wrapped into a smaller space. '
																+ 'I am not sure if we can do this, because it it really, really long and it also has this word '
																+ '"supercalafragilisticeXPaladocious" that is 35 characters long with quotes! ' + char(10)
																+ 'Line breaks appear before and after this sentence.' + char(13) + char(10)
																+ 'Check out what                               '
																+ 'happens when we have a                a bunch                        of     spaces?'

select sf.fWordWrapString(@string, 62)
select sf.fWordWrapString(@string, 32)	
select sf.fWordWrapString(N'CheckOutAVeryLongWordThatExceedsTheLineLengthAllByItself', 15)
select sf.fWordWrapString(N'This string does not require wrapping.', 60)	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @wordWrapString						nvarchar(max)																												-- return value

	select
		@wordWrapString = isnull(@wordWrapString + char(13) + char(10) + x.Line, x.Line) 
	from
		sf.fWordWrapLines(@String, @LineLength) x

	return(@wordWrapString)
end
GO
