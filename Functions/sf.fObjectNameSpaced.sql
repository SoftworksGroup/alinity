SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fObjectNameSpaced]
	(
	@ObjectName               nvarchar(512)
	)
returns nvarchar(512)
as
/*********************************************************************************************************************************
Function: Object Name Spaced
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the object-name with spaces inserted where changes in case occur (returns a "user friendly name")
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| March   2012		|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function is used to create labels out of object names.  For example the value: ApplicationUserGrant is returned as
"Application User Grant".  The function often provides default values for code descriptions and object labels stored in the 
database, and then which can be updated through the user interface. 

If a schema prefix, or other qualifiers, exist in the string - it is returned within parenthesis at the end of the string.

If the @ObjectName provided is NULL, then NULL is returned.

Example:
--------

select sf.fObjectNameSpaced( 'sf.MyTestTable')                            --> My Test Table (sf)
select sf.fObjectNameSpaced( 'MyTestTable')                               --> My Test Table
select sf.fObjectNameSpaced( 'ApplicationUserGrant')                      --> Application User Grant
select sf.fObjectNameSpaced( 'SomeServer.SoftworksFramework.sf.MyTestTable')    --> My Test Table (SomeServer.SoftworksFramework.sf)

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare	
		 @objectNameSpaced				nvarchar(512)							                  -- string to return; object with spaces inserted
		,@i								        int                 = 1                     -- iterator - over characters in string
		,@isUpper					        bit                                         -- indicates if current character is UPPERcase
		,@isUpperLast			        bit                                         -- indicates if previous character was UPPERcase
		,@char						        nchar(1)                                    -- next character to process
		,@baseObjectName          nvarchar(257)                               -- part of name not including schema/qualifier portion

	set @ObjectName = rtrim(@ObjectName)
	if @ObjectName is not null set @objectNameSpaced = N''									-- initialize output value if parameter is provided

	if @ObjectName like N'%.%' 
	begin
		set @baseObjectName = sf.fObjectName(convert(nvarchar(257), @ObjectName))
	end
	else
	begin
		set @baseObjectName = convert(nvarchar(257), @ObjectName)
	end

	while @i <= len(@baseObjectName)
	begin

		set @char 		= substring(@baseObjectName, @i, 1)
		set @isUpper 	= sf.fIsUpper(@char)

		if @isUpperLast is null
		begin
			set @isUpperLast = @isUpper
		end

		if @isUpperLast = 0 and @isUpper = 1
		begin
			set @objectNameSpaced = convert(nvarchar(512), @objectNameSpaced + ' ' + @char)
		end
		else
		begin
			set @objectNameSpaced = convert(nvarchar(512), @objectNameSpaced + @char)
		end

		set @isUpperLast = @isUpper
		set @i += 1

	end

	if @ObjectName <> @baseObjectName
	begin
		set @objectNameSpaced = @objectNameSpaced + ' (' + replace(@ObjectName, N'.' + @baseObjectName, '' ) + ')'
	end

	return( @objectNameSpaced )
	
end
GO
