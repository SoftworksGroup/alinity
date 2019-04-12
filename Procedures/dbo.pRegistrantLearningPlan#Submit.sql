SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pRegistrantLearningPlan#Submit]
	@RegistrantLearningPlanSID int  -- key of the learning plan to submit
 ,@FormResponseDraft		xml       -- form content being submitted
 ,@FormVersionSID				int       -- version of the form to obtain definition for
as
/*********************************************************************************************************************************
Procedure : Registrant Learning Plan Submit (form responses)
Notice    : Copyright © 2012 Softworks Group Inc.
Summary   : Saves form responses marked to "PostOnSubmit" to the database tables
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Sep	2017			|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure extracts values from the XML document of form responses and writes those values to the database tables.  The 
procedure expects to be called from pRegistrantLearningPlan#Update.  The procedure will also support being called from a process 
which submits multiple forms as a batch.

Unlike the #Approve version of the procedure, this procedure limits updates performed to those where the attribute in the form XML 
"PostOnSubmit" is enabled (="true").  If the calling program has not yet changed the status of the record to SUBMITTED, this 
procedure sets that status (supports batch calling). 

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Submit a registrant learning plan form in new status at random">
		<SQLScript>
			<![CDATA[
			
declare
	@registrantLearningPlanSID		int
 ,@formResponseDraft						xml
 ,@formVersionSID								int;

select top (1)
	@registrantLearningPlanSID	 = rr.RegistrantLearningPlanSID
 ,@formResponseDraft = rr.FormResponseDraft
 ,@formVersionSID		 = rr.FormVersionSID
from
	dbo.vRegistrantLearningPlan rr
where
	rr.RegistrantLearningPlanStatusSCD = 'NEW'
order by
	newid();

if @@rowcount = 0
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pRegistrantLearningPlan#Submit
		@RegistrantLearningPlanSID = @registrantLearningPlanSID
	 ,@FormResponseDraft = @formResponseDraft
	 ,@FormVersionSID = @formVersionSID;

	select
		x.RegistrantLearningPlanSID
	 ,x.RegistrantLearningPlanStatusSCD
	from
		dbo.vRegistrantLearningPlan x
	where
		x.RegistrantLearningPlanSID = @registrantLearningPlanSID
	and
		x.RegistrantLearningPlanStatusSCD = 'SUBMITTED'

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
	 @ObjectName			= 'dbo.pRegistrantLearningPlan#Submit'
	,@DefaultTestOnly = 1
-------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)									-- message text (for business rule errors)
	 ,@blankParm						varchar(50)											-- tracks if any required parameters are not provided
	 ,@formStatusSID				int															-- key of SUBMITTED status record (in sf.FormStatus)
	 ,@currentFormStatusSCD varchar(25)											-- current status of the record
	 ,@formDefinition				xml;														-- xml of the form definition for the learning plan

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @FormVersionSID is null						set @blankParm = '@FormVersionSID';
		if @FormResponseDraft is null					set @blankParm = '@FormResponseDraft';
		if @RegistrantLearningPlanSID is null set @blankParm = '@RegistrantLearningPlanSID';
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
		from
			dbo.RegistrantLearningPlan																																	 rr
		join
			sf.FormVersion																																				 fv on rr.FormVersionSID = fv.FormVersionSID
		outer apply dbo.fRegistrantLearningPlan#CurrentStatus(rr.RegistrantLearningPlanSID) rrcs
		where
			rr.RegistrantLearningPlanSID = @RegistrantLearningPlanSID;

		if @@rowcount = 0
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.RegistrantLearningPlan'
			 ,@Arg2 = @RegistrantLearningPlanSID;

			raiserror(@errorText, 18, 1);
		end;

		begin transaction;

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

			exec dbo.pRegistrantLearningPlanStatus#Insert @RegistrantLearningPlanSID = @RegistrantLearningPlanSID, @FormStatusSID = @formStatusSID;
		end;

		exec sf.pForm#Post		-- auto approval not enabled so process post-on-submit columns
				@FormRecordSID = @RegistrantLearningPlanSID
			 ,@FormActionCode = 'SUBMIT'
			 ,@FormSchemaName = 'dbo'
			 ,@FormTableName = 'RegistrantLearningPlan'
			 ,@FormDefinition = @formDefinition
			 ,@Response = @FormResponseDraft;

		commit;
	end try

	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
