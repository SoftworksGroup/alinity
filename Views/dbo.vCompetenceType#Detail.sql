SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vCompetenceType#Detail]
as
/*********************************************************************************************************************************
View    : Competence Type Detail
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns details related to a competence type
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Russ Poirier| Nov	2018    |	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This view returns details about the competence type. This view is designed to be used on learning plan forms where the
help prompt or attached requirements of the competence type is required. Normally the dbo.vCompetenceType entity view has all 
the values we need to source a form list but because help prompts is a nvarchar(max) column, DBStudio excludes the help prompt 
and attached requirements from being added to the entity view.

Example
-------
!<TestHarness>
<Test Name = "SelectAll" Description="Selects all records from the view.">
<SQLScript>
<![CDATA[
		select 
			cta.*
    from
      dbo.vCompetenceType#Detail cta
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:03" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.vCompetenceType#Detail'
	,	@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

select
	 ctype.CompetenceTypeSID
	,ctype.CompetenceTypeLabel
	,ctype.CompetenceTypeCategory
	,ctype.HelpPrompt
	,ctype.IsDefault
	,ctype.IsActive
	,ctype.UserDefinedColumns
	,ctype.CompetenceTypeXID
	,ctype.LegacyKey
	,ctype.RowGUID
	,ctype.RowStamp
	,stuff((
					select
						'|' + rtrim(lrct.LearningRequirementSID)
					from
						dbo.LearningRequirementCompetenceType lrct
					where
						lrct.CompetenceTypeSID = ctype.CompetenceTypeSID
					for xml path('')
				)
				,1
				,1
				,''
			 )				AttachedRequirements
from
	dbo.CompetenceType      ctype
GO
