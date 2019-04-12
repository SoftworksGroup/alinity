SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRenewal#Stat
/*********************************************************************************************************************************
View			: Renewal Stat (Statistics)
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a list of renewal status codes and labels
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Sep 2018		|	Initial version
				: Tim Edlund					| Jan 2019		| Added new categories to support reconciliation of totals with queries

Comments	
--------
This view returns a list of renewal statistic records.  The view is hard-coded and conforms to the codes applied internally by 
the dbo.pRegistration#RenewalStatus$SummaryXML procedure.  The view is designed to support presentation of results from the 
procedure on the user interface (to show 0 totals where no forms are in a given statistics category).

Note that the "OTHER" category is reserved for errors.  No forms should end up in this category but it is included to
preserve balancing to the actual total number of records.  No forms should appear in this category under normal circumstances
as it indicates forms are not in any status/ownership that is expected by the procedure.  If the total of the category is zero, 
the calling procedure eliminates it.

Maintenance Note
----------------
Ensure the codes returned by this view are consistent with codes returned by dbo.pRegistration#RenewalStatus$SummaryXML.

Example
-------
<TestHarness>
	<Test Name="One" Description="Returns view content">
		<SQLScript>
			<![CDATA[

select x.* from dbo.vRenewal#Stat x order by x.RenewalStatSID;

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
  @ObjectName = 'dbo.vRenewal#Stat'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */


as
select
	100						RenewalStatSID
 ,'Not Started' RenewalStatLabel
 ,'NOT.STARTED' RenewalStatCode
union
select
	101						RenewalStatSID
 ,'In Progress' RenewalStatLabel
 ,'IN.PROGRESS' RenewalStatCode
union
select
	102								RenewalStatSID
 ,'In Admin Review' RenewalStatLabel
 ,'IN.ADMIN.REVIEW' RenewalStatCode
union
select
	103				 RenewalStatSID
 ,'Rejected' RenewalStatLabel
 ,'REJECTED' RenewalStatCode
union
select
	104				 RenewalStatSID
 ,'Not Paid' RenewalStatLabel
 ,'NOT.PAID' RenewalStatCode
union
select 105 RenewalStatSID , 'Other' RenewalStatLabel, 'OTHER' RenewalStatCode
union
select
	106												RenewalStatSID
 ,'Complete: Same Register' RenewalStatLabel
 ,'COMPLETE'								RenewalStatCode
union
select
	107													RenewalStatSID
 ,'Complete: Register Change' RenewalStatLabel
 ,'COMPLETE.REG.CHANGE'				RenewalStatCode
union
select
	108							RenewalStatSID
 ,'Did Not Renew' RenewalStatLabel
 ,'DID.NOT.RENEW' RenewalStatCode;
GO
