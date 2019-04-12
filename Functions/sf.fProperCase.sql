SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fProperCase]
(
	 @inputString as nvarchar(max)
) 
returns nvarchar(max) 
as
/*********************************************************************************************************************************
View    : Proper Case
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns input string converted to mixed case
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| February 2011 | Initial version
				: Tim Edlund	| January  2014	| Removed casing exception for "DI" which caused "Disabled" to format as "DiSabled"

Comments	
--------
This function converts text to mixed case.  Pattern matching (regex) is applied to handle common person-name situations where 
simply capitalizing after a space would not produce the correct result.  See examples for details.

Example
-------
select dbo.sfProperCase('this is a title')					--> This is a title
select dbo.sfProperCase('THIS IS ALSO a title')			--> This is also a title
select dbo.sfProperCase('ed mcdonald')							--> Ed McDonald			
select dbo.sfProperCase('JANET o''donnel')					--> Janet O'Donnel
select dbo.sfProperCase('the_underscore_test.')			--> The_Underscore_Test
select dbo.sfProperCase('the-hyphen-test.')					--> The-Hyphen-Test
select dbo.sfProperCase(null)												--> NULL

select dbo.sfProperCase(
	  'it''s crazy! i couldn''t believe kate mcdonald, leo dicaprio, (terrence) trent d''arby (circa the 80''s), and jada '
	+ ' pinkett-smith all showed up to [cHris o''donnell''s] party...donning l''oreal lIpstick! They''re heading to '
	+ 'o''neil''s pub later on t''nite.' )

-->It's Crazy! I Couldn't Believe Kate McDonald, Leo DiCaprio, (Terrence) Trent D'Arby (Circa The 80's), And Jada  Pinkett-Smith 
All Showed Up To [Chris O'Donnell's] Party...Donning L'Oreal Lipstick! They're Heading To O'Neil's Pub Later On T'nite.

--------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare
		 @properCase			nvarchar(max)		= N''											-- return value
		,@reset						bit							= 1												-- whether next char requires uppercase
		,@i								int							= 1												-- position in string (character index)
		,@nextChar				nchar(1)																	-- value of the next character	
		
	if @inputString is null 
	begin
		set @properCase = null
	end
	else
	begin

		while @i <= len(@inputString)
		begin
			
			select 
				 @nextChar		= substring(@inputString,@i,1)
				,@properCase	= @properCase + (case when @reset=1 then upper(@nextChar) else lower(@nextChar) end)
				,@reset				= 
					(case when
						(case 
							when substring(@inputString, @i - 4, 5) like '_[a-z] [DOL]''' then 1
							when substring(@inputString, @i - 4, 5) like '_[a-z] [M][C]'	then 1 
							else 0 
						end) = 1 
					then 1
					else 
						(case	when @nextChar like N'[a-zA-Z]' or @nextChar in ('''') then 0 else 1 end)
					end)
				,@i = @i +1
		end
		
	end
	
	return(@properCase)

end
GO
