SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistration#Label (@RegistrationSID int)
returns nvarchar(85)
as
/*********************************************************************************************************************************
Function: Registration Label
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns a label for identifying the registration based on the Register, Section and Registration Year
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version

Comments	
--------
This function creates a label for the registration. The label does not include registrant information but is based on the 
register and section.  For example:  "Active Practice (International) 2018/2019 ".  The label begins with the Register 
label value (the registration type).  The value within the parentheses is the Section.  If the Section label is 
"[PracticeRegName] Default", then it is excluded.  If the section label repeats the register name, the duplicate portion
is eliminated.  If the Section label in this example was "[PracticeRegName] Default", the resulting label would be: 
"Active Practice 2018/2019". The final component in the label is the registration year. 

The configuration may include an extended version of the function to return a customized format.  A shell function for
customization exists in the project in the EXT schema and using the same function name.

Example
-------
<TestHarness>
	<Test Name = "Simple" Description="Returns the function result for several records at random.">
	<SQLScript>
	<![CDATA[

select top (10)
	rl.RegistrationSID
 ,pr.PracticeRegisterLabel
 ,prs.PracticeRegisterSectionLabel
 ,rsy.YearStartTime
 ,rsy.YearEndTime
 ,rl.RegistrationYear
 ,dbo.fRegistration#Label(rl.RegistrationSID) RegistrationLabel
from
	dbo.Registration				 rl
join
	dbo.PracticeRegisterSection	 prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
join
	dbo.PracticeRegister				 pr on prs.PracticeRegisterSID				= pr.PracticeRegisterSID
join
	dbo.RegistrationSchedule		 rs on pr.RegistrationScheduleSID			= rs.RegistrationScheduleSID
join
	dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID		= rsy.RegistrationScheduleSID and rl.RegistrationYear = rsy.RegistrationYear
order by
	newid();

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:03" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistration#Label'
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare @formattedLabel nvarchar(85); -- return value 	 

	if exists
	(
		select
			1
		from
			sf.vRoutine r
		where
			r.SchemaName = 'ext' and r.RoutineName = 'fRegistration#Label'
	)
	begin
		set @formattedLabel = ext.fRegistration#Label(@RegistrationSID);
	end;

	if @formattedLabel is null
	begin

		select
			@formattedLabel = cast(case
															 when year(rsy.YearStartTime) = year(rsy.YearEndTime) then ltrim(rsy.RegistrationYear)
															 else ltrim(year(rsy.YearStartTime)) + '/' + ltrim(year(rsy.YearEndTime))
														 end + ' ' + dbo.fPracticeRegisterSection#Label(prs.PracticeRegisterSectionSID) as nvarchar(85))
		from
			dbo.Registration						 rl
		join
			dbo.PracticeRegisterSection	 prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
		join
			dbo.PracticeRegister				 pr on prs.PracticeRegisterSID				= pr.PracticeRegisterSID
		join
			dbo.RegistrationSchedule		 rs on pr.RegistrationScheduleSID			= rs.RegistrationScheduleSID
		join
			dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID		= rsy.RegistrationScheduleSID and rl.RegistrationYear = rsy.RegistrationYear
		where
			rl.RegistrationSID = @RegistrationSID;

	end;

	return (@formattedLabel);

end;
GO
