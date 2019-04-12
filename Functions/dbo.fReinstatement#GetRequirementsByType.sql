SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fReinstatement#GetRequirementsByType] 
(
	@ReinstatementSID									int								-- reinstatement to retrieve requirements for
 ,@RegistrationRequirementTypeCode  varchar(20)       -- code of the requirement type, NULL returns all requirements
 ,@IsDeclaration                    bit               -- returns declarations if passed as ON, otherwise returns non-declarations
)
returns table
/*********************************************************************************************************************************
Function: Reinstatement - Get Requirements By Type
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns requirements for the reinstatement based on the type passed
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-----------------------------------------------------------------------------------------------------------
				: Russ Poirier|	Mar 2019		| Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function returns a list of requirements for a specific reinstatement to be used on client-specific forms. Only requirements 
tied to the register change mapping that matches the reinstatement will be returned. 

The column "RequirementResponse" is returned hard-coded to null, this is required for ReadLive DB links to prevent the response from 
being overwritten on each load. The DBLink must include this attribute on the mapping to avoid overwrite: 
OnExistsInResponse="Ignore".

Example
-------
<TestHarness>
	<Test Name="Simple" Description="A basic test of the functionality">
		<SQLScript>
		<![CDATA[
		declare
      @reinstatementSID int

    select
      @reinstatementSID = r.ReinstatementSID
    from
      dbo.Reinstatement r
    order by
      newid()

    select
      *
    from
      dbo.fReinstatement#GetRequirementsByType(@reinstatementSID, 'S!REINSTATEMENT.DEC', 1)

	  ]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.fReinstatement#GetRequirementsByType'
	,	@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		 sf.fAltLanguage#Field(rer.RowGUID, 'RequirementDescription', cast(rer.RequirementDescription as nvarchar(max)), null)		RequirementDescription
		,sf.fAltLanguage#Field(rer.RowGUID, 'RegistrationRequirementLabel', rer.RegistrationRequirementLabel, null)								RegistrationRequirementLabel
		,sf.fAltLanguage#Field(rrt.RowGUID, 'RegistrationRequirementTypeLabel', rrt.RegistrationRequirementTypeLabel, null)				RegistrationRequirementTypeLabel
		,sf.fAltLanguage#Field(rrt.RowGUID, 'RegistrationRequirementTypeCategory', rrt.RegistrationRequirementTypeCategory, null) RegistrationRequirementTypeCategory           
		,cast(null as bit)								                 RequirementResponse
		,prcr.RequirementSequence
		,prcr.RowGUID
	from
		dbo.PracticeRegisterChangeRequirement prcr
	join
		dbo.PracticeRegisterChange prc on prcr.PracticeRegisterChangeSID = prc.PracticeRegisterChangeSID
	join
		dbo.RegistrationRequirement rer on rer.RegistrationRequirementSID = prcr.RegistrationRequirementSID
	join
		dbo.RegistrationRequirementType rrt on rer.RegistrationRequirementTypeSID = rrt.RegistrationRequirementTypeSID
	join 
		dbo.Reinstatement re on prc.PracticeRegisterSectionSID = re.PracticeRegisterSectionSID
  join
    dbo.Registration r on re.RegistrationSID = r.RegistrationSID
  join
    dbo.PracticeRegisterSection prs on r.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID and prs.PracticeRegisterSID = prc.PracticeRegisterSID
	where
		re.ReinstatementSID = @ReinstatementSID
	and
		rrt.RegistrationRequirementTypeCode like 'S!%.DEC'
	and
		rrt.RegistrationRequirementTypeCode = isnull(@RegistrationRequirementTypeCode, rrt.RegistrationRequirementTypeCode)
);
GO
