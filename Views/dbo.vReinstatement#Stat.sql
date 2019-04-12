SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vReinstatement#Stat
/*********************************************************************************************************************************
View			: Reinstatement Stat (Statistics)
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a list of reinstatement status codes and labels
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This view returns a list of reinstatement statistic records.  The view is hard-coded and conforms to the codes applied internally by 
the dbo.pRegistration#ReinstatementStatus$SummaryXML procedure.  The view is designed to support presentation of results from the 
procedure on the user interface (to show 0 totals where no forms are in a given statistics category).

Note that the "OTHER" category is reserved for errors.  No forms should end up in this category but it is included to
preserve balancing to the actual total number of records.  No forms should appear in this category under normal circumstances
as it indicates forms are not in any status/ownership that is expected by the procedure.  If the total of the category is zero, 
the calling procedure eliminates it.

Maintenance Note
----------------
Ensure the codes returned by this view are consistent with codes returned by dbo.pRegistration#ReinstatementStatus$SummaryXML.

Example
-------
<TestHarness>
	<Test Name="One" Description="Returns view content">
		<SQLScript>
			<![CDATA[

select x.* from dbo.vReinstatement#Stat x order by x.ReinstatementStatSID;

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
  @ObjectName = 'dbo.vReinstatement#Stat'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

as
select
	101						ReinstatementStatSID
 ,'In Progress' ReinstatementStatLabel
 ,'IN.PROGRESS' ReinstatementStatCode
union
select
	102										 RegistrantAppStatSID
 ,'In Supervisor Review' RegistrantAppStatLabel
 ,'IN.SUPERVISOR.REVIEW' RegistrantAppStatCode
union
select
	103								ReinstatementStatSID
 ,'In Admin Review' ReinstatementStatLabel
 ,'IN.ADMIN.REVIEW' ReinstatementStatCode
union
select
	104				 ReinstatementStatSID
 ,'Rejected' ReinstatementStatLabel
 ,'REJECTED' ReinstatementStatCode
union
select
	105				 ReinstatementStatSID
 ,'Not Paid' ReinstatementStatLabel
 ,'NOT.PAID' ReinstatementStatCode
union
select 106 ReinstatementStatSID , 'Other' ReinstatementStatLabel, 'OTHER' ReinstatementStatCode
union
select
	107				 ReinstatementStatSID
 ,'Complete' ReinstatementStatLabel
 ,'COMPLETE' ReinstatementStatCode;
GO
