SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vCompetenceTypeActivity#Detail]
as
/*********************************************************************************************************************************
View    : Competence Type Activity Detail
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns details related to a competence type activity
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Cory Ng     | Jan	2018    |	Initial Version
				: Russ Poirier|	Nov 2018		| Added requirements stuff for form logic
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This view returns details about the competence type activity. This view is designed to be used on learning plan forms where the
help prompt of either the competence type or activity is required. Normally the dbo.vCompetenceTypeActivity entity view has all 
the values we need to source a form list but because help prompts is a nvarchar(max) column, DBStudio excludes the help prompt 
from being added to the entity view.

Example
-------
!<TestHarness>
<Test Name = "SelectAll" Description="Selects all records from the view.">
<SQLScript>
<![CDATA[
		select 
			cta.*
    from
      dbo.vCompetenceTypeActivity#Detail cta
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:03" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.vCompetenceTypeActivity#Detail'

------------------------------------------------------------------------------------------------------------------------------- */

select
	cta.CompetenceTypeActivitySID
 ,cta.CompetenceTypeSID
 ,cta.CompetenceActivitySID
 ,ct.CompetenceTypeLabel
 ,ca.CompetenceActivityLabel
 ,ca.CompetenceActivityName
 ,ca.UnitValue
 ,cta.EffectiveTime
 ,cta.ExpiryTime
 ,cta.CompetenceTypeActivityXID
 ,ct.HelpPrompt CompetenceTypeHelpPrompt
 ,ca.HelpPrompt CompetenceActivityHelpPrompt
 ,case
		when ca.IsActive = cast(0 as bit) or ct.IsActive = cast(0 as bit) then cast(0 as bit)
		else sf.fIsActive(cta.EffectiveTime, cta.ExpiryTime)
	end						IsActive
 ,stuff((
					select
						'|' + rtrim(lrct.LearningRequirementSID)
					from
						dbo.LearningRequirementCompetenceType lrct
					where
						lrct.CompetenceTypeSID = ct.CompetenceTypeSID
					for xml path('')
				)
				,1
				,1
				,''
			 )				AttachedRequirements
from
	dbo.CompetenceTypeActivity cta
join
	dbo.CompetenceActivity		 ca on cta.CompetenceActivitySID = ca.CompetenceActivitySID
join
	dbo.CompetenceType				 ct on cta.CompetenceTypeSID		 = ct.CompetenceTypeSID
GO
