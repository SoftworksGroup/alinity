SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrant#ByYearAndGender
(
	@StartingRegistrationYear smallint	-- the first year in the range of registration years to include in the analysis
 ,@EndingRegistrationYear		smallint	-- the last year in the range of registration years to include in the analysis
 ,@PracticeRegisterSID			int				-- the register to analyze results for
)
returns table
/*********************************************************************************************************************************
Function: Registrant By Year and Gender
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns reporting/statistical data on the gender of the membership for a given practice register within a range of years
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Dec 2017			|	Initial Version 
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function supports reporting routines on gender changes in the membership. It returns one row for each year and gender  
combination.  The values may be visualized as a line or area chart, or with filtering - as a series of pie charts.  The analysis
uses the current (latest) gender setting for each registrant.

Limitation
----------
End users cannot adjust the gender selections available in the application.  These are set in the system table sf.Gender.


Example
-------
<TestHarness>
	<Test Name="All" Description="Returns all records.">
		<SQLScript>
			<![CDATA[
				
				declare
					@endingRegistrationYear		smallint = sf.fTodayYear()
				 ,@startingRegistrationYear smallint
				 ,@practiceRegisterSID			int
				 ,@practiceRegisterLabel		nvarchar(35);
				
				select top (1)
					@practiceRegisterSID	 = pr.PracticeRegisterSID
				 ,@practiceRegisterLabel = pr.PracticeRegisterLabel
				from
					dbo.PracticeRegister pr
				where
					pr.IsRenewalEnabled = 1 and pr.IsActivePractice = 1 and pr.IsActive = 1
				order by
					pr.PracticeRegisterSID;
				
				set @startingRegistrationYear = @endingRegistrationYear - 15;
				
				select
					z.RegistrationYear
				 ,z.GenderLabel
				 ,z.RegistrationCount
				 ,@practiceRegisterLabel PracticeRegisterLabel
				from
					dbo.fRegistrant#ByYearAndGender(@startingRegistrationYear, @endingRegistrationYear, @practiceRegisterSID) z
				order by
					z.RegistrationYear
				 ,z.RegistrationCount desc
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrant#ByYearAndGender'
 ,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
as
return select
					x.RegistrationYear
				,g.GenderLabel
				,count(1) RegistrationCount
			 from
				(
					select
						rl.RegistrationYear
					 ,p.GenderSID
					from
						dbo.Registration				rl
					join
						dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID and prs.PracticeRegisterSID = @PracticeRegisterSID
					join
						dbo.Registrant							r on rl.RegistrantSID								 = r.RegistrantSID
					join
						sf.Person										p on r.PersonSID										 = p.PersonSID
					where
						rl.RegistrationYear between @StartingRegistrationYear and @EndingRegistrationYear
				)					 x
			 join
				 sf.Gender g on x.GenderSID = g.GenderSID
			 group by
				 x.RegistrationYear
				,g.GenderLabel;
GO
