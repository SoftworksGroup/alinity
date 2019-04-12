SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFormatFileAsName]
(
	 @LastName				nvarchar(35)					-- last name
	,@FirstName				nvarchar(30)					-- first name
	,@MiddleNames			nvarchar(30)					-- middle names
)
returns nvarchar(65)
as 
/*********************************************************************************************************************************
Function: Format File As Name
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: takes the individual components of a name and formats them as LastName,FirstName MiddleNames
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Kim Doring	| Dec		2012			|	Initial version
				: Tim Edlund	| Dec		2012			| Code review and refinements
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function accepts all the components of a name and formats them as a string used for alphabetical name sorting.  Any of the
values may be passed as NULL. If any of the values are not-null, a string will be returned. If all values are null, then null is
returned.  The format of the returned string is as follows:

LastName,FirstName MiddleNames

Because the combined length of all parameters is much shorter than the maximum return length, an algorithm is applied to set 
precedence to the components of the name that will be included in the return value.  The precedence ensures that the full last
name is always included in the result.  All of the first name is also included unless doing so would eliminate even the first
character of the middle name.  It is desirable to include at least the first initial of the middle name to help distinguish 
between individuals. As much of the middle name is included in the output as remain in the maximum character positions of the 
return value.  This can result in a truncated middle name. 

Leading and trailing spaces are trimmed from parameters before processing. No case conversions are applied.

Examples:
--------

select top (1)
	sf.fFormatFileAsName(p.LastName, p.FirstName, p.MiddleNames) FileAsName
from
	sf.Person p
order by
	newid()
	
select
	 sf.fFormatFileAsName( 'Jones'	, 'John'  , 'Stanley Peter')		FullName
	,sf.fFormatFileAsName( 'Jones'	,  null   ,  null					 )		OnlyLast
	,sf.fFormatFileAsName(  null		, 'John'  ,  null					 )		OnlyFirst
	,sf.fFormatFileAsName(  null		,  null		, 'Stanley Peter')		OnlyMiddle
	,sf.fFormatFileAsName(  null		, 'John'  , 'Stanley Peter')		NullLast
	,sf.fFormatFileAsName( 'Jones'	,  null   , 'Stanley Peter')		NullFirst
	,sf.fFormatFileAsName( 'Jones'	, 'John'  ,  null					 )		NullMiddle
	,sf.fFormatFileAsName(  null		,  null		,  null					 )		AllNull
	,sf.fFormatFileAsName( 'LASTAbcdefghijklmnopqrstuvwxyz-0123', 'FIRSTAbcdefghijklmnopqrstuvwxy','MIDDLE') TruncMiddle
	,sf.fFormatFileAsName( 'LASTAbcdefghijklmnopqrstuvwxyz-0123', 'FIRSTAbcdefghijklmnopqrstuvwxy', null)		 TruncFirst
	,sf.fFormatFileAsName( 'LASTAbcdefghijklmnopqrstuvwxyz-0123',  null														,'MIDDLEAbcdefghijklmnopqrstuvwx') NullFirstTruncMiddle

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @formattedName					nvarchar(65)																	-- return value
		,@MAXLENGTH							int															= 65					-- NOTE: must match return parameter length!
		,@first									nvarchar(30)																	-- NOTE: must match lengths in the call syntax!
		,@middle								nvarchar(30)
		,@prefix								nvarchar(35)
		,@remaining							int																						-- tracks remaining character positions
		,@cutOff								int																						-- track substring max length for next component

	-- format inbound parameters

	set @LastName					= ltrim(rtrim(@LastName))													-- remove leading and trailing spaces
	set @FirstName				= ltrim(rtrim(@FirstName))
	set @MiddleNames			= ltrim(rtrim(@MiddleNames))
	
	if len(@LastName)			= 0 set @LastName			= null											-- set zero length strings to null
	if len(@FirstName)		= 0	set @FirstName		= null
	if len(@MiddleNames)	= 0 set @MiddleNames	= null

	if isnull(len(@LastName) + 1,0)	+ isnull(len(@FirstName) + 1, 0) 
	+ isnull(len(@MiddleNames), 0) <= @MAXLENGTH
	begin

		set @formattedName =
			cast																																	
			(
				rtrim																															-- remove trailing space if necessary
				(
						isnull(@LastName		+ ', ', '')
					+ isnull(@FirstName		+ ' ', '')
					+ isnull(@MiddleNames      , '')
				)
				as nvarchar(65)
			)

	end
	else
	begin

		set @remaining = @MAXLENGTH
		set @remaining -= (isnull(len(@LastName),0))
	
		if @remaining > 0
		begin

			-- ensure there is at least enough space for the first character 
			-- of the middle name if one was provided, 1 space characters, and 1 comma

			if @MiddleNames is not null and @FirstName is not null 
			and (@remaining - (len(@FirstName) + 3)) < 0
			begin
				set @cutOff = len(@FirstName) - 3																	-- allows for 1 middle name character
			end																																	-- 1 space after first name and 1 comma after last name
			else if @MiddleNames is null and @FirstName is not null
			and (@remaining - (len(@FirstName) + 1)) < 0
			begin
				set @cutOff = len(@FirstName) - 1																	-- allows for 1 comma after last name
			end
			else
			begin
				set @cutOff = @remaining
			end

			set @first = left(@FirstName, @cutOff)

			if @MiddleNames is not null and @FirstName is not null
			begin
				set @remaining -= (isnull(len(@first),0) + 1)											-- allow for space between first and middle
			end

		end

		if @remaining > 0 
		begin
	
			if @MiddleNames is not null 
			and (@remaining - (len(@MiddleNames) + 1)) < 0
			begin
				set @cutOff = @remaining - 1
			end
			else
			begin
				set @cutOff = @remaining
			end
		
			set @middle			= left(@MiddleNames, @cutOff)
		
		end

		set @formattedName =
			cast																																	
			(
				rtrim																															-- remove trailing space if necessary
				(
						isnull(@LastName	+ ',', '')
					+ isnull(@first			+ ' ', '')
					+ isnull(@middle				 , '')
				)
				as nvarchar(65)
			)
	
	end

	if right(@formattedName, 1) = N','	set @formattedName = left(@formattedName, len(@formattedName) - 1)
	
	if len(@formattedName) = 0 set @formattedName = NULL										-- len() trims trailing spaces!	

	return @formattedName

end
GO
