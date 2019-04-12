SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationEntity#GetDescriptions]
	 @DBObjects                            xml															-- entities to return descriptions for
as
/*********************************************************************************************************************************
Procedure : Application Entity - Get Descriptions
Notice    : Copyright © 2016 Softworks Group Inc.
Summary   : Returns the descriptions for the tables and columns in an Excel-compatible XML format
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Cory Ng			| Dec		2016		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure returns table and column descriptions as a Excel-compatible XML document for the DB objects passed in the XML 
document. The XML document produced by this procedure can be opened in Excel as a XML table and modified through that inferface.
The advantage of using excel to modify the description is the ability to use spell checking and compare descriptions to other
descriptions being entered as there may be some patterns that can be copied. The only two fields in the XML that are meant to
be edited is Description and IsOverride. All the other fields are informational and meant to help the user write their
description.

IsOverride
----------
The IsOverride bit is defaulted to ON (1) if a custom description for the entity already exists. If the user would like the
custom description removed on the next deployment the value can be set to OFF (0) which will remove the custom description
and will not be written on the next deployment.

The XML document can be passed to sf.pApplicationEntity#OverrideDescriptions to override the existing documentation with the
ones specified in the XML document.

Example
-------

<TestHarness>
	<Test Name="Simple" IsDefault="true" Description="Get the descriptions for the applicationuser user table and username column.">
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

	begin try

		select
			 DBObject.TableName
			,DBObject.ColumnName
			,DBObject.[Type]
			,DBObject.Nullable
			,DBObject.InBaseTable
			,DBObject.Description
			,case 
				when DBObject.CustomDescription is not null then @ON 
				else @OFF
			 end											IsOverride
		from
			(
			select																															-- return table descriptions
				 DBObject.SchemaAndTableName	TableName
				,''														ColumnName
				,''														OrdinalPosition
				,''														[Type]
				,''														Nullable
				,''														InBaseTable
				,DBObject.CustomDescription		CustomDescription
				,DBObject.Description
			from
				sf.vTable DBObject
			join
			(
				select
					t.c.value('@Name', 'varchar(128)')	SchemaAndTableName
				from
					@DBObjects.nodes('DBObjects/Table') t(c)
			) x on DBObject.SchemaAndTableName = x.SchemaAndTableName
			union
			select																															-- return entity columns
				 replace(DBObject.SchemaAndViewName, '.v', '.')			TableName
				,DBObject.ColumnName
				,DBObject.OrdinalPosition	
				,DBObject.TypeSpecification											[Type]
				,cast(DBObject.IsNullable as char(1))						Nullable
				,case 
					when BaseColumn.ColumnID is not null then '1' 
					else '0' 
				end																							InBaseTable
				,DBObject.CustomDescription		CustomDescription
				,DBObject.Description
			from
				sf.vViewColumn DBObject
			join
			(
				select
					 t.c.value('@ViewName', 'varchar(128)')			SchemaAndViewName
					,t.c.value('@Name', 'varchar(128)')					ColumnName
				from
					@DBObjects.nodes('DBObjects/Column') t(c)
			) x on DBObject.SchemaAndViewName = x.SchemaAndViewName and DBObject.ColumnName = x.ColumnName
			left outer join
				sf.vTableColumn BaseColumn on DBObject.SchemaAndViewName = BaseColumn.SchemaName + '.v' + BaseColumn.TableName and DBObject.ColumnName = BaseColumn.ColumnName
			where
				DBObject.DataType <> 'timestamp'																	-- descriptions for timestamp and PK are not editable
			and
			(
				BaseColumn.ColumnID is null 
			or 
				BaseColumn.IsIdentity = cast(0 as bit)
			)									
		) DBObject
		order by
			 DBObject.TableName
			,DBObject.OrdinalPosition
		for xml auto, root('Definitions')

	end try

	begin catch
		if @@trancount > 0 rollback
		exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
	end catch

	return(@errorNo)

end
GO
