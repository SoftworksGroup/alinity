SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vAnnouncement#TagSummary]
as
/*********************************************************************************************************************************
View    : Announcement Tag Summary
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Parses tag values from TagList to provide a unique list of tags to assign or search
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-----------------------------------------------------------------------------------------
				: Tim Edlund  | Aug		2017  |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This view is used in data entry and search procedures to show the user the tags which have already been assigned.  It returns
one row for each unique tag assigned, along with the count of records using that tag.

Example
-------
!<TestHarness>
<Test Name = "SelectAll" Description="Selects all records from the view.">
<SQLScript>
<![CDATA[
begin transaction;

insert
	sf.Announcement
(
	Title
 ,DocumentContent
 ,EffectiveTime
 ,ExpiryTime
 ,TagList
)
select
	'This is my test'
 ,cast(N'This is my doc content' as varbinary(max))
 ,sf.fToday()
 ,dateadd(day, 1, sf.fToday())
 ,cast(N'<TagList> <Tag Name=''Tag1'' /><Tag Name=''Tag2'' /></TagList>' as xml);

select ts.* from sf.vAnnouncement#TagSummary ts;

if @@rowcount = 0 
begin
	raiserror(N'* ERROR: no sample data found to run test', 18, 1);
end

if @@trancount > 0 rollback;
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:03" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vAnnouncement#TagSummary'

------------------------------------------------------------------------------------------------------------------------------- */

select
	isnull( t.Tag
				 ,'~'
				)	 Tag
 ,count(1) TagCount
from
( select
		Tag.t.value( '@Name'
								,'nvarchar(50)'
							 ) Tag
	from
		sf.Announcement													 o
	cross apply o.TagList.nodes('//Tag') Tag(t)
) t
group by
	t.Tag;
GO
