SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fReinstatementPeriod#IsOpen
(
	@RegistrantSID		int				-- key of the reinstatement period status is being looked up for
 ,@RegistrationYear smallint	-- registration year to check if reinstatement is open at the current time
)
returns bit
as
/*********************************************************************************************************************************
Sproc    : Reinstatement - (Period) Is Open
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Returns a bit indicating whether the Reinstatement period is open for the given registration year at the current time
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Dec 2018		|	Initial version

Comments	
--------
This function is used throughout the application to indicate whether the reinstatement period is currently open.  The function takes 
into consideration time values only and does not look to see whether a reinstatement form is already in place for the registrant
and/or whether or not the member is on a register that allows reinstatement. This function is used in more generic scenarios such
as payment of reinstatement invoices is permitted which is determined on time only.  Note that the function does consider
whether or not the member is an early verifier or has been granted a reinstatement extension.

If the registration year is passed in as NULL, then the NEXT registration year is assumed to be the one for which the reinstatement
schedule is applied.  Otherwise, the reinstatement open and closed date-times are looked up for the year provided.

The @RegistrantSID parameter should normally be provided.  The function checks to see if the given registrant is a reinstatement 
verifier (has an earlier reinstatement start date) or has been granted a reinstatement extension (later end date). If no registrant key
is provided the function will based its return value on whether the current time is within the open period only (useful in
some reporting scenarios).

LIMITATIONS
-----------
The function does not check if the registrant already has an open reinstatement for the given year or whether they are currently
on a register that allows reinstatement. DO NOT add these criteria to this function since the function is used in contexts such
as determining whether a reinstatement invoice can still be paid which must not be subject to those additional criteria.

Example
-------
<TestHarness>
  <Test Name = "Random" IsDefault ="true" Description="Executes the function for 10 registrants selected at random (current)">
    <SQLScript>
      <![CDATA[

select
	r.RegistrantLabel
 ,dbo.fReinstatementPeriod#IsOpen(r.RegistrantSID, null) IsReinstatementPeriodOpen
from
(
	select top (10)
		r.RegistrantSID
	from
		dbo.Registrant r
	order by
		newid()
)									x
join
	dbo.vRegistrant r on x.RegistrantSID = r.RegistrantSID;

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:03:00"/>
    </Assertions>
  </Test>
  <Test Name = "ReinstatementInvoices" Description="Executes the function for (max) 10 unpaid reinstatement invoices selected at random">
    <SQLScript>
      <![CDATA[
select
	r.RegistrantLabel
 ,x.InvoiceSID
 ,r.PersonSID
 ,x.RegistrationSID
 ,x.RegistrationYear
 ,dbo.fReinstatementPeriod#IsOpen(reg.RegistrantSID, x.RegistrationYear) IsReinstatementPeriodOpen
from
(
	select top (10)
		rr.InvoiceSID
	 ,rr.RegistrationSID
	 ,rr.RegistrationYear
	from
		dbo.Reinstatement												rr
	cross apply dbo.fInvoice#Total(rr.InvoiceSID) it
	where
		it.TotalDue > 0
	order by
		newid()
)									 x
join
	dbo.Registration reg on x.RegistrationSID = reg.RegistrationSID
join
	dbo.vRegistrant	 r on reg.RegistrantSID		= r.RegistrantSID;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:10:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.fReinstatementPeriod#IsOpen'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@isOpen								 bit			= cast(0 as bit)													-- return value
	 ,@ON										 bit			= cast(1 as bit)													-- constant for bit comparisons = 1
	 ,@OFF									 bit			= cast(0 as bit)													-- constant for bit comparison = 0
	 ,@currentTime					 datetime = sf.fNow()																-- current time in user time zone
	 ,@isCurrentUserVerifier bit			= sf.fIsGranted('EXTERNAL.VERIFICATION'); -- indicates whether current user is an early verifier

	if @RegistrationYear is null
	begin
		set @RegistrationYear = dbo.fRegistrationYear#Current(); -- defaults to "current" registration year
	end;

	select
		@isOpen =
		(case
			 when @currentTime between (case
																		when @isCurrentUserVerifier = @ON then rsy.ReinstatementVerificationOpenTime -- verifiers have earlier reinstatement start
																		else rsy.ReinstatementGeneralOpenTime
																	end
																 ) and rsy.ReinstatementEndTime then @ON -- current time falls in open reinstatement period
			 else @OFF
		 end
		)
	from
		dbo.RegistrationSchedule		 rs
	join
		dbo.RegistrationScheduleYear rsy on rs.RegistrationScheduleSID = rsy.RegistrationScheduleSID and rsy.RegistrationYear = @RegistrationYear
	left outer join
		dbo.Registrant							 r on r.RegistrantSID							 = @RegistrantSID
	where
		rs.IsDefault = @ON;

	return (@isOpen);

end;
GO
