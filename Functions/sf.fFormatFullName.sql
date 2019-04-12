SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFormatFullName]
(
	 @LastName											nvarchar(35)														-- surname - "Edlund"
	,@FirstName											nvarchar(30)														-- given name - "Tim"
	,@MiddleNames										nvarchar(30)														-- middle name or middle initial - if any
	,@NamePrefix										nvarchar(35)														-- salutation prefix (e.g. Dr., Mrs., Mr. etc.)
)
returns nvarchar(65)
as 
/*********************************************************************************************************************************
Function: Format Full Name
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Combines non-null name components in a format suitable for addressing: e.g. "Mr. Tim E Edlund"
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year			| Change Summary
				: ------------|-----------------|-----------------------------------------------------------------------------------------
				: Tim Edlund	| Dec		2012			|	Initial version
					Kim Doring		Dec		2012			| Code review and refinements
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function accepts name parameters and a name prefix (salutation).  Any of the values may be passed as NULL. If any of the values
are not-null, a string will be returned. If all values are null, then null is returned.

Because the combined length of all parameters is much shorter than the maximum return length, an algorithm is applied to set 
precedence to the components of the name that will be included in the return value.  The precedence ensures that the full last
name is always included in the result.  All of the first name is also included unless doing so would eliminate even the first
character of the middle name.  It is desirable to include at least the first initial of the middle name to help distinguish 
between individuals. As much of the middle name is included in the output as remain in the maximum character positions of the 
return value.  This can result in a truncated middle name.  If all of the NamePrefix cannot fit in the character positions 
remaining, then none of it is shown. (Truncated name prefixes will not occur).

Leading and trailing spaces are trimmed from parameters before processing. No case conversions are applied.

Example
-------

select top (1)
	sf.fFormatFullName(p.LastName, p.FirstName, p.MiddleNames, np.NamePrefixLabel) FullName
from
	sf.Person p
left outer join
	sf.NamePrefix np on p.NamePrefixSID = np.NamePrefixSID
order by
	newid()

select
	 sf.fFormatFullName( 'LASTAbcdefghijklmnopqrstuvwxyz-0123','FIRSTAbcdefghijklmnopqrstuvwxy'	,'MIDDLEAbcdefghijklmnopqrstuvwx','Mrs.') TruncMiddle
	,sf.fFormatFullName( 'LASTAbcdefghijklmnopqrstuvwxyz-0123','FIRSTAbcdefghijkl'							,'MIDDLE'												 ,'Mrs.') FullLengthName
	,sf.fFormatFullName( 'LASTAbcdefghijklmnopqrstuvwxyz-0123','FIRSTAbcdefghijklm'							,'MIDDLE'												 ,'Mrs.') TruncPrefix
	,sf.fFormatFullName( 'LASTAbcdefghijklmnopqrstuvwxyz-0123','FIRSTAbcdefghijklmnopqrstuvwxy'	, NULL													 ,'Mrs.') NullMiddleTruncFirst
	,sf.fFormatFullName( 'LASTAbcdefghijklmnopqrstuvwxyz-0123', NULL														,'MIDDLEAbcdefghijklmnopqrstuvwx','Mrs.') NullFirstTruncMiddle
	,sf.fFormatFullName( 'Edlund', 'Timothy'	, 'Edmer'	, 'Mr.')	FullName
	,sf.fFormatFullName( 'Edlund', 'Timothy'	,  NULL		, 'Mr.')	NullMiddle
	,sf.fFormatFullName( 'Edlund', 'Tim'			,  NULL		,  NULL)	NullMiddleAndPrefix
	,sf.fFormatFullName(  NULL		, 'Timothy'	, 'Edmer'	, 'Mr.')	NullLast
	,sf.fFormatFullName( 'Edlund',  NULL			,  NULL		,  NULL)	OnlyLast
	,sf.fFormatFullName(  NULL		, 'Tim'			, NULL		,  NULL)	OnlyFirst
	,sf.fFormatFullName(  NULL		,  NULL			, NULL		, 'Mr.')	OnlyPrefix
	,sf.fFormatFullName(  NULL		,  NULL			, NULL		,  NULL)	AllNull

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
	set @NamePrefix				= ltrim(rtrim(@NamePrefix))
	
	if len(@LastName)			= 0 set @LastName			= null											-- set zero length strings to null
	if len(@FirstName)		= 0	set @FirstName		= null
	if len(@MiddleNames)	= 0 set @MiddleNames	= null
	if len(@NamePrefix)		= 0 set @NamePrefix		= null

	if isnull(len(@LastName),0)	+ isnull(len(@FirstName) + 1, 0) 
	+ isnull(len(@MiddleNames) + 1, 0) + isnull(len(@NamePrefix) + 1, 0) <= @MAXLENGTH
	begin

			set @formattedName = 
			cast
			(
					isnull(@NamePrefix		+ ' ','')	
				+ isnull(@FirstName			+ ' ','')
				+ isnull(@MiddleNames		+ ' ','')
				+ isnull(@LastName,'')
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
			-- of the middle name if one was provided, and 2 space characters

			if @MiddleNames is not null and @FirstName is not null 
			and (@remaining - (len(@FirstName) + 3)) < 0
			begin
				set @cutOff = len(@FirstName) - 3																	-- allows for 1 middle name character and
			end																																	-- 1 space after first and middle names
			else if @MiddleNames is null and @FirstName is not null
			and (@remaining - (len(@FirstName) + 1)) < 0
			begin
				set @cutOff = len(@FirstName) - 1																	-- allows for 1 space after first name
			end
			else
			begin
				set @cutOff = @remaining
			end

			set @first = left(@FirstName, @cutOff)
			if @FirstName is not null set @remaining -= (isnull(len(@first),0) + 1)												-- allow for space between first and middle/last

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
			set @remaining -= (isnull(len(@middle),0) + 1)
		
		end

		if @remaining >= len(@NamePrefix) + 1 set @prefix = @NamePrefix

		set @formattedName = 
			cast
			(
					isnull(@prefix		+ ' ','')	
				+ isnull(@first			+ ' ','')
				+ isnull(@middle		+ ' ','')
				+ isnull(@LastName,'')
			as nvarchar(65)
			)
	
	end

	if len(@formattedName) = 0 set @formattedName = NULL										-- len() trims trailing spaces!	

	return @formattedName

end
GO
