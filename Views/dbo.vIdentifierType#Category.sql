SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vIdentifierType#Category]
as
/*********************************************************************************************************************************
View    : Identifier Type - Category
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns the list of all identifier type categories
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Russ Poirier| Mar 2019      |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This view returns the a distinct list of all active identifier type categories. These categories are used within profile update
forms when adding other identifiers and allow a 3rd level of grouping for selecting the specific organization.

Example
-------
<TestHarness>
<Test Name = "SelectAll" Description="Selects all records from the view.">
<SQLScript>
<![CDATA[
		select 
			 itc.*
		from
			dbo.vIdentifierType#Category itc
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:02" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vIdentifierType#Category'

------------------------------------------------------------------------------------------------------------------------------- */

select distinct
    it.IdentifierTypeCategory
  , it.IsOtherRegistration
from
  dbo.IdentifierType  it;
GO
