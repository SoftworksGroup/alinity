SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vRoutine]
as
/*********************************************************************************************************************************
View    : Routines (procedures and functions)
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns information about stored procedures and functions from the SQL Server data dictionary 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				:	Tim Edlund	|	May	2011				| Initial version
				: Adam Panter	| May 2014				| Added test harness

----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the list of stored procedures and functions in the database.  The columns returned support routines that need
to check for the existence of extended routines.  The view is also used as a data source for reports about the database 
structure.  The view does not include triggers!

The calculated columns for "BaseSchemaName", "BaseTableName" and ApplicationEntitySCD are based on naming conventions for generated 
functions and procedures created for the framework by SGIStudio. String manipulation is required to extract the associated
base schema and table from the routine name.  An outer select is then used to determine if the base schema and table created
join out to physical tables.  Note that these column values will be null for procedures which are not generated. Procedures and 
functions are generated on each main table in the application to support insert, update, delete, validation and extensions.
 
Collation
---------
Character values returned in the view have the collation of the current database applied to them.  This ensures that if collation 
of the system view is different than the database where the product is deployed, comparisons of values will not result in collation 
errors. Collation conversions must be applied to all system view columns (SGI coding standard!).  

Compatibility with other SQL Server versions
--------------------------------------------
This object references "sys" (system) because of complexities in referencing system functions - like object_id() - in deployments
for target databases.  Microsoft does not guarantee that sys definitions will be compatible in SQL Server upgrades.  This view
may not deploy successfully on databases other than the database version identified at the top of this script.

Testing
-------
Two unit tests are included. The first selects a random set of 50 Routine records from the dbo schema and ensures that the result 
set is not empty, and completes in less than five seconds. The second test selects a single random row, from a randomly selected 
table, and ensures that exactly one row is returned, in less than one second.

--!<TestHarness>
--<Test Name = "RandomSet" Description="Select 50 records from the view based. Assertions include getting a non empty result set, and a response time of less than 5 seconds.">
--<SQLScript>
--<![CDATA[
		select top 50
			 ObjectID
			,SchemaName
			,RoutineName
			,RoutineType
			,IsProcedure
			,IsFunction
			,IsDeterministic
			,IsSchemaBound
			,SQLDataAccess
			,SchemaAndRoutineName
			,BaseSchemaName
			,BaseTableName
			,BaseApplicationEntitySCD 	 
		from
			sf.vRoutine r
		where
			SchemaName = 'dbo'
		order by 
			newid()
			  
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:05" />
--</Assertions>
--</Test>

--<Test Name = "DetailSelect" Description="Select details for all Routines belonging to a randomly selected BaseTable. Assertions include getting 1 record back and a response time of less than 1 second.">
--<SQLScript>
--<![CDATA[
		select 
			 ObjectID
			,SchemaName
			,RoutineName
			,RoutineType
			,IsProcedure
			,IsFunction
			,IsDeterministic
			,IsSchemaBound
			,SQLDataAccess
			,SchemaAndRoutineName
			,BaseSchemaName
			,BaseTableName
			,BaseApplicationEntitySCD 	 
		from
			sf.vRoutine r
		where
			BaseTableName =
		  (
				Select top (1) 
					name
				from
					sys.tables
				order by 
					newid()
			)
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:01" />
--</Assertions>
--</Test>
--!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vRoutine'
------------------------------------------------------------------------------------------------------------------------------- */

select
	 x.ObjectID
	,x.SchemaName
	,x.RoutineName
	,x.RoutineType
	,x.IsProcedure
	,x.IsFunction
	,x.IsDeterministic
	,x.IsSchemaBound
	,x.SQLDataAccess
	,x.SchemaAndRoutineName
	,x.LastModified
	,xs.name										collate database_default										BaseSchemaName
	,xt.name										collate database_default										BaseTableName
	,xs.name + '.' + xt.name		collate database_default										BaseApplicationEntitySCD
from
(
	select
		 o.object_id																													ObjectID
		,r.ROUTINE_SCHEMA		collate database_default													SchemaName
		,r.ROUTINE_NAME			collate database_default													RoutineName
		,r.ROUTINE_TYPE			collate database_default													RoutineType
		,cast(case when r.ROUTINE_TYPE = 'PROCEDURE' then 1 else 0 end as bit)	IsProcedure
		,cast(case when r.ROUTINE_TYPE = 'FUNCTION'	 then 1 else 0 end as bit)	IsFunction
		,cast(case when r.IS_DETERMINISTIC = 'YES'	 then 1 else 0 end as bit)	IsDeterministic	
		,objectproperty(o.object_id, 'IsSchemaBound')													IsSchemaBound
		,r.SQL_DATA_ACCESS																										SQLDataAccess
		,r.ROUTINE_SCHEMA + N'.' + r.ROUTINE_NAME 	collate database_default	SchemaAndRoutineName
		,o.modify_date																												LastModified
		,case
			when sf.fStringCount(r.ROUTINE_NAME, N'#') = 2																			
        then  substring(r.ROUTINE_NAME, 1, charindex(N'#',r.ROUTINE_NAME) - 1)
			when r.ROUTINE_SCHEMA = N'ext' and charindex(N'#p', r.ROUTINE_NAME) > 0
        then  substring(r.ROUTINE_NAME, 1, charindex(N'#',r.ROUTINE_NAME) - 1)			
			when r.ROUTINE_SCHEMA = N'ext' and r.ROUTINE_NAME like N'p%' and charindex(N'#', r.ROUTINE_NAME) = 0
        then  N'dbo'						
			when r.ROUTINE_SCHEMA = N'ext' and r.ROUTINE_NAME like N'f%#Check'		
        then  N'dbo'
			else r.ROUTINE_SCHEMA
		 end																				collate database_default  BaseSchemaName
		,case
			when sf.fStringCount(r.ROUTINE_NAME, N'#') = 2																			
        then  substring(r.ROUTINE_NAME, charindex(N'#',r.ROUTINE_NAME) + 2, (charindex(N'#', r.ROUTINE_NAME, charindex('#',r.ROUTINE_NAME) + 2)) - (charindex(N'#',r.ROUTINE_NAME) + 2))
			when r.ROUTINE_SCHEMA = N'ext' and charindex(N'#p', r.ROUTINE_NAME) > 0
        then  substring(r.ROUTINE_NAME, charindex(N'#',r.ROUTINE_NAME) + 2, 126)
			when charindex(N'#', r.ROUTINE_NAME) > 0																				
        then  substring(r.ROUTINE_NAME, 2, charindex(N'#', r.ROUTINE_NAME) -2)
			else substring(r.ROUTINE_NAME, 2, 127)
		 end                                        collate database_default  BaseTableName	
	from
		INFORMATION_SCHEMA.ROUTINES	r
	join
		sys.schemas									s		on r.ROUTINE_SCHEMA = s.name
	join
		sys.objects									o		on s.schema_id = o.schema_id and o.name = r.ROUTINE_NAME
) x
left outer join
	sys.schemas									xs		on x.BaseSchemaName = xs.name collate database_default
left outer join
	sys.tables									xt		on xs.schema_id = xt.schema_id and x.BaseTableName = xt.name	collate database_default
GO
