SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fDatePlusTimeToDT]
(
	 @DatePart         date
	,@TimePart         time
)
returns datetime
as
/*********************************************************************************************************************************
ScalarF	: Date Plus Time To DateTime
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Combines the date part and the time part passed in and returns a date-time value
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Jul		2013	|	Initial Version (adapted from a function written by Carl Nolan)
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used to combine dates with times to product date-time data types.  There is no built-in function to perform
this action in TSQL, however, it can be accomplished in a single line. When a time value is cast to a datetime the date component 
is set to '1900-01-01', and this date equates to a days equivalent of zero in the SQL date and time functions. This function
relies on this fact to produce the date-time result. 

Example
-------

declare
	  @datePart	date		= getdate()
	 ,@timePart	time		= cast(dateadd(hour, 1, getdate()) as time)

select
	 @datePart																		DatePart
	,@timePart																		TimePart			
	,sf.fDatePlusTimeToDT(@DatePart, @TimePart)		ServerDateTime

------------------------------------------------------------------------------------------------------------------------------- */

begin
	return(dateadd(dd, datediff(dd, 0, @DatePart), cast(@TimePart as datetime)))
end
GO
