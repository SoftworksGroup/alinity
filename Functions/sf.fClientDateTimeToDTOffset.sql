SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fClientDateTimeToDTOffset]
(
	@DateTime						datetime																		-- value to be converted
)
returns datetimeoffset(7)
as
/*********************************************************************************************************************************
TableF	: Client Date Time to (server) Date Time Offset
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the @DateTime passed in as a DateTimeOffset value adjusted to the SERVER timezone
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Jul		2013	|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used primarily in scheduling situations where a date-time value provided from the UI must be converted between 
the client time zone and the timezone at the server. 

Example
-------

<TestHarness>
  <Test Name="fClientDateTimeToDTOffsetTest" IsDefault="true" Description="Exercises the fClientDateTimeToDTOffset() function.">
    <SQLScript>
      <![CDATA[

				declare
					 @dateFromUI				datetime							= getdate()

				select
					 @dateFromUI																	DateFromUI
					,sf.fClientDateTimeToDTOffset(@dateFromUI)		ServerDateTime
	]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/> 
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fClientDateTimeToDTOffsetTest'
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @serverDateTime										datetimeoffset(7)									-- return value
		,@clientTZOffSet										varchar(6)												-- offset for client timezone - e.g. "-06:00"
		,@serverTZOffSet										varchar(6)	= convert(varchar(6), datename (tzoffset, sysdatetimeoffset()))	-- offset at the server 

	if @DateTime is not null
	begin

		set @clientTZOffSet = 
			convert(varchar(6), isnull(sf.fConfigParam#Value('ClientTimeZoneOffSet'), @serverTZOffSet))

		set @serverDateTime = cast(cast(@DateTime as varchar(30)) + ' ' + @clientTZOffSet as datetimeoffset(7))

		set @serverDateTime = convert(datetimeoffset, switchoffset (@serverDateTime, @serverTZOffSet))

	end

	return(@serverDateTime)

end
GO
