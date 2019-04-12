SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vTableIndexSpace]
as
/*********************************************************************************************************************************
View    : Table Index Space
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns disk space usage information for table indexes in the database
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version
------------------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 through SQL 2014. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the space required for each table index in the database. This information may be useful in product reports for 
analysts or those responsible for database administration.  Note that full-text index space is reported through a separate view.

Collation
---------
Character values returned in the view have the collation of the current database applied to them.  This ensures that if collation 
of the system view is different than the database where the product is deployed, comparisons of values will not result in collation 
errors. Collation conversions must be applied to all system view columns (SGI coding standard!).  

Compatibility with other SQL Server versions
--------------------------------------------
This object references "sys" (system) views because of complexities in referencing system functions - like object_id() - in 
deployments for target databases.  Microsoft does not guarantee that sys view definitions will be compatible in SQL Server 
upgrades.  This view may not deploy successfully on databases other than the database version identified above.

Example
-------
<TestHarness>
  <Test Name = "All" IsDefault ="true" Description="Executes view for non-sys schemas">
    <SQLScript>
      <![CDATA[
select
	*
from
	sf.vTableIndexSpace tis
where
	tis.SchemaName <> 'sys'
order by
	tis.SchemaAndTableName;      
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.vTableIndexSpace'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
select
	object_schema_name(i.object_id) collate database_default																	SchemaName
 ,object_name(i.object_id) collate database_default																					TableName
 ,i.name collate database_default																														IndexName
 ,i.index_id																																								IndexID
 ,cast(round((8 * sum(a.used_pages)) / 1024.00, 2) as decimal(9, 2))												TableIndexSpaceUsedMB
 ,object_schema_name(i.object_id) + '.' + object_name(i.object_id) collate database_default SchemaAndTableName
from
	sys.indexes					 as i
join
	sys.partitions			 as p on p.object_id		= i.object_id and p.index_id = i.index_id
join
	sys.allocation_units as a on a.container_id = p.partition_id
group by
	i.object_id
 ,i.index_id
 ,i.name;
GO
