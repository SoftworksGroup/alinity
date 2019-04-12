SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fStripNoise]
(
	 @String			nvarchar(max)                                             -- string to strip noise characters from
	,@Noise				nvarchar(max)		= '!•@•#•&•*•(•)•<•>•:• •_•-•''•.•,•"•;'	-- delimited noise characters to strip
	,@Delimiter		nvarchar(15)		= '•'																			-- delimiter used in the noise character string
	,@ReplaceWith	nvarchar(5)			= ''																			-- value to replace stripped characters with
	,@RemoveCRLF	bit							= 1																				-- whether or not to remove line feed and carriage return
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
Function: Strip Noise
Notice  : Copyright © 2016 Softworks Group Inc.
Summary	: takes a string and strips out the specified noise characters
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Kris Dawson	| Nov   2016			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to strip noise characters out of the provided string, typically to improve matching algorithms by removing
punctuation. Optionally the noise list, the delimiter used by it and the character to replace the noise characters with can be
provided to tweak the functionality.

Example:
--------

-- default

select [sf].[fStripNoise]('10134 at 99 - ave', default, default, default, default)

-- null and empty strings

select [sf].[fStripNoise](null, default, default, default, default)
select [sf].[fStripNoise]('', default, default, default, default)

-- replace all instances of 'a' or 'c' with 'EH' using ',' as the noise delimiter

select [sf].[fStripNoise]('abcdefg', 'a,c', ',', 'EH', default)

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@ON																bit = cast(1 as bit)								-- constant for true bit

	declare
		@noiseList                        table																-- stores results of query
		(
			NoiseCharacter                 nvarchar(255) not null								-- the noise character (or word/phrase)
		)

	if @RemoveCRLF = @ON set @Noise = @Noise + @Delimiter + char(10) + @Delimiter + char(13)

	if @String is not null
	begin

		-- populate a table with the noise characters

		insert
			@noiseList
		select
			cast(Item as nvarchar(255))
		from
			sf.fSplitString(@Noise, @Delimiter)
	
		-- strip noise characters and replace with the replacement character

		select
			@String = replace(@String, n.NoiseCharacter, @ReplaceWith)
		from
			@noiseList n

	end

	return @String

end
GO
