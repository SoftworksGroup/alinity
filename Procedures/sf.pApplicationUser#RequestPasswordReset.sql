SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pApplicationUser#RequestPasswordReset
	@UserNameEmailAddress varchar(75)				-- login ID of the existing user
 ,@EmailMessageSID			int = null output -- email message ID for the password reset
as
/*********************************************************************************************************************************
Sproc    : Application User - Request Password Reset
Notice   : Copyright © 2015 Softworks Group Inc.
Summary  : Queue a new password reset confirmation email for the user
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Cory Ng			| Jun	2015		  | Initial version
				 : Cory Ng			| Dec 2015			| Changed references to LinkURI to MessageLinkSID based on modeling updates
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure looks up the user based on the email address to ensure its valid in the system, then creates and queues a new
password reset confirmation email. Validation is performed before the email message is created to ensure the user is active and
has an authentication authority of email.

If the user is using a federated login method they must change their password the external services website. If AD is used they
must change their password on their computer or registrant the network administrator.

Example:
--------
 
<TestHarness>
	<Test Name = "Simple" IsDefault ="true" Description="Create a new password reset email for a random user.">
		<SQLScript>
			<![CDATA[
				declare 
					 @userNameEmailAddress varchar(75)
					,@emailMessageSID int
											
				select
					@UserNameEmailAddress = au.UserName
				from
					sf.vApplicationUser au
				where
					au.AuthenticationAuthoritySCD = 'EMAIL.TS'
				and
					au.IsActive = 1
				order by
					newid()

				exec sf.pApplicationUser#RequestPasswordReset
					 @UserNameEmailAddress	= @userNameEmailAddress
					,@EmailMessageSID				= @emailMessageSID output

				select
					*
				from
					sf.PersonEmailMessage pem
				where
					pem.EmailMessageSID = @emailMessageSID

				delete
					sf.EmailMessage
				where
					EmailMessageSID = @emailMessageSID
						
						
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pApplicationUser#RequestPasswordReset'

------------------------------------------------------------------------------------------------------------------------------- */
begin

	set nocount on;

	declare
		@errorNo												int						= 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText											nvarchar(4000)									-- message text (for business rule errors)
	 ,@ON															bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@personSID											int															-- key of existing person record
	 ,@authenticationAuthoritySCD			varchar(10)											-- authentication authority for the user
	 ,@defaultEmailSenderEmailAddress varchar(150)										-- the email address to send the email with
	 ,@priorityLevel									tinyint													-- values for email message copied from template:
	 ,@subject												nvarchar(120)
	 ,@body														varbinary(max)
	 ,@isApplicationUserRequired			bit
	 ,@linkExpiryHours								int
	 ,@applicationEntitySID						int
	 ,@messageLinkSID									int;

	set @EmailMessageSID = null;

	begin try

		-- call a subroutine to insert an email message for the 
		-- profile identified based on the template values
		-- check parameters

		select top (1)
			@priorityLevel						 = et.PriorityLevel
		 ,@subject									 = et.Subject
		 ,@body											 = et.Body
		 ,@isApplicationUserRequired = et.IsApplicationUserRequired
		 ,@linkExpiryHours					 = et.LinkExpiryHours
		 ,@applicationEntitySID			 = et.ApplicationEntitySID
		from
			sf.EmailTemplate et
		where
			charindex(N'password', et.EmailTemplateLabel) > 0 and charindex(N'reset', et.EmailTemplateLabel) > 0
		order by
			et.EmailTemplateSID;

		if @subject is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ConfigurationNotComplete'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
			 ,@Arg1 = 'default email template for password resets';

			raiserror(@errorText, 17, 1);

		end;

		select
			@defaultEmailSenderEmailAddress = es.SenderEmailAddress
		from
			sf.EmailSender es
		where
			es.IsDefault = @ON;

		if @defaultEmailSenderEmailAddress is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ConfigurationNotComplete'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
			 ,@Arg1 = 'default email sender';

			raiserror(@errorText, 17, 1);

		end;

		select
			@messageLinkSID = el.MessageLinkSID
		from
			sf.vMessageLink el
		where
			el.MessageLinkSCD = 'PASSWORD.RESET';


		if @messageLinkSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'ConfigurationNotComplete'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
			 ,@Arg1 = 'email link';

			raiserror(@errorText, 17, 1);

		end;

		select
			@personSID									= au.PersonSID
		 ,@authenticationAuthoritySCD = au.AuthenticationAuthoritySCD
		from
			sf.vApplicationUser au
		where
			au.UserName = @UserNameEmailAddress and au.IsActive = @ON;

		if @personSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.ApplicationUser'
			 ,@Arg2 = @UserNameEmailAddress;

			raiserror(@errorText, 18, 1);

		end;

		if @authenticationAuthoritySCD <> 'EMAIL.TS'
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'OnlyEmailAuthorityCanBeReset'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The user name entered is using a login method other than email. If an external service (eg: Microsoft, Google) is used to login you must request a password change from that website.';

			raiserror(@errorText, 18, 1);

		end;

		exec sf.pEmailMessage#Insert
			@EmailMessageSID = @EmailMessageSID output
		 ,@SenderEmailAddress = @defaultEmailSenderEmailAddress
		 ,@PriorityLevel = @priorityLevel
		 ,@Subject = @subject
		 ,@Body = @body
		 ,@IsApplicationUserRequired = @isApplicationUserRequired
		 ,@MessageLinkSID = @messageLinkSID
		 ,@LinkExpiryHours = @linkExpiryHours
		 ,@ApplicationEntitySID = @applicationEntitySID
		 ,@RecipientPersonSID = @personSID;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
