SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrant#ByYearAndAge]
(
	@StartingRegistrationYear smallint	-- the first year in the range of registration years to include in the analysis
 ,@EndingRegistrationYear		smallint	-- the last year in the range of registration years to include in the analysis
 ,@PracticeRegisterSID			int				-- the register to analyze results for
)
returns table
/*********************************************************************************************************************************
Function: Registrant By Year and Age
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns reporting/statistical data on the age of the membership for a given practice register within a range of years
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Nov 2017			|	Initial Version
				: Russ Poirier|	Jan	2019			|	Added additional filter for proper AgeRangeTypeCode
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function supports reporting routines on age changes in the membership. It returns one row for each year and age range 
combination.  The values may be visualized as a line or area chart, or with filtering - as a series of pie charts.  The analysis
calculates the age of the registrants at the BEGINNING of the registration year.

Limitation
----------
End users cannot adjust the age ranges.  They are fixed as a hard-coded view within this procedure.  This is done to control
the number of categories that must be visualized in graphing of the data.

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
			 ,z.AgeRange
			 ,z.RegistrationCount
			 ,@practiceRegisterLabel PracticeRegisterLabel
			from
				dbo.fRegistrant#ByYearAndAge(@startingRegistrationYear, @endingRegistrationYear, @practiceRegisterSID) z
			order by
				z.RegistrationYear
			 ,z.DisplayOrder;
			
			if @@rowcount = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
		]]>
 		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fRegistrant#ByYearAndAge'
 ,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
as
return select
					z.RegistrationYear
				,z.AgeRange
				,z.DisplayOrder
				,count(1) RegistrationCount
			 from (
							select
								x.RegistrationYear
							 ,case
									when x.RegistrantAge is null then 'Age Unknown'
									when ab.StartAge is null and x.RegistrantAge < 30 then '< 30 Years'
									when ab.StartAge is null and x.RegistrantAge > 60 then '> 60 Years'
									else ltrim(ab.StartAge) + '-' + ltrim(ab.EndAge) + ' Years'
								end AgeRange
							 ,case
									when x.RegistrantAge is null then 0
									when ab.StartAge is null and x.RegistrantAge < 30 then 1
									when ab.StartAge is null and x.RegistrantAge > 60 then 9
									else ab.DisplayOrder
								end DisplayOrder
							from
							(
								select
									rl.RegistrationYear
								 ,sf.fAgeInYears(p.BirthDate, rl.EffectiveTime) RegistrantAge
								from
									dbo.Registration				rl
								join
									dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
																										 and prs.PracticeRegisterSID	 = @PracticeRegisterSID
								join
									dbo.Registrant							r on rl.RegistrantSID								 = r.RegistrantSID
								join
									sf.Person										p on r.PersonSID										 = p.PersonSID
								where
									rl.RegistrationYear between @StartingRegistrationYear and @EndingRegistrationYear
							)							 x
							left outer join
								dbo.vAgeRange ab on x.RegistrantAge between ab.StartAge and ab.EndAge and ab.AgeRangeTypeCode = 'S!MEMBERAGE'
							where
								x.RegistrantAge is not null
						) z
			 group by
				 z.RegistrationYear
				,z.AgeRange
				,z.DisplayOrder;
GO
