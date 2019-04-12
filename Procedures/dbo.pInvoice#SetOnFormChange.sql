SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pInvoice#SetOnFormChange
	@FormTypeCode					 varchar(15)							-- must be one of: APPLICATION, RENEWAL, REINSTATEMENT 
 ,@RegistrationRecordSID int											-- key of a form record (e.g. dbo.RegistrantApp, dbo.RegistrantRenewal, etc.)
 ,@ReasonSID						 int = null								-- optional reason why the form was approved to assign on the Registration record
 ,@InvoiceSID						 int = null output				-- key of invoice record found or inserted
 ,@RegistrationSID			 int = null output				-- key of new registration created (if any)
 ,@FormStatusSCD				 varchar(25) = 'APPROVED' -- form status event invoice is required for
 ,@ReturnDataSet				 bit = 0									-- when 1 the key of the new invoice is returned as a data set
as

/*********************************************************************************************************************************
Procedure	: Invoice - set New
Notice		: Copyright © 2017 Softworks Group Inc.
Summary		: Creates a new invoice for registration actions including Application, Renewal and Reinstatement
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2018		|	Initial version
					: Tim Edlund	| Jun 2018		| Support for FK change to RegistrationSID and on-submit invoicing for applications
					: Tim Edlund	| Sep 2018		| Added support to avoid including catalog items unless "from" register matches condition
					: Tim Edlund	| Oct 2018		| Added support for administrative fees for PAP subscribers
					: Tim Edlund	| Nov 2018		| Moved location of #SetOnPaid to make call where pre-existing invoice exists
					: Tim Edlund	| Dec 2018		| Modified call to $GetDefaults to avoid terminating prior registration on invoice creation
					: Cory Ng			| Apr 2019		| Updated to only assign PAP fees on renewal invoices

Comments	
--------
This procedure generates invoices for the primary registration actions supported by the system.  The procedure is normally called
from within the #Approve procedure of registration form records (Application, Renewal and Reinstatement). For application an 
initial invoice may be generated on the SUBMIT event as an application fee may apply prior to the registration fee being charged 
on approval.

It is also possible for Admin's to call this procedure to setup an invoice in advance of a form being approved.  This allows
price adjustments to be made on the invoice prior to the individual completing or paying for their form. 

The @ReturnDataSet parameter controls whether the new invoice SID (primary key) will be returned to the caller for display of 
the invoice.  The calling program must look at the InvoiceSID column from the parent entity to identify which invoice to display 
information for. The invoice values should be displayed on the user interface and where a payment is owing, the user is typically
prompted for credit card payment as a next step when called from client-portal only.

The procedure supports the specific list of @FormTypeCode values identified with the parameter above.  Any other value being 
passed results in an error.

The procedure checks to see if an invoice already exists on the registration record referenced, and if so, an additional invoice 
is NOT generated. No error results in this case as invoices can be created in advance by administrators to support special 
pricing scenarios. 

The main logic of the procedure is to add the invoice and then add a line item for each fee that applies for the given 
registration action (Application, Renewal and Reinstatement).  Fees may be time sensitive (e.g. late fee charges for renewals) and 
may also be pro-rated where applied part-way through the registration year.  

If no fees have been configured for the registration action then an error is raised. If the organization does not want to charge
for a registration action (e.g. free application), at least one active fee must be defined for it which can be set at $0 for
its price.

It is possible for the invoice created to be pre-paid. For renewal invoices, the procedure checks for an applies Pre-Authorized-
Payments (PAP). 

Once the invoice has been generated, its primary key is written back into the source form table - e.g. dbo.RegistrantRenewal, 
dbo.Reinstatement etc.  This write is made without using the EF sprocs to avoid recursion since the top of the call stack
for the transaction is typically the #Update procedure.

Finally the procedure calls the pRegistration#SetOnPaid procedure to check if the invoice is fully paid (as a result of 
pre-pay, PAP or being a $0 invoice) and if so, then creates the new Registration record associated with the parent form.  If
the invoice is not fully paid creation of the registration record is deferred until payment is made.

@ReasonSID
----------
The @ReasonSID parameter is optional and may be passed by the caller to fill-in the ReasonSID on the resulting dbo.Registration
record. The value is normally provided by the @ReasonSIDOnApprove column on the base entity. The value is intended to provide 
explanation as to why the new registration was approved/required if not following a typical process. For example, it may 
provide the reason why a requirement normally required on an application was by-passed in the case of this particular registrant.
The value should generally be provided for Registration-Change forms but will normally be blank for other form types.  

Example
-------
<TestHarness>
	<Test Name = "Select100" Description="Select an approved but not invoiced renewal at random.">
		<SQLScript>
				<![CDATA[
declare
	@registrantRenewalSID int
 ,@invoiceSID						int
 ,@registrantSID				int;

select top (1)
	@registrantRenewalSID = rr.RegistrantRenewalSID
 ,@registrantSID				= rr.RegistrantSID
from
	dbo.vRegistrantRenewal rr
where
	rr.NewFormStatusSCD = 'APPROVED' and rr.InvoiceSID is null
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pInvoice#SetOnFormChange
		@FormTypeCode = 'RENEWAL'
	 ,@RegistrationRecordSID = @registrantRenewalSID
	 ,@InvoiceSID = @invoiceSID output;

	select * from		dbo.vInvoice i where i.InvoiceSID = @invoiceSID;

	select top 5
		*
	from
		dbo.vRegistration reg
	where
		reg.RegistrantSID = @registrantSID
	order by
		reg.RegistrantSID desc;

end;
]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pInvoice#SetOnFormChange'
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo										int							= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText									nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm									varchar(50)												-- tracks if any required parameters are not provided
	 ,@ON													bit							= cast(1 as bit)	-- constant for bit comparison and assignments
	 ,@OFF												bit							= cast(0 as bit)	-- constant for bit comparison and assignments
	 ,@papSubscriptionSID					int																-- key of PAP subscriber (to apply available payments to new invoice)
	 ,@practiceRegisterSID				int																-- the register the fees for the invoice are based on
	 ,@practiceRegisterSectionSID int																-- register section-specific fees for the invoice are based on
	 ,@isActivePractice						bit																-- tracks whether destination register is an active practice type
	 ,@catalogItemSID							int																-- identifier of a specific fee to apply to the invoice
	 ,@personSID									int																-- identifier of the registrant on the invoice
	 ,@registrationYear						smallint													-- year to generate renewal invoice for
	 ,@registrantSID							int																-- key of the registrant the invoice is being created for
	 ,@fromPracticeRegisterSID		int																-- the register the member is moving from 
	 ,@formGUID										uniqueidentifier									-- key of associated form driving the registration change
	 ,@effectiveTime							datetime													-- date new registration will become effective (required for prorated prices)
	 ,@now												datetime				= sf.fNow()				-- current time in the user timezone
	 ,@isLateFeeApplied						bit							= cast(0 as bit)	-- tracks if late fee applies (renewal only)
	 ,@isKeyValid									bit							= cast(0 as bit)	-- tracks if key provided to do the form lookup is valid
	 ,@i													int																-- loop iteration counter
	 ,@maxrow											int;															-- loop limit

	declare @work table (ID int identity(1, 1), CatalogItemSID int not null);

	set @InvoiceSID = null;
	set @RegistrationSID = null;

	begin try

-- SQL Prompt formatting off
		if @RegistrationRecordSID is null	set @blankParm = '@RegistrationRecordSID'
		if @FormTypeCode					is null set @blankParm = '@FormTypeCode';
-- SQL Prompt formatting on

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
		end;

		if @FormTypeCode not in ('APPLICATION', 'RENEWAL', 'REINSTATEMENT', 'REGCHANGE')
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NotInList'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 provided "%2" is not valid. It must be one of: %3'
			 ,@Arg1 = 'fee type code'
			 ,@Arg2 = @FormTypeCode
			 ,@Arg3 = '"APPLICATION", "RENEWAL", "REINSTATEMENT", "REGCHANGE"';

			raiserror(@errorText, 18, 1);
		end;

		-- lookup required values from the registration record for which
		-- the invoice is being created

		if @FormTypeCode = 'APPLICATION'
		begin

			select
				@personSID									= r.PersonSID
			 ,@registrantSID							= r.RegistrantSID
			 ,@InvoiceSID									= ra.InvoiceSID
			 ,@practiceRegisterSectionSID = ra.PracticeRegisterSectionSID
			 ,@practiceRegisterSID				= prsTo.PracticeRegisterSID
			 ,@isActivePractice						= pr.IsActivePractice
			 ,@formGUID										= ra.RowGUID
			 ,@fromPracticeRegisterSID		= prsFr.PracticeRegisterSID
			from
				dbo.RegistrantApp						ra
			join
				dbo.Registration						reg on ra.RegistrationSID								= reg.RegistrationSID
			join
				dbo.Registrant							r on reg.RegistrantSID									= r.RegistrantSID
			join
				dbo.PracticeRegisterSection prsTo on ra.PracticeRegisterSectionSID	= prsTo.PracticeRegisterSectionSID
			join
				dbo.PracticeRegister				pr on prsTo.PracticeRegisterSID					= pr.PracticeRegisterSID
			join
				dbo.PracticeRegisterSection prsFr on reg.PracticeRegisterSectionSID = prsFr.PracticeRegisterSectionSID
			where
				ra.RegistrantAppSID = @RegistrationRecordSID;

			set @isKeyValid = cast(@@rowcount as bit);

		end;
		else if @FormTypeCode = 'RENEWAL'
		begin

			select
				@personSID									= r.PersonSID
			 ,@registrantSID							= reg.RegistrantSID
			 ,@registrationYear						= rr.RegistrationYear
			 ,@InvoiceSID									= rr.InvoiceSID
			 ,@practiceRegisterSID				= prsTo.PracticeRegisterSID
			 ,@practiceRegisterSectionSID = rr.PracticeRegisterSectionSID
			 ,@isActivePractice						= pr.IsActivePractice
			 ,@formGUID										= rr.RowGUID
			 ,@isLateFeeApplied						= (case
																				 when r.LateFeeExclusionYear = rr.RegistrationYear then @OFF -- check for late fee exclusion for this registrant
																				 when rsy.RenewalLateFeeStartTime <= @now then @ON
																				 else @OFF
																			 end
																			)
			from
				dbo.RegistrantRenewal				 rr
			join
				dbo.Registration						 reg on rr.RegistrationSID							 = reg.RegistrationSID
			join
				dbo.PracticeRegisterSection	 prsTo on rr.PracticeRegisterSectionSID	 = prsTo.PracticeRegisterSectionSID
			join
				dbo.PracticeRegister				 pr on prsTo.PracticeRegisterSID				 = pr.PracticeRegisterSID
			join
				dbo.Registrant							 r on reg.RegistrantSID									 = r.RegistrantSID
			join
				dbo.RegistrationScheduleYear rsy on pr.RegistrationScheduleSID			 = rsy.RegistrationScheduleSID and rr.RegistrationYear = rsy.RegistrationYear
			join
				dbo.PracticeRegisterSection	 prsFr on reg.PracticeRegisterSectionSID = prsFr.PracticeRegisterSectionSID
			where
				rr.RegistrantRenewalSID = @RegistrationRecordSID;

			set @isKeyValid = cast(@@rowcount as bit);

		end;
		else if @FormTypeCode = 'REINSTATEMENT'
		begin

			select
				@personSID									= r.PersonSID
			 ,@registrantSID							= reg.RegistrantSID
			 ,@registrationYear						= rin.RegistrationYear
			 ,@InvoiceSID									= rin.InvoiceSID
			 ,@practiceRegisterSID				= prsTo.PracticeRegisterSID
			 ,@practiceRegisterSectionSID = rin.PracticeRegisterSectionSID
			 ,@isActivePractice						= pr.IsActivePractice
			 ,@formGUID										= rin.RowGUID
			 ,@fromPracticeRegisterSID		= prsFr.PracticeRegisterSID
			from
				dbo.Reinstatement						 rin
			join
				dbo.Registration						 reg on rin.RegistrationSID							 = reg.RegistrationSID
			join
				dbo.PracticeRegisterSection	 prsTo on rin.PracticeRegisterSectionSID = prsTo.PracticeRegisterSectionSID
			join
				dbo.PracticeRegister				 pr on prsTo.PracticeRegisterSID				 = pr.PracticeRegisterSID
			join
				dbo.Registrant							 r on reg.RegistrantSID									 = r.RegistrantSID
			join
				dbo.RegistrationScheduleYear rsy on pr.RegistrationScheduleSID			 = rsy.RegistrationScheduleSID and rin.RegistrationYear = rsy.RegistrationYear
			join
				dbo.PracticeRegisterSection	 prsFr on reg.PracticeRegisterSectionSID = prsFr.PracticeRegisterSectionSID
			where
				rin.ReinstatementSID = @RegistrationRecordSID;

			set @isKeyValid = cast(@@rowcount as bit);

			-- for reinstatements an effective time is required to support
			-- prorated pricing - calculate the value through the default sproc

			if @isKeyValid = @ON
			begin

				exec dbo.pRegistration#Insert$GetDefaults -- NOTE: avoid passing @ExpiryTime to ensure previous license is not terminated!
					@RegistrantSID = @registrantSID
				 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID
				 ,@EffectiveTime = @effectiveTime output
				 ,@TerminatePriorRegistration = @OFF;

				if (dbo.fRegistrationYear(@effectiveTime) not between @registrationYear - 1 and @registrationYear + 1)  -- do not allow future dating of 2+ years
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'RegYearEffectiveTooFar'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The effective time (%1) must be in the current or next registration year only.'
					 ,@Arg1 = @effectiveTime;

					raiserror(@errorText, 16, 1);

				end;

				set @registrationYear = dbo.fRegistrationYear(@effectiveTime);	-- set the registration year based on the effective date of the registration

			end;
		end;
		else if @FormTypeCode = 'REGCHANGE'
		begin

			select
				@personSID									= r.PersonSID
			 ,@registrantSID							= reg.RegistrantSID
			 ,@registrationYear						= rc.RegistrationYear
			 ,@InvoiceSID									= rc.InvoiceSID
			 ,@practiceRegisterSID				= prsTo.PracticeRegisterSID
			 ,@practiceRegisterSectionSID = rc.PracticeRegisterSectionSID
			 ,@isActivePractice						= pr.IsActivePractice
			 ,@effectiveTime							= rc.RegistrationEffective
			 ,@formGUID										= rc.RowGUID
			 ,@fromPracticeRegisterSID		= prsFr.PracticeRegisterSID
			from
				dbo.RegistrationChange			 rc
			join
				dbo.Registration						 reg on rc.RegistrationSID							 = reg.RegistrationSID
			join
				dbo.PracticeRegisterSection	 prsTo on rc.PracticeRegisterSectionSID	 = prsTo.PracticeRegisterSectionSID
			join
				dbo.PracticeRegister				 pr on prsTo.PracticeRegisterSID				 = pr.PracticeRegisterSID
			join
				dbo.Registrant							 r on reg.RegistrantSID									 = r.RegistrantSID
			join
				dbo.RegistrationScheduleYear rsy on pr.RegistrationScheduleSID			 = rsy.RegistrationScheduleSID and rc.RegistrationYear = rsy.RegistrationYear
			join
				dbo.PracticeRegisterSection	 prsFr on reg.PracticeRegisterSectionSID = prsFr.PracticeRegisterSectionSID
			where
				rc.RegistrationChangeSID = @RegistrationRecordSID;

			set @isKeyValid = cast(@@rowcount as bit);

			-- for RegistrationChanges an effective time is required to support
			-- prorated pricing - calculate the value through the default sproc

			if @isKeyValid = @ON
			begin

				exec dbo.pRegistration#Insert$GetDefaults -- NOTE: avoid passing @ExpiryTime to ensure previous license is not terminated!
					@RegistrantSID = @registrantSID
				 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID
				 ,@EffectiveTime = @effectiveTime output
				 ,@TerminatePriorRegistration = @OFF;

				if (dbo.fRegistrationYear(@effectiveTime) not between @registrationYear - 1 and @registrationYear + 1)  -- do not allow future dating of 2+ years
				begin

					exec sf.pMessage#Get
						@MessageSCD = 'RegYearEffectiveTooFar'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The effective time (%1) must be in the current or next registration year only.'
					 ,@Arg1 = @effectiveTime;

					raiserror(@errorText, 16, 1);

				end;

				set @registrationYear = dbo.fRegistrationYear(@effectiveTime);	-- set the registration year based on the effective date of the registration

			end;
		end;
		else
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NotSupported'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 provided to the application "%2" is not supported.'
			 ,@Arg1 = 'form type'
			 ,@Arg2 = @FormTypeCode;

			raiserror(@errorText, 18, 1);

		end;

		if @isKeyValid = @OFF -- if no records were found the key must be invalid 
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = @FormTypeCode
			 ,@Arg2 = @RegistrationRecordSID;

			raiserror(@errorText, 18, 1);
		end;

		-- if an invoice has already been created for this record 
		-- then no changes are made to it; otherwise check for fees

		if @InvoiceSID is null or (@FormTypeCode = 'APPLICATION' and @FormStatusSCD = 'APPROVED')
		begin

			select -- check if this person is a PAP subscriber
				@papSubscriptionSID = ps.PAPSubscriptionSID
			from
				dbo.PAPSubscription ps
			where
				ps.PersonSID = @personSID and ps.CancelledTime is null;

			if @@rowcount = 0 or @papSubscriptionSID is null
			begin
				set @papSubscriptionSID = -1;
			end;

			-- load work table with catalog items that apply for
			-- this registration action

			insert
				@work (CatalogItemSID)
			select
				prci.CatalogItemSID
			from
				dbo.PracticeRegisterCatalogItem prci
			join
				dbo.CatalogItem									ci on prci.CatalogItemSID							= ci.CatalogItemSID
			left outer join
				dbo.PracticeRegisterChange			prc on prci.PracticeRegisterChangeSID = prc.PracticeRegisterChangeSID
			where
				prci.PracticeRegisterSID																										 = @practiceRegisterSID
				and sf.fIsActive(prci.EffectiveTime, prci.ExpiryTime)												 = @ON
				and
				(
					prci.PracticeRegisterSectionSID is null or prci.PracticeRegisterSectionSID = @practiceRegisterSectionSID
				)
				and
				(
					prci.PracticeRegisterChangeSID is null or prc.PracticeRegisterSID					 = @fromPracticeRegisterSID
				)
				and (ci.IsLateFee																														 = @OFF or @isLateFeeApplied = @ON)
				and
				(
					(
						prci.IsAppliedOnApplication																							 = @ON and @FormTypeCode = 'APPLICATION' and @FormStatusSCD = 'SUBMITTED'
					)
					or
					(
						prci.IsAppliedOnApplicationApproval																			 = @ON and @FormTypeCode = 'APPLICATION' and @FormStatusSCD = 'APPROVED'
					)
					or (prci.IsAppliedOnRenewal																								 = @ON and @FormTypeCode = 'RENEWAL')
					or (prci.IsAppliedOnReinstatement																					 = @ON and @FormTypeCode = 'REINSTATEMENT')
					or (prci.IsAppliedOnRegChange																							 = @ON and @FormTypeCode = 'REGCHANGE')
					or (prci.IsAppliedToPAPSubscribers																				 = @ON and @FormTypeCode = 'RENEWAL' and @papSubscriptionSID <> -1)
				)
			order by
				prci.FeeSequence;

			set @maxrow = @@rowcount;

			-- if no fees are configured - raise an error if the target
			-- register is active (no fees for inactive is allowed!)

			if @maxrow = 0
			begin

				if @isActivePractice = @ON
				begin

					set @errorText = @FormTypeCode + N' Fee';

					exec sf.pMessage#Get
						@MessageSCD = 'RecordNotConfigured'
					 ,@MessageText = @errorText output
					 ,@DefaultText = N'The %1 record was not found. Please complete the missing configuration before trying again or contact the Help Desk for assistance.'
					 ,@Arg1 = @errorText;

					raiserror(@errorText, 17, 1);
				end;
				else if @FormStatusSCD = 'APPROVED'
				begin

					-- registration is to an in-active type and
					-- no invoice is required - create the registration 

					exec dbo.pRegistration#Insert
						@RegistrationSID = @RegistrationSID output
					 ,@RegistrantSID = @registrantSID
					 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID
					 ,@RegistrationYear = @registrationYear
					 ,@EffectiveTime = @effectiveTime
					 ,@InvoiceSID = null
					 ,@ReasonSID = @ReasonSID
					 ,@FormGUID = @formGUID;

				end;

			end;
			else -- otherwise if pricing is configured create the invoice
			begin

				exec dbo.pInvoice#Insert -- insert the invoice parent
					@InvoiceSID = @InvoiceSID output
				 ,@PersonSID = @personSID
				 ,@RegistrationYear = @registrationYear;

				set @i = 0;

				while @i < @maxrow -- insert a row for each catalog item that applies
				begin

					set @i += 1;

					select @catalogItemSID = w .CatalogItemSID from @work w where w.ID = @i;

					-- call the EF sproc to look up the price, description and
					-- tax setting from the catalog for each fee component

					exec dbo.pInvoiceItem#Insert
						@InvoiceSID = @InvoiceSID
					 ,@CatalogItemSID = @catalogItemSID
					 ,@EffectiveTime = @effectiveTime -- ensure passed as NULL except for REINSTATEMENT/REGCHANGE since proration does not apply for APPLICATION/RENEWAL
					 ,@RegistrationYear = @registrationYear;

				end;

				-- write the new invoice number back into the originating
				-- form record (no EF sproc call to avoid recursion)

				if @FormTypeCode = 'APPLICATION'
				begin

					update
						dbo.RegistrantApp
					set
						InvoiceSID = @InvoiceSID
					where
						RegistrantAppSID = @RegistrationRecordSID;	-- the "on approved" invoice will overwrite the "on submit" invoice

				end;
				else if @FormTypeCode = 'RENEWAL'
				begin

					update
						dbo.RegistrantRenewal
					set
						InvoiceSID = @InvoiceSID
					where
						RegistrantRenewalSID = @RegistrationRecordSID;

				end;
				else if @FormTypeCode = 'REINSTATEMENT'
				begin

					update
						dbo.Reinstatement
					set
						InvoiceSID = @InvoiceSID
					where
						ReinstatementSID = @RegistrationRecordSID;

				end;
				else if @FormTypeCode = 'REGCHANGE'
				begin

					update
						dbo.RegistrationChange
					set
						InvoiceSID = @InvoiceSID
					where
						RegistrationChangeSID = @RegistrationRecordSID;

				end;

				-- for renewal invoices (only) check to see if there are pre-authorized payments
				-- that can be applied to the outstanding invoice amount to pay it off
				-- a loop is required as the person may have more than 1 subscription!

				if @InvoiceSID is not null and @FormTypeCode = 'RENEWAL'
				begin

					set @papSubscriptionSID = -1;

					while @papSubscriptionSID is not null
					begin

						select top (1)
							@papSubscriptionSID = ps.PAPSubscriptionSID
						from
							sf.Person																		 p
						join
							dbo.PAPSubscription													 ps on p.PersonSID = ps.PersonSID
						join
							dbo.PAPTransaction													 papt on ps.PAPSubscriptionSID = papt.PAPSubscriptionSID
						join
							dbo.Payment																	 pmt on papt.PaymentSID = pmt.PaymentSID
						cross apply dbo.fPayment#Total(pmt.PaymentSID) ptot
						where
							p.PersonSID = @personSID and ptot.TotalUnapplied > 0.00 and ps.PAPSubscriptionSID > @papSubscriptionSID
						order by
							ps.PAPSubscriptionSID;

						if @@rowcount > 0
						begin

							exec dbo.pPAPTransaction#Apply
								@PAPSubscriptionSID = @papSubscriptionSID;

						end;
						else
						begin -- no subscriber to check for PAP
							set @papSubscriptionSID = null;
						end;

					end;
				end;
			end;
		end;

		-- if the form is APPROVED and nothing is owing on the invoice
		-- then a registration can be created - this scenario is checked
		-- through a separate sproc call

		if @FormStatusSCD = 'APPROVED' and @InvoiceSID is not null
		begin

			exec dbo.pRegistration#SetOnPaid
				@InvoiceSID = @InvoiceSID
			 ,@ReasonSID = @ReasonSID
			 ,@RegistrationSID = @RegistrationSID output;

		end;

		-- when called from the UI to setup an invoice in advance
		-- return the invoice key for retrieval

		if @ReturnDataSet = @ON
		begin
			select @InvoiceSID InvoiceSID ;
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
