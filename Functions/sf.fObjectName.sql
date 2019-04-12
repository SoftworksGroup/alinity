SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fObjectName]
	(
	@QualifiedObjectName       nvarchar(257)
	)
returns nvarchar(128)
as
/*********************************************************************************************************************************
Function: Object Name
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the object-name component of a fully qualified object that may also include the server, database and schema
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| November 2011		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to isolate the ending segment (the name portion) from a fully or partially qualified object name which could
contain segments for schema, database and server.  Note that the function does not check if the object exists in the current 
database.  The function is a string manipulation utility.  See also examples below:

Example:
--------

The function allows the object name to include SERVER.DB.SCHEMA.OBJECTNAME or
2 and 3 part qualified names also:

select sf.fObjectName( 'sf.MyTestTable')
select sf.fObjectName( 'SoftworksFramework.sf.MyTestTable')
select sf.fObjectName( 'SomeServer.SoftworksFramework.sf.MyTestTable')
select sf.fObjectName( 'MyTestTable')
select sf.fObjectName('ValueIsRequired.CancelledReason')

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @objectName        nvarchar(128)       -- return value
		,@i                 int                 -- string position index
		,@start             int                 -- start position
		,@chars             int                 -- substring length
		
	set @objectName = replace(replace(@QualifiedObjectName, '[', ''), ']', '')
	
	set @i = sf.fStringCount(@QualifiedObjectName, N'.')
	
	if @i = 1 
	begin
		set @start  = charindex( '.', @objectName ) + 1
	end
	else if @i = 2 
	begin
		set @start  = charindex( '.', @objectName, charindex( '.', @objectName ) + 1) + 1
	end
	else if @i = 3      
	begin
		set @start = charindex( '.', @objectName, charindex( '.', @objectName, charindex( '.', @objectName ) + 1) + 1) + 1
	end
	
	if @i between 1 and 3
	begin
		set @chars      = len(@QualifiedObjectName) - @start + 1
		set @objectName = substring(@objectName, @start, @chars)
	end
	
	return(@objectName)
	
end
GO
