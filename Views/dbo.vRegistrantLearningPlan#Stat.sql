SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantLearningPlan#Stat
/*********************************************************************************************************************************
View			: Learning Plan Stat (Statistics)
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a list of learning plan status codes and labels
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This view returns a list of learning plan statistic records. The view is hard-coded and conforms to the codes applied internally by 
the dbo.pRegistration#RegistrantLearningPlanStatus$SummaryXML procedure.  The view is designed to support presentation of results from the 
procedure on the user interface (to show 0 totals where no forms are in a given statistics category).

Note that the "OTHER" category is reserved for errors.  No forms should end up in this category but it is included to
preserve balancing to the actual total number of records.  No forms should appear in this category under normal circumstances
as it indicates forms are not in any status/ownership that is expected by the procedure.  If the total of the category is zero, 
the calling procedure eliminates it.

Maintenance Note
----------------
Ensure the codes returned by this view are consistent with codes returned by dbo.pRegistration#RegistrantLearningPlanStatus$SummaryXML.

Example
-------
<TestHarness>
	<Test Name="One" Description="Returns view content">
		<SQLScript>
			<![CDATA[

select x.* from dbo.vRegistrantLearningPlan#Stat x order by x.RegistrantLearningPlanStatSID;

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
  @ObjectName = 'dbo.vRegistrantLearningPlan#Stat'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

as
select
	101						RegistrantLearningPlanStatSID
 ,'In Progress' RegistrantLearningPlanStatLabel
 ,'IN.PROGRESS' RegistrantLearningPlanStatCode
union
select
	102								RegistrantLearningPlanStatSID
 ,'In Admin Review' RegistrantLearningPlanStatLabel
 ,'IN.ADMIN.REVIEW' RegistrantLearningPlanStatCode
union
select
	103				 RegistrantLearningPlanStatSID
 ,'Rejected' RegistrantLearningPlanStatLabel
 ,'REJECTED' RegistrantLearningPlanStatCode
union
select 104 RegistrantLearningPlanStatSID , 'Other' RegistrantLearningPlanStatLabel, 'OTHER' RegistrantLearningPlanStatCode
union
select
	105			 RegistrantLearningPlanStatSID
 ,'Complete' RegistrantLearningPlanStatLabel
 ,'COMPLETE' RegistrantLearningPlanStatCode;
GO
