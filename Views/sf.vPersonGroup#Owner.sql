SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vPersonGroup#Owner]
as
/*********************************************************************************************************************************
View    : Person Group Owner
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns a (distinct) list of ACTIVE group owners
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-----------------------------------------------------------------------------------------
				: Tim Edlund  | Jun		2017  |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This view is used in the UI and in reporting to provide a list of group owners of "ACTIVE" groups.  Owners of in-active groups
are not included. 

Example
-------
!<TestHarness>
<Test Name = "SelectAll" Description="Selects all records from the view.">
<SQLScript>
<![CDATA[
		select 
			 x.*
		from
			sf.vPersonGroup#Owner x
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:03" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vPersonGroup#Owner'

------------------------------------------------------------------------------------------------------------------------------- */


select
		pg.ApplicationUserSID																									OwnerApplicationUserSID
	,	sf.fFormatFileAsName(p.LastName, p.FirstName, p.MiddleNames)					OwnerFileAsName
	,	pg.PersonGroupCount
from
(
	select
			pg.ApplicationUserSID
		,	count(1) PersonGroupCount
	from
		sf.PersonGroup pg
	where
		pg.IsActive = cast(1 as bit)
	group by
		pg.ApplicationUserSID
	) pg
join
	sf.ApplicationUser	au	on pg.ApplicationUserSID = au.ApplicationUserSID
join
	sf.Person						p		on au.PersonSID = p.PersonSID
GO
