SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW sf.vTableSpace
as
/*********************************************************************************************************************************
View    : TableSpace
Notice  : Copyright © 2015 Softworks Group Inc.
Summary	: Returns record counts and disk space usage information for tables in the database
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| May 2015		| Initial version
----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 through SQL 2014. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the page allocation and page usage information (in megabytes) for each table in database along with row 
counts.  This information may be useful in product reports for analysts or those responsible for database administration.  

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

<TestHarness>
  <Test Name = "All" IsDefault ="true" Description="Executes view for non-sys schemas">
    <SQLScript>
      <![CDATA[
select
	*
from
	sf.vTableSpace ts
where
	ts.SchemaName <> 'sys'
order by
	ts.SchemaAndTableName;      
		]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.vTableSpace'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
select
	ts.SchemaName
 ,ts.TableName
 ,(case
		 when filegroup_name(ts.DataSpaceID) = 'PRIMARY' then 'Dictionary (primary)'
		 else sf.fObjectNameSpaced(filegroup_name(ts.DataSpaceID))
	 end
	)																																	 DataFileGroup
 ,(case
		 when filegroup_name(ts.LOBDataSpaceID) = 'PRIMARY' then 'Dictionary (primary)'
		 else sf.fObjectNameSpaced(filegroup_name(ts.LOBDataSpaceID))
	 end
	)																																	 LOBFileGroup
 ,ts.RowsInTable
 ,ts.TotalPages
 ,ts.UsedPages
 ,ts.TableSpaceAllocatedMB
 ,ts.TableSpaceUsedMB
 ,cast(isnull(tis.TableIndexSpaceUsedMB, 0.00) as decimal(9, 2))		 TableIndexSpaceUsedMB
 ,cast(isnull(ftis.FullTextIndexSpaceUsedMB, 0.00) as decimal(9, 2)) FullTextIndexSpaceUsedMB
 ,ts.SchemaName + '.' + ts.TableName																 SchemaAndTableName
 ,ts.DataSpaceID
 ,ts.LOBDataSpaceID
from
(
	select
		s.name collate database_default																			SchemaName
	 ,t.name collate database_default																			TableName
	 ,p.rows																															RowsInTable
	 ,i.data_space_id																											DataSpaceID
	 ,t.lob_data_space_id																									LOBDataSpaceID
	 ,sum(a.total_pages)																									TotalPages
	 ,sum(a.used_pages)																										UsedPages
	 ,cast(round((sum(a.total_pages) * 8) / 1024.00, 2) as decimal(9, 2)) TableSpaceAllocatedMB
	 ,cast(round((sum(a.used_pages) * 8) / 1024.00, 2) as decimal(9, 2))	TableSpaceUsedMB
	from
		sys.tables					 t
	join
		sys.schemas					 s on t.schema_id		 = s.schema_id
	join
		sys.indexes					 i on t.object_id		 = i.object_id
	join
		sys.partitions			 p on i.object_id		 = p.object_id and i.index_id = p.index_id
	join
		sys.allocation_units a on p.partition_id = a.container_id
	where
		t.name not like 'dt%' and i.object_id > 255 and i.index_id <= 1
	group by
		s.name
	 ,t.name
	 ,p.rows
	 ,i.data_space_id
	 ,t.lob_data_space_id
) ts
left outer join
(
	select
		x.SchemaName
	 ,x.TableName
	 ,sum(x.TableIndexSpaceUsedMB) TableIndexSpaceUsedMB
	from
		sf.vTableIndexSpace x
	group by
		x.SchemaName
	 ,x.TableName
) tis on ts.SchemaName	= tis.SchemaName and ts.TableName = tis.TableName
left outer join
(
	select
		z.SchemaName
	 ,z.TableName
	 ,sum(z.FullTextIndexSpaceUsedMB) FullTextIndexSpaceUsedMB
	from
		sf.vFullTextIndexSpace z
	group by
		z.SchemaName
	 ,z.TableName
) ftis on ts.SchemaName = ftis.SchemaName and ts.TableName = ftis.TableName;
GO
