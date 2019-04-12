SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#SetPassword]
	@UserName								nvarchar(75)		-- login email of the user to change password for
 ,@AuthenticationSystemID nvarchar(50)		-- alternate login identifier or RowGUID  
 ,@NewPassword						varbinary(8000) -- new password
as
/*********************************************************************************************************************************
Sproc    : Application User - Set Password
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Changes the user password on the application profile. No data set is returned.
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Oct 2017		| Initial version
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
 
This procedure is called when the password on the profile requires updating. The value of @NewPassword must already be encrypted
to use this procedure. 

Passwords may be reset by either administrators or end users.  This procedure supports the reset from the Admin portal.  The 
administrator must ensure the user requesting the change has verified their identity as owner of the profile. 

The other scenario for calling the procedure is from the Client (external) portal where the end user themselves is requesting the 
change and uses the application screens provided to capture and confirm the new password. The reset of the password is that 
scenario occurs through dbo.pApplicationUser#ConfirmPasswordReset because an email confirmation link must be validated.

Example:
--------
<TestHarness>
	<Test Name = "SetAndReset" IsDefault ="true" Description="Updates password to test value and then resets it to original value.">
		<SQLScript>
			<![CDATA[

declare
	@userName								nvarchar(75)
 ,@authenticationSystemID nvarchar(50)
 ,@newPassword						varbinary(8000)
 ,@oldPassword						varbinary(8000)
 ,@personSID							int;

select top (1) -- select a user at random and store existing values
	@userName								= au.UserName
 ,@authenticationSystemID = au.AuthenticationSystemID
 ,@oldPassword						= au.GlassBreakPassword
 ,@newPassword						= sf.fHashString(au.RowGUID, 'test@sgi')
 ,@personSID							= au.PersonSID
from
	sf.ApplicationUser au
order by
	newid();

exec sf.pApplicationUser#SetPassword
	@UserName = @userName
 ,@AuthenticationSystemID = @authenticationSystemID
 ,@NewPassword = @newPassword;

select
	*
from
	sf.ApplicationUser au
where
	au.GlassBreakPassword = @newPassword;

exec sf.pApplicationUser#SetPassword -- call a second time to set values back to original
	@UserName = @userName
 ,@AuthenticationSystemID = @authenticationSystemID
 ,@NewPassword = @oldPassword;

select
	*
from
	sf.ApplicationUser au
where
	au.GlassBreakPassword = @oldPassword;



		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="RowCount" ResultSet="2" Value="1" />
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="4" Value="Test Test"/>
			<Assertion Type="ExecutionTime" Value="00:00:03"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pApplicationUser#SetPassword'

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo						int						= 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText					nvarchar(4000)									-- message text (for business rule errors)
	 ,@blankParm					nvarchar(100)										-- error checking buffer for required parameters
	 ,@ON									bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@OFF								bit						= cast(0 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@personSID					int															-- key of person record to update
	 ,@applicationUserSID int;														-- key of application record to update

	begin try


		if @NewPassword is null
			set @blankParm = '@NewPassword';
		if @AuthenticationSystemID is null
			set @blankParm = '@AuthenticationSystemID';
		if @UserName is null
			set @blankParm = '@UserName';

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);

		end;

		-- ensure required values from user profile (must exist)

		select
			@applicationUserSID = au.ApplicationUserSID
		 ,@personSID					= au.PersonSID
		from
			sf.ApplicationUser au
		where
			au.UserName = @UserName and au.AuthenticationSystemID = @AuthenticationSystemID; -- search on both values

		if @applicationUserSID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'Application User'
			 ,@Arg2 = @applicationUserSID;

			raiserror(@errorText, 18, 1);
		end;

		exec sf.pApplicationUser#Update
			@ApplicationUserSID = @applicationUserSID
		 ,@GlassBreakPassword = @NewPassword;

	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
