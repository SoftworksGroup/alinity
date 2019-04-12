SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW sf.vFullTextIndexSpace
as
/*********************************************************************************************************************************
View    : Full Text Index Space
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns disk space usage for full-text indexes in the database
----------------------------------------------------------------------------------------------------------------------------------
History	: Author							| Month Year	| Change Summary
				: ------------------- + ----------- + -----------------------------------------------------------------------------------
 				: Tim Edlund          | Aug 2018		|	Initial version
------------------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 through SQL 2014. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the space required for each full text index in the database. This information may be useful in product reports for 
analysts or those responsible for database administration.  

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
	sf.vFullTextIndexSpace fti
where
	fti.SchemaName <> 'sys'
order by
	fti.SchemaAndTableName;      
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.vFullTextIndexSpace'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

select
	x.TableID
 ,object_schema_name(x.TableID)																 SchemaName
 ,object_name(x.TableID)																			 TableName
 ,x.FragmentRows
 ,x.FullTextIndexSpaceUsedMB
 ,object_schema_name(x.TableID) + '.' + object_name(x.TableID) SchemaAndTableName
from
(
	select
		fif.table_id																								 TableID
	 ,sum(fif.row_count)																					 FragmentRows
	 ,convert(decimal(7, 2), sum(fif.data_size / 1024.0 / 1024.0)) FullTextIndexSpaceUsedMB
	from
		sys.fulltext_index_fragments fif
	group by
		fif.table_id
) x;
GO
