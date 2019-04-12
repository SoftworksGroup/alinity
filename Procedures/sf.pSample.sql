SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pSample]
	 @Language                      char(2)       = 'en'                    -- language to create sample data for
	,@Region                        varchar(10)   = 'all'										-- designator for locale to generate data for
	,@Quantity                      int           = 1000                    -- optional designator for volume to generate
	,@SystemCodeColumnTemplate			nvarchar(128) = N'{:TableName:}SCD'     -- template to identify system codes
	,@StopAtSchemaAndTableName			nvarchar(257)	= null										-- debugging aid to terminate before given table
	,@ReturnDataSet									bit						= 1										    -- when 0 no dataset is returned
	,@ClientTestServerName					nvarchar(128)	= N'none'									-- to pass name of a specific client test server
	,@isSTGIncluded									bit						= 0												-- by default the staging schema data is not generated
as
/*********************************************************************************************************************************
Sproc    : Sample data generation
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : updates tables with sample data for testing and training
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund   | April 2012	  | Initial Version
				 : Tim Edlund   | May   2012    | Updated to ensure sample data for sf.DocumentContext is generated last
				 : Tim Edlund   | June  2012    | Updated to support fine tuning of dependency order where FK level is the same
				 : Tim Edlund		| Nov		2012		| Updated to cause sf.RecordAudit sample data to be generated last. Updated to support 
																					specification of an allowed test server through @ClientTestServerName. 
				 : Kris Dawson	| Nov		2014		|	Updated to allow sample to run if there are no session records (new DB)
----------------------------------------------------------------------------------------------------------------------------------

**** !!! DROP THIS PROCEDURE FROM PRODUCTION DEPLOYMENTS !!! ****

Comments  
--------

This procedure is responsible for inserting data for testing and training.  Note that this procedure does NOT install the core
master table values required by the application.  That process is carried out by the procedure sf.pSetup.  

The data inserted by this procedure is NOT intended for production systems. This procedure is intended to be run on development 
and training databases only. The procedure raises an error if the db name does not end with "Dev", "Design", "Test", "UAT", 
"Demo", and "Debug".

The inserts themselves are performed by subroutines. The subroutines are called through dynamic SQL so that this procedure does 
not require maintenance when new subroutines are added and removed as the data model evolves. This routine is a component of the
Softworks framework schema but ALL its subroutines must be placed in the EXT schema and coded with values specific for the 
application. 

One subroutine is required for each table and the subroutines must follow a naming convention in order to be found by this
parent procedure.  The naming convention is:  ext.pSample$<TableName> for tables in EXT, and ext.pSample$<schema>#<TableName> for 
tables in other schemas.  The dynamic SQL call depends on this naming convention being followed.  Examples:

	ext.pSample$Patient           -- inserts Sample data for the ext.Patient  table
	ext.pSample$SF#Person         -- inserts Sample data for the sf.Person table

Not all tables will require Sample data and therefore not all will have a subroutine to call.  The absence of a subroutine for a 
table does not cause an error. 

@SystemCodeColumnTemplate
-------------------------
The procedure checks for a subroutine for tables which do NOT have "system code" columns.  System codes tables must be populated
through the sf.pSetup procedure and do not support "sample" or additional data.  The @SystemCodeColumnTemplate parameter is 
required in order to determine which tables contain a column matching the "system code" definition for the given database
design. Other tables that do not contain system codes - but which may have already been populated to some extent by pSetup, are
included for sample data generation. (E.g. the sf.Person table receives records from pSetup for the initial "SysAdmin" user).

@Language Support
-----------------
For applications that support installation in different languages, the @Language parameter is provided and passed to each 
subroutine. While system code values are not different regardless of the language of installation, descriptive column values 
may be established for each language of installation. If the language requested is not found, each subroutine should install
records using its default language (English).

@Region
-------
Some sample data generators may support insert of data that is regional.  For example, sample data for US installation may
include different values than if the installation were for a Canadian client.  More fine grained differences may also be 
supported by the subroutines for different states and provinces.  The @Region parameter is optional but may be provided for
passing to the subroutines.

@Quantity
---------
This is an optional numeric value that is passed to subroutines and can be used to control the volume of records generated.  The
value will typically apply to only the primary entities of the application - e.g. "Person" or "Organization" records - and the
volumes of all other entities will be factored based on those.

@ClientTestServerName
---------------------
The procedure is intended for use in development and testing databases only.  The procedure will only run on specific internal 
development servers - referenced by name in the code.  The @ClientTestServerName parameter allows a specific client testing 
server name to be enabled also.

Output
------
By default a table listing each table name and the number of rows added is returned as output. The data set returned can be 
displayed by installation and upgrade UI's.  This behaviour can be suppressed where required by setting @ReturnDataSet = 0. 

Example:
--------

exec sf.pSample @ReturnDataSet = 0

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@targetDBname											nvarchar(128)		= db_name()				-- name of the db currently connected
		,@i																	int																-- loop iterator - each table to process
		,@maxRow														int																-- loop limit - all tables to process
		,@schemaName												nvarchar(128)											-- schema of current table process
		,@tableName													nvarchar(128)											-- current table to process
		,@rowsInTable												int																-- count of rows in the table being processed
		,@SampleUser												nvarchar(75)											-- user assigned to audit insert and update audit columns
		,@subroutineName										nvarchar(128)											-- name of routine to search for and execute if found		
		,@dynSQL														nvarchar(1000)										-- buffer for dynamic SQL
		,@dynSQLParms                       nvarchar(1000)                    -- parameter definitions for dynamic SQL
		,@startTime													datetime2													-- starting time of 1 table's processing
		
	declare
		@work																table															-- tables to process
		(
			 ID																int								identity(1,1)
			,SchemaName												nvarchar(128)			not null
			,TableName												nvarchar(128)			not null
			,TableLevel                       int               not null
			,IsSubroutineExecuted							bit 							not null	      default cast(0 as bit)
			,InitialRowCount									int								not null	      default 0
			,EndingRowCount										int								not null	      default 0
			,ProcessingMinutes								int								not null				default 0
		)
		
	begin try

		-- check parameters, procedure may only run if it is on development server
		if 
			@@servername not like '%DEVDB__'  and @@version not like '%Developer%Edition%' 
		and 
			@@serverName <> @ClientTestServerName
		and 
			exists(select top (1) ApplicationUserSessionSID from sf.ApplicationUserSession)
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'DevServersOnlySample'
				,@MessageText   = @errorText output
				,@DefaultText   = N'This procedure (%1) can only be run on development servers.'
				,@Arg1					= N'sf.pSample'

			raiserror(@errorText, 18, 1)

		end

		if isnull(@Quantity,0) <= 0 set @Quantity = 1000                      -- quantity is required by some subroutines
	
		-- set the system user to a known value for the installation; do not change this 
		-- value as it is required in order to distinguish "Sample" data from "setup" data 
		-- in development and testing databases
	
		set @SampleUser = N'sample@softworksgroup.com'	
	
		-- process tables so that the Configuration parameter tables are processed first, other SF 
		-- tables with special loaders are published next, then process remaining tables in FK
		-- dependency order to ensure parent rows exist before child rows (see also sf.vTableLevel)
	
		insert
			@work
		(
			 SchemaName
			,TableName
			,TableLevel
		)
		select
			 t.SchemaName
			,t.TableName
			,t.TableLevel
		from
			sf.vTableLevel t
		where
			t.TableName not like '[_]%'                                         -- avoid temporary tables
		and
			t.SchemaName <> 'CDC'                                               -- avoid all change data capture tables
		and
			(t.SchemaName <> 'stg' or @isSTGIncluded = cast(1 as bit))					-- avoid stg schema unless specifically requested
		and
			t.TableName <> 'sysdiagrams'
		and
			t.TableName <> 'systranschemas'                                     -- exclude SSMS modeling tables 
		and
			not exists
			(
				select 
					1 
				from 
					sf.vTableColumn tc 
				where 
					tc.SchemaName = t.SchemaName
				and 
					tc.TableName = t.TableName 
				and 
					tc.ColumnName = replace(@SystemCodeColumnTemplate, '{:TableName:}', tc.TableName)
			)
		order by
		 (
			case 
				when t.SchemaName = N'sf' and t.TableName = N'Document'						then  999	
				when t.TableName = 'DocumentContext'      then 9999								-- has no dependencies defined in RI but must generate last
				when t.TableName = 'RecordAudit'					then 9999								-- record audit data requires all other table data first
				else t.TableLevel
			end
			)
		 ,
			(
			case 
				when left(t.TableName,15)		= 'ApplicationUser'     then 0				-- break ties on table level so that user info generates first
				when right(t.TableName,12)	= 'StatusChange'        then 0
				when charindex('Provider', t.TableName) > 0					then 0
				else 100
			end																																  
			)
		,t.TableLevel

		set @maxRow = @@rowcount
		set @i			= 0
		
		while @i < @maxRow
		begin
		
			set @i += 1
			set @startTime = sysdatetime()
			
			select 
				 @schemaName			= w.SchemaName
				,@tableName				= w.TableName
				,@subroutineName	= N'pSample$' + (case when w.SchemaName = N'dbo' then '' else upper(w.SchemaName) + '#' end) + w.TableName				
			from
				@work w
			where
				w.ID = @i
	
			-- check for debug stop point				

			if @schemaName + '.' + @tableName = @StopAtSchemaAndTableName
			begin
				print (N'Processing stopped for debugging at: ' + @StopAtSchemaAndTableName)
				set @maxRow = -1
				break
			end
				
			if exists(select 1 from sf.vRoutine r where r.SchemaName = 'ext' and r.RoutineName = @subroutineName)
			begin
			
				-- count rows in table before subroutine call and update the work table
				-- with the value; reset identity if table is empty
	
				set @dynSQL	= N'select @rowsInTable = count(1) from ' + @schemaName + '.' + @tableName

				exec sp_executesql 
					 @dynSQL
					,N'@rowsInTable int output'
					,@rowsInTable output

				update 
					@work 
				set 
					InitialRowCount = isnull(@rowsInTable,0) 
				where 
					ID = @i

				-- if there are no rows in the table, reset the identity to the SGI standard starting value

				if isnull(@rowsInTable,0) = 0 
				begin
					set @dynSQL = 'dbcc checkident( ''' + @schemaName + '.' + @tableName + ''', reseed, 1000000) with NO_INFOMSGS'
					exec sp_executesql  @dynSQL
				end

				set @dynSQL = N'exec ext.' + @subroutineName 
					+ ' @SampleUser = ''' + @SampleUser   + ''''
					+ ',@Language   = ''' + @Language     + ''''
					+ ',@Region     = ''' + @Region       + ''''
					+ ',@Quantity   = ' + convert(varchar(10), @Quantity)

				-- execute the SQL then obtain the ending count and store it

				exec sp_executesql
					@dynSQL

				set @dynSQL	= N'select @rowsInTable = count(1) from ' + @schemaName + '.' + @tableName

				exec sp_executesql 
					 @dynSQL
					,N'@rowsInTable int output'
					,@rowsInTable output
				
				update 
					@work 
				set 
					 EndingRowCount				= isnull(@rowsInTable,0) 
					,IsSubroutineExecuted = 1
					,ProcessingMinutes		= datediff(minute, @startTime, sysdatetime())
				where 
					ID = @i
				
			end

		end
		
		if @ReturnDataSet = 1
		begin
		
			select
				sf.fObjectNameSpaced(w.TableName) + (case when w.SchemaName = N'dbo' then '' else ' (' + w.SchemaName + ')' end)  TableName
				,(w.EndingRowCount - w.InitialRowCount)																					                                  RecordsAdded
				,w.ProcessingMinutes
			from
				@work w
			where
				w.IsSubroutineExecuted = 1
			order by
				 w.SchemaName
				,w.TableName
				
			if @maxRow = -1 select N'Processing stopped for debugging BEFORE: ' + @StopAtSchemaAndTableName
				
		end
	
	end try

	begin catch
	
		-- list contents in work table before rolling back to provide
		-- some debugging information to the caller
	
		select
			 w.ID									
			,w.SchemaName					
			,w.TableName
			,w.TableLevel					
			,w.InitialRowCount		
			,w.EndingRowCount		
			,w.ProcessingMinutes	
			,w.IsSubroutineExecuted
		from
			@work w
		order by
			w.ID

		print @dynSQL
			
		exec @errorNo = sf.pErrorRethrow
		
	end catch

	return(@errorNo)

end
GO
