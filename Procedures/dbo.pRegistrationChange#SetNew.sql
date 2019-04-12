SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pRegistrationChange#SetNew
	@Registrations							xml									-- list of Registration SID values to change registration for
 ,@PracticeRegisterSectionSID int									-- ID of practice register section to change to (target register section)
 ,@ReasonSID									int = null					-- ID of reason for change of registration
 ,@ReservedRegistrantNo				varchar(50) = null	-- Registrant no to set when change is approved (only applied if one registration is changing)
 ,@RegistrationEffective			date = null					-- Registration effective date to set when the change is approved
 ,@IsPreviewOnly							bit = 0							-- when 1 the insert is not performed result is returned
 ,@ReturnDataSet							bit = 1							-- controls whether data set is returned (forced ON for preview mode)
 ,@JobRunSID									int = null					-- job run id used for logging when called as asynchronous process
 ,@StopOnError								bit = 0							-- controls whether procedure terminate on first error; s/b OFF on async calls
 ,@RecordsProcessed						int = 0 output			-- count of records processed  
 ,@ErrorCount									int = 0 output			-- count of errors encountered during processing
 ,@DebugLevel									int = 0							-- when > 0 debug statements to trace logic are sent to the console
as
/*********************************************************************************************************************************
Sproc    : Registration Change - Set New
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : Inserts Registration Change records, or previews the insert, for the given list of registrant ID's passed in
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| Apr 2018		|	Initial version
					: Cory Ng			| Sep 2018		| Passed through reserved registrant no if passed (only applies if one registration is changing)
					: Cory Ng			| Mar 2019		| Updated to only pull only non declaration requirements into the reg change form and deal
																				with recycling withdrawn registration change forms

Errors	
--------
This procedure is called from the UI to insert one or more dbo.RegistrationChange records.  The procedure may be called passing
@IsPreviewOnly = 1 in which case the insert is not carried but validation is performed and a data set indicating whether any 
errors would result is returned.  The @ReturnDataSet parameter is forced ON when in preview mode but it may be set OFF explicitly
when preview mode is not being used.

The registrant key values (dbo.Registrant.RegistrationSID) must be passed in the XML parameter using the following format:

<Registrations>
		<Registration SID="1003170" />
		<Registration SID="1000011" />
		<Registration SID="1000123" />
</Registrations> 

Selecting registration to apply in this procedure can be done manually using various search screens available in the 
system or through product or custom queries that return registrant keys that can be formatted as the XML parameter.  

A Reason key is optional but should be used to explain the reason for the change - for example on assignment of non-renewing 
individuals the reason key for "Did not renew" should be provided.

Setting all non-renewed to suspended/inactive
---------------------------------------------
Although this procedure is designed to support any type of register change, the most common change is applied after the
renewal period to suspend or deactivate registrants who have not renewed. These individuals are assigned to an inactive register. 
The process is accomplished by first executing a product query (quick search) to select non-renewed registrations. The full set of 
those registrants or a sub-set can then be selected by the administrator for processing using the multi-select ("pinning") 
feature. The menu option for "Change registration" is then selected. This option prompts the user for the target register 
(inactive) and a reason for the change to pass along with the list of selected registrant keys to this procedure for processing.  
Because the process may be time consuming if large numbers of registrants must be processed, the process should be submitted 
asynchronously (pass job run SID)  if the quantity of keys exceeds 1000. 

Auto-approval rules
--------------------
Processing of changes to an active register typically requires actions from the Administrator or Registrant or both. The actions
needed are defined as (dbo) Practice-Register-Change-Requirement records.  When changing to an inactive practice register, 
however, no actions are required so manual approvals is not required.  This procedure will automatically approve the registration 
change if: 

1) the target register is inactive and 
2) no mapped requirements for the change have been created.

Normally moving to an inactive practice type does not involve requirement mapping but it is possible to set them up to avoid
having this procedure automatically approve the change.

Mapping requirements
--------------------
When the registration changes it "to" an active practice registration a mapping should be in place for it.  A mapping 
is the first step in defining both requirements and pricing for the change (dbo.PracticeRegisterChange).  If a change
needs to be put through that is not mapped, it will be allowed by the system for System Administrators.  In that case
a warning is returned in messages and the change cannot be auto-approved. 

Validation
----------
Validation is applied regardless of whether or not the Preview Mode is being invoked (@IsPreviewOnly = 1).  Review the 
case logic populating the "Comments" column of the work table for the current list. When the procedure is being called
asynchronously (@JobRunSID is not null), an errors identified in the pre-validation process are logged. If being 
called synchronously and not in Preview mode, any validation error is reported to the console.

Example
-------
<TestHarness>
	<Test Name = "Inactive" IsDefault ="true" Description="Sets a small random group of active registrations to
inactive status">
		<SQLScript>
			<![CDATA[
declare
	@registrations					xml
 ,@registrationSIDList		nvarchar(1000)
 ,@practiceRegisterSectionSID int
 ,@practiceRegisterLabel			nvarchar(35)
 ,@reasonSID									int
 ,@reasonName									nvarchar(65)
 ,@registrationYear						smallint = dbo.fRegistrationYear#Current();

select top (1)
	@practiceRegisterSectionSID = prs.PracticeRegisterSectionSID
 ,@practiceRegisterLabel			= pr.PracticeRegisterLabel
from
	dbo.PracticeRegister				pr
join
	dbo.PracticeRegisterSection prs on pr.PracticeRegisterSID = prs.PracticeRegisterSID
where
	pr.IsDefaultInactivePractice = 1 -- get inactive practice register
	and prs.IsActive						 = 1
order by
	pr.PracticeRegisterSID;

-- look for the default reason code to apply in this scenario

select
	@reasonSID	= rsn.ReasonSID
 ,@reasonName = rsn.ReasonName
from
	dbo.Reason rsn
where
	rsn.ReasonCode = 'REGCHANGE.NORENEWAL';

-- get some registrations for the current year
-- where no renewal form exists

set @registrationSIDList = N'<Registrations>';

select top (1)
	@registrationSIDList =
		@registrationSIDList + char(13) + char(10) + char(9) + N'<Registration SID="' + ltrim(reg.RegistrationSID) + N'" />'
from
	dbo.fRegistrant#LatestRegistration$SID(-1, null) rlMx
join
	dbo.Registration															 reg on rlMx.RegistrationSID = reg.RegistrationSID
left outer join
	dbo.RegistrantRenewal															 rr on reg.RegistrationSID	 = rr.RegistrationSID
left outer join
  dbo.Reinstatement                               r on reg.RegistrationSID = r.RegistrationSID
left outer join
  dbo.RegistrationChange                          rc on reg.RegistrationSID = rc.RegistrationSID
where
	sf.fIsActive(reg.EffectiveTime, reg.ExpiryTime) = 1 and rr.RegistrantRenewalSID is null and r.ReinstatementSID is null and rc.RegistrationChangeSID is null and reg.PracticeRegisterSectionSID <> @practiceRegisterSectionSID; -- avoid registrations already in target section
--order by
--	newid(); -- randomization increases test length considerably

if @@rowcount = 0 or @reasonSID is null or @practiceRegisterSectionSID is null
begin
	print ('reg label = ' + isnull(@practiceRegisterLabel, 'null'));
	print ('reason name = ' + isnull(@reasonName, 'null'));
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	set @registrationSIDList += char(13) + char(10) + N'</Registrations>';
	set @registrations = cast(@registrationSIDList as xml);

	if 1 = 0 -- change clause to output additional debug information for test
	begin

		select
			x.RegistrationSID
		 ,reg.RegistrantNo
		 ,reg.RegistrationSID
		 ,reg.RegistrationNo
		 ,reg.PracticeRegisterLabel
		 ,reg.PracticeRegisterSectionLabel
		 ,reg.EffectiveTime
		 ,reg.ExpiryTime
		from
		(
			select
				Registration.reg.value('@SID', 'int') RegistrationSID
			from
				@registrations.nodes('//Registration') Registration(reg)
		)												 x
		left outer join
			dbo.vRegistration reg on x.RegistrationSID = reg.RegistrationSID;

		select
			@practiceRegisterLabel TargetRegister
		 ,@reasonName						 ReasonName
		 ,@registrations		 Registrants; -- output parameters for sproc call to console

	end;

	exec dbo.pRegistrationChange#SetNew -- execute procedure in preview mode
		@Registrations = @registrations
	 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID
	 ,@ReasonSID = @reasonSID
	 ,@IsPreviewOnly = 1;

	begin transaction;

	exec dbo.pRegistrationChange#SetNew -- execute procedure to write changes
		@Registrations = @registrations
	 ,@PracticeRegisterSectionSID = @practiceRegisterSectionSID
	 ,@ReasonSID = @reasonSID
	 ,@IsPreviewOnly = 0
	 ,@ReturnDataSet = 1;

	rollback; -- avoid saving the changes
end;
  
		]]>
		</SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="ExecutionTime" Value="00:00:20"/>
    </Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pRegistrationChange#SetNew'
 ,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo							 int					 = 0																			-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						 nvarchar(4000)																					-- message text for business rule errors
	 ,@ON										 bit					 = cast(1 as bit)													-- constant for bit comparisons = 1
	 ,@OFF									 bit					 = cast(0 as bit)													-- constant for bit comparison = 0
	 ,@blankParm						 varchar(50)																						-- name of required parameter left blank
	 ,@updateUser						 nvarchar(75)	 = sf.fApplicationUserSession#UserName()	-- user running the procedure
	 ,@isActivePractice			 bit																										-- indicates whether target register is active practice
	 ,@toPracticeRegisterSID int																										-- key of practice register new registration is on
	 ,@toRegistrationLabel	 nvarchar(75)																						-- label describing the registration and section where change registrations will apply
	 ,@isSA									 bit					 = sf.fIsSysAdmin()												-- tracks if current user is a system administrator (allows un-mapped changes to active)
	 ,@i										 int																										-- loop iteration counter
	 ,@maxrow								 int																										-- loop limit
	 ,@registrationSID			 int																										-- values for next registration change to process:
	 ,@registrantNo					 varchar(50)
	 ,@requirementCount			 int
	 ,@comments							 nvarchar(250)
	 ,@registrationChangeSID int																										-- key of new registration record inserted
	 ,@termLabel						 nvarchar(35)																						-- buffer for configurable label text
	 ,@isCancelled					 bit					 = cast(0 as bit)													-- checks for cancellation request on async job calls  
	 ,@currentProcessLabel	 nvarchar(35)																						-- label for stage of work
	 ,@resultMessage				 nvarchar(4000)																					-- summary of job result
	 ,@personSID						 int																										-- key of person changing registrations
	 ,@formStatusSCD				 varchar(25)																						-- form status of the existing reg change
	 ,@invoiceSID						 int																										-- invoice of the existing reg change
	 ,@noteContent					 nvarchar(max)																					-- buffer for note content to add if deleting withdrawn form
	 ,@cancelReasonSID			 int																										-- key of cancellation reason for invoice (if previous invoice exists)
	 ,@created							 nvarchar(25);																					-- date and time when previous reg change was created (for message)
	 
	declare @work table
	(
		ID											int						not null identity(1, 1)
	 ,RegistrationSID					int						not null
	 ,RegistrantSID						int						null
	 ,RegistrantNo						varchar(50)		null
	 ,RegistrantLabel					nvarchar(75)	null
	 ,RegistrationChangeLabel nvarchar(125) null
	 ,RequirementCount				int						null
	 ,Comments								nvarchar(250) null
	 ,RegistrationChangeSID		int						null
	 ,FormStatusLabel					nvarchar(35)	null
	 ,NewRegistrationSID			int						null
	 ,EffectiveTime						datetime			null
	 ,ExpiryTime							datetime			null
	);

	set @RecordsProcessed = 0;
	set @ErrorCount = 0;

	begin try

		if isnull(@JobRunSID, 0) > 0
		begin

			set @DebugLevel = 0;

			if @StopOnError is null
			begin
				set @StopOnError = @OFF; -- stopping on errors defaults off if running in background
			end;

		end;
		else
		begin
			set @StopOnError = @ON; -- if running in foreground always stop on errors
		end;

		if isnull(@JobRunSID, 0) > 0 -- if call is async, update the job run record
		begin

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'JOBSTATUS.INPROCESS'
			 ,@TermLabel = @termLabel output
			 ,@DefaultLabel = N'In Process'
			 ,@UsageNotes = N'Indicates the job is currently running, or appears to be running because no completion time or failure was reported.';

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@CurrentProcessLabel = @termLabel;

			set @IsPreviewOnly = @OFF;
			set @ReturnDataSet = @OFF;

		end;

-- SQL Prompt formatting off
		if @PracticeRegisterSectionSID is null	set @blankParm = '@PracticeRegisterSectionSID'
		if @Registrations is null					set @blankParm = '@Registrations'
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

		if @IsPreviewOnly = @ON set @ReturnDataSet = @ON; -- return DS is required if previewing results

		-- validate target register section

		select
			@toPracticeRegisterSID = prs.PracticeRegisterSID
		 ,@toRegistrationLabel	 =
				pr.PracticeRegisterLabel + (case
																			when replace(prs.PracticeRegisterSectionLabel, ' ', '') = replace(pr.PracticeRegisterLabel, ' ', '') + 'Default' then ''
																			else ' (' + prs.PracticeRegisterSectionLabel + ')'
																		end
																	 )	-- the register Section if not "[PracticeRegName] Default"
		 ,@isActivePractice			 = pr.IsActivePractice
		from
			dbo.PracticeRegisterSection prs
		join
			dbo.PracticeRegister				pr on prs.PracticeRegisterSID = pr.PracticeRegisterSID
		where
			prs.PracticeRegisterSectionSID = @PracticeRegisterSectionSID;

		if @toPracticeRegisterSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'dbo.PracticeRegisterSection'
			 ,@Arg2 = @PracticeRegisterSectionSID;

			raiserror(@errorText, 18, 1);
		end;

		-- parse XML key values into table for processing

		insert
			@work (RegistrationSID)
		select
			Registration.reg.value('@SID', 'int') RegistrationSID
		from
			@Registrations.nodes('//Registration') Registration(reg);

		set @maxrow = @@rowcount;

		if @maxrow = 0
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'EmptyParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was empty.'
			 ,@Arg1 = '@Registrations';

			raiserror(@errorText, 18, 1);
		end;

		if @maxrow > 1
		begin
			set @ReservedRegistrantNo = null;
		end
		
		if @DebugLevel > 1
		begin

			select
				w.ID
			 ,w.RegistrationSID
			 ,reg.RegistrantSID
			 ,r.RegistrantNo
			from
				@work						 w
			left outer join
				dbo.Registration reg on w.RegistrationSID = reg.RegistrationSID
			left outer join
				dbo.Registrant	 r on reg.RegistrantSID		= r.RegistrantSID;

		end;

		-- check for errors for the set of registrations passed

		update
			w
		set
			w.RegistrantSID = reg.RegistrantSID
		 ,w.RegistrantNo = r.RegistrantNo
		 ,w.RegistrantLabel = r.RegistrantLabel
		 ,w.RegistrationChangeLabel = cast(dbo.fRegistration#Label(reg.RegistrationSID) + ' -> ' + @toRegistrationLabel as nvarchar(125))
		 ,w.RequirementCount = prc.RequirementCount
		 ,w.Comments = case
										 when rc.RegistrationSID is not null then 'ERROR: Another change is pending for this registration'
										 when reg.PracticeRegisterSectionSID = @PracticeRegisterSectionSID then 'ERROR: Registration is already in effect (duplicate)'
										 when w.RegistrationSID <> rlMX.RegistrationSID then
											 'ERROR: Not the latest active (non-future dated) registration for the member. Change not allowed.'
										 when @isActivePractice = @ON and prsFR.PracticeRegisterSID <> @toPracticeRegisterSID and prc.PracticeRegisterSID is null and @isSA = @ON then
											 'Warning: No mapping defined for this change'
										 when @isActivePractice = @ON and prsFR.PracticeRegisterSID <> @toPracticeRegisterSID and prc.PracticeRegisterSID is null then
											 'ERROR: No mapping defined for this change (change not allowed)'
										 when @isActivePractice = @ON and prsFR.PracticeRegisterSID <> @toPracticeRegisterSID and isnull(prc.RequirementCount, 0) = 0 then
											 'Warning: No requirements are defined for this mapped change (automatic approval applies)'
										 else isnull(dbo.fRegistration#Pending(reg.RegistrationSID, 'REGCHANGE'), 'OK')
									 end
		from
			@work																																			w
		join
			dbo.Registration																													reg on w.RegistrationSID = reg.RegistrationSID -- inner join = reg key must be valid
		join
			dbo.PracticeRegisterSection																								prsFR on reg.PracticeRegisterSectionSID = prsFR.PracticeRegisterSectionSID
		join
			dbo.vRegistrant																														r on reg.RegistrantSID = r.RegistrantSID
		left outer join
		(
			select
				rc.RegistrationSID
			from
				@work																																					w
			join
				dbo.RegistrationChange																												rc on w.RegistrationSID = rc.RegistrationSID
			cross apply dbo.fRegistrationChange#CurrentStatus(rc.RegistrationChangeSID, -1) rccs
			where
				rccs.IsFinal = @OFF -- check if any other registration changes are in progress for the registration
			group by
				rc.RegistrationSID
		)																																						rc on reg.RegistrationSID = rc.RegistrationSID
		left outer join
		(
			select
				prc.PracticeRegisterSID
			 ,prc.PracticeRegisterSectionSID
			 ,count(prcr.PracticeRegisterChangeRequirementSID) RequirementCount -- count requirements for the mapped change (if any)
			from
				dbo.PracticeRegisterChange						prc
			left outer join -- outer join to enable row to return if mapping exists but no active requirements
			(
				select
					 x.PracticeRegisterChangeRequirementSID
					,x.PracticeRegisterChangeSID
				from
					dbo.PracticeRegisterChangeRequirement x
				join
					dbo.RegistrationRequirement rr on x.RegistrationRequirementSID = rr.RegistrationRequirementSID
				join
					dbo.RegistrationRequirementType rrt on rr.RegistrationRequirementTypeSID = rrt.RegistrationRequirementTypeSID
				where
					rrt.RegistrationRequirementTypeCode not like 'S!%.DEC'
				and
					x.IsActive = @ON
			) prcr on prc.PracticeRegisterChangeSID = prcr.PracticeRegisterChangeSID
			where
				prc.IsActive = @ON
			group by
				prc.PracticeRegisterSID
			 ,prc.PracticeRegisterSectionSID
		)																																						prc on prsFR.PracticeRegisterSID = prc.PracticeRegisterSID and prc.PracticeRegisterSectionSID = @PracticeRegisterSectionSID
		outer apply dbo.fRegistrant#LatestRegistration$SID(reg.RegistrantSID, null) rlMX;

		select @ErrorCount = count (1) from @work w where left(w.Comments, 5) = 'ERROR';

		-- if errors exist and preview is off and not running
		-- async then force dataset back on to show errors 

		if (
				 @ErrorCount > 0 and @IsPreviewOnly = @OFF and isnull(@JobRunSID, 0) = 0
			 )
		begin
			set @ReturnDataSet = @ON;
		end;

		-- process the changes if not in preview mode
		-- and no errors were detected

		if @IsPreviewOnly = @OFF
		begin

			set @i = 0;

			while @i < @maxrow
			begin

				set @i += 1;
				set @registrationChangeSID = null;

				select
					@registrationSID				= w.RegistrationSID
				 ,@registrantNo						= w.RegistrantNo
				 ,@requirementCount				= w.RequirementCount
				 ,@comments								= w.Comments
				 ,@registrationChangeSID	= rc.RegistrationChangeSID
				 ,@personSID							= r.PersonSID
				 ,@formStatusSCD					= cs.FormStatusSCD
				 ,@invoiceSID							= cs.InvoiceSID
				 ,@created								= format(sf.fDTOffsetToClientDateTime(rc.CreateTime), 'dd-MMM-yyyy hh:mm tt')
				from
					@work w
				join
					dbo.Registrant r on w.RegistrantSID = r.RegistrantSID
				left outer join
					dbo.RegistrationChange rc on w.RegistrationSID = rc.RegistrationSID

				outer apply
					dbo.fRegistrationChange#CurrentStatus(rc.RegistrationChangeSID, rc.RegistrationYear) cs
				where
					w.ID = @i;

				-- check if a cancellation request occurred
				-- where job is running in async mode

				if isnull(@JobRunSID, 0) > 0 and (@i = 1 or @i % 100 = 0) -- update on first record then every 100
				begin

					if exists
					(
						select
							1
						from
							sf.JobRun jr
						where
							jr.CancellationRequestTime is not null and jr.JobRunSID = @JobRunSID
					)
					begin
						set @isCancelled = @ON;
					end;

					set @currentProcessLabel = cast('Processing Reg#' + ltrim(@registrantNo) as nvarchar(35));

					exec sf.pJobRun#Update
						@JobRunSID = @JobRunSID
					 ,@CurrentProcessLabel = @currentProcessLabel
					 ,@RecordsProcessed = @RecordsProcessed
					 ,@TotalRecords = @maxrow
					 ,@TotalErrors = @ErrorCount
					 ,@IsCancelled = @isCancelled
					 ,@UpdateUser = @updateUser;

				end;

				begin try

					begin transaction;

					-- if an error was detected in validation, report it to the 
					-- job if running async, otherwise to the caller (UI)

					if left(@comments, 5) = 'ERROR'
					begin

						if isnull(@JobRunSID, 0) > 0 -- if running async log this error
						begin

							insert
								sf.JobRunError (JobRunSID, MessageText, DataSource, RecordKey)
							select
								@JobRunSID
							 ,N'* ' + substring(@comments, 6, 1000)
							 ,'RegistrationChange'
							 ,isnull(ltrim(@registrationSID), 'NULL');

							set @ErrorCount += 1;
							set @RecordsProcessed += 1;

						end;
						else
						begin
							raiserror(@comments, 16, 1); -- throw error text from comments to caller 
						end;

					end;
					else
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
									 ,@Arg1 = @registrationChangeSID
									 ,@Arg2 = 'renew';

									raiserror(@errorText, 16, 1);
								end;

							end;
							else
							begin

								select
									@cancelReasonSID = rsn.ReasonSID
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
										i.InvoiceSID = @invoiceSID and i.CancelledTime is null	-- cancel the invoice to avoid confusion with new renewal
								)
								begin

									exec dbo.pInvoice#Update
										@InvoiceSID = @invoiceSID
									 ,@ReasonSID = @cancelReasonSID
									 ,@IsCancelled = @ON;

								end;

							end;

							-- before deleting the withdrawn form, record
							-- a note about its details

							set @noteContent = N'A withdrawn registration change for this member was removed to allow a new registration change form to replace it. The previous registration change was created %1. ';

							set @noteContent = replace(@noteContent, '%1', @created);

							if @invoiceSID is not null
							begin
								set @noteContent += N' The registration change was invoiced, reference #%1, but no payments were applied against it. The invoice was cancelled. ';
								set @noteContent = replace(@noteContent, '%1', ltrim(@invoiceSID));
							end;
							else
							begin
								set @noteContent += N' The registration change was not invoiced.';

							end;

							exec dbo.pPersonNote#Set
								@PersonSID = @personSID
							 ,@NoteTitle = 'Withdrawn Registration Change Form Replaced'
							 ,@NoteContent = @noteContent;

							delete
								dbo.RegistrationChangeRequirement
							where
								RegistrationChangeSID = @registrationChangeSID

							exec dbo.pRegistrationChange#Delete
								@RegistrationChangeSID = @registrationChangeSID;

						end;

						exec dbo.pRegistrationChange#Insert -- insert the registration change
							@RegistrationChangeSID = @registrationChangeSID output
						 ,@RegistrationSID = @registrationSID
						 ,@PracticeRegisterSectionSID = @PracticeRegisterSectionSID
						 ,@ReservedRegistrantNo = @ReservedRegistrantNo
						 ,@RegistrationEffective = @RegistrationEffective
						 ,@CreateUser = @updateUser;

						if isnull(@requirementCount, 0) = 0 -- where no requirements exist auto-approve the change
						begin

							exec dbo.pRegistrationChange#Approve
								 @RegistrationChangeSID = @registrationChangeSID
								,@ReasonSID = @ReasonSID;

						end;

						-- where a dataset is  returned update the working table
						-- with key values from the new records to show on the UI

						if @ReturnDataSet = @ON
						begin

							update
								w
							set
								w.RegistrationChangeSID = @registrationChangeSID
							 ,w.FormStatusLabel = cs.FormStatusLabel			-- status of the new form
							 ,w.NewRegistrationSID = reg.RegistrationSID	-- values from RL only exist where auto-approve applied
							 ,w.EffectiveTime = reg.EffectiveTime
							 ,w.ExpiryTime = reg.ExpiryTime
							from
								@work																																				w
							join
								dbo.RegistrationChange																											rc on rc.RegistrationChangeSID = @registrationChangeSID
							cross apply dbo.fRegistrationChange#CurrentStatus(@registrationChangeSID, -1) cs
							left outer join
								dbo.Registration reg on rc.RowGUID = reg.FormGUID
							where
								w.ID = @i;

						end;
					end;

					commit;

					set @RecordsProcessed += 1;

				end try
				begin catch

					set @ErrorCount += 1;
					set @RecordsProcessed += 1;

					if @@trancount > 0 rollback; -- rollback the last transaction to allow the error to be logged

					if isnull(@JobRunSID, 0) = 0 and @DebugLevel > 0
					begin

						print (cast('Processing Reg#' + ltrim(@registrantNo) as nvarchar(35)) + ' | RegistrationSID:  ' + isnull(ltrim(@registrationSID), 'NULL')
									 + ' Register Section Key: ' + isnull(ltrim(@PracticeRegisterSectionSID), 'NULL')
									);

						print (error_message());
					end;

					-- if the procedure is running asynchronously record the
					-- error, else re-throw it to end processing

					if isnull(@JobRunSID, 0) > 0
					begin

						insert
							sf.JobRunError (JobRunSID, MessageText, DataSource, RecordKey)
						select
							@JobRunSID
						 ,N'* ERROR: ' + error_message()
						 ,'RegistrationChange'
						 ,isnull(ltrim(@registrationSID), 'NULL');

					end;

					if @StopOnError = @ON
					begin
						exec @errorNo = sf.pErrorRethrow;
					end;

				end catch;

			end;

		end;

		if @ReturnDataSet = @ON
		begin

			select
				w.ID
			 ,w.RegistrationSID
			 ,w.RegistrantLabel
			 ,w.RegistrationChangeLabel
			 ,case
					when left(w.Comments, 6) = 'ERROR:' then 'ERROR'
					when left(w.Comments, 8) = 'Warning:' then 'WARNING'
					else 'OK'
				end																																ValidationStatus
			 ,ltrim(replace(replace(w.Comments, 'ERROR:', ''), 'Warning:', '')) Comments
			 ,w.RegistrationChangeSID
			 ,w.FormStatusLabel
			 ,w.NewRegistrationSID
			 ,w.EffectiveTime
			 ,w.ExpiryTime
			from
				@work w;

		end;

		if (
				 @ErrorCount > 0 and @IsPreviewOnly = @OFF and isnull(@JobRunSID, 0) = 0
			 )
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'InvalidRegistrationChange'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'%1 registration change(s) targeted is not valid. No changes were processed.'
			 ,@Arg1 = @ErrorCount;

			raiserror(@errorText, 18, 1);

		end;

		if isnull(@JobRunSID, 0) > 0 and @isCancelled = @OFF -- update job result if used
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'JobCompletedSucessfully'
			 ,@MessageText = @resultMessage output
			 ,@DefaultText = N'The %1 job was completed successfully.'
			 ,@Arg1 = 'registration change';

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@TotalRecords = @maxrow
			 ,@TotalErrors = @ErrorCount
			 ,@RecordsProcessed = @RecordsProcessed
			 ,@ResultMessage = @resultMessage;

		end;

	end try
	begin catch

		if isnull(@JobRunSID, 0) > 0
		begin

			if @@trancount > 0 rollback; -- roll back any pending trx so that update can succeed

			exec sf.pTermLabel#Get
				@TermLabelSCD = 'JOB.FAILED'
			 ,@TermLabel = @termLabel output
			 ,@DefaultLabel = N'*** JOB FAILED'
			 ,@UsageNotes = N'A label reporting failure of jobs (normally accompanied by error report text from the database).';

			set @errorText = @termLabel + char(13) + char(10) + error_message();

			exec sf.pJobRun#Update
				@JobRunSID = @JobRunSID
			 ,@ResultMessage = @errorText
			 ,@IsFailed = @ON;

		end;

		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
