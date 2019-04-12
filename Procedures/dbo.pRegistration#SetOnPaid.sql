SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistration#SetOnPaid
	@PaymentSID				 int = null					-- key of payment to check for creation of new registration
 ,@InvoicePaymentSID int = null					-- key of a specific applied payment to check for creation of new registration
 ,@InvoiceSID				 int = null					-- key of invoice to check for full payment and check for creation of new registrations
 ,@ReasonSID				 int = null					-- optional reason why the form was approved to assign on the Registration record
 ,@RegistrationSID	 int = null output	-- key of new registration created (if any)
as
/*********************************************************************************************************************************
Sproc    : Registration - Set On Paid
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Creates a new registration record for applications, renewals, reinstatements and registration changes when paid/$0
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version
					: Tim Edlund	| Jun 2018		| Changed FK reference in Registrant App from RegistrantSID to RegistrationSID 

Comments	
--------
This procedure is called from various parts of the invoice creation and form approval processes.  Once an application, renewal,
reinstatement or registration change form is approved and its associated invoice is paid, a new Registration record must be 
created.  This procedure performs that function first checking that the invoice is paid and the form is in an "APPROVED" status, 
and that an registration has not already been created for the given form (using the RowGUID of the form as a check against 
duplicates).

Because the procedure is called from various contexts, there is a choice of 3 parameters that may be passed to indicate which
invoice or invoices should be checked.  Regardless of the parameter passed, a list of invoices is derived which is then checked
for association with application, renewal, reinstatement or registration change forms.

@PaymentSID - joins to Application-Payment and then Invoice to check all invoices and its related registration forms
@InvoicePaymentSID - joins to a single Invoice and then its related registration form 
@InvoiceSID - checks for related registration form

Note that if a configuration requires that the application, renewal, reinstatement or registration change result in no fees, an 
invoice must still be configured for it if the new registration type is an "Active Practice" type.  If the new registration is
in-active then an invoice does not need to exist. Where no invoice exists the procedure pRegistration#Set is called (and
is also called by this routine) to perform the actual insert of the new registration record.

The logic applied in this procedure is based on only 1 form being associated with an invoice.  Business rules implemented as
check constraints on the tables prevent, for example, 2 renewals being charged on the same invoice or a combination of 
renewals and reinstatements appearing on the same invoice.

@ReasonSID
----------
The @ReasonSID parameter is optional and may be passed by the caller to fill-in the ReasonSID on the resulting dbo.Registration
record. The value is normally provided by the @ReasonSIDOnApprove column on the base entity. The value is intended to provide 
explanation as to why the new registration was approved/required if not following a typical process. For example, it may 
provide the reason why a requirement normally required on an application was by-passed in the case of this particular registrant.
The value should generally be provided for Registration-Change forms but will normally be blank for other form types.  

Example
-----------
[example call syntax here]
 


------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo										int = 0						-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText									nvarchar(4000)		-- message text for business rule errors
	 ,@applicationSID							int								-- key of next Application form to create registration for
	 ,@registrantRenewalSID				int								-- key of next Renewal  form to create registration for
	 ,@reinstatementSID						int								-- key of next Reinstatement form to create registration for
	 ,@registrationChangeSID			int								-- key of next Registration change to create registration for
	 ,@registrantSID							int								-- key of registrant to assign registration to
	 ,@registrationYear						smallint					-- registration year to assign
	 ,@formStatusSCD							varchar(25)				-- current status of the form record (s/b "APPROVED")
	 ,@practiceRegisterSectionSID int								-- section to assign the registration to
	 ,@formGUID										uniqueidentifier	-- key of associated form driving the registration change
	 ,@effectiveTime							datetime					-- effective time for new registration (reinstatement/reg change only)
	 ,@i													int								-- loop iteration counter
	 ,@maxrow											int;							-- loop limit

	declare @work table (ID int identity(1, 1), InvoiceSID int not null);

	set @RegistrationSID = null;

	begin try

		-- check parameters

		if @PaymentSID is null and @InvoicePaymentSID is null and @InvoiceSID is null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = 'PaymentSID/InvoicePaymentSID/InvoiceSID';

			raiserror(@errorText, 18, 1);
		end;

		-- depending on the key passed in a different SELECT statement
		-- is used to load the work table with invoice numbers to 
		-- process

		if @PaymentSID is not null
		begin

			insert
				@work (InvoiceSID)
			select
				ip.InvoiceSID
			from
				dbo.Payment																	p
			join
				dbo.InvoicePayment													ip on p.PaymentSID = ip.PaymentSID
			cross apply dbo.fInvoice#Total(ip.InvoiceSID) it
			where
				p.PaymentSID = @PaymentSID and it.TotalDue <= cast(0.0 as decimal(11, 2));	-- must be fully paid

		end;
		else if @InvoicePaymentSID is not null
		begin

			insert
				@work (InvoiceSID)
			select
				ip.InvoiceSID
			from
				dbo.InvoicePayment													ip
			cross apply dbo.fInvoice#Total(ip.InvoiceSID) it
			where
				ip.InvoicePaymentSID = @InvoicePaymentSID and it.TotalDue <= cast(0.0 as decimal(11, 2)); -- must be fully paid

		end;
		else
		begin

			insert
				@work (InvoiceSID)
			select
				@InvoiceSID
			from
				dbo.fInvoice#Total(@InvoiceSID) it
			where
				it.TotalDue <= cast(0.0 as decimal(11, 2)); -- must be fully paid

		end;

		set @maxrow = @@rowcount;
		set @i = 0;

		while @i < @maxrow
		begin

			set @i += 1;

			select @InvoiceSID = w .InvoiceSID from @work w where w.ID = @i;

			set @applicationSID = null;
			set @registrantRenewalSID = null;
			set @reinstatementSID = null;
			set @registrationChangeSID = null;
			set @registrantSID = null;

			select
				@applicationSID				 = ra.InvoiceSID
			 ,@registrantRenewalSID	 = rr.RegistrantRenewalSID
			 ,@reinstatementSID			 = rin.ReinstatementSID
			 ,@registrationChangeSID = rc.RegistrationChangeSID
			from
				dbo.Invoice						 i
			left outer join
				dbo.RegistrantApp			 ra on i.InvoiceSID	 = ra.InvoiceSID
			left outer join
				dbo.RegistrantRenewal	 rr on i.InvoiceSID	 = rr.InvoiceSID
			left outer join
				dbo.Reinstatement			 rin on i.InvoiceSID = rin.InvoiceSID
			left outer join
				dbo.RegistrationChange rc on i.InvoiceSID	 = rc.InvoiceSID
			where
				i.InvoiceSID = @InvoiceSID;

			-- where the invoice is associated with a registration form
			-- store the values required to insert the new registration

			if @applicationSID is not null
			begin

				select
					@registrantSID							= reg.RegistrantSID
				 ,@registrationYear						= ra.RegistrationYear
				 ,@formStatusSCD							= cs.FormStatusSCD
				 ,@practiceRegisterSectionSID = ra.PracticeRegisterSectionSID
				 ,@formGUID										= ra.RowGUID
				from
					dbo.Invoice																											 i
				join
					dbo.RegistrantApp																								 ra on i.InvoiceSID = ra.InvoiceSID
				join
					dbo.Registration																								 reg on ra.RegistrationSID = reg.RegistrationSID
				outer apply dbo.fRegistrantApp#CurrentStatus(ra.RegistrantAppSID, -1) cs
				where
					i.InvoiceSID = @InvoiceSID;

			end;
			else if @registrantRenewalSID is not null -- renewal form is associated with the invoice
			begin

				select
					@registrantSID							= rl.RegistrantSID
				 ,@registrationYear						= rr.RegistrationYear
				 ,@formStatusSCD							= cs.FormStatusSCD
				 ,@practiceRegisterSectionSID = rr.PracticeRegisterSectionSID
				 ,@formGUID										= rr.RowGUID
				from
					dbo.Invoice																															 i
				join
					dbo.RegistrantRenewal																										 rr on i.InvoiceSID = rr.InvoiceSID
				join
					dbo.Registration																												 rl on rr.RegistrationSID = rl.RegistrationSID
				cross apply dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) cs
				where
					i.InvoiceSID = @InvoiceSID;

			end;
			else if @reinstatementSID is not null -- reinstatement form is associated with this invoice
			begin

				select
					@registrantSID							= rl.RegistrantSID
				 ,@registrationYear						= rin.RegistrationYear
				 ,@formStatusSCD							= cs.FormStatusSCD
				 ,@practiceRegisterSectionSID = rin.PracticeRegisterSectionSID
				 ,@formGUID										= rin.RowGUID
				 ,@effectiveTime							= rin.RegistrationEffective
				from
					dbo.Invoice																											 i
				join
					dbo.Reinstatement																								 rin on i.InvoiceSID = rin.InvoiceSID
				join
					dbo.Registration																								 rl on rin.RegistrationSID = rl.RegistrationSID
				cross apply dbo.fReinstatement#CurrentStatus(rin.ReinstatementSID, -1) cs
				where
					i.InvoiceSID = @InvoiceSID;

			end;
			else if @registrationChangeSID is not null -- registration change is associated with this invoice
			begin

				select
					@registrantSID							= rl.RegistrantSID
				 ,@registrationYear						= rc.RegistrationYear
				 ,@formStatusSCD							= cs.FormStatusSCD
				 ,@practiceRegisterSectionSID = rc.PracticeRegisterSectionSID
				 ,@formGUID										= rc.RowGUID
				 ,@effectiveTime							= rc.RegistrationEffective 
				from
					dbo.Invoice																																i
				join
					dbo.RegistrationChange																										rc on i.InvoiceSID = rc.InvoiceSID
				join
					dbo.Registration																													rl on rc.RegistrationSID = rl.RegistrationSID
				cross apply dbo.fRegistrationChange#CurrentStatus(rc.RegistrationChangeSID, -1) cs
				where
					i.InvoiceSID = @InvoiceSID;

			end;

			if @registrantSID is not null and @formStatusSCD = 'APPROVED'
			begin

				if not exists
				(
					select
						1
					from
						dbo.Registration rl
					where
						rl.RegistrantSID									= @registrantSID
						and rl.PracticeRegisterSectionSID = @practiceRegisterSectionSID
						and rl.RegistrationYear						= @registrationYear
						and isnull(rl.FormGUID, newid())	= @formGUID -- if the FormGUID is null in the record, ignore as matching criteria for duplicates
				)
				begin

					exec dbo.pRegistration#Insert
						@RegistrationSID = @RegistrationSID output
					 ,@RegistrantSID = @registrantSID
					 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID
					 ,@RegistrationYear = @registrationYear
					 ,@ReasonSID = @ReasonSID
					 ,@InvoiceSID = @InvoiceSID
					 ,@FormGUID = @formGUID
					 ,@EffectiveTime = @effectiveTime;

				end;
			end;
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
