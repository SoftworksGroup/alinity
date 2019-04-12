SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.pSetup$SF#Job
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.Job data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.Job master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Jul	2013			| Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------

This procedure adds jobs provided with the product.  Jobs cannot be added by end users so the content of the table is fixed. A
UI is provided to allow the job label to be updated but the call syntax and job code (JobSCD) are not modifiable by end users or
configurators. A MERGE statement is used to synchronize the target table with the version defined in the procedure. 

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
	
			exec dbo.pSetup$SF#Job
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.Job

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#Job'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0										-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)												-- message text (for business rule errors)
	 ,@sourceCount int																	-- count of rows in the source table
	 ,@targetCount int																	-- count of rows in the target table
	 ,@ON					 bit					 = cast(1 as bit)				-- constant for boolean comparisons
	 ,@OFF				 bit					 = cast(0 as bit)				-- constant for boolean comparisons
	 ,@CRLF				 nchar(2)			 = char(13) + char(10); -- constant for formatting job syntax script

	begin try

		declare @setup table -- setup data for staging rows to be inserted
		(
			ID								 int					 not null identity(1, 1)
		 ,JobSCD						 varchar(132)	 not null
		 ,JobLabel					 nvarchar(35)	 not null
		 ,JobDescription		 nvarchar(max) not null
		 ,CallSyntaxTemplate nvarchar(max) not null
		 ,IsParallelEnabled	 bit					 not null
		 ,JobScheduleSID		 int					 null
		);

		-- insert job to find records recently updated; this job can be added generically
		-- for any table that has an associated #Search procedure and a application page ending
		-- with Management (all search pages end with management as a naming convention)

		insert
			@setup
		(
			JobSCD
		 ,JobLabel
		 ,JobDescription
		 ,CallSyntaxTemplate
		 ,IsParallelEnabled
		 ,JobScheduleSID
		)
		values
		(
			'sf.pEntitySetVerify', N'Business rule verification', N'Checks data in the system to ensure compliance with currently-enabled business rules.'
		 ,N'exec sf.pEntitySetVerify' + @CRLF + '   @JobRunSID            = {JobRunSID}' + @CRLF + '  ,@VerifyMode           = ''{p1}''' + @CRLF
			+ '  ,@ApplicationEntitySID = {p2}', @OFF, null
		)
		,
		(
			 'sf.pJobHistory#Purge'
			,N'Job history purge'
			,N'Removes job history that is older than the retention period specified for the system in configuration parameters (default is 3 months).  Running this procedure helps to ensure the job system remains responsive and easy to administer.  The history of job runs and schedule events is purged.'
			,N'exec sf.pJobHistory#Purge'
				+ @CRLF + '   @JobRunSID            = {JobRunSID}      , @JobSID         = {p1}'
			,@OFF
			,(select min(js.JobScheduleSID) from sf.JobSchedule js where js.JobScheduleLabel like 'Sunday night before%')
		)
		,
		(
			 'sf.pTaskTrigger#Execute'
			,N'Automated task creation'
			,N'Checks the set of task triggers defined in the system for creation of new tasks. Note that this process should be scheduled to run frequently - typically every 15 minutes. Each task trigger is also assigned a schedule which this procedure checks to see if the trigger is due to be run.'
			,N'exec sf.pTaskTrigger#Execute'
				+ @CRLF + '   @JobRunSID            = {JobRunSID}'
			,@ON
			,(select min(js.JobScheduleSID) from sf.JobSchedule js where js.JobScheduleLabel like 'Every 15%')
		)
		,
		(
			 'sf.pTextTrigger#Execute'
			,N'Automated text message creation'
			,N'Checks the set of text message triggers defined in the system for creation of new text messages. Note that this process should be scheduled to run frequently - typically every 15 minutes. Each text message trigger is also assigned a schedule which this procedure checks to see if the trigger is due to be run.'
			,N'exec sf.pTextTrigger#Execute'
				+ @CRLF + '   @JobRunSID            = {JobRunSID}'
			,@ON
			,null -- text triggers are not yet supported so schedule is disabled
			--,(select min(js.JobScheduleSID) from sf.JobSchedule js where js.JobScheduleLabel like 'Every 15%')
		)
		,
		(
			 'sf.pEmailTrigger#Execute'
			,N'Automated email creation'
			,N'Checks the set of email triggers defined in the system for creation of new emails. Note that this process should be scheduled to run frequently - typically every 15 minutes. Each email trigger is also assigned a schedule which this procedure checks to see if the trigger is due to be run.'
			,N'exec sf.pEmailTrigger#Execute'
				+ @CRLF + '   @JobRunSID            = {JobRunSID}'
			,@ON
			,(select min(js.JobScheduleSID) from sf.JobSchedule js where js.JobScheduleLabel like 'Every 15%')
		)
		,
		(
			 'sf.pEmailMessage#Queue'
			,N'Queue and process emails'
			,N'Used by the system to process and queue emails for sending.  This job is normally initiated by the system when an email is sent from the UI.'
			,N'exec sf.pEmailMessage#Queue @JobRunSID = {JobRunSID} ,@EmailMessageSID = {p1}, @QueuedTime = {p2}'
			,@ON
			,null
		)
		,
		(
			 'sf.pEmailMessage#Purge'
			,N'Purge Recipient Email Documents'
			,N'This process accepts a list of archived email messages for document-purging.  The recipient messages have their Email Documents deleted but the recipient messages themselves are retained. This process is normally invoked to free-up disk space.'
			,N'exec sf.pEmailMessage#Purge @JobRunSID = {JobRunSID} ,@EmailMessages = ''{p1}'', @UpdateUser = ''{p2}'''
			,@OFF
			,null
		)
		,
		(
			 'sf.pTimeZoneOffset#Adjust'
			,N'Adjust Time-Zone Offset for DST'
			,N'This process adjusts the time-zone offset for entry and exit from Daylight Savings Time. An update is only performed where required (once each March and November).  If your "DST Status" configuration parameter is set to "N/A" then no adjustments are ever processed. See also "Daylight Savings" in "Settings->Other Configuration".'
			,N'exec sf.pTimeZoneOffset#Adjust @JobRunSID = {JobRunSID}'
			,@OFF
			,(select min(js.JobScheduleSID) from sf.JobSchedule js where js.JobScheduleLabel like 'Sunday%2%am%')
		)
		,
		(
			 'dbo.pGLTransaction#Repost'
			,N'Repost GL Transactions'
			,N'This process rewrites General Ledger transactions from the date entered up to the current date. Missing entries are generated and where adjustments have been made to posting dates, the new date is applied and multiple lines to the same account are consolidated. Once the procedure is run you must reconcile reports with your General Ledger system from the start date entered.'
			,N'exec dbo.pGLTransaction#Repost @JobRunSID = {JobRunSID} ,@StartDate = {p1}'
			,@OFF
			,null
		)
		,
		(
			 'dbo.pPayment#ReapplyBatch'
			,N'Re-apply Payments'
			,N'This procedure is called to clean-up payment records where the amount paid has gone out of sync with the total amount of the payment. The procedure only adjusts payments where the paid and applied amounts do not agree. Reposting of associated GL entries occurs automatically.'
			,N'exec dbo.pPayment#ReApplyBatch @JobRunSID = {JobRunSID}'
			,@OFF
			,null
		)
		,
		(
			 'dbo.pRegistrationChange#SetNew'
			,N'Change Registrations'
			,N'This process allows changes in registration to be processed as a batch action which may apply to thousands if members. A common example is to use the process to set non-renewing members onto an Inactive register after the renewal period closes.'
			,N'exec dbo.pRegistrationChange#SetNew @JobRunSID = {JobRunSID} ,@RegistrationLicenses = {p1}, @PracticeRegisterSectionSID = {p2}, @ReasonSID = {p3}'
			,@OFF
			,null
		)
		,
		(
			 'dbo.pSyncDataMap#Process'
			,N'Sync Data With Another System'
			,N'This process synchronizes data with another database.  Most often the other database will be another version of Alinity which is being referenced or kept up to date during the transition to the new version, but it may be an external database system as well. Configuration of synchronization is best carried out by the Help Desk team.'
			,N'exec dbo.pSyncDataMap#Process @JobRunSID = {JobRunSID}'
			,@OFF
			,(select min(js.JobScheduleSID) from sf.JobSchedule js where charindex(N'Every 60', js.JobScheduleLabel) > 0)
		)
		,
		(
			 'dbo.pPAPBatch#Process'
			,N'Process PAP Transactions'
			,N'This process creates payments for confirmed PAP transactions. This process is run after the bank has reported the status of the batch run and any rejected payments have been identified.'
			,N'exec dbo.pPAPBatch#Process @JobRunSID = {JobRunSID}, @PAPBatchSID = {p1}'
			,@OFF
			,null
		)
		,
		(
			 'dbo.pPAPTransaction#Apply'
			,N'PAP Transactions Apply'
			,N'This process checks for pre-authorized payments which are unapplied, and looks for renewal invoices with outstanding balances against which to apply them. This procedure applies only to the situation where a member has renewed prior to the last PAP transaction is received.  If all PAP payments are in place prior to renewal, the system automatically applies the payments when the renewal is approved.'
			,N'exec pPAPTransaction#Apply @JobRunSID = {JobRunSID}'
			,@OFF
			,null
		)
		,(
			 'dbo.pInvoice#SetRenewalLateFees'
			,N'Add Late Fees To Unpaid Renewals'
			,N'This adds a late fee line item to renewal invoices created prior to the time the late fees came into effect, and which are unpaid after late-fee kick-in.  This process should be scheduled to run nightly at midnight. The procedure performs no action prior to the late fee activation date and will not impact an invoice where the late fee has already been added.'
			,N'exec dbo.pInvoice#SetRenewalLateFees @JobRunSID = {JobRunSID}'
			,@OFF
			,(select min(js.JobScheduleSID) from sf.JobSchedule js where js.JobScheduleLabel like '%Every night%at midnight%')
		)
		,
		(
			 'dbo.pRegistrationSnapshot#ResetModified'
			,N'Snapshot Reset Modified Status'
			,N'This process resets the modified status of profiles in the snapshot.  This causes no records to appear modified until they are edited.  This process should only be run after the export file for the snapshot has been finalized and provided to the receiver. Resetting the modified status allows the next export to included changed records only.'
			,N'exec dbo.pRegistrationSnapshot#ResetModified @JobRunSID = {JobRunSID}, @RegistrationSnapshotSID = {p1}'
			,@ON
			,null
		)
		,
		(
			 'dbo.pRegistrationSnapshot#CIHICreate'
			,N'CIHI Snapshot Creation'
			,N'This process creates a snapshot of registration information matching requirements of the Canadian Institute for Health Informatics (CIHI). This process is generally run 6 months after the start of the registration year. Exports are then provided to CIHI based on snapshot which can be edited, and re-exported to resolve errors in the submission.'
			,N'exec dbo.pRegistrationSnapshot#CIHICreate @JobRunSID = {JobRunSID}, @RegistrationSnapshotSID = {p1}'
			,@OFF
			,(select min(js.JobScheduleSID) from sf.JobSchedule js where js.JobScheduleLabel like '%Every night%before midnight%')
		)
		,
		(
			 'dbo.pRegistrationSnapshot#CIHIUpdate'
			,N'CIHI Snapshot Code Update'
			,N'This process updates the code values on the profiles in an existing snapshot after changes have been made in the master tables. CIHI requires specific coding values for employment status, province and country identifiers, etc. These are recorded in various master tables and applied on the profile records during snapshot creation and updates.'
			,N'exec dbo.pRegistrationSnapshot#CIHIUpdate @JobRunSID = {JobRunSID}, @RegistrationSnapshotSID = {p1}'
			,@ON
			,null
		)
		,
		(
			 'dbo.pRegistrationSnapshot#CIHIValidate'
			,N'CIHI Snapshot Validation'
			,N'This process checks the profiles in an existing snapshot for conformance to the requirements of the Canadian Institute for Health Informatics (CIHI). This process is generally called from the user interface.'
			,N'exec dbo.pRegistrationSnapshot#CIHIValidate @JobRunSID = {JobRunSID}, @RegistrationSnapshotSID = {p1}'
			,@ON
			,null
		)
		,
		(
			 'stg.pRegistrantProfile#Process'
			,N'Staged registrant record processing'
			,N'Validates and applies staged Registrant records to the main database.  This procedure is used to apply records imported from spreadsheets or from custom conversion programs into Alinity''s staging area.'
			,N'exec stg.pRegistrantProfile#Process @JobRunSID = {JobRunSID}, @Action = ''{p1}'''
			,@ON
			,null
		)
		,
		(
			 'stg.pRegistrantExamProfile#Process'
			,N'Staged exam record processing'
			,N'Validates and applies staged Registrant Exam records to the main database.  This procedure is used to apply records imported from spreadsheets or from custom conversion programs into Alinity''s staging area.'
			,N'exec stg.pRegistrantExamProfile#Process @JobRunSID = {JobRunSID}, @Action = ''{p1}'''
			,@ON
			,null
		)
		merge
      sf.Job target
    using
    (
      select
				 x.JobSCD
        ,x.JobLabel
				,x.JobDescription
				,x.CallSyntaxTemplate
				,x.IsParallelEnabled
				,x.JobScheduleSID
				,@SetupUser CreateUser
				,@SetupUser	UpdateUser			       
			from 
				@setup x
    ) source
    on 
      target.JobSCD = source.JobSCD
  	when not matched by target then
	    insert 
      (
				 JobSCD
        ,JobLabel
				,JobDescription
				,CallSyntaxTemplate
				,IsParallelEnabled
				,JobScheduleSID
				,CreateUser
				,UpdateUser
      ) 
      values
	    (
				 source.JobSCD
        ,source.JobLabel
				,source.JobDescription
				,source.CallSyntaxTemplate
				,source.IsParallelEnabled
				,source.JobScheduleSID
        ,source.CreateUser
				,source.UpdateUser
      )
    when matched then
     update 
        set																																-- don't overwrite existing schedule assignments even if null
				JobLabel						= source.JobLabel
				,JobDescription			= source.JobDescription
				,CallSyntaxTemplate = source.CallSyntaxTemplate
				,IsParallelEnabled	= source.IsParallelEnabled
				,JobScheduleSID			= source.JobScheduleSID
				,UpdateUser         = @SetupUser
    when not matched by source then
      delete
			;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from @setup;
		select @targetCount = count(1) from sf.Job;

		if isnull(@targetCount, 0) < @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupCountTooLow'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Insert of some setup records failed. Source table count is %1 but target table (%2) count is only %3. Check "JOIN" conditions.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.Job'
			 ,@Arg3 = @targetCount;

			raiserror(@errorText, 18, 1);
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
