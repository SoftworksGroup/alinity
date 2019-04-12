SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vTask#Context
as
/*********************************************************************************************************************************
View			: Task Context
Notice		: Copyright © 2018 Softworks Group Inc.
Summary		: Returns a list of possible contexts (sf) Task records can be assigned to
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This view is used in the management of Task records. It provides a hard-coded list of possible "contexts", or related entities,
tasks can be associated with.  The list of all possible contexts is defined in the view "dbo.vTask#Search".  Any changes made here 
must be kept in sync with the view.

Maintenance Note
----------------
Ensure any changes to the values and codes returned in this view are consistent with dbo.vTask#SearchCT codes returned by this 
view are consistent with codes returned by dbo.pRegistration#TaskContextus$SummaryXML.

Example
-------
<TestHarness>
	<Test Name="One" Description="Returns view content">
		<SQLScript>
			<![CDATA[

select x.* from dbo.vTask#Context x order by x.TaskContextSID;

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
  @ObjectName = 'dbo.vTask#Context'
 ,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

select
	101											TaskContextSID
 ,'General Admin'					TaskContextLabel
 ,'ADMIN'									TaskContextCode
 ,'fa fa-check'						TaskContextIcon
union
select 
	102											TaskContextSID 
 ,'Renewal'								TaskContextLabel
 ,'RENEWAL'								TaskContextCode
 ,'fa fa-retweet'					TaskContextIcon
union
select
	103											TaskContextSID
 ,'Application'						TaskContextLabel
 ,'APPLICATION'						TaskContextCode
 ,'fa fa-copy'						TaskContextIcon
union
select
	104											TaskContextSID
 ,'Reinstatement'					TaskContextLabel
 ,'REINSTATEMENT'					TaskContextCode
 ,'fa fa-exchange'				TaskContextIcon
union
select
	105											TaskContextSID
 ,'Registration Change'		TaskContextLabel
 ,'REG.CHANGE'						TaskContextCode
 ,'fa fa-arrows-h'				TaskContextIcon
union
select
	106											TaskContextSID
 ,'Profile Update'				TaskContextLabel
 ,'PROFILE.UPDATE'				TaskContextCode
 ,'fa fa-pen-square'			TaskContextIcon
union
select
	107											TaskContextSID
 ,'CE Plan/Report'				TaskContextLabel
 ,'LEARNING.PLAN'					TaskContextCode
 ,'fa fa-graduation-cap'	TaskContextIcon
union
select
	108											TaskContextSID
 ,'Audit'									TaskContextLabel
 ,'AUDIT'									TaskContextCode
 ,'fa fa-check-square'		TaskContextIcon
union
select
	109											TaskContextSID
 ,'Member/Person'					TaskContextLabel
 ,'MEMBER'								TaskContextCode
 ,'fa fa-user'						TaskContextIcon
union
select
	110											TaskContextSID
 ,'Organization'					TaskContextLabel
 ,'ORGANIZATION'					TaskContextCode
 ,'fa fa-building'				TaskContextIcon
union
select 
	111											TaskContextSID 
 ,'Group'									TaskContextLabel
 ,'GROUP'									TaskContextCode
 ,'fa fa-users'						TaskContextIcon
union
select
	999											TaskContextSID
 ,'(Removed)'							TaskContextLabel
 ,'REMOVED'								TaskContextCode
 ,'fa fa-question'				TaskContextIcon;
GO
