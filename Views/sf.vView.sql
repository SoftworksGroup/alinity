SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW sf.vView
as
/*********************************************************************************************************************************
View    : View
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns view information from the SQL Server data dictionary 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| July		2011		| Initial version
				: Tim Edlund	| November 2011		| Added column based on SGI_ApplicationEntitySCD extended property
				: Cory Ng			| December	2016	| Added custom description to the view for client specific view descriptions

----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the list of views in the database (tables are NOT returned).  The columns returned support routines that 
allow prompting in queries.  The view is also used as a data source for reports about the database structure.

The calculated columns for "BaseSchemaName", "BaseTableName" and ApplicationEntitySCD are based on naming conventions for generated 
views created for the framework by SGIStudio.  Note that these column values will be null for most views which are not generated since
they depend on a naming convention. 

SGI_ApplicationEntitySCD Property
---------------------------------
A search is performed in the dictionary for the SGI_ApplicationEntitySCD property which is used to relate the view to its entity 
in the application.  The property can be set manually, however, is set automatically by a generator when entity views are created.  
Only "entity" views store this property.  By convention, the value of the property is always the schema + base table name. For
example "dbo.Person".  
 
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

Testing
-------
Two unit tests are included. The first selects a random set of 50 views and ensures that the result set is not empty, and completes
in less than five seconds. The second test selects a single view at random, and ensures that exactly one row is returned, in less than
one second. The ViewName must not be null.

--!<TestHarness>
--<Test Name = "RandomSet" Description="Select 50 records from the view based on 50 randomly selected primary key values. Assertions include getting a non empty result set, and a response time of less than 5 seconds.">
--<SQLScript>
--<![CDATA[
			select
				v.ObjectID
				,v.SchemaName
				,v.ViewName
				,v.Description
				,v.IsSchemaBound
				,v.ApplicationEntitySCD
				,v.SchemaAndViewName
				,v.LastModified
				,v.BaseSchemaName
				,v.BaseTableName
				,v.BaseApplicationEntitySCD
			from
			 	sf.vView v
			join
			(
				select top 50
					v.ObjectID
				from
					sf.vView v
				order by
					newid()
			) x 
			on 
				v.ObjectID = x.ObjectID
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:05" />
--</Assertions>
--</Test>

--<Test Name = "DetailSelect" Description="Selects view details for a randomly selected view. Assertions include getting 1 record back and a response time of less than 1 second.">
--<SQLScript>
--<![CDATA[
		select 
			 v.ObjectID
			,v.SchemaName
			,v.ViewName
			,v.Description
			,v.IsSchemaBound
			,v.ApplicationEntitySCD
			,v.SchemaAndViewName
			,v.LastModified
			,v.BaseSchemaName
			,v.BaseTableName
			,v.BaseApplicationEntitySCD
		from
			sf.vView v
		where
			v.ViewName = 
			(
				select top (1) 
					name
				from
					sys.views
				order by
					newid()
			)
		and
			ViewName is not null 

--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="RowCount" RowSet="1" Value="1" ResultSet="1"/>
--  <Assertion Type="ExecutionTime" Value="00:00:01" />
--</Assertions>
--</Test>
--!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vView'
------------------------------------------------------------------------------------------------------------------------------- */
select
	x.ObjectID
 ,x.SchemaName
 ,x.ViewName
 ,x.Description
 ,x.IsSchemaBound
 ,x.ApplicationEntitySCD
 ,x.SchemaAndViewName
 ,x.LastModified
 ,s.name collate database_default								 BaseSchemaName
 ,t.name collate database_default								 BaseTableName
 ,s.name + '.' + t.name collate database_default BaseApplicationEntitySCD
from
(
	select
		v.object_id																								ObjectID
	 ,s.name collate database_default														SchemaName
	 ,v.name collate database_default														ViewName
	 ,convert(nvarchar(500), p.value) collate database_default	Description
	 ,convert(nvarchar(500), cd.value) collate database_default CustomDescription
	 ,objectproperty(v.object_id, 'IsSchemaBound')							IsSchemaBound
	 ,convert(nvarchar(257), e.value) collate database_default	ApplicationEntitySCD
	 ,s.name + N'.' + v.name collate database_default						SchemaAndViewName
	 ,so.modify_date																						LastModified
	 ,case
			when v.name like N'%#v%#%' then substring(v.name, 1, charindex(N'#', v.name) - 1)
			else s.name
		end collate database_default															BaseSchemaName
	 ,case
			when v.name like N'%#v%#%' then
				substring(v.name, charindex(N'#', v.name) + 2, (charindex(N'#', v.name, charindex('#', v.name) + 2)) - (charindex(N'#', v.name) + 2))
			when v.name like N'v%#%' then substring(v.name, 2, charindex(N'#', v.name) - 2)
			else substring(v.name, 2, 127)
		end collate database_default															BaseTableName
	from
		sys.views								v
	join
		sys.objects							so on v.object_id = so.object_id
	join
		sys.schemas							s on s.schema_id	= v.schema_id
	left outer join
		sys.extended_properties p on p.major_id		= v.object_id and p.minor_id = 0 and p.name = 'MS_Description' and p.class = 1
	left outer join
		sys.extended_properties e on e.major_id		= v.object_id and e.minor_id = 0 and e.name = 'SGI_ApplicationEntitySCD' and e.class = 1
	left outer join
		sys.extended_properties cd on cd.major_id = v.object_id and cd.minor_id = 0 and cd.name = 'CustomDescription' and cd.class = 1
)							x
left outer join
	sys.schemas s on x.BaseSchemaName = s.name collate database_default
left outer join
	sys.tables	t on s.schema_id			= t.schema_id and x.BaseTableName = t.name collate database_default;
GO
