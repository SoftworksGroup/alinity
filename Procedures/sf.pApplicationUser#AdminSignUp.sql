SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#AdminSignUp]
	 @UserNameEmailAddress					varchar(75)															-- login ID (must be valid email address!) of new/existing user
	,@PersonSID											int								= null output					-- key of existing person (or otherwise pass name values)
	,@FirstName											nvarchar(30)			= null								-- first name to store on the login profile
	,@LastName											nvarchar(35)			= null								-- last name to store on the login profile
	,@AppPassword										varbinary(8000)		= null								-- password to put on account 
	,@HashSalt											uniqueidentifier	= null								-- seed value used to create password hash
	,@GenderSID											int								= null								-- reference to gender (defaults to unknown if not provided)
as
/*********************************************************************************************************************************
Sproc    : Application User - Admin Sign-Up
Notice   : Copyright © 2015 Softworks Group Inc.
Summary  : Creates a person record and inactive user account 
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Christian T	| June 2015		  | Initial version.
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
This procedure only creates a user account and person information. It facilitates the creation of a user by an administrator
without having to create the password on bulk invite. An email can be generated to the user and when the user clicks confirm 
they are prompted for their password. Which then calls this procedure then immediately calls the confirm procedure.
It is called from the application and from s.pApplicationUser#SelfSignUp.


Example:
--------
 
<TestHarness>
	<Test Name = "CreateAndDelete" IsDefault ="true" Description="Creates a user and then deletes that user">
		<SQLScript>
			<![CDATA[
			declare 
				@PersonSID int
				,@AppPassword varbinary(8000)
				,@GenderSID int
				,@HashSalt											uniqueidentifier

				select 
					top (1) @GenderSID = g.GenderSID 
				from 
					sf.Gender g
				order by newid()

				set @AppPassword = cast('test' as varbinary(8000))

				set @HashSalt = newid()
			
				exec sf.pApplicationUser#AdminSignUp 
				@UserNameEmailAddress		= 'testytest@home.com'		
				,@PersonSID							= @PersonSID output							
				,@FirstName							= 'Testy'							
				,@LastName							= 'Testerson'							
				,@AppPassword						= @AppPassword						
				,@HashSalt							= @HashSalt							
				,@GenderSID							= @GenderSID	


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
	@ObjectName = 'sf.pApplicationUser#AdminSignUp'

------------------------------------------------------------------------------------------------------------------------------- */
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
		
		
	set @PersonSID = @PersonSID

	begin try

		-- check parameters

		if @UserNameEmailAddress is null set @blankParm = '@UserNameEmailAddress'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'BlankParameter'
				,@MessageText = @errorText output
				,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1        = @blankParm
 
			raiserror(@errorText, 18, 1)

		end

		if @PersonSID is not null																							-- if person key is passed, ensure it is valid
		begin

			if not exists( select 1	from sf.Person p where p.PersonSID = @PersonSID)
			begin
			
				exec sf.pMessage#Get
					 @MessageSCD  = 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'person'
					,@Arg2        = @PersonSID
				
				raiserror(@errorText, 18, 1)

			end

			select																															-- check if a user for this person SID also exists
				@applicationUserSID = au.ApplicationUserSID 
			from 
				sf.ApplicationUser au 
			where 
				au.PersonSID = @PersonSID

			-- if a password was not provided and there is no existing user 
			-- record, raise error

			if @applicationUserSID is null and @AppPassword is null
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'BlankParameter' 
					,@MessageText = @errorText output
					,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
					,@Arg1        = 'AppPassword'
 
				raiserror(@errorText, 18, 1)

			end

			-- look for the email address on an existing record
			-- if found, ensure the owner is the PersonSID passed

			select 
				 @personEmailAddressSID = pea.PersonEmailAddressSID 
				,@personSIDOnEmail			= pea.PersonSID
			from 
				sf.PersonEmailAddress pea 
			where 
				pea.EmailAddress = @UserNameEmailAddress

			if @personEmailAddressSID is not null and (@personSIDOnEmail <> @PersonSID)
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'EmailNotOwned'
					,@MessageText = @errorText output
					,@DefaultText = N'The email address provided "%1" is not owned by the person referenced (keys: %2, %3)'
					,@Arg1        = @UserNameEmailAddress
					,@Arg2				= @PersonSID
					,@Arg3				= @personSIDOnEmail
 
				raiserror(@errorText, 18, 1)

			end

		end	
		else
		begin

			-- if the email address already exists, the person key must be provided

			if exists(select 1 from sf.PersonEmailAddress pea where pea.EmailAddress = @UserNameEmailAddress)
			begin

					exec sf.pMessage#Get
						 @MessageSCD  = 'BlankParameter'
						,@MessageText = @errorText output
						,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
						,@Arg1        = 'PersonSID'
 
					raiserror(@errorText, 18, 1)

			end

			-- if no person key passed (normal scenario), then ensure
			-- values required to create profile and user are provided

			if @HashSalt		is null set @blankParm = '@HashSalt'
			if @AppPassword	is null set @blankParm = '@AppPassword'
			if @FirstName		is null	set @blankParm = '@FirstName'
			if @LastName		is null	set @blankParm = '@LastName'

			if @blankParm is not null
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'BlankParameter'
					,@MessageText = @errorText output
					,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
					,@Arg1        = @blankParm
 
				raiserror(@errorText, 18, 1)

			end

			-- finally check that required configuration values have been set

			if @GenderSID is null	select @GenderSID = g.GenderSID from sf.Gender g where g.GenderSCD = 'U'

			if @GenderSID is null
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'ConfigurationNotComplete'
					,@MessageText = @errorText output
					,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
					,@Arg1        = 'Unknown Gender'

				raiserror(@errorText, 17, 1)
			
			end

		end

		-- check that configuration includes the expected key value
		-- for email (tenant services) authentication authority

		if @applicationUserSID is null
		begin

			select 
				@authenticationAuthoritySID = aa.AuthenticationAuthoritySID 
			from 
				sf.AuthenticationAuthority aa 
			where 
				aa.AuthenticationAuthoritySCD = 'EMAIL.TS'

			if @authenticationAuthoritySID is null
			begin

				exec sf.pMessage#Get
					 @MessageSCD  = 'ConfigurationNotComplete'
					,@MessageText = @errorText output
					,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
					,@Arg1        = 'Authentication Authority: Email.TS'

				raiserror(@errorText, 17, 1)
			
			end

		end

		-- error checking is complete; handle all inserts as single transaction

		begin transaction

		if @PersonSID is null
		begin

			exec sf.pPerson#Insert
				 @PersonSID								= @PersonSID output
				,@FirstName								= @FirstName
				,@LastName								= @LastName
				,@GenderSID								= @GenderSID

		end

		if @personEmailAddressSID is null
		begin

			exec sf.pPersonEmailAddress#Insert
				 @PersonEmailAddressSID		= @personEmailAddressSID	output
				,@PersonSID								= @PersonSID
				,@EmailAddress						= @UserNameEmailAddress
				,@IsPrimary								= @ON

		end

		if @applicationUserSID is null
		begin

			set @authenticationSystemID = cast(@HashSalt as nvarchar(50))

			exec sf.pApplicationUser#Insert
				 @ApplicationUserSID			= @applicationUserSID output
				,@PersonSID								= @PersonSID
				,@UserName								= @UserNameEmailAddress
				,@AuthenticationSystemID	= @authenticationSystemID								-- used to hash the password
				,@GlassBreakPassword			= @AppPassword
				,@IsActive								= @OFF																	-- email is not confirmed so set account inactive

			update
				sf.ApplicationUser
			set
				RowGUID = @HashSalt
			where
				ApplicationUserSID = @applicationUserSID

		end

		commit

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow
	end catch
 
	return(@errorNo)
 
end
GO
