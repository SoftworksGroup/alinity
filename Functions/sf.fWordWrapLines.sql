SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fWordWrapLines]
(
	 @String			nvarchar(max)                                             -- string to split into lines on words
	,@LineLength	int	
)
returns @Lines	table 
(
	 ID				int							identity(1,1) 
	,Line			nvarchar(1000)	
)
as
/*********************************************************************************************************************************
Function: Word Wrap - return LINES
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Takes a string containing words and returns it as a table of lines word-wrapped to specified line length
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| May   2012		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to format strings of text that must fit within a maximum line length.  This version of the function returns
a table of "line" values that can be retrieved and displayed sequentially. An alternate form of the function - fWordWrapString -
returns the same content but with carriage-return + linefeed pairs inserted into the text at the end of each line.

The wrapping algorithm is simple: words are divided based on space characters. Any existing line breaks in the text are preserved
so that any paragraphs defined in the text block are preserved.  Line breaks in the text must be defined using a carriage-return 
linefeed pair, a carriage return character on its own, or a linefeed character on its own.

If any word in the text exceeds the @LineLength, then the word is returned in multiple lines. 

The function calls another library function to split the string on space characters (based on a recursive CTE). 

Note that line lengths longer than 1000 are NOT supported.  If a line length is less than 1 or longer than 1000, then a blank
table is returned.

Maintenance Note
----------------
Changes to this function or its documentation must remain consistent with sf.fWordWrapString. Ensure that function is updated with
relevant changes made here!

Example:
--------

declare
	 @string			nvarchar(max)	= N'This is a really long line that we need to have wrapped into a smaller space. '
																+ 'I''m not sure if we can do this, because it''s really, really long and it also has this word '
																+ '"supercalafragilisticeXPaladocious" that is 35 characters long with quotes! ' + char(10)
																+ 'Line breaks appear before and after this sentence.' + char(13) + char(10)
																+ 'Line breaks appear before and after this sentence, with just a CR.' + char(13) 
																+ 'Check out what                               '
																+ 'happens when we have a                a bunch                        of     spaces?'

select Line from sf.fWordWrapLines(@string, 62)
select Line from sf.fWordWrapLines(@string, 32)	
select Line from sf.fWordWrapLines(N'CheckOutAVeryLongWordThatExceedsTheLineLengthAllByItself', 15)
select Line from sf.fWordWrapLines(N'This string does not require wrapping.', 60)	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @maxRows										int				
		,@i													int
		,@line											nvarchar(1000)
		,@nextWord									nvarchar(1000)
		,@lineBreak									int

	declare
		@words		table
	(
		 ID				int								not null
		,Word			nvarchar(1000)		not null
	)

	-- need to change both CR/LF and CR sequences to LF; Synoptec comments contain CRs only
	set @String = replace(replace(@String, char(13) + char(10), char(10)), char(13), char(10))

	-- use another library function to split the string provided into 
	-- words, breaking on spaces
	
	if @LineLength between 1 and 1000																																	-- avoid parsing if LineLength is invalid!
	begin

		insert
			@words
		(
			 ID
			,Word
		) 
		select
			 ID
			,Item
		from 
			sf.fSplitString(@String, N' ')

	end

	set @maxRows	= @@rowcount
	set @i				= 0
	set @line			= N''

	while @i < @maxRows
	begin
		set @i					+=1
		set @lineBreak	= 0

		select 
			@nextWord = w.Word
		from	
			@words w
		where
			w.ID = @i

		if len(@line + (case when len(@line) > 0 then N' ' else N'' end) + @nextWord) <= @LineLength		-- next word fits into line length
		begin
			set @line += (case when len(@line) > 0 then N' ' else N'' end) + @nextWord										 -- add to line with space
		end
		else
		begin

			if len(@nextWord) >= @LineLength																															-- next word is a whole line on its own
			begin
				if len(@line) > 0 insert @Lines (Line) select @line																					-- if content in prior line - add it

				set @line = @nextWord

				while len(@line) >= @LineLength
				begin
					insert @Lines (Line) select left(@line, @lineLength)																			-- and then add this word as a line
					set @line = substring(@line, @lineLength + 1, 1000)
				end

			end
			else																																													-- next word isn't line on its own, but doesn't fit on existing line	
			begin
				insert @Lines (Line) select @line																														-- add the existing line	
				set @line = @nextWord																																				-- start next line with this word
			end
		end

		set @lineBreak	= charindex(char(10), @line)

		if @lineBreak > 0																																								-- if line break exists
		begin
			insert @Lines (Line) select left(@line, @lineBreak - 1)																				-- add the line up to the break	
			set @line = substring(@line, @lineBreak + 1, 1000)																						-- add remaining portion to next line	
		end

	end

	if len(@line) > 0 insert @Lines (Line) select @line																								-- add the final line if non-blank

	return
end
GO
