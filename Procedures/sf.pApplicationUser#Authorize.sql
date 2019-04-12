SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pApplicationUser#Authorize
	@UserName								nvarchar(75)				-- application username to authorize
 ,@IPAddress							varchar(45)					-- IP address of the user session
 ,@AuthenticationSystemID nvarchar(50) = null -- lookup ID for federated logins (only) see note
as
/*********************************************************************************************************************************
Sproc    : Application User Authorize
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Returns single row of user context information including database, user display name, and application grants as xml
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ + ----------- + ------------------------------------------------------------------------------------------
				 : Tim Edlund     Apr 2010			Initial Version
				 : Tim Edlund     Nov 2011			Updated to return data status color (business rule check) on the database
																				Updated MessageSCD codes to new standard - removed underscores
				 : Art Lucas      Feb 2012			Updated to add support for ApplicationGrantXML - used in the front-end to easily control
																				access to resources.
				 : Tim Edlund     Feb 2012      Updated for rename of sf.UserSession to sf.ApplicationUserSession.  Added SessionGUID.
																				Updated to store 1 row into sf.ApplicationUserSession each time procedure is called in
																				order to support auditing of logins and various checks by sf.ApplicationUserSession#Set
																				Added "culture" value to profile.
				 : Tim Edlund     Jun 2012      Removed @ApplicationCode parameter and revised logic to check for license violations
																				to use the sf.vLicense#ModuleStatus view.  Updated documentation.
				 : Tim Edlund     Jul 2012      Update XML argument of grants returned to check to ensure grant is in effect (IsActive in
																				#Ext view) Change required to enforce term defined in Effective-Expiry date columns added
																				to the sf.ApplicationUserGrant table.
				 : Tim Edlund     Nov 2012			Added "IsUnused" bit to indicate if the user has not logged in recently (term of recent
																				is defined in sf.ConfigParam). Also implemented "Exclude" tag on column list for
																				supporting overrides on some columns returned from sf.vApplicationUser at end of sproc.
				: Tim Edlund			May	2014			Added spacing to error message around user name.
				: Tim Edlund			Jun	2014			Added @AuthenticationSystemID parameter as an alternate means, in addition to @UserName,
																				to lookup the user record in the table. This value should be passed by the client-tier
																				when a federated login (e.g. MS Account, Google Account) is being used.  For direct
																				email and AD logins, this value should not be passed.  Updated documentation.
				: Tim Edlund			Jul 2014			Changed logic so that if the user name is "JobExec", then the account does not have to be
																				in an active status.  JobExec is a system account reserved for running background jobs.
																				The UI prevents users from logging in (on the client) using this account.  The back-end
																				allows authorization so that when a job is called, this account which has SA rights can
																				be used to ensure background jobs will not fail due to rights issues.
				:	Kris Dawson			Oct 2014			Changed logic so that if the user name is "admin@helpdesk", then the account does not
																				have to be in an active status. Updated the access check to ensure that the grant is
																				active as well.
				:	Kris Dawson			Feb 2015			Changed to call sf.pApplicationUser#Get when retrieving the application user entity
				:	Russ Poirier		Mar 2017			Replaced "registrant" with "contact" for error messages
				: Tim Edlund			Apr 2017			Removed check for module license counts.  The process is too slow on larger systems to
																				run at login.  The checks for license count violations were improved for the assignment
																				of grants and changes to effective dates for grants - eliminating the need to run the
																				checks in this procedure.
				: Tim Edlund			May 2017			Added support for an alternate username scenario where a registration ID (Alinity) or 
																				other identification number is used instead of an email address for login.  The value is
																				searched in the AuthenticationSystemID column (also used for Federated Login) in the 
																				application user table. 
				: Tim Edlund			Jun 2018			Removed logic that copied values of previous user profile properties to the current 
																				session.  The original logic to the copying was implemented in September 2014.
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------

This procedure is designed to be called by the front end at start-up. This version of the framework supports 3 login types:
	1) Active Directory
	2) Federated logins - e.g. MS Account, Google Account
	3) Direct Email logins (email address is stored in sf.ApplicationUser "UserName" column)

When this procedure is called, the user has already successful logged in.  Where AD is used the user need only have logged into
the network.  For Federated login the client-tier has checked for a valid token and for non-federated login, the user name and
password challenge has passed.

At the point this procedure is called, the user has been "authenticated" but needs to be "authorized" by this procedure to
determine what rights (if any) they have on the application.  This procedure handles that process by checking for an application
user record (sf.ApplicationUser) and at least one valid grant record (sf.ApplicationUserGrant). This information needs to be
looked up by the AuthenticationSystemID in the case of federated logins (the value typically being a GUID), or, by the user name
for AD and direct email logins.  (For direct email logins the UserName IS the primary email address.)

The procedure returns 1 row of user profile/context information, a session GUID to identify the session on subsequent calls to
the database, and, an XML document of grants they have been assigned. Each grant is a system code stored in the sf.ApplicationGrant
table. The existence of the code in the dataset means that the right has been granted (a row in sf.ApplicationUserGrant).  Grants
not made do not appear in the XML. If the user has the SysAdmin grant, then they are treated by the application as if all grant
codes have been assigned to them.

While an individual may have authority to login and access the executable, they may not be an authorized user of the application.
This procedure raises an error if the user is not authorized. If the user is authorized, then the "last authorized time" on the
user session is updated and a data set is returned.

The procedure returns the name of the database. This is done so that the UI can display the name and provide the user confirmation
that the are logged into the correct database - e.g. UAT, PROD, etc..  The procedure also checks the sf.vApplicationEntity view to
see if there are any known data errors on the database at the time of login.  If there are errors the database name is
displayed in a highlight color (e.g. red), while otherwise it is displayed in a non-highlighted color. An exclamation point is
also added to the DB name if there are errors pending. It is good practice to differentiate the non-highlighted color between UAT
and PROD databases by setting different colors in the sf.ConfigParam table (parameter = 'DatabaseNameValidColor').

The UI components of the system require a common culture value to be returned from the database. While it is technically possible
for each user to have their own culture value - e.g. "en-ca" versus "fr-ca", it is not supported in the current version of
framework applications.  The culture value is looked up in the sf.ConfigParam table and provided as part of the ApplicationEntity
entity returned by this procedure.

Attempts by unauthorized accounts end up being tracked in sf.ApplicationUserSession. The unauthorized records can be identified
easily since their "LastAuthorizedTime" will be null.

Note that the pApplicationUserSession#Set must NOT be called in advance of calling this procedure. This procedure sets up the
new sf.ApplicationUserSession record for the new user session and also passes back a GUID stored by the front-end which is
is used on all subsequent calls to the database to re-validate the user session.  SEE also sf.pApplicationUserSession#Set.

Example:
--------

<TestHarness>
	<Test Name="AuthorizeRandomUser" IsDefault="true" Description="Selects an active user at random, who has at least 1 grant, and attempts
				to authorize them.">
		<SQLScript>
			<![CDATA[

declare
	 @applicationUserSID	int
	,@userName						nvarchar(75)

select top(1)
	 @applicationUserSID	= aug.ApplicationUserSID
	,@userName						= aug.UserName
from
	sf.vApplicationUserGrant aug
where
	aug.ApplicationUserIsActive = cast(1 as bit)
order by
	newid()

exec sf.pApplicationUser#Authorize
	@UserName   = @userName
 ,@IPAddress = '10.0.0.1'

select
	'OK'
from
	sf.vApplicationUserSession
where
	UserName = @userName
and
	datediff(second, CreateTime, sysdatetimeoffset()) < 5

]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="RowCount" ResultSet="2" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="1" Value="OK"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" ResultSet="1"  />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pApplicationUser#Authorize'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo									 int					 = 0	-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText								 nvarchar(4000)			-- message text (for business rule errors)
	 ,@blankParm								 varchar(100)				-- tracks blank values in required parameters
	 ,@applicationUserSID				 int								-- primary key of the application record found
	 ,@applicationUserSessionSID int								-- primary key of the new session record created
	 ,@contextInfo							 binary(128)				-- pk of the ApplicationUserSession table record updated
	 ,@defaultText							 nvarchar(1000);		-- buffer to manage definitions of error messages

	begin try

		-- check parameters

		if @IPAddress is null set @blankParm = '@IPAddress';
		if @UserName is null set @blankParm = '@UserName';

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = @blankParm;

			raiserror(@errorText, 18, 1);

		end;

		-- ensure the user name is stored in lowercase; if the value is passed
		-- in with a backslash separating the domain - reformat with "@" sign

		set @UserName = sf.fFormatUserName(@UserName);

		-- look for at least one ApplicationUserGrant assigned to this username; lookup by
		-- the federated authentication systems ID if provided, otherwise lookup by the username

		if @AuthenticationSystemID is not null
		begin

			select top (1)
				@applicationUserSID = aug.ApplicationUserSID
			 ,@UserName						= aug.UserName	-- if the primary email address was updated in the federated user record, we want
			from -- their audit information to be the same as before so look it up
				sf.vApplicationUserGrant aug
			where
				aug.AuthenticationSystemID		= @AuthenticationSystemID and aug.IsActive = cast(1 as bit) -- ensure the grant made to the user is currently active
				and
				(
					aug.ApplicationUserIsActive = cast(1 as bit) or aug.UserName = N'JobExec' or aug.UserName = N'admin@helpdesk'
				)
			order by
				aug.ApplicationUserGrantSID desc;

		end;
		else
		begin

			-- if the user name provided includes an "@" sign then we assume
			-- it is an email address; otherwise assume it is some form of
			-- ID number and look it up in the authentication-system-ID column

			if charindex('@', @UserName) > 0
			begin

				select top (1)
					@applicationUserSID = aug.ApplicationUserSID
				from
					sf.vApplicationUserGrant aug
				where
					aug.UserName									= @UserName
					and aug.IsActive							= cast(1 as bit)
					and
					(
						aug.ApplicationUserIsActive = cast(1 as bit) or aug.UserName = N'JobExec' or aug.UserName = N'admin@helpdesk'
					)
				order by
					aug.ApplicationUserGrantSID desc;

			end;
			else
			begin

				select top (1)
					@applicationUserSID = aug.ApplicationUserSID
				from
					sf.vApplicationUserGrant aug
				where
					aug.AuthenticationSystemID		= @UserName
					and aug.IsActive							= cast(1 as bit)
					and
					(
						aug.ApplicationUserIsActive = cast(1 as bit) or aug.UserName = N'JobExec' or aug.UserName = N'admin@helpdesk'
					)
				order by
					aug.ApplicationUserGrantSID desc;

			end;

		end;

		if @@rowcount = 0
		begin

			set @defaultText =
				N'Your account does not have authorization on this application or is marked inactive. '
				+ 'Please contact the application administrator for assistance. (Account ID: %1)';

			exec sf.pMessage#Get
				@MessageSCD = 'AccountNotAuthorized'
			 ,@MessageText = @errorText output
			 ,@Arg1 = @UserName
			 ,@DefaultText = @defaultText;

			raiserror(@errorText, 16, 1);

		end;

		-- user is authorized - 1st ensure any previously active sessions for the user are inactivated

		update
			sf.ApplicationUserSession
		set
			IsActive = 0
		 ,UpdateTime = sysdatetimeoffset()
		 ,UpdateUser = @UserName
		where
			ApplicationUserSID = @applicationUserSID and IsActive = 1;

		-- next insert the new session record and capture its PK

		insert
			sf.ApplicationUserSession
		(
			ApplicationUserSID
		 ,IPAddress
		 ,CreateUser
		 ,UpdateUser
		)
		select @applicationUserSID, @IPAddress, @UserName, @UserName;

		set @applicationUserSessionSID = scope_identity();

		-- set the context info to the key of the session record
		-- so that other sprocs can determine the application user

		set @contextInfo = convert(binary(128), @applicationUserSessionSID);
		set context_info @contextInfo;

		-- select the full application user entity

		exec sf.pApplicationUser#Get
			@ApplicationUserSID = @applicationUserSID;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
