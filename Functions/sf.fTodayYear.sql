SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fTodayYear]
(
)
returns smallint
as
/*********************************************************************************************************************************
TableF	: Today Year
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the current year (4 digits) in the client's time zone
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | Apr 2017			|	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used primarily in 2 situations.  1) In setting default values for year columns (e.g. "Registration year")  and 
2) In comparing a year entered in the UI to the current year 

Use of getdate ... convert(date, getdate()) ... will produce incorrect results during a few hours at the start and end of year
depending on the client's timezone relative to the server time.  Consider for example a client who is in a timezone 8 hours ahead 
of the server.  

In order for this function to produce correct results, the sf.ConfigParam table must be set to the offset of the client
configuration. If no setting is found, the client timezone is assumed to be the same as the server timezone.

The function calls sf.fToday() to produce the whole date from which the year is taken.

Example
-------

select sf.fTodayYear(), sydatetimeoffset()

------------------------------------------------------------------------------------------------------------------------------- */

begin
	return(cast(year(sf.fToday()) as smallint))
end
GO
