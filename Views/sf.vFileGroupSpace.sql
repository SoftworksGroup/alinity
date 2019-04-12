SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vFileGroupSpace]
as
/*********************************************************************************************************************************
View    : File Group Space
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns details of file groups and space allocated, used and remaining in them
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | May 2017		|	Initial version
				: Tim Edlund					| Aug 2018		| Implemented override for PRIMARY file group name and calculations for filestream
---------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 through SQL 2014. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns details of space usage in file groups.  Typically each file group is assigned 2 or more files.  The space 
available for data is calculated as the space remaining in the set of files.  The view is intended for use in monitoring space 
available for data growth on a database.  Note that because a file group may have growth remaining for its files before hitting
the maximum allocation does not mean the space is available on disk.  The available disk space must also be checked to ensure 
file expansion is possible.

The Softworks standard for file sizing is NOT to allow unrestricted growth in files.  Where unrestricted growth is enabled on a 
file no information is returned on allocated size and percentage utilization.

Compatibility with other SQL Server versions
--------------------------------------------
This object references "sys" (system) views because of complexities in referencing system functions - like object_id() - in 
deployments for target databases.  Microsoft does not guarantee that sys view definitions will be compatible in SQL Server 
upgrades.  This view may not deploy successfully on databases other than the database version identified above.

Example
-------
<TestHarness>
<Test Name = "Select" Description="Select all records from the view.">
<SQLScript>
<![CDATA[
select 
	* 
from 
	sf.vFileGroupSpace 
order by 
	1
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:03" />
</Assertions>
</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.vFileGroupSpace'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

select
	x.DataSpaceID
 ,replace(sf.fObjectNameSpaced(x.[FileGroup]), ' )', ')') [FileGroup]
 ,x.SpaceAllocated
 ,(case when x.UsedSpace is null or x.UsedSpace = 0 then x.CurrentSpaceAllocated else x.UsedSpace end)											UsedSpace
 ,(x.SpaceAllocated - (case when x.UsedSpace is null or x.UsedSpace = 0 then x.CurrentSpaceAllocated else x.UsedSpace end)) AvailableSpace
 ,cast(round(
							(x.SpaceAllocated - (case when x.UsedSpace is null or x.UsedSpace = 0 then x.CurrentSpaceAllocated else x.UsedSpace end)) / x.SpaceAllocated
							* 100.0
						 ,1
						) as decimal(4, 1))																																															PercentAvailable
from
(
	select
		fs.[FileGroup]
	 ,fs.DataSpaceID
	 ,sum(fs.MaxFileSize)			SpaceAllocated
	 ,sum(fs.CurrentFileSize) CurrentSpaceAllocated
	 ,sum(fs.UsedSpace)				UsedSpace
	 ,sum(fs.AvailableSpace)	AvailableSpace
	from
		sf.vFileSpace fs
	group by
		fs.DataSpaceID
	 ,fs.[FileGroup]
) x;
GO
