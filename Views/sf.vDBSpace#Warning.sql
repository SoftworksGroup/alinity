SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW sf.vDBSpace#Warning
as
/*********************************************************************************************************************************
View    : Database Space - Warning
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Checks if disk space is low in any file group and returns Message Text and Message Icon if found (otherwise no records)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Nov 2018		|	Initial version

Comments	
--------
This view is used in statistical displays and login alerts to advise Administrative users if any file groups are low on 
disk space.  Adding disk space or purging records may be required.  If disk space is sufficient and no warning applies, then
NO record is returned.  The view returns 0 or 1 record.  If multiple file groups are below the threshold for a warning
only the file group with the least space is returned.

Example
-------
!<TestHarness>
<Test Name = "Select" Description="Select all records from the view.">
<SQLScript>
<![CDATA[
select 
	* 
from 
	sf.vDBSpace#Warning fs
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
	@ObjectName = 'sf.vDBSpace#Warning'
------------------------------------------------------------------------------------------------------------------------------- */

select
	fgs.FileGroup + ' space is down to ' + ltrim(fgs.PercentAvailable) + '% available (' + format(fgs.AvailableSpace, '###,###')
	+ ' MB). Contact the Help Desk to add more space or purge data.' MessageText
 ,(case
		 when fgs.AvailableSpace < 50 or fgs.PercentAvailable < 5 then 'fa-exclamation-square'
		 else 'fa-exclamation-triangle'
	 end
	)																																 MessageIcon
from
(
	select
		min(fgs.FileGroup) FileGroup
	from
		sf.vFileGroupSpace fgs
	where
		(fgs.AvailableSpace < 100 and round(fgs.PercentAvailable,0) < 15) or (round(fgs.PercentAvailable,0) < 10)
)										 minFG
join
	sf.vFileGroupSpace fgs on minFG.FileGroup = fgs.FileGroup;
GO
