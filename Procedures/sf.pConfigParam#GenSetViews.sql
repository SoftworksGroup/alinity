SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pConfigParam#GenSetViews]
as
/*********************************************************************************************************************************
Sproc    : Configuration Parameter - Generate "Set" Views
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Generates dbo.vConfigParam#Active and dbo.vConfigParam#Default views based on current set of configuration parameters
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year | Change Summary
				 : ------------ +  --------- + -------------------------------------------------------------------------------------------
				 : Tim Edlund   | May 2012	 | Initial Version
				 : Tim Edlund		| Jan 2018	 | Updated to avoid errors when parameter codes contains periods (column names get underscore)
----------------------------------------------------------------------------------------------------------------------------------

Comments  
--------
This procedure creates 2 views for working with configuration parameters.  The views are based on data stored in sf.ConfigParam
but are stored in the DBO schema since they reflect application specific configuration values. The first view 
"dbo.vConfigParam#Active" contains the current setting of configuration parameters in the database. The second view 
"dbo.vConfigParam#Default" contains the default settings of the parameters as provided at installation.

Configuration parameters are stored in the sf.ConfigParam table and stored as nvarchar data types. Without these views, the
values of configuration parameters must be retrieved from sf.ConfigParam - usually via sf.fConfigParam#Value - and then cast to 
their target data type which is also stored in the table. These views handle the casting required and also represent the full
set of configuration parameter values in a single row. The "ConfigParamSCD" obtained from the table is applied as the column name.

NOTE that it is critical this procedure be re-run whenever configuration parameters defined for the application change. When a
parameter is added, removed or renamed in the table (sf.ConfigParam), the views are out of data and must be regenerated. To ensure
the views are up to date, the procedure is called automatically whenever pSetup$SF#ConfigParam is called. This occurs through the
sf.pSetup control program.

This procedure also generates descriptions of each parameter column on the active view. These are obtained from the sf.ConfigParam 
table inserted into the database as extended column properties.  They are also included as columns in the Active view itself so
that the UI has all components required for maintenance in a single select. The columns with usage notes are named the 
ConfigParamSCD + "Usage".  Note that these column prompts are typically long and require a multi-line display control of some 
type (unlike more typical "column prompt" values which are limited to about 100 characters).

Example:
--------

<TestHarness>
  <Test Name = "Generate" IsDefault ="true" Description="Executes the procedure to generate the 2 views and then checks for 
	records and columns.">
    <SQLScript>
      <![CDATA[
exec sf.pConfigParam#GenSetViews                                          -- the procedure takes no parameters
select * from dbo.vConfigParam#Active                                     -- test the views created
select * from dbo.vConfigParam#Default
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="NotEmptyResultSet" ResultSet="2"/>      
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
  <Test Name = "Extended" IsDefault ="false" Description="Checks to ensure extended properties were generated.">
    <SQLScript>
      <![CDATA[
select                                                                    -- check for extended properties
   vc.ColumnName
  ,vc.[Description]
from
  sf.vViewColumn vc
where
  vc.SchemaName = 'dbo'
and
  vc.ViewName = 'vConfigParam#Active'
and
  vc.[Description] is not null
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>      
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute 
	 @ObjectName = 'sf.pConfigParam#GenSetViews'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo					int					 = 0	-- 0 no error, if < 50000 SQL error, else business rule
	 ,@activeValueView	nvarchar(max)			-- SQL buffer for creating dbo.vConfigParam#Active
	 ,@defaultValueView nvarchar(max)			-- SQL buffer for creating dbo.vConfigParam#Default
	 ,@CRLF							nchar(2)		 = char(13) + char(10);

	begin try

		-- generate syntax to produce a column for the Active parameter; create a select statement 
		-- to retrieve the value then cast it to the data type defined for it

		select
			@activeValueView =
			isnull(@activeValueView + @CRLF + '  ,', '   ') + '(select cast( ' + sf.fPadR(N'sf.fConfigParam#Value(''' + cp.ConfigParamSCD + ''')', 50) + ' as '
			+ sf.fPadR(cp.DataType + (case when right(cp.DataType, 4) = 'char' then '(' + ltrim(cp.MaxLength) + ')' else '' end) + ')) ', 25)
			+ replace(replace(cp.ConfigParamSCD, '.', '_'), ' ', '_') -- replace period's and spaces with underscores in column name
			+ @CRLF + '  , cast( ''' + replace(cp.UsageNotes, '''', '''''') + ''' as nvarchar(max)) ' + replace(replace(cp.ConfigParamSCD, '.', '_'), ' ', '_')
			+ 'Usage'
		from	(
						select top (1000)
							x.ConfigParamSCD
						 ,x.DataType
						 ,x.MaxLength
						 ,x.UsageNotes
						from
							sf.ConfigParam x
						order by
							x.ConfigParamSCD
					) cp
		where
			isnull(cp.MaxLength, 1) <= 4000; -- avoid encoded image columns that have lengths > 4k

		-- the default view syntax is the same except a different function is called
		-- to obtain the default value

		--exec sf.pLinePrint @TextToPrint = @activeValueView
		set @defaultValueView = replace(@activeValueView, 'fConfigParam#Value(', 'fConfigParam#DefaultValue(');

		-- add documentation for the view and complete the SELECT syntax

		set @activeValueView =
			'CREATE VIEW [dbo].[vConfigParam#Active]' + @CRLF + 'as' + @CRLF
			+ '/*********************************************************************************************************************************' + @CRLF
			+ 'View    : dbo.vConfigParam#Active' + @CRLF + 'Notice  : Copyright © ' + cast(year(sysdatetime()) as char(4)) + ' Softworks Group Inc.' + @CRLF
			+ 'Summary : presents all ACTIVE configuration parameter values for the database in a single row' + @CRLF
			+ '-----------------------------------------------------------------------------------------------------------------------------------' + @CRLF
			+ 'Author  : Generated by Softworks Framework: ' + object_name(@@procid) + ' | Designer: Tim Edlund' + @CRLF + 'Version : '
			+ datename(month, sysdatetime()) + ' ' + cast(year(sysdatetime()) as char(4)) + @CRLF
			+ '-----------------------------------------------------------------------------------------------------------------------------------' + @CRLF
			+ 'Comments' + @CRLF + '--------' + @CRLF
			+ 'This view presents the current settings of all configuration parameters in the database as a single row. Configuration parameters' + @CRLF
			+ 'are stored in the sf.ConfigParam table and stored as nvarchar data types. Without this view, the values of configuration parameters' + @CRLF
			+ 'must be retrieved from sf.ConfigParam - usually via sf.fConfigParam#Value - and then cast to their target data type which is also' + @CRLF
			+ 'stored in the table.' + @CRLF + '' + @CRLF
			+ 'NOTE that it is critical this view be regenerated whenever configuration parameters defined for the application change. When a' + @CRLF
			+ 'parameter is added, removed or renamed in the table (sf.ConfigParam), this view is out of date until regenerated.' + @CRLF + '' + @CRLF
			+ 'When the view is generated, descriptions of each parameter are pulled from the sf.ConfigParam table as well and inserted into the ' + @CRLF
			+ 'database as extended column properties. This value may be queried by the UI to present help text. Note that these column prompts ' + @CRLF
			+ 'are typically long and require a multi-line display control of some type.' + @CRLF + '' + @CRLF
			+ 'When designing the UI, close attention must be paid to the setting of the IsReadOnly bit in sf.ConfigParam. When parameters are set' + @CRLF
			+ 'to IsReadOnly = 1, it is done as a requirement of the application software and therefore not even SA''s can edit them.' + @CRLF + '' + @CRLF
			+ 'Another view "dbo.vConfigParam#Default" has an identical structure but presents default values of each configuration parameter. That' + @CRLF
			+ 'view is used to support "resetting" parameters back to their default settings.' + @CRLF + @CRLF 
			+ 'Example' + @CRLF
			+ '-------' + @CRLF
			+ '<TestHarness>'
			+ '	<Test Name="All" IsDefault="True"  Description="returns all records from the view.">' + @CRLF
			+ '		<SQLScript>' + @CRLF
			+ '			<![CDATA[' + @CRLF
			+ @CRLF +
			+ '			select' + @CRLF
			+ '			x.*' + @CRLF
			+ '			from' + @CRLF
			+ '			dbo.vConfigParam#Active x' + @CRLF
			+ @CRLF +
			+ '			if @@ROWCOUNT = 0 raiserror( N''* ERROR: no sample data found to run test'', 18, 1) ' + @CRLF
			+ @CRLF +
			+ '		]]> '+ @CRLF
			+ '	</SQLScript>' + @CRLF
			+ '	<Assertions>'+ @CRLF
			+ '		<Assertion Type="NotEmptyResultSet" ResultSet="1" />' + @CRLF
			+ '		<Assertion Type="ExecutionTime" Value="00:00:80" />'  + @CRLF
			+ '	</Assertions>'+ @CRLF
			+ '	</Test>'+ @CRLF
			+ '</TestHarness>'
			+ @CRLF + @CRLF
			+ 'exec sf.pUnitTest#Execute' + @CRLF
			+ '   @ObjectName = ''dbo.vConfigParam#Active''' + @CRLF
			+ '  ,@DefaultTestOnly = 1 ' + @CRLF
			+ '-------------------------------------------------------------------------------------------------------------------------------- */' + @CRLF + ''
			+ @CRLF + 'select ' + @CRLF + @activeValueView;

		if object_id('dbo.vConfigParam#Active') > 0 -- drop the view where it exists
		begin -- use dynamic to avoid project warnings
			exec sp_executesql
				@stmt = N'drop view dbo.vConfigParam#Active';
		end;


		exec sp_executesql @stmt = @activeValueView; -- create the view via dynamic SQL

		-- repeat the process for creating the default value view

		set @defaultValueView =
			'CREATE VIEW [dbo].[vConfigParam#Default]' + @CRLF + 'as' + @CRLF
			+ '/*********************************************************************************************************************************' + @CRLF
			+ 'View    : dbo.vConfigParam#Default' + @CRLF + 'Notice  : Copyright © ' + cast(year(sysdatetime()) as char(4)) + ' Softworks Group Inc.' + @CRLF
			+ 'Summary : presents all DEFAULT configuration parameter values for the database in a single row' + @CRLF
			+ '-----------------------------------------------------------------------------------------------------------------------------------' + @CRLF
			+ 'Author  : Generated by Softworks Framework: ' + object_name(@@procid) + ' | Designer: Tim Edlund' + @CRLF + 'Version : '
			+ datename(month, sysdatetime()) + ' ' + cast(year(sysdatetime()) as char(4)) + @CRLF
			+ '-----------------------------------------------------------------------------------------------------------------------------------' + @CRLF
			+ 'This view presents the default settings of all configuration parameters in the database as a single row. Configuration parameters' + @CRLF
			+ 'are stored in the sf.ConfigParam table and stored as nvarchar data types. Without this view, the values of configuration parameters' + @CRLF
			+ 'must be retrieved from sf.ConfigParam - usually via sf.fConfigParam#Value - and then cast to their target data type which is also' + @CRLF
			+ 'stored in the table.' + @CRLF + '' + @CRLF
			+ 'NOTE that it is critical this view be regenerated whenever configuration parameters defined for the application change. When a' + @CRLF
			+ 'parameter is added, removed or renamed in the table (sf.ConfigParam), this view is out of date until regenerated.' + @CRLF + '' + @CRLF
			+ 'This view is used primarily to compare or reset "active" parameter values with the set of default parameter values provided at' + @CRLF
			+ 'installation.  Active parameter values are provided in the view "dbo.vConfigParam#Active".' + @CRLF + '' + @CRLF + 
			+ 'Example' + @CRLF
			+ '-------' + @CRLF
			+ '<TestHarness>'
			+ '	<Test Name="All" IsDefault="True"  Description="returns all records from the view.">' + @CRLF
			+ '		<SQLScript>' + @CRLF
			+ '			<![CDATA[' + @CRLF
			+ @CRLF +
			+ '			select' + @CRLF
			+ '			x.*' + @CRLF
			+ '			from' + @CRLF
			+ '			dbo.vConfigParam#Active x' + @CRLF
			+ @CRLF +
			+ '			if @@ROWCOUNT = 0 raiserror( N''* ERROR: no sample data found to run test'', 18, 1) ' + @CRLF
			+ @CRLF +
			+ '		]]> '+ @CRLF
			+ '	</SQLScript>' + @CRLF
			+ '	<Assertions>'+ @CRLF
			+ '		<Assertion Type="NotEmptyResultSet" ResultSet="1" />' + @CRLF
			+ '		<Assertion Type="ExecutionTime" Value="00:00:80" />' + @CRLF
			+ '	</Assertions>'+ @CRLF
			+ '	</Test>'+ @CRLF
			+ '</TestHarness>'
			+ @CRLF + @CRLF
			+ 'exec sf.pUnitTest#Execute' + @CRLF
			+ '   @ObjectName = ''dbo.vConfigParam#Default''' + @CRLF
			+ '  ,@DefaultTestOnly = 1 ' + @CRLF
			+ '-------------------------------------------------------------------------------------------------------------------------------- */' + @CRLF + ''
			+ @CRLF + 'select ' + @CRLF + @defaultValueView;

		if object_id('dbo.vConfigParam#Default') > 0 -- drop the view where it exists
		begin -- use dynamic to avoid project warnings
			exec sp_executesql
				@stmt = N'drop view dbo.vConfigParam#Default';
		end;

		exec sp_executesql @stmt = @defaultValueView; -- create the view via dynamic SQL

		-- finally, add extended properties for the columns of the active view to allow the
		-- UI to provide prompt text

		set @activeValueView = null;

		select
			@activeValueView =
			isnull(@activeValueView + @CRLF, '') + 'exec sp_addExtendedProperty @name = ''MS_Description'', @value = ''' + replace(cp.UsageNotes, '''', '''''')
			+ ''',@level0type = ''schema'', @level0name = ''dbo'', @level1type = ''view'', @level1name = ''vConfigParam#Active'', @level2Type = ''Column'', @level2Name = '''
			+ replace(replace(cp.ConfigParamSCD, '.', '_'), ' ', '_') -- replace period's and spaces with underscores in column name
			+ ''';'
		from	(
						select top (1000)
							x.ConfigParamSCD
						 ,x.DataType
						 ,x.MaxLength
						 ,x.UsageNotes
						from
							sf.ConfigParam x
						order by
							x.ConfigParamSCD
					) cp
		where
			isnull(cp.MaxLength, 1) <= 4000 -- avoid encoded image columns that have lengths > 4k
		order by
			cp.ConfigParamSCD;

		--exec sf.pLinePrint @TextToPrint = @activeValueView;
		exec sp_executesql @stmt = @activeValueView; -- create the extended properties

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
