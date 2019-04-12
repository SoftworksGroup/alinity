SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fClientDateToDTOffset]
(
@Date date -- value to be converted
)
returns datetimeoffset(7)
as

/*********************************************************************************************************************************
TableF	: Client Date to (server) Date Time Offset
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the @Date passed in as a DateTimeOffset value adjusted to the SERVER timezone
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Dec 2012		|	Initial version
				: Tim Edlund					| Sep 2019		| Logic changed to set the time to the FIRST moment of the day (previously as 23:59:59)

Comments	
--------
This function is used primarily in situations where the user interface has prompted the client to enter a date, and this value
is then used in a query against datetimeoffset values stored in the database timezone.  A common example is where the user 
enters a date range that is then used to query against audit times in the table that are stored in the server time using
date-time-offsets.

LIMITATION
----------
Since the date has no time component, the resulting date-time is converted from the user timezone "00:00:00 00000" time.  You cannot
receive an end-of-day time from this function. Use sf.fClientDateTimeToDTOffset to get end of day time values.

Example
-------

<TestHarness>
  <Test Name="fClientDateToDTOffset" IsDefault="true" Description="Exercises the fClientDateToDTOffset() function.">
    <SQLScript>
      <![CDATA[
				declare
					 @dateFromUI				date							= getdate()

				select
					 @dateFromUI															DateFromUI
					,sf.fClientDateToDTOffset(@dateFromUI)		ServerDateTime
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1"/> 
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fClientDateToDTOffset'
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@serverDateTime datetimeoffset(7)																														-- return value
	 ,@clientTZOffSet varchar(6)																																	-- offset for client timezone - e.g. "-06:00"
	 ,@serverTZOffSet varchar(6) = convert(varchar(6), datename(tzoffset, sysdatetimeoffset()));	-- offset at the server 

	if @Date is not null
	begin
		set @clientTZOffSet = convert(varchar(6), isnull(sf.fConfigParam#Value('ClientTimeZoneOffSet'), @serverTZOffSet));
		set @serverDateTime = cast(cast(@Date as varchar(10)) + ' 00:00:00.00000 ' + @clientTZOffSet as datetimeoffset(7));
		set @serverDateTime = convert(datetimeoffset, switchoffset(@serverDateTime, @serverTZOffSet));
	end;

	return (@serverDateTime);

end;
GO
