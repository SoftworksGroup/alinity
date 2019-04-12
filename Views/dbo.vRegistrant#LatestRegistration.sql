SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrant#LatestRegistration
/*********************************************************************************************************************************
View		: Registrant - Latest Registration
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns latest registration information for each registrant (current or past) in the system
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version
Comments	
--------
This view provides alternate call syntax for the fRegistrant#LatestRegistration table function. The view format is generally
faster when all registrants must be queried.  The view provides one record for each current or past member in the system. The
latest registration information is returned along with the registrant name, number and name of the register and section.  A
bit value is returned to indicate whether the member is currently registered in an active-practice status.

See also table function:dbo.fRegistrant#LatestRegistration

Example
-------
select
	*
from
	dbo.vRegistrant#LatestRegistration x
where
	x.LatestRegistrationYear = 2018 and x.IsRenewalEnabled = 1
------------------------------------------------------------------------------------------------------------------------------- */
as
select
--!<ColumnList DataSource="dbo.fRegistrant#LatestRegistration" Alias="lReg">
 lReg.RegistrantSID
,lReg.PersonSID
,lReg.RegistrationSID
,lReg.RegistrantNo
,lReg.RegistrantLabel
,lReg.FirstName
,lReg.MiddleNames
,lReg.LastName
,lReg.CommonName
,lReg.BirthDate
,lReg.DeathDate
,lReg.PersonEmailAddressSID
,lReg.EmailAddress
,lReg.HomePhone
,lReg.MobilePhone
,lReg.IsOnPublicRegistry
,lReg.RenewalExtensionExpiryTime
,lReg.RegistrationYear
,lReg.RegistrationLabel
,lReg.RegistrationNo
,lReg.PracticeRegisterSID
,lReg.PracticeRegisterSectionSID
,lReg.EffectiveTime
,lReg.ExpiryTime
,lReg.CardPrintedTime
,lReg.ReasonSID
,lReg.ReasonGroupSID
,lReg.ReasonName
,lReg.PracticeRegisterName
,lReg.PracticeRegisterLabel
,lReg.IsActivePractice
,lReg.IsLearningPlanEnabled
,lReg.LearningModelSID
,lReg.PracticeRegisterSectionLabel
,lReg.IsSectionDisplayedOnRegistration
,lReg.IsRenewalEnabled
,lReg.RegisterRank
,lreg.PersonLegacyKey
,lReg.RegistrantIsCurrentlyActive
--!</ColumnList>
	,lreg.RegistrationYear LatestRegistrationYear	-- columns need to be available with and without "Latest" prefix
	,lReg.EffectiveTime LatestRegistrationEffectiveTime
	,lReg.ExpiryTime LatestRegistrationExpiryTime
from
	dbo.fRegistrant#LatestRegistration(-1, null) lreg;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Returns the latest registration (license/permit/applicant-status) of each registrant including registrants who are no longer in active practice. |EXPORT ^PersonList', 'SCHEMA', N'dbo', 'VIEW', N'vRegistrant#LatestRegistration', NULL, NULL
GO
