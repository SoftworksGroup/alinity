SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrationScheduleYear#Month
/*********************************************************************************************************************************
View			: Registration Schedule Year - Month
Notice		: Copyright © 2019 Softworks Group Inc.
Summary		: Returns a list of month information that can be ordered in the sequence of months in the client registration year
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2019		|	Initial version

Comments	
--------
This view is designed primarily to support drop-down lists in member forms where the user must pick starting and ending months
that match the order of months in the organizations registration year.  For example, if the registration year starts April 1st,
the month sequence required is:

Apr
May
Jun
...
Jan
Feb
Mar

This view returns a "MonthSequence" column that can be used to produce the ordering.  The start and ending dates in each 
month are also returned.

Example
-------
<TestHarness>
	<Test Name="One" Description="Returns view content for current registration year.">
		<SQLScript>
			<![CDATA[

select
	x.*
from
	dbo.vRegistrationScheduleYear#Month x
where
	x.registrationyear = dbo.fRegistrationYear#Current()
order by
	x.MonthSequence

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.vRegistrationScheduleYear#Month'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

as
select
	z.RegistrationYear
 ,z.MonthSequence
 ,z.MonthNo
 ,substring('Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ', (z.MonthNo * 4) - 3, 3)									MonthLabel
 ,cast(ltrim(z.RegistrationYear) + right('0' + ltrim(z.MonthNo) + '01', 4) as date)											FirstDayOfMonth
 ,sf.fLastDayOfMonth(cast(ltrim(z.RegistrationYear) + right('0' + ltrim(z.MonthNo) + '01', 4) as date)) LastDayOfMonth
from
(
	select
		x.RegistrationYear
	 ,x.MonthSequence
	 ,(x.YearStartMonth + x.MonthSequence - 1) - (case when x.YearStartMonth + x.MonthSequence - 1 > 12 then 12 else 0 end) MonthNo
	from
	(
		select
			rsy.RegistrationYear
		 ,month(rsy.YearStartTime) YearStartMonth
		 ,m.MonthSequence
		from
			dbo.RegistrationScheduleYear rsy
		cross join
		(
			values (1)
			 ,(2)
			 ,(3)
			 ,(4)
			 ,(5)
			 ,(6)
			 ,(7)
			 ,(8)
			 ,(9)
			 ,(10)
			 ,(11)
			 ,(12)
		)															 m (MonthSequence)
	) x
) z;
GO
