SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vTableRowCount]
as
/*********************************************************************************************************************************
View    : Table Row Count
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns total rows for each table
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| Apr	2013				| Initial version

----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the schema and table name, along with a count of rows in the table.  

Collation
---------
Character values returned in the view have the collation of the current database applied to them.  This ensures that if collation 
of the system view is different than the database where the product is deployed, comparisons of values will not result in collation 
errors. Collation conversions must be applied to all system view columns (SGI coding standard!).  

Compatibility with other SQL Server versions
--------------------------------------------
This object references "sys" (system) views because of complexities in referencing system functions - like object_id() - in 
deployments for target databases.  Microsoft does not guarantee that sys view definitions will be compatible in SQL Server upgrades.  
This view may not deploy successfully on databases other than the database version identified at the top of this script.

------------------------------------------------------------------------------------------------------------------------------- */

select
	 schema_name(so.schema_id)	collate database_default										SchemaName
	,so.name										collate database_default										TableName
	,isnull(sum(ptn.[rows]),0)																							TotalRows
from
	sys.objects so
join
	sys.partitions ptn on so.object_id = ptn.object_id
where
	so.type = 'U'
and
	so.is_ms_shipped = 0x0
and
	index_id < 2 -- 0=heap, 1=clustered
group by
	 so.schema_id
	,so.name
GO
