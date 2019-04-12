SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fTable#RowGUIDColumnName]
(
	 @ApplicationEntitySCD								varchar(50)												-- schema.tablename of table to get PK column for
)
returns nvarchar(128)
as
/*********************************************************************************************************************************
ScalarF		: Get Row GUID Column Name
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns the name of the row GUID column for the table
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| July 2013		|	Initial version

Comments	
--------
This function is used to modularize lookups to the dictionary where the Row GUID column name is required.  The lookup is based
on the application entity system code passed in. This value is in "schema.tablename" format - e.g. "sf.ApplicationUser". If the 
entity code is invalid or no row GUID column with the identifier attribute is found, NULL is returned.

Example
-------

select sf.fTable#RowGUIDColumnName( 'sf.ApplicationUser')		ColumnName
	
------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare 
		 @rowGUIDColumnName			nvarchar(128)																	-- return value
		
		select
			@rowGuidColumnname = tc.ColumnName																	-- lookup row GUID column from dictionary
		from
			sf.vTableColumn tc
		where
			tc.SchemaAndTableName = @ApplicationEntitySCD
		and
			tc.IsRowGUID = cast(1 as bit)																				-- must have Row GUID attribute turned on!

	return(@rowGUIDColumnName)

end
GO
