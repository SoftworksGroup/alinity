SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistration#Insert$GetDefaults
	@RegistrantSID							int			 output					-- key of registrant to derive new registration defaults for (or use PersonSID)
 ,@PracticeRegisterSectionSID int			 = null output	-- key of the register section to create new registration for (default available)
 ,@EffectiveTime							datetime = null output	-- day the new registration takes effect (default available)
 ,@ExpiryTime									datetime = null output	-- last day the new registration remains in effect (default available)
 ,@RegistrationYear						smallint = null output	-- year the new registration take effect - pass for Renewal (default available)
 ,@PracticeRegisterSID				int			 = null output	-- key of the register to create new registration for (default available)
 ,@PersonSID									int = null							-- key of person to create new registration for (or use RegistrantSID)
 ,@TerminatePriorRegistration bit = 1									-- when 0 any previous registration is not terminated
as
/*********************************************************************************************************************************
Sproc    : Registration Insert - Get Defaults
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure returns default values required for inserting new registration records
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Apr 2018		|	Initial version
				: Tim Edlund					| Jun 2018		| Current time used for changes on current date to allow multiple changes on same day
				: Tim Edlund					| Dec 2018		| Added parameter to avoid terminating previous registration (on invoice creation)

Comments	
--------
This procedure is called from pRegistration#Insert and pInvoice#SetOnFormChange procedures to return default values for effective 
and expiry times, as well as other related values for the new registration record.  The logic is separated out of the #Insert 
procedure to simplify maintenance and testing due to its complexity.

Note that unless @TerminatePriorRegistration is passed as 0 (OFF), any registration which has an expiry date after the 
new @ExpiryTime, is terminated.  The termination is carried out by updating the dbo.Registration record's ExpiryTime
column.  If only the calculation of an Effective-Time is required by the caller, for example when generating an invoice, then 
the parameter should be passed as 0.  This ensures the prior registration will not terminate until the invoice is paid.

The procedure provides defaults to support common scenarios such as Renewal and reinstatement.  For Renewals the next
Registration Year may be provided which results in the effective and expiry times automatically being set to the years' starting
and ending dates.  Also for Renewals, if the new year registration is generated late because approval from an administrator was
delayed or payment was late, the system will automatically back-date the new registration to the start of the year to avoid
creating a gap.  

For Reinstatements, the procedure automatically expires the previous registration where it was a non-practicing type so that
the reinstated registration applies immediately and no gap or overlap results with the previous in-active registration.

For administrators, temporary permit expiry times default to the number of days specified as the permit length on the
register after the effective date.  Note that even if a temporary permit normally has a period of 90 days, the administrator
may pass an explicit expiry date to shorten or extend the default period. 

This procedure works in parallel with several mandatory (product level) business rules imposed on registration
records which include:

1. Gaps between registrations are not allowed. Ideally the system will maintain a continuous record of the members registration
including one or more periods on the primary in-active register.  This rule may be mitigated to avoid records created 
prior to conversion to Alinity by using the "NoGapStartDate" configuration parameter.  Only registrations created after this
date are included in the no-gap rule.

2. Effective times must not be later than expiry times.  This is a standard data quality rule implemented on all tables
with effective-expiry time column pairs.

3. Overlaps in registrations are not allowed.  A member may only have one active registration at the same time. 

4. Deletion of a future dated registration is allowed if that registration never came into effect and, if no payments are applied 
on its associated invoice.  The administrator can un-apply payments on the associated invoice to get around this restriction. 
The associated invoice is also cancelled in this operation if one exists. 

Example:
--------
<TestHarness>
  <Test Name = "InactiveToActive" IsDefault ="true" Description="Gets defaults for a randomly selected registrant moving from inactive to active.">
    <SQLScript>
      <![CDATA[
declare
	@personSID									int -- variables to capture output from sproc
 ,@registrantSID							int
 ,@practiceRegisterSectionSID int
 ,@effectivetime							datetime
 ,@expiryTime									datetime
 ,@registrationYear						smallint
 ,@practiceRegisterSID				int;

select
	@practiceRegisterSectionSID = max(prs.PracticeRegisterSectionSID) -- locate an active practice section to assign
from
	dbo.PracticeRegister				pr
join
	dbo.PracticeRegisterSection prs on pr.PracticeRegisterSID = prs.PracticeRegisterSID
where
	pr.IsActivePractice = 1;

select top (1)
	@personSID = r.PersonSID	-- locate a person currently on on an inactive register
from
	dbo.Registration						reg
join
	dbo.PracticeRegisterSection prs on reg.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
join
	dbo.PracticeRegister				pr on prs.PracticeRegisterSID					= pr.PracticeRegisterSID and pr.IsActivePractice = 0 -- locate someone who is not active
join
	dbo.Registrant							r on reg.RegistrantSID								= r.RegistrantSID
where
	sf.fIsActive(reg.EffectiveTime, reg.ExpiryTime) = 1
order by
	newid();

if @practiceRegisterSectionSID is null or @personSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pRegistration#Insert$GetDefaults
		@RegistrantSID = @registrantSID output
	 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID
	 ,@EffectiveTime = @effectivetime output
	 ,@ExpiryTime = @expiryTime output
	 ,@RegistrationYear = @registrationYear output
	 ,@PracticeRegisterSID = @practiceRegisterSID output
	 ,@PersonSID = @personSID;

	select
		@registrantSID							RegistrantSID
	 ,@practiceRegisterSectionSID PracticeRegisterSectionSID
	 ,@effectivetime							EffectiveTime
	 ,@expiryTime									ExpiryTime
	 ,@registrationYear						RegistrationYear
	 ,@practiceRegisterSID				PracticeRegisterSID
	 ,@personSID									PersonSID;

	rollback; -- don't save updates made for testing

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistration#Insert$GetDefaults'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo								 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText							 nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON											 bit					 = cast(1 as bit) -- constant for bit comparison and assignments
	 ,@OFF										 bit					 = cast(0 as bit) -- constant for bit comparison and assignments
	 ,@isActivePractice				 bit														-- indicates if new registration is for active practice
	 ,@practiceRegisterTypeSCD varchar(15)										-- type of term for new registration - e.g. FIXED.ANNUAL (see master table/setup)
	 ,@termPermitDays					 int														-- days length for temporary permit (new registration)
	 ,@previousRegistrationSID int														-- key of previous registration (for updates)
	 ,@previousExpiryDate			 date														-- date previous registration expires
	 ,@revisedExpiryTime			 date														-- new date to assign as previous expiry if previous registration is perpetual type
	 ,@previousIsActive				 bit														-- tracks whether previous registration is expired
	 ,@today									 date					 = sf.fToday()		-- current date in the user timezone
	 ,@now										 datetime			 = sf.fNow();			-- current time in user timezone

	set @RegistrantSID = @RegistrantSID; -- initialize output values			
	set @PracticeRegisterSectionSID = @PracticeRegisterSectionSID;
	set @EffectiveTime = @EffectiveTime;
	set @ExpiryTime = @ExpiryTime;
	set @RegistrationYear = @RegistrationYear;
	set @PracticeRegisterSID = @PracticeRegisterSID;

	begin try

		-- the registrant SID is required but may be derived based on
		-- a person key passed in

		if @RegistrantSID is null and @PersonSID is not null
		begin

			select
				@RegistrantSID = r.RegistrantSID
			from
				dbo.Registrant r
			where
				r.PersonSID = @PersonSID;

			if @RegistrantSID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'dbo.Registrant'
				 ,@Arg2 = @PersonSID;

				raiserror(@errorText, 18, 1);
			end;

		end;

		-- a practice register section is also required and may
		-- be defaulted based on the parent register; a default
		-- for which may also be defined in the configuration

		if @PracticeRegisterSectionSID is null and @PracticeRegisterSID is null
		begin

			select
				@PracticeRegisterSID = pr.PracticeRegisterSID
			from
				dbo.PracticeRegister pr
			where
				pr.IsDefault = @ON; -- lookup default register

		end;

		if @PracticeRegisterSectionSID is null and @PracticeRegisterSID is not null
		begin

			select
				@PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
			from
				dbo.PracticeRegisterSection prs
			where
				prs.PracticeRegisterSID = @PracticeRegisterSID and prs.IsDefault = @ON; -- lookup default section for the register

		end;
		else if @PracticeRegisterSID is null and @PracticeRegisterSectionSID is not null
		begin

			select
				@PracticeRegisterSID = prs.PracticeRegisterSID
			from
				dbo.PracticeRegisterSection prs
			where
				prs.PracticeRegisterSectionSID = @PracticeRegisterSectionSID;

		end;

		-- in order to default any remaining values both a registrant
		-- and practice register section key must have been identified

		if @RegistrantSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@RegistrantSID';

			raiserror(@errorText, 18, 1);

		end;

		if @PracticeRegisterSectionSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@PracticeRegisterSectionSID';

			raiserror(@errorText, 18, 1);
		end;

		-- look up details of the registration the member is moving
		-- to as well as their latest registration (if any)

		select
			@isActivePractice				 = pr.IsActivePractice
		 ,@practiceRegisterTypeSCD = prt.PracticeRegisterTypeSCD
		 ,@termPermitDays					 = pr.TermPermitDays
		from
			dbo.PracticeRegisterSection prs
		join
			dbo.PracticeRegister				pr on prs.PracticeRegisterSID			= pr.PracticeRegisterSID
		join
			dbo.PracticeRegisterType		prt on pr.PracticeRegisterTypeSID = prt.PracticeRegisterTypeSID
		where
			prs.PracticeRegisterSectionSID = @PracticeRegisterSectionSID;

		if @practiceRegisterTypeSCD is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.PracticeRegisterSection'
			 ,@Arg2 = @PracticeRegisterSectionSID;

			raiserror(@errorText, 18, 1);
		end;

		select
			@previousRegistrationSID = rl.RegistrationSID
		 ,@previousExpiryDate			 = cast(rl.ExpiryTime as date)
		 ,@previousIsActive				 = rl.IsActive
		from
			dbo.fRegistrant#LastRegistration(@RegistrantSID) rl;

		-- where the member is moving to inactive practice and the
		-- previous expiry has already occurred, the effective
		-- date defaults to the day following the previous expiry 
		-- to avoid creating gaps

		if @EffectiveTime is null and @isActivePractice = @OFF and @previousExpiryDate < @today
		begin
			set @EffectiveTime = cast(dateadd(day, 1, @previousExpiryDate) as datetime); -- backdate the new registration effective time to avoid gaps
		end;

		-- otherwise if the effective time is not passed it defaults to 
		-- the current time unless a Registration Year is provided in which 
		-- case it defaults to the later of the registration year start-time
		-- or the current date 

		if @EffectiveTime is null and @RegistrationYear is null
		begin
			set @EffectiveTime = @now; -- if no registration year - default to now
		end;
		else if @EffectiveTime is null
		begin

			select
				@EffectiveTime = rsy.YearStartTime
			from
				dbo.RegistrationSchedule		 rs
			join
				dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID = rsy.RegistrationScheduleSID
			where
				rs.IsDefault = @ON and rsy.RegistrationYear = @RegistrationYear;

			if @@rowcount = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotConfigured'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
				 ,@Arg1 = '"Registration Schedule Year"';

				raiserror(@errorText, 17, 1);
			end;

			if @today > cast(@EffectiveTime as date)
			begin

				-- allow the registration to be backdated if there is an approved 
				-- renewal for the previous registration but otherwise set to current time

				if not exists
				(
					select
						1
					from
						dbo.vRegistrantRenewal rr
					where
						rr.RegistrationSID = @previousRegistrationSID and rr.FormStatusSCD = 'APPROVED'
				)
				begin
					set @EffectiveTime = cast(@now as datetime);
				end;

			end;

		end;

		-- if the previous registration's term ends after the 
		-- new registration will start, then end its term
		-- on the day before the new effective time

		if @previousIsActive = @ON and cast(@EffectiveTime as date) < @previousExpiryDate and @TerminatePriorRegistration = @ON
		begin

			set @revisedExpiryTime = cast(convert(varchar(8), dateadd(day, -1, cast(@EffectiveTime as date)), 112) + ' 23:59:59.99' as datetime); -- expire the previous inactive registration

			update
				dbo.Registration
			set -- if this registration only became active today; then set the expiry to the current time
				ExpiryTime = (case
												when cast(EffectiveTime as date) = @today then dateadd(second, -1, @now)
												when EffectiveTime > @revisedExpiryTime then dateadd(second, 1, EffectiveTime)
												else @revisedExpiryTime
											end
										 )
			where
				RegistrationSID = @previousRegistrationSID;

		end;

		-- the registration year is automatically set to the
		-- year in which the effective time falls (not a default)

		set @RegistrationYear = dbo.fRegistrationYear(@EffectiveTime); -- for term permits expiry may be in different registration year

		-- the expiry time is automatically set to the end of the
		-- registration year for FIXED.ANNUAL types and to the
		-- end of the "2099" registration year when PERPETUAL

		if @practiceRegisterTypeSCD in ('FIXED.ANNUAL', 'PERPETUAL')
		begin

			select
				@ExpiryTime =
				case
					when @practiceRegisterTypeSCD = 'PERPETUAL' then datefromparts(2099, month(rsy.YearEndTime), day(rsy.YearEndTime)) -- perpetual registrations are set to end in 2099
					else rsy.YearEndTime
				end
			from
				dbo.RegistrationSchedule		 rs
			join
				dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID = rsy.RegistrationScheduleSID
			where
				rs.IsDefault = @ON and rsy.RegistrationYear = @RegistrationYear;

			if @@rowcount = 0
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotConfigured'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
				 ,@Arg1 = '"Registration Schedule Year"';

				raiserror(@errorText, 17, 1);
			end;

		end;

		-- for term permits the expiry time defaults based on the 
		-- the number of days specified for the permit (user can 
		-- override the length by passing an expiry time)

		if @ExpiryTime is null and @practiceRegisterTypeSCD = 'TERM.PERMIT'
		begin
			set @ExpiryTime = dateadd(day, @termPermitDays, cast(@EffectiveTime as date));
		end;

		-- finally ensure effective and expiry time values are set
		-- to start-of-day and end-of-day time values unless they
		-- are for the current day in which case current time is used

		exec sf.pEffectiveExpiry#Set
			@EffectiveTime = @EffectiveTime output
		 ,@ExpiryTime = @ExpiryTime output;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;

GO
