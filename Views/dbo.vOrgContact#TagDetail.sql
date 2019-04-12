SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vOrgContact#TagDetail]
as
/*********************************************************************************************************************************
View    : Organization Contact Tag Detail
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Parses tag values from TagList column as individual rows for searching; returns 1 row if no tags
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-----------------------------------------------------------------------------------------
				: Tim Edlund  | Jul		2017  |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This view is used optionally in search procedures to support searching by organization contact tags.  For example, if a tag name
for "Technical" or "Billing" contact is defined, then the search from either the Org or Person entity may join to this view to
support searching on those values. If a record has no tags assigned, a row is still returned for it to allow inner joining to
this view. 

Example
-------
!<TestHarness>
<Test Name = "SelectAll" Description="Selects all records from the view.">
<SQLScript>
<![CDATA[
		select 
			 td.*
		from
			dbo.vOrgContact#TagDetail td
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:03" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vOrgContact#TagDetail'

------------------------------------------------------------------------------------------------------------------------------- */
select 
		oc.OrgContactSID
	,	oc.OrgSID
	,	oc.PersonSID
	,	Tag.t.value('@Name', 'nvarchar(50)') Tag
	,	sf.fIsActive(oc.EffectiveTime, oc.ExpiryTime) IsActive
	, oc.UpdateTime
from
	dbo.OrgContact oc
outer apply
	oc.TagList.nodes('//Tag') Tag(t)
GO
