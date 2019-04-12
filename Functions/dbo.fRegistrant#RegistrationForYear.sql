SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrant#RegistrationForYear
(
	@RegistrantSID		int -- must be provided - identifies registrant to return registration for
 ,@RegistrationYear smallint
)
returns table
as
/*********************************************************************************************************************************
Function : Registrant - Registration For Year
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Override syntax of dbo.fRegistrant#Registration to return last registration record for registrant and given reg year
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2018		|	Initial version

Comments	
--------
This function is called across the system to return basic information about the last registration for a given year and registrant.
The function always returns a single Registration record unless the given registrant does not have a registration in the
registration year specified.  The function will return the last registration that the registrant had in that year according to
the Effective-Time. Returning this registration is useful in inquiries and to determine whether a renewal or reinstatement was
completed for a given year (Admin Portal).

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Selects historical registration for a registrant at random.">
    <SQLScript>
      <![CDATA[
declare
	@RegistrantSID		int
 ,@RegistrationYear smallint

select top (1)
	@RegistrantSID		= rl.RegistrantSID
 ,@RegistrationYear = r.RegistrationYear
from
	dbo.Registration rl
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end
else
begin

	select
		*
	from
		dbo.fRegistrant#RegistrationForYear(@RegistrantSID, @RegistrationYear)

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
		dbo.fRegistrant#Registration(@RegistrantSID, null, @RegistrationYear) r
);
GO
