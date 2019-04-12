SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fListDisplayColumnName]
(
	 @SchemaName			nvarchar(128)														-- schema where view is located
	,@ViewName				nvarchar(128)														-- name of view to return display column for
) 
returns nvarchar(128)
as
/*********************************************************************************************************************************
ScalarF	: List Display Column Name
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns a column name from a view appropriate for display in drop-down lists (used most often in query construction)
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | Aug	2011			|	Initial Version
				:	Tim Edlund	|	Dec 2013			|	Updated to include "DisplayName" as high ranked column value for display.  Documentation
																				updated.
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used primarily to support the UI where the user needs to pick a data source for a lookup list.  This occurs most
frequently in Query definition where the user wants the UI to present a drop-down list of choices for a selection criteria field.
For example - to have a query select for a given City.  The purpose of the function is to return to the caller the name of the 
column that should be used as the display source.  Continuing the example for City, a good display column might be "CityName".

The value that is used to form the actual link is always the primary key - CitySID.  This function does not return that but a
view that applies this function does:  sf.vListDataSource.

This function returns NULL for the display column name if it cannot find a suitable candidate for display.  NULL return values
will occur frequently UNLESS OVERRIDE COLUMNS ARE PROVIDED IN THE EXTENDED view for the underlying table.  Here is a summary
of the logic that is applied.

The source of lists and their display columns are views only.  Tables are not considered list sources since Entity Framework is 
the expected implementation for projects using the DB framework and an entity view is defined for every table.  Columns are 
considered eligible for display based ONLY ON NAMING CONVENTIONS as defined in the WHERE clause below.  ALSO - if multiple columns 
are found that could serve as effective display columns they are ranked in a specific order (also based on naming convention). The
ORDER BY clause in the code below defines that order.

What to do if no display column is returned or the wrong column is returned?
----------------------------------------------------------------------------
These situations are easily addressed by going to the EXT (extended view) for the base entity and creating a column with a 
higher ranked priority. For example, suppose the function returns "CityName" as the display column for the dbo.vCity list
data source.  The name may work but if you need the user to be able to distinguish between Edmonton Alberta and Edmonton
Kentucky you may need to use a different column.  To achieve this, go to the vCityExt view and create a column with the
name "ListLabel".  The specific value "ListLabel" has the highest ranked priority for columns returned by this function (again 
see SELECT in source below).

NOTE that for many views which represent associative relationships, the display column returned (if any) by this function
is likely to be wrong.  The function is likely to return a parent table descriptor which only shows 1 side of the relationship.
It is more likely that some form of calculated value is required for the display column in order to given the user the 
information required in the drop-down.  Again - just add your calculated column in the view directly (if not an EF view) or
in the EXT view if the source is an EF view.

Example
-------

-- this function is most effectively tested from a view that relies on it

select
	*
from
	sf.vListDataSource lds
where
	lds.DisplayColumnName is not null			-- when used in the UI, avoid including sources where no display column could be derived!
order by
	 lds.SchemName
	,lds.ViewName

------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare 
		@displayColumn	nvarchar(128)																					-- return value - display column name to return

	-- eligible column names are defined in the where clause; the assignment to the variable 
	-- will occur multiple times but only the last assignment is returned; the ORDER BY 
	-- clause ensures the highest priority column name gets the last assignment
		
	select
		@displayColumn = vc.ColumnName
	from
		sf.vViewColumn vc
	where
		vc.SchemaName = @SchemaName
	and
		vc.ViewName		= @ViewName
	and
		(
		vc.ColumnName = 'ListLabel'																						-- only columns matching one of these naming conventions
		or																																		-- are candidates to be display columns (see doc above)
		vc.ColumnName = 'DisplayName'
		or 
		vc.ColumnName = substring(vc.ViewName, 2, 127) + 'Label'
		or
		vc.ColumnName = substring(vc.ViewName, 2, 127) + 'Name'
		or
		vc.ColumnName = substring(vc.ViewName, 2, 127) + 'Title'
		or
		vc.ColumnName = 'SearchName'
		or
		(vc.ColumnName = 'Description' and vc.MaxLength <= 75)
		)
	order by
		(
		case 
			when vc.ColumnName = 'ListLabel'															then 9 -- this block defines the priority order for choosing a column name
			when vc.ColumnName = 'DisplayName'														then 8 -- from the view structure!		
			when vc.ColumnName = substring(vc.ViewName, 2, 127) + 'Label' then 7
			when vc.ColumnName = substring(vc.ViewName, 2, 127) + 'Name'	then 6
			when vc.ColumnName = substring(vc.ViewName, 2, 127) + 'Title' then 5
			when vc.ColumnName = 'SearchName'															then 4
			when vc.ColumnName = 'Description' and vc.MaxLength <= 75			then 3			
			else																															 0	
		end
		)
		
	return(@displayColumn)
	
end
GO
