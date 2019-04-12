SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#ApplicationGrant]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as

/*********************************************************************************************************************************
Sproc    : Setup sf.ApplicationGrant data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Updates dbo.ApplicationGrant master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History	 : Author							| Month Year	| Change Summary
				 : ------------------ + ----------- + ------------------------------------------------------------------------------------
 				 : Tim Edlund         | Apr 2014		|	Initial version

Comments
--------
This procedure synchronizes the sf.ApplicationGrant table with the settings required by the current version of the application. 
If a record is missing it is added. Where the record exists, it is set to current values. ApplicationGrants no longer used are
deleted from the table. One MERGE statement is used to carryout all operations.

This procedure has one edge case bug: if a record is removed from this procedure and that record exists in a child record in 
sf.Notification the merge statement will fail on the foreign key constraint. 

Example:
--------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set 
	up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			if not exists
			(
				select 
					1 
				from 
					sf.ApplicationUserGrant
			)
			begin
				delete from sf.ApplicationGrant
				dbcc checkident( 'sf.ApplicationGrant', reseed, 1000000) with NO_INFOMSGS
			end

			exec dbo.pSetup$SF#ApplicationGrant
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.ApplicationGrant

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#ApplicationGrant'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int					 = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON					 bit					 = cast(1 as bit) -- constant for bit comparisons = 1
	 ,@OFF				 bit					 = cast(0 as bit) -- constant for bit comparison = 0
	 ,@sourceCount int														-- count of rows in the source table
	 ,@targetCount int;														-- count of rows in the target table

	declare @setup table
	(
		ID									 int					 identity(1, 1)
	 ,ApplicationGrantSCD	 varchar(30)	 not null
	 ,ApplicationGrantName nvarchar(150) not null
	 ,UsageNotes					 nvarchar(max) not null
	 ,IsDefault						 bit					 not null
	);

	begin try

		insert
			@setup (ApplicationGrantSCD, ApplicationGrantName, UsageNotes, IsDefault)
		values
-- SQL Prompt formatting off
			 ('ADMIN.BASE'						,N'Administration (General)'		,N'This grant provides access to the Administrator module is used by internal staff, and which may be used by some external consultants or volunteers. Additional grants are required for some administrative functions (see description of all grants).', @OFF)
			,('ADMIN.SYSADMIN'				,N'System Administrator'				,N'This grant provides access to ALL options in the system including setting up other administrative users.', @OFF)
			,('ADMIN.EMAIL'						,N'Email Manager'								,N'This grant provides access to sending email on behalf of the organization and managing and archiving email message history.', @OFF)      
			,('ADMIN.EXPORT'					,N'Data Export Administrator'		,N'This grant allows administrators to export data from screens they have access to. Note that reports may also provide an export option which are not controlled through this grant.', @OFF)			
			,('ADMIN.ACCOUNTING'			,N'Accounting Administrator'		,N'This grant allows administrators to update the GL Accounts, cancel payments and make certain types of adjusting entries.', @OFF)
			,('ADMIN.SETTINGS'				,N'Settings Administrator'			,N'This grant allows administrators to update settings that affect the overall configuration. Support from the help desk is recommended for the advanced category of these settings.', @OFF)			
			,('ADMIN.UTILITIES'				,N'Utilities Administrator'			,N'This grant allows administrators access to technical utilities available in the software including monitoring of background jobs, application of optional business rules,  error logs, archiving and other features for investigating and resolving issues.', @OFF)			
			,('ADMIN.RENEWAL'					,N'Renewal Administrator'				,N'This grant provides access to review and approve renewals as well as provide feedback to registrants on their renewal form submissions. Renewals can be accessed by all administrations from the Person screen but this grant provides access to the Renewal Management Dashboard. This grant is normally reserved for internal staff.', @OFF)
			,('ADMIN.REINSTATEMENT'		,N'Reinstatement Administrator'	,N'This grant provides access to review and approve reinstatements as well as provide feedback to registrants on their reinstatement (reinstatement) form submissions. Reinstatements can be accessed by all administrations from the Person screen but this grant provides access to the Reinstatement Management Dashboard. This grant is normally reserved for internal staff.', @OFF)
			,('ADMIN.APPLICATION'			,N'Application Administrator'		,N'This grant provides access to assign applications to reviewers and to approve or fail applications as well as provide feedback on application submissions.  All applications can be accessed by Application Administrators. This grant is generally reserved for internal staff.', @OFF)			
			,('ADMIN.COMPETENCE'			,N'Competence Administrator'		,N'This grant provides access to review and approve Learning Plans, provide feedback to registrants and access to requirement settings for learning plans.  Learning Plans can be accessed by all administrations from the Person screen but this grant provides access to the Learning Plan Management Dashboard. This grant is normally reserved for internal staff.', @OFF)
			,('ADMIN.AUDIT'						,N'Audit Administrator'					,N'This grant provides access to assign audits to reviewers and to approve or fail audits as well as provide feedback on audit submissions.  All audits can be accessed by Audit Administrators. This grant is generally reserved for internal staff.', @OFF)
			,('ADMIN.TASK'						,N'Task Management'							,N'This grant provides access to the task management features, which includes creating a task linked to form types (eg: renewal, profile update, etc.), managing your task and unassigned tasks in your queue.', @OFF)
			,('ADMIN.COMPLAINTS'			,N'Complaint Management'				,N'This grant provides access to the complaint management features, which includes creating new complaints and administering and closing existing complaints', @OFF)
			,('EXTERNAL.BASE'					,N'Member Portal (General)'			,N'This grant provides access to login for members, applicants, committee members, and other non-staff users requiring access to Alinity features. This grant only provides access to login and to update the user profile but no other features.', @OFF)
			,('EXTERNAL.REGISTRANT'		,N'Member/Applicant'						,N'This grant provides access to self-service features available to registrants and applicants: Applications, Renewals, Profile Updates, etc. The grant only provides access to the person''s own records.', @OFF)
			,('EXTERNAL.EMPLOYER'			,N'Employer/Supervisor'					,N'This grant provides access to employer and supervisor functions configured in the system. If the individual is setup to confirm employment or credentials (e.g. on Application or Renewal forms), they only see the records of individuals to which they have been specifically assigned. The role also grants access to Register details that may not available to the public.', @OFF)
			,('EXTERNAL.APPLICATION'	,N'Application Reviewer'				,N'This grant provides access to review application submissions (e.g. Application Committee members). Individuals receiving this grant can review, make comments and recommend decisions about applications but cannot approve or reject them. This grant only provides access to applications which have been specifically assigned to this reviewer.', @OFF)
			,('EXTERNAL.AUDIT'				,N'Audit Reviewer'							,N'This grant provides access to review audit submissions (e.g. Audit Committee members). Individuals receiving this grant can review, make comments and recommend decisions about audits but cannot approve or reject them. This grant only provides access to audits which have been specifically assigned to this reviewer.', @OFF)
			,('EXTERNAL.VERIFICATION'	,N'Verification Assistant'			,N'This grant provides access to early renewal and other form types to verify them in production prior to making them available to all registrants.', @OFF)
-- SQL Prompt formatting on
		merge sf.ApplicationGrant target
		using
		(
			select
				x.ApplicationGrantSCD
			 ,x.ApplicationGrantName
			 ,x.UsageNotes
			 ,x.IsDefault
			 ,@SetupUser CreateUser
			 ,@SetupUser UpdateUser
			from
				@setup x
		) source
		on target.ApplicationGrantSCD = source.ApplicationGrantSCD
		when not matched by target then
			insert
			(
				ApplicationGrantSCD
			 ,ApplicationGrantName
			 ,UsageNotes
			 ,IsDefault
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.ApplicationGrantSCD
			 ,source.ApplicationGrantName -- this will overwrite client changes on upgrades but is intentional to ensure any change in meaning is explained
			 ,source.UsageNotes						-- also overwrite of client changes
			 ,source.IsDefault, @SetupUser, @SetupUser
			)
		when matched then update set
												IsDefault = source.IsDefault
											 ,ApplicationGrantName = source.ApplicationGrantName
											 ,UsageNotes = source.UsageNotes
											 ,UpdateUser = @SetupUser
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount	 = count(1) from @setup ;
		select @targetCount	 = count(1) from sf .ApplicationGrant;

		if isnull(@targetCount, 0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.ApplicationGrant'
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
