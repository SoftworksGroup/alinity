SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pDB#SetToMailinator]
(
	@PreservedDomains varchar(500) = null -- list of domains that should NOT be overwritten - do not include "@" e.g. "softworks.ca"
 ,@IsRedo						bit = 0							-- set to 1 to allow existing mailinator addresses to be regenerated (use after scrambling names)
)
as
/*********************************************************************************************************************************
Procedure	: Set To Mailinator
Notice		: Copyright © 2017 Softworks Group Inc. 
Summary		: Sets application-user login ID's and email addresses to @mailinator addresses and sets a common password
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Nov 2017		|	Initial version 
					: Tim Edlund	| Aug 2018		| Added parameters to enable sproc to be called after names are scrambled to reassign
					: Russ Poirier| Mar 2019		|	Added where clause to check for Admin grants so usernames are not changed
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
** DROP THIS PROCEDURE FROM PRODUCTION INSTANCES **

This procedure is intended for use on staging instances only.  It is designed to be called after a production backup has been
restored onto the test instance.  The procedure updates user logins (sf.ApplicationUser.UserName) and email addresses 
(sf.PersonEmailAddress) with an "@mailinator" address.  A common password is assigned to each account.  These changes facilitate 
testing including testing of email functions without the risk of sending test messages to actual end-user email accounts.

Login ID's using the @softworks% domain or the client domain (e.g. @clpna%) are NOT changed to mailinator accounts to make it
easier for staff to participate in testing.  Note, however, that the password for these accounts IS changed to the standard
password which is:  [clientID]@als.

To avoid changing login addresses of client administrators, the list of their email domain must be passed in @PreservedDomains.
Enter the list without "@" signs and use commas to separate multiple domains.  eg. "softworks.ca, softworksgroup.com, gmail.com".
If this value is left blank a domain name of "@[clientID].%" is assumed. If the database name is clpnaTest for example, the
client ID = 'CLPNA' and any user name with a domain like '@clpna.%' is not reset.

Some checking is done on the server name to avoid being called on production instances, however, the procedure should be 
specifically dropped (along with sf.pDBZap) in post deployment scripts.  Running the procedure on production instances will 
require IMMEDIATE restoring from backup since all user ID's and emails, and passwords are changed by the process

LIMITATIONS
-----------
The procedure has many dependencies on development procedures and policies in effect at Softworks at the time of the
procedure's development.  These include:

1) Specific server name patterns identified as development, testing or staging servers (see code below).  Any other 
server name pattern blocks the procedure from running.

2) The database name must include the client acronym and a limited number of additional words that are replaced.  If a "test" or 
"V6" extension to that name is included - for example:  "clpnaTest", "clpnaTestV6", or "AlinityCLPNA" and "CLPNASynoptec" all 
resolve to the client ID of "clpna" and the common password of "clpna@als".

To create the unique email addresses and logins the existing first name, first initial of the last name and 3 digits  from the
sf.Person.PersonSID column are combined with the "@mailinator.com" suffix. This method does not always result in unique ID's
for every profile.  Where a login/email address would result in a duplicate, a second occurrence is not created
and that login/email is left unchanged.  This impacts a very small number of records and does not impact testing.

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo				int						= 0								-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText			nvarchar(4000)									-- message text (for business rule errors)    
	 ,@ON							bit						= cast(1 as bit)	-- used on bit comparisons to avoid multiple casts
	 ,@dbName					varchar(50)		= db_name()				-- name of current database
	 ,@passwordString varchar(20)											-- common password to set all accounts to
	 ,@serverName			varchar(50)		= @@servername;		-- name of server

	declare @work table (ApplicationUserSID int not null, NewEmail nvarchar(75) not null);

	begin try

		if @serverName not like '%STGDB%' and @serverName not like '%Dev'
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'InvalidServer'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 operation is only permitted on staging and development servers. The procedure cannot be executed on server "%2"'
			 ,@Arg1 = 'Set-To-Mailinator'
			 ,@Arg2 = @serverName;

			raiserror(@errorText, 18, 1);

		end;

		-- load a work table with the new login ID values derived based on the first name
		-- 3 digits of the SID, first letter of last name + @mailinator

		if @PreservedDomains is null
		begin
			set @PreservedDomains = '[!NONE]'
		end

		insert
			@work (NewEmail, ApplicationUserSID)
		select -- next look for duplicates
			z.NewEmail
		 ,min(z.ApplicationUserSID) ApplicationUserSID	-- take first occurrence in case of duplicate
		from
		(
			select
				x.NewEmail
			 ,x.ApplicationUserSID
			 ,case
					when sf.fIsStringContentValid(x.NewEmail, N'abcdefghijklmnopqrstuvwxyzÇéâêîôûàèùëïü0123456789@.-_') = 0 -- check that resulting email address is valid
							 or
							 (
								 charindex('@', x.NewEmail) = 0 and x.NewEmail <> N'SysAdmin' and x.NewEmail <> N'JobExec' and x.NewEmail <> N'admin@helpdesk'
							 ) then 'No'
					else 'Yes'
				end																																	ValidUserName
			 ,case when sf.fIsValidEmail(x.NewEmail) = 0 then 'No' else 'Yes' end ValidEmailAddress
			from
			(
				select
					lower(replace(replace(replace(replace(replace(replace(replace(p.FirstName, ' ', ''), '.', ''), '_', ''), '''', ''), '(', ''), ')', ''), '!', '')
								+ '.' + left(p.LastName, 1)
							 ) + right(ltrim(p.PersonSID), 3) + '@mailinator.com' NewEmail
				 ,au.ApplicationUserSID
				from
					sf.ApplicationUser au
				join
					sf.Person					 p on au.PersonSID = p.PersonSID
				left outer join
					sf.ApplicationUserGrant aug	on	au.ApplicationUserSID = aug.ApplicationUserSID
				left outer join
					sf.ApplicationGrant ag	on	aug.ApplicationGrantSID = ag.ApplicationGrantSID
				where
					(au.UserName not like '%@mailinator.com' or @IsRedo = @ON)
					and au.UserName not in ('support@softworksgroup.com', 'JobExec', 'admin@helpdesk', 'SysAdmin')
					and @PreservedDomains not like '%' + sf.fStringSegment(au.UserName, '@', 2) + '%' -- avoid administrator email addresses
					and au.UserName not like '%@softworks.ca'
					and au.UserName not like '%@' + replace(db_name(), 'test', '') + '%' -- avoids domains matching base name of db: - e.g clpnaTest -> %@clpna%
					and	ag.ApplicationGrantSCD not like 'ADMIN.%'
			) x
		) z
		where
			z.ValidUserName = 'yes' and z.ValidEmailAddress = 'yes'
		group by
			z.NewEmail;

		-- update the user name to the new email address created
		-- on each profile

		update
			au
		set
			au.UserName = w.NewEmail
		from
			sf.ApplicationUser au
		join
			@work							 w on au.ApplicationUserSID = w.ApplicationUserSID
		where
			au.UserName <> w.NewEmail;

		print 'ok - ' + ltrim(@@rowcount) + ' user profiles updated with new login';

		-- now update email address to match the username created

		update
			pea
		set
			pea.EmailAddress = cast(au.UserName as varchar(75))
		from
			sf.PersonEmailAddress pea
		join
			sf.ApplicationUser		au on pea.PersonSID = au.PersonSID
		where
			pea.IsPrimary = @ON and pea.EmailAddress <> au.UserName and au.UserName not in ('support@softworksgroup.com', 'JobExec', 'admin@helpdesk', 'SysAdmin');

		-- update to the common password on all accounts

		set @passwordString = lower(replace(replace(@dbName, 'Test', ''), 'V6', '') + '@als');

-- SQL Prompt formatting off
		update
			sf.ApplicationUser
		set
			GlassBreakPassword = sf.fHashString(cast(RowGUID as nvarchar(50)), @passwordString)
		where
			GlassBreakPassword <> sf.fHashString(cast(RowGUID as nvarchar(50)), @passwordString)
		and
			UserName not in ('support@softworksgroup.com', 'JobExec', 'admin@helpdesk', 'SysAdmin');
-- SQL Prompt formatting on

		print 'ok - ' + ltrim(@@rowcount) + ' passwords updated to "' + @passwordString + '"';

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
