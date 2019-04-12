SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrantRenewal#GetRequirementsByType] 
(
	@RegistrantRenewalSID	            int								-- renewal to retrieve requirements for
 ,@RegistrationRequirementTypeCode  varchar(20)       -- code of the requirement type, NULL returns all requirements
 ,@IsDeclaration                    bit               -- returns declarations if passed as ON, otherwise returns non-declarations
)
returns table
/*********************************************************************************************************************************
Function: Registrant Renewal - Get Requirements By Type
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns requirements for the renewal based on the type passed
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-----------------------------------------------------------------------------------------------------------
				: Cory Ng   	| Dec 2018		|	Initial Version
				: Cory Ng			| Jan 2019		| Updated for alternate language support
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function returns a list of requirements for a specific renewal to be used on client-specific forms. Only requirements tied to
the register change mapping that matches the renewal will be returned. 

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
      @registrantRenewalSID int

    select
      @registrantRenewalSID = rr.RegistrantRenewalSID
    from
      dbo.RegistrantRenewal rr
    order by
      newid()

    select
      *
    from
      dbo.fRegistrantRenewal#GetRequirementsByType(@registrantRenewalSID, 'S!RENEWAL.DEC', 1)

	  ]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="ExecutionTime" Value="00:00:02" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
		@ObjectName = 'dbo.fRegistrantRenewal#GetRequirementsByType'
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
		dbo.RegistrantRenewal rr on prc.PracticeRegisterSectionSID = rr.PracticeRegisterSectionSID
  join
    dbo.Registration r on rr.RegistrationSID = r.RegistrationSID
  join
    dbo.PracticeRegisterSection prs on r.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID and prs.PracticeRegisterSID = prc.PracticeRegisterSID
	where
		rr.RegistrantRenewalSID = @RegistrantRenewalSID
	and
		rrt.RegistrationRequirementTypeCode like 'S!%.DEC'
	and
		rrt.RegistrationRequirementTypeCode = isnull(@RegistrationRequirementTypeCode, rrt.RegistrationRequirementTypeCode)
);
GO
