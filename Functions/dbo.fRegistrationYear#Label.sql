SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrationYear#Label 
(
	@RegistrationYear smallint -- registration year to lookup
)
returns varchar(9)
as
/*********************************************************************************************************************************
ScalarF		: Registration Year - Label
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns 9 digit string show 2 years if the registration year provided is not based on a calendar year
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This function is used to return a registration year label based on a Registration Year passed in.  The label is derived based on
the Registration Schedule established in the configuration.  Another function - dbo.fRegistrationYearLabel - accepts an event
time to produce the same output.  If the registration year crosses a calendar year end, then 9 digits are returned - 
e.g. "2019/2020" - otherwise 4 digits are returned in the string.

Example
-------
<TestHarness>
	<Test Name="Simple" IsDefault="True"  Description="Test the correct label is returned when the calendar year and the registration year match">
		<SQLScript>
			<![CDATA[
						
declare @registrationYear smallint;

select top (1)
	@registrationYear = rsy.RegistrationYear
from
	dbo.RegistrationScheduleYear rsy
order by
	newid();

select
	@registrationYear															 RegistrationYear
 ,dbo.fRegistrationYear#Label(@registrationYear) RegistrationYearLabel;
]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fRegistrationYear#Label'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin
	declare @registrationYearLabel varchar(9); -- return value; 

	if @RegistrationYear is not null
	begin


		select
			@registrationYearLabel = (case
																	when year(rsy.YearStartTime) = year(rsy.YearEndTime) then ltrim(rsy.RegistrationYear)
																	else ltrim(year(rsy.YearStartTime)) + '/' + ltrim(year(rsy.YearEndTime))
																end
															 )
		from
			dbo.RegistrationScheduleYear rsy
		where
			rsy.RegistrationYear = @RegistrationYear;

	end;

	return (@registrationYearLabel);
end;
GO
