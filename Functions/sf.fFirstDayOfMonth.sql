SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFirstDayOfMonth]
(
	 @DateInMonth						date										-- a date in the month to calculate the 1st for
)
returns date
as
/*********************************************************************************************************************************
ScalarF	: Last Day Of Month
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the first date in the month for the date passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | March 2011    |	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is created primarily to complement, fLastDayOfMonth().  It simplifies syntax in creating a date value which is the
first date of the month passed in.

If the @DateInMonth value is NULL when passed in, then NULL is returned.

Example
-------

select sf.fFirstDayOfMonth(sysdatetimeoffset())
select sf.fFirstDayOfMonth(sysdatetimeoffset()-30)
select sf.fFirstDayOfMonth(sysdatetimeoffset()-62)
select sf.fFirstDayOfMonth(sysdatetimeoffset()-6100)
------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @firstDayOfMonth												date														-- return value

	if @DateInMonth is not null
	begin

		set @firstDayOfMonth 
			= convert(date, convert(varchar(4), year(@DateInMonth) ) + '/'	+ convert(varchar(2), month(@DateInMonth)) + '/01')

	end

	return(@firstDayOfMonth)

end
GO
