SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW sf.vForeignKey#Untrusted
as
/*********************************************************************************************************************************
View    : Foreign Key
Notice  : Copyright © 2018 Softworks Group Inc.
Summary	: Returns table, key and correction script for un-trusted foreign key constraints across the database
----------------------------------------------------------------------------------------------------------------------------------
History		: Author	  	| Month Year	| Change Summary
					: ----------- + ----------- + ------------------------------------------------------------------------------------------
					: Tim Edlund	| May 2018		|	Initial version

Comments	
--------
Returns the list of foreign key indexes which are not-trusted - meaning the data contained in them may not meet the referential
integrity constraint it is defined to support.

Sometimes as part of Data Migration strategy, or to carry out some ETL operation, team members disable keys and constraints to 
improve performance or reduce initial errors. After the data load finishes the constraint can be re-enabled. What is often not
understood is that SQL Server won’t start using the foreign key constraint just by enabling it.  SQL Server must be instructed
to recheck all of the data that’s been loaded.  This view isolates the keys that require re-validation and also provides a
SQL Script to process that revalidation.

----------------------------------------------------------------------------------------------------------------------------------
Warning: This view is verified for SQL Server 2014 and 2016 only. Deployment on other versions may fail!
----------------------------------------------------------------------------------------------------------------------------------

Example
-------
<TestHarness>
  <Test Name = "All" IsDefault ="true" Description="Executes the view to return all untrusted foreign keys">
    <SQLScript>
      <![CDATA[
select
	x.SchemaName
 ,x.TableName
 ,x.SchemaAndTableName
 ,x.UntrustedFK
 ,x.ReCheckSQL
from
	sf.vForeignKey#Untrusted x
order by
	x.SchemaAndTableName;
  ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:02"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName			= 'sf.vForeignKey#Untrusted'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */

select
	s.name																																						SchemaName
 ,o.name																																						TableName
 ,s.name + '.' + o.name																															SchemaAndTableName
 ,i.name																																						UntrustedFK
 ,'alter table ' + s.name + '.' + o.name + ' with check check constraint ' + i.name ReCheckSQL
from
	sys.foreign_keys i
inner join
	sys.objects			 o on i.parent_object_id = o.object_id
inner join
	sys.schemas			 s on o.schema_id				 = s.schema_id
where
	i.is_not_trusted = 1 and i.is_not_for_replication = 0;
GO
