SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vOrg#TagDetail]
as
/*********************************************************************************************************************************
View    : Organization Tag Detail
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Parses tag values from TagList column as individual rows for searching; returns 1 row if no tags
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-----------------------------------------------------------------------------------------
				: Tim Edlund  | Jul		2017  |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This view is used in search procedures to support searching by name and label values, as well as tag names which have been
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
			dbo.vOrg#TagDetail td
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:03" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vOrg#TagDetail'

------------------------------------------------------------------------------------------------------------------------------- */

select 
		o.OrgSID
	,	o.OrgName
	,	o.OrgLabel
	,	dbo.fOrg#FullLabel(o.OrgSID)																					FullOrgLabel							--# Organization label including all parent organizations separated by a dash
	,	Tag.t.value('@Name', 'nvarchar(50)') Tag
	, o.CitySID
	, o.RegionSID
	,	o.IsEmployer
	, o.IsCredentialAuthority
	, o.IsAdminReviewRequired
	, o.IsActive
	, o.UpdateTime
from
	dbo.Org o
outer apply
	o.TagList.nodes('//Tag') Tag(t)
GO
