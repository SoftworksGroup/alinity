SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vTask#Search
as
/*********************************************************************************************************************************
View    : Task - Target Reference
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns reference text and context for tasks linked to target records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This view is used in searching and displaying details about tasks. When tasks are created for follow-up on other records, the
Row GUID of the target record is stored in the (sf) Task.  This view looks up the target GUID in ALL possible target entities
supported by the application and then displays the name of the target in the "Context" column returned.  The "Reference" column
is returned as the registrant-label where the target record can be linked back to a person, or, shows the organization label or
group label if the target context is an organization or group.  

If no target context has been entered for the task then the Context column is set to "Admin" and the Reference is returned as 
NULL.  If a target row GUID has been entered but not target records is located for it, then "Removed" is returned as the
context.

Limitations
-----------
When Removed is returned, it is possible the target record originally referred to has been deleted from the target table. Because
RowGUID is used rather than a TableSID column, no referential integrity will block deletion of the target row.

Maintenance Note
----------------
Ensure any changes to the values and codes returned in this view are consistent with dbo.vTask#Context

Example
-------
<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Execute the view to return all records.">
    <SQLScript>
      <![CDATA[
declare
  @cutOffDate date = dateadd(day, -90, sf.fToday())
  
select x.* from dbo.vTask#Search x where x.CreateTime > @cutOffDate
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:30"/>
    </Assertions>
  </Test>  
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vTask#Search'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

select
	t.TaskSID
 ,t.TaskTitle
 ,t.TaskDescription
 ,tq.TaskQueueLabel
 ,ts.TaskStatusLabel
 ,t.CreateTime
 ,t.DueDate
 ,t.NextFollowUpDate
 ,t.ClosedTime
 ,ts.IsClosedStatus																																																																													 IsClosed
 ,cast(case when ts.TaskStatusSCD = 'CANCELLED' then 1 else 0 end as bit)																																																		 IsCancelled
 ,datediff(day, x.Today, t.DueDate)																																																																					 DaysDueOrLate
 ,pOwner.FirstName + ' ' + left(pOwner.LastName, 1)																																																													 OwnerName
 ,cast(coalesce(o.OrgLabel, pg.PersonGroupLabel, dbo.fRegistrant#Label(pRef.LastName, pRef.FirstName, pRef.MiddleNames, rRef.RegistrantNo, 'REGISTRATION')) as nvarchar(75)) Reference
 ,ctxt.TaskContextCode
 ,ctxt.TaskContextLabel
 ,ctxt.TaskContextIcon
 ,t.TargetRowGUID
 ,ts.TaskStatusSCD
 ,coalesce(r.PersonSID, p.PersonSID, pgm.PersonSID)																																																													 PersonSID
 ,rRef.RegistrantNo
 ,rRef.RegistrantSID
 ,pOwner.PersonSID																																																																													 OwnerPersonSID
 ,t.TaskQueueSID
 ,t.ApplicationUserSID
 ,rnw.RegistrantRenewalSID
 ,app.RegistrantAppSID
 ,rin.ReinstatementSID
 ,rc.RegistrationChangeSID
 ,pu.ProfileUpdateSID
 ,rlp.RegistrantLearningPlanSID
 ,ra.RegistrantAuditSID
 ,o.OrgSID
 ,pg.PersonGroupSID
 ,pgm.PersonGroupMemberSID
 ,reg.RegistrationSID																																																																												 BaseRegistrationSID
from
	sf.Task									 t
join
	sf.TaskStatus						 ts on t.TaskStatusSID = ts.TaskStatusSID
join
	sf.TaskQueue						 tq on t.TaskQueueSID = tq.TaskQueueSID
cross apply
(select sf.fToday() Today) x
left outer join
	sf.ApplicationUser				 au on t.ApplicationUserSID = au.ApplicationUserSID
left outer join
	sf.Person									 pOwner on au.PersonSID = pOwner.PersonSID
left outer join
	dbo.RegistrantRenewal			 rnw on t.TargetRowGUID = rnw.RowGUID
left outer join
	dbo.RegistrantApp					 app on t.TargetRowGUID = app.RowGUID
left outer join
	dbo.Reinstatement					 rin on t.TargetRowGUID = rin.RowGUID
left outer join
	dbo.RegistrationChange		 rc on t.TargetRowGUID = rc.RowGUID
left outer join
	dbo.ProfileUpdate					 pu on t.TargetRowGUID = pu.RowGUID
left outer join
	dbo.RegistrantLearningPlan rlp on t.TargetRowGUID = rlp.RowGUID
left outer join
	dbo.RegistrantAudit				 ra on t.TargetRowGUID = ra.RowGUID
left outer join
	sf.Person									 p on t.TargetRowGUID = p.RowGUID
left outer join
	dbo.Org										 o on t.TargetRowGUID = o.RowGUID
left outer join
	sf.PersonGroup						 pg on t.TargetRowGUID = pg.RowGUID
left outer join
	sf.PersonGroupMember			 pgm on t.TargetRowGUID = pgm.RowGUID
outer apply
(
	select
		cast(case
					 when t.TargetRowGUID is null then 'ADMIN'
					 when rnw.RowGUID is not null then 'RENEWAL'
					 when app.RowGUID is not null then 'APPLICATION'
					 when rin.RowGUID is not null then 'REINSTATEMENT'
					 when rc.RowGUID is not null then 'REG.CHANGE'
					 when pu.RowGUID is not null then 'PROFILE.UPDATE'
					 when rlp.RowGUID is not null then 'LEARNING.PLAN'
					 when ra.RowGUID is not null then 'AUDIT'
					 when p.RowGUID is not null then 'MEMBER'
					 when o.RowGUID is not null then 'ORGANIZATION'
					 when pg.RowGUID is not null then 'GROUP'
					 else 'REMOVED'
				 end as varchar(15)) TaskContextCode
)														 ctxtCode
left outer join
	dbo.vTask#Context ctxt on ctxtCode.TaskContextCode																																	 = ctxt.TaskContextCode
left outer join
	dbo.Registration	reg on coalesce(rnw.RegistrationSID, app.RegistrationSID, rin.RegistrationSID, rc.RegistrationSID) = reg.RegistrationSID
left outer join
	dbo.Registrant		r on isnull(reg.RegistrantSID, ra.RegistrantSID)																									 = r.RegistrantSID -- link to person through registrant if form-based context
left outer join
	sf.Person					pRef on coalesce(r.PersonSID, p.PersonSID, pgm.PersonSID)																					 = pRef.PersonSID -- otherwise person is linked directly or as group-member
left outer join
	dbo.Registrant		rRef on pRef.PersonSID																																						 = rRef.PersonSID; -- required to get registrant# of reference;
GO
