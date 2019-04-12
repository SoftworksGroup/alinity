SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrationChange#Label (@RegistrationChangeSID int)
returns nvarchar(100)
as
/*********************************************************************************************************************************
Function: Registration Label
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns a label for identifying the registration change based on the FROM and TO Register and Section
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version

Comments	
--------
This function creates a label for the registration change. The label does not include registrant information but is based on the 
register and section for both the "FROM" side of the change and the "TO" side.  

For example:  "Active Practice (International) 2018/2019 -> Associate 2019/2020".  

The label begins with the Register label value (the registration type) on both sides.  The value within the parentheses is the 
Section.  If the Section label is "[PracticeRegName] Default", then it is excluded.  The final component in the label is the 
registration year.   The final component in the label on each side is the registration year.  If the FROM Section label in this 
example was "[PracticeRegName] Default", the resulting label would be: "Active Practice 2018/2019 -> Associate 2019/2020".  

The configuration may include an extended version of the function to return a customized format.  A shell function for
customization exists in the project in the EXT schema and using the same function name.

Example
-------
<TestHarness>
	<Test Name = "Simple" Description="Returns the function result for several records at random.">
	<SQLScript>
	<![CDATA[

select top (10)
	rl.RegistrationChangeSID
 ,pr.PracticeRegisterLabel
 ,prs.PracticeRegisterSectionLabel
 ,rsy.YearStartTime
 ,rsy.YearEndTime
 ,rl.RegistrationYear
 ,dbo.fRegistrationChange#Label(rl.RegistrationChangeSID) RegistrationLabel
from
	dbo.RegistrationChange				 rl
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
	@ObjectName = 'dbo.fRegistrationChange#Label'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare @formattedLabel nvarchar(100); -- return value 	 

	if exists
	(
		select
			1
		from
			sf.vRoutine r
		where
			r.SchemaName = 'ext' and r.RoutineName = 'fRegistrationChange#Label'
	)
	begin
		set @formattedLabel = ext.fRegistrationChange#Label(@RegistrationChangeSID);
	end;

	if @formattedLabel is null
	begin

		select
			@formattedLabel = cast(prFR.PracticeRegisterLabel -- the registration type FROM
														 + (case
																	when replace(prsFR.PracticeRegisterSectionLabel, ' ', '') = replace(prFR.PracticeRegisterLabel, ' ', '') + 'Default' then ''
																	else ' (' + prsFR.PracticeRegisterSectionLabel + ')'
																end
															 ) -- the register Section if not "[PracticeRegName] Default"
														 + N' ' + (case
																				 when year(rsyFR.YearStartTime) = year(rsyFR.YearEndTime) then ltrim(rsyFR.RegistrationYear)
																				 else ltrim(year(rsyFR.YearStartTime)) + '/' + ltrim(year(rsyFR.YearEndTime))
																			 end
																			) + ' -> ' + prTO.PracticeRegisterLabel -- the registration type TO
														 + (case
																	when replace(prsTO.PracticeRegisterSectionLabel, ' ', '') = replace(prTO.PracticeRegisterLabel, ' ', '') + 'Default' then ''
																	else ' (' + prsTO.PracticeRegisterSectionLabel + ')'
																end
															 ) -- the register Section if not "[PracticeRegName] Default"
														 + N' ' + (case
																				 when year(rsyTO.YearStartTime) = year(rsyTO.YearEndTime) then ltrim(rsyTO.RegistrationYear)
																				 else ltrim(year(rsyTO.YearStartTime)) + '/' + ltrim(year(rsyTO.YearEndTime))
																			 end
																			) as nvarchar(100)) -- the registration year label
		from
			dbo.RegistrationChange			 rc
		join
			dbo.Registration				 rlFR on rc.RegistrationSID					= rlFR.RegistrationSID
		join
			dbo.PracticeRegisterSection	 prsFR on rlFR.PracticeRegisterSectionSID = prsFR.PracticeRegisterSectionSID
		join
			dbo.PracticeRegister				 prFR on prsFR.PracticeRegisterSID				= prFR.PracticeRegisterSID
		join
			dbo.RegistrationSchedule		 rsFR on prFR.RegistrationScheduleSID			= rsFR.RegistrationScheduleSID
		join
			dbo.RegistrationScheduleYear rsyFR on rsFR.RegistrationScheduleSID		= rsyFR.RegistrationScheduleSID and rlFR.RegistrationYear = rsyFR.RegistrationYear
		join
			dbo.PracticeRegisterSection	 prsTO on rc.PracticeRegisterSectionSID		= prsTO.PracticeRegisterSectionSID
		join
			dbo.PracticeRegister				 prTO on prsTO.PracticeRegisterSID				= prTO.PracticeRegisterSID
		join
			dbo.RegistrationSchedule		 rsTO on prTO.RegistrationScheduleSID			= rsTO.RegistrationScheduleSID
		join
			dbo.RegistrationScheduleYear rsyTO on rsTO.RegistrationScheduleSID		= rsyTO.RegistrationScheduleSID and rc.RegistrationYear = rsyTO.RegistrationYear
		where
			rc.RegistrationChangeSID = @RegistrationChangeSID;

	end;

	return (@formattedLabel);

end;
GO
