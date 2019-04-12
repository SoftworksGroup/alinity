SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#EmailTemplate]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.EmailTemplate data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.EmailTemaplte master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Richard K		| Apr	2015			|	Initial Version
				 : Tim Edlund		| Oct 2017			| Update to ensure templates required for defaults are inserted.
				 : Kris Dawson	| Jan 2018			| Templates for audit submit and feedback sent
				 : Taylor N			| Feb 2018			| Replaced references to alinity.com and synoptec helpdesks with "support@softworksgroup.com"
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure is responsible for creating sample data in the sf.EmailTemplate table. The data is only inserted if the table contains
no records.  Otherwise, the procedure makes no changes to the database.  The table will contain no records when the product
is first installed.

Keep in mind the pSetup (parent) procedure is run not only for installation, but also after each upgrade. This ensures any new
tables receive starting values. Tables like this one may be setup with whatever data makes sense to the end user and, therefore,
must not be modified during upgrades. This is achieved by avoiding execution if any records are found in the table. 


<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="If no records exist in the emailtemplate table we'll reseed the ident and run the setup sproc">
		<SQLScript>
		<![CDATA[
			delete from sf.EmailTemplate
			dbcc checkident( 'sf.EmailTemplate', reseed, 1000000) with NO_INFOMSGS
		
			exec dbo.pSetup$SF#EmailTemplate
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'AB'

			select * from sf.EmailTemplate

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#EmailTemplate'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo							int						= 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText						nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON										bit						= cast(1 as bit)	-- constant for bit = 1
	 ,@OFF									bit						= cast(0 as bit)	-- constant for bit = 0
	 ,@applicationEntitySID int;														-- required for merge field(s) context

	begin try

		select @applicationEntitySID from sf.ApplicationEntity ae where ae.ApplicationEntitySCD = 'sf.vPerson'

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Applicant Invitation'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,LinkExpiryHours
			 ,UsageNotes
			 ,ApplicationEntitySID
			 ,CreateUser
			)
			values
			(
				'Applicant Invitation'
			 ,1
			 ,N'Confirm your Alinity account'
			 ,cast(N'<p>Hi [@FirstName] ,<br /></p><p>Thank you for signing up to Alinity™. We have a couple more things we need to know about you before you can log in. Please click the link below to complete your registration:</p><p><a href="http://[@@UserRegistration]" target="_blank">Complete registration</a></p><p>Alternatively, you can cut and paste the following URL:</p><p>http://[@@UserRegistration]</p><p>If you have any questions about this process, please contact the Help Desk at <a href="mailto:support@softworksgroup.com" target="_blank">support@softworksgroup.com</a></p>' as varbinary(max))
			 ,48
			 ,'This is an invitation email template to send to new users to allow them to verify their email address'
			 ,@applicationEntitySID
			 ,@SetupUser
			);

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Supervisor Invitation'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,LinkExpiryHours
			 ,UsageNotes
			 ,ApplicationEntitySID
			 ,CreateUser
			)
			values
			(
				'Supervisor Invitation'
			 ,1
			 ,N'Confirm your Alinity account'
			 ,cast(N'<p>Hi [@FirstName] ,<br /></p><p>You have been invited to use Alinity™. We have a couple more things we need to know about you before you can log in. Please click the link below to complete your registration:</p><p><a href="http://[@@UserRegistration]" target="_blank">Complete registration</a></p><p>Alternatively, you can cut and paste the following URL:</p><p>http://[@@UserRegistration]</p><p>If you have any questions about this process, please contact the Help Desk at <a href="mailto:support@softworksgroup.com" target="_blank">support@softworksgroup.com</a></p>' as varbinary(max))
			 ,48
			 ,'This is an invitation email template to send to supervisors who have been invited to use Alinity.'
			 ,@applicationEntitySID
			 ,@SetupUser
			);

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Password Reset Confirmation'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Password Reset Confirmation'
			 ,1
			 ,N'Reset your Alinity password'
			 ,cast(N'&lt;p&gt;Hi [@FirstName],&lt;br /&gt;&lt;/p&gt;&lt;p&gt;This is an automated email from Alinity in response to your request to reset your password. If you did not request a password reset, you can ignore this email and your password will remain unchanged.&lt;/p&gt;&lt;p&gt;To reset your password and access your account, click the following link:&lt;/p&gt;&lt;p&gt;&lt;a href="http://[@@PasswordReset]" style="font-family:Verdana, Geneva, sans-serif;font-size:12px;" target="_blank"&gt;Reset my password&lt;/a&gt;&lt;/p&gt;&lt;p&gt;Alternatively, you can copy and paste the following URL:&lt;/p&gt;&lt;p class="p1"&gt;&lt;span class="s1"&gt;&lt;a href="http://[@@PasswordReset]" target="_blank"&gt;http://[@@PasswordReset]&lt;/a&gt;&lt;/span&gt;&lt;/p&gt;&lt;p class="p1"&gt;&lt;/p&gt;&lt;p class="p1"&gt;If you have any questions about this process, please registrant the Help Desk at &lt;a href="mailto:support@softworksgroup.com" target="_blank"&gt;support@softworksgroup.com&lt;/a&gt;.&lt;/p&gt;&lt;p class="p1"&gt;&lt;br /&gt;&lt;/p&gt;&lt;p class="p1"&gt;&lt;span class="s1"&gt;&lt;/span&gt;&lt;/p&gt;&lt;p&gt;&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,@applicationEntitySID
			 ,'This email template is used when user''s request a password reset. The template contains a link back to the application that will allow the user to change their password.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Employer App Verification Ready'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Employer App Verification Ready'
			 ,1
			 ,N'Registrant application verification ready'
			 ,cast(N'&lt;p&gt;Hi&amp;nbsp;[@DisplayName],&lt;/p&gt;&lt;p&gt;One or more have claimed as one of their employers. Before we can accept them as a registrant we require that some details entered on the application be reviewed by your organization. You can log into the portal to view the application at:&lt;/p&gt;&lt;p&gt;&lt;a href="http://[@@ClientAppPortal]" target="_blank"&gt;[@@ClientAppPortal]&lt;/a&gt;&lt;br /&gt;&lt;/p&gt;&lt;p&gt;Thank you for your time.&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.RegistrantApp#Search'
				)
			 ,'This email template is sent to employers when application verification is required for the employer.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'App Feedback For Applicant'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'App Feedback For Applicant'
			 ,1
			 ,N'Application Update'
			 ,cast(N'&lt;p&gt;Hi&amp;nbsp;[@DisplayName],&lt;/p&gt;&lt;p&gt;There is an update for you on our directory, please go to your member profile and review the request. You can log into the portal at:&lt;/p&gt;&lt;p&gt;&lt;a href="http://[@@ClientAppPortal]" target="_blank"&gt;[@@ClientAppPortal]&lt;/a&gt;&lt;br /&gt;&lt;/p&gt;&lt;p&gt;Thank you for your time.&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.RegistrantApp#Search'
				)
			 ,'This email template is sent to applicants who have feedback to review on their application.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Audit Feedback For Registrant'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Audit Feedback For Registrant'
			 ,1
			 ,N'Audit Update'
			 ,cast(N'&lt;p&gt;Hi&amp;nbsp;[@DisplayName],&lt;/p&gt;&lt;p&gt;There is an update for you on our directory, please go to your member profile and review the request. You can log into the portal at:&lt;/p&gt;&lt;p&gt;&lt;a href="http://[@@ClientAppPortal]" target="_blank"&gt;[@@ClientAppPortal]&lt;/a&gt;&lt;br /&gt;&lt;/p&gt;&lt;p&gt;Thank you for your time.&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.RegistrantAudit#Search'
				)
			 ,'This email template is sent to registrants who have feedback to review on their audit.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Submitted App Confirmation'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Submitted App Confirmation'
			 ,1
			 ,N'Application Submitted'
			 ,cast(N'&lt;p&gt;Hi&amp;nbsp;[@DisplayName],&lt;/p&gt;&lt;p&gt;Your application for enrollment on our directory has been received. We will notify you once the review is complete or if additional items are required. Thank you.&lt;br /&gt;&lt;/p&gt;&lt;p&gt;Thank you for your time.&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.RegistrantApp#Search'
				)
			 ,'This email template is sent to applicants who have recently submitted their application.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Submitted Audit Confirmation'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Submitted Audit Confirmation'
			 ,1
			 ,N'Audit Submitted'
			 ,cast(N'&lt;p&gt;Hi&amp;nbsp;[@DisplayName],&lt;/p&gt;&lt;p&gt;Your audit response has been received. We will notify you once the review is complete or if additional items are required. &lt;br /&gt;&lt;/p&gt;&lt;p&gt;Thank you for your time.&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.RegistrantAudit#Search'
				)
			 ,'This email template is sent to registrants who have recently submitted their audit.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Audit Withdrawal'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Audit Withdrawal'
			 ,1
			 ,N'Audit Withdrawn'
			 ,cast(N'&lt;p&gt;Hi&amp;nbsp;[@DisplayName],&lt;/p&gt;&lt;p&gt;Your audit has been withdrawn and no further action is required on your part. &lt;br /&gt;&lt;/p&gt;&lt;p&gt;Thank you for your time.&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.RegistrantAudit#Search'
				)
			 ,'This email template is sent to registrants who have recently submitted their audit.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Approved App Confirmation'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Approved App Confirmation'
			 ,1
			 ,N'Application Submitted'
			 ,cast(N'&lt;p&gt;Hi&amp;nbsp;[@DisplayName],&lt;/p&gt;&lt;p&gt;Your application for enrollment on our directory has been approved. To download the confirmation log into the portal at:&lt;/p&gt;&lt;p&gt;&lt;a href="http://[@@ClientAppPortal]" target="_blank"&gt;[@@ClientAppPortal]&lt;/a&gt;&lt;br /&gt;&lt;/p&gt;&lt;p&gt;Thank you for your time.&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.RegistrantApp#Search'
				)
			 ,'This email template is sent to applicants who have had their application approved.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Renewal Approved - Payment Due'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Renewal Approved - Payment Due'
			 ,1
			 ,N'Renewal Approved - Payment Due'
			 ,cast(N'&lt;p&gt;Hi&amp;nbsp;[@DisplayName],&lt;/p&gt;&lt;p&gt;Your renewal has been approved. You are not licensed until you have paid for your renewal. To make payment log into the portal at:&lt;/p&gt;&lt;p&gt;&lt;a href="http://[@@ClientAppPortal]" target="_blank"&gt;[@@ClientAppPortal]&lt;/a&gt;&lt;br /&gt;&lt;/p&gt;&lt;p&gt;Thank you for your time.&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.Registration#Search'
				)
			 ,'This email template is sent to registrants who have had their renewals approved but have not paid yet.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Renewal Approved'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Renewal Approved'
			 ,1
			 ,N'Renewal Approved'
			 ,cast(N'&lt;p&gt;Hi&amp;nbsp;[@DisplayName],&lt;/p&gt;&lt;p&gt;Your renewal has been approved. To download your practice permit or tax receipt log into the portal at:&lt;/p&gt;&lt;p&gt;&lt;a href="http://[@@ClientAppPortal]" target="_blank"&gt;[@@ClientAppPortal]&lt;/a&gt;&lt;br /&gt;&lt;/p&gt;&lt;p&gt;Thank you for your time.&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.Registration#Search'
				)
			 ,'This email template is sent to registrants who have had their renewals approved.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Inactive Renewal Approved'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Inactive Renewal Approved'
			 ,1
			 ,N'Registration Cancelled'
			 ,cast(N'&lt;p&gt;Hi&amp;nbsp;[@DisplayName],&lt;/p&gt;&lt;p&gt;Your registration has been cancelled.&lt;br /&gt;&lt;/p&gt;&lt;p&gt;Thank you for your time.&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.Registration#Search'
				)
			 ,'This email template is sent to registrants who renewed into the default inactive register.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Blocked PU Confirmation'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Blocked PU Confirmation'
			 ,1
			 ,N'Profile Update Blocked'
			 ,cast(N'&lt;p&gt;Hi&amp;nbsp;[@DisplayName],&lt;/p&gt;&lt;p&gt;Your profile update submission has been received. The changes will be made once the profile update form is reviewed and approved.&lt;br /&gt;&lt;/p&gt;&lt;p&gt;Thank you for your time.&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.ProfileUpdate#Search'
				)
			 ,'The email template is sent to registrants who have recently submitted their profile update and have been blocked for review.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Approved PU Confirmation'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Approved PU Confirmation'
			 ,1
			 ,N'Profile Update Approved'
			 ,cast(N'&lt;p&gt;Hi&amp;nbsp;[@DisplayName],&lt;/p&gt;&lt;p&gt;Your profile update has been approved.&lt;br /&gt;&lt;/p&gt;&lt;p&gt;Thank you for your time.&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.ProfileUpdate#Search'
				)
			 ,'The email template is sent to registrants who have recently had their profile update approved.';

		end;

		if not exists
		(
			select
				1
			from
				sf.EmailTemplate et
			where
				et.EmailTemplateLabel = 'Renewal Feedback for Registrant'
		)
		begin

			insert
				sf.EmailTemplate
			(
				EmailTemplateLabel
			 ,PriorityLevel
			 ,Subject
			 ,Body
			 ,IsApplicationUserRequired
			 ,LinkExpiryHours
			 ,ApplicationEntitySID
			 ,UsageNotes
			)
			select
				'Renewal Feedback for Registrant'
			 ,1
			 ,N'Renewal Update'
			 ,cast(N'&lt;p&gt;&lt;span style="font-family:Arial, Helvetica, sans-serif;font-size:small;"&gt;&lt;/span&gt;&lt;span style="font-family:Arial, Helvetica, sans-serif;font-size:small;"&gt;Hello [@FirstName],&amp;nbsp;&lt;/span&gt;&lt;/p&gt;&lt;p&gt;&lt;span style="font-family:Arial, Helvetica, sans-serif;font-size:small;"&gt;Your renewal has been returned back to you with feedback from the staff.&lt;/span&gt;&lt;/p&gt;&lt;p&gt;&lt;span style="font-family:Arial, Helvetica, sans-serif;font-size:small;"&gt;Please login to the portal below, review the feedback on the form and if necessary, fix any outstanding&amp;nbsp;issues.&lt;/span&gt;&lt;/p&gt;&lt;p&gt;&lt;span style="font-family:Arial, Helvetica, sans-serif;font-size:small;"&gt;Once your have reviewed/correct your renewal form, please re-submit.&lt;/span&gt;&lt;/p&gt;&lt;p&gt;&lt;/p&gt;&lt;p&gt;&lt;span style="font-family:Arial, Helvetica, sans-serif;font-size:small;"&gt;[@@ClientAppPortal]&lt;/span&gt;&lt;/p&gt;&lt;p&gt;&lt;/p&gt;&lt;p&gt;Thank you.&lt;/p&gt;&lt;p&gt;&lt;span style="font-family:Arial, Helvetica, sans-serif;font-size:small;"&gt;&lt;/span&gt;&lt;span style="font-family:Arial, Helvetica, sans-serif;"&gt;&lt;span style="font-size:small;"&gt;&lt;/span&gt;&lt;/span&gt;&lt;/p&gt;' as varbinary(max))
			 ,@OFF
			 ,48
			 ,(
					select
						ae.ApplicationEntitySID
					from
						sf.ApplicationEntity ae
					where
						ae.ApplicationEntitySCD = 'dbo.Registration'
				)
			 ,'The email template is sent to registrants who have feedback on their renewal.';

		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
