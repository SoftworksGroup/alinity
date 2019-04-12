SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantAudit#TimeToSubmitByAge
(
	@RegistrationYear smallint	-- the registration year to include in the analysis
 ,@AuditType				int				-- the audit type to analyze results
)
returns table
/*********************************************************************************************************************************
Function: Registrant Audit - Time to Submit (form) by Age
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns reporting/statistical data on the amount of time individuals require to submit their audit forms by age range
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Gunjan P  	| Feb 2018			|	Initial Version
				: Tim Edlund	| Jul 2018			| Updated to apply dbo.AgeRange table rather than hard-coded view 
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function supports reporting routines on the audit process.  It returns one row for each time band (in minutes) and age range
(registrant age in years) measuring the duration for audit form completion.  The analysis measures the gap in time between the 
form creation time and the time the first "SUBMIT" status was recorded.  Where an individual saves their form and submits on 
another day, the form is put into a "multiple-day" category. The query uses the same general components as the Audit Management 
dashboard screen.

Limitation
----------
End users cannot adjust the time or age ranges.  They are fixed as a derived table within this procedure.

Example
-------
<TestHarness>
  <Test Name = "RandomSelect" IsDefault ="true" Description="Executes the function to return records at random.">
    <SQLScript>
      <![CDATA[
declare
	@registrationYear					 smallint
  ,@auditType                 int 
 
	
select top (100)
	@registrationYear	 = max(rl.RegistrationYear)
from
	dbo.Registration rl
order by
	newid()

select top (1)
	@auditType	 = atp.AuditTypeSID
from
	dbo.AuditType atp
where
	atp.IsActive = 1
order by
	atp.AuditTypeSID;

select
	x.AgeRange
 ,x.TimeBand
 ,x.FormCount
 ,x.AgeRangeDisplayOrder
 ,x.TimeBandDisplayOrder
from
	dbo.fRegistrantAudit#TimeToSubmitByAge(@registrationYear, @auditType) x
order by
	x.AgeRangeDisplayOrder
 ,x.TimeBandDisplayOrder;

if @@rowcount = 0 raiserror( N'* ERROR: no data found for test case', 18, 1)

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrantAudit#TimeToSubmitByAge'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return select
				 z.TimeBand
				,z.AgeRangeLabel AgeRange
				,z.DisplayOrder	 AgeRangeDisplayOrder
				,z.TimeBandDisplayOrder
				,count(1) FormCount
			 from
				(
					select
						case
							when tb.StartDuration is null and ra.FormCompletionMinutes < 15 then '< 15 Minutes'
							when tb.StartDuration is null and ra.FormCompletionMinutes > 90 then 'Multiple sessions'
							else ltrim(tb.StartDuration) + '-' + ltrim(tb.EndDuration) + ' Minutes'
						end TimeBand
					 ,case
							when tb.StartDuration is null and ra.FormCompletionMinutes < 15 then 1
							when tb.StartDuration is null and ra.FormCompletionMinutes > 90 then 9
							else tb.DisplayOrder
						end TimeBandDisplayOrder
					 ,ar.AgeRangeLabel
					 ,ar.DisplayOrder
					from
					(
						select
							ra.RegistrantAuditSID
						 ,ra.AuditTypeSID
						 ,datediff(minute, ra.CreateTime, ras.CreateTime) FormCompletionMinutes
						 ,sf.fAgeInYears(p.BirthDate, ras.CreateTime)			RegistrantAge
						from
							dbo.RegistrantAudit ra
						join
							dbo.AuditType				atype on ra.AuditTypeSID		 = atype.AuditTypeSID
						join
							dbo.Registrant			r on ra.RegistrantSID				 = r.RegistrantSID
						join
							sf.Person						p on r.PersonSID						 = p.PersonSID
						join
						(
							select
								ras.RegistrantAuditSID
							 ,min(ras.CreateTime) CreateTime
							from
								dbo.RegistrantAuditStatus ras
							join
								sf.FormStatus							fs on ras.FormStatusSID = fs.FormStatusSID and fs.FormStatusSCD = 'SUBMITTED'
							group by
								ras.RegistrantAuditSID
						)											ras on ra.RegistrantAuditSID = ras.RegistrantAuditSID
						where
							ra.RegistrationYear = @RegistrationYear and ra.AuditTypeSID = (case when @AuditType = 0 then ra.AuditTypeSID else @AuditType end)
					)													ra
					left outer join
						dbo.vCompletionTimeBand tb on ra.FormCompletionMinutes between tb.StartDuration and tb.EndDuration
					left outer join
						dbo.vAgeRange						ar on ra.RegistrantAge between ar.StartAge and ar.EndAge and ar.AgeRangeTypeCode = 'CLIENTAGE'
				) z
			 group by
				 z.DisplayOrder
				,z.AgeRangeLabel
				,z.TimeBand
				,z.TimeBandDisplayOrder;
GO
