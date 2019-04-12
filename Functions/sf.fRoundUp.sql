SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fRoundUp]
(
	@Number								float						-- the number to be rounded
 ,@DecimalPlaces				int							-- the number of decimals to return
)
returns float
as
/*********************************************************************************************************************************
ScalarF : sf.fRoundUp
Notice  : Copyright © 2014 Softworks Group Inc.
Summary : returns a float value - rounded up with the specified number of decimal points remaining
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Sep		2011  |	Initial version

Comments	
--------
This function is used to force upward rounding.  The number of decimal places may be specified - defaults to 0.  The value returned
will always move the last digit upward if there are fractional values in the next decimal place.  

The input and return numbers are float types so casting to the required type may be required to conform with code-analysis rules.
Wrapper functions exist to handle the casts to common types.

Example
-------
select sf.fRoundUp( 10.0000001, 0)		=> 11
select sf.fRoundUp( 112, -1)					=> 120

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @numberRounded					float							-- return value
		,@roundUpAdjustment			float = 0					-- adjustment for round up

	-- when rounding we cannot just add 1
	-- calculate the round up value using an adjustment based on power()

	if @Number - cast(round(@Number, @DecimalPlaces) as float) > 0			
	begin
		set @roundUpAdjustment = power(10, (@DecimalPlaces * -1) )
	end
 
	set @numberRounded = round(@Number, @DecimalPlaces) + @roundUpAdjustment
	
	return(@numberRounded)

end
GO
