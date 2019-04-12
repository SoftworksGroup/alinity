SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vApplication#Stat
/*********************************************************************************************************************************
View			: RegistrantApp Stat (Statistics)
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a list of application status codes and labels
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version

Comments	
--------
This view returns a list of application statistic records.  The view is hard-coded and conforms to the codes applied internally by 
the dbo.pRegistration#RegistrantAppStatus$SummaryXML procedure.  The view is designed to support presentation of results from the 
procedure on the user interface (to show 0 totals where no forms are in a given statistics category).

Note that the "OTHER" category is reserved for errors.  No forms should end up in this category but it is included to
preserve balancing to the actual total number of records.  No forms should appear in this category under normal circumstances
as it indicates forms are not in any status/ownership that is expected by the procedure.  If the total of the category is zero, 
the calling procedure eliminates it.

Maintenance Note
----------------
Ensure the codes returned by this view are consistent with codes returned by dbo.pRegistration#RegistrantAppStatus$SummaryXML.

Example
-------
<TestHarness>
	<Test Name="One" Description="Returns view content">
		<SQLScript>
			<![CDATA[

select x.* from dbo.vApplication#Stat x order by x.RegistrantAppStatSID;

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
  @ObjectName = 'dbo.vApplication#Stat'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

as
select
	101						ApplicationStatSID
 ,'In Progress' ApplicationStatLabel
 ,'IN.PROGRESS' ApplicationStatCode
union
select
	102										 ApplicationStatSID
 ,'In Supervisor Review' ApplicationStatLabel
 ,'IN.SUPERVISOR.REVIEW' ApplicationStatCode
union
select
	103								ApplicationStatSID
 ,'In Admin Review' ApplicationStatLabel
 ,'IN.ADMIN.REVIEW' ApplicationStatCode
union
select
	104				 ApplicationStatSID
 ,'Rejected' ApplicationStatLabel
 ,'REJECTED' ApplicationStatCode
union
select
	105				 ApplicationStatSID
 ,'Not Paid' ApplicationStatLabel
 ,'NOT.PAID' ApplicationStatCode
union
select
	106			ApplicationStatSID
 ,'Other' ApplicationStatLabel
 ,'OTHER' ApplicationStatCode
union
select
	107				 ApplicationStatSID
 ,'Complete' ApplicationStatLabel
 ,'COMPLETE' ApplicationStatCode;
GO
