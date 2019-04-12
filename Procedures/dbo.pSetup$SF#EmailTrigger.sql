SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#EmailTrigger]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- locale (country) to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.EmailTrigger data
Notice   : Copyright © 2015 Softworks Group Inc.
Summary  : Inserts starting values into sf.EmailTrigger if no records exist in the table
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)		| Month Year	| Change Summary
				 : ------------ | ----------- |-------------------------------------------------------------------------------------------
				 : Cory Ng		  | Jul	2016		| Initial Version
				 : Kris Dawson	| Jan	2018		| Updated to merge, updated triggers using "business hours" schedules to use 24h schedules
				 : Tim Edlund		| Jul 2018		| Modified conditions search for schedule labels to use "like" operator
----------------------------------------------------------------------------------------------------------------------------------

Comments  
--------
This procedure is responsible for creating sample data in the sf.EmailTrigger table. If you modify a pre-existing trigger's insert
statement a migration script will need to be created for this since this table does not use a merge statement.

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table. 

Example:
--------
<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Runs setup and the content of the table is then listed via a SELECT.">
		<SQLScript>
			<![CDATA[
			exec dbo.pSetup$SF#EmailTrigger 
				 @SetupUser = N'setup@softworksgroup.com'
				,@Language  = 'en'
				,@Region		= 'Alinity'
	
			select * from sf.EmailTrigger
		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pSetup$SF#EmailTrigger'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int = 0				-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000) -- message text (for business rule errors)
	 ,@sourceCount int						-- count of rows in the source table
	 ,@targetCount int;						-- count of rows in the target table

	declare @setup table
	(
		ID								int					 identity(1, 1)
	 ,EmailTriggerLabel nvarchar(35) not null
	 ,EmailTemplateSID	int					 not null
	 ,QuerySID					int					 not null
	 ,MinDaysToRepeat		int					 not null
	 ,JobScheduleSID		int					 not null
	);

	begin try

		insert
			@setup
		(
			EmailTriggerLabel
		 ,EmailTemplateSID
		 ,QuerySID
		 ,MinDaysToRepeat
		 ,JobScheduleSID
		)
		values
-- SQL Prompt formatting off
			(
				 'Employer App Verification Ready'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Employer App Verification Ready')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Apps ready for org verification')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every night%after midnight%')
			)
			,(
				 'App Feedback For Applicant'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'App Feedback For Applicant')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Apps reviewed with feedback (Email)')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every 15 minutes%')
			),(
				 'Audit Feedback For Registrant'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Audit Feedback For Registrant')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Audits with feedback (Email)')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every 15 minutes%')
			),(
				 'Submitted Audit Confirmation'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Submitted Audit Confirmation')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Submitted audits (Email)')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every 15 minutes%')
			),(
				 'Audit Withdrawn'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Audit Withdrawal')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Withdrawn audits (Email)')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every 15 minutes%')
			),(
				 'Submitted App Confirmation'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Submitted App Confirmation')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Submitted applications (Email)')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every 15 minutes%')
			),(
				 'Approved App Confirmation'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Approved App Confirmation')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Approved applications (Email)')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every 15 minutes%')
			),(
				 'Registrant Review Overdue'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'App Feedback For Applicant')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Registrant review overdue')
				,14
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every night%after midnight%')
			), (
				 'Employer Verification Overdue'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Employer App Verification Ready')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Employer verification overdue')
				,14
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every night%after midnight%')
			),(
				 'Blocked PU Confirmation'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Blocked PU Confirmation')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Blocked PU (Email)')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every 15 minutes%')
			),(
				 'Approved PU Confirmation'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Approved PU Confirmation')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Approved PU (Email)')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every 15 minutes%')
			),(
				 'Unpaid Approved Renewals'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Renewal Approved - Payment Due')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Unpaid approved renewals (Email)')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every 15 minutes%')
			),(
				 'Paid Approved Renewals'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Renewal Approved')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Paid approved renewals (Email)')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every 15 minutes%')
			),(
				 'Inactive Approved Renewals'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Inactive Renewal Approved')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Inactive approved renewals (Email)')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every 15 minutes%')
			),(
				 'Returned Renewals'
				,(select x.EmailTemplateSID from sf.EmailTemplate x where x.EmailTemplateLabel = 'Renewal Feedback for Registrant')
				,(select x.QuerySID from sf.Query x where x.QueryLabel = 'Renewals returned (Email)')
				,0
				,(select x.JobScheduleSID from sf.JobSchedule x where x.JobScheduleLabel like 'Every 15 minutes%')
			)
-- SQL Prompt formatting on

		merge sf.EmailTrigger target
		using
		(
			select
				x.EmailTriggerLabel
			 ,x.EmailTemplateSID
			 ,x.QuerySID
			 ,x.MinDaysToRepeat
			 ,x.JobScheduleSID
			from
				@setup x
		) source
		on target.EmailTriggerLabel = source.EmailTriggerLabel
		when not matched by target then
			insert
			(
				EmailTriggerLabel
			 ,EmailTemplateSID
			 ,QuerySID
			 ,MinDaysToRepeat
			 ,JobScheduleSID
			 ,IsActive
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.EmailTriggerLabel, source.EmailTemplateSID, source.QuerySID, source.MinDaysToRepeat, source.JobScheduleSID, cast(0 as bit), @SetupUser, @SetupUser
			)
		when matched then update set
												target.EmailTriggerLabel = source.EmailTriggerLabel
											 ,target.QuerySID = source.QuerySID
											 ,target.MinDaysToRepeat = source.MinDaysToRepeat
											 ,target.JobScheduleSID = source.JobScheduleSID
											 ,UpdateUser = @SetupUser
											 ,UpdateTime = sysdatetimeoffset();

		-- check count of @setup table and the target table
		-- target should have exactly as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;

		select @targetCount	 = count(1) from sf .EmailTrigger;

		if isnull(@targetCount, 0) < @sourceCount
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.EmailTrigger'
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
