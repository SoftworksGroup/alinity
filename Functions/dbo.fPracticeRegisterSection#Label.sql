SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fPracticeRegisterSection#Label (@PracticeRegisterSectionSID int)
returns nvarchar(71)
as
/*********************************************************************************************************************************
Function: Registration Label
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns a label for the section that includes the register but may suppress the section based on settings
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This function creates a label for display of the register and section in registrations. Sections can be marked as IsDisplayed = 0
in which case they will not appear as part of the label. The Register label is always included.  The function also checks for the
sequence of <RegisterLabel> + ' Default' and eliminates the word "Default" if the section is the default section for the register.

Limitations
-----------
Unlike dbo.fRegistration#Label() and extension point for this function is NOT provided. 

Example
-------
<TestHarness>
	<Test Name = "Simple" Description="Returns the function result for several records at random.">
	<SQLScript>
	<![CDATA[

select top (10)
	prs.Practic
	eRegisterSectionSID
 ,pr.PracticeRegisterLabel
 ,prs.PracticeRegisterSectionLabel
 ,prs.IsDefault
 ,prs.IsDisplayedOnLicense
 ,dbo.fPracticeRegisterSection#Label(prs.PracticeRegisterSectionSID) PracticeRegisterSectionLabel
from
	dbo.PracticeRegisterSection prs
join
	dbo.PracticeRegister				pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
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
	 @ObjectName			= 'dbo.fPracticeRegisterSection#Label'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare @formattedLabel nvarchar(71); -- return value 	 

	select
		@formattedLabel =
		cast(pr.PracticeRegisterLabel + ' '
				 + (case
							when replace(prs.PracticeRegisterSectionLabel, ' ', '') = replace(pr.PracticeRegisterLabel, ' ', '') + 'Default' then ''
							else
		(case
			 when prs.IsDisplayedOnLicense = cast(1 as bit) then ' (' + ltrim(rtrim(replace(prs.PracticeRegisterSectionLabel, pr.PracticeRegisterLabel, ''))) + ')'
			 else ''
		 end
		)
						end
					 ) as nvarchar(71))
	from
		dbo.PracticeRegisterSection prs
	join
		dbo.PracticeRegister				pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
	where
		prs.PracticeRegisterSectionSID = @PracticeRegisterSectionSID;

	return ltrim(rtrim((@formattedLabel)));

end;
GO
