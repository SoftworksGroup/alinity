SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pDBZap]
		@MyLogin                 nvarchar(75)																	-- schema where tables to check are located
	 ,@ClientTestServerName		nvarchar(128)	 = N'none'											-- to pass name of a specific client test server
as
/*********************************************************************************************************************************
Procedure	: DELETES ALL RECORDS FROM THE DATABASE!!!
Notice		: Copyright © 2014 Softworks Group Inc. 
Summary		: utility procedure for use in development only - deletes ALL records from the database
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| Mar		2011  |	Initial version 
						Tim Edlund	| Nov		2012	| Updated to support specification of an allowed test server through @ClientTestServerName.
																				Modified dynamic SQL statement to delete 100 records at a time to avoid over-flowing log
																				for large record sizes (XML and document tables). 
----------------------------------------------------------------------------------------------------------------------------------

**** !!! DROP THIS PROCEDURE FROM PRODUCTION DEPLOYMENTS !!! ****

Comments	
--------

This procedure resets the database by removing all records. The procedure is intended for use in development and testing
databases only.  The procedure will only run on specific internal development servers - referenced by name in the 
code.  The @ClientTestServerName parameter allows a specific client testing server name to be enabled also.

In addition to being restricted by server name, the procedure also requires that the logged in user name match the 
@MyLogin parameter (e.g. tim.e@sgi or sgi\tim.e formats are accepted).  This is intended to prevent accidental start-up
of the procedure.

This procedure is not intended for use with production databases and should be removed from their deployments!

Transaction Log Full Error
--------------------------
This error arises because the procedure attempts to delete all records for a table in a single transaction. If the row-size or 
count of records is very large in a table, the space required to process the statement can exceed what has been allocated for the 
transaction log. 

The error handling in the procedure prints out the schema and table where the error occurred. 

If you get this error, you can work around it by manually executing the script below – changed for your table and key name – which 
deletes a set number of records per transaction rather than all transactions in the table. When the script runs successfully, 
re-try sf.pDBZap. 

declare
	 @deleteTrxSize				int = 50																					-- number of rows to delete in 1 transaction
	,@lastDeleted					int = -1																					-- count of rows deleted in last statement
	,@totalDeleted				int = 0																						-- count of rows deleted in total

while @lastDeleted <> 0
begin

	delete 
		dbo.SynopticTemplateVersion																						-- EDIT for your table name and key column!
	where
		SynopticTemplateVersionSID in
		(
			select top 50
				SynopticTemplateVersionSID
			from
				dbo.SynopticTemplateVersion
		)

	set @lastDeleted	= @@rowcount
	set @totalDeleted += @lastDeleted

end

select @totalDeleted TotalRowsDeleted

Example:
--------
exec sf.pDBZap
	 @MyLogin         = 'tim.e@sgi'

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@i																	int																-- loop iterator - each table to process
		,@maxRow														int																-- loop limit - all tables to process
		,@targetDBname											nvarchar(128)	= db_name()					-- name of the db currently connected
		,@currentLogin                      nvarchar(75)                      -- currently logged in user name
		,@schemaName												nvarchar(128)											-- schema of current table process
		,@tableName													nvarchar(128)											-- current table to process
		,@dynSQL														nvarchar(1000)										-- buffer for dynamic SQL
		,@rowsDeleted												int																-- counts rows deleted
		
	declare
		@work																table															-- tables to process
		(
			 ID																int								identity(1,1)
			,SchemaName												nvarchar(128)			not null
			,TableName												nvarchar(128)			not null
		)
		
	begin try
	
		-- check parameters

		if @@servername not like '%DEVDB__' and @@version not like '%Developer%Edition%' and @@serverName <> @ClientTestServerName 
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'DevServersOnly'
				,@MessageText   = @errorText output
				,@DefaultText   = N'This procedure (%1) can only be run on development servers.'
				,@Arg1					= N'sf.pDBZap'

			raiserror(@errorText, 18, 1)

		end

		-- compare current user to provided user

		set @MyLogin 	      = lower(@MyLogin)																	-- reformat: "SGI\tim.e" => "tim.e@sgi"
		set @i				      = charindex('\', @MyLogin)													
		if @i > 0			      set @MyLogin = substring(@MyLogin,@i + 1, 75) + '@' + left(@MyLogin,@i - 1)

		set @currentLogin 	= lower(suser_name())
		set @i				      = charindex('\', @currentLogin)													
		if @i > 0			      set @currentLogin = substring(@currentLogin,@i + 1, 75) + '@' + left(@currentLogin,@i - 1)

		if isnull(@MyLogin,N'x') <> @currentLogin
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'UserNameDoesNotMatch'
				,@MessageText   = @errorText output
				,@DefaultText   = N'The provided user name "%1" does not match logged in user "%2".'
				,@Arg1          = @MyLogin
				,@Arg2          = @currentLogin

			raiserror(@errorText, 18, 1)

		end

		-- process tables so that the Configuration parameter tables are processed first, then process in
		-- FK dependency order to ensure parent rows exist before child rows (see also sf.vTableLevel)
	
		insert
			@work
		(
			 SchemaName
			,TableName
		)
		select
			 t.SchemaName
			,t.TableName
		from
			sf.vTableLevel t
		where
			t.TableName not like '[_]%'                                         -- avoid temporary tables
		and
			not (t.SchemaName = 'dbo' and t.TableName = 'sysdiagrams')          -- avoid MS tables
		and
			not (t.SchemaName = 'sf' and t.TableName = 'License')								-- avoid License table
		order by
			 t.TableLevel desc                                                  -- process tables in FK dependency order
			,t.SchemaName
			,t.TableName
		
		set @maxRow = @@rowcount
		set @i			= 0
		
		while @i < @maxRow
		begin
		
			set @i += 1
			
			select 
				 @schemaName			= w.SchemaName
				,@tableName				= w.TableName
			from
				@work w
			where
				w.ID = @i
				
			-- create a dynamic command to delete 100 records at a time from 
			-- each table - this avoids overrunning log space for tables with 
			-- large records sizes (documents and XML)

			set @dynSQL	= N'delete ' + @schemaName + '.' + @tableName 
				+ ' where ' + @tableName + 'SID in (select top (1) ' + @tableName + 'SID from ' + @schemaName + '.' + @tableName + ')'

			set @rowsDeleted = 1

			while isnull(@rowsDeleted,0) > 0				
			begin

				exec sp_executesql 
						@dynSQL

				set @rowsDeleted = @@rowcount

			end

			-- reset identity value to SGI standard starting value

			set @dynSQL = 'dbcc checkident( ''' + @schemaName + '.' + @tableName + ''', reseed, 1000000) with NO_INFOMSGS'
			exec sp_executesql  @dynSQL
					
		end
		
	end try

	begin catch

		print ' '																															-- print debug information
		print replicate('=', 100)
		print (N'Error @ "' + @schemaName + '.' + @tableName + '"')
		print replicate('=', 100)
		print ' '

		exec @errorNo     = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
