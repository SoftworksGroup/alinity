SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vPersonGroup#TagSummary]
as
/*********************************************************************************************************************************
View    : Person Group Tag Summary
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Parses tag values from TagList to provide a unique list of tags to assign or search
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Jun		2017  |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This view is used in data entry and search procedures to show the user the tags which have already been assigned.  It returns
one row for each unique tag assigned on "ACTIVE" records, along with the count of records using that tag.  A system ID (SID)
column is generated for each record returned so that the view can be used as selection criteria on drop-down lists for reports.

Example
-------
!<TestHarness>
<Test Name = "SelectAll" Description="Selects all records from the view.">
<SQLScript>
<![CDATA[
		select 
			 ts.*
		from
			sf.vPersonGroup#TagSummary ts
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:03" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vPersonGroup#TagSummary'
------------------------------------------------------------------------------------------------------------------------------- */

select
	row_number() over (order by t.Tag) TagSID
 ,isnull(t.Tag, '~')								 Tag
 ,count(1)													 TagCount
from
(
	select
		Tag.t.value('@Name', 'nvarchar(50)') Tag
	from
		sf.PersonGroup											pg
	cross apply pg.TagList.nodes('//Tag') Tag(t)
	where
		pg.IsActive = cast(1 as bit)
) t
group by
	t.Tag;
GO
