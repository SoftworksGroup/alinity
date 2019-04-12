SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrationChange#Approve
	@RegistrationChangeSID int					-- key of the registration change to approve
 ,@ReasonSID						 int	= null	-- optional reason why the form was approved
as
/*********************************************************************************************************************************
Procedure : Registrant Change Approve
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Generates an invoice where required and saves new registration if paid
----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version
					
Comments	
--------
This procedure is called when the "APPROVE" action is called from the UI (by an administrator). A dynamic form is NOT involved
with the Registration Change process so no calls to sf.pForm#Post are carried out.

The procedure is most often called from pRegistrationChange#Update or a front end batch approval process.  If the calling 
program has not yet changed the status of the record to APPROVED, this procedure sets that status (this supports batch
calling).

The procedure checks to ensure any requirements associated with the registration change have been met.  It is also responsible
for calling the invoice generation process to charge the member where the change requires payment.  If charges do not result, 
a $0 invoice must still be configured in setup.  If no amount is owing for the change, or an amount was owing but could be paid 
off through existing unapplied payments, then new registration record is also created as part of the transaction initiated by 
this procedure.  Generation of the new registration record completes the approval process.

If an amount is owing for the change, the new registration record is not created until the member pays it which is handled 
through the payment action.  

Subroutines are called to handle the various stages of the process.

Note that once a form is in an APPROVED state, it can no longer be edited.  

@ReasonSID
----------
The @ReasonSID parameter is optional and may be passed by the caller to fill-in the ReasonSID on the resulting dbo.Registration
record. The value is normally provided by the @ReasonSIDOnApprove column on the base entity. The value is intended to provide 
explanation as to why the new registration was approved/required if not following a typical process.  For example, it may 
provide the reason why a requirement normally required, was by-passed in the case of this particular registrant.

Example
-------
<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Approve a change form in submitted status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@RegistrationChangeSID		int

select top 1
	@RegistrationChangeSID = rc.RegistrationChangeSID
from
	dbo.vRegistrationChange rc
where
	rc.RegistrationChangeStatusSCD = 'SUBMITTED'
order by
	newid()

exec dbo.pRegistrationChange#Approve
	 @RegistrationChangeSID = @RegistrationChangeSID

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pRegistrationChange#Approve'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */
begin

	set nocount on;

	declare
		@errorNo								 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText							 nvarchar(4000)									-- message text (for business rule errors)
	 ,@currentFormStatusSCD		 varchar(25)										-- current status of the record
	 ,@OFF										 bit					 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@outstandingRequirements int;														-- count of requirements that remain unapproved

	begin try

		if @RegistrationChangeSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@RegistrationChangeSID';

			raiserror(@errorText, 18, 1);
		end;

		-- retrieve values required to check 
		-- status and the key value

		select
			@currentFormStatusSCD = cs.FormStatusSCD
		from
			dbo.fRegistrationChange#CurrentStatus(@RegistrationChangeSID,-1) cs;

		if @currentFormStatusSCD is null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.RegistrationChange'
			 ,@Arg2 = @RegistrationChangeSID;

			raiserror(@errorText, 18, 1);
		end;

		-- ensure all requirements assigned to the registration
		-- changes are in a final status and are not rejected

		select
			@outstandingRequirements = count(1)
		from
			dbo.RegistrationChangeRequirement rcr
		join
			dbo.RequirementStatus							rs on rcr.RequirementStatusSID = rs.RequirementStatusSID
		where
			rcr.RegistrationChangeSID = @RegistrationChangeSID -- for the given registration change
			and
			(
				rs.IsFinal							= @OFF or rs.RequirementStatusSCD = 'FAILED' -- requirement is open or rejected
			);

		if isnull(@outstandingRequirements, 0) > 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RequirementsOutstanding'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The registration change cannot be approved because not all requirements have been met.';

			raiserror(@errorText, 16, 1);
		end;

		-- ensure the form is based on the latest 
		-- license (to avoid overwriting a later change)

		if exists
		(
			select
				1
			from
				dbo.RegistrationChange rc
			join
				dbo.Registration			 reg on rc.RegistrationSID	 = reg.RegistrationSID
			join
				dbo.Registration			 regNew on reg.RegistrantSID = regNew.RegistrantSID and regNew.EffectiveTime > reg.EffectiveTime
			where
				rc.RegistrationChangeSID = @RegistrationChangeSID
		)
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RegistrationOutOfDate'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 cannot be approved because a new registration was approved since this %1 was created. Withdraw this %1 and create a new one based on the current registration.'
			 ,@Arg1 = 'registration-change';

			raiserror(@errorText, 16, 1);

		end;

		begin transaction;

		-- if the form status is not already set to submitted, 
		-- update its status now

		if @currentFormStatusSCD <> 'APPROVED'
		begin

			exec dbo.pRegistrationChangeStatus#Insert
				@RegistrationChangeSID = @RegistrationChangeSID
			 ,@FormStatusSCD = 'APPROVED';

		end;

		-- invoices for are generated upon approval; if no fees are involved
		-- or the generated invoice has been prepaid, then the subroutine 
		-- will also insert the new registration

		exec dbo.pInvoice#SetOnFormChange
			@FormTypeCode = 'REGCHANGE'
		 ,@RegistrationRecordSID = @RegistrationChangeSID
		 ,@ReasonSID = @ReasonSID;

		commit;
	end try
	begin catch
		if @@trancount > 0 rollback;

		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
