SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fAgeInYears]
(			
	 @StartDate			            date                                        -- date to begin measuring age at (e.g. birth date)
	,@EndDate				            date                                        -- date to end measuring age at (e.g. sf.fToday())
)
returns int
as
/*********************************************************************************************************************************
ScalarF	: Age in Years
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: calculates age in years - correcting for scenarios where year-boundaries crossed are not the same as full years
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | May 2012		|	Initial Version
				: Tim Edlund	| Feb	2014		| Corrected error in function for birthdays.  Updated testing section to new standard.
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function calculates the difference in years between 2 dates.  Note that the internal function "datediff" cannot be used
for this since that function counts years by looking for year-boundaries that are crossed.  For example 2014-12-31 and 2015-01-01
are 1 year apart according to datediff. The algorithm applied here uses the day-of-the-year date part to correctly calculate the
age in years.  

Example
-------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Shows 2 examples - first where year boundary is not crossed and the second
				where it is crossed.  In both cases no years or duration have passed so result is zero.">
		<SQLScript>
			<![CDATA[
			
declare
	 @startDate			date
	,@endDate				date
		
set @endDate		= '20120103'
set @startDate	= '20120101'

select
	 @startDate														StartDate													-- no years have passed between the dates
	,@endDate															EndDate
	,datepart(dayofyear, @startDate)			DayOfYearStartDate
	,datepart(dayofyear, @endDate)				DayOfYearEndDate
	,datediff(day, @startDate, @endDate)	AgeInDays
	,datediff(year, @startDate, @endDate) AgeInYearsDateDiff
	,sf.fAgeInYears(@startDate, @endDate)	AgeInYearsFromFcn
	
set @startDate = '20111231'

select																																		-- moving into next calendar year but no elapsed year
	 @startDate														StartDate													-- note how datediff cannot be used for duration!
	,@endDate															EndDate
	,datepart(dayofyear, @startDate)			DayOfYearStartDate
	,datepart(dayofyear, @endDate)				DayOfYearEndDate
	,datediff(day, @startDate, @endDate)	AgeInDays
	,datediff(year, @startDate, @endDate) AgeInYearsDateDiff		
	,sf.fAgeInYears(@startDate, @endDate)	AgeInYearsFromFcn
 
]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="RowCount" ResultSet="2" Value="1" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="7" Value="0"/>
			<Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="7" Value="0"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" ResultSet="1"/>
		</Assertions>
	</Test>
	<Test Name="Birthdays" Description="First data set shows the year span on birthdays using January 6th as that date.  The 
				second example shows the person being born on Febuary 29th - leap year - so their birthday is March 1st in non-leap years.">
		<SQLScript>
			<![CDATA[
			
declare
	 @startDate			date
	,@endDate				date

set @startDate = '19600106'
set @endDate = '20140106'

select
	 @startDate														StartDate													-- this example is a birthday - adjust by 1 day 
	,@endDate															EndDate														-- since we are 1 year older ON our birthdays
	,datepart(dayofyear, @startDate)			DayOfYearStartDate
	,datepart(dayofyear, @endDate)				DayOfYearEndDate
	,datediff(day, @startDate, @endDate)	AgeInDays
	,datediff(year, @startDate, @endDate) AgeInYearsDateDiff		
	,sf.fAgeInYears(@startDate, @endDate)	AgeInYearsFromFcn

set @startDate = '19640229'
set @endDate = '20140301'

select
	 @startDate														StartDate													-- shows example of being born on February 29 (leap year)
	,@endDate															EndDate														-- person does not age another year until March 1st
	,datepart(dayofyear, @startDate)			DayOfYearStartDate
	,datepart(dayofyear, @endDate)				DayOfYearEndDate
	,datediff(day, @startDate, @endDate)	AgeInDays
	,datediff(year, @startDate, @endDate) AgeInYearsDateDiff		
	,sf.fAgeInYears(@startDate, @endDate)	AgeInYearsFromFcn
 
]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="RowCount" ResultSet="2" Value="1" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="7" Value="54"/>
			<Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="7" Value="50"/>
			<Assertion Type="ExecutionTime" Value="00:00:01" ResultSet="1"/>
		</Assertions>
	</Test>

</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fAgeInYears'

------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
		@ageInYears		            int                                         -- return value
		
	set @ageInYears = 
	(
		case
			when datepart(dayofyear, @StartDate) = datepart(dayofyear, @EndDate)
				then datediff(year, @StartDate, dateadd(day, 1, @EndDate))
			when datepart(dayofyear, @StartDate) < datepart(dayofyear, @EndDate)
				then datediff(year, @StartDate, @EndDate)
			when datediff(year, @StartDate, dateadd(year, -1, @EndDate)) = -1
				then 0
			else
				datediff(year, @StartDate, dateadd(year, -1, @EndDate))
		 end
		)
		
	return(@ageInYears)	

end
GO
