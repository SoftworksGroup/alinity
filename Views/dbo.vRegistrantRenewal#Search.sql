SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantRenewal#Search
as
/*********************************************************************************************************************************
View		: Registrant Renewal - Search
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns registration and renewal status details
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------+-------------+---------------------------------------------------------------------------------------------
				: Cory Ng   	| Jan	2018		| Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view is wrapper for the dbo.fRegistrantRenewal#Search function. This view is used as a merge source when emailing from the
renewal search UI. Please see dbo.fRegistrantRenewal#Search documentation for details.

Example:
--------

<TestHarness>
  <Test Name="Random5" IsDefault="true" Description="Return the renewal details for 5 random licenses">
    <SQLScript>
      <![CDATA[

select top 5
  *
from
  dbo.vRegistrantRenewal#Search
order by
  newid()

    ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute 
	@ObjectName = 'dbo.vRegistrantRenewal#Search'

------------------------------------------------------------------------------------------------------------------------------- */
	
select
	 rrs.RegistrationSID
	,rrs.RegistrantSID
	,rrs.RegistrantNo
	,rrs.RegistrantRenewalSID
	,rrs.RegistrantLabel
	,rrs.FormStatusSID																																																									
	,rrs.FormStatusSCD
	,rrs.FormStatusLabel				
	,rrs.FormOwnerSCD
	,rrs.FormOwnerLabel						
	,rrs.PersonSID
	,rrs.FirstName
	,rrs.MiddleNames
	,rrs.LastName
	,rrs.EmailAddress
	,rrs.RegistrationYear																																																									
	,rrs.PracticeRegisterSectionSID
	,rrs.PracticeRegisterSectionLabel
	,rrs.PracticeRegisterSID
	,rrs.PracticeRegisterLabel
	,rrs.IsActivePractice
	,rrs.IsRegisterChange					
	,rrs.PracticeRegisterLabelTo	
	,rrs.IsActivePracticeTo				
	,rrs.NextFollowUp
	,rrs.IsFollowUpDue
	,rrs.IsNotStarted
	,rrs.IsAutoApprovalBlocked
	,rrs.AutoApprovalInfo					
	,rrs.ReasonSID																																																												
	,rrs.InvoiceNo
	,rrs.TotalDue
	,rrs.IsUnPaid									
	,rrs.RenewedRegistrationNo					
	,rrs.IsPDFGenerated						
	,rrs.PersonDocSID
	,rrs.IsPDFRequired						
	,rrs.IsPAPSubscriber					
	,rrs.LastStatusChangeUser
	,rrs.LastStatusChangeTime
	,rrs.LicenseCreateTime
	,rrs.RenewedWeekEndingDate
	,rrs.LicenseExpiryTime
	,rrs.RegistrantRenewalXID
	,pma.AddressBlockForHTML																												PersonAddressBlockForHTML
	,pma.AddressBlockForPrint																												PersonAddressBlockForPrint
	,rrs.LegacyKey
from
  dbo.Registration rl
join
	dbo.Registrant r on rl.RegistrantSID = r.RegistrantSID
cross apply
  dbo.fRegistrantRenewal#Search2(rl.RegistrationSID) rrs
cross apply 
	dbo.fPersonMailingAddress#Formatted(r.PersonSID) pma
GO
