SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrants#ActivePracticeInPeriod$SID]
(
	@ActivePeriodStart datetime -- first day of period to search for active-practice registrations in
 ,@ActivePeriodEnd	 datetime -- last day of period to search for active-practice registrations in
)
returns @ActivePracticeInPeriod table
(
	RegistrantSID					 int not null
 ,ActiveRegistrationSID	 int not null
 ,EndingRegistrationSID	 int null
 ,EndingIsActivePractice bit null
)
/*********************************************************************************************************************************
Function : Registrants - Active Practice in Period
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns all registrants who were in active practice within the time period provided along with ending registration key
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)				| Month Year	| Change Summary
				 : ---------------- + ----------- + --------------------------------------------------------------------------------------
				 : Tim Edlund				| Jul 2018		| Initial version
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This is a helper function used to query active members.  The function returns the primary keys of the registrant and  2
registration records of members who are in active practice at some point in the period identified through the @ActivePeriodStart and
@ActivePeriodEnd parameters. Active practice is determined by the Is-Active-Practice bit column on the associated (dbo)
PracticeRegister record.

The function returns both the key of the registration record that was active in the period, AND, the key of the 
registration record which was in effect at the end of the term.  The 2 values will not be the same if the registrant
was active during the period specified but became inactive before that period ended.

If @ActivePeriodStart and @ActivePeriodEnd values are passed as NULL, the function sets the start date to the beginning of the 
current registration year and sets the end date to the current time.

Example
-------
<TestHarness>
  <Test Name = "DefaultPeriod" IsDefault ="true" Description="Returns registrant keys who have been in active practice in the 
	current year.">
    <SQLScript>
      <![CDATA[
select
	x.RegistrantSID
 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, null) RegistrantLabel
 ,x.ActiveRegistrationSID
 ,x.EndingRegistrationSID
 ,prA.PracticeRegisterLabel																														ActivePracticeRegisterLabel
 ,regA.EffectiveTime																																	ActiveEffectiveTime
 ,regA.ExpiryTime																																			ActiveExpiryTime
 ,prE.PracticeRegisterLabel																														EndingPracticeRegisterLabel
 ,regE.EffectiveTime																																	EndingEffectiveTime
 ,regE.ExpiryTime																																			EndingExpiryTime
from
	dbo.fRegistrants#ActivePracticeInPeriod$SID(null, null) x
join
	dbo.Registrant																					r on x.RegistrantSID										= r.RegistrantSID
join
	sf.Person																								p on r.PersonSID												= p.PersonSID
join
	dbo.Registration																				regA on x.ActiveRegistrationSID					= regA.RegistrationSID
join
	dbo.PracticeRegisterSection															prsA on regA.PracticeRegisterSectionSID = prsA.PracticeRegisterSectionSID
join
	dbo.PracticeRegister																		prA on prsA.PracticeRegisterSID					= prA.PracticeRegisterSID
join
	dbo.Registration																				regE on x.EndingRegistrationSID					= regE.RegistrationSID
join
	dbo.PracticeRegisterSection															prsE on regE.PracticeRegisterSectionSID = prsE.PracticeRegisterSectionSID
join
	dbo.PracticeRegister																		prE on prsE.PracticeRegisterSID					= prE.PracticeRegisterSID
--where
--	prA.PracticeRegisterSID <> prE.PracticeRegisterSID -- to see records WHERE registration changed by end of period
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:25"/>
    </Assertions>
  </Test>
  <Test Name = "FirstHalf" IsDefault ="false" Description="Returns registrant keys who were active in the first 6 months of LAST registration year.">
    <SQLScript>
      <![CDATA[
declare
	@start datetime
 ,@end	 datetime
 ,@registrationYear smallint = (dbo.fRegistrationYear#Current() - 1);

select
	@start = isnull(@start, rsy.YearStartTime)	-- use start of previous registration year
from
	dbo.RegistrationScheduleYear rsy
where
	rsy.RegistrationYear = @registrationYear

set @end = dateadd(month, 6, @start); -- set end to +6 months past start of the registration year
set @end = dateadd(day, -1, @end); -- subtract 1 day to get to end of the 6th month

exec sf.pEffectiveExpiry#Set
	@EffectiveTime = @start output
 ,@ExpiryTime = @end output; -- set to end of day time

select
	x.RegistrantSID
 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, null) RegistrantLabel
 ,x.ActiveRegistrationSID
 ,x.EndingRegistrationSID
 ,prA.PracticeRegisterLabel																														ActivePracticeRegisterLabel
 ,regA.EffectiveTime																																	ActiveEffectiveTime
 ,regA.ExpiryTime																																			ActiveExpiryTime
 ,prE.PracticeRegisterLabel																														EndingPracticeRegisterLabel
 ,regE.EffectiveTime																																	EndingEffectiveTime
 ,regE.ExpiryTime																																			EndingExpiryTime
from
	dbo.fRegistrants#ActivePracticeInPeriod$SID(@start, @end) x
join
	dbo.Registrant																						r on x.RegistrantSID										= r.RegistrantSID
join
	sf.Person																									p on r.PersonSID												= p.PersonSID
join
	dbo.Registration																					regA on x.ActiveRegistrationSID					= regA.RegistrationSID
join
	dbo.PracticeRegisterSection																prsA on regA.PracticeRegisterSectionSID = prsA.PracticeRegisterSectionSID
join
	dbo.PracticeRegister																			prA on prsA.PracticeRegisterSID					= prA.PracticeRegisterSID
join
	dbo.Registration																					regE on x.EndingRegistrationSID					= regE.RegistrationSID
join
	dbo.PracticeRegisterSection																prsE on regE.PracticeRegisterSectionSID = prsE.PracticeRegisterSectionSID
join
	dbo.PracticeRegister																			prE on prsE.PracticeRegisterSID					= prE.PracticeRegisterSID
--where
--	prA.PracticeRegisterSID <> prE.PracticeRegisterSID -- to see records WHERE registration changed by end of period

print @start 
print @end 
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:25"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrants#ActivePracticeInPeriod$SID'
 ,@DefaultTestOnly = 1 
------------------------------------------------------------------------------------------------------------------------------- */
as
begin

	declare
		@ON								bit			= cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@registrationYear smallint

	-- if a start date is not provided set it- to the start of the 
	-- current registration year and set end time to current time

	if @ActivePeriodStart is null or @ActivePeriodEnd is null
	begin
		set @registrationYear = dbo.fRegistrationYear#Current();

		select
			@ActivePeriodStart = isnull(@ActivePeriodStart, rsy.YearStartTime)
		from
			dbo.RegistrationScheduleYear rsy
		where
			rsy.RegistrationYear = @registrationYear;

		set @ActivePeriodEnd = sf.fNow(); -- current time in user timezone

	end;

	insert
		@ActivePracticeInPeriod
	(
		RegistrantSID
	 ,ActiveRegistrationSID
	 ,EndingRegistrationSID
	 ,EndingIsActivePractice
	)
	select
		x.RegistrantSID
	 ,x.RegistrationSID
	 ,z.RegistrationSID
	 ,z.IsActivePractice
	from
	(
		select
			reg.RegistrantSID
		 ,reg.RegistrationSID
		 ,rank() over (partition by
										 reg.RegistrantSID
									 order by
										 reg.EffectiveTime desc
										,reg.RegistrationSID desc
									) LatestRank
		from
			dbo.Registration						reg
		join
			dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
		join
			dbo.PracticeRegister				pr on prs.PracticeRegisterSID					= pr.PracticeRegisterSID and pr.IsActivePractice = @ON -- include only ACTIVE-PRACTICE registrations
		where
			reg.EffectiveTime <= @ActivePeriodEnd and reg.ExpiryTime >= @ActivePeriodStart	-- where the registration was effective within the range of dates (inclusive)
	) x
	cross apply
	(
		select
			reg3.RegistrationSID
		 ,pr.IsActivePractice
		from
		(
			select top (1)
				reg2.RegistrationSID
			from
				dbo.Registration reg2
			where
				reg2.RegistrantSID = x.RegistrantSID and reg2.EffectiveTime <= @ActivePeriodEnd and reg2.ExpiryTime >= @ActivePeriodStart -- isolate latest registration for this member in the period (active or not)
			order by
				reg2.EffectiveTime desc
			 ,reg2.RegistrationSID desc
		)															y
		join
			dbo.Registration						reg3 on y.RegistrationSID							 = reg3.RegistrationSID -- join out to get whether active practice or not
		join
			dbo.PracticeRegisterSection prs on reg3.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
		join
			dbo.PracticeRegister				pr on prs.PracticeRegisterSID					 = pr.PracticeRegisterSID
	) z
	where
		x.LatestRank = 1;

	return;

end;
GO
