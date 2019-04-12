SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vCompetenceType#Category]
as
/*********************************************************************************************************************************
View    : Competence Type - Category
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns the list of all competence type categories
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Cory Ng   	| Jan 2018      |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view returns the a distinct list of all active competence type categories. These categories are used within client specific
continuing competence forms to allow for a 3rd level of grouping when selecting activities.

Example
-------
<TestHarness>
<Test Name = "SelectAll" Description="Selects all records from the view.">
<SQLScript>
<![CDATA[
		select 
			 ctc.*
		from
			dbo.vCompetenceType#Category ctc
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:02" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vCompetenceType#Category'

------------------------------------------------------------------------------------------------------------------------------- */

select
   ct.CompetenceTypeCategory
  ,count(1)                   CompetenceTypeCount
from
  dbo.CompetenceType ct
where
  ct.IsActive = cast(1 as bit)
group by
  ct.CompetenceTypeCategory;
GO
