SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantAudit#CompletedByWeek
(
	@RegistrationYear smallint -- the audit year to include in the analysis
)
returns table
/*********************************************************************************************************************************
Function: Registrant Audit - Completed By Week
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns reporting/statistical data on audits which have been completed over time
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ----------- + ------------- + ------------------------------------------------------------------------------------------
				: Tim Edlund	| Jan 2018 			|	Initial Version 
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function supports reporting routines on the audit process.  It returns one row for each register and week-ending date
where audits were completed.

Both the Audit TYPE "SID" and "Label" are returned so that the SID can be used as selection criteria for reports where only
1 type of audit is of interest.

Example
-------
<TestHarness>
  <Test Name = "RandomSelect" IsDefault ="true" Description="Executes the function to return records at random.">
    <SQLScript>
      <![CDATA[

				declare 
					@registrationYear smallint;
				
				select
					@registrationYear = max(ra.RegistrationYear)
				from
					dbo.RegistrantAudit ra
				
				select
					x.*
				 ,@registrationYear RegistrationYear
				from
					dbo.fRegistrantAudit#CompletedByWeek(@registrationYear) x
				order by
					x.AuditTypeLabel
				 ,x.FormCount;

				if @@rowcount = 0
				raiserror(N'* ERROR: no data found for test case', 18, 1);
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrantAudit#CompletedByWeek'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		x.AuditTypeSID
	 ,x.AuditTypeLabel
	 ,x.AuditWeekEndingDate
	 ,count(1) FormCount
	from	(
					select
						ra.AuditTypeSID
					 ,atype.AuditTypeLabel
					 ,cast(dateadd(dd, 7 - datepart(dw, cs.LastStatusChangeTime), cs.LastStatusChangeTime) as date) AuditWeekEndingDate
					from
						dbo.RegistrantAudit																									 ra
					cross apply dbo.fRegistrantAudit#CurrentStatus(ra.RegistrantAuditSID, -1) cs
					join
						dbo.AuditType atype on ra.AuditTypeSID = atype.AuditTypeSID
					where
						ra.RegistrationYear	 = @RegistrationYear -- filter first for registrations in the target year
						and
						(
							cs.FormStatusSCD = 'APPROVED' or cs.FormStatusSCD = 'REJECTED' -- to be considered complete, they must be in one of these statuses
						)
				) x
	group by
		x.AuditTypeSID
	 ,x.AuditTypeLabel
	 ,x.AuditWeekEndingDate
);
GO
