SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vTableIndexColumn]
as
/*********************************************************************************************************************************
View    : Index Column
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns index columns information from the SQL Server data dictionary 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Jun 2013		| Initial version
				: Adam Panter	| May 2014		| Added test harness

----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the list of index columns on tables (index columns on views are NOT returned).  The columns returned support 
routines that check database structure for compliance with Softworks standards.  The view is also used as a data source for reports 
about the database structure.

Indexes on CDC capture instance tables and certain other table indexes are excluded from the view.  Tables beginning with underscores 
are considered temporary and are not targets for standard compliance checking.  Certain tables created by the MS diagramming tool 
and Visual Studio tools are also excluded.  The procedures of SGI Studio skip these tables by using this view as a table source.  
For a complete list of excluded tables, see the WHERE clause in the vTable view. 

Collation
---------
Character values returned in the view have the collation of the current database applied to them.  This ensures that if collation 
of the target database is different than the database where SGI Studio is deployed, comparisons of values will not result in 
collation errors. Collation conversions must be applied to all string values from external databases (SGI coding standard!).  

Compatibility with other SQL Server versions
--------------------------------------------
This object references "sys" (system) views because of complexities in referencing system functions - like object_id() - in 
deployments for target databases.  Microsoft does not guarantee that sys view definitions will be compatible in SQL Server upgrades.  
This view may not deploy successfully on databases other than the database version identified at the top of this script.

Testing
-------
Two unit tests are included. The first selects 50 Table Index Column records at random and ensures that the result set is not empty,
and completes in less than five seconds. The second test selects the index of the first column from a randomly selected table, and 
ensures that exactly one row is returned, in less than one second. IndexName and ColumnName must not be null.

--!<TestHarness>
--<Test Name = "ColumnRandomSet" Description="Select 50 records from the view based on 50 randomly selected primary key values. Assertions include getting a non empty result set, and a response time of less than 5 seconds.">
--<SQLScript>
--<![CDATA[
			select top 50 
				 tic.SchemaName
				,tic.TableName
				,tic.ObjectID
				,tic.IndexID
				,tic.IndexName
				,tic.ColumnName
				,tic.ColumnOrdinalPosition
				,tic.IndexColumnOrdinalPosition
				,tic.IsIncludedColumn
				,tic.IsDescendingKey
				,tic.IsForeignKey
			from
				sf.vTableIndexColumn tic
			where schemaName = 'dbo'
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:15" />
--</Assertions>
--</Test>

--<Test Name = "DetailSelect" Description="Select a TableIndex record from a randomly selected TableName. Assertions include getting 1 record back and a response time of less than 1 second.">
--<SQLScript>
--<![CDATA[
		select  
			 SchemaName
			,TableName
			,ObjectID
			,IndexID
			,IndexName
			,ColumnName
			,ColumnOrdinalPosition
			,IndexColumnOrdinalPosition
			,IsIncludedColumn
			,IsDescendingKey
			,IsForeignKey
		from
			sf.vTableIndexColumn vtl
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
			IndexID = 1
		and
			IndexName is not null
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
	@ObjectName = 'sf.vTableIndexColumn'

------------------------------------------------------------------------------------------------------------------------------- */

select
	 t.SchemaName
	,t.TableName
	,ti.ObjectID
	,ti.IndexID																															
	,ti.IndexName
	,c.ColumnName
	,c.OrdinalPosition																											ColumnOrdinalPosition
	,ic.index_column_id																											IndexColumnOrdinalPosition																	
	,cast( 
			case
				when ic.is_included_column = 1 then 1 
				else 0
			end
			as bit)																															IsIncludedColumn
	,cast( 
			case
				when ic.is_descending_key = 1 then 1 
				else 0
			end
			as bit)																															IsDescendingKey	
	,cast(
			case when exists 
        (
        select 
          'x' 
        from 
          sf.vTableKeyColumn tkc 
			  where 
          t.ObjectID = TableObjectID 
        and 
          tkc.ColumnName = c.ColumnName 
        and 
          tkc.ConstraintType = 'fk'
        ) 
				then 1
				else 0 
			end
			as bit)																															IsForeignKey
from 
	sf.vTableIndex		ti
join
	sys.index_columns	ic on ic.object_id = ti.ObjectID and ic.index_id = ti.IndexID
join
	sf.vTable					t on ti.ObjectID = t.ObjectID
join
	sf.vTableColumn		c on t.ObjectID = c.TableObjectID and ic.column_id = c.ColumnID
GO
