SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pReinstatement#Submit
	@ReinstatementSID	 int	-- key of the change to submit
 ,@FormResponseDraft xml	-- form content to submit
as
/*********************************************************************************************************************************
Procedure : Registrant Change Submit (form responses)
Notice    : Copyright © 2018 Softworks Group Inc.
Summary   : Saves form responses marked to "PostOnSubmit" to the database tables or calls #Approve if auto-approval is enabled
----------------------------------------------------------------------------------------------------------------------------------
History		: Author(s)  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar 2018		|	Initial version
					: Cory Ng			| Dec 2018		| Pass the previous year to the sub form submit procedure so it can select the
																			| correct learning plan to submit

Comments	
--------
This procedure is called when the "SUBMIT" action is applied from the UI by the member or administrator. The procedure validates
parameters and retrieves the form definition that will be required to post the content of the form to database tables.  The
procedure checks whether the form will be automatically approved (auto-approve enabled), in which case it calls the #Approve 
procedure. If auto-approval is not enabled then the form posting procedure is called (sf.pForm#Post) to write values marked to 
"post-on-submit" to the database tables.  

The #Approve procedure will call sf.pForm#Post as well and avoiding the extra call to the process improves performance. Unlike 
the #Approve version of the procedure, this procedure limits updates performed to those where the attribute in the form XML 
"PostOnSubmit" is enabled (="true").  If the calling program has not yet changed the status of the record to SUBMITTED, this 
procedure sets that status (this supports batch calling). 

Example
-------
<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Submit a registrant change form in new status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@reinstatementSID int
 ,@formResponseDraft		 xml

select top (1)
	@reinstatementSID = r.ReinstatementSID
 ,@formResponseDraft		 = r.FormResponseDraft
from
	dbo.vReinstatement r
where
	r.ReinstatementStatusSCD = 'NEW'
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pReinstatement#Submit
		@ReinstatementSID = @reinstatementSID
	 ,@FormResponseDraft = @formResponseDraft

	select
		x.ReinstatementSID
	 ,x.ReinstatementStatusSCD
	from
		dbo.vReinstatement x
	where
		x.ReinstatementSID = @reinstatementSID and x.ReinstatementStatusSCD = 'SUBMITTED';

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
	 @ObjectName			= 'dbo.pReinstatement#Submit'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int							= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm						varchar(50)												-- tracks if any required parameters are not provided
	 ,@OFF									bit							= cast(0 as bit)	-- constant for bit comparisons
	 ,@rowGUID							uniqueidentifier									-- linking value to sub-forms of the parent forms
	 ,@registrationYear			smallint													-- the year of registration targetted by the form
	 ,@currentFormStatusSCD varchar(25)												-- current status of the record
	 ,@formDefinition				xml																-- xml of the form definition for the renewal
	 ,@registrationSID			int;															-- registration being reinstated

	begin try

-- SQL Prompt formatting off
		if @FormResponseDraft			is null set @blankParm = '@FormResponseDraft';
		if @ReinstatementSID	is null set @blankParm = '@ReinstatementSID';
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

		-- retrieve values required for posting
		-- and to check status and the key value

		select
			@currentFormStatusSCD = isnull(cs.FormStatusSCD, 'NEW')
		 ,@formDefinition				= fv.FormDefinition
		 ,@registrationYear			= r.RegistrationYear
		 ,@rowGUID							= r.RowGUID
		 ,@registrationSID			= r.RegistrationSID
		from
			dbo.Reinstatement																							 r
		join
			sf.FormVersion																								 fv on r.FormVersionSID = fv.FormVersionSID
		outer apply dbo.fReinstatement#CurrentStatus(r.ReinstatementSID, -1) cs -- returns no rows if no status records exist (use outer)
		where
			r.ReinstatementSID = @ReinstatementSID;

		if @@rowcount = 0
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.Reinstatement'
			 ,@Arg2 = @ReinstatementSID;

			raiserror(@errorText, 18, 1);
		end;

		begin transaction;

		-- Tim Edlund | Sep 2018
		-- Submit any sub-forms associated with this parent
		-- form that are not already submitted.
		-- Pass the registration year as the previous year 
		-- as learning plans tied to a reinstatement are 
		-- always a year back

		set @registrationYear = @registrationYear - 1	

		exec dbo.pSubForms#Submit
			@ParentRowGUID = @rowGUID
		 ,@RegistrationYear = @registrationYear;

		-- if the form status is not already set to submitted, 
		-- update its status now

		if @currentFormStatusSCD <> 'SUBMITTED'
		begin

			exec dbo.pReinstatementStatus#Insert
				@ReinstatementSID = @ReinstatementSID
			 ,@FormStatusSCD = 'SUBMITTED';

		end;

		-- before posting the submitted form to the main tables, check
		-- if it will be auto-approved and if so, call #Approve
		-- to avoid posting the content twice

		if exists
		(
			select
				1
			from
				dbo.fReinstatement#AutoApprovalStatus(@registrationSID) aas
			where
				aas.IsAutoApprovalPending = @OFF
		)
		begin

			exec sf.pForm#Post -- auto approval not enabled - apply post-on-submit columns only 
				@FormRecordSID = @ReinstatementSID
			 ,@FormActionCode = 'SUBMIT'
			 ,@FormSchemaName = 'dbo'
			 ,@FormTableName = 'Reinstatement'
			 ,@FormDefinition = @formDefinition
			 ,@Response = @FormResponseDraft;

		end;
		else
		begin

			exec dbo.pReinstatement#Approve -- auto-approval is enabled - approve the form
				@ReinstatementSID = @ReinstatementSID
			 ,@FormResponseDraft = @FormResponseDraft;

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
