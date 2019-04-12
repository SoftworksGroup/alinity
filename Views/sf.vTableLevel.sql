SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vTableLevel]
as
/*********************************************************************************************************************************
View    : Table (Foreign Key Dependency) Level
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns tables in the current database organized by "TableLevel" indicating dependency order of foreign keys
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| February 2012		| Initial version
				: Adam Panter	| May 2014				| Added test harness
----------------------------------------------------------------------------------------------------------------------------------
Warning: This Table is verified for SQL Server 2008 R2 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns sequencing information for processing tables.  The sequence information is based on the dependency order of 
foreign keys.  A row is returned for each view in the database.  The result set is organized by "TableLevel" where the value 
indicates the number of levels of "parent" tables which exist above the view.  If the TableLevel = 0, then that view has no
parents and is not dependent on any other view.

The view is useful in situations where tables must be processed in parent-child orders - such as insertion of data where foreign
keys are involved; parent rows must be inserted first.  

The dependency information is based on the sys.sysdepends view.   A CTE is created to iterate through all parent-child 
relationships between the Tables.  A row for all tables is returned. 

Compatibility with other SQL Server versions
--------------------------------------------
This object references "sys" (system) Tables because of complexities in referencing system functions - like object_id() - in 
deployments for target databases.  Microsoft does not guarantee that sys view definitions will be compatible in SQL Server upgrades.  
This view may not deploy successfully on databases other than the database version identified at the top of this script.

Testing
-------
Two unit tests are included. The first selects 50 table level records at random and ensures that the result set is not empty, and
completes in less than five seconds. The second test selects a single table level record at random, and ensures that exactly one 
row is returned, in less than one second. Table name must not be null.

--!<TestHarness>
--<Test Name = "RandomSet" Description="Select 50 records from the view based on 50 randomly selected primary key values. 
Assertions include getting a non empty result set, and a response time of less than 5 seconds.">
--<SQLScript>
--<![CDATA[
			select
				 vtl.TableLevel
				,vtl.SchemaName
				,vtl.TableName
			from
				sf.vTableLevel vtl
			join
			(
				select top 50
					vtl.TableName
				from
					sf.vTableLevel vtl
				order by
					newid()
			) x 
			on 
				vtl.TableName = x.TableName
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:05" />
--</Assertions>
--</Test>

--<Test Name = "DetailSelect" Description="Select a table Level record from a randomly selected table. Assertions include getting 1 record back and a response time of less than 1 second.">
--<SQLScript>
--<![CDATA[
		select
			 vtl.TableLevel
			,vtl.SchemaName
			,vtl.TableName
		from
			sf.vTableLevel vtl
		where 
			vtl.TableName =
			(
				select top (1)
					name
				from 
					sys.tables
				order by
					newid()
			)	
		and
			vtl.TableName is not null 
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="RowCount" RowSet="1" Value="1" ResultSet="1"/>
--  <Assertion Type="ExecutionTime" Value="00:00:01" />
--</Assertions>
--</Test>
--!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vTableLevel'

------------------------------------------------------------------------------------------------------------------------------- */

with FKs as 
(
	select distinct
		 ForeignKeyName		= foreignKey.name
		,OnTableName			= onTable.name
		,OnTableID				= onTable.id
		,AgainstTableName = againstTable.name 
		,AgainstTableID		= againstTable.id
	from 
		sysforeignkeys	fk
	join 
		sysobjects			foreignKey		on foreignKey.id = fk.constid
	join 
		sysobjects			onTable				on fk.fkeyid = onTable.id
	join 
		sysobjects			againstTable	on fk.rkeyid = againstTable.id
	where 
		againstTable.type	= 'U'
	and
		onTable.type			= 'U'
	and 
		againstTable.id		<> onTable.id
	and 
		fk.fkeyid					<> fk.rkeyid
)
,cteTable as 
(
	select distinct																								-- Base Case: tables depending on no other (no parents)
		 TableName		= so.name  
		,TableID			= so.id
		,OnTableID		= 0
		,Lvl					= 0  
		,RootTableID	= so.id  
		,Lineage			= convert(nvarchar(1000),name)
	from 
		sysobjects so
	where 
		so.type = 'U'
	and 
		so.id not in (select fk.OnTableID from FKs fk)
	union all select																							-- Recursive Step: tables depending on other tables (have parents)
		 o.OnTableName
		,o.OnTableID
		,o.AgainstTableID
		,a.Lvl + 1
		,RootTableID	= a.RootTableID
		,Lineage			= convert(nvarchar(1000), a.Lineage + '\' + o.OnTableName)
	from
		cteTable a																									-- a = againstTable
	join 
		FKs o on o.AgainstTableID = a.TableID												-- o = onTable
)
select 
	 TableLevel		= max(lvl)
	,t.SchemaName
	,x.TableName
--    ,Tree			= replicate('.',lvl) + convert(varchar(2),lvl)	-- uncomment for debugging
--    ,x.Lineage
from  
		cteTable x
join
	sf.vTable t on x.TableID = t.ObjectID
group by 
	 t.SchemaName
	,x.TableName
GO
