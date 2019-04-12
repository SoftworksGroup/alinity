SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantApp#SetNew
	@RegistrationSID						int = null	-- key of the base registration application is linked to (default register)
 ,@RegistrantSID							int = null	-- key of the registrant (required if no Registration key is passed)
 ,@PracticeRegisterSectionSID int					-- key of the practice register section the registrant is applying to
as
/*********************************************************************************************************************************
Sproc    : Application - Set New
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : This procedure create a new application record along with any sub-forms 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Oct 2018		|	Initial version

Comments	
--------
This procedure is called from the UI to setup a new application form along with any sub-forms which are configured as part of the
application process. Once the records have been inserted, a data set is returned that enables the UI to navigate through the 
form-set.  A subroutine - dbo.pSubForms#GetStatus - handles insert of sub-form components and return of the record set 
providing statuses for navigation.

The identifier of the registration the application is based on should be passed. In the situation where the registrant is new and
they were not automatically placed on the Applicant's register, NULL or -1 can be passed for the @RegistrationSID and this procedure
will add a registration to the default (Applicant's) register.  This logic requires, however, that the @RegistrantSID parameter
be passed in.  Failure to pass either parameter will lead to a missing parameter error being raised. 

The procedure also handles deletion of any pre-existing form in a WITHDRAWN status. Registration records can only have a single
Application record associated with them (UK constraint) so any previous WITHDRAWN form must be removed to avoid duplication.  The
procedure handles both the deletion and insertion in a single transaction so that the entire process succeeds or fails
as a unit.  The fact a WITHDRAWN form existed is recorded as a note in the members profile.

If the registrant already has a application that is not WITHDRAWN for the given registration, then an error is raised.

Example
-------
<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Creates a new application for a registrant selected at random">
		<SQLScript>
		<![CDATA[

declare
	@registrationSID						int
 ,@practiceRegisterSectionSID int
 ,@registrationYear						smallint = dbo.fRegistrationYear#Current();

select top (1)
	@registrationSID = lReg.RegistrationSID
from
	dbo.fRegistrant#LatestRegistration(-1, @registrationYear) lReg
join
	dbo.PracticeRegister																			pr on lReg.PracticeRegisterSID = pr.PracticeRegisterSID
left outer join
	dbo.RegistrantApp																					app on lReg.RegistrationSID		 = app.RegistrationSID
where
	pr.IsDefault = 1 -- currently on the Application register
	and app.RegistrantAppSID is null	-- no application exists
order by
	newid();

select top (1)
	@practiceRegisterSectionSID = prs.PracticeRegisterSectionSID
from
	dbo.PracticeRegisterSection prs
join
	dbo.PracticeRegister				pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
join
  dbo.PracticeRegisterForm		prf on pr.PracticeRegisterSID = prf.PracticeRegisterSID
join
  sf.Form											f on prf.FormSID = f.FormSID
join
  sf.FormType									ft on f.FormTypeSID = ft.FormTypeSID
where
	pr.IsActivePractice = 1
and
  ft.FormTypeSCD = 'APPLICATION.MAIN'
order by
	newid();

if @registrationSID is null or @practiceRegisterSectionSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin tran

	exec dbo.pRegistrantApp#SetNew
		@RegistrationSID = @registrationSID
	 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID;

	rollback

end;

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
	<Test Name="Withdrawn" Description="Replaces a withdrawn reneal form with a new application and records audit note.">
		<SQLScript>
		<![CDATA[

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
	dbo.fRegistrantApp#CurrentStatus(-1, @registrationYear ) cs
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

	exec dbo.pRegistrantApp#SetNew
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

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>

</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pRegistrantApp#SetNew'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					int							= 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText				nvarchar(4000)													-- message text for business rule errors
	 ,@tranCount				int							= @@trancount						-- determines whether a wrapping transaction exists
	 ,@sprocName				nvarchar(128)		= object_name(@@procid) -- name of currently executing procedure
	 ,@xState						int																			-- error state detected in catch block	
	 ,@blankParm				varchar(50)															-- tracks name of any required parameter not passed
	 ,@ON								bit							= cast(1 as bit)				-- constant for bit comparison = 0
	 ,@registrantAppSID int																			-- key of new/existing application record 
	 ,@invoiceSID				int																			-- key of invoice on existing form (if any)
	 ,@formStatusSCD		varchar(25)															-- status of current form (if any)
	 ,@personSID				int																			-- key of person applying
	 ,@registrationYear smallint																-- year application is to be created for (defaults to current year )
	 ,@noteContent			nvarchar(max)														-- buffer for note content to add if deleting withdrawn form
	 ,@reasonSID				int																			-- key of cancellation reason for invoice (if previous invoice exists)
	 ,@created					nvarchar(25)														-- date and time when previous r
	 ,@formSID					int																			-- key of parent (application) form record
	 ,@rowGUID					uniqueidentifier;												-- GUID on parent application form (used to join to sub-forms)

	begin try

		-- if a wrapping transaction exists set a save point to rollback to on a local error

		if @tranCount = 0 -- no outer transaction
		begin
			begin transaction;
		end;
		else -- outer transaction so create save point
		begin
			save transaction @sprocName;
		end;

-- SQL Prompt formatting off
		if @RegistrationSID is null and @RegistrantSID is null set @blankParm = '@RegistrationSID/@RegistrantSID'
		if @PracticeRegisterSectionSID	is null set @blankParm = '@PracticeRegisterSectionSID'
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

		-- if a registration key is not passed, add the registrant to the
		-- Application Practice Register (default register)

		if isnull(@RegistrationSID, -1) = -1 and @RegistrantSID is not null
		begin

			exec dbo.pRegistrant#Insert$ApplicantRegistration
				@RegistrantSID = @RegistrantSID
			 ,@RegistrationSID = @RegistrationSID output;

		end;

		-- validate the registration parameter and check for 
		-- an existing form

		select
			@registrationYear = reg.RegistrationYear
		 ,@RegistrantSID		= reg.RegistrantSID
		 ,@personSID				= r.PersonSID
		 ,@registrantAppSID = app.RegistrantAppSID
		 ,@invoiceSID				= app.InvoiceSID
		 ,@formStatusSCD		= cs.FormStatusSCD
		 ,@created					= format(sf.fDTOffsetToClientDateTime(app.CreateTime), 'dd-MMM-yyyy hh:mm tt')
		from
			dbo.Registration																										 reg
		join
			dbo.Registrant																											 r on reg.RegistrantSID = r.RegistrantSID
		left outer join
			dbo.RegistrantApp																										 app on reg.RegistrationSID = app.RegistrationSID
		outer apply dbo.fRegistrantApp#CurrentStatus(app.RegistrantAppSID, -1) cs
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

		if @registrantAppSID is not null
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
						 ,@Arg1 = @registrantAppSID
						 ,@Arg2 = 're-apply';

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
							i.InvoiceSID = @invoiceSID and i.CancelledTime is null	-- cancel the invoice to avoid confusion with new application
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

				set @noteContent =
					N'A withdrawn application for this member was removed to allow a new application form to replace it. The previous application was created %1. ';

				set @noteContent = replace(@noteContent, '%1', @created);

				if @invoiceSID is not null
				begin
					set @noteContent += N' The application was invoiced, reference #%1, but no payments were applied against it. The invoice was cancelled. ';
					set @noteContent = replace(@noteContent, '%1', ltrim(@invoiceSID));
				end;
				else
				begin
					set @noteContent += N' The application was not invoiced.';

				end;

				exec dbo.pPersonNote#Set
					@PersonSID = @personSID
				 ,@NoteTitle = 'Withdrawn Application Form Replaced'
				 ,@NoteContent = @noteContent;

				exec dbo.pRegistrantApp#Delete
					@RegistrantAppSID = @registrantAppSID;

			end;
			else
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'FormExists'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A %1 %2 form already exists. The status of the form is "%4". (Record ID = "%3")'
				 ,@Arg1 = @registrationYear
				 ,@Arg2 = 'application'
				 ,@Arg3 = @registrantAppSID
				 ,@Arg4 = @formStatusSCD

				raiserror(@errorText, 16, 1);
			end;
		end;

		-- insert the new form 

		exec dbo.pRegistrantApp#Insert
			@RegistrantAppSID = @registrantAppSID output
		 ,@RegistrationSID = @RegistrationSID
		 ,@PracticeRegisterSectionSID = @PracticeRegisterSectionSID;

		-- retrieve the form and GUID from the record

		select
			@formSID = fv.FormSID
		 ,@rowGUID = app.RowGUID
		from
			dbo.RegistrantApp app
		join
			sf.FormVersion		fv on app.FormVersionSID = fv.FormVersionSID
		where
			app.RegistrantAppSID = @registrantAppSID;

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
