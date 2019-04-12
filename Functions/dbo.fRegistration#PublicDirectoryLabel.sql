SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistration#PublicDirectoryLabel] (@RegistrationSID int)
returns nvarchar(75)
as
/*********************************************************************************************************************************
Function: Registration Label
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns a label for identifying the registration based on the Register and Section
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version

Comments	
--------
This function creates a label for the registration for use on the Public Directory. The label does not include the registrant 
name but is based on the Directory to display the practice section and optionally the section.  For example:  
"Active Practice (International)".  The label begins with the Register label value (the registration type). 
The value within the parentheses is the Section.  The Section is only included if the "IsDisplayedOnLicense" attribute
is set ON on the section.  Also, if the Section label is "[PracticeRegName] Default", then it is excluded.  

If the Section label in this example was "[PracticeRegName] Default", the resulting label would be: "Active Practice".  

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
 ,dbo.fRegistration#PublicDirectoryLabel(rl.RegistrationSID) RegistrationLabel
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
	@ObjectName = 'dbo.fRegistration#PublicDirectoryLabel'
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare @formattedLabel nvarchar(75); -- return value 	 

	if exists
	(
		select
			1
		from
			sf.vRoutine r
		where
			r.SchemaName = 'ext' and r.RoutineName = 'fRegistration#PublicDirectoryLabel'
	)
	begin
		set @formattedLabel = ext.fRegistration#PublicDirectoryLabel(@RegistrationSID);
	end;

	if @formattedLabel is null
	begin

		select
			@formattedLabel = cast(pr.PracticeRegisterLabel -- the registration type
														 + (case
																	when replace(prs.PracticeRegisterSectionLabel, ' ', '') = replace(pr.PracticeRegisterLabel, ' ', '') + 'Default' then ''
																	else (case when prs.IsDisplayedOnLicense = cast(1 as bit) 
																		then ' (' + ltrim(rtrim(replace(prs.PracticeRegisterSectionLabel, pr.PracticeRegisterLabel, ''))) + ')' 
																		else '' end)
																end
															 )  as nvarchar(75)) -- the register Section if not "[PracticeRegName] Default" and IsDisplayedOnLicense is ON
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
