SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fRegistrant#IsEligibleForAudit]
(
	@RegistrantSID		int				-- primary key of Registrant to check
 ,@AuditTypeSID			int				-- the type of audit to check for duplicate audits
 ,@RegistrationYear smallint	-- the year to assign to check for duplicate audits
)
returns bit
as
/*********************************************************************************************************************************
TableF	: Registrant - Audit Eligibility
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Checks a registrant to determine if they are eligible for auditing and returns ON when eligible
-----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2017		|	Initial version
					: Tim Edlund	| Apr 2018		| Supported no active registration on directed audits (some reinstatement scenarios)

Comments	
--------
The function is used by audit procedures to check whether registrants being targeted for audit are eligible. To be eligible 
various criteria must be checked:

o active user account
o active primary email address
o must not already have an audit of the same type in same year
o active-practice registration in the given year OR member has a directed audit

The last criteria is conditional.  Normally individuals being audited will need to have an active-practice registration but
in certain reinstatement scenarios (and where historical data is not converted), it may be necessary to setup an audit for
an individual without an active-practice registration.  This can be achieved by using one of the "directed audit" columns in
the dbo.Registrant record. If an active-practice registration is not found the function still allows the audit if a directed
audit is found for the given target year.

Example
-------
<TestHarness>
	<Test Name = "Simple" Description="Returns eligibility check results for 10 registrants selected at random.">
	<SQLScript>
	<![CDATA[

declare
		@auditTypeSID			 int
	,	@registrationYear	 smallint = ltrim(datepart(year, sf.fNow()))

select top 1
	@auditTypeSID = at.AuditTypeSID
from	
	dbo.AuditType at
order by
	newid()

select 
		r.RegistrantLabel
	,	dbo.fRegistrant#IsEligibleForAudit(r.RegistrantSID, @auditTypeSID, @registrationYear)				IsEligibleForAudit
from 
	dbo.vRegistrant r
join
(	select top 10 
		z.RegistrantSID
	from
		dbo.Registrant z
	order by
		newid()
) x on r.RegistrantSID = x.RegistrantSID

if @@rowcount = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

	]]>
	</SQLScript>
	<Assertions>
		<Assertion Type="ExecutionTime" Value="00:00:05" />
	</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.fRegistrant#IsEligibleForAudit'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@ON								 bit			= cast(1 as bit)		-- used on bit comparisons to avoid multiple casts
	 ,@registrationCount int													-- count of active registrations
	 ,@year							 smallint = sf.fTodayYear();	-- current year

	if exists
	(
		select
			1
		from
			dbo.Registrant				r
		join
			sf.ApplicationUser		au on r.PersonSID							= au.PersonSID and au.IsActive = @ON -- check for active user account
		join
			sf.PersonEmailAddress pea on r.PersonSID						= pea.PersonSID and pea.IsActive = @ON and pea.IsPrimary = @ON -- check for active primary email address	
		left outer join
			dbo.RegistrantAudit		ra on r.RegistrantSID					= ra.RegistrantSID
																	and ra.RegistrationYear = isnull(@RegistrationYear, @year)
																	and ra.AuditTypeSID			= isnull(@AuditTypeSID, ra.AuditTypeSID)
		where
			r.RegistrantSID = @RegistrantSID and ra.RegistrantAuditSID is null	-- check for audit already existing
	)
	begin

		-- check for active registration for the given year

		select
			@registrationCount = count(1)
		from
			dbo.Registration				rl
		join
			dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID and prs.IsActive = @ON
		join
			dbo.PracticeRegister				pr on prs.PracticeRegisterSID				 = pr.PracticeRegisterSID and pr.IsActivePractice = @ON
		where
			rl.RegistrantSID = @RegistrantSID and sf.fIsActive(rl.EffectiveTime, rl.ExpiryTime) = @ON;

		-- if no active registration, check for directed audit for
		-- the given year (allow the audit as it may be for reinstatement)

		if @registrationCount = 0
		begin

			select
				@registrationCount = count(1)
			from
				dbo.Registrant r
			where
				r.RegistrantSID																	 = @RegistrantSID
				and
				(
					isnull(r.DirectedAuditYearCompetence, 0)			 = isnull(@RegistrationYear, @year)
					or isnull(r.DirectedAuditYearPracticeHours, 0) = isnull(@RegistrationYear, @year)
				);

		end;

	end;

	return (cast(isnull(@registrationCount, 0) as bit));

end;
GO
