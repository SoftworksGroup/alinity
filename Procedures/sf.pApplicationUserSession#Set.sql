SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pApplicationUserSession#Set
	@UserName									 nvarchar(75)				-- application user name from AD to lookup in ApplicationUserSession
 ,@SessionGUID							 uniqueidentifier		-- created at login to identify current session (checks duplicates)
 ,@TimeOut									 int = null					-- timeout in minutes; NULL gets default - pass 0 to override (none)
 ,@ApplicationUserSessionSID int = null output	-- pk of sf.ApplicationUserSession record inserted or updated
as
/*********************************************************************************************************************************
Sproc		: User Session Set
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Establishes the user context setting for the application user
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Apr		2010		|	Initial version
				:	Tim Edlund	|	Mar		2011		|	Updated documentation
        : Tim Edlund  | Mar		2012    | Added checks for: missing session, duplicate session, session timeout
                                        Revised overview documentation
				: Tim Edlund	| Nov		2012		| Change error severity from 10 to 16 to simplify catching the errors in the front end.
																				Removed references to IPAddress (which was not being checked) and updated documentation.
				: Tim Edlund	| Feb		2014		| Added support for @TimeOut = 0 which overrides default time out behaviour to avoid
																				timing out. Used when there is keyboard activity from the user monitored by the UI.
				: Tim Edlund	| May		2015		| Update logic for @TimeOut = 0 so that the time on the previous session record is only
																				updated when a value other than 0 is provided. This allows a save to complete when user
																				has pending edits active but will time out on next request for data (whenever 0 is not
																				passed on subsequent calls).
				: Cory Ng			| Jul		2017		| Updated to return application user entity to avoid second call to retrieve entity right
																				after session is set. This should also avoid deadlocks on the session record.
				: Tim Edlund	|	May 2018			| Added support for a separate administrative timeout which can be different than the
																				general time out used on the non-admin portals.  Defaults to 60 minutes. SCD=AdminTimeOut
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure is called by framework web services whenever a database connection is obtained.  The only call made to the database
that does not call this procedure is the login authorization sproc:  sf.pApplicationUser#Authorize.  That procedure returns the
@SessionGUID value that is then stored in a cookie by the client-tier and must be passed to this procedure on all subsequent
database requests by that session.

This procedures has 2 purposes:
  1) security checks: ensure the user has active session, not duplicated, and not timed out
  2) identification : to enable other back-end procedures to be able to determine who the actual "application user" is.

When a user accesses the application (authentication has occurred through Active Directory) a GUID value is returned from an
authorization procedure (sf.pApplicationUser#Authorize).  The authorization procedure's main purpose is to provide the list of
grants the user has access to but it also returns a GUID value which is stored in a cookie by the front end. That value is passed
to this sproc on all calls for database access that occur throughout the session. The authorization procedure also creates a
session record (sf.ApplicationUserSession) associated with the GUID which stores the user name and IP address.

When this procedure is called it first checks to ensure no more than 1 active session exists for the given @UserName. Such a
scenario should not be possible given the actions carried out in sf.pApplicationUser#Authorize to cancel old sessions, however,
the check is performed as a precaution against back-end attacks.

The procedure next locates the sf.ApplicationUserSession record where the IsActive (session) bit is turned ON. The GUID value from
that record is compared to the GUID retrieved from the cookie and passed in. If they are different an error is raised.  This
error arises when 2 or more users have attempted to login with the same ID. When the second user connects to the application
using the same ID, the sf.pApplicationUser#Authorize procedure sets any previous session records for that user name to inactive.
If a previously connected session still has the application running, they will have no active session for their GUID. Based on
this method, the latest session to access with a given user name receives access, while any previously connected session using
that name loses theirs. This ensures: 1) only one session per user name is active and 2) any prior session that was not ended
through a logout (e.g. where user just closes their browser or the application "crashes out" ) is marked inactive when that user
next accesses the application.

The procedure also checks to ensure the session has not timed out due to inactivity.  The timeout calculation uses a "sliding"
method. This means that every time this procedure is called, the timer is reset to 0.  If the timeout period is set to 30 minutes
for example, as long as the user is accessing the database at least once every 30 minutes, their session will remain active.

The @TimeOut value can be passed directly but is most often obtained from a configuration value (sf.ConfigParam) when NULL. The
parameter is intended primarily to support "workstation specific" timeouts that need to be shorter than the system-wide default
for workstations in public areas. In these cases the timeout value is obtained from "local storage" on that workstation.

Overriding the timeout behaviour is achieved by passing @TimeOut as 0 (or any negative value).  This supports situations where
there is keyboard activity in the UI layer of the program but database activity has not occurred during the time out period.
To prevent this procedure from showing a time out, the UI layer resets the inactivity timer when there is keyboard activity
and if no timeout has occurred according to that criteria, then the UI passes @TimeOut = 0 to avoid having the database
raise the error.

All errors raised by this procedure - except un-handled exceptions - are assigned the severity value of "16". These errors will
appear in the UI in the usual error panel. The user will be unable to proceed until they login to the application again so
it is important to include that information on all error messages coming out of this procedure. The user must close and re-
open their browser (or the application if running out-of-browser) in order to gain access to the application. Restarting the
application invokes another challenge to AD for credentials which are passed to the application.

The second purpose of this procedure is to enable other back-end procedures and views to be able to determine who the current user
is. In order to take advantage of "pooled logins" which are permanently connected and therefore provide quick access, all
Framework applications use shared database ID's. The database ID then, does not tell the application who the actual user is.  To
determine the "application user", this procedure is called on each access to the database to set the context_info value to the
primary key of the user session record (sf.ApplicationUserSession). This record was created at login.  The record itself stores
information about the user including their name, IP address and their "SessionGUID" as well as when they last accessed the
database.  With this done, any back-end procedure called subsequently can determine who the application user is rather than
seeing only the database ID.

If the UserName is passed in using the older style format:  "domain\username" it is reformatted by this procedure as:
"username@domain". This is done to ensure user session records are not duplicated for user names that are functionally equivalent
on the domain.

Example
-------
<TestHarness>
  <Test Name = "Active" IsDefault ="true" Description="Locates an active session at random and attempts to re-use it.">
    <SQLScript>
      <![CDATA[
declare
	@userName		 nvarchar(75)
 ,@sessionGUID uniqueidentifier;

select top (1)
	@userName		 = aus.UserName
 ,@sessionGUID = aus.RowGUID
from
	sf.vApplicationUserSession aus
where
	aus.IsActive = 1
order by
	newid();

if @@rowcount = 0 or @userName is null
begin
	raiserror('** ERROR ** No Suitable Data Found For Test!', 17, 1);
end;
else
begin

	select
		aus.UserName
	 ,aus.UpdateTime
	 ,cast((select count(1) from sf.vApplicationUserGrant aug where aug.UserName = aus.UserName and aug.IsActive = 1 and left(aug.ApplicationGrantSCD,6) = 'ADMIN.') as bit) IsAdmin
	from
		sf.vApplicationUserSession aus
	where
		aus.RowGUID = @sessionGUID;

	exec sf.pApplicationUserSession#Set
		@UserName = @userName
	 ,@SessionGUID = @sessionGUID;

	select
		aus.UserName
	 ,aus.UpdateTime
	from
		sf.vApplicationUserSession aus
	where
		aus.RowGUID = @sessionGUID;

end;
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="2" Value="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:01"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pApplicationUserSession#Set'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo			int							= 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText		nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm		varchar(100)											-- tracks blank values in required parameters
	 ,@ON						bit							= cast(1 as bit)	-- constant for bit comparisons = 1
	 ,@charPosition int																-- character position used in reformatting user name
	 ,@sessionCount int																-- count of active sessions for the user
	 ,@updateTime		datetimeoffset										-- time the user last accessed - to check timeout
	 ,@rowGUID			uniqueidentifier									-- GUID on the user session row (should match @SessionGUID)
	 ,@contextInfo	binary(128)												-- PK of the ApplicationUserSession table record updated
	 ,@defaultText	nvarchar(1000)										-- buffer for storing default text for error messages raised

	set @ApplicationUserSessionSID = null; -- initialize output parameters in all code paths

	begin try

		if @UserName is null set @blankParm = '@UserName'; -- check for required parameters - throw error if null
		if @SessionGUID is null set @blankParm = '@SessionGUID';

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);

		end;

		-- set timeout value to configuration setting, or if not defined, to 20 minutes

		if @TimeOut is null
			set @TimeOut = isnull(convert(smallint, sf.fConfigParam#Value('TimeOut')), 20);

		-- ensure the user name is stored in lowercase; if the value is passed
		-- in with a backslash separating the domain - reformat with "@" sign

		set @UserName = lower(@UserName); -- reformat: "sgi\tim.e" => "tim.e@sgi"
		set @charPosition = charindex('\', @UserName);

		if @charPosition > 0
			set @UserName = substring(@UserName, @charPosition + 1, 75) + '@' + left(@UserName, @charPosition - 1);

		-- 1st check for duplicate active logins

		select
			@sessionCount = count(1)
		from
			sf.ApplicationUser				au
		join
			sf.ApplicationUserSession aus on au.ApplicationUserSID = aus.ApplicationUserSID and aus.IsActive = cast(1 as bit)
		where
			au.UserName = @UserName;

		if @sessionCount = 0
		begin

			set @defaultText =
				N'No active session was found for your user ID "%1". Another user may have logged in with your ID '
				+ N'causing your session to be closed.  User ID''s cannot be shared. Please login again to ' + N're-establish your session.';

			exec sf.pMessage#Get
				@MessageSCD = 'NotLoggedIn'
			 ,@MessageText = @errorText output
			 ,@DefaultText = @defaultText
			 ,@Arg1 = @UserName;

			raiserror(@errorText, 16, 1); -- severity 16!

		end;
		else if @sessionCount > 1 -- multiple sessions - mark all inactive the user name
		begin -- scenario should already be prevented by #Authorize

			update
				aus
			set
				aus.IsActive = 0
			from
				sf.ApplicationUser				au
			join
				sf.ApplicationUserSession aus on au.ApplicationUserSID = aus.ApplicationUserSID
			where
				au.UserName = @UserName;

			set @defaultText =
				N'Multiple active sessions were found for your user ID "%1". User ID''s cannot be shared. ' + N'Please login again to re-establish your session.';


			exec sf.pMessage#Get
				@MessageSCD = 'DuplicateSessions'
			 ,@MessageText = @errorText output
			 ,@DefaultText = @defaultText
			 ,@Arg1 = @UserName;

			raiserror(@errorText, 16, 1);

		end;

		select -- retrieve details for the 1 active session
			@ApplicationUserSessionSID = aus.ApplicationUserSessionSID
		 ,@updateTime								 = aus.UpdateTime
		 ,@rowGUID									 = aus.RowGUID
		from
			sf.ApplicationUser				au
		join
			sf.ApplicationUserSession aus on au.ApplicationUserSID = aus.ApplicationUserSID and aus.IsActive = cast(1 as bit)
		where
			au.UserName = @UserName;

		if @SessionGUID <> @rowGUID -- the user's session was closed - likely a shared login
		begin

			set @defaultText =
				N'Another active session was found for your user ID "%1". Another user may have logged in with your ID '
				+ N'causing your session to be closed.  User ID''s cannot be shared.  Please login again to ' + N're-establish your session.';

			exec sf.pMessage#Get
				@MessageSCD = 'NewSessionGUID'
			 ,@MessageText = @errorText output
			 ,@DefaultText = @defaultText
			 ,@Arg1 = @UserName;

			raiserror(@errorText, 16, 1);

		end;

		if @TimeOut > 0 and datediff(minute, @updateTime, sysdatetimeoffset()) >= @TimeOut -- inactivity time limit reached (no override)
		begin

			-- if the are an administrator check for
			-- override of admin time out - defaults to 60 minutes

			if exists
			(
				select
					1
				from
					sf.vApplicationUserGrant aug
				where
					aug.UserName = @UserName and aug.IsActive = @ON and left(aug.ApplicationGrantSCD, 6) = 'ADMIN.'
			)
			begin
				set @TimeOut = isnull(convert(smallint, sf.fConfigParam#Value('AdminTimeOut')), 20);
			end;

			if datediff(minute, @updateTime, sysdatetimeoffset()) >= @TimeOut
			begin

				set @defaultText = N'Your session was closed after %1 minutes of inactivity. Please login again to re-establish your session.';

				exec sf.pMessage#Get
					@MessageSCD = 'SessionTimedOut'
				 ,@MessageText = @errorText output
				 ,@DefaultText = @defaultText
				 ,@Arg1 = @TimeOut;

				raiserror(@errorText, 16, 1);
			end;
			else
			begin

				update
					sf.ApplicationUserSession
				set
					UpdateTime = sysdatetimeoffset()
				where
					ApplicationUserSessionSID = @ApplicationUserSessionSID; -- if admin didn't time out update their session time

			end;

		end;
		else if @TimeOut > 0 -- update previous session record only if 0 not passed!
		begin

			update
				sf.ApplicationUserSession
			set
				UpdateTime = sysdatetimeoffset()
			where
				ApplicationUserSessionSID = @ApplicationUserSessionSID;

		end;

		-- set the context info to the key of the session record
		-- so that other sprocs can determine the application user

		set @contextInfo = convert(binary(128), @ApplicationUserSessionSID);
		set context_info @contextInfo;

	end try
	begin catch

		-- the error handler formats error differently depending on whether or not an active
		-- session has been set; on sessions errors (severity = 16) set a user session to
		-- cause error output to be formatted in XML for the front end

		if error_severity() = 16
		begin

			if @ApplicationUserSessionSID is null
			begin

				select top (1)
					@ApplicationUserSessionSID = aus.ApplicationUserSessionSID
				from
					sf.ApplicationUser				au
				join
					sf.ApplicationUserSession aus on au.ApplicationUserSID = aus.ApplicationUserSID and aus.IsActive = cast(1 as bit)
				where
					au.UserName = @UserName
				order by
					aus.ApplicationUserSessionSID desc; -- take last session; active or not

			end;

			if @ApplicationUserSessionSID is not null
			begin
				set @contextInfo = convert(binary(128), @ApplicationUserSessionSID);
				set context_info @contextInfo;
			end;

		end;

		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
