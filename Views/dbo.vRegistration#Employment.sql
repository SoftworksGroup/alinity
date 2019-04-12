SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistration#Employment
/*********************************************************************************************************************************
View		: Registration - Employment
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns all employment records for a registrant's registration year
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Cory Ng             | Sep 2018		|	Initial version
Comments	
--------
This view returns registrations as well as information about their active employers from the previous registration year. This view 
is looking at active employment record from the previous year since it is originally designed for running exports during the same 
registration year, the current year employment normally wouldn't be provided until the end of the registration year. This view can 
return the same registration record multiple times if they have more than one employment for the year.

Example
-------
select
	*
from
	dbo.vRegistration#Employment x
------------------------------------------------------------------------------------------------------------------------------- */
as
select
  r.RegistrationSID
 ,r.RegistrantSID
 ,r.RegistrationNo
 ,r.RegistrationYear
 ,r.EffectiveTime                     RegistrationEffectiveTime
 ,r.ExpiryTime                        RegistrationExpiryTime
 ,r.CardPrintedTime
 ,reg.RegistrantNo
 ,reg.IsOnPublicRegistry
 ,reg.DirectedAuditYearCompetence
 ,reg.DirectedAuditYearPracticeHours
 ,reg.LateFeeExclusionYear
 ,reg.IsRenewalAutoApprovalBlocked
 ,reg.RenewalExtensionExpiryTime
 ,p.PersonSID
 ,p.FirstName
 ,p.CommonName
 ,p.MiddleNames
 ,p.LastName
 ,p.BirthDate
 ,p.HomePhone
 ,p.MobilePhone
 ,p.DeathDate
 ,re.PracticeHours
 ,p.IsTextMessagingEnabled
 ,re.Phone
 ,re.EffectiveTime            EmploymentEffectiveTime
 ,re.ExpiryTime               EmploymentExpiryTime
 ,re.[Rank]
 ,g.GenderSCD
 ,g.GenderLabel
 ,np.NamePrefixLabel
 ,et.EmploymentTypeName
 ,et.EmploymentTypeCode
 ,et.EmploymentTypeCategory
 ,er.EmploymentRoleName
 ,er.EmploymentRoleCode
 ,o.OrgName
 ,o.OrgLabel
 ,o.StreetAddress1
 ,o.StreetAddress2
 ,o.StreetAddress3
 ,o.CitySID
 ,o.PostalCode
from
  dbo.Registration r
join
  dbo.Registrant reg on r.RegistrantSID = reg.RegistrantSID
join
  sf.Person p on reg.PersonSID = p.PersonSID
join
  sf.NamePrefix np on p.NamePrefixSID = np.NamePrefixSID
join
  sf.Gender g on p.GenderSID = g.GenderSID
join
  dbo.RegistrationScheduleYear rsy on r.RegistrationYear = rsy.RegistrationYear
join
  dbo.RegistrantEmployment re on r.RegistrantSID = re.RegistrantSID and re.RegistrationYear = r.RegistrationYear - 1 and re.PracticeHours > 0
join
  dbo.EmploymentType et on re.EmploymentTypeSID = et.EmploymentTypeSID
join
  dbo.EmploymentRole er on re.EmploymentRoleSID = er.EmploymentRoleSID
join
  dbo.Org o on re.OrgSID = o.OrgSID
GO
