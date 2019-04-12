SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.vRegistrationChange#Search
as
/*********************************************************************************************************************************
View		: Registration Change - Search
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns columns required for the Registration Change notes screen
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------+-------------+---------------------------------------------------------------------------------------------
				: Taylor N   	| Jan	2019		| Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view is intened for use with the Registration Change notes screen, in order to populate the entity 
label. It primarily returns the registration change label as well as the registrant's formatted name, 
but also returns the base registration change columns to support other potential searching uses.

Example:
--------

<TestHarness>
  <Test Name="Random5" IsDefault="true" Description="Return the registration change details for 5 random records">
    <SQLScript>
      <![CDATA[

select top 5
  *
from
  dbo.vRegistrationChange#Search
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
	@ObjectName = 'dbo.vRegistrationChange#Search'

------------------------------------------------------------------------------------------------------------------------------- */

select
	rc.RegistrationChangeSID
 ,rc.RegistrationSID
 ,rc.PracticeRegisterSectionSID
 ,rc.RegistrationYear
 ,rc.NextFollowUp
 ,rc.RegistrationEffective
 ,rc.ReservedRegistrantNo
 ,rc.ConfirmationDraft
 ,rc.ReasonSID
 ,rc.InvoiceSID
 ,rc.ComplaintSID
 ,rc.UserDefinedColumns
 ,rc.RegistrationChangeXID
 ,rc.LegacyKey
 ,rc.IsDeleted
 ,rc.CreateUser
 ,rc.CreateTime
 ,rc.UpdateUser
 ,rc.UpdateTime
 ,rc.RowGUID
 ,rc.RowStamp
 ,rce.RegistrationChangeLabel
 ,sf.fFormatDisplayName(ps.LastName, isnull(ps.CommonName, ps.FirstName)) DisplayName
from
	dbo.RegistrationChange																			rc
join
	dbo.Registration																						rn on rc.RegistrationSID = rn.RegistrationSID
join
	dbo.Registrant																							rg on rn.RegistrantSID = rg.RegistrantSID
join
	sf.Person																										ps on rg.PersonSID = ps.PersonSID
outer apply fRegistrationChange#Ext(rc.RegistrationChangeSID) rce;
GO
