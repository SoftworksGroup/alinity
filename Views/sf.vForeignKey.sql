SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vForeignKey]
as
/*********************************************************************************************************************************
View    : Foreign Key
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns table and update rule information for foreign key relationships
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | April 2010    |	Initial Version 
				: Adam Panter	| May 2014			| Added test harness
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
Returns the list of foreign keys (RI constraints) in the database along with the indicator for the update and delete cascade option.  
Note that this view does not include column information.  To see columns involved in FK relationships use vTableKeyColumn.

An application specific view is used rather than the underlying DBMS provided views to standardize column name references to the 
application across different database systems and DBMS upgrades.  DBMS upgrades may change columns in dictionary views which, given 
the use of this view, can be accommodated with a simple view update rather than requiring changes to application code.

Testing
-------
Two unit tests are included. The first selects all foreign keys from DBO and ensures that the result set is not empty, and completes
in less than five seconds. The second test selects a single random foreign key, and ensures that exactly one row is returned, in less than
one second. FKConstraintName must not be null.

--!<TestHarness>
--<Test Name = "RandomSet" Description="Select all Foreign Keys from the view which are in the DBO schema. Assertions include getting a non empty result set, and a response time of less than 5 seconds.">
--<SQLScript>
--<![CDATA[
			select top 50
				 fk.FKTableName
				,fk.FKConstraintName
				,fk.UKSchemaName
				,fk.UKTableName
				,fk.UKConstraintName
				,fk.CascadeOnDelete
				,fk.CascadeOnUpdate
			from
				sf.vForeignKey fk
			where
				fk.FKSchemaName = 'dbo'
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:05" />
--</Assertions>
--</Test>

--<Test Name = "DetailSelect" Description="Select 1 foreign key from a random selection of keys in the INFORMATION_SCHEMA.TABLE_CONSTRAINTS table. Assertions include getting back exactly 1 record and a response time of less than 1 second.">
--<SQLScript>
--<![CDATA[
		select  
			fk.FKTableName
			,fk.FKConstraintName
			,fk.UKSchemaName
			,fk.UKTableName		
			,fk.UKConstraintName
			,fk.CascadeOnDelete
			,fk.CascadeOnUpdate	
		from
			sf.vForeignKey fk
		where
			fk.FKConstraintName = 
			(
				select top (1)
					constraint_name
				from 
					INFORMATION_SCHEMA.TABLE_CONSTRAINTS fk 
				where
					fk.TABLE_NAME not like '[_]%' 
				and 
					fk.TABLE_NAME <> 'sysdiagrams'
				and
					fk.constraint_name like 'fk_%'
				order by
					newid()
			)
		and
			fk.FKConstraintName is not null
		
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="RowCount" RowSet="1" Value="1" ResultSet="1"/>
--  <Assertion Type="ExecutionTime" Value="00:00:01" />
--</Assertions>
--</Test>
--!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vForeignKey'
------------------------------------------------------------------------------------------------------------------------------- */
select
	 fk.TABLE_SCHEMA																												FKSchemaName
	,fk.TABLE_NAME																													FKTableName
	,rc.CONSTRAINT_NAME																											FKConstraintName
	,uk.TABLE_SCHEMA																												UKSchemaName
	,uk.TABLE_NAME																													UKTableName
	,rc.UNIQUE_CONSTRAINT_NAME																							UkConstraintName
	,(case when lower(rc.UPDATE_RULE) = 'cascade' then 'y' else 'n' end) 		CascadeOnUpdate
	,(case when lower(rc.DELETE_RULE) = 'cascade' then 'y' else 'n' end) 		CascadeOnDelete
from 
	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
join
	INFORMATION_SCHEMA.TABLE_CONSTRAINTS fk 
	on 
	rc.CONSTRAINT_SCHEMA = fk.CONSTRAINT_SCHEMA
	and 
	rc.CONSTRAINT_NAME = fk.CONSTRAINT_NAME
left outer join
	INFORMATION_SCHEMA.TABLE_CONSTRAINTS uk 
	on 
	rc.UNIQUE_CONSTRAINT_SCHEMA = uk.CONSTRAINT_SCHEMA 
	and 
	rc.UNIQUE_CONSTRAINT_NAME = uk.CONSTRAINT_NAME
where
		fk.TABLE_NAME not like '[_]%' 
	and 
		fk.TABLE_NAME <> 'sysdiagrams'
GO
