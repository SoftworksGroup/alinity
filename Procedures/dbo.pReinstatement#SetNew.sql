SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pReinstatement#SetNew
	@RegistrationSID						int -- key of the registration being reinstated
 ,@PracticeRegisterSectionSID int -- key of the practice register section the registrant is reinstating to
as
/*********************************************************************************************************************************
Sproc    : Registrant Reinstatement - Set New
Notice   : Copyright © 2017 Softworks Group Inc.
Summary  : Creates new reinstatement record along with any sub-forms configured within the reinstatement for the given registration
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Mar 2018		|	Initial version
				: Tim Edlund					| Dec 2018		| Revised to incorporate latest standard (Nov/2018) from renewal

Comments	
--------
This procedure is called from the UI to setup a new reinstatement form along with any sub-forms which are configured as part of the
reinstatement process. Once the records have been inserted, a data set is returned that enables the UI to navigate through the 
form-set.  A subroutine - dbo.pSubForms#GetStatus - handles insert of sub-form components and return of the record set 
providing statuses for navigation.

The identifier of the registration being reinstated must be passed in.  This also identifies the registrant. The practice register 
section (what they are reinstating to) must also be identified.  

The reinstatement year is set automatically based on adding 1 to the year of the registration being reinstated.  Note that if more than 1 
year has passed then a REINSTATEMENT option must be used rather than RENEWAL.

The procedure also handles deletion of any pre-existing form in a WITHDRAWN status. Registration records can only have a single
Reinstatement record associated with them (UK constraint) so any previous WITHDRAWN form must be removed to avoid duplication.  The
procedure handles both the deletion and insertion in a single transaction so that the entire process succeeds or fails
as a unit.  The fact a WITHDRAWN form existed is recorded as a note in the members profile.

If the registrant already has a reinstatement that is not WITHDRAWN for the given registration, then an error is raised.

Example
-------
<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Sets a new reinstatement for a random registration for the current year">
		<SQLScript>
		<![CDATA[
begin tran;

declare
	@registrationSID						int
 ,@practiceRegisterSectionSID int
 ,@registrationYear						smallint = dbo.fRegistrationYear#Current()
 ,@now												datetime = sf.fNow()
 ,@ON													bit			 = cast(1 as bit)
 ,@OFF												bit			 = cast(0 as bit);

select
	@practiceRegisterSectionSID = prs.PracticeRegisterSectionSID
from
	dbo.PracticeRegisterSection prs
join
	dbo.PracticeRegister				pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
where
	pr.IsActivePractice = @ON and prs.IsDefault = @ON;

select top (1)
	@registrationSID = rl.RegistrationSID
from
	dbo.Registration																							 rl
cross apply dbo.fRegistrant#RegistrationCurrent(rl.RegistrantSID) rrc
where
	rl.RegistrationYear = @registrationYear
	and rrc.IsReinstatementEnabled = cast(1 as bit)
order by
	newid();

if @registrationSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	exec dbo.pReinstatement#SetNew
		@RegistrationSID = @registrationSID
	 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID;

end;

 if @@trancount > 0 rollback;

 select * from dbo.vOrgOtherName
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
	<Test Name="Withdrawn" Description="Replaces a withdrawn reinstatement form with a new reinstatement and records audit note.">
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
	dbo.fReinstatement#CurrentStatus(-1, @registrationYear + 1) cs
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

	exec dbo.pReinstatement#SetNew
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
	 @ObjectName = 'dbo.pReinstatement#SetNew'
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
	 ,@OFF							bit							= cast(0 as bit)				-- constant for bit comparison = 0
	 ,@reinstatementSID int																			-- key of new/existing reinstatement record 
	 ,@invoiceSID				int																			-- key of invoice on existing form (if any)
	 ,@formStatusSCD		varchar(25)															-- status of current form (if any)
	 ,@registrantSID		int																			-- key of registrant reinstating
	 ,@personSID				int																			-- key of person reinstating
	 ,@registrationYear smallint																-- year reinstatement is to be created for (defaults to current year + 1)
	 ,@noteContent			nvarchar(max)														-- buffer for note content to add if deleting withdrawn form
	 ,@reasonSID				int																			-- key of cancellation reason for invoice (if previous invoice exists)
	 ,@created					nvarchar(25)														-- date and time when previous reinstatement was created (for message)
	 ,@formSID					int																			-- key of parent (reinstatement) form record
	 ,@rowGUID					uniqueidentifier;												-- GUID on parent reinstatement form (used to join to sub-forms)

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
			@registrationYear = reg.RegistrationYear
		 ,@registrantSID		= reg.RegistrantSID
		 ,@personSID				= r.PersonSID
		 ,@reinstatementSID = rin.ReinstatementSID
		 ,@invoiceSID				= rin.InvoiceSID
		 ,@formStatusSCD		= cs.FormStatusSCD
		 ,@created					= format(sf.fDTOffsetToClientDateTime(rin.CreateTime), 'dd-MMM-yyyy hh:mm tt')
		from
			dbo.Registration																										 reg
		join
			dbo.Registrant																											 r on reg.RegistrantSID = r.RegistrantSID
		left outer join
			dbo.Reinstatement																										 rin on reg.RegistrationSID = rin.RegistrationSID
		outer apply dbo.fReinstatement#CurrentStatus(rin.ReinstatementSID, -1) cs
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

		if dbo.fReinstatementPeriod#IsOpen(@registrantSID, @registrationYear) = @OFF
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ReinstatementPeriodNotOpen'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The reinstatement period for the %1 year is not open. The reinstatement cannot be %2.'
			 ,@Arg1 = @registrationYear
			 ,@Arg2 = 'created';

			raiserror(@errorText, 16, 1);

		end;

		if @reinstatementSID is not null
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
						 ,@Arg1 = @reinstatementSID
						 ,@Arg2 = 'reinstate';

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
							i.InvoiceSID = @invoiceSID and i.CancelledTime is null	-- cancel the invoice to avoid confusion with new reinstatement
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
					N'A withdrawn reinstatement for this member was removed to allow a new reinstatement form to replace it. The previous reinstatement was created %1. ';

				set @noteContent = replace(@noteContent, '%1', @created);

				if @invoiceSID is not null
				begin
					set @noteContent += N' The reinstatement was invoiced, reference #%1, but no payments were applied against it. The invoice was cancelled. ';
					set @noteContent = replace(@noteContent, '%1', ltrim(@invoiceSID));
				end;
				else
				begin
					set @noteContent += N' The reinstatement was not invoiced.';

				end;

				exec dbo.pPersonNote#Set
					@PersonSID = @personSID
				 ,@NoteTitle = 'Withdrawn Reinstatement Form Replaced'
				 ,@NoteContent = @noteContent;

				exec dbo.pReinstatement#Delete
					@ReinstatementSID = @reinstatementSID;

			end;
			else
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'FormExists'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'A %1 %2 form already exists. The status of the form is "%4". (Record ID = "%3")'
				 ,@Arg1 = @registrationYear
				 ,@Arg2 = 'reinstatement'
				 ,@Arg3 = @reinstatementSID
				 ,@Arg4 = @formStatusSCD;

				raiserror(@errorText, 16, 1);
			end;
		end;

		-- insert the new form 

		exec dbo.pReinstatement#Insert
			@ReinstatementSID = @reinstatementSID output
		 ,@RegistrationSID = @RegistrationSID
		 ,@PracticeRegisterSectionSID = @PracticeRegisterSectionSID;

		-- retrieve the form and GUID from the record

		select
			@formSID = fv.FormSID
		 ,@rowGUID = rin.RowGUID
		from
			dbo.Reinstatement rin
		join
			sf.FormVersion		fv on rin.FormVersionSID = fv.FormVersionSID
		where
			rin.ReinstatementSID = @reinstatementSID;

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
