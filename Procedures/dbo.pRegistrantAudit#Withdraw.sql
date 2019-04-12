SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantAudit#Withdraw]
	@RegistrantAuditSID int -- key of the audit form to withdraw
as
/*********************************************************************************************************************************
Procedure : Registrant Audit Withdraw
Notice    : Copyright © 2012 Softworks Group Inc.
Summary   : Withdraws an audit form
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Kris Dawson	| Oct	2017			|	Initial version
				:							|								| 
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure withdraws the audit form and any associated reviews. The member can never withdraw an audit so a check is made
against ADMIN.AUDIT (so that, or sa).

Audit Administrators can perform withdrawal on final statuses, this is to match the ability of administrators to withdraw
approved renewals.

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Withdraw an audit form in new, submitted or returned status at random">
		<SQLScript>
			<![CDATA[

declare @RegistrantAuditSID int;

select top (1)
	@RegistrantAuditSID = ra.RegistrantAuditSID
from
	dbo.vRegistrantAudit rr
where
	rr.RegistrantAuditStatusSCD in ('RETURNED', 'SUBMITTED', 'NEW')
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pRegistrantAudit#Withdraw
		@RegistrantAuditSID = @RegistrantAuditSID;

	if @@trancount > 0 rollback; -- rollback transaction to avoid permanent data change
end;			

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pRegistrantAudit#Withdraw'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int							 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm						varchar(50)												-- tracks if any required parameters are not provided
	 ,@ON										bit							 = cast(1 as bit) -- constant for bit comparisons
	 ,@OFF									bit							 = cast(0 as bit) -- constant for bit comparisons
	 ,@now									datetimeoffset(7)									-- current time
	 ,@recordSID						int																-- next review record to process
	 ,@registrantSID				int																-- key of registrant audit is created for
	 ,@registrationYear			smallint													-- year of audit record
	 ,@isFinalStatus				bit;															-- current status of the record

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @RegistrantAuditSID is null set @blankParm = '@RegistrantAuditSID';
-- SQL Prompt formatting on

		if @blankParm is not null
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);
    end

		select
			@isFinalStatus				= fs.IsFinal		 
		 ,@registrantSID				= ra.RegistrantSID
		 ,@registrationYear			= ra.RegistrationYear -- the registration year of the registration being renewed
		from
      dbo.RegistrantAudit ra
		cross apply 
			dbo.fRegistrantAudit#CurrentStatus(ra.RegistrantAuditSID, -1) racs	
		join
			sf.FormStatus																					fs on racs.FormStatusSID = fs.FormStatusSID
    where
      ra.RegistrantAuditSID = @RegistrantAuditSID
      
		if @registrantSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.RegistrantAudit'
			 ,@Arg2 = @RegistrantAuditSID;

			raiserror(@errorText, 18, 1);
		end;		

		if @isFinalStatus = @ON and sf.fIsGranted('ADMIN.AUDIT') = @OFF
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'FormIsFinal'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 action cannot be carried out because this form is already in a final status. Contact registration for assistance.'
			 ,@Arg1 = 'withdraw';

			raiserror(@errorText, 16, 1);
		end;
		
		-- set all reviews to withdrawn

		while @recordSID is not null
		begin

			set @recordSID = null;

			select
				@recordSID = rar.RegistrantAuditReviewSID
			from
				dbo.RegistrantAuditReview rar
			join
				sf.FormVersion																			fv on rar.FormVersionSID = fv.FormVersionSID
			join
				sf.Form																							f on fv.FormSID = f.FormSID
			cross apply
				dbo.fRegistrantAuditReview#CurrentStatus(rar.RegistrantAuditReviewSID, f.FormTypeSID)	racs
			where
				rar.RegistrantAuditSID = @RegistrantAuditSID and racs.FormStatusSCD <> 'WITHDRAWN';

			if @recordSID is not null
			begin

				exec dbo.pRegistrantAuditReview#Update
					 @RegistrantAuditReviewSID = @recordSID
					,@NewFormStatusSCD = 'WITHDRAWN';

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
