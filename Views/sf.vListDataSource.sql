SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [sf].[vListDataSource]
as
/*********************************************************************************************************************************
View    : List Data Source
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns a list of views with "display" and "value" columns for construction of drop-down lists in the UI
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | August	2011  |	Initial Version 
				: Adam Panter	| May 2014			| Added test harness
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------

This view is used primarily to support the UI where the user needs to pick a data source for a lookup list.  This occurs most
frequently in Query definition where the user wants the UI to present a drop-down list of choices for a selection criteria field.
For example - to have a query select for a given City.  The purpose of the function is to return to the caller the name of the 
column that should be used as the display source.  Continuing the example for City, a good display column might be "CityName".
The view also returns the value column name for binding - and this is always the first column in the ordinal position of the
underlying view (which by coding convention, should be a unique key!).

The logic of the view is straight forward except for returning the display name column. That value is returned through a function
which ranks possible column names according to hard coded naming conventions.  See sf.fListDisplayColumnName for details. 

The source of lists and their display columns are views only.  Tables are not considered list sources but since the EF is the
standard implementation for projects using the framework an entity view is defined for every table.  This view excludes views
in the CDC schema and also excludes %EXT views since all columns on the EXT views are represented in their corresponding entity
view.

Testing
-------
Two unit tests are included. The first selects data sources for all views in the dbo schema, and ensures that the result set is 
not empty, and completes in less than five seconds. The second test selects the data source for a randomly selected view,
and ensures that exactly one row is returned, in less than one second.

--!<TestHarness>
--<Test Name = "RandomSet" Description="Select 50 records from the view based on 50 randomly selected primary key values. Assertions include getting a non empty result set, and a response time of less than 5 seconds.">
--<SQLScript>
--<![CDATA[
			select 				 
				 DataBaseName
				,SchemaName
				,ViewName
				,QualifiedViewName
				,DisplayColumnName 
				,ValueColumnName
			from
				sf.vListDataSource lds
			where 
				SchemaName = 'dbo'
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="NotEmptyResultSet" RowSet="1" ResultSet="1"/>'
--  <Assertion Type="ExecutionTime" Value="00:00:05" />
--</Assertions>
--</Test>

--<Test Name = "DetailSelect" Description="Select details of a randomly selected view. Assertions include getting exactly 1 record back and a response time of less than 1 second.">
--<SQLScript>
--<![CDATA[
			select
				 DataBaseName
				,SchemaName
				,ViewName
				,QualifiedViewName
				,DisplayColumnName 
				,ValueColumnName
			from
				sf.vListDataSource lds
			where 
				ViewName = 
				(
					select top (1)
						ViewName
					from
						sf.vView v
					where
						v.SchemaName <> 'cdc'
					and
						right(v.ViewName,3) <> 'Ext'
					order by
						newid()
				)
--]]>
--</SQLScript>
--<Assertions>
--  <Assertion Type="RowCount" RowSet="1" Value="1" ResultSet="1"/>
--  <Assertion Type="ExecutionTime" Value="00:00:01" />
--</Assertions>
--</Test>
--!</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.vListDataSource'

------------------------------------------------------------------------------------------------------------------------------- */

select
	 v.ObjectID
	,db_name()																						DatabaseName
	,v.SchemaName
	,v.ViewName
	,v.SchemaName + N'.' + v.ViewName											QualifiedViewName
	,sf.fListDisplayColumnName( v.SchemaName, v.ViewName)	DisplayColumnName
	,vc.ColumnName																				ValueColumnName
from
	sf.vView v
join
	sf.vViewColumn vc on v.SchemaName = vc.SchemaName and v.ViewName = vc.ViewName and vc.OrdinalPosition = 1		-- value column is the first one!
where
	v.SchemaName <> 'cdc'																									-- change data capture views are not eligible sources of list lookups
	and
	right(v.ViewName,3) <> 'Ext'																					-- avoid extended views since all their columns appear on the entity view
GO
