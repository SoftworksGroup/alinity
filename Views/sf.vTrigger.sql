SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vTrigger]
as
/*********************************************************************************************************************************
View    : Triggers 
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns information about triggers from the SQL Server data dictionary 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				:	Tim Edlund	|	Dec	2011				| Initial version
				: Adam Panter	| May 2014				| Added test harness
----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2008 R2 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This view returns the list of triggers in the database.  The columns returned support procedures that need to check for the existence 
of triggers.  The view is also used as a data source for reports about the database structure.  The view includes table triggers
and database triggers.
 
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
Two unit tests are included. The first selects a random set of 50 triggers and ensures that the result set is not empty, and 
completes in less than five seconds. The second test randomly selects a single trigger, and ensures that exactly one row is returned,
in less than one second. The trigger name and type must not be null.

--!<TestHarness>
--<Test Name = "RandomSet" Description="Select 50 records from the view based on 50 randomly selected primary key values. Assertions include getting a non empty result set, and a response time of less than 5 seconds.">
--<SQLScript>
--<![CDATA[
		select 
			 tr.ObjectID
			,tr.SchemaName
			,tr.TriggerName
			,tr.TriggerType
			,tr.IsDisabled
			,tr.IsInsteadOfTrigger
			,tr.IsTableTrigger
			,tr.IsDatabaseTrigger
			,tr.SchemaAndTriggerName
			,tr.LastModified
		from
			sf.vTrigger tr
			join
			(
				select top 50
					tr.ObjectID
				from
					sf.vTrigger tr
				order by
					newid()
			) x 
			on 
				tr.ObjectID = x.ObjectID
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:05" />
--</Assertions>
--</Test>

--<Test Name = "DetailSelect" Description="Select trigger details for a random trigger. Assertions include getting 1 record back and a response time of less than 1 second">
--<SQLScript>
--<![CDATA[
		select 
			 tr.ObjectID
			,tr.SchemaName
			,tr.TriggerName
			,tr.TriggerType
			,tr.IsDisabled
			,tr.IsInsteadOfTrigger
			,tr.IsTableTrigger
			,tr.IsDatabaseTrigger
			,tr.SchemaAndTriggerName
			,tr.LastModified
		from
			sf.vTrigger tr	 
		where 
			tr.TriggerName =
			(
				select top (1)
					name
				from 
					sys.triggers
				order by
					newid()
			)	 
		and
			TriggerName is not null
		and
			TriggerType is not null
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="RowCount" RowSet="1" Value="1" ResultSet="1"/>
--  <Assertion Type="ExecutionTime" Value="00:00:01" />
--</Assertions>
--</Test>
--!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vTrigger'
------------------------------------------------------------------------------------------------------------------------------- */

select
	 tr.object_id																														ObjectID
	,s.name								collate database_default													SchemaName
	,tr.name							collate database_default													TriggerName
	,case 
		when tr.parent_class  = 0			then 'Database' 
		when v.ViewName is not null		then 'InsteadOf'
		when t.TableName is not null	then 'Table'
		else															 '?'
	 end																																			TriggerType
	,cast(tr.is_disabled as bit)																							IsDisabled
	,cast(tr.is_instead_of_trigger as bit)																		IsInsteadOfTrigger
	,cast(case when t.TableName is not null then 1 else 0 end as bit)					IsTableTrigger
	,cast(case when tr.parent_class = 0 then 1 else 0 end as bit)							IsDatabaseTrigger	
	,s.name + N'.' + tr.name	collate database_default												SchemaAndTriggerName
	,tr.modify_date																														LastModified
from 
	sys.triggers			tr
left outer join
	sys.sysobjects		so on tr.object_id = so.id
left outer join
	sys.schemas				s	 on so.uid = s.schema_id
left outer join
	sf.vTable					t	 on tr.parent_id = t.ObjectID		
left outer join
	sf.vView					v	 on tr.parent_id = v.ObjectID
GO
