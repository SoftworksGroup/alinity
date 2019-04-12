SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fLastDayOfMonth]
(
	 @DateInMonth						date										-- a date in the month to calculate the month end for
)
returns date
as
/*********************************************************************************************************************************
ScalarF	: Last Day Of Month
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the last date in the month for the date passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | March 2011    |	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is useful in accounting and other situations where the last date of the month a transaction occurs in needs to 
be calculated.  The function provides the correct values for February including leap years. 

If the @DateInMonth value is NULL when passed in, then NULL is returned.

Example
-------

select sf.fLastDayOfMonth(sysdatetimeoffset())
select sf.fLastDayOfMonth(sysdatetimeoffset()-30)
select sf.fLastDayOfMonth(sysdatetimeoffset()-62)
select sf.fLastDayOfMonth(sysdatetimeoffset()-6100)
------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @lastDayOfMonth												date														-- return value

	if @DateInMonth is not null
	begin

		set @lastDayOfMonth = 
			convert(date, convert(varchar(4), year(@DateInMonth) ) + '/' + convert(varchar(2), month(@DateInMonth)) + '/01')

		set @lastDayOfMonth = dateadd( dd, -1, dateadd(m, 1, @lastDayOfMonth))

	end

	return(@lastDayOfMonth)

end
GO
