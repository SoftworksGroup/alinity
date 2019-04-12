SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrant#RegistrationCurrent
(
	@RegistrantSID int	-- must be provided - identifies registrant to return registration for
)
returns table
as
/*********************************************************************************************************************************
Function : Registrant - Registration Current
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Override syntax of dbo.fRegistrant#Registration to return current registration record for registrant
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2018		|	Initial version

Comments	
--------
This function is called across the system to return basic information about the latest registration for a registrant. The
function always returns a single Registration record unless the given registrant does not have a currently active registration.
The function will return the last registration that the registrant had according to Effective-Time and where it is in an active
status as compared with the current time in the client timezone. Returning this registration is useful on current-status
inquires on the Registrant (Admin Portal).

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Selects current registration for a registrant at random.">
    <SQLScript>
      <![CDATA[
declare @RegistrantSID int

select top (1)
	@RegistrantSID = rl.RegistrantSID
from
	dbo.Registration rl
where
	sf.fIsActive(rl.EffectiveTime, rl.ExpiryTime) = 1
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end
else
begin
	select * from		dbo.fRegistrant#RegistrationCurrent(@RegistrantSID)
end
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fRegistrant#RegistrationCurrent'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
return
(
	select
		--!<ColumnList DataSource="dbo.fRegistrant#Registration" Alias="r">
		 r.RegistrantSID
		,r.RegistrantNo
		,r.RegistrationSID
		,r.RegistrationNo
		,r.EffectiveTime
		,r.ExpiryTime
		,r.IsActive
		,r.PracticeRegisterSID
		,r.PracticeRegisterName
		,r.PracticeRegisterLabel
		,r.Description
		,r.IsActivePractice
		,r.IsApplicantRegister
		,r.PracticeRegisterSectionSID
		,r.IsSectionDisplayedOnLicense
		,r.PracticeRegisterSectionLabel
		,r.RegistrantAppSID
		,r.ApplicationRowGUID
		,r.ApplicationFormSID
		,r.ApplicationStatusSCD
		,r.RegistrantRenewalSID
		,r.RenewalRowGUID
		,r.RenewalFormSID
		,r.RenewalStatusSCD
		,r.ReinstatementSID
		,r.ReinstatementRowGUID
		,r.ReinstatementFormSID
		,r.ReinstatementStatusSCD
		,r.RegistrationChangeSID
		,r.RegistrationChangeRowGUID
		,r.RegistrationChangeStatusSCD
		,r.IsApplicationEnabled
		,r.IsRenewalEnabled
		,r.IsReinstatementEnabled
	--!</ColumnList>
	from
		dbo.fRegistrant#Registration(@RegistrantSID, 1, null) r
);
GO
