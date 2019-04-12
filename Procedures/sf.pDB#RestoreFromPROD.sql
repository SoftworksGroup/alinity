SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pDB#RestoreFromPROD
as
/*********************************************************************************************************************************
Procedure	: Restore (backup) from PROD
Notice		: Copyright © 2017 Softworks Group Inc. 
Summary		: Restores a production backup to refresh the test system 
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Nov 2017		|	Initial version 
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
** DROP THIS PROCEDURE FROM PRODUCTION INSTANCES **

This procedure is intended for use on staging instances only to refresh test instances with production data.  Note that after
this procedure completes the procedure sf.pDB#ResetFromPROD must be run to change user email addresses and login ID's to 
"@mailinator" versions with a known (and simple) password.  

Some checking is done on the server name to avoid being called on production instances, however, the procedure should be 
specifically dropped (along with sf.pDBZap) in post deployment scripts. 

LIMITATIONS
-----------
The procedure has many dependencies on development procedures and policies in effect at Softworks at the time of the
procedure's development.  These include:

1) Specific server name patterns identified as development, testing or staging servers (see code below).  Any other 
server name pattern blocks the procedure from running.

2) The backup to be restored must have a specific name:  "<clientID>PROD.bak".  The clientID must be present in the 
database name.  For example, if the client ID is "clpna" then the backup file must be called "clpnaPROD.bak" regardless
of what the full database name is on the production side. 

3) The name of the backup file to restore is derived based on the name of the current database onto which the backup
will be restored.  The test/staging database name then must include the client acronym and a limited number of additional
words that are replaced.  If a "test" or "V6" extension to that name is included - for example:  "clpnaTest", 
"clpnaTestV6", or "AlinityCLPNA" and "CLPNASynoptec" all resolve to the client ID of "clpna" and the assumed database
backup name to restore of "clpnaPROD.bak".

4) The file groups and file names to be restored must exactly match the groups and names on the test instance.  In order
to generate the restore command the local database file group structure is used as the basis. If a file name is added in
production which does not exist on the test database, this procedure will fail.  To resolve, add the new file name to 
the test database first and then re-run.

Call Syntax
-----------

-- !! FIRST ensure a current backup of PROD is available on the current server
-- AND that the backup is named <ClientID>Prod.bak

use myDB
go
exec sf.pDB#RestoreFromPROD
go
use myDB
go
exec sf.pDB#ResetFromPROD
go

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		int						= 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	nvarchar(4000)											-- message text (for business rule errors)    
	 ,@CRLF				nchar(2)			= char(13) + char(10) -- short hand for carriage return line feed pair
	 ,@dbName			varchar(50)		= db_name()						-- name of current database
	 ,@serverName varchar(50)		= @@servername				-- name of server
	 ,@backupName varchar(100)												-- name of backup file to restore
	 ,@script			nvarchar(2000);											-- buffer for dynamic sql statements

	begin try

		if @serverName not like '%STGDB%' and @serverName not like '%Dev'
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'InvalidServer'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The %1 operation is only permitted on staging and development servers. The procedure cannot be executed on server "%2"'
			 ,@Arg1 = 'Restore-From-Prod'
			 ,@Arg2 = @serverName;

			raiserror(@errorText, 18, 1);

		end;

		-- create commands to take the current database offline, restore from the
		-- production backup, and then bring the database back online (executed from master)

		set @backupName = replace(replace(@dbName, 'Test', ''), 'V6', '') + 'PROD.bak';

		set @script = 'use master; ' + @CRLF + @CRLF + 'alter database ' + @dbName + ' set offline with rollback immediate;' + @CRLF;

		set @script =
			cast(@script + @CRLF + 'restore database ' + @dbName + @CRLF + 'from disk = N''Z:\Backup\' + @dbName + '\' + @backupName + '''' + @CRLF + 'with' + @CRLF
					 + '  file = 1' as nvarchar(2000));

		select
			@script = cast(@script + @CRLF + '  ,move N''' + fs.LogicalFileName + ''' to N''' + fs.FileName + '''' as nvarchar(2000))
		from	(
						select top (100)
							fs.LogicalFileName
						 ,fs.FileName
						from
							sf.vFileSpace fs
						order by
							fs.DataSpaceID	-- REQUIRES THAT THE PROD backup use the same file-groups and filenames as the current DB!
						 ,fs.FileID
					) fs;

		set @script = cast(@script + @CRLF + '  ,nounload' as nvarchar(2000));
		set @script = cast(@script + @CRLF + '  ,replace' as nvarchar(2000));
		set @script = cast(@script + @CRLF + '  ,stats = 5;' + @CRLF as nvarchar(2000));
		set @script = cast(@script + @CRLF + 'alter database ' + @dbName + ' set online with rollback immediate;' + @CRLF as nvarchar(2000));
		set @script = cast(@script + @CRLF + 'use ' + @dbName + ';' + @CRLF as nvarchar(2000));

		print 'ok - initiating restore of ' + @backupName;
		print replicate('-', 75);
		exec sys.sp_executesql @stmt = @script; -- execute the restore
		print replicate('-', 75);
		print 'ok - restore of ' + @backupName + ' complete';

	end try
	begin catch
		print @script;
		exec @errorNo = sf.pErrorRethrow; -- catch the error, rollback if pending, and re-throw
	end catch;

	return (@errorNo);

end;
GO
