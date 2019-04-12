SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vExam#Dashboard
/*********************************************************************************************************************************
View			: Exam Dashboard
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a list of exams, per registrant, and the various statuses related to their ability to challenge
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Kris Dawson         | Mar 2019		|	Initial version

Comments	
--------
This view returns a list of exams that are available online currently for each application user with a registrant record. Each
row will contain information about several checks required to be passed before the user can challenge the exam. These checks are:
	- Not exceeding the maximum number of attempts in a 1 year period
	- Not taking an exam before the minimum lag period is passed (0 = no lag)
	- Not having passed the exam in a 1 year period
	- Not having any pending exams
	- Their culture must match the exam culture

This view is intended to be called with the ApplicationUserSID on a where clause to populate a list of exams on the client portal
dashboard.

Example
-------
<TestHarness>
	<Test Name="One" Description="Returns view content">
		<SQLScript>
			<![CDATA[
declare
	@applicationUserSID int;

select top 1 @applicationUserSID = ApplicationUserSID from sf.ApplicationUser order by newid();

select x.* from dbo.vExam#Dashboard x where ApplicationUserSID = @applicationUserSID;

if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.vExam#Dashboard'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
as
select
	 au.ApplicationUserSID
	,e.ExamSID
	,e.ExamName
	,case
		when isnull(re.PassedExams, 0) <> 0 then cast (0 as bit)
		else cast(1 as bit)
	end																				IsPassedExamsOK
	,re.PassedExams
	,case
		when isnull(re.AttemptsWithinYear, 0) >= e.MaxAttemptsPerYear then cast(0 as bit)
		else cast(1 as bit)
	end																				IsMaxAttemptsOK
	,isnull(re.AttemptsWithinYear, 0)					AttemptsWithinYear
	,e.MaxAttemptsPerYear
	,case
		when e.MinLagDaysBetweenAttempts = 0 then cast(1 as bit)
		when cast(sf.fNow() as date) < isnull(dateadd(dd, e.MinLagDaysBetweenAttempts, re.LastAttempt), cast('1980-01-01' as date)) then cast(0 as bit)
		else cast(1 as bit)
	end																				IsMinLagDaysOK
	,re.LastAttempt	
	,e.MinLagDaysBetweenAttempts
	,case
		when isnull(re.PendingExams, 0) = 0 then cast(1 as bit)
		else cast(0 as bit)
	end																				IsPendingOK
	,isnull(re.PendingExams, 0)								PendingExams
	,case
		when e.CultureSID = au.CultureSID then cast(1 as bit)
		else cast(0 as bit)
	end																				IsCultureOK
	,auc.CultureLabel													ApplicationUserCulture
	,ec.CultureLabel													ExamCulture
from
	sf.ApplicationUser au
join
	sf.Culture auc on au.CultureSID = auc.CultureSID
join
	dbo.Registrant r on au.PersonSID = r.PersonSID
join
	(
		select
			 ExamSID
			,ExamName
			,MinLagDaysBetweenAttempts
			,MaxAttemptsPerYear
			,CultureSID
		from
			dbo.Exam
		where
			IsOnlineExam = cast(1 as bit)
		and
			IsEnabledOnPortal = cast(1 as bit)
		and
			sf.fIsActive(EffectiveTime, ExpiryTime) = cast(1 as bit)
	) e on 1 = 1
join
	sf.Culture ec on e.CultureSID = ec.CultureSID
left outer join
	(
		select
			 xre.ExamSID
			,xau.ApplicationUserSID
			,count(1)																													AttemptsWithinYear
			,max(isnull(xre.ExamResultDate, xre.ExamDate))										LastAttempt
			,sum(case when xes.ExamStatusSCD = 'PENDING'then 1 else 0 end)		PendingExams
			,sum(case when xes.ExamStatusSCD = 'PASSED' then 1 else 0 end)		PassedExams
		from
			dbo.RegistrantExam xre
		join
			dbo.ExamStatus xes on xre.ExamStatusSID = xes.ExamStatusSID
		join
			dbo.Registrant xr on xre.RegistrantSID = xr.RegistrantSID
		join
			sf.ApplicationUser xau on xr.PersonSID = xau.PersonSID
		where
			xre.ExamDate >= dateadd(mm, -12, cast(sf.fNow() as date))
		or
			xes.ExamStatusSCD = 'PENDING'
		group by
			xre.ExamSID, xau.ApplicationUserSID
	) re on e.ExamSID = re.ExamSID and au.ApplicationUserSID = re.ApplicationUserSID;
GO
