SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vApplicationUser#Admin
as
/*********************************************************************************************************************************
View    : Application User - Admin
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns application users who are administrators (must be active or have an open task assigned)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This view is applied primarily in task management.  It provides the distinct list of application user who are either sys-admin's 
or have the ADMIN.BASE grant (regular administrators).  The view does not include in-active application user accounts unless
the account has at least one open task.  The view also removes the JobExec, HelpDesk and Support accounts.  The objective is to
return only administrators who are eligible for task-assignment or who have tasks assigned.

Limitations
-----------
Because the grant names used to identify administrators are not generic across applications, this view cannot be located in the
SF schema.

Example
-------
<TestHarness>
  <Test Name = "Default" IsDefault ="true" Description="Execute the view to return all records.">
    <SQLScript>
      <![CDATA[ 
select x.* from dbo.vApplicationUser#Admin x
			]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:30"/>
    </Assertions>
  </Test>  
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.vApplicationUser#Admin'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

select
	au.ApplicationUserSID
 ,au.UserName
 ,p.FirstName
 ,p.CommonName
 ,p.MiddleNames
 ,p.LastName
 ,p.HomePhone
 ,p.MobilePhone
from
(
	select distinct
		aug.ApplicationUserSID
	from
		sf.ApplicationUserGrant aug
	join
		sf.ApplicationGrant			ag on aug.ApplicationGrantSID = ag.ApplicationGrantSID
	where
		ag.ApplicationGrantSCD = 'ADMIN.BASE' or ag.ApplicationGrantSCD = 'ADMIN.SYSADMIN' 
)										 x
left outer join
(
	select distinct
		t.ApplicationUserSID
	from
		sf.Task t
	where
		t.ApplicationUserSID is not null and t.ClosedTime is null
)										 y on x.ApplicationUserSID	= y.ApplicationUserSID
join
	sf.ApplicationUser au on x.ApplicationUserSID = au.ApplicationUserSID
join
	sf.Person					 p on au.PersonSID					= p.PersonSID
where
	(au.IsActive		= cast(1 as bit) or y.ApplicationUserSID is not null)
	and au.UserName <> 'JobExec'
	and au.UserName not like '%@helpdesk'
	and au.UserName not like 'support@%';
GO
