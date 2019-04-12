SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vAnnouncement#TagDetail]
as
/*********************************************************************************************************************************
View    : Announcement Tag Detail
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Parses tag values from TagList column as individual rows for searching; returns 1 row if no tags
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-----------------------------------------------------------------------------------------
				: Cory Ng     | Sep		2017  |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This view is used in search procedures to support searching by tile and note values, as well as tag names which have been
entered into the TagList column of the record.  If a record has no tags assigned, a row is still returned including the other
search columns. 

Example
-------
!<TestHarness>
<Test Name = "SelectAll" Description="Selects all records from the view.">
<SQLScript>
<![CDATA[
		select 
			 td.*
		from
			sf.vAnnouncement#TagDetail td
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:03" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vAnnouncement#TagDetail'

------------------------------------------------------------------------------------------------------------------------------- */

select
	a.AnnouncementSID
 ,a.Title
 ,a.IsActive
 ,Tag.t.value( '@Name'
							,'nvarchar(50)'
						 ) Tag
 ,a.UpdateUser
 ,a.UpdateTime
from
	sf.vAnnouncement			a
outer apply 
  a.TagList.nodes('//Tag') Tag(t);
GO
