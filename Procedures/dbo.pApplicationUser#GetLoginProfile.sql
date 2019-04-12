SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pApplicationUser#GetLoginProfile]
	@UserName								nvarchar(75)		 = null output	-- login email of the user to return profile for 
 ,@AuthenticationSystemID nvarchar(50)		 = null output	-- federated login identifier / RowGUID of user
 ,@SubDomain							varchar(63)			 = null					-- when provided, sproc returns if is account owner
 ,@ReturnDataSet					bit							 = 1						-- when 0, no data set is returned (use output parameters below)
 ,@FirstName							nvarchar(30)		 = null output	-- values looked up from profile: (for calls from back-end)
 ,@LastName								nvarchar(35)		 = null output
 ,@DisplayName						nvarchar(65)		 = null output
 ,@AppPassword						varbinary(8000)	 = null output
 ,@HashSalt								uniqueidentifier = null output
 ,@IsAccountOwner					bit							 = 0 output
as
/*********************************************************************************************************************************
Sproc    : Application User - Get Login Profile
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Returns login profile information from the Tenant Services database for a user of a client application
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Nov 2014		| Initial version.
				 : Tim Edlund		| Mar	2015		| Added branching to handle deployments without Tenant Service database.
				 : Tim Edlund		| Oct 2017		| Updated to eliminate use of tenant services - local profiles only
				 : Cory Ng			| Nov 2018		| Updated to support look up by registrant # if passed through @UserName parameter
----------------------------------------------------------------------------------------------------------------------------------
 
Comments
--------

This procedure is called to retrieve user profile information.  The procedure SELECT's content from the sf.Person and 
sf.ApplicationUser tables in the local database.

Is Account Owner (on returned data set)
---------------------------------------
The @SubDomain parameter is optional.  When the user is logging into their specific sub-domain, pass this value and the procedure
looks up whether or not the user is the account owner for the subscription.  If a sub-domain value is not provided, then the
procedure always returns NULL for this value.

The values are returned as a data set.  A function import and custom business object are required to use the procedure within
the entity framework.  The values returned can be updated in the UI and passed back for update in the applicaction user through
the dbo.pApplicationUser#SetLoginProfile procedure.  

Maintenance Note
----------------
Any changes to the structure of the data set returned by this procedure may require parallel changes in 
dbo.pApplicationUser#SetLoginProfile.

Example:
--------
 
<TestHarness>
	<Test Name = "UserName" IsDefault ="true" Description="Passes valid user name for lookup.">
		<SQLScript>
			<![CDATA[

declare                                                                   
	 @userName															nvarchar(75)

select top 1
		@userName = au.UserName
from
	sf.ApplicationUser au
where
	au.UserName not in ('JobExec', 'admin@helpdesk')
order by
	newid()

exec dbo.pApplicationUser#GetLoginProfile
	 @UserName	= @userName

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'dbo.pApplicationUser#GetLoginProfile'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo	 int					 = 0								-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText nvarchar(4000)										-- message text (for business rule errors)
	 ,@blankParm varchar(100)											-- tracks blank values in required parameters
	 ,@ON				 bit					 = cast(1 as bit)		-- used on bit comparisons to avoid multiple casts
	 ,@OFF			 bit					 = cast(0 as bit);	-- used on bit comparisons to avoid multiple casts

	set @UserName = @UserName; -- first 2 output variables can also provide input
	set @AuthenticationSystemID = @AuthenticationSystemID;
	set @FirstName = null; -- remaining are returned only		
	set @LastName = null;
	set @DisplayName = null;
	set @AppPassword = null;
	set @HashSalt = null;
	set @IsAccountOwner = null;

	begin try

		-- look up the user based on their user name if a @
		-- sign is passed in otherwise look up person by
		-- by registrant #

		if charindex('@', @UserName) > 0
		begin

			select
				@UserName								= au.UserName
			 ,@AuthenticationSystemID = au.AuthenticationSystemID
			 ,@FirstName							= p.FirstName
			 ,@LastName								= p.LastName
			 ,@DisplayName						= sf.fFormatDisplayName(p.LastName, isnull(p.CommonName, p.FirstName))
			 ,@AppPassword						= au.GlassBreakPassword
			 ,@HashSalt								= au.RowGUID
			from
				sf.ApplicationUser au
			join
				sf.Person					 p on au.PersonSID = p.PersonSID
			where
				au.UserName = isnull(@UserName, au.UserName) and au.AuthenticationSystemID = isnull(@AuthenticationSystemID, au.AuthenticationSystemID);

		end
		else
		begin

			select
				@UserName								= au.UserName
			 ,@AuthenticationSystemID = au.AuthenticationSystemID
			 ,@FirstName							= p.FirstName
			 ,@LastName								= p.LastName
			 ,@DisplayName						= sf.fFormatDisplayName(p.LastName, isnull(p.CommonName, p.FirstName))
			 ,@AppPassword						= au.GlassBreakPassword
			 ,@HashSalt								= au.RowGUID
			from
				dbo.Registrant r 
			join
				sf.Person					 p on r.PersonSID = p.PersonSID
			join
				sf.ApplicationUser au on p.PersonSID = au.PersonSID
			where
				r.RegistrantNo = @UserName;

		end

		if @UserName is null or @AuthenticationSystemID is null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'RecordNotFound'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
			 ,@Arg1 = 'sf.ApplicationUser'
			 ,@Arg2 = @UserName;

			raiserror(@errorText, 16, 1);  -- this error occurrs when an invalid login email is provided (not logged) in; turn down severity to avoid logging
		end;


		select
			@AuthenticationSystemID					AuthenticationSystemID
		 ,@UserName												UserName
		 ,@FirstName											FirstName
		 ,@LastName												LastName
		 ,@DisplayName										DisplayName
		 ,@AppPassword										AppPassword
		 ,@HashSalt												HashSalt
		 ,@OFF														IsAccountOwner
		 ,cast(0 as money)								CurrentBalance
		 ,cast(null as datetimeoffset(7)) LastPaidPeriodEndTime
		 ,cast(null as datetimeoffset(7)) LastEnabledLoginTime
		 ,@OFF														IsLoginBlocked
		 ,@OFF														IsCancelled
		 ,@OFF														IsActiveTrial
		 ,cast(null as datetimeoffset(7)) TrialExpiryTimeCTZ;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
