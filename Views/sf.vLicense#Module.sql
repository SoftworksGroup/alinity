SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vLicense#Module]
as
/*********************************************************************************************************************************
View    : License Module
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the count of licensed users for each module
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | April 2010    |	Initial Version
				: Tim Edlund	| Dec 2014			| Updated for new license format. Items from the license that are not per-user licenses
				:             |               | are excluded.
				: Kris Dawson | May 2017      | Updated to use actual module name
				: Cory Ng			| Sep 2017			| Wrapped ModuleSCD with isnull to allow it to be added to the EF diagram
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

***** WARNING: TAMPERING WITH THIS VIEW WILL BLOCK ACCESS TO THE APPLICATION FOR ALL USERS *****

This view is used in validating assignment of users to application modules and for the "About" display in the software to report on 
the license.  The view parses the XML in the license record to obtain the count of the users allowed for each module.  

Some modules have specific license counts while other modules are simply enabled or disabled.  For the enabled/disabled modules, the
count of license is set to be the same as the administrative module.  

Testing
-------
Two unit tests are included. The first selects all License Modules and ensures that the result set is not empty, and completes
in less than five seconds. The second test selects the admin License Module, and ensures that the name is not null, number of 
licenses is not empty, and exactly one row is returned, in less than one second.

!<TestHarness>
<Test Name = "SingleLicenseSelect" Description="Select all license records from the view based. Asserts that only 1 license is 
returned.">
<SQLScript>
<![CDATA[
	select 
		 lm.ModuleName
		,lm.TotalLicenses
		,lm.ModuleSCD
	from
		sf.vLicense#Module lm
	
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vLicense#Module'

------------------------------------------------------------------------------------------------------------------------------- */

select
	 isnull(cast(substring(x.ModuleSCD,6,15)as varchar(15)), '~')							ModuleSCD									-- module code for license limit enforcement
	,x.ModuleName
	,case
			when x.TotalLicenses is null and x.IsEnabled = cast(1 as bit) then y.AdminLicenses							-- quantity for user license limit enforcement
			else isnull(x.TotalLicenses,0)																		
	 end																																		TotalLicenses
from
(
select  
	 item.Node.value('@Code[1]', 'varchar(20)')					ModuleSCD
	,item.Node.value('@Name[1]', 'nvarchar(100)')				ModuleName
	,item.Node.value('@Quantity[1]', 'int')							TotalLicenses
	,item.Node.value('@Enabled[1]', 'bit')							IsEnabled
from 
	sf.License l
cross apply
	l.License.nodes('License/Item') item(Node)
) x
cross apply
(
select  
	item.Node.value('@Quantity[1]', 'int')							AdminLicenses
from 
	sf.License l
cross apply
	l.License.nodes('License/Item') item(Node)
where
	item.Node.value('@Code[1]', 'varchar(15)')	 = 'ULIC.ADMIN'		
) y
where
	left(x.ModuleSCD,5) = 'ULIC.'																						-- avoid any items that are not "module" codes
GO
