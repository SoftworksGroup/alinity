SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pLinePrint]
	 @TextToPrint										nvarchar(max)							-- text block to print line by line
as
/*********************************************************************************************************************************
Procedure	: Line Print
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: prints text block provided line by line
History		: Author(s)  	| Month Year			| Change Summary
					: ------------|-----------------|-----------------------------------------------------------------------------------------
					:	Tim Edlund	|	April			2011	| Initial version
					:	Tim Edlund	|	April			2015	| Updated break position variable to Int from SmallInt (modules over 65K in lines!)
					: Tim Edlund	| May				2018	| Removed leading blank line

Comments	
--------
This is a utility procedure used primarily in debugging. The procedure prints the text provided on a line by line basis
using the "print" command.  Individual lines are recognized based on the existence of:

		carriage return line feed pairs - char(13) + char(10)
		line feeds alone								- char(10)

When no end of line character is detected, the procedure prints out the remainder of the text.

If the text passed in is NULL, one blank line is printed.

Example:
--------

declare
	@textToPrint		nvarchar(max)

select 
	@textToPrint = v.VIEW_DEFINITION
from 
	INFORMATION_SCHEMA.VIEWS v

exec sf.pLinePrint
	 @TextToPrint		= @textToPrint

------------------------------------------------------------------------------------------------------------------------------- */
begin

	set nocount on
																																																																			
	declare
		 @errorNo 													int = 0														-- 0 no error, if < 50000 SQL error, else business rule
		,@nextBreakChar											nvarchar(5)												-- end of line character(s)
		,@nextBreakPos											int																-- position of next line break in characters
		,@nextLine													nvarchar(4000)										-- SQL syntax to execute dynamically to create/drop

	begin try

		set @nextBreakPos = -1

		while @TextToPrint is not null and @nextBreakPos <> 0
		begin

			-- search for line break character

			set @nextBreakPos	= 0
			
			if @nextBreakPos = 0
			begin
				set @nextBreakChar	= char(13) + char(10)
				if @nextBreakPos	= 0 set @nextBreakPos = charindex(@nextBreakChar, @TextToPrint )
			end
			
			if @nextBreakPos = 0
			begin
				set @nextBreakChar	= char(10)
				if @nextBreakPos	= 0 set @nextBreakPos = charindex(@nextBreakChar, @TextToPrint )
			end			
			
			if @nextBreakPos > 0											-- parse line at the break
			begin
				set @nextLine = left(@TextToPrint, @nextBreakPos - 1)
				set @TextToPrint = substring(@TextToPrint, @nextBreakPos + len(@nextBreakChar), len(@TextToPrint))
			end
			else																			-- no breaks left - print the rest of the block
			begin
				set @nextLine = convert(nvarchar(4000), @TextToPrint)
			end

			print @nextLine

		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
