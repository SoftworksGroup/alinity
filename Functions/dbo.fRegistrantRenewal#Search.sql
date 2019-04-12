SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.fRegistrantRenewal#Search (@RegistrationYear smallint) -- registration year to return registrations for (not renewal year)
returns table
/*********************************************************************************************************************************
Function: Registrant Renewal - Search
Notice  : Copyright © 2017 Softworks Group Inc.
Summary	: Returns the all registrants who are expected to renew for a given year and their renewal form status
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Oct 2017			|	Initial Version (based on view originally developed by Tim and Cory for same purpose)
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is intended for management of Registrant Renewals but is based on Registration.  The change in base entity
is required in order to show not only registrants who have, or are in the process of renewing, but also those registrants
who are expected to renew.  Every registrant who has a registration is expected to renew the following year unless their registration
is on a register that does not allow renewal (e.g. "temporary permits").  

The function cannot be run without the Registration Year (of licensing) as the base selection criteria.

The function is designed to allow renewals from not only the current year to be selected, but also renewals from previous years.
It is possible to use the function, for example, to find out who did not complete their renewal 5 years ago. 

Because of the design of the function which must report on renewals which have not yet started, and because some APPROVED forms 
are treated as open, the Form Status Label and Form Owner Label are overridden where no renewal is started and where the
form is approved but not paid or a registration has not yet been issued.

Maintenance Note
----------------
A search sproc - pRegistrantRenewal#SearchCT depends on the structure of this function so do not modify this structure without
checking the dependencies in the sproc first.

Example
-------
<TestHarness>
	<Test Name="One" Description="returns 1 record" >
		<SQLScript>
			<![CDATA[

									declare
					 @applicationUserSID					int
					,@userName										nvarchar(75)
					,@registrationSID				int
					,@personSID										int
					,@formVersionSID							int
					,@invoiceSID									int
					,@glAccountCode								varchar(10) = '201'
					,@practiceRegisterLabel				varchar(15) = 'Active'
					,@registrantRenewalSID				int
					,@registrantSID								int
					,@formStatusSID								int
					,@practiceRegisterSectionSID	int
					,@responseXML									xml
					,@registrationYear						int
					,@nextRegistrationYear				int
					,@registrationScheduleSID int

				select 
						@registrationYear			= dbo.fRegistrationYear#Current()
					,	@nextRegistrationYear = dbo.fRegistrationYear#Current() + 1

				begin tran
					

					-- Set up test data

					select top 1
							@personSID								= p.PersonSID
						,	@registrantSID						= r.RegistrantSID
					from
						dbo.Registrant r 
					join
						sf.Person p on r.PersonSID	= p.PersonSID
					order by
						newid()

					select
						@practiceRegisterSectionSID		= prs.PracticeRegisterSectionSID
					from
						dbo.PracticeRegister pr
					join
						dbo.PracticeRegisterSection prs on prs.PracticeRegisterSID =  pr.PracticeRegisterSID
					where
						prs.IsDefault = cast(1 as bit)
					and
						pr.PracticeRegisterLabel = @practiceRegisterLabel

					select top 1
						@formVersionSID = fv.FormVersionSID
					from
						sf.FormVersion fv
					order by
						newid()
					
					select
						@formStatusSID = fs.FormStatusSID
					from
						sf.FormStatus fs
					where
						fs.FormStatusSCD = 'Approved'

				if not exists ( select 1 from dbo.RegistrationScheduleYear rsy where rsy.RegistrationYear = @nextRegistrationYear)
				begin
						

						select
							@registrationScheduleSID = rs.RegistrationScheduleSID
						from
							dbo.RegistrationSchedule rs
						where
							rs.IsDefault = cast(1 as bit)

					insert
						dbo.RegistrationScheduleYear
					(
						RegistrationScheduleSID
					 ,RegistrationYear
					 ,YearStartTime
					 ,YearEndTime
					 ,RenewalVerificationOpenTime
					 ,RenewalGeneralOpenTime
					 ,RenewalLateFeeStartTime
					 ,RenewalEndTime
					 ,ReinstatementVerificationOpenTime
					 ,ReinstatementGeneralOpenTime
					 ,ReinstatementEndTime
					 ,PAPBlockStartTime
					 ,PAPBlockEndTime
					 ,CreateUser
					 ,UpdateUser
					)
					select
						@registrationScheduleSID
					 ,@registrationYear																																								 RegistrationYear
					 ,dateadd(year, (@nextRegistrationYear - rsy.RegistrationYear), rsy.YearStartTime)										 YearStartTime
					 ,dateadd(year, (@nextRegistrationYear - rsy.RegistrationYear), rsy.YearEndTime)											 YearEndTime
					 ,dateadd(year, (@nextRegistrationYear - rsy.RegistrationYear), rsy.RenewalVerificationOpenTime)			 RenewalVerificationOpenTime
					 ,dateadd(year, (@nextRegistrationYear - rsy.RegistrationYear), rsy.RenewalGeneralOpenTime)						 RenewalGeneralOpenTime
					 ,dateadd(year, (@nextRegistrationYear - rsy.RegistrationYear), rsy.RenewalLateFeeStartTime)					 RenewalLateFeeStartTime
					 ,dateadd(year, (@nextRegistrationYear - rsy.RegistrationYear), rsy.RenewalEndTime)										 RenewalEndTime
					 ,dateadd(year, (@nextRegistrationYear - rsy.RegistrationYear), rsy.ReinstatementVerificationOpenTime) ReinstatementVerificationOpenTime
					 ,dateadd(year, (@nextRegistrationYear - rsy.RegistrationYear), rsy.ReinstatementGeneralOpenTime)			 ReinstatementGeneralOpenTime
					 ,dateadd(year, (@nextRegistrationYear - rsy.RegistrationYear), rsy.ReinstatementEndTime)							 ReinstatementEndTime
					 ,dateadd(year, (@nextRegistrationYear - rsy.RegistrationYear), rsy.PAPBlockStartTime)								 PAPBlockStartTime
					 ,dateadd(year, (@nextRegistrationYear - rsy.RegistrationYear), rsy.PAPBlockEndTime)									 PAPBlockEndTime
					 ,rsy.CreateUser
					 ,rsy.UpdateUser
					from
						dbo.RegistrationScheduleYear rsy
					join
					(
						select
							min(rsy.RegistrationScheduleYearSID) RegistrationScheduleYearSID
						 ,min(rsy.RegistrationYear)						 RegistrationYear
						from
							dbo.RegistrationScheduleYear rsy
						where
							rsy.RegistrationYear > @registrationYear
					)															 x on rsy.RegistrationScheduleYearSID = x.RegistrationScheduleYearSID;
				end

				
				if not exists ( select 1 from dbo.RegistrationScheduleYear rsy where rsy.RegistrationYear = @registrationYear)
				begin
						
	

						select
							@registrationScheduleSID = rs.RegistrationScheduleSID
						from
							dbo.RegistrationSchedule rs
						where
							rs.IsDefault = cast(1 as bit)

					insert
						dbo.RegistrationScheduleYear
					(
						RegistrationScheduleSID
					 ,RegistrationYear
					 ,YearStartTime
					 ,YearEndTime
					 ,RenewalVerificationOpenTime
					 ,RenewalGeneralOpenTime
					 ,RenewalLateFeeStartTime
					 ,RenewalEndTime
					 ,ReinstatementVerificationOpenTime
					 ,ReinstatementGeneralOpenTime
					 ,ReinstatementEndTime
					 ,PAPBlockStartTime
					 ,PAPBlockEndTime
					 ,CreateUser
					 ,UpdateUser
					)
					select
						@registrationScheduleSID
					 ,@registrationYear																																								 RegistrationYear
					 ,dateadd(year, (@registrationYear - rsy.RegistrationYear), rsy.YearStartTime)										 YearStartTime
					 ,dateadd(year, (@registrationYear - rsy.RegistrationYear), rsy.YearEndTime)											 YearEndTime
					 ,dateadd(year, (@registrationYear - rsy.RegistrationYear), rsy.RenewalVerificationOpenTime)			 RenewalVerificationOpenTime
					 ,dateadd(year, (@registrationYear - rsy.RegistrationYear), rsy.RenewalGeneralOpenTime)						 RenewalGeneralOpenTime
					 ,dateadd(year, (@registrationYear - rsy.RegistrationYear), rsy.RenewalLateFeeStartTime)					 RenewalLateFeeStartTime
					 ,dateadd(year, (@registrationYear - rsy.RegistrationYear), rsy.RenewalEndTime)										 RenewalEndTime
					 ,dateadd(year, (@registrationYear - rsy.RegistrationYear), rsy.ReinstatementVerificationOpenTime) ReinstatementVerificationOpenTime
					 ,dateadd(year, (@registrationYear - rsy.RegistrationYear), rsy.ReinstatementGeneralOpenTime)			 ReinstatementGeneralOpenTime
					 ,dateadd(year, (@registrationYear - rsy.RegistrationYear), rsy.ReinstatementEndTime)							 ReinstatementEndTime
					 ,dateadd(year, (@registrationYear - rsy.RegistrationYear), rsy.PAPBlockStartTime)								 PAPBlockStartTime
					 ,dateadd(year, (@registrationYear - rsy.RegistrationYear), rsy.PAPBlockEndTime)									 PAPBlockEndTime
					 ,rsy.CreateUser
					 ,rsy.UpdateUser
					from
						dbo.RegistrationScheduleYear rsy
					join
					(
						select
							min(rsy.RegistrationScheduleYearSID) RegistrationScheduleYearSID
						 ,min(rsy.RegistrationYear)						 RegistrationYear
						from
							dbo.RegistrationScheduleYear rsy
						where
							rsy.RegistrationYear > @registrationYear
					)															 x on rsy.RegistrationScheduleYearSID = x.RegistrationScheduleYearSID;
				end


				insert into dbo.Registration
				(
						RegistrantSID
					,	PracticeRegisterSectionSID
					,	LicenseNO
					,	RegistrationYear
					,	EffectiveTime
					,	ExpiryTime
				)
				select
						@registrantSID
					,	@practiceRegisterSectionSID
					,	'*** TEST LICENSE ***'
					,	@registrationYear
					,ltrim(@registrationYear) + '-01-01'
					,ltrim(@registrationYear) + '-12-31'

				set @registrationSID = scope_identity()

				insert into dbo.Invoice
				(
						PersonSID
					,	InvoiceDate
					,	Tax1Label
					,	Tax1Rate
					,	Tax1GLAccountCode
					,	Tax2Label
					,	Tax2Rate
					,	Tax2GLAccountCode
					,	Tax3Label
					,	Tax3Rate
					,	Tax3GLAccountCode
					,	RegistrationYear
				)
				select
						@personSID
					,	sf.fNow()
					,	x.Tax1Label
					,	x.Tax1Rate
					,	x.Tax1GLAccountCode
					,	x.Tax2Label
					,	x.Tax2Rate
					,	x.Tax2GLAccountCode
					,	x.Tax3Label
					,	x.Tax3Rate
					,	x.Tax3GLAccountCode
					,	@nextRegistrationYear
				from
					dbo.fTaxRates() x
			
				set @invoiceSID = scope_identity()

				insert into dbo.InvoiceItem
				(
					InvoiceSID
					,InvoiceItemDescription
					,Price
					,Quantity
					,GLAccountCode
					,SourceGUID
				)
				select
						@invoiceSID
					,	'*** TEST INVOICE ITEM ***'
					,	1.01
					,	1
					,	@GLAccountCode
					, newid()

					insert into dbo.RegistrantRenewal
					(
							RegistrationSID
						,	FormVersionSID
						,	FormResponseDraft
						,	AdminComments
						, PracticeRegisterSectionSID
						,	RegistrationYear
						, InvoiceSID
					)
					select
							@registrationSID 
						,	@formVersionSID 
						,	'<FormReseponse/>' 
						, '<AdminComments/>' 
						,	@PracticeRegisterSectionSID 
						,	@nextRegistrationYear 
						, @invoiceSID

					set @registrantRenewalSID = scope_identity()

					insert into dbo.RegistrantRenewalStatus
					(
							RegistrantRenewalSID
						,	FormstatusSID
					)
					select
							@registrantRenewalSID
						,	@formStatusSID

					select
							x.FormStatusSID
						,	x.FormStatusSCD			
						,	x.FormStatusLabel		
						,	x.FormOwnerSCD			
						,	x.FormOwnerLabel		
						,	x.RegistrationYear
						,	x.PracticeRegisterSectionLabel
						,	x.PracticeRegisterLabel
						,	x.IsActivePractice
						,	x.IsRegisterChange
						,	x.PracticeRegisterLabelTo
						,	x.IsActivePractice
						,	x.IsNotStarted
						,	x.IsAutoApprovalBlocked
						,	x.InvoiceNo
						,	x.TotalDue
						,	x.IsUnPaid
						,	x.RenewedRegistrationNo
						,	x.IsPDFGenerated
						,	x.PersonDocSID
						,	x.IsPDFRequired
						,	x.IsPAPSubscriber
						,	x.RenewedWeekEndingDate
						,	x.LicenseExpiryTime
					from
						dbo.fRegistrantRenewal#Search(@registrationYear) x
					where
						x.RegistrantSID = @registrantSID


				if @@ROWCOUNT = 0 raiserror('* ERROR: no data found for test case',16,1) 
				if @@TRANCOUNT > 0 rollback

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ScalarValue"	ResultSet="1" Row="1" Column="2" Value="APPROVED" />
			<Assertion Type="ScalarValue"	ResultSet="1" Row="1" Column="3" Value="Approved (not paid)" />
			<Assertion Type="ScalarValue"	ResultSet="1" Row="1" Column="4" Value="REGISTRANT" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="5" Value="Registrant"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="7" Value="Active Default"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="8" Value="Active"/>
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
	<Test Name="All" IsDefault="True"  Description="returns all records for the current year">
		<SQLScript>
			<![CDATA[

				select
						x.RegistrationSID
					,	x.RegistrantSID
					,	x.RegistrantNo
					,	x.RegistrantRenewalSID
					,	x.RegistrantLabel
					,	x.FormStatusSID
					,	x.FormStatusSCD			
					,	x.FormStatusLabel		
					,	x.FormOwnerSCD			
					,	x.FormOwnerLabel		
					,	x.PersonSID
					,	x.FirstName
					,	x.MiddleNames
					,	x.LastName
					,	x.EmailAddress
					,	x.RegistrationYear
					,	x.PracticeRegisterSectionLabel
					,	x.PracticeRegisterSID
					,	x.PracticeRegisterLabel
					,	x.IsActivePractice
					,	x.IsRegisterChange
					,	x.PracticeRegisterLabelTo
					,	x.IsActivePractice
					, x.NextFollowUp
					,	x.IsFollowUpDue
					,	x.IsNotStarted
					,	x.IsAutoApprovalBlocked
					,	x.AutoApprovalInfo
					,	x.ReasonSID
					,	x.InvoiceNo
					,	x.TotalDue
					,	x.IsUnPaid
					,	x.RenewedRegistrationNo
					,	x.IsPDFGenerated
					,	x.PersonDocSID
					,	x.IsPDFRequired
					,	x.IsPAPSubscriber
					,	x.LastStatusChangeUser
					,	x.LastStatusChangeTime
					,	x.LicenseCreateTime
					,	x.RenewedWeekEndingDate
					,	x.LicenseExpiryTime
					,	x.RegistrantRenewalXID
					,	x.LegacyKey
				from
					dbo.fRegistrantRenewal#Search(year(sf.fNow())) x

				if @@ROWCOUNT = 0 raiserror( N'* ERROR: no sample data found to run test', 18, 1)

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1" />
			<Assertion Type="ExecutionTime" Value="00:00:80"/>
		</Assertions>
	</Test>	
</TestHarness>

exec sf.pUnitTest#Execute
  @ObjectName = 'dbo.fRegistrantRenewal#Search'
 ,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */
as
return
(
	select
		rl.RegistrationSID
	 ,r.RegistrantSID
	 ,rr.RegistrantRenewalSID
	 ,r.RegistrantNo
	 ,dbo.fRegistrant#Label(p.LastName, p.FirstName, p.MiddleNames, r.RegistrantNo, 'RENEWAL')							 RegistrantLabel
	 ,aas.FormStatusSID																																																								-- the label has an override but not the code or SID (used for searching)
	 ,aas.FormStatusSCD
	 ,case
		when aas.FormStatusSCD is null then 'Not Started'
		when aas.FormStatusSCD = 'APPROVED' and it.TotalDue > 0.00 then 'Approved (not paid)'
		when aas.FormStatusSCD = 'APPROVED' and rlNext.RegistrationSID is null then 'Approved (no ' + ltrim(rl.RegistrationYear + 1) + ' registration)' -- this is an anomaly condition
		when aas.FormStatusSCD = 'APPROVED' then 'Complete'
		when aas.FormStatusSCD = 'NEW' then 'Started (not submitted)'
		when aas.FormStatusSCD = 'SUBMITTED' or aas.FormStatusSCD = 'UNLOCKED' then 'Reviewing (admin)'
		else aas.FormStatusLabel
		end																																																		 FormStatusLabel					-- override where no form exists and approved but not finalized
	 ,case
		when aas.FormStatusSCD is null then 'REGISTRANT'																				 -- override owner for scenarios after approval; not paid, no registration
		when aas.FormStatusSCD = 'APPROVED' and it.TotalDue > 0.00 then 'REGISTRANT'
		when aas.FormStatusSCD = 'APPROVED' and rlNext.RegistrationSID is null then 'ADMIN' -- this is an anomaly condition
		else aas.FormOwnerSCD
		end																																																		 FormOwnerSCD
	 ,case
		when aas.FormOwnerSCD is null or (aas.FormOwnerSCD = 'NONE' and it.TotalDue > 0.00) then 'Registrant'
		when aas.FormStatusSCD = 'APPROVED' and rlNext.RegistrationSID is null then 'Admin' -- this is an anomaly condition
		else aas.FormOwnerLabel
		end																																																		 FormOwnerLabel						-- override where form not started or 'NONE' and invoice unpaid 
	 ,p.PersonSID
	 ,p.FirstName
	 ,p.MiddleNames
	 ,p.LastName
	 ,pea.EmailAddress
	 ,rl.RegistrationYear																																																							-- the main search criteria column for renewal management
	 ,prs.PracticeRegisterSectionSID
	 ,prs.PracticeRegisterSectionLabel
	 ,pr.PracticeRegisterSID
	 ,pr.PracticeRegisterLabel
	 ,pr.IsActivePractice
	 ,(case
		 when pr.PracticeRegisterSID <> isnull(pr2.PracticeRegisterSID, pr.PracticeRegisterSID) then cast(1 as bit)
		 else cast(0 as bit)
		 end
		)																																																			 IsRegisterChange					-- indicates if renewal is to a different register
	 ,pr2.PracticeRegisterLabel																																							 PracticeRegisterLabelTo	-- name for the register of the renewed registration
	 ,pr2.IsActivePractice																																									 IsActivePracticeTo				-- indicates whether the register they are renewing to is an active practice
	 ,rr.NextFollowUp
	 ,cast((case when rr.NextFollowUp <= sf.fToday() then 1 else 0 end) as bit)															 IsFollowUpDue
	 ,cast((case when rr.RegistrantRenewalSID is null then 1 else 0 end) as bit)														 IsNotStarted
	 ,case
		when aas.FormStatusSCD = 'SUBMITTED' and aas.IsAutoApprovalPending = cast(0 as bit) then cast(1 as bit)
		else cast(0 as bit)
		end																																																		 IsAutoApprovalBlocked		-- to support a search filter on blocked approvals
	 ,case
		when aas.FormStatusSCD = 'SUBMITTED' and aas.IsAutoApprovalPending = cast(0 as bit) then aas.ReasonName
		else cast(null as nvarchar(50))
		end																																																		 AutoApprovalInfo					-- show on UI as info button only when auto-approval is blocked
	 ,aas.ReasonSID																																																										-- system blocking reasons override reasons in the form
	 ,rr.InvoiceSID																																													 InvoiceNo
	 ,it.TotalDue
	 ,cast(it.TotalDue as bit)																																							 IsUnPaid									-- to support a search filter on unpaid invoice amounts
	 ,rlNext.RegistrationNo																																											 RenewedRegistrationNo					-- allows confirmation that a registration has been generated
	 ,cast(isnull(pdc.PersonDocContextSID, 0) as bit)																												 IsPDFGenerated						-- controls where PDF icon display in UI
	 ,pdc.PersonDocSID
	 ,case
		when aas.FormStatusSCD = 'APPROVED' and pdc.PersonDocContextSID is null then cast(1 as bit)
		else cast(0 as bit)
		end																																																		 IsPDFRequired						-- to support search filter on records requiring PDF generation
	 ,cast(isnull(ps.PAPSubscriptionSID, 0) as bit)																													 IsPAPSubscriber					-- indicates this person is a current subscriber to the pre-authorized payment program
	 ,aas.CreateUser																																												 LastStatusChangeUser
	 ,aas.CreateTime																																												 LastStatusChangeTime
	 ,rlNext.CreateTime																																											 LicenseCreateTime
	 ,convert(varchar(50), (dateadd(dd, @@datefirst - datepart(dw, rlNext.CreateTime) - 6, getdate())), 101) RenewedWeekEndingDate
	 ,rl.ExpiryTime																																													 LicenseExpiryTime
	 ,rr.RegistrantRenewalXID
	 ,rr.LegacyKey
	from
		dbo.Registration																												 rl
	join
	(
		select
			rl.RegistrantSID
		 ,rl.RegistrationYear
		 ,max(rl.RegistrationSID) RegistrationSID
		from
			dbo.Registration rl
		where
			rl.RegistrationYear = @RegistrationYear
		group by
			rl.RegistrantSID
		 ,rl.RegistrationYear
	)																																							 rlMx on rl.RegistrationSID = rlMx.RegistrationSID
	join
		dbo.Registrant																															 r on rl.RegistrantSID = r.RegistrantSID
	join
		sf.Person																																		 p on r.PersonSID = p.PersonSID
	join
		dbo.PracticeRegisterSection																									 prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
	join
		dbo.PracticeRegister																												 pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
	join
		sf.ApplicationEntity																												 ae on ae.ApplicationEntitySCD = 'dbo.RegistrantRenewal'
	left outer join
		dbo.RegistrantRenewal																												 rr on rl.RegistrationSID = rr.RegistrationSID
	left outer join
		dbo.PAPSubscription																													 ps on p.PersonSID = ps.PersonSID and ps.CancelledTime is null
	left outer join
		dbo.PersonDocContext																												 pdc on ae.ApplicationEntitySID = pdc.ApplicationEntitySID
																																												and rr.RegistrantRenewalSID = pdc.EntitySID
																																												and pdc.IsPrimary = cast(1 as bit)
	left outer join
		sf.PersonEmailAddress																												 pea on p.PersonSID = pea.PersonSID and pea.IsActive = cast(1 as bit) and pea.IsPrimary = cast(1 as bit)
	left outer join
		dbo.Registration																												 rlNext on rlNext.RegistrationNo = r.RegistrantNo + '.' + ltrim(rl.RegistrationYear + 1) + '.1' -- renewal must be sequence #1
	left outer join
		dbo.PracticeRegisterSection																									 prs2 on rr.PracticeRegisterSectionSID = prs2.PracticeRegisterSectionSID
	left outer join
		dbo.PracticeRegister																												 pr2 on prs2.PracticeRegisterSID = pr2.PracticeRegisterSID
	outer apply dbo.fRegistrantRenewal#AutoApprovalStatus(rr.RegistrantRenewalSID) aas
	outer apply dbo.fInvoice#Total(rr.InvoiceSID) it
	left outer join
		dbo.Reason rsn on aas.SystemReasonCode = rsn.ReasonCode -- check for system blocking reason returned from function
	where
		rl.RegistrationYear			= @RegistrationYear -- has a registration in the selected registration year
		and pr.IsRenewalEnabled = cast(1 as bit) -- the register allows renewal
);
GO
