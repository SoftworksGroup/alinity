SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRegistrantCredential#Qualifying]
/*********************************************************************************************************************************
View		: Registrant Credential - Qualifying
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns qualifying credentials for registrants
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version
Comments	
--------
This view provides one record for each qualifying credential for each member.  While members typically have only 1 qualifying
credential, if a second exists it is also returned. The "Qualifying Credential Rank" column can be used to isolate the record
with the earliest graduation date.  The latest registration information for the registrant is returned in the leading columns
to provide context. Details of the granting institution including location and region is also returned.  Use the "Registrant
Is Currently Active" column to return qualifying credentials for currently active members only.

This view returns Qualifying credential information only. Use the dbo.vRegistrantCredential#Education view to return all 
education credentials.

Example
-------
select
	*
from
	dbo.vRegistrantCredential#Qualifying x
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
 ,rc.ProgramName
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
 ,sp.ISONumber					 GrantingOrgStateProvinceISONumber
 ,ctry.ISONumber				 GrantingOrgCountryISONumber
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
								 rc.EffectiveTime
								,rc.RegistrantCredentialSID
							)					 QualifyingCredentialRank	
from
	dbo.RegistrantCredential					 rc
join
	dbo.vRegistrant#LatestRegistration lreg on rc.RegistrantSID		= lreg.RegistrantSID
join
	dbo.QualifyingCredentialOrg				 qco on rc.CredentialSID		= qco.CredentialSID and rc.OrgSID = qco.OrgSID
join
	dbo.Credential										 crd on rc.CredentialSID		= crd.CredentialSID
join
	dbo.Org														 org on rc.OrgSID						= org.OrgSID
join
	dbo.City													 cty on org.CitySID					= cty.CitySID
join
	dbo.StateProvince									 sp on cty.StateProvinceSID = sp.StateProvinceSID
join
	dbo.Country												 ctry on sp.CountrySID			= ctry.CountrySID
join
	dbo.Region												 rgn on org.RegionSID				= rgn.RegionSID;



GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns one record for each qualifying credential for each member.  While members typically have only 1 qualifying credential, if a second exists it is also returned. The "Qualifying Credential Rank" column can be used to isolate the record with the earliest graduation date. |EXPORT+ ^PersonList ^OrgList ^RegistrationList', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrantCredential#Qualifying', NULL, NULL
GO
