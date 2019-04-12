SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vLicense#ModuleStatus]
as
/*********************************************************************************************************************************
View    : License Module Status
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the count of licensed users for each module
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-----------------------------------------------------------------------------------------
				: Tim Edlund  | Apr		2010  |	Initial Version
				: Cory Ng			| Aug		2014	| Updated logic to avoid counting license if user is inactive
				: Tim Edlund	| Apr		2015	| Avoid counting license for JobExec and help desk staff. 
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

***** WARNING: TAMPERING WITH THIS VIEW WILL BLOCK ACCESS TO THE APPLICATION FOR ALL USERS *****

This view is used in validating assignment of users to application modules. The view calculates the number of assignments remaining 
for each module.  The view retrieves the count of license for each module through the license document and then calculates the
number of users assigned to each. 

The design depends on every module identifier value - which appears as "ModuleSCD" in sf.vLicense#Module, also be implemented as a 
"GrantCode" in the ApplicationGrant table.  This is critical to determining the count of licenses since it is the granting of that 
code value to a user that counts as the use of a license.

On "STGDB" Servers Checks License Limits Are Ignored
----------------------------------------------------
The function contains logic to bypass checks on staging and test servers.  As the naming conventions for these types of 
servers is updated, changes to the function are required. Note that this can result in the available license counts on
staging severs, are returned by vLicense#ModuleStatus - to be negative.  This will not occur on production servers.

Maintenance Note (sf.fLicense#IsAvailable has parallel logic)
--------------------------------------------------------------
The logic in this function is nearly the same as that implemented in sf.fLicense#IsAvailable except that this view calculates
the available license count for all modules while the function calculates it for a single module associated with a specific
application grant.  If the logic in this function requires updating, check if the same changes should be made in 
sf.fLicense#IsAvailable.

Example
-------
!<TestHarness>
<Test Name = "BulkSelect" Description="Select all records from the view.">
<SQLScript>
<![CDATA[
		select 
			 ModuleSCD
			,ModuleName
			,TotalLicenses
			,AssignedLicenses
			,RemainingLicenses
		from
			sf.vLicense#ModuleStatus lms
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:01" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vLicense#ModuleStatus'

------------------------------------------------------------------------------------------------------------------------------- */
select
	 isnull(lm.ModuleSCD, '~')													ModuleSCD
	,lm.ModuleName
	,lm.TotalLicenses
	,isnull(al.AssignedLicenses,0)											AssignedLicenses
	,(lm.TotalLicenses - isnull(al.AssignedLicenses,0)) RemainingLicenses
from 
	sf.vLicense#Module				lm
left outer join	
	(
		select
			 x.ModuleSCD
			,count(x.ApplicationUserSID) AssignedLicenses                       -- count the number of users with at least 1 grant to each module - requires a license
		from
		(																																			-- isolate distinct users granted to each module code
			select
				 left(ag.ApplicationGrantSCD,(case charindex('.', ag.ApplicationGrantSCD) when 0 then len(ag.ApplicationGrantSCD) + 1 else charindex('.', ag.ApplicationGrantSCD) end) - 1)  ModuleSCD 
				,au.ApplicationUserSID
			from 
				sf.ApplicationUserGrant aug
			join
				sf.ApplicationGrant     ag     on aug.ApplicationGrantSID = ag.ApplicationGrantSID
			join
				sf.ApplicationUser      au     on aug.ApplicationUserSID = au.ApplicationUserSID
			where
				sf.fIsActive(aug.EffectiveTime, aug.ExpiryTime) = cast(1 as bit)
			and
				au.IsActive = cast(1 as bit)
			and
				au.UserName <> N'JobExec'																					-- do not count built-in system users or members of the help desk team
			and
				right(au.UserName,13) <> '@softworks.ca'
			and
				right(au.UserName,15) <> '@alinityapp.com'
			and
				right(au.UserName,19) <> '@softworksgroup.com'
			group by
				 left(ag.ApplicationGrantSCD,(case charindex('.', ag.ApplicationGrantSCD) when 0 then len(ag.ApplicationGrantSCD) + 1 else charindex('.', ag.ApplicationGrantSCD) end) - 1)
				,au.ApplicationUserSID
		) x
		group by
			x.ModuleSCD
	) al on lm.ModuleSCD = al.ModuleSCD
GO
