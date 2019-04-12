SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
create procedure dbo.pFormSet#SetStatus
	 @ParentRowGUID				uniqueidentifier					-- GUID identifying the instance of the form (e.g. the member renewal)
	,@FormStatusSCD				varchar(25)								-- form status to set
	,@IsParentSet					bit												-- indicates if called from a parent form to avoid look up for a parent form
as
/*********************************************************************************************************************************
Sproc    : Form Set - Set Status
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure sets all form's that are part of the passed form set GUID to the form status SCD passed.
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Cory Ng			| Nov 2018 		| Initial version
 
Comments
--------
This procedure is called when any form in a form set is set to either an returned or unlocked status. All other forms in the form
set are set to the passed in status. If its being called by a parent form passing @IsParentSet as ON bypasses the check of the
other parent form types as the EF procedure would have updated the status already. If called by a child form (eg: profile update
or learning plan), the parent form is looked up by the parent row GUID passed.

This procedure is not used for setting statuses to submit or approved. These status are done through the submit and approval
procedures as they handle setting the statuses on sub-forms as well running form posting logic.

Call Syntax
-----------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			declare
				@parentRowGUID uniqueidentifier;

			select top (1)
				@parentRowGUID = rr.RowGUID
			from
				dbo.RegistrantRenewal rr
			cross apply
				dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) cs
			where
				cs.FormOwnerSCD = 'ADMIN'
			order by
				newid()

			begin tran

			exec dbo.pFormSet#SetStatus
				 @ParentRowGUID = @parentRowGUID
				,@FormStatusSCD = 'RETURNED'
				,@IsParentSet = 1

			rollback

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pFormSet#SetStatus'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo								int							 = 0																		-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText							nvarchar(4000)																					-- message text for business rule errors
	 ,@blankParm							varchar(50)																							-- tracks name of any required parameter not passed
	 ,@OFF										bit							 = cast(0 as bit)												-- constant for bit comparison = 0
	 ,@registrantFormSID			int																											-- key of the registrant's form SID
	 ,@currentFormStatusSCD		varchar(25)																							-- form status of the current registrant form
	 ,@i											int																											-- loop index
	 ,@maxRows								int																											-- loop limit

	declare 
		@learningPlans table																														-- list of learning plans to change status for
	(
		 ID												 int      identity(1,1)
		,RegistrantLearningPlanSID int not null
	);

	begin try

		-- check parameters

-- SQL Prompt formatting off
		if @ParentRowGUID				is null set @blankParm = '@ParentRowGUID';
		if @FormStatusSCD				is null set @blankParm = '@FormStatusSCD';
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

		if @FormStatusSCD not in ('RETURNED', 'UNLOCKED')
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'InvalidStatus'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The status (%1) can''t be set to other form''s in the form set.'
			 ,@Arg1 = @FormStatusSCD;

			raiserror(@errorText, 18, 1);
		end;

		-- If parent form status not already set look for the 
		-- parent form based on the ParentRowGUID passed and 
		-- set it's status

		if @IsParentSet = @OFF
		begin

			select
				 @registrantFormSID = rr.RegistrantRenewalSID
				,@currentFormStatusSCD = cs.FormStatusSCD
			from
				dbo.RegistrantRenewal rr
			cross apply
				dbo.fRegistrantRenewal#CurrentStatus(rr.RegistrantRenewalSID, -1) cs
			where
				rr.RowGUID = @ParentRowGUID
			and
				cs.IsFinal = @OFF

			if @registrantFormSID is not null and @currentFormStatusSCD <> @FormStatusSCD
			begin

				exec dbo.pRegistrantRenewal#Update
					 @RegistrantRenewalSID = @registrantFormSID
					,@NewFormStatusSCD = @FormStatusSCD

			end

			if @registrantFormSID is null
			begin
			
				select
					 @registrantFormSID = rr.ReinstatementSID
					,@currentFormStatusSCD = cs.FormStatusSCD
				from
					dbo.Reinstatement rr
				cross apply
					dbo.fReinstatement#CurrentStatus(rr.ReinstatementSID, -1) cs
				where
					rr.RowGUID = @ParentRowGUID
				and
					cs.IsFinal = @OFF

				if @registrantFormSID is not null and @currentFormStatusSCD <> @FormStatusSCD
				begin

					exec dbo.pReinstatement#Update
						 @ReinstatementSID = @registrantFormSID
						,@NewFormStatusSCD = @FormStatusSCD

				end

			end

			if @registrantFormSID is null
			begin
			
				select
					 @registrantFormSID = rr.RegistrantAppSID
					,@currentFormStatusSCD = cs.FormStatusSCD
				from
					dbo.RegistrantApp rr
				cross apply
					dbo.fRegistrantApp#CurrentStatus(rr.RegistrantAppSID, -1) cs
				where
					rr.RowGUID = @ParentRowGUID
				and
					cs.IsFinal = @OFF

				if @registrantFormSID is not null and @currentFormStatusSCD <> @FormStatusSCD
				begin

					exec dbo.pRegistrantApp#Update
						 @RegistrantAppSID = @registrantFormSID
						,@NewFormStatusSCD = @FormStatusSCD

				end

			end

			if @registrantFormSID is null
			begin
			
				select
					 @registrantFormSID = rr.RegistrantAuditSID
					,@currentFormStatusSCD = cs.FormStatusSCD
				from
					dbo.RegistrantAudit rr
				cross apply
					dbo.fRegistrantAudit#CurrentStatus(rr.RegistrantAuditSID, -1) cs
				where
					rr.RowGUID = @ParentRowGUID
				and
					cs.IsFinal = @OFF

				if @registrantFormSID is not null and @currentFormStatusSCD <> @FormStatusSCD
				begin

					exec dbo.pRegistrantAudit#Update
						 @RegistrantAuditSID = @registrantFormSID
						,@NewFormStatusSCD = @FormStatusSCD

				end

			end

		end
		
		set @registrantFormSID = null

		select																																-- set status for profile updates
			@registrantFormSID = rr.ProfileUpdateSID
		from
			dbo.ProfileUpdate rr
		cross apply
			dbo.fProfileUpdate#CurrentStatus(rr.ProfileUpdateSID, -1) cs
		where
			rr.ParentRowGUID = @ParentRowGUID
		and
			cs.FormStatusSCD <> @FormStatusSCD
		and
			cs.IsFinal = @OFF

		if @registrantFormSID is not null 
		begin

			exec dbo.pProfileUpdate#Update
					@ProfileUpdateSID = @registrantFormSID
				,@NewFormStatusSCD = @FormStatusSCD

		end

		set @registrantFormSID = null

		insert																																-- form set can have multiple learning plan forms assigned
			@learningPlans(RegistrantLearningPlanSID)
		select
			 rr.RegistrantLearningPlanSID
		from
			dbo.RegistrantLearningPlan rr
		cross apply
			dbo.fRegistrantLearningPlan#CurrentStatus(rr.RegistrantLearningPlanSID) cs
		where
			rr.ParentRowGUID = @ParentRowGUID
		and
			cs.FormStatusSCD <> @FormStatusSCD
		and
			cs.IsFinal = @OFF

		set @maxRows = @@rowcount
		set @i = 0
		
		while @i < @maxRows
		begin

			set @i += 1

			select
				@registrantFormSID = x.RegistrantLearningPlanSID
			from
				@learningPlans x
			where
				x.ID = @i

			exec dbo.pRegistrantLearningPlan#Update
					@RegistrantLearningPlanSID = @registrantFormSID
				,@NewFormStatusSCD = @FormStatusSCD

		end

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
