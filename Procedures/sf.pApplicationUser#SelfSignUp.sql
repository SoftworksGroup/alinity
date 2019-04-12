SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#SelfSignUp]
	 @UserNameEmailAddress					varchar(75)															-- login ID (must be valid email address!) of new/existing user
	,@LinkURI												varchar(150)														-- web page location (without GUID) link should navigate to
	,@PersonSID											int								= null output					-- key of existing person (or otherwise pass name values)
	,@FirstName											nvarchar(30)			= null								-- first name to store on the login profile
	,@LastName											nvarchar(35)			= null								-- last name to store on the login profile
	,@AppPassword										varbinary(8000)		= null								-- password to put on account 
	,@HashSalt											uniqueidentifier	= null								-- seed value used to create password hash
	,@GenderSID											int								= null								-- reference to gender (defaults to unknown if not provided)
	,@AutoQueueMessage							bit								= 1										-- stops the procedure from queuing the email message
	,@EmailMessageSID								int								= null output
as
/*********************************************************************************************************************************
Sproc    : Application User - Self Sign-Up
Notice   : Copyright © 2015 Softworks Group Inc.
Summary  : Creates a person record and inactive user account with an email message to the new user
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Christian T	| June 2015		  | Initial version.
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure  creates a user account, person information and email messages. It is used on a users self sign up or by an 
administrative sign up in the application. The password is entered when the invite is created in this scenario. This allows an 
administrator to simulate a self sign up or for the user to perform a self sign up. The former is an unlikely scenario but 
necessary in some organizations that have an older clientèle and are forced to help users get signed up. It is also a very handy 
development tool.

The main difference between AdminSignUp and SelfSign up is that SelfSignUp creates email messages AdminSignUp simply creates the 
Person, PersonEmailAddress and ApplicationUser records.


Example:
--------
 
<TestHarness>
	<Test Name = "CreateAndDelete" IsDefault ="true" Description="Creates a user and email then deletes that user and email">
		<SQLScript>
			<![CDATA[
				declare 
					@PersonSID int
					,@EmailMessageSID int
					,@AppPassword varbinary(8000)
					,@GenderSID int
					,@HashSalt											uniqueidentifier
					,@LinkURI												varchar(250)		
					,@ON														bit	=	cast(1 as bit)				
					,@OFF														bit	= cast(0 as bit)				
											
					select 
						top (1) @GenderSID = g.GenderSID 
					from 
						sf.Gender g
					order by newid()

					set @AppPassword = cast('test' as varbinary(8000))

					set @HashSalt = newid()

					set @LinkURI = '[@@SubDomain].permitsy.com/person/confirminvite'
			
					exec sf.pApplicationUser#SelfSignUp 
					@UserNameEmailAddress		= 'testytest@home.com'		
					,@PersonSID							= @PersonSID output							
					,@FirstName							= 'Testy'							
					,@LastName							= 'Testerson'							
					,@AppPassword						= @AppPassword						
					,@HashSalt							= @HashSalt							
					,@GenderSID							= @GenderSID	
					,@LinkURI								= @LinkURI
					,@AutoQueueMessage			= @ON
					,@EmailMessageSID				= @EmailMessageSID output

					delete from sf.EmailMessage where EmailMessageSID = @EmailMessageSID
					delete from sf.ApplicationUser where PersonSID = @PersonSID
					delete from sf.PersonEmailAddress where PersonSID = @PersonSID
					delete from sf.Person where PersonSID = @PersonSID
			
						
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pApplicationUser#SelfSignUp'

------------------------------------------------------------------------------------------------------------------------------- */
 
set nocount on
 
begin
 
	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@blankParm                         varchar(100)											-- tracks blank values in required parameters
		,@ON																bit	=	cast(1 as bit)							-- used on bit comparisons to avoid multiple casts
		,@OFF																bit	= cast(0 as bit)							-- used on bit comparisons to avoid multiple casts
		,@authenticationSystemID						nvarchar(50)											-- buffer to store password hash value in new user record
		,@authenticationAuthoritySID				int																-- key of email authentication authority (required in config)
		,@applicationUserSID								int																-- key of new/existing application user record
		,@personEmailAddressSID							int																-- key of new/existing email address record
		,@personSIDOnEmail									int																-- key of person owning email address (if any)
		,@defaultEmailSenderEmailAddress		varchar(150)											-- the email address to send the email with
		,@messageSubscriptionSID						int																-- values for email message copied from template:
		,@priorityLevel											tinyint				
		,@subject														nvarchar(120)	
		,@body															varbinary(max)
		,@isApplicationUserRequired					bit						
		,@linkExpiryHours										int						
		,@applicationEntitySID							int						
		,@pendingPersonEmailMessageSID			int		
		,@xmlRecipientList									xml
		,@newPersonSID											int

	set @EmailMessageSID	= null			
	set @PersonSID				= @PersonSID
	set @newPersonSID			= @PersonSID																			

	begin try

		-- call a subroutine to insert an email message for the 
		-- profile identified based on the template values
		-- check parameters

		select top (1)
			 @priorityLevel								= et.PriorityLevel
			,@subject											= et.Subject
			,@body												= et.Body
			,@isApplicationUserRequired		= et.IsApplicationUserRequired
			,@linkExpiryHours							= et.LinkExpiryHours
			,@applicationEntitySID				= et.ApplicationEntitySID
		from
			sf.EmailTemplate et
		where
			charindex(N'new', et.EmailTemplateLabel) > 0
		and
			charindex(N'user', et.EmailTemplateLabel) + charindex(N'applicant', et.EmailTemplateLabel) > 0															-- users are called applicants in Alinity

		if @messageSubscriptionSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'ConfigurationNotComplete'
				,@MessageText = @errorText output
				,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
				,@Arg1        = 'default email template for new users'

			raiserror(@errorText, 17, 1)
			
		end
		
		select
			@defaultEmailSenderEmailAddress = es.SenderEmailAddress
		from
			sf.EmailSender es
		where
			es.IsDefault = @ON

		
		if @defaultEmailSenderEmailAddress is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'ConfigurationNotComplete'
				,@MessageText = @errorText output
				,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
				,@Arg1        = 'default email sender'

			raiserror(@errorText, 17, 1)
			
		end

		-- error checking is complete; handle all inserts as single transaction, transaction is created inside the procedure
		-- the procedure is also called from the application

		exec sf.pApplicationUser#AdminSignUp 
			@UserNameEmailAddress		= @UserNameEmailAddress		
			,@PersonSID							= @PersonSID output							
			,@FirstName							= @FirstName							
			,@LastName							= @LastName							
			,@AppPassword						= @AppPassword						
			,@HashSalt							= @HashSalt							
			,@GenderSID							= @GenderSID							

		-- need second instance of person key for call signature
		-- PersonSID is output and should not be changed

		set @newPersonSID = @PersonSID													

		begin transaction
		
		if @AutoQueueMessage = @OFF																						-- in order to allow a preview of the email before it is queued
		begin
			set @xmlRecipientList = cast('<People><Person PersonSID="' + cast(@PersonSID as varchar(max)) + '"/></People>' as xml)
			set @newPersonSID = null
		end

		exec sf.pEmailMessage#Insert
			 @EmailMessageSID							= @EmailMessageSID	output
			,@SenderEmailAddress					= @defaultEmailSenderEmailAddress
			,@PriorityLevel								= @priorityLevel
			,@Subject											= @subject
			,@Body												= @body
			,@IsApplicationUserRequired		= @isApplicationUserRequired
			,@LinkExpiryHours							= @linkExpiryHours
			,@LinkURI											= @LinkURI
			,@ApplicationEntitySID				= @applicationEntitySID		
			,@RecipientPersonSID					= @newPersonSID						
			,@RecipientList								= @xmlRecipientList										

		commit

	end try
 
	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow
	end catch
 
	return(@errorNo)
 
end
GO
