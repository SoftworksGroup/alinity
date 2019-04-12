SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrationYearLabel
(
	@EventTime datetime -- date time of event to return registration year label for
)
returns varchar(9)
as
/*********************************************************************************************************************************
ScalarF		: Registration Year
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns a 4 or 9 digit string label year indicating in which registration year the event occurred
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2017		|	Initial version
				: Tim Edlund					| Sep 2018		| Updated to call sub-function dbo.fRegistrationYear#Label

Comments	
--------
This function is used to return a registration year label based on the default Registration Schedule established in the 
configuration.   It is used, for example, to determine which registration year an invoice is generated in. If the registration
year crosses a calendar year end, then 9 digits are returned - e.g. "2019/2020" - otherwise 4 digits are returned in the string.

Another function - dbo.fRegistrationYear#Label - is called by this function to produce the label based on the registration
year derived from the event time. 

Example
-------
<TestHarness>
	<Test Name="Random" IsDefault="True"  Description="Executes function for an event time selected at random">
		<SQLScript>
			<![CDATA[
declare @eventTime datetime;

select top (1)
	@eventTime = dateadd(minute, 10000, rsy.YearStartTime)
from
	dbo.RegistrationScheduleYear rsy
order by
	newid();

select @eventTime	 EventTime, dbo.fRegistrationYearLabel(@eventTime) RegistrationYearLabel;
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fRegistrationYearLabel'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin
	declare @registrationYearLabel varchar(9); -- return value; 

	if @EventTime is not null
	begin
		set @registrationYearLabel = dbo.fRegistrationYear#Label(dbo.fRegistrationYear(@EventTime));
	end;

	return (@registrationYearLabel);
end;
GO
