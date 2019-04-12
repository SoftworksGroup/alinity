SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vTableColumn]
as
/*********************************************************************************************************************************
View    : Table Column
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns table column information from the SQL Server data dictionary 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| January		2009	| Initial version
				:	Tim Edlund	|	July			2011	| Implemented expanded version based on SGI Studio for consistency
																					vTableColumnExt eliminated from model
																					"AllowNulls" column changed to "IsNullable" in new version!
				: Tim Edlund  | December  2011	| Update type specifications to support DateTime precision: time, datetimeoffset
				: Tim Edlund  | April     2012  | Corrected incorrect length returned on "varbinary" data type columns
				: Tim Edlund  | June      2012  | Removed ValidationMask as design migrated to support dynamic masks - e.g. to change
																					the phone or postal code mask based on the country associated with the record
				: Adam Panter	| May				2014	| Added test harness
				: Cory Ng			| December	2016	| Added custom description to the view for client specific column descriptions
				: Tim Edlund	| May				2017	| Added "IsFullTextIndexed" attribute

----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns a list of column information for tables in the database (view column information is NOT returned).  The columns 
returned support query management and execution routines, setup checks and general reporting on the database structure.
 
Collation
---------
Character values returned in the view have the collation of the current database applied to them.  This ensures that if collation 
of the system view is different than the database where the product is deployed, comparisons of values will not result in collation 
errors. Collation conversions must be applied to all system view columns (SGI coding standard!). 

Compatibility with other SQL Server versions
--------------------------------------------
This object references "sys" (system) views because of complexities in referencing system functions - like object_id() - in
deployments for target databases.  MS does not guarantee that sys view definitions will be upward compatible in SQL Server 
upgrades.  This view may not deploy successfully on databases other than the database version identified at the top of this script.

Testing
-------
Two unit tests are included. The first selects 50 TableColumn records at random from the dbo schema, and ensures that the result
set is not empty, and completes in less than five seconds. The second test select details for a random column on a randomly selected 
table, and ensures that exactly one row is returned, in less than one second. ColumnName and DataType must not be null.

--!<TestHarness>
--<Test Name = "RandomSet" Description="Select 50 TableColumn records at random from the dbo schema. Assertions include getting a non empty result set, and a response time of less than 5 seconds.">
--<SQLScript>
--<![CDATA[			
		select  top 50
			 TableName
			,SchemaAndTableName
			,ColumnName
			,DataType
			,TypeSpecification
			,ColumnDefault
			,Description
			,ObjectNameLength
		from
			sf.vTableColumn vtc
		where 
			SchemaName = 'dbo'
		order by
			newid()
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:10" />
--</Assertions>
--</Test>

--<Test Name = "DetailSelect" Description="Select details for the a randomly selected row from a randomly selected table. Assertions include getting 1 record back and a response time of less than 1 second.">
--<SQLScript>
--<![CDATA[
		select top (1)
			 TableName
			,SchemaAndTableName
			,ColumnName
			,DataType
			,TypeSpecification
			,ColumnDefault
			,Description
			,ObjectNameLength
		from
			sf.vTableColumn vtc		
		where 
			TableName =
			(
				Select top (1)
					name
				from 
					sys.Tables
				order by 
					newid()
			)
		and
			ColumnName is not null
		and
			DataType is not null
		order by 
			newid()
		
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="RowCount" RowSet="1" Value="1" ResultSet="1"/>
--  <Assertion Type="ExecutionTime" Value="00:00:01" />
--</Assertions>
--</Test>
--!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vTableColumn'
------------------------------------------------------------------------------------------------------------------------------- */

select
	 t.ObjectID																															TableObjectID
	,sc.column_id																														ColumnID
	,c.ORDINAL_POSITION																											OrdinalPosition
	,t.SchemaName
	,t.TableName
	,t.SchemaName + N'.' + t.TableName																			SchemaAndTableName
	,c.COLUMN_NAME				collate database_default													ColumnName
	,c.DATA_TYPE					collate database_default													DataType
	,isnull(c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION)								MaxLength
	,c.NUMERIC_SCALE																												Decimals
	,case
		when c.DATA_TYPE = 'timestamp' then cast(0 as bit)
		else sc.is_nullable
	 end																																		IsNullable
	,isnull(sc.is_identity,0)																								IsIdentity
	,isnull(sc.is_rowguidcol,0)																							IsRowGUID
	,isnull(sc.is_computed,0)																								IsComputed
	,isnull(sc.is_sparse,0)																									IsSparse
	,isnull(sc.is_column_set,0)																							IsColumnSet
	,isnull(sc.is_filestream,0)																							IsFileStream
	,(case when fic.object_id is null then 0 else 1 end)										IsFullTextIndexed
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
	,c.COLUMN_DEFAULT										collate database_default						ColumnDefault	
	,convert(nvarchar(4000), p.value)		collate database_default						[Description]
	,convert(nvarchar(4000), cd.value)	collate database_default						CustomDescription
	,len(c.COLUMN_NAME)																											ObjectNameLength
from
	INFORMATION_SCHEMA.COLUMNS	c
join
	sf.vTable										t 
	on 
		t.SchemaName = c.TABLE_SCHEMA	collate database_default 
	and 
		t.TableName = c.TABLE_NAME		collate database_default 
left outer join																																																		-- outer join to ensure timestamps included (see above)
	sys.columns									sc	on t.ObjectID = sc.object_id and c.COLUMN_NAME = sc.name
left outer join
	sys.extended_properties	    p		on  t.ObjectID = p.major_id and sc.column_id = p.minor_id and p.name = 'MS_Description'	and p.class = 1
left outer join
	sys.extended_properties	    cd	on  t.ObjectID = cd.major_id and sc.column_id = cd.minor_id and cd.name = 'CustomDescription'	and cd.class = 1
left outer join
	sys.fulltext_index_columns fic	on 	sc.object_id = fic.object_id and sc.column_id = fic.column_id
GO
