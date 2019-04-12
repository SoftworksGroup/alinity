SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantApp#Submit
	@RegistrantAppSID	 int	-- key of the application to approve
 ,@FormResponseDraft xml	-- form content being approved
 ,@FormVersionSID		 int	-- version of the form to obtain definition for
as
/*********************************************************************************************************************************
Procedure : Registrant Application Submit (form responses)
Notice    : Copyright © 2012 Softworks Group Inc.
Summary   : Saves form responses marked to "PostOnSubmit" to the database tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Aug	2017			|	Initial version
				: Tim Edlund	| Oct 2017			| Updated to include optimizations implemented for renewal.
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure extracts values from the XML document of form responses and writes those values to the database tables.  The 
procedure expects to be called from pRegistrantApp#Update.  The procedure will also support being called from a process which
submits multiple forms as a batch.

Unlike the #Approve version of the procedure, this procedure limits updates performed to those where the attribute in the form XML 
"PostOnSubmit" is enabled (="true").  If the calling program has not yet changed the status of the record to SUBMITTED, this procedure 
sets that status (supports batch calling). 

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Submit a registrant application form in new status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@registrantAppSID	 int
 ,@formResponseDraft xml
 ,@formVersionSID		 int;

select top (1)
	@registrantAppSID	 = rr.RegistrantAppSID
 ,@formResponseDraft = rr.FormResponseDraft
 ,@formVersionSID		 = rr.FormVersionSID
from
	dbo.vRegistrantApp rr
where
	rr.FormStatusSCD = 'NEW'
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pRegistrantApp#Submit
		@RegistrantAppSID = @registrantAppSID
	 ,@FormResponseDraft = @formResponseDraft
	 ,@FormVersionSID = @formVersionSID;

	select
		x.RegistrantAppSID
	 ,x.FormStatusSCD
	from
		dbo.vRegistrantApp x
	where
		x.RegistrantAppSID = @registrantAppSID
	and
		x.FormStatusSCD = 'SUBMITTED'

		if @@trancount > 0 rollback;	-- rollback transaction to avoid permanent data change
	end;

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="5" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pRegistrantApp#Submit'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int = 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)				-- message text (for business rule errors)
	 ,@blankParm						varchar(50)						-- tracks if any required parameters are not provided
	 ,@OFF									bit = cast(0 as bit)	-- constant for bit comparison = 0
	 ,@formStatusSID				int										-- key of SUBMITTED status record (in sf.FormStatus)
	 ,@currentFormStatusSCD varchar(25)						-- current status of the record
	 ,@rowGUID							uniqueidentifier			-- linking value to sub-forms of the parent forms
	 ,@registrationYear			smallint							-- the year of registration targeted by the form
	 ,@formDefinition				xml;									-- xml of the form definition for the application

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @FormVersionSID is null 		set @blankParm = '@FormVersionSID';
		if @FormResponseDraft is null	set @blankParm = '@FormResponseDraft';
		if @RegistrantAppSID is null	set @blankParm = '@RegistrantAppSID';
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

		select
			@currentFormStatusSCD = rrcs.FormStatusSCD
		 ,@formDefinition				= fv.FormDefinition
		 ,@registrationYear			= ra.RegistrationYear
		 ,@rowGUID							= ra.RowGUID
		from
			dbo.RegistrantApp																															 ra
		join
			sf.FormVersion																																 fv on ra.FormVersionSID = fv.FormVersionSID
		outer apply dbo.fRegistrantApp#CurrentStatus(ra.RegistrantAppSID, -1) rrcs
		where
			ra.RegistrantAppSID = @RegistrantAppSID;

		if @@rowcount = 0
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.RegistrantApp'
			 ,@Arg2 = @RegistrantAppSID;

			raiserror(@errorText, 18, 1);
		end;

		begin transaction;

		-- Tim Edlund | Sep 2018
		-- Submit any sub-forms associated with this parent
		-- form that are not already submitted

		exec dbo.pSubForms#Submit
			@ParentRowGUID = @rowGUID
		 ,@RegistrationYear = @registrationYear;

		-- if the form status is not already set to submitted, 
		-- update its status now

		if @currentFormStatusSCD <> 'SUBMITTED'
		begin

			select
				@formStatusSID = fs.FormStatusSID
			from
				sf.FormStatus fs
			where
				fs.FormStatusSCD = 'SUBMITTED';

			if @formStatusSID is null
			begin
				exec sf.pMessage#Get
					@MessageSCD = 'RecordNotFound'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				 ,@Arg1 = 'sf.FormStatus'
				 ,@Arg2 = 'SUBMITTED';

				raiserror(@errorText, 18, 1);
			end;

			exec dbo.pRegistrantAppStatus#Insert
				@RegistrantAppSID = @RegistrantAppSID
			 ,@FormStatusSID = @formStatusSID;

		end;

		-- Tim Edlund | Sep 2018
		-- Before posting the submitted form to the main
		-- tables, check if it will be auto-approved so
		-- that posting is only performed once

		if dbo.fRegistrantApp#IsAutoApprovalPending(@RegistrantAppSID) = @OFF
		begin

			exec sf.pForm#Post -- auto approval not enabled so process post-on-submit columns
				@FormRecordSID = @RegistrantAppSID
			 ,@FormActionCode = 'SUBMIT'
			 ,@FormSchemaName = 'dbo'
			 ,@FormTableName = 'RegistrantApp'
			 ,@FormDefinition = @formDefinition
			 ,@Response = @FormResponseDraft;

			-- invoices may be generated upon submit event for applications
			-- but only where auto-approval is not enabled

			exec dbo.pInvoice#SetOnFormChange
				@FormTypeCode = 'APPLICATION'
			 ,@RegistrationRecordSID = @RegistrantAppSID
			 ,@FormStatusSCD = 'SUBMITTED';

		end
		else
		begin

			exec dbo.pRegistrantApp#Approve -- otherwise auto-approval is enabled so process approval
				@RegistrantAppSID = @RegistrantAppSID
			 ,@FormResponseDraft = @FormResponseDraft
			 ,@FormVersionSID = @FormVersionSID;

		end;

		commit;

	end try
	begin catch
		if @@trancount > 0 rollback;

		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
