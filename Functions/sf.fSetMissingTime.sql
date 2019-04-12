SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fSetMissingTime]
(
	 @DateTime				datetime
)
returns datetime
as 
/*********************************************************************************************************************************
Function: Set Missing Time on DateTime
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Adds the current time to date or datetime value passed in - only where the time component is missing
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| Dec		2012			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used where a DateTime value is being used in a date control, and other situations where the time component is
truncated and a time value is required. This occurs on business rules for example where an Expiry time is expected (e.g. for a
grant or assignment), but the user enters a value in a "date" control which truncates time.  The end result is that the 
ExpiryTime appears as midnight which could cause conflicts in business rules.

This function checks if the date time value passed contains a time component other than "00:00:00" - if it does, then no change
to the date is carried out and the date provided is returned. If the time component is missing, however, the current time - 
adjusted for the client timezone - is added onto the "date" portion of the value passed in and that resulting datetime is
returned

Example
-------

declare
	 @dateNoTime		datetime = '20151015'				-- date with no time portion
	,@dateWithTime	datetime = getdate()				-- full date time

select
	 @dateNoTime													DateNoTimeBefore
	,sf.fSetMissingTime(@dateNoTime)			DateNoTimeAfter
	,@dateWithTime												DateWithTimeBefore
	,sf.fSetMissingTime(@dateWithTime)		DateWithTimeAfter

*/
begin

	declare
		 @dateWithTime					datetime
		,@time									varchar(12)

	if @DateTime is not null
	begin

		if left(cast(@DateTime as time), 12) <> '00:00:00.000'
		begin
			set @dateWithTime = @DateTime
		end
		else
		begin
			set @time					= cast(cast(sf.fNow() as time) as varchar(12))
			set @dateWithTime = cast((convert(varchar(8), @DateTime, 112)) + ' ' + @time as datetime)
		end

	end

	return(@dateWithTime)

end
GO
