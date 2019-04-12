SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION sf.fDST#IsActive ()
returns bit
as
/*********************************************************************************************************************************
Function: Daylight Savings Time - Is Active
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns 1 or 0 indicating whether DST is currently in effect based on time in the client time zone
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This function calculates with DST is in effect.  The function uses a standard algorithm for determine the start and ending
dates and times when DST goes into effect. Note that the time for the start of DST is always 3:00am DST time but since the
system won't be in DST time yet, 2:00am is used.  If the procedure to adjust the DST offset is run hourly, and given DST starts 
at 3:00am "DST" time, the system time will jump from 1:59.9999 am directly to 3:00am. 

Example
-------
<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Calls function for current time">
    <SQLScript>
      <![CDATA[
	select sf.fDST#IsActive() IsDSTActiveNow
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:01"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.fDST#IsActive'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@isDSTActive		 bit												-- return value; ON (1) when daylight savings time period is active
	 ,@ON							 bit			= cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@OFF						 bit			= cast(0 as bit)	-- constant for bit comparison = 0
	 ,@now						 datetime = sf.fNow()				-- current time in user time zone	
	 ,@year						 smallint = year(sf.fNow()) -- current year in user time zone
	 ,@startOfMarch		 datetime										-- times to calculate start and end of DST period:
	 ,@startOfNovember datetime
	 ,@dstStart				 datetime
	 ,@dstEnd					 datetime;

	-- calculate the dates and times when DST starts and ends in current year

	set @startOfMarch = dateadd(month, 2, dateadd(year, @year - 1900, 0));
	set @startOfNovember = dateadd(month, 10, dateadd(year, @year - 1900, 0));
	set @dstStart = dateadd(hour, 2, dateadd(day, ((15 - datepart(dw, @startOfMarch)) % 7) + 7, @startOfMarch));
	set @dstEnd = dateadd(hour, 2, dateadd(day, ((8 - datepart(dw, @startOfNovember)) % 7), @startOfNovember));

	-- determine if current time in the range of the DST period

	if @now between @dstStart and @dstEnd -- current time is in the DST period
	begin
		set @isDSTActive = @ON;
	end;
	else -- otherwise not active
	begin
		set @isDSTActive = @OFF;
	end;

	return (@isDSTActive);
end;
GO
