SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vTableIndex]
as
/*********************************************************************************************************************************
View    : Index
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns index information from the SQL Server data dictionary 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| Jun 2013		| Initial version
				: Adam Panter	| May 2014		| Added test harness
----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the list of table indexes in the database (indexes on views are NOT returned).  The columns returned support 
routines that check database structure for compliance with Softworks standards.  The view is also used as a data source for reports 
about the database structure.

Views on CDC capture instance tables and certain other table indexes are excluded from the view.  Tables beginning with underscores 
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
Two unit tests are included. The first selects 50 table index records at random and ensures that the result set is not empty, and 
completes in less than five seconds. The second test selects the index of the primary key column of a randomly selected table,
and ensures that exactly one row is returned, in less than one second. IndexName and FileGroupName must not be null.

--!<TestHarness>
--<Test Name = "RandomSet" Description="Select 50 records from the view based on 50 randomly selected primary key values. Assertions include getting a non empty result set, and a response time of less than 5 seconds.">
--<SQLScript>
--<![CDATA[
			 select
				 vti.TableName
				,vti.IndexName
				,vti.FileGroupName
				,vti.IsClusteredIndex
				,vti.IsPrimaryKey
				,vti.IsUniqueIndex
				,vti.IsFiltered
				,vti.FilterDefinition
				,vti.IsUniqueKey
				,vti.IsUniqueConstraint
				,vti.IndexType
				,vti.XMLIndexType
				,vti.Description   
			from
				sf.vTableIndex vti
			join
			(
				select top 50
					vti.IndexName
				from
					sf.vTableIndex vti
				order by
					newid()
			) x 
			on 
				vti.IndexName = x.IndexName
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:05" />
--</Assertions>
--</Test>

--<Test Name = "DetailSelect" Description="Retrieve details for the primary key index of a randomly selected table. Assertions include getting 1 record back and a response time of less than 1 second.">
--<SQLScript>
--<![CDATA[
		select 
		 	 vti.TableName
			,vti.IndexName
			,vti.FileGroupName
			,vti.IsClusteredIndex
			,vti.IsPrimaryKey
			,vti.IsUniqueIndex
			,vti.IsFiltered
			,vti.FilterDefinition
			,vti.IsUniqueKey
			,vti.IsUniqueConstraint
			,vti.IndexType
			,vti.XMLIndexType
			,vti.Description   
		from
			sf.vTableIndex vti
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
				IsPrimaryKey = 1
			and
				IndexName is not null
			and	
				FileGroupName is not null
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="RowCount" RowSet="1" Value="1" ResultSet="1"/>
--  <Assertion Type="ExecutionTime" Value="00:00:01" />
--</Assertions>
--</Test>
--!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vTableIndex'
------------------------------------------------------------------------------------------------------------------------------- */

select 
	 t.SchemaName
	,t.TableName
	,i.name						collate database_default															IndexName
	,ds.name					collate database_default															FileGroupName 
	,cast(
		case
			when lower(i.type_desc) = 'clustered' then 1 
			else 0 
		end
		as bit)																																IsClusteredIndex
	,cast( 
		case
			when i.is_primary_key = 1 then 1 
			else 0
		end
		as bit)																																IsPrimaryKey
	,cast(
		case 
			when i.is_unique = 1 then 1 
			else 0  
		end
		as bit)																																IsUniqueIndex
	,cast(
		case 
			when i.has_filter = 1 then 1 
			else 0  
		end
		as bit)																																IsFiltered
	,i.filter_definition																										FilterDefinition
	,cast(
		case 
			when i.is_unique_constraint = 1 then 1 
			else 0  
		end
		as bit)																																IsUniqueKey
	,cast(
		case 
			when i.is_unique_constraint = 1 then 1 
			else 0  
		end
		as bit)																																IsUniqueConstraint
	,i.object_id																														ObjectID 
	,i.index_id																															IndexID
	,i.type_desc			collate database_default              								IndexType
	,case 
		when i.type_desc = 'XML' and xi.secondary_type_desc is null 
		then 'Primary'
		when i.type_desc = 'XML' and xi.secondary_type = 'P' 
		then 'Path'		
		when i.type_desc = 'XML' and xi.secondary_type = 'R' 
		then 'Property'	
		when i.type_desc = 'XML' and xi.secondary_type = 'V' 
		then 'Value'					
		else null
	 end							collate database_default															XMLIndexType
	 ,isnull(epc.value, epi.value)																					Description
from 
	sys.indexes i
join
	sf.vTable t on i.object_id = t.ObjectID
join
	sys.data_spaces ds on i.data_space_id = ds.data_space_id
left outer join
	sys.xml_indexes xi on i.object_id = xi.object_id and	i.index_id = xi.index_id
outer apply
	fn_listextendedproperty ('ms_description', 'schema', t.SchemaName,  'table', t.TableName, 'constraint', i.name) epc
outer apply
	fn_listextendedproperty ('ms_description', 'schema', t.SchemaName,  'table', t.TableName, 'index', i.name)			epi
where
	i.name is not null
GO
