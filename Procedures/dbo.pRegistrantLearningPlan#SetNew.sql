SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrantLearningPlan#SetNew
	@RegistrantLearningPlanSID int = null output	-- identity value assigned to the new record o returned from the existing
 ,@RegistrantSID						 int								-- identifies the registrant the learning plan should be created/returned for
 ,@RegistrationYear					 smallint						-- identifies the year the learning plan should be created/returned for
 ,@ReturnDataSet						 bit = 0						-- when 1 return the learning plan entity added
as
/*********************************************************************************************************************************
Sproc    : Registrant Learning Plan - Set New
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Inserts new registrant learning plan or changes status on existing one if withdrawn - returns entity dataset.
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Jul 2018		|	Initial version

Errors	
--------
This procedure is called from the UI to insert a new learning plan for a registrant. The registrant SID and year must both be
passed.  If a learning plan already exists for the criteria, then the key for that record is returned in the output parameter
and the data set for the entity is returned as a data set.

Note that if an existing learning plan is found, and that learning plan has the status of WITHDRAWN, then the procedure updates
the status back to "NEW".  This allows a withdrawn learning plan form to be recovered for a given registration year.

Example
-------
<TestHarness>
	<Test Name = "NoLearningPlan" IsDefault ="true" Description="Creates new learning plan for current year for a random registrant">
		<SQLScript>
			<![CDATA[
declare
	@registrantSID						 int
 ,@registrationYear					 smallint = dbo.fRegistrationYear#Current()
 ,@now											 datetime = sf.fNow()
 ,@registrantLearningPlanSID int;

select top (1)
	@registrantSID = ra.RegistrantSID
from
	dbo.fRegistration#Active(@now) ra
left outer join
	dbo.RegistrantLearningPlan		 rlp on ra.RegistrantSID = rlp.RegistrantSID and ra.RegistrationYear = rlp.RegistrationYear
where
	ra.RegistrationYear = @registrationYear and rlp.RegistrantLearningPlanSID is null
order by
	newid();

if @registrantSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pRegistrantLearningPlan#SetNew
		@RegistrantLearningPlanSID = @registrantLearningPlanSID output
	 ,@RegistrantSID = @registrantSID
	 ,@RegistrationYear = @registrationYear;

	select
		rlp.RegistrantLearningPlanSID
	 ,rlp.RegistrantSID
	 ,rlp.RegistrationYear
	 ,cs.FormStatusSCD
	from
		dbo.RegistrantLearningPlan																												 rlp
	cross apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
	where
		rlp.RegistrantLearningPlanSID = @registrantLearningPlanSID;

	if xact_state() <> -1 rollback;

end;
		]]>
		</SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
	</Test>
	<Test Name = "Withdrawn" IsDefault ="false" Description="Locates WITHDRAWN learning plan and returns it as a NEW status">
		<SQLScript>
			<![CDATA[
declare
	@registrantSID						 int
 ,@registrationYear					 smallint = dbo.fRegistrationYear#Current()
 ,@registrantLearningPlanSID int;

select top (1)
	@registrantSID		= rlp.RegistrantSID
 ,@registrationYear = rlp.RegistrationYear
from
	dbo.RegistrantLearningPlan																												 rlp
cross apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
where
	cs.FormStatusSCD = 'WITHDRAWN'
order by
	newid();

if @registrantSID is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	begin transaction;

	exec dbo.pRegistrantLearningPlan#SetNew
		@RegistrantLearningPlanSID = @registrantLearningPlanSID output
	 ,@RegistrantSID = @registrantSID
	 ,@RegistrationYear = @registrationYear;

	select
		rlp.RegistrantLearningPlanSID
	 ,rlp.RegistrantSID
	 ,rlp.RegistrationYear
	 ,cs.FormStatusSCD
	from
		dbo.RegistrantLearningPlan																												 rlp
	cross apply dbo.fRegistrantLearningPlan#CurrentStatus(rlp.RegistrantLearningPlanSID) cs
	where
		rlp.RegistrantLearningPlanSID = @registrantLearningPlanSID;

	if xact_state() <> -1 rollback;

end;
		]]>
		</SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrantLearningPlan#SetNew'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo	 int					 = 0											-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)													-- message text for business rule errors
	 ,@tranCount int					 = @@trancount						-- determines whether a wrapping transaction exists
	 ,@sprocName nvarchar(128) = object_name(@@procid)	-- name of currently executing procedure
	 ,@xState		 int																		-- error state detected in catch block
	 ,@blankParm varchar(50);														-- name of required parameter left blank

	set @RegistrantLearningPlanSID = null;

	begin try

		-- use a transaction so that any additional updates implemented through the extended
		-- procedure or through table-specific logic succeed or fail as a logical unit

		if @tranCount = 0 -- no outer transaction
		begin
			begin transaction;
		end;
		else -- outer transaction so create save point
		begin
			save transaction @sprocName;
		end;

-- SQL Prompt formatting off
		if @RegistrantSID is null	set @blankParm = '@RegistrantSID'
		if @RegistrationYear is null					set @blankParm = '@RegistrationYear'
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
			@RegistrantLearningPlanSID = rlp.RegistrantLearningPlanSID
		from
			dbo.RegistrantLearningPlan rlp
		where
			rlp.RegistrantSID = @RegistrantSID and rlp.RegistrationYear = @RegistrationYear;

		if @RegistrantLearningPlanSID is null
		begin

			exec dbo.pRegistrantLearningPlan#Insert
				@RegistrantLearningPlanSID = @RegistrantLearningPlanSID output
			 ,@RegistrantSID = @RegistrantSID
			 ,@RegistrationYear = @RegistrationYear;

		end;
		else
		begin

			if exists
			(
				select
					1
				from
					dbo.fRegistrantLearningPlan#CurrentStatus(@RegistrantLearningPlanSID) cs
				where
					cs.FormStatusSCD = 'WITHDRAWN'
			)
			begin

				exec dbo.pRegistrantLearningPlanStatus#Insert
					@RegistrantLearningPlanSID = @RegistrantLearningPlanSID
				 ,@FormStatusSCD = 'NEW';

			end;

		end;

		if @tranCount = 0 and xact_state() = 1 commit transaction;

		if @ReturnDataSet = cast(1 as bit)
		begin

			select
				--!<ColumnList DataSource="dbo.vRegistrantLearningPlan" Alias="rlp">
				 rlp.RegistrantLearningPlanSID
				,rlp.RegistrantSID
				,rlp.RegistrationYear
				,rlp.LearningModelSID
				,rlp.FormVersionSID
				,rlp.LastValidateTime
				,rlp.FormResponseDraft
				,rlp.AdminComments
				,rlp.NextFollowUp
				,rlp.ConfirmationDraft
				,rlp.ReasonSID
				,rlp.IsAutoApprovalEnabled
				,rlp.ReviewReasonList
				,rlp.ParentRowGUID
				,rlp.UserDefinedColumns
				,rlp.RegistrantLearningPlanXID
				,rlp.LegacyKey
				,rlp.IsDeleted
				,rlp.CreateUser
				,rlp.CreateTime
				,rlp.UpdateUser
				,rlp.UpdateTime
				,rlp.RowGUID
				,rlp.RowStamp
				,rlp.LearningModelSCD
				,rlp.LearningModelLabel
				,rlp.LearningModelIsDefault
				,rlp.UnitTypeSID
				,rlp.CycleLengthYears
				,rlp.IsCycleStartedYear1
				,rlp.MaximumCarryOver
				,rlp.LearningModelRowGUID
				,rlp.PersonSID
				,rlp.RegistrantNo
				,rlp.YearOfInitialEmployment
				,rlp.IsOnPublicRegistry
				,rlp.CityNameOfBirth
				,rlp.CountrySID
				,rlp.DirectedAuditYearCompetence
				,rlp.DirectedAuditYearPracticeHours
				,rlp.LateFeeExclusionYear
				,rlp.IsRenewalAutoApprovalBlocked
				,rlp.RenewalExtensionExpiryTime
				,rlp.ArchivedTime
				,rlp.RegistrantRowGUID
				,rlp.FormSID
				,rlp.VersionNo
				,rlp.RevisionNo
				,rlp.IsSaveDisplayed
				,rlp.ApprovedTime
				,rlp.FormVersionRowGUID
				,rlp.ReasonGroupSID
				,rlp.ReasonName
				,rlp.ReasonCode
				,rlp.ReasonSequence
				,rlp.ToolTip
				,rlp.ReasonIsActive
				,rlp.ReasonRowGUID
				,rlp.IsDeleteEnabled
				,rlp.IsReselected
				,rlp.IsNullApplied
				,rlp.zContext
				,rlp.IsViewEnabled
				,rlp.IsEditEnabled
				,rlp.IsSaveBtnDisplayed
				,rlp.IsApproveEnabled
				,rlp.IsRejectEnabled
				,rlp.IsUnlockEnabled
				,rlp.IsWithdrawalEnabled
				,rlp.IsInProgress
				,rlp.RegistrantLearningPlanStatusSID
				,rlp.RegistrantLearningPlanStatusSCD
				,rlp.RegistrantLearningPlanStatusLabel
				,rlp.LastStatusChangeUser
				,rlp.LastStatusChangeTime
				,rlp.FormOwnerSCD
				,rlp.FormOwnerLabel
				,rlp.FormOwnerSID
				,rlp.IsPDFDisplayed
				,rlp.PersonDocSID
				,rlp.RegistrantLearningPlanLabel
				,rlp.RegistrationYearLabel
				,rlp.CycleEndRegistrationYear
				,rlp.CycleRegistrationYearLabel
				,rlp.NewFormStatusSCD
			--!</ColumnList>
			from
				dbo.vRegistrantLearningPlan rlp
			where
				rlp.RegistrantLearningPlanSID = @RegistrantLearningPlanSID;

		end

	end try
	begin catch
		set @xState = xact_state();

		if @tranCount > 0 and @xState = 1
		begin
			rollback transaction @sprocName; -- committable wrapping trx exists: rollback to savepoint
		end;
		else if @xState <> 0 -- full rollback
		begin
			rollback;
		end;

		exec @errorNo = sf.pErrorRethrow; -- process message text and re-throw the error
	end catch;

	return (@errorNo);

end;
GO
