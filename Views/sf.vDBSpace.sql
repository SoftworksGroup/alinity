SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW sf.vDBSpace
as
/*********************************************************************************************************************************
View    : Database Space
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Summarizes space used and available in the current database in 3 simple categories for presenting on UI
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version 

Comments	
--------
This view summarizes details from the sf.vFileGroupSpace view into simplified categories, and 1 category for "free" space, 
for presentation to user. The view will include only 3 categories where standard SGI file groups have been deployed:

	o Base Storage
	o Documents
	o Free

Note that because this view may be used for calculation of disk space charges, the "Log" file group is treated as using only
20% of its maximum capacity. This is because log space usage is dynamic and only rarely (mostly during upgrades) exceeds
20% of available space. 

Maintenance note
----------------
The category labels returned by this view are depended on in the pDBSpace#SummaryXML procedure.  If changes are made,
ensure the procedure is also updated.

Example
-------
!<TestHarness>
<Test Name = "Select" Description="Select all records from the view.">
<SQLScript>
<![CDATA[
select 
	* 
from 
	sf.vDBSpace fs
order by 
	1
	
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:03" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vDBSpace'
------------------------------------------------------------------------------------------------------------------------------- */
select
	z.Category
 ,z.SpaceInMB
 ,cast(round(z.SpaceInMB / 1024.00, 1) as decimal(5, 1)) SpaceInGB
from
(
	select
		x.Category
	 ,sum(x.UsedSpace) SpaceInMB
	from
	(
		select	(case when fgs.FileGroup like 'Document%' then 'Documents' else 'Base Storage' end)					 Category
		 ,round((case when fgs.FileGroup = 'Log' then 0.10 * fgs.SpaceAllocated else fgs.UsedSpace end), -1) UsedSpace
		from
			sf.vFileGroupSpace fgs
	) x
	group by
		x.Category
	union all
	(select
			'Free'																																																			Category
		,round(sum((case when fgs.FileGroup = 'Log' then 0.20 * fgs.AvailableSpace else fgs.AvailableSpace end)), -1) SpaceInMB
	 from
			sf.vFileGroupSpace fgs)
) z;
GO
