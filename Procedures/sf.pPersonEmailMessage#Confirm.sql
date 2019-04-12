SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pPersonEmailMessage#Confirm]
	 @PersonEmailMessageGUID					uniqueidentifier											-- identifier of the email message being confirmed
	,@Password												varbinary(8000) = null								-- hashed password for the user account
	,@AuthenticationAuthoritySCD			varchar(10)			= null								-- application authority indicator (Email, Google,AD etc)	
	,@AuthenticationSystemID					nvarchar(50)		= null								-- for federated logins - ID from external system
	,@ApplicationUserSID							int							= null		output			-- identifier of (new) user record created/updated (if any)
as
/*********************************************************************************************************************************
Procedure : Person Email Message - Confirm
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Sets confirmed time in email message referenced; creates or updates sf.ApplicationUser information if provided
History   : Author(s)			| Month Year		| Change Summary
          : -------------	|-------------	|-----------------------------------------------------------------------------------------
          : Tim Edlund		| Apr 2015			| Initial version (based on drafts by Christian T. and Richard K.)

Comments
--------
This procedure is called when a user clicks a "confirmation link" in an email message.  Confirmations may be used for various
purposes.  This version of the procedure expects the following use-cases:

1) New user creation		- email is an Application User Invite (bit) and data to create new account is provided in parameters
2) Password reset				- password is provided and existing user account exists (applies to email login authority only)
3) Email acknowledgment - simple recording of the fact the user has acknowledged receipt of the (important) email

Note that for applications using tenant services, DO NOT CALL this version of the procedure. Instead call the wrapper version 
which is deployed in the DBO schema of the client database.

Example:
--------

TODO: Christian April 2015

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo												int = 0																-- 0 no error, <50000 SQL error, else business rule
		,@errorText											nvarchar(4000)												-- message text (for business rule errors)
		,@blankParm											nvarchar(100)													-- error checking buffer for required parameters
		,@ON														bit = cast(1 as bit)									-- used on bit comparisons to avoid multiple casts
		,@OFF														bit = cast(0 as bit)									-- used on bit comparisons to avoid multiple casts				
		,@personEmailMessageSID					int																		-- primary key on the email being confirmed
		,@personSID											int																		-- identifier for the person who received the email
		,@emailAddress									nvarchar(75)													-- current email address for the user email 
		,@authenticationAuthoritySID		int																		-- identifier for application authority		
		,@templateApplicationUserSID		int																		-- identifier for the template user to copy grants from (if any)
		,@convertedInviteGUID						nvarchar(50)													-- string version of the email GUID (to avoid cast error)
		
	set @ApplicationUserSID = null									

	begin try	

		-- obtain identifying values based on the GUID passed; including
		-- latest current email address (may not be the one email was sent on)

		select 
			 @personSID										= pem.PersonSID
			,@emailAddress								= cast(isnull(pea.EmailAddress, pem.EmailAddress) as nvarchar(75))	-- becomes user name for user-invites
			,@templateApplicationUserSID	= em.ApplicationUserSID
			,@personEmailMessageSID				= pem.PersonEmailMessageSID
			,@AuthenticationSystemID			= 
			(
				case 
					when @AuthenticationAuthoritySCD = 'EMAIL.TS' then cast(@PersonEmailMessageGUID as nvarchar(50)) 
					else @AuthenticationSystemID 
				end
			)
		from
			sf.PersonEmailMessage			pem
		join
			sf.EmailMessage						em	on pem.EmailMessageSID = em.EmailMessageSID
		left outer join																																									-- use email on invite if current email is inactive
			sf.PersonEmailAddress			pea on pem.PersonSID = pea.PersonSID and pea.IsPrimary = @ON and pea.IsActive = @ON
		where
			pem.RowGUID = @PersonEmailMessageGUID

		if @personEmailMessageSID is null																			-- ensure GUID passed is valid
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  = 'RecordNotFound'
				,@MessageText = @errorText output
				,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
				,@Arg1        = 'Person Email Message'
				,@Arg2        = @PersonEmailMessageGUID

			raiserror(@errorText, 18, 1)

		end

		-- if email is of type user-invite, validate parameters and create
		-- the new application user record

		--TODO: Tim June 2015

		if 1=1 --@isApplicationUserInvite = @ON																			-- if authentication authority not passed get the default
		begin

			if @AuthenticationAuthoritySCD is null 
			begin
				select @authenticationAuthoritySID = aa.AuthenticationAuthoritySID from sf.AuthenticationAuthority aa where aa.IsDefault = @ON

				if @authenticationAuthoritySID is null
				begin

					exec sf.pMessage#Get
						 @MessageSCD  = 'ConfigurationNotComplete'
						,@MessageText = @errorText output
						,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
						,@Arg1        = 'Default Authentication Authority'

					raiserror(@errorText, 17, 1)

				end

			end
			else
			begin

				select 
					@authenticationAuthoritySID = aa.AuthenticationAuthoritySID
				from
					sf.AuthenticationAuthority aa
				where
					aa.AuthenticationAuthoritySCD = @AuthenticationAuthoritySCD
				and 
					aa.IsActive = @ON

				if @authenticationAuthoritySID is null
				begin

					exec sf.pMessage#Get
						 @MessageSCD  = 'RecordNotFound'
						,@MessageText = @errorText output
						,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
						,@Arg1        = 'Authentication Authority'
						,@Arg2        = @AuthenticationAuthoritySCD

					raiserror(@errorText, 18, 1)

				end

			end

			-- unless the authentication authority is email, the ID from the
			-- external system MUST be passed; for email logins a password is required

			if @AuthenticationAuthoritySCD <> 'EMAIL.TS' and @AuthenticationSystemID is null set @blankParm = '@AuthenticationSystemID'
			if @AuthenticationAuthoritySCD	= 'EMAIL.TS' and @Password							 is null set @blankParm = '@Password'

			if @blankParm is not null
			begin
		
				exec sf.pMessage#Get
					 @MessageSCD  	= 'BlankParameter'
					,@MessageText 	= @errorText output
					,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
					,@Arg1          = @blankParm

				raiserror(@errorText, 18, 1)

			end

			-- create the new user
					
			exec sf.pApplicationUser#Insert																			
				 @ApplicationUserSID					= @ApplicationUserSID				output		
				,@PersonSID										= @personSID
				,@AuthenticationAuthoritySID	= @authenticationAuthoritySID
				,@UserName										= @emailAddress
				,@GlassBreakPassword					= @Password
				,@AuthenticationSystemID			= @AuthenticationSystemID						-- for email logins value is set to GUID by after insert trigger
				,@TemplateApplicationUserSID	= @templateApplicationUserSID				-- pass in template user to assign grants 

		end
		else if @Password is not null																					-- password reset!
		begin

			select
				@ApplicationUserSID = au.ApplicationUserSID
			from
				sf.ApplicationUser au
			where
				au.PersonSID = @personSID

			if @authenticationAuthoritySID is null
			begin

				exec sf.pMessage#Get
					 @MessageSCD	= 'RecordNotFound'
					,@MessageText = @errorText output
					,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
					,@Arg1        = 'Application User'
					,@Arg2        = @personSID

				raiserror(@errorText, 18, 1)

			end

			exec sf.pApplicationUser#Update
				 @ApplicationUserSID	= @ApplicationUserSID
				,@GlassBreakPassword	= @Password

		end
		
		exec sf.pPersonEmailMessage#Update
			 @PersonEmailMessageSID	= @personEmailMessageSID										-- update confirmed time on the email message record
			,@IsConfirmed						= @ON																				
		
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)
end
GO
