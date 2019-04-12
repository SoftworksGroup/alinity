SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fSchemaName]
	(
	@QualifiedObjectName       nvarchar(257)
	)
returns nvarchar(128)
as
/*********************************************************************************************************************************
Function: Schema Name
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the schema-name component of a fully qualified object that may also include the server, database and object
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| November 2011		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to isolate the "schema" segment (the second last portion) from a fully or partially qualified object name which 
could contain segments for schema, database, server and object name.  Note that the function does not check if the schema exists in 
the current database.  The function is a string manipulation utility.  

If the @QualifiedObjectName value provided does not include at least 1 period (2 segments), then this function will return NULL.

Example:
--------
The function allows the object name to include SERVER.DB.SCHEMA.OBJECTNAME or
2 and 3 part qualified names also:

select sf.fSchemaName( 'sf.MyTestTable')
select sf.fSchemaName( 'SoftworksFramework.sf.MyTestTable')
select sf.fSchemaName( 'SomeServer.SoftworksFramework.sf.MyTestTable')
select sf.fSchemaName( 'MyTestTable')

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @schemaName        nvarchar(128)       -- return value
		,@i                 int                 -- string position index
		,@start             int                 -- start position
		,@chars             int                 -- substring length
		
	set @schemaName = replace(replace(@QualifiedObjectName, '[', ''), ']', '')
	
	set @i = sf.fStringCount(@QualifiedObjectName, N'.')
	
	if @i = 1 
	begin
		set @start  = 1
		set @chars  = charindex( '.', @schemaName ) - 1
	end
	else if @i = 2 
	begin
		set @start  = charindex( '.', @schemaName ) + 1
		set @chars  = charindex( '.', @schemaName, charindex( '.', @schemaName ) + 1) - @start
	end
	else if @i = 3      
	begin
		set @start = charindex( '.', @schemaName, charindex( '.', @schemaName ) + 1) + 1
		set @chars = charindex( '.', @schemaName, charindex( '.', @schemaName, charindex( '.', @schemaName ) + 1) + 1) - @start
	end
	else if @i < 1 or @i > 3
	begin
		set @schemaName = N'?Error'
	end
	
	if @start is not null and @schemaName not like N'?%' set @schemaName = substring(@schemaName, @start, @chars)
	
	return(@schemaName)
	
end
GO
