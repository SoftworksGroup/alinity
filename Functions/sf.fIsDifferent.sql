SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsDifferent]
(
	 @Value1															sql_variant												-- first value to compare
	,@Value2															sql_variant												-- last value to compare
)
returns bit
as
/*********************************************************************************************************************************
ScalarF		: Is Different 
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns a bit indicating if the 2 values passed are different
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Feb		2013	|	Initial version

Comments	
--------
This function is used to compare 2 values to determine if they have different values.  This is similar to an expression of
the form "@Value1 = @Value2" except that NULL's in either value are handled correctly - and if both @Value's are NULL then
the bit is returned as 0 (indicating the values are the same).

The function accepts SQL variants as the data type so that strings, integers and date/time values, and bits can be provided 
and compared. Both values passed in must be of the same data type to obtain predictable results.

LIMITATION: this function does not support nvarchar(max) or varchar(max) data types which cannot be passed into sql_variant types!

Example
-------

declare
	 @value1				nvarchar(50)
	,@value2				nvarchar(50)

set @value1 = N'Hello World'
set @value2 = N'Hello World'
select sf.fIsDifferent(@value1, @value2)
set @value2 = N'Hello Universe'
select sf.fIsDifferent(@value1, @value2)

declare
	 @value1				datetime
	,@value2				datetime

set @value1 = dateadd(day, 10, getdate())
set @value2 = @value1
select sf.fIsDifferent(@value1, @value2)
set @value1 = dateadd(day, 1, getdate())
select sf.fIsDifferent(@value1, @value2)

declare
	 @value1				decimal(10, 3)
	,@value2				decimal(10, 3)

set @value1 = 10.001
set @value2 = 10.001
select sf.fIsDifferent(@value1, @value2)
set @value1 = 10.002
select sf.fIsDifferent(@value1, @value2)
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
