SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrantRenewal#ApprovedByRegister]
(
	@RenewalYear smallint -- the renewal year to include in the analysis
)
returns table
/*********************************************************************************************************************************
Function: Registrant Renewal - Approved By Register
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns reporting/statistical data on renewals which have been approved (paid and non-paid)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Nov 2017			|	Initial Version 
				: Tim Edlund	| Jan 2018			| Updated to exclude registrations which expired in the target year before renewal opened
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function supports reporting routines on the renewal process.  It returns one row for each register which has renewals 
recorded against it for the given renewal year.  The query uses the same components as the Renewal Management dashboard screen.

Example
-------
<TestHarness>
  <Test Name = "RandomSelect" IsDefault ="true" Description="Executes the function to return records at random.">
    <SQLScript>
      <![CDATA[
declare
	@registrationYear  smallint
	

select top (100)
	@registrationyear	 = max(rl.RegistrationYear)
from
	dbo.Registration rl
order by
	newid()


select
	x.PracticeRegisterLabel
 ,x.Paid
 ,x.NotPaid
 ,x.TotalApproved
from
	dbo.fRegistrantRenewal#ApprovedByRegister(@registrationYear) x
order by
	x.PracticeRegisterLabel;

if @@rowcount = 0 raiserror( N'* ERROR: no data found for test case', 18, 1)
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:10"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrantRenewal#ApprovedByRegister'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		rrs.PracticeRegisterLabel
   ,rrs.PracticeRegisterLabel + N' -> ' + rrs.PracticeRegisterLabelTo   RegisterChange
	 ,sum((case when rrs.RenewedRegistrationNo is not null then 1 else 0 end)) Paid
	 ,sum((case when rrs.RenewedRegistrationNo is null then 1 else 0 end))			NotPaid
	 ,count(1)																														TotalApproved
	from
		dbo.fRegistration#Renewal(@RenewalYear - 1)											 rl
	join
		dbo.RegistrantRenewal																										 rr on rl.RegistrationSID = rr.RegistrationSID
	cross apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) cs
	cross apply dbo.fRegistrantRenewal#Search2(rl.RegistrationSID) rrs
	where
		cs.FormStatusSCD = 'APPROVED'
	group by
		rrs.PracticeRegisterLabel
   ,rrs.PracticeRegisterLabel + N' -> ' + rrs.PracticeRegisterLabelTo
);
GO
