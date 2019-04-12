SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantCredential#Education
/*********************************************************************************************************************************
View		: Registrant Credential - Education 
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns qualifying and non-qualifying education credentials for registrants
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version
Comments	
--------
This view provides one record for each education credential for each member. Both qualifying and non-qualifying education
is returned.  Specializations, which are also stored through the dbo.RegistrantCredential table, are not returned.

The "Education Credential Rank" column can be used to select records in priority order where qualifying credentials are
ranked highest, followed by education related to the profession, and finally non-related education.  The latest registration 
information for the registrant is returned in the leading columns to provide context. Details of the granting institution 
where available, are provided.  Use the "Registrant Is Currently Active" column to return qualifying credentials for currently 
active members only.

This view returns all Education credential information. Use the dbo.vRegistrantCredential#Qualifying view if only the 
qualifying credentials are required. 

Example
-------
select
	*
from
	dbo.vRegistrantCredential#Education x
where
	x.RegistrantIsCurrentlyActive = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
select
	lreg.RegistrantNo
 ,lreg.RegistrantLabel
 ,lreg.RegistrationLabel
 ,lreg.LatestRegistrationYear
 ,lreg.RegistrantIsCurrentlyActive
 ,crd.CredentialLabel
 ,cast(isnull(qco.QualifyingCredentialOrgSID, 0) as bit) IsQualifyingCredential
 ,crd.IsRelatedToProfession
 ,rc.ProgramName
 ,rc.ProgramStartDate
 ,rc.ProgramTargetCompletionDate
 ,year(rc.EffectiveTime)																 GraduationYear
 ,org.OrgName																						 GrantingOrgName
 ,org.StreetAddress1																		 GrantingOrgStreetAddress1
 ,org.StreetAddress2																		 GrantingOrgStreetAddress2
 ,org.StreetAddress3																		 GrantingOrgStreetAddress3
 ,cty.CityName																					 GrantingOrgCityName
 ,sp.StateProvinceCode																	 GrantingOrgStateProvinceCode
 ,ctry.CountryName																			 GrantingOrgCountryName
 ,org.PostalCode																				 GrantingOrgPostalCode
 ,rgn.RegionName																				 GrantingOrgRegionName
	----- CIHI coding ----------------------------------
 ,crd.CredentialCode
 ,sp.ISONumber																					 GrantingOrgStateProvinceISONumber
 ,ctry.ISONumber																				 GrantingOrgCountryISONumber
	--- standard export columns  -------------------
 ,lReg.PracticeRegisterLabel
 ,lReg.PracticeRegisterSectionLabel
 ,lReg.EmailAddress
 ,lReg.FirstName
 ,lReg.CommonName
 ,lReg.MiddleNames
 ,lReg.LastName
 ,lReg.PersonLegacyKey
 ,org.LegacyKey OrgLegacyKey
	----- System ID's ----------------------------------
 ,rc.RegistrantCredentialSID
 ,rc.RegistrantSID
 ,lreg.RegistrationSID
 ,lreg.PersonSID
 ,rc.CredentialSID
 ,crd.CredentialTypeSID
 ,rc.OrgSID
 ,org.OrgTypeSID
 ,cty.CitySID
 ,cty.StateProvinceSID
 ,org.RegionSID
 ,rank() over (partition by
								 rc.RegistrantSID
							 order by
								 isnull(qco.QualifyingCredentialOrgSID, 0) desc
								,crd.IsRelatedToProfession desc
								,rc.EffectiveTime
								,rc.RegistrantCredentialSID
							)																					 EducationCredentialRank
from
	dbo.RegistrantCredential					 rc
join
	dbo.vRegistrant#LatestRegistration lreg on rc.RegistrantSID		= lreg.RegistrantSID
join
	dbo.Credential										 crd on rc.CredentialSID		= crd.CredentialSID and crd.IsSpecialization = cast(0 as bit)
left outer join
	dbo.Org														 org on rc.OrgSID						= org.OrgSID
left outer join
	dbo.City													 cty on org.CitySID					= cty.CitySID
left outer join
	dbo.StateProvince									 sp on cty.StateProvinceSID = sp.StateProvinceSID
left outer join
	dbo.Country												 ctry on sp.CountrySID			= ctry.CountrySID
left outer join
	dbo.Region												 rgn on org.RegionSID				= rgn.RegionSID
left outer join
	dbo.QualifyingCredentialOrg				 qco on rc.CredentialSID		= qco.CredentialSID and rc.OrgSID = qco.OrgSID;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns one record for each education credential for each member. Both qualifying and non-qualifying education is returned. Specializations, which are also stored through the dbo.RegistrantCredential table, are not returned. |EXPORT+ ^PersonList ^OrgList ^RegistrationList', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential#Education', NULL, NULL
GO
