SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrationYearLabel#Current] ()
returns varchar(9)
as
/*********************************************************************************************************************************
ScalarF		: Registration Year Label - Current
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns a 4 or 9 character value indicating the current registration year
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Sep	2017		|	Initial version

Comments	
--------
This function is used to return a registration year label based on the time in the user timezone.   If the registration year
crosses a calendar year end, then 9 digits are returned - e.g. "2019/2020" - otherwise 4 digits are returned in the string.

Example
-------
<TestHarness>
	<Test Name="Simple" IsDefault="True"  Description="Ensures that the function works correctly">
		<SQLScript>
			<![CDATA[
						
				
				select
					dbo.fRegistrationYearLabel#Current()

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

------------------------------------------------------------------------------------------------------------------------------- */
begin
	declare
		@now									 datetime = sf.fNow() -- current time in user timezone
	 ,@registrationYear			 smallint							-- year to lookup label for
	 ,@registrationYearLabel varchar(9);					-- return value

	set @registrationYear = dbo.fRegistrationYear#Current();

	if @registrationYear is not null
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
			rsy.RegistrationYear = @registrationYear;

	end;

	return (@registrationYearLabel);
end;
GO
