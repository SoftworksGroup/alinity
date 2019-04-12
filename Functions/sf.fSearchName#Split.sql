SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fSearchName#Split]
(
	 @SearchName											nvarchar(150)											    -- text containing the name values to search
)
returns @name table
(
	 LastName													nvarchar(35)													-- last name value parsed from @SearchName
	,FirstName												nvarchar(30)													-- first name value parsed from @SearchName
	,MiddleNames											nvarchar(30)													-- middle name value parsed from @SearchName

)
as
/*********************************************************************************************************************************
TableF	 : Search Name Split
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Parses name search string provided into last, first and middle name components formatted and ready for "LIKE" search
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-------------------------------------------------------------------------------------------
				 : Tim Edlund   | Jun 2012			| Initial Version (as sproc)
				 : Tim Edlund		| Jan	2014		  | Updated algorithm to support multi-word last names like "van der hoff"
				 : Tim Edlund		| Jan 2014			| Moved code to a table function to allow more convenient calling from wizard UI's. The
																					procedure version was updated to call this function to avoid duplicating the logic.

Comments  
--------
This is a helper function used by routines which search against name.  The name values are assumed to reside in sf.Person which
is the basis of the data types and lengths of parameters.  The routine parses the search string provided in @SearchName
into 1 or more of the 3 name parts returned as output.  

The procedure assumes that if a comma is included in the string, then the last name component has been provided to the left of the 
comma followed the first name a space and a middle name.  If no comma is included but one or more spaces exist within the trimmed
string, then the logic assumes the first name is provided first.  If a second space exists then the middle name is next followed
by the last name.  If only 2 strings exist within the text provided then they are assumed to be first and last name components.
A single string is assumed to the last name.

The procedure also formats and prepares the values for searching using a LIKE operator by putting a '%' character at the end
of the output values (if not null).  Another library function replaces ? and * characters with the SQL wild-cards of % and _ in 
case they user has placed those into the string. 

Note that if a user wants to search for a multi-word last name only - without a first name, then they must put a comma at the end 
of the string.  This is so that the algorithm can distinguish between that case and the situation where a first and last name are
separated by a space.

declare
	 @searchName											nvarchar(150)										      -- test parameter 
	,@lastName												nvarchar(35)
	,@firstName												nvarchar(30)
	,@middleNames											nvarchar(30)
	,@i																tinyint

set @i = 0

while @i < 9
begin

	set @i += 1

	if @i = 1 or @i = 9 set @SearchName = 'Edlund, Tim E'
	if @i = 2 set @SearchName = 'Van Man, Tim'
	if @i = 3 set @SearchName = 'Van Der Hoff, Tim E'
	if @i = 4 set @SearchName = '  Edlund, Tim   '
	if @i = 5 set @SearchName = 'Tim E Edlund'
	if @i = 6 set @SearchName = 'Tim Edlund'
	if @i = 7 set @SearchName = 'Edlund'
	if @i = 8 set @SearchName = ' Van Der Hoff   ,    '
	
	select
		 @searchName  TestParameter
		,sn.*
	from
		sf.fSearchName#Split( @searchName ) sn

end
------------------------------------------------------------------------------------------------------------------------------- */

begin	

	declare
		 @lastName													nvarchar(35)									    -- last name value parsed from @SearchName
		,@firstName													nvarchar(30)									    -- first name value parsed from @SearchName
		,@middleNames												nvarchar(30)									    -- middle name value parsed from @SearchName		
		,@comma														  tinyint														-- comma character position used in parse
		,@space1														tinyint														-- space character position used in parse
		,@space2														tinyint														-- position of a second space character

	set @SearchName = ltrim(rtrim(@SearchName))															-- remove all leading and trailing spaces

	while charindex(N' ,', @SearchName) > 0																	-- remove internal spaces before commas
	begin
		set @SearchName = replace(@SearchName, N' ,', ',')
	end

	while charindex(N', ', @SearchName) > 0																	-- remove internal spaces after commas
	begin
		set @SearchName = replace(@SearchName, N', ', ',')
	end

	while charindex(N'  ', @SearchName) > 0																	-- remove internal double spaces
	begin
		set @SearchName = replace(@SearchName, N'  ', ' ')
	end

	set @comma = charindex(N',', @SearchName)																-- check for comma 

	-- if the string contains a comma, everything to the left of the comma 
	-- is treated as the last name to support multi-word last names like
	-- "Van Der Hoff, Tim"

	if @comma > 1
	begin
		set @space1		= charindex(N' ', @SearchName, @comma + 1)							-- check for 1st space after comma
	end
	else
	begin
		set @space1 = charindex(N' ', @SearchName)														-- check for 1st space - no comma
	end

	set @space2 = charindex(N' ', @SearchName, @space1 + 1)									-- check for 2nd space after 1st space

	if @comma > 1	and @space1 > 1																																			-- comma and space found - assume "Last,First Middle" format	
	begin
		set @lastName			= ltrim(rtrim(left(@SearchName, @comma - 1)))
		set @firstName		= ltrim(rtrim(substring(@SearchName, @comma + 1, @space1 - @comma - 1)))
		set @middleNames	= ltrim(rtrim(substring(@SearchName, @space1 + 1, 30)))
	end
	else if @comma > 1																																								-- comma found - no space found - assume "Last,First" format	
	begin
		set @lastName			= ltrim(rtrim(left(@SearchName, @comma - 1)))				
		set @firstName		= ltrim(rtrim(substring(@SearchName, @comma + 1, 30)))
	end
	else if @space1 > 1 and @space2 > 1																																-- no comma, 2 spaces - assume "First Middle Last" format	
	begin
		set @firstName		= ltrim(rtrim(left(@SearchName, @space1 - 1)))
		set @middleNames	= ltrim(rtrim(substring(@SearchName, @space1 + 1, @space2 - @space1 - 1)))
		set @lastName			= ltrim(rtrim(substring(@SearchName, @space2 + 1, 30)))
	end
	else if @space1 > 1																																								-- 1 space only  - assume "First Last" format
	begin
		set @firstName			= ltrim(rtrim(left(@SearchName, @space1 - 1)))				
		set @lastName				= ltrim(rtrim(substring(@SearchName, @space1 + 1, 30)))
	end
	else
	begin
		set @lastName = convert(nvarchar(35), @SearchName)																							-- no comma or spaces - assume last only
	end
		
	-- ensure any remaining zero length strings are set back to null

	if len(@lastName)			= 0 set @lastName			= null
	if len(@firstName)		= 0 set @firstName		= null
	if len(@middleNames)	= 0 set @middleNames	= null

	-- replace file-system style wild cards and add a trailing "%" to any not null name part

	if @lastName    is not null set @lastName     =  cast(sf.fSearchString#Format(@lastName)    as nvarchar(35))                  
	if @firstName   is not null set @firstName    =  cast(sf.fSearchString#Format(@firstName)   as nvarchar(30))
	if @middleNames is not null set @middleNames  =  cast(sf.fSearchString#Format(@middleNames) as nvarchar(30)) 

	insert
		@name
	(
		 LastName
		,FirstName
		,MiddleNames
	) select
		 @lastName
		,@firstName
		,@middleNames
				
	return

end
GO
