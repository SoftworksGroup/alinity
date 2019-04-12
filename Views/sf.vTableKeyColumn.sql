SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vTableKeyColumn]
as
/*********************************************************************************************************************************
View    : Table Key Column
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns dictionary information about columns involved in primary, foreign and unique keys
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Apr 2010    |	Initial Version
				:	Tim Edlund	|	Nov	2012		| Corrected bug in join condition
				: Adam Panter	| May 2014		| Added test harness
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
Returns the list of columns involved in primary, unique and foreign keys.  For additional information about foreign key constraints 
use vForeignKey.  

An application specific view is used rather than the underlying DBMS provided views to standardize references to the application 
across DBMS upgrades which might impact the dictionary views.  

Testing
-------
Two unit tests are included. The first selects 50 Table Key Column records at random, and ensures that the result set is not empty, 
and completes in less than five seconds. The second test randomly selects a single table key column record, and ensures that 
exactly one row is returned, in less than one second. ConstraintName and ColumnName must not be null.
	
--!<TestHarness>
--<Test Name = "RandomSet" Description="Select 50 records from the view based on 50 randomly constraints. Assertions include getting a non empty result set, and a response time of less than 5 seconds.">
--<SQLScript>
--<![CDATA[
			select
				 vtkc.SchemaName
				,vtkc.TableName
				,vtkc.ConstraintName
				,vtkc.ConstraintType
				,ColumnName
				,OrdinalPosition
				,SchemaAndTableName
			from
				sf.vTableKeyColumn vtkc
			join
			(
				select top 50
					vtkc.ConstraintName
				from
					sf.vTableKeyColumn vtkc
				order by
					newid()
			) x 
			on 
				vtkc.ConstraintName = x.ConstraintName
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:05" />
--</Assertions>
--</Test>

--<Test Name = "DetailSelect" Description="Select 1 from a randomly selected table. Assertions include getting 1 record back and a response time of less than 1 second.">
--<SQLScript>
--<![CDATA[
		select  top (1)
			 vtkc.SchemaName
			,vtkc.TableName
			,vtkc.ConstraintName
			,vtkc.ConstraintType
			,vtkc.ColumnName
			,vtkc.OrdinalPosition
			,vtkc.SchemaAndTableName
		from
			sf.vTableKeyColumn vtkc
		where 
			vtkc.TableName =
			(
				select top (1)
					name
				from 
					sys.tables
				order by
					newid()
			)	
		and
			vtkc.ConstraintName is not null
		and
			vtkc.ColumnName is not null
		order by
			newid()
	 
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="RowCount" RowSet="1" Value="1" ResultSet="1"/>
--  <Assertion Type="ExecutionTime" Value="00:00:01" />
--</Assertions>
--</Test>
--!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vTableKeyColumn'
------------------------------------------------------------------------------------------------------------------------------- */

select
	 kcu.CONSTRAINT_SCHEMA													SchemaName																					
	,kcu.TABLE_NAME 																TableName	
	,kcu.CONSTRAINT_NAME 														ConstraintName																					
	,(
		case lower(tc.CONSTRAINT_TYPE) 
			when 'foreign key' 	then 'fk' 
			when 'unique' 			then 'uk' 
			when 'primary key' 	then 'pk' 
			else '??' 
		end
		) 																						ConstraintType
	,kcu.COLUMN_NAME 																ColumnName																					
	,kcu.ORDINAL_POSITION 													OrdinalPosition	
	,kcu.CONSTRAINT_SCHEMA + N'.' + kcu.TABLE_NAME	SchemaAndTableName																			
from
	INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
join
	INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	on
		kcu.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA
	and
		kcu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME	
where
		kcu.TABLE_NAME not like '[_]%' 
	and 
		kcu.TABLE_NAME <> 'sysdiagrams'
GO
