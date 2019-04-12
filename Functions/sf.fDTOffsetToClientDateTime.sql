SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fDTOffsetToClientDateTime]
(
	@DateTimeOffset					datetimeoffset(7)																-- value to be converted
)
returns datetime
as
/*********************************************************************************************************************************
ScalarF	: DateTime Offset To Client DateTime
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the @DateTimeOffset passed in as a DateTime adjusted for the client timezone
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Dec		2012	|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used primarily in situations where a date-time-offset value must be compared to a date-time value entered by
the client.  This is required, for example, to check whether an EffectiveTime (stored as datetime) on an assignment record
is set before the CreateTime stored in the table as a datetimeoffset.

Example
-------

declare
	 @effectiveTime			datetime					= getdate()
	,@createTime				datetimeoffset(7) = sysdatetimeoffset()

select
	 @createTime																CreateTimeDTO
	,sf.fDTOffsetToClientDateTime(@createTime)	CreateTimeAsClientDateTime
	,@effectiveTime															EffectiveTime

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @clientDateTime										datetime													-- return value
		,@clientTZOffSet										varchar(6)												-- offset for client timezone - e.g. "-06:00"
		,@serverTZOffSet										varchar(6)	= convert(varchar(6), datename (tzoffset, sysdatetimeoffset()))	-- offset at the server 

	set @clientTZOffSet = 
		convert(varchar(6), isnull(sf.fConfigParam#Value('ClientTimeZoneOffSet'), @serverTZOffSet))

	set @clientDateTime = convert(datetime, switchoffset (@DateTimeOffset, @clientTZOffSet))

	return(@clientDateTime
	)
end
GO
