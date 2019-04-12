SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#SetUserName]
	@UserName								nvarchar(75)	-- login email of the user to change user name for (existing value)
 ,@AuthenticationSystemID nvarchar(50)	-- alternate login identifier or RowGUID  
	 ,@NewUserName						varchar(75)	-- new user name to assign to the login profile
as
/*********************************************************************************************************************************
Sproc    : Application User - Set User Name
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Changes the user name value on the application profile. No data set is returned.
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Oct 2017		| Initial version
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------
 
This procedure is called when the user name value on the profile requires updating. The procedure ONLY supports resetting 
user names based on email addresses.  The @NewUserName value must be a valid email address.

The procedure may be called from a UI component on either the Administrator or Client portal.  When called from the Admin portal 
the administrator must ensure the user requesting the change has verified their identity as owner of the profile. The 
administrator must also confirm that the new user name is a valid email address. Sending to and getting a reply from the address 
in advance of making the change is recommended.

The other scenario for calling the procedure is from the Client (external) portal where the end user themselves is requesting the 
change and uses the application screens provided to verify their identity.  The reset of the user name is only applied when the
email confirming the change is confirmed. (Sent to the new address).

The procedure adds the new username as the user's primary email address if it does not already exist in the person-email-address 
table. If the address exists, but it is not active or primary, it is set to an active and primary state.

Example:
--------
<TestHarness>
	<Test Name = "SetAndReset" IsDefault ="true" Description="Updates username to test value and then resets it to original value.">
		<SQLScript>
			<![CDATA[

declare
	@userName								nvarchar(75)
 ,@authenticationSystemID nvarchar(50)
 ,@newUserName						nvarchar(75)
 ,@personSID							int;

select top (1) -- select a user at random and store existing values
	@userName								= au.UserName
 ,@authenticationSystemID = au.AuthenticationSystemID
 ,@newUserName						= left(au.UserName, charindex('@', au.UserName)) + 'unitTest.com'
 ,@personSID							= au.PersonSID
from
	sf.ApplicationUser au
order by
	newid();

exec sf.pApplicationUser#SetUserName
	@UserName = @userName
 ,@AuthenticationSystemID = @authenticationSystemID
 ,@NewUserName = @newUserName;

select
	*
from
	sf.ApplicationUser au
where
	au.UserName = @newUserName;

select
	*
from
	sf.PersonEmailAddress pea
where
	pea.PersonSID = @personSID
order by
	pea.CreateTime desc;

exec sf.pApplicationUser#SetUserName -- call a second time to set values back to original
	@UserName = @newUserName
 ,@AuthenticationSystemID = @authenticationSystemID
 ,@NewUserName = @userName;

select
	*
from
	sf.ApplicationUser au
where
	au.UserName = @userName;

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
	@ObjectName = 'sf.pApplicationUser#SetUserName'

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo							 int					 = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText						 nvarchar(4000)									-- message text (for business rule errors)
	 ,@blankParm						 nvarchar(100)									-- error checking buffer for required parameters
	 ,@ON										 bit					 = cast(1 as bit) -- used on bit comparisons to avoid multiple casts
	 ,@OFF									 bit					 = cast(0 as bit) -- used on bit comparisons to avoid multiple casts
	 ,@newMessageText nvarchar(1000) -- buffer to hold multi-line message t
	 ,@personSID						 int														-- key of person record to update
	 ,@applicationUserSID		 int														-- key of application record to update
	 ,@personEmailAddressSID int;														-- checks for existing of the new user name as an email address

	begin try

		if @NewUserName is null
			set @blankParm = '@NewUserName';
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

		set @NewUserName = ltrim(rtrim(@NewUserName));

		if sf.fIsValidEmail(@NewUserName) = @OFF
		begin

			set @newMessageText =
				N'The email address is not a valid format. Ensure the address does not contain spaces.'
				+ 'An "@" sign must separate the username and the domain. Example: john.doe@softworksgroup.com"';

			exec sf.pMessage#Get
				@MessageSCD = 'InvalidEmailAddress'
			 ,@MessageText = @errorText output
			 ,@DefaultText = @newMessageText

			raiserror(@errorText, 16, 1);
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
			 ,@Arg2 = @UserName;

			raiserror(@errorText, 18, 1);
		end;

		-- ensure new user name won't create a duplicate

		if exists(select 1 from sf.ApplicationUser au where au.UserName = @NewUserName and au.ApplicationUserSID <> @applicationUserSID)
		begin

			set @newMessageText =
				N'This email address is already assigned as the login for another account. User names must be unique.';

			exec sf.pMessage#Get
				@MessageSCD = 'UserNameNotUnique'
			 ,@MessageText = @errorText output
			 ,@DefaultText = @newMessageText

			raiserror(@errorText, 16, 1);
		end

		-- check to see if the new username is already recorded as 
		-- an active and primary email address

		select
			@personEmailAddressSID = pea.PersonEmailAddressSID
		from
			sf.ApplicationUser		au
		join
			sf.Person							p on au.PersonSID	 = p.PersonSID
		left outer join
			sf.PersonEmailAddress pea on p.PersonSID = pea.PersonSID and pea.EmailAddress = @NewUserName
		where
			au.ApplicationUserSID = @applicationUserSID;

		begin transaction;

		if @personEmailAddressSID is null
		begin

			exec sf.pPersonEmailAddress#Insert
				@PersonSID = @personSID
			 ,@EmailAddress = @NewUserName
			 ,@IsPrimary = @ON
			 ,@IsActive = @ON;

		end;
		else
		begin

			if not exists
			(
				select
					1
				from
					sf.PersonEmailAddress pea
				where
					pea.PersonEmailAddressSID = @personEmailAddressSID and pea.IsPrimary = @ON and pea.IsActive = @ON
			)
			begin

				exec sf.pPersonEmailAddress#Update
					@PersonEmailAddressSID = @personEmailAddressSID
				 ,@IsPrimary = @ON
				 ,@IsActive = @ON;

			end;
		end;

		exec sf.pApplicationUser#Update
			@ApplicationUserSID = @applicationUserSID
		 ,@UserName = @NewUserName;

		commit;
	end try
	begin catch
		if @@trancount > 0 rollback;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
