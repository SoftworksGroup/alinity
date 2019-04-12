SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFormatDisplayName]
(
	 @LastName											nvarchar(35)														-- surname - "Edlund"
	,@FirstName											nvarchar(30)														-- given name - "Tim"
)
returns nvarchar(65)
as 
/*********************************************************************************************************************************
Function: Display Name
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Combines first name and last name (no middle, no prefix) into a name label for use on the UI and reports
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| Dec		2012			|	Initial version
					Kim Doring		Dec		2012			| Code review and refinements
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function accepts first name and last name components to create a display label.  The function combines the values
with a space in-between - First Last.  This function is used where less space is available to display the name than
the sf.fFormatFileAsName() or sf.fFormatFullName() functions require.  The fFormatDisplayName() function is commonly 
used on the status bar to indicate who the logged in user is.

Leading and trailing spaces are trimmed from parameters before processing. No case conversions are applied.

Example
-------

select top (1)
	sf.fFormatDisplayName(p.LastName, p.FirstName) DisplayName
from
	sf.Person p
order by
	newid()

select
	 sf.fFormatDisplayName( 'LASTAbcdefghijklmnopqrstuvwxyz-0123','FIRSTAbcdefghijklmnopqrstuvwxy') TruncFirst
	,sf.fFormatDisplayName( 'Edlund',  NULL			)	OnlyLast
	,sf.fFormatDisplayName(  NULL		, 'Tim'			)	OnlyFirst
	,sf.fFormatDisplayName(  NULL		,  NULL			)	AllNull

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @formattedName					nvarchar(65)																	-- return value
		,@MAXLENGTH							int															= 65					-- NOTE: must match return parameter length!

	-- format inbound parameters

	set @LastName					= ltrim(rtrim(@LastName))													-- remove leading and trailing spaces
	set @FirstName				= ltrim(rtrim(@FirstName))
	
	if len(@LastName)			= 0 set @LastName			= null											-- set zero length strings to null
	if len(@FirstName)		= 0	set @FirstName		= null

	set @formattedName = cast(rtrim(isnull(@FirstName	 + ' ','') + isnull(@LastName,''))	as nvarchar(65))

	if len(@formattedName) = 0 set @formattedName = NULL										-- len() trims trailing spaces!	
	return @formattedName

end
GO
