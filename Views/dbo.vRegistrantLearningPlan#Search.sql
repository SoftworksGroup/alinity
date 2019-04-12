SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrantLearningPlan#Search
as
/*********************************************************************************************************************************
View		: Registrant Learning Plan - Search
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns registrant learning plan details
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------+-------------+---------------------------------------------------------------------------------------------
				: Cory Ng   	| Jan	2018		| Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view is wrapper for the dbo.fRegistrantLearningPlan#Search function. This view is used as a merge source when emailing from 
the renewal search UI. Please see dbo.fRegistrantLearningPlan#Search documentation for details.

Example:
--------

<TestHarness>
  <Test Name="Random5" IsDefault="true" Description="Return the details of 5 random learning plans">
    <SQLScript>
      <![CDATA[

select top 5
  *
from
  dbo.vRegistrantLearningPlan#Search
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
	@ObjectName = 'dbo.vRegistrantLearningPlan#Search'

------------------------------------------------------------------------------------------------------------------------------- */
	
select
	 rlps.RegistrantSID
	,rlps.RegistrantNo
	,rlps.RegistrantLearningPlanSID
	,rlps.RegistrantLabel
	,rlps.PracticeRegisterLabel
	,rlps.FormStatusSID																																					
	,rlps.FormStatusSCD
	,rlps.FormStatusLabel	
	,rlps.FormOwnerSCD
	,rlps.FormOwnerLabel
	,rlps.PersonSID
	,rlps.FirstName
	,rlps.MiddleNames
	,rlps.LastName
	,rlps.EmailAddress
	,rlps.RegistrationYear		
	,rlps.NextFollowUp
	,rlps.IsFollowUpDue
	,rlps.IsNotStarted
	,rlps.IsPDFGenerated						
	,rlps.PersonDocSID
	,rlps.IsPDFRequired					
	,rlps.LastStatusChangeUser
	,rlps.LastStatusChangeTime
	,rlps.RegistrantLearningPlanXID
	,rlps.LegacyKey
	,pma.AddressBlockForHTML																									PersonAddressBlockForHTML
	,pma.AddressBlockForPrint																									PersonAddressBlockForPrint
from
	dbo.Registrant	r
cross apply
  dbo.fRegistrantLearningPlan#Search(r.RegistrantSID, dbo.fRegistrationYear#Current()) rlps
cross apply
	dbo.fPersonMailingAddress#Formatted(r.PersonSID) pma
GO
