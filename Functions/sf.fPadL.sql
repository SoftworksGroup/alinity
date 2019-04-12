SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fPadL]
(
	 @StringToPad		nvarchar(4000)									-- string that requires space padding
	,@FinalLength		smallint												-- final length of the string
)
returns nvarchar(4000)
as
/*********************************************************************************************************************************
ScalarF		: Pad Left
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: returns string padded on the left hand side with spaces to @FinalLength
History		: Author(s)  	| Month Year			| Change Summary
					: ------------|-----------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| April			2010  |	Initial version

Comments	
--------
This function is used for formatting fixed length output. It pads the string passed in with spaces on the left hand side to the
desired length.  If the string provided is already longer than the @FinalLength requested, the value will be truncated.

If either parameter is passed with NULL, then NULL is returned.

Example
-------
select N'x' + sf.fPadL(N'Tim', 10)
select sf.fPadL(N'ThisWillBeTruncated', 10)
select sf.fPadL(null, 10)
select sf.fPadL(N'Test', null)

------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @padL													nvarchar(4000)									-- return value

	if @StringToPad is not null and @FinalLength is not null
	begin
		set @padL = replicate(N' ', @FinalLength) 
		set @padL = right(@padL + @StringToPad, @FinalLength)
	end

	return(@padL)

end
GO
