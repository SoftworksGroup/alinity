SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrant#PracticeHoursByYear]
(
	@RegistrantSID					int = null														-- system ID for the member
 ,@PersonSID							int = null														-- alternate ID used to look up the member
 ,@RegistrationYearEnding smallint = null												-- the ending registration year (defaults to current year)
)
returns @PracticeHours table
(
	RegistrationYear				 smallint			not null	-- registration year
 ,RegistrationYearLabel		 varchar(10)	not null	-- registration year label (eg: 2017/2018)
 ,TotalHours							 int					not null	-- total hours for the registration year
 ,OtherJurisdictionHours	 int					not null	-- total other jurisdiction hours for the registration year
)
as
/*********************************************************************************************************************************
Function: Registrant - Practice hours by year
Notice  : Copyright © 2019 Softworks Group Inc.
Detail	: Returns the practice hours per year for the member based on the practice hour requirement interval
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Detail
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Cory Ng			| Feb 2019			|	Initial Version
				: Cory Ng			| Mar 2019			| Return other jurisdiction hours if its to be included in the requirement calculation
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used to support display of the members total practice hours as it related to the regulatory bodies practice hour
requirement. A row is returned for each year that would count towards the requirement as if it is ending in the passed parameter
@RegistrationYearEnding. 

The number of years returned is determined by the config param "PracticeHourInterval" (eg: Assuming the current year is 2019 
setting this to 3 would return 2017, 2018 and 2019). In the case where the practice hour requirement isn't rolling but matches the 
CCP cycle, this value would be set to -1 in which case it will look for a non-withdrawn/rejected learning plan that contains the 
ending year passed and return the years for that cycle.

Example
-------
<TestHarness>
	<Test Name="Simple" Description="A basic test of the functionality">
		<SQLScript>
		<![CDATA[

		declare
			 @registrantSID int
			,@registrationYear smallint

		select top 1
			 @registrantSID = re.RegistrantSID
			,@registrationYear = re.RegistrationYear
		from
			dbo.RegistrantEmployment re
		order by
			newid()

		select
			*
		from
			dbo.fRegistrant#PracticeHoursByYear(@RegistrantSID, null, @RegistrationYear) rph
	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName				= 'dbo.fRegistrant#PracticeHoursByYear'
	,	@DefaultTestOnly	=	1

------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
		@practiceHourInterval								int					
	 ,@registrationYearStart							smallint
	 ,@otherJurisdictionHoursIncluded			bit
	 ,@ON																	bit = cast(1 as bit)

	if @RegistrantSID is null and @PersonSID is not null
	begin

		select
			@RegistrantSID = r.RegistrantSID
		from
			dbo.Registrant r
		where
			r.PersonSID = @PersonSID

	end

	if @RegistrationYearEnding is null
	begin
		set @RegistrationYearEnding = dbo.fRegistrationYear#Current()
	end

	set @practiceHourInterval = isnull(convert(smallint, sf.fConfigParam#Value('PracticeHourInterval')), 1)
	set @otherJurisdictionHoursIncluded = isnull(convert(bit, sf.fConfigParam#Value('OtherJurisHoursIncluded')), 1)

	if @practiceHourInterval = -1
	begin

		select
				@registrationYearStart = rlp.RegistrationYear
			 ,@RegistrationYearEnding = (rlp.RegistrationYear + lm.CycleLengthYears - 1)
		from
			dbo.RegistrantLearningPlan rlp
		join
			dbo.LearningModel lm on rlp.LearningModelSID = lm.LearningModelSID
		cross apply
			dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
		where
			rlp.RegistrantSID = @RegistrantSID
		and
			cs.FormStatusSCD not in ('REJECTED', 'WITHDRAWN', 'DISCONTINUED')
		and
			@RegistrationYearEnding = (rlp.RegistrationYear + lm.CycleLengthYears - 1)

	end
	else
	begin
		set @registrationYearStart = @RegistrationYearEnding - (@practiceHourInterval - 1)
	end

	if @registrationYearStart is not null
	begin

		insert
			@PracticeHours
		(
			RegistrationYear
		 ,RegistrationYearLabel
		 ,TotalHours
		 ,OtherJurisdictionHours
		)
		select
			 rsy.RegistrationYear
			,rsy.RegistrationYearLabel
			,case when isnull(re.TotalHours, 0) = 0
					then isnull(rp.TotalPracticeHours, 0)
					else re.TotalHours
				end + isnull(rp.OtherJurisdictionHours, 0)
			,isnull(rp.OtherJurisdictionHours, 0)
		from
			dbo.vRegistrationScheduleYear rsy
		left outer join
			(
				 select
					 re.RegistrationYear
					,re.TotalPracticeHours
					,case when @otherJurisdictionHoursIncluded = @ON then re.OtherJurisdictionHours else 0 end OtherJurisdictionHours
				from
					dbo.RegistrantPractice re
				where
					re.RegistrantSID = @RegistrantSID
				) rp on rsy.RegistrationYear = rp.RegistrationYear
		left outer join
			(
				select
					 re.RegistrationYear
					,sum(re.PracticeHours) TotalHours
				from
					dbo.RegistrantEmployment re
				where
					re.RegistrantSID = @RegistrantSID
				group by
					 re.RegistrationYear
			) re on rsy.RegistrationYear = re.RegistrationYear
		where
			rsy.RegistrationYear between @registrationYearStart and @RegistrationYearEnding;

	end

	return;

end;
GO
