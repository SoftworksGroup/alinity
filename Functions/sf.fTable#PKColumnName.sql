SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fTable#PKColumnName]
(
	 @ApplicationEntitySCD								varchar(50)												-- schema.tablename of table to get PK column for
)
returns nvarchar(128)
as
/*********************************************************************************************************************************
ScalarF		: Get Primary Key Column Name
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns the name of the primary key column for the table
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| July 2013		|	Initial version

Comments	
--------
This function is used to modularize lookups to the dictionary where the Row GUID column name is required.  The lookup is based
on the application entity system code passed in. This value is in "schema.tablename" format - e.g. "sf.ApplicationUser". If the 
code is invalid or no primary key is defined on the table, NULL is returned.

Example
-------

select sf.fTable#PKColumnName( 'sf.ApplicationUser')		ColumnName
	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare 
		 @pkColumnName			nvarchar(128)																			-- return value
		
	select
		@pkColumnName = tkc.ColumnName																				-- lookup the PK column name from dictionary
	from
		sf.vTableKeyColumn tkc
	where
		tkc.SchemaAndTableName = @ApplicationEntitySCD
	and
		tkc.ConstraintType = 'pk'																							-- constraint must be defined (must have PK!)
	and
		tkc.OrdinalPosition = 1																								-- in case multiple columns, take the first

	return(@pkColumnName)

end
GO
