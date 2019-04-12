SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrationYear#Current] ()
returns smallint
as
/*********************************************************************************************************************************
ScalarF		: Registration Year - Current
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns a 4 digit year indicating the current registration year
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Sep	2017		|	Initial version

Comments	
--------
This function is used to return a registration year based on the time in the user timezone.  

Example
-------
<TestHarness>
	<Test Name="Simple" IsDefault="True"  Description="Ensures that the function works correctly">
		<SQLScript>
			<![CDATA[
						
				
				select
					dbo.fRegistrationYear#Current()

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>


exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fRegistrationYear#Current'
 ,@DefaultTestOnly = 1


------------------------------------------------------------------------------------------------------------------------------- */
begin
	declare
		@now							datetime = sf.fNow()	-- current time in user timezone
	 ,@registrationYear smallint;							-- return value

	select
		@registrationYear = rsy.RegistrationYear
	from
		dbo.RegistrationSchedule		 rs
	join
		dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID = rsy.RegistrationScheduleSID
	where
		rs.IsDefault = cast(1 as bit) and @now between rsy.YearStartTime and rsy.YearEndTime;

	return (@registrationYear);
end;
GO
