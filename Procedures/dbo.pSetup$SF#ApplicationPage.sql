SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#ApplicationPage]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.ApplicationPage data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Updates sf.ApplicationPage master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Nov 2012			| Initial Version
				 : Tim Edlund		| Jun 2015			| Added "application route" column values 
----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This procedure synchronizes the sf.ApplicationPage table with the settings required by the current version of the application. If
a record is missing it is added. Where the record exists, it is set to current values and records dropped from the product are
deleted from the table. One MERGE statement is used to carryout all operations.

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table.

The @routePrefix is used because dev URLS and prod URLS differ in the domain name. 

ApplicationPages listed below that do not have a driving entity were given a placeholder of sf.ApplicationUser.

Example
-------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures setup executes successfully.">
		<SQLScript>
		<![CDATA[
		
exec dbo.pSetup$SF#ApplicationPage
	@SetupUser = 'system@softworksgroup.com'
	,@Language = 'EN'
	,@Region = null

select * from sf.ApplicationPage ap order by ap.ApplicationPageURI

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#ApplicationPage'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
begin
	set nocount on;

	declare
		@errorNo		 int					 = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)									-- message text (for business rule errors)
	 ,@sourceCount int														-- count of rows in the source table
	 ,@targetCount int														-- count of rows in the target table
	 ,@ON					 bit					 = cast(1 as bit) -- constant for boolean comparisons
	 ,@OFF				 bit					 = cast(0 as bit) -- constant for boolean comparisons
	 ,@routePrefix varchar(40)	 = '[@@SubDomain].alinityapp.com';

	declare @setup table
	(
		ID									 int					identity(1, 1)
	 ,ApplicationPageURI	 varchar(150) not null	-- required! used to lookup pages from program logic (used like an SCD)
	 ,ApplicationRoute		 varchar(150) not null
	 ,ApplicationPageLabel nvarchar(35) not null
	 ,IsSearchPage				 bit					not null
	 ,ApplicationEntitySID int					not null
	);

	begin try

		-- only include name of portal in label (to make it unique) when the
		-- portal is not "Admin"

-- SQL Prompt formatting off
		insert
			@setup
		(
			 ApplicationPageLabel
			,ApplicationPageURI
			,ApplicationRoute
			,IsSearchPage
			,ApplicationEntitySID
		)
		values
			 (N'Configuration management'					,'ConfigParamList'											      ,@routePrefix + '/admin/configparam'															      ,@ON    ,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.ConfigParam'))
			,(N'Member portal'										,'ClientApplicationPortal'										,@routePrefix + '/client/'																							,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrantApp'))
			,(N'User confirmation'								,'UserConfirmation'														,@routePrefix + '/account/userconfirmation'															,@OFF   ,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.PersonEmailMessage'))
			,(N'Password reset confirmation'			,'PasswordReset'															,@routePrefix + '/account/resetpassword'																,@OFF   ,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.PersonEmailMessage'))
			,(N'Edit text template'								,'EditTextTemplate'														,@routePrefix + '/admin/texttemplate/edit'															,@OFF   ,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.TextTemplate'))
			,(N'Edit email template'							,'EditEmailTemplate'													,@routePrefix + '/admin/emailtemplate/edit'															,@OFF   ,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.EmailTemplate'))
			,(N'Entity descriptions'							,'EntityDescriptions'													,@routePrefix + '/admin/applicationentity/entitydescriptions'						,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.ApplicationEntity'))
			,(N'Person management'                ,'PersonList'                                 ,@routePrefix + '/admin/person'																					,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.Person'))
			,(N'License management'               ,'LicenseList'                                ,@routePrefix + '/admin/license'																				,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.License'))
			,(N'Registrant management'            ,'RegistrantList'															,@routePrefix + '/admin/registrant'																			,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.Registrant'))
			,(N'Supervisor management'            ,'SupervisorList'                             ,@routePrefix + '/admin/orgcontact'																			,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.OrgContact'))
			,(N'Organization management'					,'OrgList'														        ,@routePrefix + '/admin/org'																						,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.Org'))
			,(N'Organization details'							,'OrgDetails'																	,@routePrefix + '/admin/org/details'																		,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.Org'))
			,(N'Application management'           ,'ApplicationList'                            ,@routePrefix + '/admin/registrantapp'																	,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrantApp'))
			,(N'Business rule details'						,'BusinessRuleDetails'												,@routePrefix + '/admin/applicationentity/details'											,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.ApplicationEntity'))
			,(N'Table management'									,'BusinessRuleList'											    	,@routePrefix + '/admin/applicationentity'															,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.ApplicationEntity'))
			,(N'Contact management'								,'ContactList'																,@routePrefix + '/admin/contact'																				,@OFF   ,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.Contact'))
			,(N'Create audit group'								,'CreateAuditGroup'														,@routePrefix + '/admin/registrantaudit/createauditgroup'								,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.Registrant'))
			,(N'Create email message'							,'CreateEmailMessage'													,@routePrefix + '/admin/emailmessage/createemail'       								,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.EmailMessage'))
      ,(N'Email management'									,'EmailMessageList'														,@routePrefix + '/admin/emailmessage'       														,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.EmailMessage'))
      ,(N'Task management'									,'TaskList'																		,@routePrefix + '/admin/task'       																		,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.Task'))
			,(N'Task details'											,'TaskDetails'																,@routePrefix + '/admin/task/details'       														,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.Task'))
      ,(N'Audit management'									,'RegistrantAuditList'												,@routePrefix + '/admin/registrantaudit'																,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrantAudit'))
			,(N'Group management'									,'GroupList'																	,@routePrefix + '/admin/persongroup'																		,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.PersonGroup'))
			,(N'Group details'										,'PersonGroupDetails'													,@routePrefix + '/admin/persongroup/details'														,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.PersonGroup'))
			,(N'Group member details'							,'PersonGroupMemberDetails'										,@routePrefix + '/admin/persongroupmember/details'											,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.PersonGroupMember'))
      ,(N'Renewal management'								,'RegistrantRenewalList'											,@routePrefix + '/admin/registrantrenewal'															,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrantRenewal'))
			,(N'Error management'									,'UnexpectedErrorList'												,@routePrefix + '/admin/unexpectederror'																,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.UnexpectedError'))
			,(N'PAD subscriber management'				,'PAPSubscription'														,@routePrefix + '/admin/papsubscription'																,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.PAPSubscription'))
      ,(N'Payment management'   						,'PaymentList'     														,@routePrefix + '/admin/payment'        																,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.Payment'))
			,(N'Profile update management'				,'ProfileUpdateList'													,@routePrefix + '/admin/profileupdate'        													,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.ProfileUpdate'))
			,(N'Reinstatement management'   			,'ReinstatementList'      										,@routePrefix + '/admin/reinstatement'        													,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.Reinstatement'))
			,(N'Registration changes'   					,'RegistrationChangeList'											,@routePrefix + '/admin/registrationchange'        											,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrationChange'))
			,(N'Registration management'   				,'RegistrationList'														,@routePrefix + '/admin/registration'        														,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.Registration'))
			,(N'Snapshot management'							,'RegistrationSnapshotList'										,@routePrefix + '/admin/registrationsnapshot'        										,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrationSnapshot'))
			,(N'Snapshot profiles'								,'RegistrationProfileList'										,@routePrefix + '/admin/registrationprofile'        										,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrationProfile'))
			,(N'Learning management'							,'RegistrantLearningPlanList'									,@routePrefix + '/admin/registrantlearningplan'        									,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrantLearningPlan'))
			,(N'Invoice management'								,'InvoiceList'																,@routePrefix + '/admin/invoice'							        									,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.Invoice'))
			,(N'Complaint management'							,'ComplaintList'															,@routePrefix + '/admin/complaint'							        								,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.Complaint'))
			,(N'Learning details'									,'RegistrantLearningPlanDetails'							,@routePrefix + '/admin/registrantlearningplan/reviewlearningplan'			,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrantLearningPlan'))
			,(N'Registration change details'			,'RegistrationChangeDetails'									,@routePrefix + '/admin/registrationchange/reviewregchange'							,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrationChange'))
			,(N'Profile update details'						,'ProfileUpdateDetails'												,@routePrefix + '/admin/profileupdate/reviewprofileupdate'							,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.ProfileUpdate'))
			,(N'Renewal details'									,'RegistrantRenewalDetails'										,@routePrefix + '/admin/registrantrenewal/reviewrenewal'								,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrantRenewal'))
			,(N'Reinstatement details'						,'ReinstatementDetails'												,@routePrefix + '/admin/reinstatement/review'														,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.Reinstatement'))
			,(N'Application details'							,'RegistrantAppDetails'												,@routePrefix + '/admin/registrantapp/reviewapplication'								,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrantApp'))
			,(N'Audit details'										,'RegistrantAuditDetails'											,@routePrefix + '/admin/registrantaudit/reviewaudit'										,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.RegistrantAudit'))
			,(N'Person details'										,'PersonDetails'															,@routePrefix + '/admin/person/details'																	,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'sf.Person'))
			,(N'Complaint details'								,'ComplaintDetails'														,@routePrefix + '/admin/complaint/details'															,@OFF		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'dbo.Complaint'))
			,(N'Registrant profiles'							,'RegistrantProfileList'											,@routePrefix + '/admin/registrantprofile'															,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'stg.RegistrantProfile'))
			,(N'Registrant exam profiles'					,'RegistrantExamProfileList'									,@routePrefix + '/admin/registrantexamprofile'													,@ON		,(select ApplicationEntitySID from sf.ApplicationEntity where ApplicationEntitySCD = 'stg.RegistrantExamProfile'))
-- SQL Prompt formatting on
		--
		merge sf.ApplicationPage target
		using
		(
			select
				x.ApplicationPageLabel
			 ,x.ApplicationPageURI
			 ,x.ApplicationRoute
			 ,x.IsSearchPage
			 ,x.ApplicationEntitySID
			from
				@setup x
		) source
		on target.ApplicationPageURI = source.ApplicationPageURI
		when not matched by target then
			insert
			(
				ApplicationPageLabel
			 ,ApplicationPageURI
			 ,ApplicationRoute
			 ,IsSearchPage
			 ,ApplicationEntitySID
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.ApplicationPageLabel, source.ApplicationPageURI, source.ApplicationRoute, source.IsSearchPage, source.ApplicationEntitySID, @SetupUser
			 ,@SetupUser
			)
		when matched then update set
												ApplicationPageLabel = source.ApplicationPageLabel
											 ,ApplicationRoute = source.ApplicationRoute
											 ,IsSearchPage = source.IsSearchPage
											 ,ApplicationEntitySID = source.ApplicationEntitySID
											 ,UpdateUser = @SetupUser
											 ,UpdateTime = sysdatetimeoffset()
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup
		select @sourceCount	 = count(1) from @setup ;

		select @targetCount	 = count(1) from sf .ApplicationPage;

		if isnull(@targetCount, 0) <> @sourceCount
		begin
			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.ApplicationPage'
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
