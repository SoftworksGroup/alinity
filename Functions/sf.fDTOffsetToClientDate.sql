SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fDTOffsetToClientDate]
(
	@DateTimeOffset					datetimeoffset(7)																-- value to be converted
)
returns date
as
/*********************************************************************************************************************************
TableF	: DateTime Offset To Client Date
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the @DateTimeOffset passed in as a Date data type adjusted for the client timezone
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Dec		2012	|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used primarily in situations where a date-time-offset value must be compared to a date value entered by
the client.  This is required, for example, to check whether an EffectiveDate (stored as date type) on an assignment record
is set before the CreateTime stored in the table as a datetimeoffset.

Example
-------

declare
	 @effectiveDate			date							= getdate()
	,@createTime				datetimeoffset(7) = sysdatetimeoffset()

select
	 @createTime															CreateTimeDTO
	,sf.fDTOffsetToClientDate(@createTime)		CreateTimeAsClientDate
	,@effectiveDate														Effective

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @clientDate												date															-- return value
		,@clientTZOffSet										varchar(6)												-- offset for client timezone - e.g. "-06:00"
		,@serverTZOffSet										varchar(6)	= convert(varchar(6), datename (tzoffset, sysdatetimeoffset()))	-- offset at the server 

	set @clientTZOffSet = 
		convert(varchar(6), isnull(sf.fConfigParam#Value('ClientTimeZoneOffSet'), @serverTZOffSet))

	set @clientDate = convert(date, switchoffset (@DateTimeOffset, @clientTZOffSet))

	return(@clientDate)

end
GO
