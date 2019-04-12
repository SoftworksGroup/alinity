SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vTable]
as
/*********************************************************************************************************************************
View    : Table
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns table information from the SQL Server data dictionary 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| January		2009	| Initial version
				:	Tim Edlund	|	July			2011	| Updated to apply same basic version as is used in SGI Studio
																					Table filters removed - all tables are returned
				: Cory Ng			| December	2016	| Added custom description to the view for client specific table descriptions
----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the list of user tables in the database (views are NOT returned).  The columns returned support routines that 
manage and execute application queries and check setup.  The view is also used as a data source for reports about the database 
structure.  

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
	 t.object_id																														ObjectID
	,s.name													  collate database_default							SchemaName
	,t.name													  collate database_default							TableName
	,f.name														collate database_default							FileGroupName
	,convert(nvarchar(max), p.value)	collate database_default							[Description]
	,convert(nvarchar(max), cd.value)	collate database_default							CustomDescription
	,cast(isnull(t.is_tracked_by_cdc,0) as bit)															IsTrackedByCDC
	,s.name + N'.' + t.name					  collate database_default							SchemaAndTableName
	,t.modify_date																													LastModified
from
	sys.tables							t																								-- eliminates views
join
	sys.schemas							s		on	s.schema_id = t.schema_id
join
	sys.indexes							i		on  t.object_id = i.object_id and i.index_id < 2			-- must either be heap index=0 or clustered =1
join
	sys.filegroups					f		on i.data_space_id = f.data_space_id
left outer join
	sys.extended_properties	p		on  p.major_id = t.object_id and p.minor_id = 0 and p.name = 'ms_description'	and	p.class = 1
left outer join
	sys.extended_properties	cd	on  cd.major_id = t.object_id and cd.minor_id = 0 and cd.name = 'CustomDescription'	and	cd.class = 1
GO
