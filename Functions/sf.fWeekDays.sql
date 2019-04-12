SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fWeekDays]
(
	 @StartDate					date										-- first date in range
	,@EndDate						date										-- last date in range
)
returns int
as
/*********************************************************************************************************************************
ScalarF	: Week Days
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns count of number of week days occurring between (inclusive) the date range passed
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | March 2011    |	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is useful in task and project planning situations or wherever the number of non-weekend days (week days) must be 
determined.  

If the @StartDate is less than the @EndDat, or if either end of the range is not provided, then NULL is returned.

Example
-------
declare
	 @StartDate		date = sysdatetimeoffset()
	,@EndDate			date = sysdatetimeoffset() + 2

select sf.fWeekDays(@StartDate, @EndDate)

select
	 @EndDate		= sysdatetimeoffset()
	,@StartDate	= sysdatetimeoffset() + 2

select sf.fWeekDays(@StartDate, @EndDate)

set @EndDate = null
select sf.fWeekDays(@StartDate, @EndDate)

set @EndDate = sysdatetimeoffset()
set @StartDate = null
select sf.fWeekDays(@StartDate, @EndDate)

set @StartDate	= sysdatetimeoffset()
set @EndDate		= dateadd(d, 6, @StartDate)
select sf.fWeekDays(@StartDate, @EndDate)

------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @weekDayCount												int														-- return value

	if @StartDate <= @EndDate
	begin

		set @weekDayCount = 
			 datediff(d, @StartDate, @EndDate) + 1 - 
			(datediff(wk,@StartDate, @EndDate) + case when datepart(dw, @StartDate) = 1 then 1 else 0 end) - 
			(datediff(wk,@StartDate, @EndDate) + case when datepart(dw, @EndDate)   = 7 then 1 else 0 end)

	end

	return(@weekDayCount)

end
GO
