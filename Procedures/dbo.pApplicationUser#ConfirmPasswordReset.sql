SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pApplicationUser#ConfirmPasswordReset]
	@PersonEmailMessageGUID uniqueidentifier	-- identifier of the email message being confirmed
 ,@Password								varbinary(8000)		-- new password to apply (encryption already applied)
as
/*********************************************************************************************************************************
Procedure : Application User - Confirm Password Reset 
Notice    : Copyright © 2015 Softworks Group Inc.
Summary   : Sets the password on the application user profile and confirms the email
History   : Author(s)			| Month Year	| Change Summary
					: -------------	|-----------	|-----------------------------------------------------------------------------------------
					: Cory Ng				| Jun 2015		| Initial version
					: Tim Edlund		| Oct 2017		| Updated to eliminate use of tenant services - password reset on local user profile

Comments
--------
This procedure sets a new password for the application user. Before this procedure is called an email message must be generated
using the sf.pApplicationUser#RequestPasswordReset stored procedure. The user must confirm their password change by clicking
on the link included in the email.  The link contains the GUID from the (sf) Person-Email-Message which is passed to this
procedure to confirm the change.

The password value has already been encrypted before the procedure is called.
 
Example:
--------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Select a random email message and reset the password. Rollback at the end">
		<SQLScript>
			<![CDATA[
				declare 
					 @personEmailMessageGUID	uniqueidentifier
					,@password								varbinary(8000) = cast('test' as varbinary(max))
											
				select
					@personEmailMessageGUID = pem.RowGUID
				from
					sf.vPersonEmailMessage pem
				where
					pem.IsPending = 1
				order by
					newid()

				begin transaction

				exec dbo.pApplicationUser#ConfirmPasswordReset
					 @PersonEmailMessageGUID	= @personEmailMessageGUID
					,@Password								= @password

				rollback
						
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'dbo.pApplicationUser#ConfirmPasswordReset'

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo							 int					 = 0							-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText						 nvarchar(4000)									-- message text (for business rule errors)
	 ,@blankParm						 nvarchar(100)									-- error checking buffer for required parameters
	 ,@ON										 bit					 = cast(1 as bit) -- used on bit comparisons to avoid multiple casts
	 ,@OFF									 bit					 = cast(0 as bit) -- used on bit comparisons to avoid multiple casts				
	 ,@personEmailMessageSID int														-- primary key on the email being confirmed
	 ,@userName							 nvarchar(75)										-- user name of the application user record
	 ,@isPending						 bit														-- tracks whether link is still pending
	 ,@applicationUserSID		 int;														-- key of the user profile record

	begin try

		if @PersonEmailMessageGUID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = '@PersonEmailMessageGUID';

			raiserror(@errorText, 18, 1);

		end;

		-- obtain identifying values based on the GUID passed

		select
			@personEmailMessageSID = pem.PersonEmailMessageSID
		 ,@userName							 = au.UserName
		 ,@applicationUserSID		 = au.ApplicationUserSID
		 ,@isPending						 = pem.IsPending
		from
			sf.vPersonEmailMessage pem
		join
			sf.ApplicationUser		 au on pem.PersonSID = au.PersonSID
		where
			pem.RowGUID = @PersonEmailMessageGUID;

		if @personEmailMessageSID is null -- ensure GUID passed is valid
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'Person Email Message'
			 ,@Arg2 = @PersonEmailMessageGUID;

			raiserror(@errorText, 18, 1);

		end;

		if @isPending = @OFF
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'LinkExpired'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 link has expired. Please request a new email and link.'
			 ,@Arg1 = 'password reset';

			raiserror(@errorText, 16, 1);
		end;

		-- all updates succeed or none are committed if error encountered

		begin transaction;

		exec sf.pApplicationUser#Update -- update the password on the profile
			@ApplicationUserSID = @applicationUserSID
		 ,@GlassBreakPassword = @Password;

		exec sf.pPersonEmailMessage#Update
			@PersonEmailMessageSID = @personEmailMessageSID -- update confirmed time on the email message record
		 ,@IsConfirmed = @ON;

		commit;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);
end;
GO
