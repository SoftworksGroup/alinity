SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fNow]
(
)
returns datetime
as
/*********************************************************************************************************************************
TableF	: Now
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the current time in the client's time zone as a datetime value
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | October 2011	|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used primarily in 2 situations.  1) In setting default values for datetime columns which are to be updated in the 
UI. Use of getdate() will produce incorrect results if the client's timezone is different than that of the database server.  For
example if the DB server is -7 and the client is -8, the "current" time provided by getdate() will be one hour off. 2) In 
comparing a datetime entered in the UI to the current date (e.g. to see if an item is backdated or future dated).

Note that this function is intended for use with date times that are updated in the UI.  If the datetime is set by the database, 
simply use a datetimeoffset data type in the column.  With this done, there is no need for special manipulations since the offset 
is stored with the value and displayed correctly in the user interface (in the users timezone).

In order for this function to produce correct results, the sf.ConfigParam table must be set to the offset of the client
configuration. If no setting is found, the client timezone is assumed to be the same as the server timezone.

Example
-------

select sf.fNow(), sysdatetimeoffset()

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @now																datetime													-- return value
		,@clientTZOffSet										varchar(6)												-- offset for client timezone - e.g. "-06:00"
		,@serverTZOffSet										varchar(6)	= convert(varchar(6), datename (tzoffset, sysdatetimeoffset()))	-- offset at the server 

	set @clientTZOffSet = 
		convert(varchar(6), isnull(sf.fConfigParam#Value('ClientTimeZoneOffSet'), @serverTZOffSet))

	set @now = convert(datetime, switchoffset (sysdatetimeoffset(), @clientTZOffSet))

	return(@now)
end
GO
