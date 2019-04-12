SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sf.pDB#Resize
	@BaseFreeRatio		decimal(4, 2)					-- factor of free space to target for base data 
 ,@SysFreeRatio			decimal(4, 2)					-- factor of free space to target for system 
 ,@DocFreeRatio			decimal(4, 2)					-- factor of free space to target for documents (file-stream) 
 ,@CurrentFileSlack decimal(4, 2) = 0.02	-- factor of slack to allow in current file sizes (0.0 to leave unchanged, 0.10 for 10% slack)
 ,@DebugLevel				tinyint = 0						-- set to 1 to print script to console, set to 2+ to avoid execution of resize script
 ,@ReduceMaxSize		bit = 1								-- when 0 any recommendation that results in reducing a max file size is ignored
as
/*********************************************************************************************************************************
Sproc    : Database Resize (files)
Notice   : Copyright © 2018 Softworks Group Inc.
Summary  : This procedure prints or executes a script to resize database files to match target free space ratios
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + ------------------------------------------------------------------------------------
 				: Tim Edlund          | Dec 2018		|	Initial version

Comments	
--------
This procedure is used to resize databases to target free-space targets.  The procedure generates validates the resulting file
sizes for overall file size and comparison of new file sizes to maximum sizes for the file group.  Any errors prevent the
script from executing or being returned.

If no errors are detected a script to resize database files is produced.  The basis of the calculation of file sizes is the table
function sf.fDBSpace#Recommendations. 

the @ReduceMaxSize parameter can be passed as 0 (OFF) to avoid having any existing maximum file size reduced.  Note that in the
case the max size is unlimited however, an error will still result.  In upgrade processes maximum file sizes may be increased 
to 100 free space 

Where @DebugLevel = 0, the procedure returns a ResultMessage appropriate for display in the user interface. 

Note that DEFAULT values are NOT provided for the 3 free space targets.  Analysis is required to set these values correctly
and the sf.fDBSpace#Recommendations() table function can be used to provide support.  Databases in the first few years of use 
which are still growing percentage wise rapidly will require higher settings than mature databases. A starting point where data 
growth is consistent from year to year, is to take the current database size in each file group type and divide by the years of 
use and add that amount for the next year as a percentage. Typically targeting resizing once per year is recommended. When using 
this method ensure all major business cycles - e.g. "Renewal" for Alinity databases, have occurred in each year counted in the 
analysis.   

While the procedure can be executed after shrinking the database first, that step is not necessary.  Periodic re-organizing of the 
database is, however, recommended as a separate process.

Note that when resizing databases restored from PROD to test systems, the database can often be reduced in size for at least
max-size values but also for current file sizes if significant slack exists.  The test case below shows good settings for
reducing size of databases on test servers (assuming no major data will be added in the TEST system).

Known Limitations
-----------------
This procedure depends on file groups which following SGI naming conventions and underlying base views for extraction of 
file-group information.

Example
-------
<TestHarness>
  <Test Name = "Minimal" IsDefault ="true" Description="Executes the procedure resizing the database for only 5% growth">
    <SQLScript>
      <![CDATA[

dbcc shrinkdatabase(0) with no_infomsgs

exec sf.pDB#Resize
	@BaseFreeRatio = 0.20
 ,@SysFreeRatio = 0.20
 ,@DocFreeRatio = 0.20
 ,@CurrentFileSlack = 0.02
-- ,@DebugLevel = 1

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:05:00"/>
    </Assertions>
  </Test>
  <Test Name = "Debug" Description="Executes the procedure resizing the database using DEBUG output. Script NOT executed to resize.">
    <SQLScript>
      <![CDATA[

select
	*
from
	sf.fDBSpace#Recommendations(0.20, 0.20, 0.20, 0.02) dsr
order by
	dsr.FileGroup;

exec sf.pDB#Resize
	@BaseFreeRatio = 0.20
 ,@SysFreeRatio = 0.20
 ,@DocFreeRatio = 0.20
 ,@CurrentFileSlack = 0.02
 ,@DebugLevel = 2;

		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>
      <Assertion Type="ExecutionTime" Value="00:01:00"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pDB#Resize'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		int						 = 0										-- 0 no error, <50000 SQL error, else business rule
	 ,@errorText	nvarchar(4000)												-- message text for business rule errors
	 ,@blankParam nvarchar(50)													-- tracks blank mandatory parameters
	 ,@ON					bit						 = cast(1 as bit)				-- constant for bit comparisons = 1
	 ,@CRLF				nchar(2)			 = char(13) + char(10)	-- carriage return + line feed characters
	 ,@resizeSQL	nvarchar(4000) = N''									-- buffer for dynamic SQL
	 ,@fileGroup	nvarchar(128)													-- file group for error messages
	 ,@fileCount	int;																	-- count of files requiring resizing

	begin try

-- SQL Prompt formatting off
		if @BaseFreeRatio is null set @blankParam = '@BaseFreeRatio'
		if @SysFreeRatio	is null set @blankParam = '@SysFreeRatio'
		if @DocFreeRatio	is null set @blankParam = '@DocFreeRatio'
-- SQL Prompt formatting on

		if @blankParam is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'BlankParameter'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
			 ,@Arg1 = 'Parameter';

			raiserror(@errorText, 18, 1);

		end;

		-- set missing defaults if any

		if @CurrentFileSlack is null set @CurrentFileSlack = 0.02;

		-- validate parameters and underlying starting file structure

		if @BaseFreeRatio > 1.0 or @BaseFreeRatio < 0.02
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NotInRange'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" value is not in the allowed range (%2 - %3).'
			 ,@Arg1 = 'Base Data Free Ratio'
			 ,@Arg2 = 0.02
			 ,@Arg3 = 1.00;

			raiserror(@errorText, 16, 1);

		end;
		else if @SysFreeRatio > 1.0 or @SysFreeRatio < 0.02
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NotInRange'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" value is not in the allowed range (%2 - %3).'
			 ,@Arg1 = 'System Data Free Ratio'
			 ,@Arg2 = 0.02
			 ,@Arg3 = 1.00;

			raiserror(@errorText, 16, 1);

		end;
		else if @DocFreeRatio > 2.0 or @DocFreeRatio < 0.02
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NotInRange'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" value is not in the allowed range (%2 - %3).'
			 ,@Arg1 = 'Document Data Free Ratio'
			 ,@Arg2 = 0.02
			 ,@Arg3 = 1.00;

			raiserror(@errorText, 16, 1);

		end;
		else if @CurrentFileSlack > 0.25 or @CurrentFileSlack < 0.02
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NotInRange'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "%1" value is not in the allowed range (%2 - %3).'
			 ,@Arg1 = 'Current File Size Slack Ratio'
			 ,@Arg2 = 0.02
			 ,@Arg3 = 0.25;

			raiserror(@errorText, 16, 1);

		end;
		else if @CurrentFileSlack >= @BaseFreeRatio or @CurrentFileSlack >= @SysFreeRatio or @CurrentFileSlack >= @DocFreeRatio
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SlackTooLarge'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'The "Current-File-Slack" value must be less than the minimum free space ratio.'
			 ,@Arg1 = 'Current File Size Slack Ratio'
			 ,@Arg2 = 0.02
			 ,@Arg3 = 0.25;

			raiserror(@errorText, 16, 1);

		end;

		select
			@fileGroup = rsz.FileGroup
		from
			sf.fDBSpace#Recommendations(@BaseFreeRatio, @SysFreeRatio, @DocFreeRatio, @CurrentFileSlack) rsz
		where
			rsz.NewMaxFileSize < rsz.CurrentFileSize;

		if @fileGroup is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'FileSizeExceedsMax'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A recommended maximum file size in the "%1" group is smaller than the current file size. You must shrink this file (or entire database) before applying these recommendations.'
			 ,@Arg1 = @fileGroup;

			raiserror(@errorText, 16, 1);

		end;

		select
			@fileGroup = rsz.FileGroup
		from
			sf.fDBSpace#Recommendations(@BaseFreeRatio, @SysFreeRatio, @DocFreeRatio, @CurrentFileSlack) rsz
		where
			rsz.FileGroup <> 'Document Data' and rsz.NewFileSize > 2050;

		if @fileGroup is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'NewFileRequired'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A recommended file size for the "%1" group exceeds 2GB. Add an additional file to the file group to keep individual file sizes manageable.'
			 ,@Arg1 = @fileGroup;

			raiserror(@errorText, 18, 1);

		end;

		select
			@fileGroup = fg.name
		from
			sys.database_files f
		left outer join
			sys.filegroups		 fg on f.data_space_id = fg.data_space_id
		where
			f.max_size = -1;

		if @fileGroup is not null
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'UnlimitedFileSize'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'A file for the "%1" group has been set to unlimited size. Unlimited file size is not supported in this environment.'
			 ,@Arg1 = @fileGroup;

			raiserror(@errorText, 18, 1);

		end;

		-- use the table function to calculate the new file
		-- sizes and format a script for execution 

		select
			@resizeSQL += @CRLF + N'alter database ' + db_name() + N' modify file (name = N''' + rsz.LogicalFileName + N''', '
										+ case when rsz.FileGroup in ('Log', 'Document Data') then '' else 'size = ' + ltrim(rsz.NewFileSize) + 'MB,' end + N' maxsize = '
										+ ltrim(rsz.NewMaxFileSize) + N'MB);'
		from
			sf.fDBSpace#Recommendations(@BaseFreeRatio, @SysFreeRatio, @DocFreeRatio, @CurrentFileSlack) rsz
		where
			(
				abs(rsz.CurrentFileSize - rsz.NewFileSize) > 1 or abs(rsz.CurrentMaxSize - rsz.NewMaxFileSize) > 1
			)
			and (@ReduceMaxSize													 = @ON or rsz.NewMaxFileSize > rsz.CurrentMaxSize) -- if parameter is OFF don't include where max size will reduce
		order by
			rsz.FileGroup;

		set @fileCount = @@rowcount;

		if @fileCount = 0
		begin

			if @DebugLevel > 0
			begin
				print 'ok - database files are sized correctly (no changes required)';
			end;
			else
			begin

				select
					'Database files are sized to recommendations (no changes were made).' ResultMessage;

			end;

		end;
		else
		begin

			set @resizeSQL = N'use master; ' + @resizeSQL;
			set @resizeSQL += @CRLF + N'print ''ok - ' + ltrim(@fileCount) + N' database file(s) resized''' + @CRLF;
			set @resizeSQL += N'use ' + db_name() + N';';

			if @DebugLevel > 0
			begin
				exec sf.pLinePrint @TextToPrint = @resizeSQL;
			end;

			if @DebugLevel < 2
			begin
				exec sp_executesql @stmt = @resizeSQL;
			end;

			if @DebugLevel = 0
			begin

				select
					ltrim(@fileCount) + N' Database file(s) resized successfully.' ResultMessage;

			end;

		end;

	end try
	begin catch
		exec sp_executesql @stmt = @resizeSQL;
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);
end;
GO
