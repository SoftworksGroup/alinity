SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsBinaryDifferent]
(
	 @Value1															varbinary(max)										-- first value to compare
  ,@Value2															varbinary(max)										-- last value to compare
)
returns bit
as
/*********************************************************************************************************************************
ScalarF		: Is Binary Different 
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns a bit indicating if the 2 values passed are different
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Kris Dawson	| Jun		2013	|	Initial version

Comments	
--------
This function is used to compare 2 binary values to determine if they have different values.  This is similar to an expression of
the form "@Value1 = @Value2" except that NULL's in either value are handled correctly - and if both @Value's are NULL then
the bit is returned as 0 (indicating the values are the same).

The function accepts varbinary(max) as the data type to handle the data type clash between variants and binaries that prevents
binaries from being compared with fIsDifferent.

Example
-------

declare
	 @value1				varbinary(max) = null
	,@value2				varbinary(max) = null

select sf.fIsBinaryDifferent(@value1, @value2)

set @value2 = 0x202020
select sf.fIsBinaryDifferent(@value1, @value2)

set @value1 = 0x202020
set @value2 = 0x202020
select sf.fIsBinaryDifferent(@value1, @value2)

set @value2 = 0x6ABCDEF
select sf.fIsBinaryDifferent(@value1, @value2)

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @isDifferent				bit																								-- return value

	if @Value1 = @Value2  or (@Value1 is null and @Value2 is null)
	begin
		set @isDifferent = cast(0 as bit)
	end
	else
	begin
		set @isDifferent = cast(1 as bit)
	end

	return(@isDifferent)

end
GO
