SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pSetup]
	 @Language                      char(2)       = 'en'                    -- language to install for
	,@Region                        varchar(10)   = 'all'										-- designator for locale to generate data for
	,@SystemCodeColumnTemplate			nvarchar(128) = N'{:TableName:}SCD'     -- template to identify system codes
	,@SysAdminUserName							nvarchar(75)														-- user name of base "System Administrator" for new installs
	,@ReturnDataSet									bit						= 1										    -- when 0 no dataset is returned
	,@StopOnMissingSproc            bit           = 1                       -- when 1 raise error if missing sproc for "system code"
	,@UTCOffset											char(6)				= null										-- time zone offset to write to configuration
as
/*********************************************************************************************************************************
Sproc    : Setup (master table data)
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : updates master tables with current starting product data set values
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund   | March		2012	| Initial Version
				 : Tim Edlund		| May			2014	| Updated the logic that sets the "CreateUser" column to use the domain from the 
																					@SysAdminUserName where provided. 
																					the relationship based on the default logic.
				: Tim Edlund		| Nov/Dec	2014	| Refined timezone setting logic originally implemented by Christian so that where an 
					Christian T											offset is not provided, the offset of the local database clock is used. This ensures 
																					datetime values inserted are consistent throughout the setup process. 
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure is responsible for setting up master table values required by the application.  Note that this procedure does NOT 
create sample data for testing or training.  The data added by this procedure is part of the product installation process.

The procedure is designed to be called for initial installation and for upgrades where new master table values may have been
added. Existing rows are never deleted by the procedure. A check is done before adding new rows to make sure the row does not 
already exist.  For columns where a default is provided, the column is not referenced in the insert statement so that the database 
default can be applied. API procedures - e.g. p<TableName>Insert or p<TableName>Default are NOT called; no additional logic is 
applied with the insert.

The inserts themselves are performed by subroutines. The subroutines are called through dynamic SQL so that this procedure does 
not require maintenance when new subroutines are added and removed as the data model evolves. This routine is a component of the
Softworks framework schema but ALL its subroutines must be placed in DBO and coded with values specific for the application.  It 
is possible that for some tables - e.g. sf.NamePrefix, sf.Gender - the values used by all applications will be the same, however, 
an application specific subroutine is still required for each table - stored in the DBO schema of the application's project.

One subroutine is required for each table and the subroutines must follow a naming convention in order to be found by this
parent procedure.  The naming convention is:  dbo.pSetup$<TableName> for tables in DBO, and dbo.pSetup$<schema>#<TableName> for 
tables in other schemas.  The dynamic SQL call depends on this naming convention being followed.  Examples:

	dbo.pSetup$CaseType						-- inserts setup data for the dbo.CaseType table
	dbo.pSetup$SF#NamePrefix			-- inserts setup data for the sf.NamePrefix table

Not all tables will require setup data and therefore not all will have a subroutine to call.  The absence of a subroutine for a 
table does not cause an error unless that table includes a column matching the @SystemCodeColumnTemplate.  Any column that 
contains a system code MUST have setup data, otherwise, the application will fail - since system code records cannot be added
by end users.  It is possible to suppress errors for missing procedures during development by passing the @StopOnMissingSproc
parameter as 0.

@Language Support
-----------------
For applications that support installation in different languages, the @Language parameter is provided and passed to each 
subroutine. While system code values are not different regardless of the language of installation, descriptive column values 
may be established for each language of installation. If the language requested is not found, each subroutine should install
records using its default language (English).

Output
------
By default a table listing each table name and the number of rows added is returned as output. The data set returned can be 
displayed by installation and upgrade UI's.  This behaviour can be suppressed where required by setting @ReturnDataSet = 0. 

Example:
--------

Note: Test harness code for this procedure must be executed from within product or client database projects!

exec sf.pSetup 
	 @ReturnDataSet = 0
	,@UTCOffset = '-7'
	,@SysAdminUserName = 'christianthordarson@gmail.com'

exec sf.pDBZap
	 @MyLogin         = 'aiadmin@ai'

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@i																	int																-- loop iterator - each table to process
		,@maxRow														int																-- loop limit - all tables to process
		,@schemaName												nvarchar(128)											-- schema of current table process
		,@tableName													nvarchar(128)											-- current table to process
		,@rowsInTable												int																-- count of rows in the table being processed
		,@setupUser												  nvarchar(75)											-- user assigned to audit insert and update audit columns
		,@subroutineName										nvarchar(128)											-- name of routine to search for and execute if found		
		,@dynSQL														nvarchar(1000)										-- buffer for dynamic SQL
		,@configParamSID										int																-- key of configuration parameter for time zone offset
		,@usageNotes												nvarchar(4000)										-- buffer for documentation for new config parameters
		
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
		)
		
	begin try
	
		-- set the system user to a value with a "setup" prefix to distinguish setup data from 
		-- "sample" data in development and testing databases; use domain from sys admin where
		-- provided
	
		if charindex('@', @SysAdminUserName) > 0																														
		begin
			set @setupUser = N'setup' + substring(@SysAdminUserName, charindex('@', @SysAdminUserName), 70)
		end
		else
		begin
			set @setupUser = N'setup@softworksgroup.com'	
		end

		-- update the time offset to the value passed in where provided to 
		-- ensure records created have correct time (especially "EffectiveTime")

		select 
			@configParamSID = cp.ConfigParamSID 
		from 
			sf.ConfigParam cp 
		where 
			cp.ConfigParamSCD = 'ClientTimeZoneOffset'

		if @configParamSID is null
		begin

			if @UTCOffset is null set @UTCOffset = cast(datename(tz,sysdatetimeoffset()) as char(6))			-- if no value was passed in, set to offset @server	

			set @usageNotes = 
				 N'This value is used to convert time values set at the database server with times provided by the end user. This option '
				+ 'is important where the database server and client workstations are not in the same time zone. The value must be entered '
				+ 'using a number of hours from Greenwich Mean Time.  For example, Mountain Standard Time is "-07:00" from GMT.'             

			exec sf.pConfigParam#Insert
				 @ConfigParamSCD		= 'ClientTimeZoneOffset'
				,@ConfigParamName		= 'Timezone Offset from GMT'
				,@ParamValue				= @UTCOffset
				,@DefaultParamValue = '-00:00'
				,@DataType					= 'varchar'
				,@MaxLength					= 6
				,@UsageNotes				= @usageNotes

		end
		else if @UTCOffset is not null																				-- only update the existing value if an offset was passed in
		begin																																	-- otherwise leave it as pre-existing value
			
			exec sf.pConfigParam#Update
				 @ConfigParamSID = @configParamSID
				,@ParamValue		 = @UTCOffset

		end

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
			t.TableName <> 'sysdiagrams'
		and
			t.TableName <> 'systranschemas'                                     -- exclude SSMS modeling tables 
		order by
			(
			case 
				when t.SchemaName = N'sf' and t.TableName = N'ConfigParam'				then	1
				when t.SchemaName = N'sf' and t.TableName = N'ApplicationEntity'  then  2
				when t.SchemaName = N'sf' and t.TableName = N'Message'            then  3
				when t.SchemaName = N'sf' and t.TableName = N'BusinessRule'       then  4
				when t.SchemaName = N'sf' and t.TableName = N'License'						then	5
				else														                                        9
			end
			)
			,t.TableLevel
			,(
			case 
				when t.SchemaName = N'sf' and t.TableName = N'ApplicationUserGrant'	then	1
				else																																			9
			end
			)
		
		set @maxRow = @@rowcount
		set @i			= 0
		
		while @i < @maxRow
		begin
		
			set @i += 1
			
			select 
				 @schemaName			= w.SchemaName
				,@tableName				= w.TableName
				,@subroutineName	= N'pSetup$' + (case when w.SchemaName = N'dbo' then '' else upper(w.SchemaName) + '#' end) + w.TableName				
			from
				@work w
			where
				w.ID = @i
				
			if exists(select 1 from sf.vRoutine r where r.SchemaName = 'dbo' and r.RoutineName = @subroutineName)
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

				if isnull(@rowsInTable,0) = 0 
				begin
					set @dynSQL = 'dbcc checkident( ''' + @schemaName + '.' + @tableName + ''', reseed, 1000000) with NO_INFOMSGS'
					exec sp_executesql  @dynSQL
				end

				set @dynSQL = N'exec dbo.' + @subroutineName 
					+ ' @SetupUser = '''		+ @setupUser 
					+ ''', @Language = '''	+ @Language
					+ ''', @Region = '''		+ @Region

				-- for the setup of the application user table, pass 1 additional parameter
				-- to insert the base system administrator (only applies if table is empty)

				if @subroutineName = 'pSetup$SF#ApplicationUser' 
				begin
					set @dynsql = cast(@dynSQL + ''', @SysAdminUserName = '''		+ @SysAdminUserName as nvarchar(1000))
				end

				set @dynSQL = cast(@dynSQL + '''' as nvarchar(1000))

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
				where 
					ID = @i
				
			end
			else if @StopOnMissingSproc = 1
			begin

				if exists
				(
					select 
						1 
					from 
						sf.vTableColumn tc 
					where 
						tc.SchemaName = @schemaName 
					and 
						tc.TableName = @tableName 
					and 
						tc.ColumnName = replace(@SystemCodeColumnTemplate, '{:TableName:}', tc.TableName)
				)
				begin

					exec sf.pMessage#Get
						 @MessageSCD    = 'MissingSetupSubroutine'
						,@MessageText   = @errorText output
						,@DefaultText   = N'A setup routine was not provided for system-code table "%1.%2".  Expected procedure name = "%3".'
						,@Arg1          = @SchemaName
						,@Arg2          = @TableName
						,@Arg3          = @SubroutineName

					raiserror(@errorText, 18, 1)
				end
			end			

			-- once configuration values are established, key data values required by other setup sprocs are 
			-- generated as a next step

			if @i = 1                                                           
			begin

				exec sf.pConfigParam#GenSetViews                                                                                          -- CREATE views to expose the configuration parameters as a flat table row

				set @setupUser = isnull(left(sf.fConfigParam#Value('SystemUser'),75), 'system@softworksgroup.com')                        -- generate for other "framework" tables that may be referenced in other setup subroutines
		
				set @i += 1
				update @work set InitialRowCount = (select count(1) from sf.ApplicationEntity) where SchemaName = N'sf' and TableName = N'ApplicationEntity'

				exec sf.pSetup$ApplicationEntity
					 @SetupUser = @setupUser
					,@Language  = @Language
					,@Product		= @Region

				update @work set EndingRowCount = (select count(1) from sf.ApplicationEntity) where SchemaName = N'sf' and TableName = N'ApplicationEntity'

				set @i += 1
				update @work set InitialRowCount = (select count(1) from sf.[Message]) where SchemaName = N'sf' and TableName = N'Message'
				--TODO: sf.message loader
				update @work set EndingRowCount = (select count(1) from sf.[Message]) where SchemaName = N'sf' and TableName = N'Message'

				set @i += 1
				update @work set InitialRowCount = (select count(1) from sf.BusinessRule) where SchemaName = N'sf' and TableName = N'BusinessRule'

				exec sf.pSetup$BusinessRule
					 @SetupUser = @setupUser
					,@Language  = @Language

				update @work set EndingRowCount = (select count(1) from sf.BusinessRule) where SchemaName = N'sf' and TableName = N'BusinessRule'

				set @i += 1
				update @work set InitialRowCount = (select count(1) from sf.BusinessRule) where SchemaName = N'sf' and TableName = N'DataSource'

			end
		
		end

		-- next execute any client specific setup procedures; these must 
		-- be called through a specific procedure in the ext schema: ext.pSetup

		if exists(select 1 from sf.vRoutine r where r.SchemaName = 'ext' and r.RoutineName = 'pSetup')
		begin
			
			set @dynSQL = N'exec ext.pSetup'
				+ ' @SetupUser = '''		+ @setupUser 
				+ ''', @Language = '''	+ @Language
				+ ''', @Region = '''		+ @Region + ''''

			exec sp_executesql
				@dynSQL

		end
		
		if @ReturnDataSet = 1
		begin
		
			select
				sf.fObjectNameSpaced(w.TableName) + (case when w.SchemaName = N'dbo' then '' else ' (' + w.SchemaName + ')' end)  TableName
				,(w.EndingRowCount - w.InitialRowCount)																					                                  RecordsAdded
			from
				@work w
			where
				w.IsSubroutineExecuted = 1
			order by
				 w.SchemaName
				,w.TableName
				
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
