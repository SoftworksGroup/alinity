SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fPadR]
(
	 @StringToPad		nvarchar(4000)									-- string that requires space padding
	,@FinalLength		smallint												-- final length of the string
)
returns nvarchar(4000)
as
/*********************************************************************************************************************************
ScalarF		: Pad Right
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: returns string padded on the right hand side with spaces to @FinalLength
History		: Author(s)  	| Month Year			| Change Summary
					: ------------|-----------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| April			2010  |	Initial version

Comments	
--------
This function is used for formatting fixed length output. It pads the string passed in with spaces on the right hand side to the
desired length.  If the string provided is already longer than the @FinalLength requested, the value will be truncated.

If either parameter is passed with NULL, then NULL is returned.

Example
-------
select sf.fPadR(N'Tim', 10) + N'x'
select sf.fPadR(N'ThisWillBeTruncated', 10)
select sf.fPadR(null, 10)
select sf.fPadR(N'Test', null)

------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @padR													nvarchar(4000)									-- return value

	if @StringToPad is not null and @FinalLength is not null
	begin
		set @padR = replicate(N' ', @FinalLength) 
		set @padR = left(@StringToPad + @padR, @FinalLength)
	end

	return(@padR)

end
GO
