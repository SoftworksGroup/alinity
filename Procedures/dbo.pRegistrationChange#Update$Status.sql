SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pRegistrationChange#Update$Status]
	@RegistrationChangeSID int					-- key of the RegistrationChange form record to process the status change for
 ,@NewFormStatusSCD			 varchar(25)	-- new status value (see sf.FormStatus for master list)
 ,@InvoiceSID						 int					-- invoice - if any - associated with the form (controls WITHDRAWAL action)
as
/*********************************************************************************************************************************
Sproc    : RegistrationChange Update Status
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure saves and processes changes in status on the RegistrationChange form
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version

Comments	
--------
This procedure is called from #Update to save and process changes in status passed through the @NewForStatusSCD parameter. No
action is performed if the new status parameter is null.

When status is changed a history record is recorded.  The procedure is also responsible for calling the #Approve and #Withdraw
subroutines when those status codes are passed. 

Example:
--------
<TestHarness>
  <Test Name = "Approve" IsDefault ="true" Description="Executes the procedure to approve a RegistrationChange form at random.">
    <SQLScript>
      <![CDATA[
declare
	@registrationChangeSID	 int
 ,@formOwnerSID			 int
 ,@invoiceSID				 int;

select top (1)
	@registrationChangeSID	 = rc.RegistrationChangeSID
 ,@formOwnerSID			 = rcs.FormOwnerSID
 ,@invoiceSID				 = rc.InvoiceSID
from
	dbo.RegistrationChange																												rc
cross apply dbo.fRegistrationChange#CurrentStatus(rc.RegistrationChangeSID, -1) rcs
where
	rcs.FormStatusSCD in ('INREVIEW', 'SUBMITTED')
order by
	newid();

if @registrationChangeSID is null
begin
	raiserror(N'* ERROR: no sample data found to run test', 18, 1);
end;
else
begin

	begin transaction;

	exec dbo.[pRegistrationChange#Update$Status]
		@RegistrationChangeSID = @registrationChangeSID
	 ,@NewFormStatusSCD = 'APPROVED'
	 ,@FormOwnerSID = @formOwnerSID
	 ,@InvoiceSID = @invoiceSID;

	select
		rcs.FormStatusSCD
	from
		dbo.fRegistrationChange#CurrentStatus(@registrationChangeSID. -1) rcs
   where
    rcs.FormStatusSCD = 'APPROVED';

	rollback;

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
	 @ObjectName = 'dbo.pRegistrationChange#Update$Status'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin
	set nocount on;

	declare
		@errorNo			 int = 0				-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText		 nvarchar(4000) -- message text (for business rule errors)
	 ,@formStatusSID int;						-- key of the form-status-code passed in (if any)

	begin try

		-- where a form status has been passed in, lookup its key
		-- and ensure the new status is saved to the status history table

		if @NewFormStatusSCD is not null -- if just saving in place (save and continue) pass this as NULL!
		begin

			select
				@formStatusSID = fs.FormStatusSID
			from
				sf.FormStatus fs
			where
				fs.FormStatusSCD = @NewFormStatusSCD;

			if @formStatusSID is null
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'sf.FormStatus'
				 ,@Arg2 = @NewFormStatusSCD;

				raiserror(@errorText, 18, 1);

			end;

			exec dbo.pRegistrationChangeStatus#Insert -- saves the new status
				@RegistrationChangeSID = @RegistrationChangeSID
			 ,@FormStatusSID = @formStatusSID;

			-- post values to the main profile as required for
			-- the SUBMIT and APPROVE form actions

			if @NewFormStatusSCD = 'APPROVED'
			begin

				exec dbo.pRegistrationChange#Approve
					@RegistrationChangeSID = @RegistrationChangeSID;

			end;
			else if @NewFormStatusSCD = 'WITHDRAWN' and @InvoiceSID is not null
			begin

				exec dbo.pRegistrationChange#Withdraw
					@RegistrationChangeSID = @RegistrationChangeSID;

			end;
		end;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
