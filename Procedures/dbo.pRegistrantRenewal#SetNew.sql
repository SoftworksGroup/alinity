SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantRenewal#SetNew
	@RegistrationSID						int -- key of the registration being renewed
 ,@PracticeRegisterSectionSID int -- key of the practice register section the registrant is renewing to
as
/*********************************************************************************************************************************
Sproc    : Registrant Renewal - Set New
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Creates new renewal record along with any sub-forms configured within the renewal for the given registration
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Dec 2017		|	Initial version
				: Tim Edlund					|	Sep 2018		|	Deleted withdrawn form, cancelled invoice and recorded audit note.
				: Tim Edlund					| Nov 2018		| Overwrite section passed to default section if same as on base registration.

Comments	
--------
This procedure is called from the UI to setup a new renewal form along with any sub-forms which are configured as part of the
renewal process. Once the records have been inserted, a data set is returned that enables the UI to navigate through the 
form-set.  A subroutine - dbo.pSubForms#GetStatus - handles insert of sub-form components and return of the record set 
providing statuses for navigation.

The identifier of the registration being renewed must be passed in.  This also identifies the registrant. The practice register 
section (what they are renewing to) must also be identified.  If the section they are being renewed to is the same as the section 
on the base registration, then the procedure automatically OVERWRITES that section to the Default section for that register. This 
is done to support transitions where an individual applies or is transferred into the jurisdiction onto an Out-of-Province or
International section of the register.  When they renew, they are automatically moved to the Default register since the special
requirements and designation involved with the application/transfer no longer apply. (See also Limitations)

The renewal year is set automatically based on adding 1 to the year of the registration being renewed.  Note that if more than 1 
year has passed then a REINSTATEMENT option must be used rather than RENEWAL.

The procedure also handles deletion of any pre-existing form in a WITHDRAWN status. Registration records can only have a single
Renewal record associated with them (UK constraint) so any previous WITHDRAWN form must be removed to avoid duplication.  The
procedure handles both the deletion and insertion in a single transaction so that the entire process succeeds or fails
as a unit.  The fact a WITHDRAWN form existed is recorded as a note in the members profile.

If the registrant already has a renewal that is not WITHDRAWN for the given registration, then an error is raised.

Limitations
-----------
If the configuration requires supporting a scenario where individuals must renew to the same section as their base registration
AND that base registration register section is not the default, then the PracticeRegisterSectionSID value must be set directly
in the renewal form logic.  

Example
-------
<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Sets a new renewal for a random registration for the current year">
		<SQLScript>
		<![CDATA[
begin tran;

declare
	@registrationSID						int
 ,@practiceRegisterSectionSID int
 ,@registrationYear						smallint = dbo.fRegistrationYear#Current();

select top (1)
	@registrationSID						= rl.RegistrationSID
 ,@practiceRegisterSectionSID = rl.PracticeRegisterSectionSID
from
	dbo.Registration						rl
join
	dbo.Registrant							r on rl.RegistrantSID								 = r.RegistrantSID
join
	dbo.PracticeRegisterSection prs on rl.PracticeRegisterSectionSID = prs.PracticeRegisterSectionSID
join
	dbo.PracticeRegisterForm		prf on prs.PracticeRegisterSID			 = prf.PracticeRegisterSID
join
	sf.vForm										f on prf.FormSID										 = f.FormSID and f.FormTypeSCD = 'RENEWAL.MAIN'
left outer join
	dbo.Reinstatement						rc on rl.RegistrationSID						 = rc.RegistrationSID
left outer join
	dbo.RegistrantRenewal				rnw on rl.RegistrationSID						 = rnw.RegistrationSID
left outer join
	dbo.RegistrationChange			rch on rl.RegistrationSID						 = rch.RegistrationSID
where
	rl.RegistrationYear = @registrationYear and rc.ReinstatementSID is null and rnw.RegistrantRenewalSID is null and rch.RegistrationChangeSID is null
order by
	newid();

if @registrationSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistrantRenewal#SetNew
		@RegistrationSID = @registrationSID
	 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID;

end;

 if @@trancount > 0 rollback;
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
	<Test Name="Withdrawn" Description="Replaces a withdrawn renewal form with a new renewal and records audit note.">
		<SQLScript>
		<![CDATA[
begin tran;

declare
	@registrationSID						int
 ,@practiceRegisterSectionSID int
 ,@personSID									int
 ,@registrationYear						smallint = dbo.fRegistrationYear#Current();

select top (1)
	@registrationSID						= cs.RegistrationSID
 ,@practiceRegisterSectionSID = cs.PracticeRegisterSectionSIDTo
 ,@personSID									= r.PersonSID
from
	dbo.fRegistrantRenewal#CurrentStatus(-1, @registrationYear + 1) cs
join
	dbo.Registration																						reg on cs.RegistrationSID = reg.RegistrationSID
join
	dbo.Registrant																							r on reg.RegistrantSID		= r.RegistrantSID
where
	cs.FormStatusSCD = 'WITHDRAWN'
order by
	newid();

if @registrationSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pRegistrantRenewal#SetNew
		@RegistrationSID = @registrationSID
	 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID;

	select
		pn.PersonSID
	 ,pn.PersonNoteTypeLabel
	 ,pn.NoteTitle
	 ,pn.NoteContent
	from
		dbo.vPersonNote pn
	where
		pn.PersonSID = @personSID
	order by
		pn.CreateTime desc;

end;

if @@trancount > 0 rollback;
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>

</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistrantRenewal#SetNew'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int							= 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)													-- message text for business rule errors
	 ,@tranCount						int							= @@trancount						-- determines whether a wrapping transaction exists
	 ,@sprocName						nvarchar(128)		= object_name(@@procid) -- name of currently executing procedure
	 ,@xState								int																			-- error state detected in catch block	
	 ,@blankParm						varchar(50)															-- tracks name of any required parameter not passed
	 ,@ON										bit							= cast(1 as bit)				-- constant for bit comparison = 0
	 ,@OFF									bit							= cast(0 as bit)				-- constant for bit comparison = 0
	 ,@registrantRenewalSID int																			-- key of new/existing renewal record 
	 ,@invoiceSID						int																			-- key of invoice on existing form (if any)
	 ,@formStatusSCD				varchar(25)															-- status of current form (if any)
	 ,@registrantSID				int																			-- key of registrant renewing
	 ,@personSID						int																			-- key of person renewing
	 ,@registrationYear			smallint																-- year renewal is to be created for (defaults to current year + 1)
	 ,@noteContent					nvarchar(max)														-- buffer for note content to add if deleting withdrawn form
	 ,@reasonSID						int																			-- key of cancellation reason for invoice (if previous invoice exists)
	 ,@created							nvarchar(25)														-- date and time when previous renewal was created (for message)
	 ,@formSID							int																			-- key of parent (renewal) form record
	 ,@rowGUID							uniqueidentifier;												-- GUID on parent renewal form (used to join to sub-forms)

	begin try

		-- if a wrapping transaction exists set a save point to rollback to on an error

		if @tranCount = 0 -- no outer transaction
		begin
			begin transaction;
		end;
		else -- outer transaction so create save point
		begin
			save transaction @sprocName;
		end;

-- SQL Prompt formatting off
		if @PracticeRegisterSectionSID	is null set @blankParm = '@PracticeRegisterSectionSID'
		if @RegistrationSID				is null set @blankParm = '@RegistrationSID';
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

		-- validate the registration parameter and check for 
		-- an existing form

		select
			@registrationYear						= reg.RegistrationYear + 1
		 ,@registrantSID							= reg.RegistrantSID
		 ,@personSID									= r.PersonSID
		 ,@registrantRenewalSID				= rnw.RegistrantRenewalSID
		 ,@invoiceSID									= rnw.InvoiceSID
		 ,@formStatusSCD							= cs.FormStatusSCD
		 ,@created										= format(sf.fDTOffsetToClientDateTime(rnw.CreateTime), 'dd-MMM-yyyy hh:mm tt')
		 ,@PracticeRegisterSectionSID = (case
																			 when @PracticeRegisterSectionSID = reg.PracticeRegisterSectionSID then prsDef.PracticeRegisterSectionSID -- section unchanged; assign the Default section
																			 else @PracticeRegisterSectionSID -- different register section selected from the renewal options on portal (do not overwrite)
																		 end
																		) -- overwrite logic to default section
		from
			dbo.Registration																														 reg
		join
			dbo.PracticeRegisterSection																									 prsFr on reg.PracticeRegisterSectionSID = prsFr.PracticeRegisterSectionSID
		join
			dbo.PracticeRegisterSection																									 prsDef on prsFr.PracticeRegisterSID = prsDef.PracticeRegisterSID and prsDef.IsDefault = @ON
		join
			dbo.Registrant																															 r on reg.RegistrantSID = r.RegistrantSID
		left outer join
			dbo.RegistrantRenewal																												 rnw on reg.RegistrationSID = rnw.RegistrationSID
		outer apply dbo.fRegistrantRenewal#CurrentStatus(rnw.RegistrantRenewalSID, -1) cs
		where
			reg.RegistrationSID = @RegistrationSID;

		if @registrationYear is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.Registration'
			 ,@Arg2 = @RegistrationSID;

			raiserror(@errorText, 18, 1);
		end;

		if dbo.fRenewalPeriod#IsOpen(@registrantSID, @registrationYear) = @OFF
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RenewalPeriodNotOpen'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The renewal period for the %1 year is not open. The renewal cannot be %2.'
			 ,@Arg1 = @registrationYear
			 ,@Arg2 = 'created';

			raiserror(@errorText, 16, 1);

		end;

		if @registrantRenewalSID is not null
		begin

			if isnull(@formStatusSCD, 'NEW') = 'WITHDRAWN'
			begin

				-- before deleting the withdrawn form, ensure no
				-- payments exist for its invoice

				if @invoiceSID is not null
				begin

					if exists (select 1 from dbo .fInvoice#Total(@invoiceSID) it where it.TotalPaid > 0.0)
					begin

						exec sf.pMessage#Get
							@MessageSCD = 'PaymentsExistOnWithdrawn'
						 ,@MessageText = @errorText output
						 ,@DefaultText = N'A "withdrawn" form exists with payment against it. Contact the office to un-apply these payments before attempting to %2. (Record ID = "%1")'
						 ,@Arg1 = @registrantRenewalSID
						 ,@Arg2 = 'renew';

						raiserror(@errorText, 16, 1);
					end;

				end;
				else
				begin

					select
						@reasonSID = rsn.ReasonSID
					from
						dbo.Reason rsn
					where
						rsn.ReasonCode = 'INVOICE.CANCEL.WITHDRAWN';

					if exists
					(
						select
							1
						from
							dbo.Invoice i
						where
							i.InvoiceSID = @invoiceSID and i.CancelledTime is null	-- cancel the invoice to avoid confusion with new renewal
					)
					begin

						exec dbo.pInvoice#Update
							@InvoiceSID = @invoiceSID
						 ,@ReasonSID = @reasonSID
						 ,@IsCancelled = @ON;

					end;

				end;

				-- before deleting the withdrawn form, record
				-- a note about its details

				set @noteContent = N'A withdrawn renewal for this member was removed to allow a new renewal form to replace it. The previous renewal was created %1. ';

				set @noteContent = replace(@noteContent, '%1', @created);

				if @invoiceSID is not null
				begin
					set @noteContent += N' The renewal was invoiced, reference #%1, but no payments were applied against it. The invoice was cancelled. ';
					set @noteContent = replace(@noteContent, '%1', ltrim(@invoiceSID));
				end;
				else
				begin
					set @noteContent += N' The renewal was not invoiced.';

				end;

				exec dbo.pPersonNote#Set
					@PersonSID = @personSID
				 ,@NoteTitle = 'Withdrawn Renewal Form Replaced'
				 ,@NoteContent = @noteContent;

				exec dbo.pRegistrantRenewal#Delete
					@RegistrantRenewalSID = @registrantRenewalSID;

			end;
			else
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'FormExists'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A %1 %2 form already exists. The status of the form is "%4". (Record ID = "%3")'
				 ,@Arg1 = @registrationYear
				 ,@Arg2 = 'renewal'
				 ,@Arg3 = @registrantRenewalSID
				 ,@Arg4 = @formStatusSCD;

				raiserror(@errorText, 16, 1);
			end;
		end;

		-- insert the new form 

		exec dbo.pRegistrantRenewal#Insert
			@RegistrantRenewalSID = @registrantRenewalSID output
		 ,@RegistrationSID = @RegistrationSID
		 ,@PracticeRegisterSectionSID = @PracticeRegisterSectionSID;

		-- retrieve the form and GUID from the record

		select
			@formSID = fv.FormSID
		 ,@rowGUID = rnw.RowGUID
		from
			dbo.RegistrantRenewal rnw
		join
			sf.FormVersion				fv on rnw.FormVersionSID = fv.FormVersionSID
		where
			rnw.RegistrantRenewalSID = @registrantRenewalSID;

		-- call a subroutine to check for and create sub-forms
		-- associated with this parent form and return statuses

		exec dbo.pFormSet#GetStatuses
			@FormSID = @formSID
		 ,@ParentRowGUID = @rowGUID;

		if @tranCount = 0 and xact_state() = 1 commit transaction;
	end try
	begin catch

		set @xState = xact_state();

		if @tranCount = 0 and (@xState = -1 or @xState = 1)
		begin
			rollback; -- rollback if any transaction is pending (committable or not)
		end;

		exec @errorNo = sf.pErrorRethrow;

	end catch;

	return (@errorNo);
end;
GO
