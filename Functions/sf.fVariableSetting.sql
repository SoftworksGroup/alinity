SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fVariableSetting]
	(
		 @VariableName				nvarchar(128)
		,@LineContent					nvarchar(max)
	) returns nvarchar(1000)
as
/*********************************************************************************************************************************
Function  : Variable Setting  [NOTE: THIS FUNCTION ALSO APPEARS IN SGISTUDIO - BE SURE TO APPLY CHANGES IN BOTH PROJECTS!]
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: parses source code line to return value the provided variable is set to
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Oct 2011		| Initial version
				: Tim Edlund	| Dec	2012		| Fixed bug where N' was being replaced where it did not start the string

Comments	
--------
This function is used to parse a source code line and return from it, the value a variable is set to. The function is used for
documenting and indexing business rule settings in the CheckFcn% procedures.  When providing the @VariableName, be sure to
provide the leading "@".  For example: '@defaultMessageText'.

Example
-------

declare
	 @lineContent			nvarchar(max) = 'set @defaultMessageText   = N''?Some default message text ...'  -- establish default message 
	,@variableName		nvarchar(128) = '@defaultMessageText'
	
print (sf.fVariableSetting(@VariableName, @LineContent))
select sf.fVariableSetting(N'@errorMessageSCD', 'set @errorMessageSCD    = ''ValueIsRequired.CancelledReason''')

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @variableSetting			nvarchar(1000)																														-- return value
		,@i										int																																				-- character index position

	set @LineContent = replace(replace(@LineContent, char(13), ''), char(10), '')											-- strip CR/LF's
	set @LineContent = replace(@LineContent, 'set ', '')																							-- strip variable setting syntax
	set @LineContent = replace(@LineContent, 'select ', '')																						-- developer may use SELECT
	set @LineContent = replace(ltrim(rtrim(@LineContent)), char(9), ' ')															-- replace tabs with single space

	while charindex(N'  ', @LineContent) > 0
	begin
		set @LineContent = ltrim(rtrim(replace(@LineContent, '  ', ' ')))																-- replace 2 spaces with 1
	end

	set @LineContent = ltrim(replace(@LineContent, @VariableName + N' =', ''))												-- remove variable assignment prefix
	set @LineContent = ltrim(replace(@LineContent, @VariableName + N'=', ''))													-- with or without space

	if @LineContent like N'N''%' set @LineContent = substring(@LineContent, 2, 1000)										-- replace Unicode if it starts the assignment
	set @LineContent = ltrim(rtrim(replace(@LineContent, '''''','''')))																-- replace double quotes with singles							

	set @i = charindex('--', @LineContent)
	if @i > 0 set @LineContent = left(@LineContent, @i-1)																							-- strip inline comment if any

	-- strip leading/ending single quote
								
	set @LineContent = ltrim(rtrim(@LineContent))
	if left(@LineContent, 1)	= N'''' set @LineContent = substring(@LineContent, 2, len(@LineContent) - 1)							
	if right(@LineContent, 1) = N'''' set @LineContent = left(@LineContent, len(@LineContent) -1 )
	
	set @variableSetting = convert(nvarchar(1000), ltrim(rtrim(@LineContent)))

	return(@variableSetting)

end
GO
