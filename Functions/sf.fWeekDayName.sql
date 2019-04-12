SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fWeekDayName]
 (
	 @Date														date
 )
returns nvarchar(9)
as
/*********************************************************************************************************************************
ScalarF	: Week Day Name
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the name (in English) of the day of the week for the date passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | October	2011  |	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used in formatting date values.  It returns the ENGLISH (only) name of the day of the week for the date passed in.

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
		 )
		 
	set @startDate = dateadd(d, -1, @startDate)
end
------------------------------------------------------------------------------------------------------------------------------- */ 
begin
 
	declare		
		 @dayname													nvarchar(9)
	 
	select 
		@dayname =
		 case (datepart(dw, @Date) + @@datefirst) % 7
			 when 1 then 'Sunday'
			 when 2 then 'Monday'
			 when 3 then 'Tuesday'
			 when 4 then 'Wednesday'
			 when 5 then 'Thursday'
			 when 6 then 'Friday'
			 when 0 then 'Saturday'
		 end
 
	return @dayname
 
end
GO
