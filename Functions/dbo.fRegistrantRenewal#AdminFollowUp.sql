SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantRenewal#AdminFollowUp
(
	@RegistrationYear						smallint	-- (base) registration year - REQUIRED (defaults to current year)
 ,@PracticeRegisterSID				int				-- optional filter - restrict to a specific Register
 ,@PracticeRegisterSectionSID int				-- optional filter - restrict to a specific Section on the Register
 ,@ReasonSID									int				-- optional filter - restrict to a specific form blocking reason
)
returns @adminFollowUp table
(
	RegistrantSID								 int							 not null
 ,RegistrantRenewalSID				 int							 not null
 ,RegistrationSID							 int							 not null
 ,PracticeRegisterSID					 int							 not null
 ,PracticeRegisterLabel				 nvarchar(35)			 not null
 ,PracticeRegisterSectionSID	 int							 not null
 ,PracticeRegisterSectionLabel nvarchar(35)			 not null
 ,RegistrationYear						 smallint					 not null
 ,NextFollowUp								 date							 null
 ,LastName										 nvarchar(35)			 not null
 ,FirstName										 nvarchar(30)			 not null
 ,MiddleNames									 nvarchar(20)			 null
 ,RegistrantNo								 varchar(50)			 not null
 ,IsRenewalAutoApprovalBlocked bit							 not null
 ,ReasonSID										 int							 null
 ,ReasonName									 nvarchar(50)			 null
 ,InvoiceSID									 int							 null
 ,IsInProgress								 bit							 not null
 ,FormStatusSCD								 varchar(25)			 not null
 ,FormStatusLabel							 nvarchar(35)			 not null
 ,FormOwnerSCD								 varchar(25)			 not null
 ,FormOwnerLabel							 nvarchar(35)			 not null
 ,StatusUser									 nvarchar(75)			 not null
 ,StatusTime									 datetimeoffset(7) not null
)
/*********************************************************************************************************************************
Function	: Registrant Renewal - Admin Follow-Up
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Returns latest status information for a registrant renewal
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| May 2018		|	Initial version

Comments	
--------
This table function modularizes the logic to locate renewal records for administrative follow-up. The table function is used
both as the basis of queries during the renewal period, and as a basis for reporting.  When used as a query source on the 
Registration Search page only the RegistrationSID value needs to be returned.  Joins to some master tables that are required
for reporting are avoided within the table function to improve performance.

The function requires specification of a Registration Year.  The @RegistrationYear is for the base-registration associated with 
the renewal. The renewal records themselves will typically have the next Registration Year on them but the base registration, 
registration year is used for consistency with the year selected on the Registration Search page.

The basic search selects any renewal record which is not in final status, and, where the form-owner is "ADMIN" or where the 
follow-up date has passed.

The remaining parameters are optional but can be used to further restrict the records returned to a register, blocking reason, 
etc. 

Example
-------
!<TestHarness>
<Test Name = "Select100" Description="Select a sample set of records from the function.">
<SQLScript>
<![CDATA[
	select top (100)
		 x.RegistrantSID
		,x.RegistrantRenewalSID
		,x.RegistrationSID
		,x.PracticeRegisterSID
		,x.PracticeRegisterLabel
		,x.PracticeRegisterSectionSID
		,x.PracticeRegisterSectionLabel
		,x.RegistrationYear
		,x.NextFollowUp
		,x.LastName
		,x.FirstName
		,x.MiddleNames
		,x.RegistrantNo
		,x.IsRenewalAutoApprovalBlocked
		,x.ReasonSID
		,x.ReasonName
		,x.InvoiceSID
		,x.IsInProgress
		,x.FormStatusSCD
		,x.FormStatusLabel
		,x.FormOwnerSCD
		,x.FormOwnerLabel
		,x.StatusUser
		,x.StatusTime
	from
		dbo.fRegistrantRenewal#AdminFollowUp(null, null, null, null) x
]]>
</SQLScript>
<Assertions>
	<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
	<Assertion Type="ExecutionTime" Value="00:00:05" />
</Assertions>
</Test>
!</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.fRegistrantRenewal#AdminFollowUp'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		@OFF	 bit			= cast(0 as	bit)	-- constant for bit comparison = 0
	 ,@today datetime = sf.fToday();		-- date in user time zone for follow-up comparisons

	if @RegistrationYear is null
	begin
		set @RegistrationYear = dbo.fRegistrationYear#Current();
	end;

	insert
		@adminFollowUp
	(
		RegistrantSID
	 ,RegistrantRenewalSID
	 ,RegistrationSID
	 ,PracticeRegisterSID
	 ,PracticeRegisterLabel
	 ,PracticeRegisterSectionSID
	 ,PracticeRegisterSectionLabel
	 ,RegistrationYear
	 ,NextFollowUp
	 ,LastName
	 ,FirstName
	 ,MiddleNames
	 ,RegistrantNo
	 ,IsRenewalAutoApprovalBlocked
	 ,ReasonSID
	 ,ReasonName
	 ,InvoiceSID
	 ,IsInProgress
	 ,FormStatusSCD
	 ,FormStatusLabel
	 ,FormOwnerSCD
	 ,FormOwnerLabel
	 ,StatusUser
	 ,StatusTime
	)
	select
		reg.RegistrantSID
	 ,rr.RegistrantRenewalSID
	 ,rr.RegistrationSID
	 ,prs.PracticeRegisterSID
	 ,pr.PracticeRegisterLabel
	 ,rr.PracticeRegisterSectionSID
	 ,prs.PracticeRegisterSectionLabel
	 ,rr.RegistrationYear
	 ,rr.NextFollowUp
	 ,p.LastName
	 ,p.FirstName
	 ,p.MiddleNames
	 ,r.RegistrantNo
	 ,r.IsRenewalAutoApprovalBlocked
	 ,rr.ReasonSID
	 ,rsn.ReasonName
	 ,rr.InvoiceSID
	 ,cs.IsInProgress
	 ,cs.FormStatusSCD
	 ,cs.FormStatusLabel
	 ,cs.FormOwnerSCD
	 ,cs.FormOwnerLabel
	 ,cs.LastStatusChangeUser
	 ,cs.LastStatusChangeTime
	from
		dbo.fRegistrant#LatestRegistration(-1, @RegistrationYear)								 reg -- start with latest registrations for the target year
	join
		dbo.RegistrantRenewal																										 rr on reg.RegistrationSID = rr.RegistrationSID
	join
		dbo.PracticeRegisterSection																							 prs on rr.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister																										 pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
	join
		dbo.Registrant																													 r on reg.RegistrantSID = r.RegistrantSID
	join
		sf.Person																																 p on r.PersonSID = p.PersonSID
	cross apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) cs
	left outer join
		dbo.Reason																	rsn on rr.ReasonSID = rsn.ReasonSID
	outer apply dbo.fInvoice#Total(rr.InvoiceSID) it
	where
		cs.IsFinal																															= @OFF -- not already in final form
		and
		(
			cs.FormOwnerSCD																												= 'ADMIN' or rr.NextFollowUp <= @today -- basic selection
		)
		and
		(
			@PracticeRegisterSID is null or prs.PracticeRegisterSID								= @PracticeRegisterSID -- optional filter criteria
		)
		and
		(
			@PracticeRegisterSectionSID is null or prs.PracticeRegisterSectionSID = @PracticeRegisterSectionSID
		)
		and (@ReasonSID is null or rr.ReasonSID																	= @ReasonSID);

	return;

end;
GO
