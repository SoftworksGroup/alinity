SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrant#Registration
(
	@RegistrantSID		int				-- must be provided - identifies registrant to return registration for
 ,@IsActive					bit				-- when 1 only currently active registration will be returned
 ,@RegistrationYear smallint	-- when set only the latest registration in that registration year will be returned
)
returns table
as
/*********************************************************************************************************************************
Function : Registrant - Registration
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns latest registration record for a given registrant that optionally matches filter criteria
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2018		|	Initial version
					: Tim Edlund	| Jun 2018		| Added support for applications and registration changes
					: Tim Edlund	| Sep 2018		| Introduced fRenewalPeriod#IsOpen function

Comments	
--------
This function is called across the system to return basic information about the latest registration for a registrant. The 
function always returns a single Registration record unless the given registrant has never had a non-withdrawn registration. 
The @RegistrantSID parameter is always required.  Additional filter conditions may be applied by passing the additional 
parameters.  To avoid additional filters, pass the parameters as NULL.

The filter criteria supported are:

1) Returning only the current registration.  This is the latest registration with Active status.  Applies when @IsActive = 1.
2) Returning only the last registration for a given registration year.  Applies when @RegistrationYear is passed.
3) Otherwise, the latest registration is returned (it may be future dated or already expired).

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Selects latest registration for a registrant at random.">
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
	select * from		dbo.fRegistrant#Registration(@RegistrantSID, null, null)
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
	 @ObjectName = 'dbo.fRegistrant#Registration'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
return
(
	select
		r.RegistrantSID
	 ,r.RegistrantNo
	 ,rl.RegistrationSID
	 ,rl.RegistrationNo
	 ,rl.EffectiveTime
	 ,rl.ExpiryTime
	 ,sf.fIsActive(rl.EffectiveTime, rl.ExpiryTime)																															 IsActive
	 ,pr.PracticeRegisterSID
	 ,pr.PracticeRegisterName
	 ,sf.fAltLanguage#Field(pr.RowGUID, 'PracticeRegisterLabel', pr.PracticeRegisterLabel, null)								 PracticeRegisterLabel
	 ,sf.fAltLanguage#Field(pr.RowGUID, 'Description', cast(pr.Description as nvarchar(max)), null)							 Description
	 ,pr.IsActivePractice
	 ,pr.IsDefault																																															 IsApplicantRegister
	 ,prs.PracticeRegisterSectionSID
	 ,prs.IsDisplayedOnLicense																																									 IsSectionDisplayedOnLicense
	 ,sf.fAltLanguage#Field(prs.RowGUID, 'PracticeRegisterSectionLabel', prs.PracticeRegisterSectionLabel, null) PracticeRegisterSectionLabel
	 ,ra.RegistrantAppSID
	 ,ra.RowGUID																																																 ApplicationRowGUID
	 ,ra.FormSID																																																 ApplicationFormSID
	 ,ra.FormStatusSCD																																													 ApplicationStatusSCD
	 ,rr.RegistrantRenewalSID
	 ,rr.RowGUID																																																 RenewalRowGUID
	 ,rr.FormSID																																																 RenewalFormSID
	 ,rr.FormStatusSCD																																													 RenewalStatusSCD
	 ,rin.ReinstatementSID
	 ,rin.RowGUID																																																 ReinstatementRowGUID
	 ,rin.FormSID																																																 ReinstatementFormSID
	 ,rin.FormStatusSCD																																													 ReinstatementStatusSCD
	 ,regchg.RegistrationChangeSID
	 ,regchg.RowGUID																																														 RegistrationChangeRowGUID
	 ,regchg.FormStatusSCD																																											 RegistrationChangeStatusSCD
	 ,cast(case
					 when rr.RegistrantRenewalSID is not null then 0			-- registrant already has a non-withdrawn renewal record
					 when ra.RegistrantAppSID is not null then 0					-- registrant already has a non-withdrawn app record
					 when rin.ReinstatementSID is not null then 0					-- registrant already has a non-withdrawn reinstatement record
					 when regchg.RegistrationChangeSID is not null then 0 -- registrant already has a non-withdrawn registration change record
					 when pr.IsDefault = 1 then 1													-- registrant is on the applicant register
					 else 0
				 end as bit)																																													 IsApplicationEnabled
	 ,cast(case
					 when rr.RegistrantRenewalSID is not null then 0			 -- registrant already has a non-withdrawn renewal record
					 when ra.RegistrantAppSID is not null then 0					 -- registrant already has a non-withdrawn app record
					 when rin.ReinstatementSID is not null then 0					 -- registrant already has a non-withdrawn reinstatement record
					 when regchg.RegistrationChangeSID is not null then 0	 -- registrant already has a non-withdrawn registration change record
					 when pr.IsRenewalEnabled = 0 then 0									 -- register does not allow renewal
					 else dbo.fRenewalPeriod#IsOpen(r.RegistrantSID, x.CurrentRegistrationYear + 1) -- renewal year is +1 from current year
				 end as bit)																																													 IsRenewalEnabled
	 ,cast(case
					 when rr.RegistrantRenewalSID is not null then 0								 -- registrant already has a non-withdrawn renewal record
					 when ra.RegistrantAppSID is not null then 0										 -- registrant already has a non-withdrawn app record
					 when rin.ReinstatementSID is not null then 0										 -- registrant already has a non-withdrawn reinstatement record
					 when regchg.RegistrationChangeSID is not null then 0						 -- registrant already has a non-withdrawn registration change record
					 when pr.IsDefault = cast(1 as bit) then 0											 -- applicant can never reinstate
					 when pr.IsActivePractice = cast(1 as bit) and x.IsActiveLicense = cast(1 as bit) then 0
					 when rl.RegistrationYear < x.CurrentRegistrationYear - x.MaxReinstatementYears then 0 -- reinstatement only allowed for one year
					 when x.CurrentTime
								between (case
													 when x.IsCurrentUserVerifier = cast(1 as bit) then rsyRegChg.ReinstatementVerificationOpenTime -- verifiers have earlier reinstatement start
													 else rsyRegChg.ReinstatementGeneralOpenTime
												 end
												) and rsyRegChg.ReinstatementEndTime then 1				 -- current date falls in open reinstatement period
					 else 0
				 end as bit)																																													 IsReinstatementEnabled
	from
		dbo.fRegistrant#Registration$Base(@RegistrantSID, @IsActive, @RegistrationYear) rl
	join
		dbo.Registrant																																	r on rl.RegistrantSID = r.RegistrantSID
	join
		dbo.PracticeRegisterSection																											prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister																														pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
	cross apply
	(
		select
			sf.fNow()																			CurrentTime
		 ,sf.fIsGranted('EXTERNAL.VERIFICATION')				IsCurrentUserVerifier
		 ,sf.fIsActive(rl.EffectiveTime, rl.ExpiryTime) IsActiveLicense
		 ,dbo.fRegistrationYear#Current()								CurrentRegistrationYear
		 ,isnull(cast(sf.fConfigParam#Value('MaxReinstatementYears') as int), 1)	MaxReinstatementYears
	)																																									x
	left outer join
	(
		select top (1)
			rl.RegistrationSID
		 ,ra.RegistrantAppSID
		 ,ra.RowGUID
		 ,fv.FormSID
		 ,cs.FormStatusSCD
		from
			dbo.fRegistrant#Registration$Base(@RegistrantSID, @IsActive, @RegistrationYear) rl
		join
			dbo.RegistrantApp																																ra on rl.RegistrationSID = ra.RegistrationSID
		join
			sf.FormVersion																																	fv on ra.FormVersionSID = fv.FormVersionSID
		outer apply dbo.fRegistrantApp#CurrentStatus(ra.RegistrantAppSID, -1)								cs
		where
			isnull(cs.FormStatusSCD, 'NEW') <> 'WITHDRAWN'	-- user may withdraw application and create second one (ignore withdrawn)
		order by
			ra.RegistrantAppSID desc
	)															 ra on rl.RegistrationSID										 = ra.RegistrationSID
	left outer join
	(
		select top (1)
			rl.RegistrationSID
		 ,rr.RegistrantRenewalSID
		 ,rr.RowGUID
		 ,fv.FormSID
		 ,cs.FormStatusSCD
		from
			dbo.fRegistrant#Registration$Base(@RegistrantSID, @IsActive, @RegistrationYear) rl
		join
			dbo.RegistrantRenewal																														rr on rl.RegistrationSID = rr.RegistrationSID
		join
			sf.FormVersion																																	fv on rr.FormVersionSID = fv.FormVersionSID
		outer apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1)			cs
		where
			isnull(cs.FormStatusSCD, 'NEW') <> 'WITHDRAWN'	-- user may withdraw renewal and create second one (ignore withdrawn)
		order by
			rr.RegistrantRenewalSID desc
	)															 rr on rl.RegistrationSID										 = rr.RegistrationSID
	left outer join
	(
		select top (1)
			rl.RegistrationSID
		 ,rin.ReinstatementSID
		 ,rin.RowGUID
		 ,fv.FormSID
		 ,cs.FormStatusSCD
		from
			dbo.fRegistrant#Registration$Base(@RegistrantSID, @IsActive, @RegistrationYear) rl
		join
			dbo.Reinstatement																																rin on rl.RegistrationSID = rin.RegistrationSID
		join
			sf.FormVersion																																	fv on rin.FormVersionSID = fv.FormVersionSID
		outer apply dbo.fReinstatement#CurrentStatus(rin.ReinstatementSID, -1)								cs
		where
			isnull(cs.FormStatusSCD, 'NEW') <> 'WITHDRAWN'	-- user may withdraw reinstatement and create second one (ignore withdrawn)
		order by
			rin.ReinstatementSID desc
	)															 rin on rl.RegistrationSID									 = rin.RegistrationSID
	left outer join
		dbo.RegistrationScheduleYear rsyRegChg on pr.RegistrationScheduleSID		 = rsyRegChg.RegistrationScheduleSID
																							and rsyRegChg.RegistrationYear = rl.RegistrationYear -- reinstatement open period is always checked for the latest registration for the registrant
	left outer join
	(
		select top (1)
			rl.RegistrationSID
		 ,regchg.RegistrationChangeSID
		 ,regchg.RowGUID
		 ,cs.FormStatusSCD
		from
			dbo.fRegistrant#Registration$Base(@RegistrantSID, @IsActive, @RegistrationYear) rl
		join
			dbo.RegistrationChange																													regchg on rl.RegistrationSID = regchg.RegistrationSID
		outer apply dbo.fRegistrationChange#CurrentStatus(regchg.RegistrationChangeSID,-1)		cs
		where
			isnull(cs.FormStatusSCD, 'NEW') <> 'WITHDRAWN'	-- admins may withdraw registration change and create second one (ignore withdrawn)
		order by
			regchg.RegistrationChangeSID desc
	)															 regchg on rl.RegistrationSID								 = regchg.RegistrationSID
);
GO
