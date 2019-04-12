SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pCreateDB]
	 @DBName													nvarchar(128)													-- name of the database to create
	,@SQLRoot													nvarchar(500) = null									-- storage path (defaults to registry lookup)
	,@DataFileSizeStartMB							smallint			= 10										-- starting size in megabytes for data files
	,@DataFileSizeGrowthMB						smallint			= 10										-- number of megabytes to increment data files on growth
	,@DataFileSizeMaxMB								smallint			= 1000									-- maximum size of each data file in megabytes ($DataFileSizeMax$=1G)
	,@DocFileSizeMaxMB								smallint			= 5000									-- maximum size of document file (stream) in megabytes
	,@LogFileSizeMaxMB								smallint			= 200										-- maximum size of log file in megabytes
as
/*********************************************************************************************************************************
Procedure	: Create Database
Notice		: Copyright © 2014 Softworks Group Inc. 
Summary		: Creates a database conforming to corporate standards for file groups, file names and locations
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-------------------------------------------------------------------------------------------
					: Tim Edlund	| May	2014		|	Initial version 
					: Tim Edlund	| Feb 2015		| Removed option to create login. Added logic to lookup default data path if not passed.
																				Replaced references to sub-folder FSData to DBData (since file stream creates sub-folder
																				automatically).  Updated documentation to describe logical and physical filenames created.
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------

This procedure creates a database that conform to corporate standards for file groups, file names and storage locations. The
database created includes 2 files for each file type, 2 log files, and 1 document storage area using file-stream architecture.
The initial file sizes along with growth increments and maximums may be passed explicitly but will otherwise default to corporate
standards for starting sizes and increments.  

The procedure supports SQL Sever 2008 and later version of SQL.  This procedure is NOT tested on version of SQL prior to 
2008!

The root path where files are to be located can be specified in the @SQLRoot parameter however all sub-folder names are hard 
coded!  The procedure will fail if the sub-folders do not exist.  The sub-folder names follow the corporate standard

...\DBData			-- for database data files
...\DBData			-- for file stream files
...\DBLogs			-- for log data

Note that all sub-folders must be located on the same logical drive letter.

The following file groups and logical and physical file names are created for the new database:

	FileGroup								Logical FileName			Physical FileName

	PRIMARY									DictionaryData1				[DBName]Dictionary1.mdf
	PRIMARY									DictionaryData2				[DBName]Dictionary2.ndf
	ApplicationIndexData		ApplicationNdx1				[DBName]Index1.ndf
	ApplicationIndexData		ApplicationNdx2				[DBName]Index2.ndf
	ApplicationRowData			ApplicationRow1				[DBName]Table1.ndf
	ApplicationRowData			ApplicationRow2				[DBName]Table2.ndf
	FullTextIndexData				FullTextIndex1				[DBName]FullText1.ndf
	FullTextIndexData				FullTextIndex2				[DBName]FullTest2.ndf
	N/A											DBLog1								[DBName]Log1.ldf
	N/A											DBLog2								[DBName]Log2.ldf
	FileStreamData					FileStreamData				[DBName]FS								<<- this is a folder not a file

In addition to creating the database with the standard structure, the Service Broker feature is also enabled. 

Example:
--------

<TestHarness>
	<Test Name="Test0001" IsDefault="true" Description="Creates 1 test database named Test0001. If the database name already exists
	it is dropped first.">
		<SQLScript>
			<![CDATA[
			
if exists(select 1 from sys.databases db where db.name = N'TEST0001')			-- drop test database if it already exists
begin

	alter database Test0001 set single_user with rollback immediate; 
	drop database Test0001;

end

execute sf.pCreateDB
	 @DBName = N'Test0001'

select
	db.name		DBName
from
	sys.databases db
where
	db.name = N'Test0001'

if exists(select 1 from sys.databases db where db.name = N'TEST0001')			-- clean-up after the test
begin
	alter database Test0001 set single_user with rollback immediate; 
	drop database Test0001;

end

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="Test0001"/>      
			<Assertion Type="ExecutionTime" Value="00:00:10" />
		</Assertions>
	</Test>

</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.pCreateDB'

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                         int = 0                             -- 0 no error, <50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)                      -- message text (for business rule errors)    
		,@ON                              bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
		,@OFF                             bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts
		,@blankParm												varchar(100)												-- buffer for checking for mandatory parameters
		,@script													nvarchar(4000)											-- buffer for dynamic SQL to create the new database
		,@i																int																	-- character index for string search
		,@isPre2012Version								bit	= 0															-- indicates if the server version is before SQL 2012

	begin try

		-- check parameters

		if @DBName is null set @blankParm = '@DBName'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		end

		if @@version like '%SQL Server 2008%' set @isPre2012Version = @ON

		-- ensure database name does not contain spaces or special characters

		if sf.fIsStringContentValid(@DBName, N'abcdefghijklmnopqrstuvwxyz0123456789') = @OFF
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'LettersNumbersOnly'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The %1 provided "%2" must contain only letters and numbers. The process cannot continue.'
				,@Arg1					= 'database name'
				,@Arg2					= @DBName

			raiserror(@errorText, 16, 1)

		end

		-- ensure the database name provided does not already exist

		if exists
		(
			select
				1
			from
				sys.databases db
			where
				db.name = @DBName
		)
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'DatabaseAlreadyExists'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The database name "%1" already exists. To recreate this database, delete it first.'
				,@Arg1					= @DBName

			raiserror(@errorText, 18, 1)

		end

		-- ensure sizing values are within expected range

		if (@DataFileSizeStartMB not between 1 and 1000)			
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'NotWithinExpectedRange'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The value provided for "%1" was not in the range expected (%2 - %3)'
				,@Arg1					= 'Data File Start Size'
				,@Arg2					= '1MB'
				,@Arg3					= '1GB'

			raiserror(@errorText, 18, 1)
		end
	
		if (@DataFileSizeGrowthMB	not between 1 and 25)
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'NotWithinExpectedRange'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The value provided for "%1" was not in the range expected (%2 - %3)'
				,@Arg1					= 'Data File Growth Increment'
				,@Arg2					= '1MB'
				,@Arg3					= '25MB'

			raiserror(@errorText, 18, 1)
		end

		if (@DataFileSizeMaxMB not between 100 and 1000)
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'NotWithinExpectedRange'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The value provided for "%1" was not in the range expected (%2 - %3)'
				,@Arg1					= 'Data File Maximum Size'
				,@Arg2					= '10MB'
				,@Arg3					= '1GB'

			raiserror(@errorText, 18, 1)
		end

		if (@DocFileSizeMaxMB			not between 100 and 50000)
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'NotWithinExpectedRange'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The value provided for "%1" was not in the range expected (%2 - %3)'
				,@Arg1					= 'Document Storage Maximum'
				,@Arg2					= '100MB'
				,@Arg3					= '50GB'

			raiserror(@errorText, 18, 1)
		end

		if (@LogFileSizeMaxMB	not between 1 and 1000)
		begin
			exec sf.pMessage#Get
				 @MessageSCD  	= 'NotWithinExpectedRange'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'The value provided for "%1" was not in the range expected (%2 - %3)'
				,@Arg1					= 'Log File Maximum'
				,@Arg2					= '1MB'
				,@Arg3					= '200MB'

			raiserror(@errorText, 18, 1)
		end

		-- if no path is provided, look it up in registry
		-- WARNING: method may not be supported in future versions !

		if @SQLRoot is null
		begin

			exec master.dbo.xp_instance_regread
				 N'HKEY_LOCAL_MACHINE'  
				,N'Software\Microsoft\MSSQLServer\MSSQLServer'  
				,N'DefaultData'
				,@SQLRoot output;

			set @i = sf.fCharIndexLast('\', @SQLRoot)														-- reduce path found to the root of the data path
			if  @i > 0 set @SQLRoot = left(@SQLRoot, @i)

		end

		set @SQLRoot = ltrim(rtrim(@SQLRoot))																	-- remove trailing space from path
		if right(@SQLRoot, 1) = N'\' set @SQLRoot = left(@SQLRoot, len(@SQLRoot) - 1)

		-- store the script template to create the database using corporate 
		-- standards for file group names, filenames and storage sub-folders

		if @isPre2012Version = @ON
		begin

			set @script = N'
				create database [$DBName$]
				on primary
				 (name = N''DictionaryData1'',    filename = N''$SQLPath$\DBData\$DBName$Dictionary1.mdf'', size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,(name = N''DictionaryData2'',    filename = N''$SQLPath$\DBData\$DBName$Dictionary2.ndf'', size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,filegroup [ApplicationIndexData] 
				 (name = N''ApplicationNdx1'',   filename = N''$SQLPath$\DBData\$DBName$Index1.ndf'',     size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,(name = N''ApplicationNdx2'',   filename = N''$SQLPath$\DBData\$DBName$Index2.ndf'',     size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,filegroup [ApplicationRowData]  DEFAULT 
				 (name = N''ApplicationRow1'',   filename = N''$SQLPath$\DBData\$DBName$Table1.ndf'',     size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,(name = N''ApplicationRow2'',   filename = N''$SQLPath$\DBData\$DBName$Table2.ndf'',     size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,filegroup [FileStreamData] contains filestream  default 
				 (name = N''FileStreamData'',    filename = N''$SQLPath$\DBData\$DBName$FS'') 
				,filegroup [FullTextIndexData] 
				 (name = N''FullTextIndex1'',    filename = N''$SQLPath$\DBData\$DBName$FullText1.ndf'',  size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,(name = N''FullTextIndex2'',    filename = N''$SQLPath$\DBData\$DBName$FullText2.ndf'',  size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				 log on
				 (name = N''DBLog1'',            filename = N''$SQLPath$\DBLogs\$DBName$Log1.ldf'',       size = 1MB, maxsize = $LogFileSizeMax$MB, filegrowth = 10%) 
				,(name = N''DBLog2'',            filename = N''$SQLPath$\DBLogs\$DBName$Log2.ldf'',       size = 1MB, maxsize = $LogFileSizeMax$MB, filegrowth = 10%);
			
				alter database [$DBName$] set enable_broker with rollback immediate;
				'

		end
		else
		begin

			set @script = N'
				create database [$DBName$]
				on primary
				 (name = N''DictionaryData1'',    filename = N''$SQLPath$\DBData\$DBName$Dictionary1.mdf'', size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,(name = N''DictionaryData2'',    filename = N''$SQLPath$\DBData\$DBName$Dictionary2.ndf'', size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,filegroup [ApplicationIndexData] 
				 (name = N''ApplicationNdx1'',   filename = N''$SQLPath$\DBData\$DBName$Index1.ndf'',     size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,(name = N''ApplicationNdx2'',   filename = N''$SQLPath$\DBData\$DBName$Index2.ndf'',     size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,filegroup [ApplicationRowData]  DEFAULT 
				 (name = N''ApplicationRow1'',   filename = N''$SQLPath$\DBData\$DBName$Table1.ndf'',     size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,(name = N''ApplicationRow2'',   filename = N''$SQLPath$\DBData\$DBName$Table2.ndf'',     size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,filegroup [FileStreamData] contains filestream  default 
				 (name = N''FileStreamData'',    filename = N''$SQLPath$\DBData\$DBName$FS'',             maxsize = $DocFileSizeMax$MB) 
				,filegroup [FullTextIndexData] 
				 (name = N''FullTextIndex1'',    filename = N''$SQLPath$\DBData\$DBName$FullText1.ndf'',  size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				,(name = N''FullTextIndex2'',    filename = N''$SQLPath$\DBData\$DBName$FullText2.ndf'',  size = $DataFileSizeStart$MB, maxsize = $DataFileSizeMax$MB, filegrowth = $DataFileSizeGrowth$MB) 
				 log on
				 (name = N''DBLog1'',            filename = N''$SQLPath$\DBLogs\$DBName$Log1.ldf'',       size = 1MB, maxsize = $LogFileSizeMax$MB, filegrowth = 10%) 
				,(name = N''DBLog2'',            filename = N''$SQLPath$\DBLogs\$DBName$Log2.ldf'',       size = 1MB, maxsize = $LogFileSizeMax$MB, filegrowth = 10%);
			
				alter database [$DBName$] set enable_broker with rollback immediate;
				'

		end
		-- replace the tokens in the template with the parameter values provided

		set @script = replace(@script, N'$DBName$',							@DBName)
		set @script = replace(@script, N'$SQLPath$',						@SQLRoot)
		set @script = replace(@script, N'$DataFileSizeStart$',	@DataFileSizeStartMB)
		set @script = replace(@script, N'$DataFileSizeMax$',		@DataFileSizeMaxMB)
		set @script = replace(@script, N'$DataFileSizeGrowth$',	@DataFileSizeGrowthMB)
		set @script = replace(@script, N'$DocFileSizeMax$',			@DocFileSizeMaxMB)
		set @script = replace(@script, N'$LogFileSizeMax$',			@LogFileSizeMaxMB)

		-- execute the statement

		exec sp_executesql @script

	end try

	begin catch
		print @script
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow																			-- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
