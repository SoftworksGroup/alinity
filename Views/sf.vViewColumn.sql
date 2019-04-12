SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vViewColumn]
as
/*********************************************************************************************************************************
View    : View Column
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns view column information from the SQL Server data dictionary 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| July			2011	| Initial version
				: Tim Edlund  | December  2011	| Update type specifications to support DateTime precision: time, datetimeoffset
        : Tim Edlund  | April     2012  | Corrected incorrect length returned on "varbinary" data type columns
        : Tim Edlund  | May       2012  | Added support for column descriptions to the view
				: Adam Panter	| May				2014	| Added test harness
				: Cory Ng			| Feb				2015	| Wrapped OrdinalPosition with isnull so it can be used on the EF diagram as a key
				: Cory Ng			| December	2016	| Added custom description to the view for client specific column descriptions

----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns a list of column information for views in the database (table column information is NOT returned).  The columns 
returned support routines that prompt for query parameters. The view is also used as a data source for reports about the database 
structure.
 
Collation
---------
Character values returned in the view have the collation of the current database applied to them.  This ensures that if collation 
of the system view is different than the database where product is deployed, comparisons of values will not result in collation
errors. Collation conversions must be applied to all system view columns (SGI coding standard!).  

Compatibility with other SQL Server versions
--------------------------------------------
This object references "sys" (system) views because of complexities in referencing system functions - like object_id() - in
deployments for target databases.  MS does not guarantee that sys view definitions will be upward compatible in SQL Server 
upgrades.  This view may not deploy successfully on databases other than the database version identified at the top of this 
script.

Testing
-------
Two unit tests are included. The first selects a random set of rows and ensures that the result set is not empty, and completes
in less than five seconds. The second test selects the first ordinal column of a randomly selected view, and ensures that
exactly one row is returned, in less than one second. It must have a non-null ColumnName and ViewName.

--!<TestHarness>
--<Test Name = "RandomSet" Description="Select 50 random records from vViewColumn. Assertions include getting a non empty result set, and a response time of less than 5 seconds.">
--<SQLScript>
--<![CDATA[ 
		select top 50 
			 OrdinalPosition
			,SchemaName
			,ViewName
			,SchemaAndViewName
			,ColumnName
			,DataType
			,Description
		from
			sf.vViewColumn  
		order by
			newid()
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:05" />
--</Assertions>
--</Test>

--<Test Name = "DetailSelect" Description="Select details of the first ordinal column from a randomly selected view. Assertions include returning exactly 1 record, and a response time of less than 1 second.">
--<SQLScript>
--<![CDATA[
		select  
			 SchemaName
			,ViewName
			,SchemaAndViewName
			,ColumnName
			,DataType
			,Description
		from
			sf.vViewColumn  
		where
			ViewName = 
			(
				Select top (1)
					ViewName
				from
					sf.vView
				order by 
					newid()
			)
		and 
			OrdinalPosition = 1 
		and
			ViewName is not null
		and
			ColumnName is not null
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="RowCount" RowSet="1" Value="1" ResultSet="1"/>
--  <Assertion Type="ExecutionTime" Value="00:00:01" />
--</Assertions>
--</Test>
--!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vViewColumn'
------------------------------------------------------------------------------------------------------------------------------- */

select
	 v.ObjectID																															ViewObjectID
	,isnull(c.ORDINAL_POSITION,0)																						OrdinalPosition
	,v.SchemaName
	,v.ViewName
	,v.SchemaName + N'.' + v.ViewName																				SchemaAndViewName
	,c.COLUMN_NAME				collate database_default													ColumnName
	,c.DATA_TYPE					collate database_default													DataType
	,isnull(c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION)								MaxLength
	,c.NUMERIC_SCALE																												Decimals
	,sc.is_nullable																													IsNullable
	,c.DATA_TYPE 
		+ (case c.DATA_TYPE
				when 'nvarchar'  			then '(' + (case when c.CHARACTER_MAXIMUM_LENGTH = -1 then 'max' else convert(varchar(15),c.CHARACTER_MAXIMUM_LENGTH) end) + ')'
				when 'varchar'				then '(' + (case when c.CHARACTER_MAXIMUM_LENGTH = -1 then 'max' else convert(varchar(15),c.CHARACTER_MAXIMUM_LENGTH) end) + ')'
        when 'varbinary'      then '(' + (case when c.CHARACTER_MAXIMUM_LENGTH = -1 then 'max' else convert(varchar(15),c.CHARACTER_MAXIMUM_LENGTH) end) + ')'
				when 'char'						then '(' + convert(varchar(15), c.CHARACTER_MAXIMUM_LENGTH) + ')'
				when 'nchar'					then '(' + convert(varchar(15), c.CHARACTER_MAXIMUM_LENGTH) + ')'
				when 'decimal'				then '(' + convert(varchar(15), c.NUMERIC_PRECISION) + ',' + convert(varchar(15), c.NUMERIC_SCALE) + ')'
				when 'numeric'				then '(' + convert(varchar(15), c.NUMERIC_PRECISION) + ',' + convert(varchar(15), c.NUMERIC_SCALE) + ')'
				when 'datetimeoffset' then '(' + convert(char(1),  c.DATETIME_PRECISION) + ')'
				when 'datetime2'			then '(' + convert(char(1),  c.DATETIME_PRECISION) + ')'
				when 'time'						then '(' + convert(char(1),  c.DATETIME_PRECISION) + ')'
				else ''
			end)														collate database_default						TypeSpecification
	,convert(nvarchar(4000), p.value)		collate database_default						[Description]
	,convert(nvarchar(4000), cd.value)	collate database_default						CustomDescription
	,len(c.COLUMN_NAME)																											ObjectNameLength
from
	INFORMATION_SCHEMA.COLUMNS		c
join
	sf.vView											v		
	on 
		v.SchemaName = c.TABLE_SCHEMA		collate database_default 
	and 
		v.ViewName = c.TABLE_NAME				collate database_default 
join
	sys.columns										sc	on v.ObjectID = sc.object_id and c.ORDINAL_POSITION = sc.column_id
left outer join
	sys.extended_properties	      p		on  v.ObjectID = p.major_id and sc.column_id = p.minor_id and p.name = 'MS_Description'	and p.class = 1
left outer join
	sys.extended_properties	      cd	on  v.ObjectID = cd.major_id and sc.column_id = cd.minor_id and cd.name = 'CustomDescription'	and cd.class = 1
GO
