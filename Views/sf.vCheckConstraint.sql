SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vCheckConstraint]
as
/*********************************************************************************************************************************
View    : Check Constraint
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns information on table check constraints in the database
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Art Lucas		| September	2011	| Initial version
				: Tim Edlund	| November	2011	| Moved from SGIStudio to framework; added object ID's				
				: Adam Panter	| May 2014				| Added test harness
----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns dictionary information for check constraints in the database.  This view is used to inspect check constraints
and to establish which ones exist when maintenance routines need to drop and recreate them to revalidate tables for current
check function settings. 

The SGI standard for enforcing business rules, except those that apply only on DELETE, is to use a check constraint.  A single 
check constraint should be implemented on each table to follow the SGI standard. The one constraint checks all business rules by 
calling a function and passing it all columns in the table. The function is named f<TableName>#Check.

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
Two unit tests are included. RandomSet selects a large pool of constraints from the dbo schema, and ensures that the
result set returned is not empty, and returned in < 5 seconds. DetailSelect selects a single record based on a randomly
selected Table name combination, and ensures that exactly one record is returned in less than 1 second.

--!<TestHarness>
--<Test Name = "RandomSet" Description="Select 50 records from the view based on 50 randomly selected constraints. Assertions include getting a non empty result set, and a response time of less than 5 seconds.">
--<SQLScript>
--<![CDATA[
			select 
				 ConstraintID
				,TableObjectID
				,SchemaName
				,TableName				 
				,ConstraintName
				,CheckClause 
				,SchemaAndTableName
			from 
				sf.vCheckConstraint cc 
			where 
				cc.schemaName = 'dbo'
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:05" />
--</Assertions>
--</Test>

--<Test Name = "DetailSelect" Description="Select details from 1 check constraint record based on a randomly selected table name. Assertions include getting back exactly 1 record and a response time of less than 1 second.">
--<SQLScript>
--<![CDATA[
		select 
			 ConstraintID
			,TableObjectID
			,SchemaName
			,TableName				 
			,ConstraintName
			,CheckClause 
			,SchemaAndTableName
		from 
			sf.vCheckConstraint cc
		where
			TableName 
		in 
			(
				select top (1) 
					name 
				from 
					sys.Tables
				order by 
					newid()
			)
		and	
			ConstraintName is not null
		and
			CheckClause is not null
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="RowCount" RowSet="1" Value="1" ResultSet="1"/>
--  <Assertion Type="ExecutionTime" Value="00:00:01" />
--</Assertions>
--</Test>
--!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vCheckConstraint'
------------------------------------------------------------------------------------------------------------------------------- */

select
	 cc.object_id																																	ConstraintID
	,t.ObjectID																																		TableObjectID
	,t.SchemaName
	,t.TableName
	,cc.name							collate database_default																ConstraintName
	,cc.[definition]			collate database_default																CheckClause
	,t.SchemaName + N'.' + t.TableName																						SchemaAndTableName
from
	sys.check_constraints	cc
join
	sf.vTable							t		on cc.parent_object_id = t.ObjectID
GO
