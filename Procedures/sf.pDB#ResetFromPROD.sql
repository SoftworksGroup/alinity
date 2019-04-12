SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pDB#ResetFromPROD]
	@PreservedDomains varchar(500) = null -- list of domains that should NOT be overwritten by mailinator email assignments
as
/*********************************************************************************************************************************
Procedure	: Reset From PROD (backup)
Notice		: Copyright © 2017 Softworks Group Inc. 
Summary		: Resets user names and email addresses after a restore from a PRODuction backup
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Nov 2017		|	Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
** DROP THIS PROCEDURE FROM PRODUCTION INSTANCES **

This procedure is intended for use on staging instances as part of a process to refresh test instances with production data.
The procedure is to be run after a production instance has been restored - typically using sf.pDB#RestoreFromPROD.  

The procedure changes user email addresses and login ID's to "@mailinator" versions with a known (and simple) password.  These 
changes facilitate testing with realistic data. To avoid changing login addresses of client administrators, the list of their 
email domain must be passed in @PreservedDomains. Enter the list without "@" signs and use commas to separate multiple 
domains.  e.g. "softworks.ca, softworksgroup.com, gmail.com".  If this value is not passed then the ClientID is extracted 
from the database name and any usernames including the @clientID are not overwritten with mailinator addresses.

Some checking is done on the server name to avoid being called on production instances, however, the procedure should be 
specifically dropped (along with sf.pDBZap) in post deployment scripts.  Running the procedure on production instances will 
require IMMEDIATE restoring from backup since all user ID's and emails, and passwords are changed by the process

LIMITATIONS
-----------
The procedure has many dependencies on development procedures and policies in effect at Softworks at the time of the
procedure's development.  These include:

1) The primary application user for the database is named the same as the database itself (e.g. "clpnaTest").  

2) The procedure drops production triggers - if any - used for synchronizing data back to V5 of Alinity.  Since the
triggers were restored from PROD, the references are invalid and the triggers must be dropped.  The procedure will
only find and drop these triggers where the trigger name is like '%#Sync%'; 

The procedure calls 2 subroutines to handle resetting the logins and email addresses to @mailintor versions and for
adding system administrator accounts for current SGI staff. See also: sf.pDB#SetToMailinator and sf.pDB#SetSGILogins.

Call Syntax
-----------
exec sf.pDB#ResetFromPROD
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		int						= 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	nvarchar(4000)											-- message text (for business rule errors)    
	 ,@CRLF				nchar(2)			= char(13) + char(10) -- short hand for carriage return line feed pair
	 ,@dbName			varchar(50)		= db_name()						-- name of current database
	 ,@serverName varchar(50)		= @@servername				-- name of server
	 ,@i					int																	-- row counter
	 ,@script			nvarchar(2000);											-- buffer for dynamic SQL statements

	begin try

		if @serverName not like '%STGDB%' and @serverName not like '%Dev'
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'InvalidServer'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 operation is only permitted on staging and development servers. The procedure cannot be executed on server "%2"'
			 ,@Arg1 = 'Reset-From-Prod'
			 ,@Arg2 = @serverName;

			raiserror(@errorText, 18, 1);

		end;

		-- reset the service broker to remove the reference
		-- to the GUID from production which won't exist
		-- in the current instance

		set @script = N'use master;' + @CRLF + N'alter database ' + @dbName + N' set new_broker with rollback immediate;' + @CRLF;
		exec sys.sp_executesql @stmt = @script;
		print 'ok - service broker reset';

		-- change the DB Owner to the default admin on the test server (HARDCODED!)

		set @script = N'use ' + @dbName + N';' + @CRLF + N'alter authorization on database:: [' + @dbName + N'] to [sgiadmin];' + @CRLF;
		exec sys.sp_executesql @stmt = @script;
		print 'ok - database owner reset (sgiadmin)';

		-- create a user account for the existing application user for 
		-- this DB and assign as db owner if it doesn't already exist

		set @script = N'use ' + @dbName + N';' + @CRLF;

		if not exists (select 1 from sys .database_principals dp where dp.name = @dbName)
		begin
			set @script = cast(@script + @CRLF + 'create user ' + @dbName + ' for login ' + @dbName + ';' + @CRLF as nvarchar(2000));
		end;

		if not exists
		(
			select
				1
			from
				sys.database_role_members drm
			join
				sys.database_principals		rol on drm.role_principal_id	 = rol.principal_id and rol.name = 'db_owner'
			join
				sys.database_principals		mbr on drm.member_principal_id = mbr.principal_id and mbr.name = @dbName
		)
		begin
			set @script = cast(@script + 'alter role db_owner add member ' + @dbName + ';' as nvarchar(2000));
		end;

		exec sys.sp_executesql @stmt = @script;
		print 'ok - application user ' + @dbName + ' assigned as db_owner';

		-- next drop any table triggers that include the keyword "#Sync"
		-- since these have dependencies on other PROD databases

		set @script = N'';

		select
			@script += @CRLF + N'drop trigger ' + t.SchemaName + N'.' + t.TriggerName + N';'
		from
			sf.vTrigger t
		where
			charindex('#Sync', t.TriggerName) > 0;

		set @i = @@rowcount;

		if @i > 0
		begin
			exec sys.sp_executesql @stmt = @script;
			print 'ok - ' + ltrim(@i) + ' #Sync triggers dropped';
		end;

		-- next call a subroutine to assign @mailinator login ID's
		-- and a common password on the application user table

		print 'ok - initiating reset of user ID''s and logins';

		exec sf.pDB#SetToMailinator
			@PreservedDomains = @PreservedDomains;

		-- and finally ensure that softworks staff accounts
		-- are added to the application user table

		exec sf.pDB#SetSGILogins;

	end try
	begin catch
		print @script;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
