SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsWeekDay]
(
	@Date													date
)
returns bit 
as 
/*********************************************************************************************************************************
ScalarF	: Is Week Day
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns true (1) when the date provided is a non-weekend date
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | October	2011  |	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used to determine if a particular date falls on a weekend.  The function takes into consideration the local setting
of the first day of week value (@@datefirst).  In the US and Canada, for example, @@datefirst returns 7, which means that days of week
6 and 7 are the weekend dates.

Example
-------
declare
	 @startDate		date  = sysdatetimeoffset()
	,@i						int		= 0 

while @i < 10
begin
	set @i += 1
	
	print 
		(
		 convert(nvarchar(10), @startDate, 121) 
		 + ' ' + sf.fWeekDayName(@startDate) 
		 + ' ' + case when sf.fIsWeekDay(@startDate) = 1 then 'Weekday' else 'Weekend' end
		 )
		 
	set @startDate = dateadd(d, -1, @startDate)
end
------------------------------------------------------------------------------------------------------------------------------- */

begin 

	declare	
		 @Datefirst									int
		,@Dateweek									int 
		,@isWeekDay									bit  = cast(0 as bit)

	set @Datefirst	= @@datefirst - 1
	set @Dateweek		= datepart(weekday, @Date) - 1

	if (@Datefirst + @Dateweek) % 7 not in (5, 6) set @isWeekDay = cast(1 as bit)

	return (@isWeekDay)
		
end
GO
