SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationEntity#OverrideDescriptions]
	 @DBObjects                            xml															-- entities to return descriptions for
as
/*********************************************************************************************************************************
Procedure : Application Entity - Override Descriptions
Notice    : Copyright © 2016 Softworks Group Inc.
Summary   : Overrides table and column descriptions with new description in XML document
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Cory Ng			| Dec		2016		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure overrides the table and column descriptions for all objects listed in the XML file. This allows clients to use
documentation more specific to their implementation over the more generic product descriptions. The XML document has an override
bit on it which if ON (1), then the description is also to a extended property called "CustomDescription". On post deployment,
all custom descriptions will be pulled up and override the product description. If the override bit is turned OFF (0), then
only the description is modified and any custom description is cleared to allow the description to be updated on future
deployments.

Updating of a description is only performed if the text of the current description and updated description are different. This
will protect against the possibility that product description is considered a custom description and overwrites updated
descriptions written by the development team.

For column descriptions both the descriptions on the table column and view columns are updated.

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Checks if the helpdesk user can be activated.">
		<SQLScript>
exec sf.pApplicationEntity#GetDescriptions
	@DBObjects = N'<DBObjects>
		<Table Name="sf.ApplicationUser"/>
		<Column TableName="sf.ApplicationUser" Name="UserName" />
	</DBObjects>'
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:03" />
		</Assertions>
	</Test>
</TestHarness>

-------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare 
		 @errorNo                         int = 0															-- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                       nvarchar(4000)											-- message text (for business rule errors)
		,@ON                              bit             = cast(1 as bit)		-- a constant to reduce repetitive cast syntax in bit comparisons
		,@OFF                             bit             = cast(0 as bit)		-- a constant to reduce repetitive cast syntax in bit comparisons
		,@i																int																	-- loop index
		,@maxRows													int																	-- loop limit - rows to process
		,@CRLF														char(2) = char(13) + char(10)				-- carriage return
		,@objectType											varchar(10)													-- object type (TABLE or COLUMN)
		,@schemaName											varchar(3)													-- schema name of the current db object
		,@tableName												varchar(128)												-- table name of the current db object
		,@columnName											varchar(128)												-- column name of the current db object (if not table)
		,@isOverride											bit																	-- indicates if the current db object description is custom
		,@description											nvarchar(max)												-- updated description to use
		,@baseTableAction									varchar(6)													-- main description action to perform on base table
		,@entityAction										varchar(6)													-- main description action to perform on entity view
		,@customBaseTableAction						varchar(6)													-- custom description action to perform on base table
		,@customEntityAction							varchar(6)													-- custom description action to perform on entity view
		,@sql															nvarchar(max)												-- dynamic SQL statement
		,@configParamSID									int																	-- config param identifier for the override descriptions
		,@xmlString												nvarchar(max)												-- XML as string format used to save to config param

	declare 
		@work table
		(
			 ID						int						identity(1,1) 
			,SchemaName		varchar(3)		not null
			,TableName		varchar(128)	not null
			,ColumnName		varchar(128)	null
			,IsOverride		bit						not null
			,Description	nvarchar(max)	null
		)

	begin try

		select
			 @configParamSID = cp.ConfigParamSID
		from
			sf.ConfigParam cp
		where
			cp.ConfigParamSCD = 'OverrideDescriptions'

		if @configParamSID is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'ConfigurationNotComplete'
				,@MessageText = @errorText output
				,@DefaultText = N'The configuration setting for "%1" is missing or invalid.'
				,@Arg1        = 'override descriptions'

			raiserror(@errorText, 17, 1)
			
		end

		insert
			@work
			(
				 SchemaName
				,TableName
				,ColumnName
				,IsOverride
				,Description
			)
		select
				substring(t.c.value('@TableName[1]', 'varchar(128)'), 0, charindex('.', t.c.value('@TableName[1]', 'varchar(128)')))
			 ,substring(t.c.value('@TableName[1]', 'varchar(128)'), charindex('.', t.c.value('@TableName[1]', 'varchar(128)')) + 1, 128)
			 ,t.c.value('@ColumnName[1]', 'varchar(128)')
			 ,t.c.value('@IsOverride[1]', 'bit')
			 ,t.c.value('@Description[1]', 'nvarchar(max)')
		from
			@DBObjects.nodes('Definitions/DBObject') t(c)
			
		select
			 @i				= 0
			,@sql			= ''
			,@maxRows = count(1)
		from
			@work

		while @i < @maxRows
		begin

			set @i += 1
			set @baseTableAction				= null
			set @entityAction						= null
			set @customBaseTableAction	= null
			set @customEntityAction			= null
			set @columnName							= null
			set @description						= null

			select
				 @schemaName	=	w.SchemaName	
				,@tableName		=	w.TableName		
				,@columnName	=	w.ColumnName	
				,@isOverride	= w.IsOverride
				,@description	=	w.Description	
			from
				@work w
			where
				w.ID = @i

			if @description is not null
			begin

				if @columnName is null or @columnName = ''												-- db object is a table
				begin
		
					select
						 @baseTableAction				= case 
																				when @description = t.Description	then null
																				when t.Description is null				then 'add' 
																				else 'update' 
																			end
						,@customBaseTableAction = case  
																				when @isOverride = @OFF and t.CustomDescription is not null then 'drop'
																				when @description = t.Description														then null
																				when @isOverride = @ON and t.CustomDescription is null			then 'add' 
																				when @isOverride = @ON and t.CustomDescription is not null	then 'update' 
																				else null													-- not override do nothing
																			end
					from
						sf.vTable t
					where
						t.SchemaName = @schemaName
					and
						t.TableName = @tableName
				
					if @baseTableAction is not null																	-- maybe null if table doesn't exist or description is the same
					begin
						set @sql += 'execute sp_' + @baseTableAction + 'extendedproperty @name = N''MS_Description'', @value = N''' + replace(@description, '''', '''''') + ''', @level0type = N''SCHEMA'', @level0name = N''' + @schemaName + ''', @level1type = N''TABLE'', @level1name = N''' + @tableName + '''' + @CRLF;
					end

					if @customBaseTableAction is not null														-- maybe null if table doesn't exist or description is the same
					begin
						
						if @customBaseTableAction = 'drop'
						begin
							set @sql += 'execute sp_dropextendedproperty @name = N''CustomDescription'', @level0type = N''SCHEMA'', @level0name = N''' + @schemaName + ''', @level1type = N''TABLE'', @level1name = N''' + @tableName + '''' + @CRLF;
						end
						else
						begin
							set @sql += 'execute sp_' + @customBaseTableAction + 'extendedproperty @name = N''CustomDescription'', @value = N''' + replace(@description, '''', '''''') + ''', @level0type = N''SCHEMA'', @level0name = N''' + @schemaName + ''', @level1type = N''TABLE'', @level1name = N''' + @tableName + '''' + @CRLF;
						end

					end

				end
				else
				begin
	
					select
						 @baseTableAction				= case 
																				when @description = tc.Description	then null
																				when tc.Description is null					then 'add' 
																				else 'update' 
																			end
						,@entityAction					= case 
																				when @description = vc.Description	then null
																				when vc.Description is null					then 'add' 
																				else 'update' 
																			end
						,@customBaseTableAction = case  
																				when @isOverride = @OFF and tc.CustomDescription is not null	then 'drop'
																				when @description = tc.Description														then null
																				when @isOverride = @ON and tc.CustomDescription is null				then 'add' 
																				when @isOverride = @ON and tc.CustomDescription is not null		then 'update' 
																				else null													-- not override do nothing
																			end
						,@customEntityAction		= case  
																				when @isOverride = @OFF and vc.CustomDescription is not null	then 'drop'
																				when @description = vc.Description														then null
																				when @isOverride = @ON and vc.CustomDescription is null				then 'add' 
																				when @isOverride = @ON and vc.CustomDescription is not null		then 'update' 
																				else null													-- not override do nothing
																			end
					from
						sf.vTableColumn tc
					left outer join
						sf.vViewColumn	vc on tc.SchemaName + '.v' + tc.TableName = vc.SchemaAndViewName and tc.ColumnName = vc.ColumnName
					where
						tc.SchemaName	= @schemaName
					and
						tc.TableName	= @tableName
					and
						tc.ColumnName	= @columnName

					if @baseTableAction is not null																	-- maybe null if column doesn't exist or description is the same
					begin
						set @sql += 'execute sp_' + @baseTableAction + 'extendedproperty @name = N''MS_Description'', @value = N''' + replace(@description, '''', '''''') + ''', @level0type = N''SCHEMA'', @level0name = N''' + @schemaName + ''', @level1type = N''TABLE'', @level1name = N''' + @tableName  + ''' , @level2type = N''COLUMN'', @level2name = N''' + @columnName + '''' + @CRLF;
					end

					if @entityAction is not null																		-- maybe null if column doesn't exist or description is the same
					begin
						set @sql += 'execute sp_' + @entityAction + 'extendedproperty @name = N''MS_Description'', @value = N''' + replace(@description, '''', '''''') + ''', @level0type = N''SCHEMA'', @level0name = N''' + @schemaName + ''', @level1type = N''VIEW'', @level1name = N''v' + @tableName + ''' , @level2type = N''COLUMN'', @level2name = N''' + @columnName + '''' + @CRLF;
					end
					
					if @customBaseTableAction is not null
					begin
						
						if @customBaseTableAction = 'drop'
						begin
							set @sql += 'execute sp_dropextendedproperty @name = N''CustomDescription'', @level0type = N''SCHEMA'', @level0name = N''' + @schemaName + ''', @level1type = N''TABLE'', @level1name = N''' + @tableName  + ''' , @level2type = N''COLUMN'', @level2name = N''' + @columnName + '''' + @CRLF;
						end
						else
						begin
							set @sql += 'execute sp_' + @customBaseTableAction + 'extendedproperty @name = N''CustomDescription'', @value = N''' + replace(@description, '''', '''''') + ''', @level0type = N''SCHEMA'', @level0name = N''' + @schemaName + ''', @level1type = N''TABLE'', @level1name = N''' + @tableName  + ''' , @level2type = N''COLUMN'', @level2name = N''' + @columnName + '''' + @CRLF;
						end

					end
					
					if @customEntityAction is not null
					begin
						
						if @customEntityAction = 'drop'
						begin
							set @sql += 'execute sp_dropextendedproperty @name = N''CustomDescription'', @level0type = N''SCHEMA'', @level0name = N''' + @schemaName + ''', @level1type = N''VIEW'', @level1name = N''v' + @tableName + ''' , @level2type = N''COLUMN'', @level2name = N''' + @columnName + '''' + @CRLF;
						end
						else
						begin
							set @sql += 'execute sp_' + @customEntityAction + 'extendedproperty @name = N''CustomDescription'', @value = N''' + replace(@description, '''', '''''') + ''', @level0type = N''SCHEMA'', @level0name = N''' + @schemaName + ''', @level1type = N''VIEW'', @level1name = N''v' + @tableName + ''' , @level2type = N''COLUMN'', @level2name = N''' + @columnName + '''' + @CRLF;
						end

					end

				end

			end

		end

		exec sp_executesql @sql

		if @maxRows is null
		begin

			exec sf.pConfigParam#Update																					-- delete override config param is no overrides exist
				 @ConfigParamSID	= @configParamSID
				,@ParamValue			= null
				,@IsNullApplied		= @ON

		end
		else
		begin

			set @xmlString = cast(@DBObjects as nvarchar(max))

			exec sf.pConfigParam#Update																					-- update override config param to passed XML so overrides are preserved on future deployments
				 @ConfigParamSID	= @configParamSID
				,@ParamValue			= @xmlString

		end

	end try
	
	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
