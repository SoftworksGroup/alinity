SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fToday]
(
)
returns date
as
/*********************************************************************************************************************************
TableF	: Today
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the current date in the client's time zone
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | October 2011	|	Initial Version
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used primarily in 2 situations.  1) In setting default values for date fields which are to be updated in the 
UI. 2) In comparing a date entered in the UI to the current date (e.g. to see if an item is backdated or future dated).

Use of getdate ... convert(date, getdate()) ... will produce incorrect results if the client's timezone is different than that of 
the database server.  Consider for example a client who is in a timezone 8 hours ahead of the server.  Between 4 pm and midnight 
at the server, the value of getdate() will be the "prior date" according to the client.  Use of this function to return the date
avoids that issue because it takes into account the offset in the client timezone.

Note that this function is intended for use with "whole dates".  For datetimeoffset values there is no need for special 
manipulations since the offset is stored with the value.

In order for this function to produce correct results, the sf.ConfigParam table must be set to the offset of the client
configuration. If no setting is found, the client timezone is assumed to be the same as the server timezone.

Example
-------

select sf.fToday(), sydatetimeoffset()

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @today															date																																				-- return value
		,@clientTZOffSet										varchar(6)																																	-- offset for client timezone - e.g. "-06:00"
		,@serverTZOffSet										varchar(6)	= convert(varchar(6), datename (tzoffset, sysdatetimeoffset()))	-- offset at the server 

	set @clientTZOffSet = 
		convert(varchar(6), isnull(sf.fConfigParam#Value('ClientTimeZoneOffSet'), @serverTZOffSet))

	set @today = convert(date, switchoffset (sysdatetimeoffset(), @clientTZOffSet))

	return(@today)

end
GO
