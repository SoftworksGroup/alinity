SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#ApplicationPageReport]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.ApplicationPageReport data
Notice   : Copyright © 2012 Softworks Group Inc
Summary  : Updates sf.ApplicationPageReport master table with values for built-in system reports
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Oct	2013			| Initial Version
				 : Christian T	| April 2014		| Added test harness
         : Russ Poirier | Feb 2017      | Added links on the registration and person pages for the three new reports
				 : Robin Payne	| Sep 2017			| Added links on the Renewal page for the new Renewal Status Summary report
				 : Gunjan P     | Feb 2018      | Added Audit status summary, Completed by Week and Form Completion Time
				 : Russ Poirier	| Mar 2019			| Added link to Registration Changes report
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------

This procedure inserts records that define the application pages on which built-in system reports should appear.  Report
definitions ("RDL" content) are loaded by the application dynamically so that new reports can be added to the application
without requiring compiling or a new deployment.  This table is also used to store the pages on which custom report definitions
should appear, however, custom reports are not addressed by setup. Custom reports must be inserted by the configurator
working on the deployment either manually, or through scripts.  Any page locations for custom reports that exist in the table at
the time this procedure is run are left unchanged.

Deletion of existing rows for built-in reports was completed by the pSetup$SF#ApplicationReport procedure which ran previously
to this one.

Note that the setup procedure is dependent on the names of reports - as assigned by pSetup$SF#ApplicationReport, and the URI's
assigned to application pages in pSetup$SF#ApplicationPage.



<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[

			delete from sf.ApplicationPageReport
			dbcc checkident( 'sf.ApplicationPageReport', reseed, 1000000) with NO_INFOMSGS

			exec dbo.pSetup$SF#ApplicationPageReport
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.ApplicationPageReport

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#ApplicationPageReport'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table
		,@ON																bit = cast(1 as bit)							-- constant for boolean comparisons
		,@OFF																bit = cast(0 as bit)							-- constant for boolean comparisons
		,@unAssigned												nvarchar(4000)										-- tracks unassigned report names

	begin try

		-- stage the data to be inserted into a temporary table

		declare
			@setup											table
			(
				 ID												int						not null identity(1,1)
				,ApplicationPageSID				int						not null
				,ApplicationReportSID			int						not null
			)

		-- insert page report assignments into the setup table in a single statement

		insert
			@setup
		(
			 ApplicationPageSID
			,ApplicationReportSID
		)																																			-- sub-selects are dependent on page URI's and report names!
    values
				((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'BusinessRuleDetails')				,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Data Dictionary'))
       ,((select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI	= 'EditTextTemplate')						,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Text Merge Definition'))
			 ,((select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI	= 'EditEmailTemplate')					,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Email Merge Definition'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'EntityDescriptions')					,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Data Dictionary'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PAPSubscription')						,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'PAP Refunds for Inactive Practice'))
       ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PersonList')									,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Security Role Membership'))
       ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PersonList')									,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Application User Roles'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PersonList')									,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Unresolved Password Resets'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PersonList')									,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Login/Email Reconciliation'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PersonList')									,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Registrations by Age'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PersonList')									,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Registrations by Gender'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PersonList')									,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Members by Urban/Rural'))
       ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'RegistrantAuditList')				,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Registrant Audit Summary'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'RegistrantAuditList')				,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Completed by Week'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'RegistrantAuditList')				,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Form Completion Time'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'RegistrationList')						,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Renewals by Register'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'RegistrationList')						,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Renewal Form Completion Time'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'RegistrationList')						,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Renewals Completed by Week'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'RegistrationList')						,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Completion Time by Age'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'RegistrationList')						,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Application Status Summary'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'RegistrationList')						,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Reinstatement Status Summary'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'RegistrationList')						,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Registration Change Status Summary'))
       ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'RegistrationList')						,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Registrant Renewal Status Summary'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'RegistrationList')						,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Registration Changes'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PaymentList')								,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Journal Entry Summary'))
       ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PaymentList')								,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Deposit Summary'))
       ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PaymentList')								,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Deposit Details'))
       ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PaymentList')								,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Revenue Summary'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PaymentList')								,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Journal Entry Detail'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PaymentList')								,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Payment Date Reconciliation'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PaymentList')								,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Unapplied Payments'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'PaymentList')								,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Outstanding Invoices'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'UnexpectedErrorList')				,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Error Details'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'UnexpectedErrorList')				,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Error Rate'))
			 ,((select ApplicationPageSID	from sf.ApplicationPage	where ApplicationPageURI	= 'UnexpectedErrorList')				,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Error Summary'))
			 ,((select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI  = 'GroupList')									,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Group Summary'))
			 ,((select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI  = 'GroupList')									,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Group Members'))
			 ,((select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI  = 'RegistrantLearningPlanList')	,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Learning Plan Status Summary'))
		   ,((select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI  = 'ProfileUpdateList')					,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Profile Update Status Summary'))
			 ,((select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI  = 'BusinessRuleList')					  ,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Data Source Summary'))
			 ,((select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI  = 'OrgList')										,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Organization Summary'))
			 ,((select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI  = 'OrgList')										,(select ApplicationReportSID from sf.ApplicationReport where ApplicationReportName = 'Organization Contacts'))
	insert
			sf.ApplicationPageReport
		(
			 ApplicationPageSID
			,ApplicationReportSID
			,CreateUser
			,UpdateUser
		)
		select
			 s.ApplicationPageSID
			,s.ApplicationReportSID
			,@SetupUser
			,@SetupUser
		from
			@setup		s
		order by
			s.ID

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from  @setup
		select @targetCount = count(1) from  sf.ApplicationPageReport

		if isnull(@targetCount,0) < @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupCountTooLow'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Insert of some setup records failed. Source table count is %1 but target table (%2) count is only %3. Check "JOIN" conditions.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'sf.ApplicationPageReport'
				,@Arg3          = @targetCount

			raiserror(@errorText, 18, 1)
		end

		-- ensure all built-in reports are exposed on at least 1 page!

		set @unAssigned =
			(
			select
				ar.ApplicationReportName
			from
				sf.ApplicationReport			ar
			left outer join
				sf.ApplicationPageReport	apr	on ar.ApplicationReportSID = apr.ApplicationReportSID
			where
				ar.IsCustom = @OFF
			and
				apr.ApplicationPageReportSID is null
		for xml path('')																											-- a tag-less xml document is created - no variable copying
		)

		if len(@unAssigned) > 1
		begin

			set @unAssigned = stuff(@unAssigned,1,1, '')												-- to remove leading comma

			exec sf.pMessage#Get
				 @MessageSCD    = 'ReportsNotAssignedToPages'
				,@MessageText   = @errorText output
				,@DefaultText   = N'The following reports are not assigned to any application page: %1'
				,@Arg1          = @unAssigned

			raiserror(@errorText, 18, 1)

		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
