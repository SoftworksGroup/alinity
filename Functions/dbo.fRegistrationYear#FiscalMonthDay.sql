SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrationYear#FiscalMonthDay (@MonthDay char(4), @YearStartMonth smallint)
returns smallint
as
/*********************************************************************************************************************************
ScalarF		: Registration Year - Fiscal Month Day
Notice		: Copyright © 2019 Softworks Group Inc.
Summary		: Returns an integer representing the fiscal month and day in a registration year for a date provided in MMDD format
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Jan 2019		|	Initial version

Comments	
--------
This function is used primarily in selection of prorated prices.  In the (dbo) Catalog-Item-Price-Proration prorated prices are
set using the month and day (MMDD) in the registration year where the prorated price should start applying.  If the registration
year begins in March, then January will be the 10th month in that year rather than the first and this sequencing is critical to
determining the price that should apply.  This function simplifies the syntax required in queries to return the month-day as
an integer taking the start of the fiscal year into effect.

For example, if the @YearStartMonth is 4 (April) and the prorated price begins Jan 15th, the value returned will be 
1015 since January is the 10th month in the fiscal year.  This value can then be compared to the current date using the same
logic to determine whether that price should apply yet.

If the @YearStartMonth is passed as NULL, the function will lookup the value in the configuration, however, passing it 
will improve performance of the calling query if many records are scanned.  if @MonthDay is passed as null, then the current
month and day (in the client timezone) is applied as default. 

Example
-------
<TestHarness>
	<Test Name="Simple" IsDefault="True"  Description="Ensures that the function works correctly">
		<SQLScript>
			<![CDATA[
						
select
	dbo.fRegistrationYear#FiscalMonthDay('0515', 4)		 May15AprStart
 ,dbo.fRegistrationYear#FiscalMonthDay('0115', 4)		 Jan15AprStart
 ,month(rsy.YearStartTime)													 YearStartMonth
 ,dbo.fRegistrationYear#FiscalMonthDay('0115', null) Jan15
from
	dbo.RegistrationScheduleYear rsy
where
	rsy.RegistrationYear = dbo.fRegistrationYear#Current();

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fRegistrationYear#FiscalMonthDay'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
		@month					smallint	-- month adjusted for start of fiscal year
	 ,@day						smallint	-- day component (of @MonthDay)
	 ,@currentYear		smallint	-- current registration year
	 ,@fiscalMonthDay smallint; -- return value;

	if @MonthDay is null
	begin
		set @MonthDay = right(convert(varchar(8), sf.fToday(), 112), 4); -- use todays month day if not passed
	end;

	if @YearStartMonth is null -- lookup start of registration year if not passed
	begin

		set @currentYear = dbo.fRegistrationYear#Current();

		select
			@YearStartMonth = month(rsy.YearStartTime)
		from
			dbo.RegistrationScheduleYear rsy
		where
			rsy.RegistrationYear = @currentYear;

	end;

	set @month = cast(left(@MonthDay, 2) as smallint); -- parse out date parts
	set @day = cast(right(@MonthDay, 2) as smallint);

	if @month >= @YearStartMonth
	begin
		set @month = @month - @YearStartMonth + 1;
	end;
	else -- adjust the month to the correct sequence number in the fiscal year
	begin
		set @month = 13 + @month - @YearStartMonth;
	end;

	-- recombine the parts and return as an integer

	set @fiscalMonthDay = cast(ltrim(@month) + right('0' + ltrim(@day), 2) as smallint);

	return (@fiscalMonthDay);

end;
GO
