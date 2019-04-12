SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fParsedParamValue]
(
	 @stringToParse					nvarchar(max)						-- string value containing e.g. {Manager=monica.l}, {Department=HCS}
	,@paramName							nvarchar(100)						-- a variable name to search for in the string:  'Department' 
)
returns nvarchar(max)
as
/*********************************************************************************************************************************
ScalarF	: Parameter Value
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: parses and returns a parameter value from the string passed in
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | March 2011    |	Initial Version
				:	Tim Edlund	|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This is a parameter parsing function which succeeds based on specific formatting being followed in the supplied string. The 
function is mostly supported for backward compatibility with previous versions of the framework. The preferred means of 
storing application parameters is to use the sf.ConfigParam table.  This function, however, can be used on systems where 
sf.ConfigParam cannot be supported. The function is useful where comment or description columns are being used to carry additional 
columns for which no permanent column exists in the data structure. In general use of sf.ConfigParam or even specific columns 
in other structures is preferred however, where the data structure cannot be modified, use of text columns to store column-like 
information may be required.

The parameter to be returned must be defined in the string - using supported syntax (see below). The parameter name is provided in 
@paramName.  The parameter is always returned as a string. 

The parameter provided in the @stringToParse must follow a specific format (example shown):

				{Department=ALS}												-- a business unit code value
				{Manager=mark.d}												-- a manager's user code value

White space before or after the {} brackets and the = sign is ignored.

If the @paramName is not found in the string passed in then NULL is returned.

Example
-------

select sf.sfParamValue('this is some preamble {Department=ALS}, {Manager=mark.d} and something else', 'manager')
select sf.sfParamValue('this is some preamble {Department=ALS}, {  Manager=  mark.d} and something else', 'manager') 	
select sf.sfParamValue('this is some preamble {Department  =  ALS   }, {Manager=mark.d} and something else', 'dEparTment') 	 
select sf.sfParamValue('{Department=ALS   }','dEparTment') 	 
select sf.sfParamValue('{Department=ALS}, {Manager=mark.d}', 'BadParamName') 	-- returns NULL 	
select sf.sfParamValue('{Department=ALS}, Manager=mark.d}', 'Manager') 				-- no opening { - returns NULL 
select sf.sfParamValue('{Department=ALS}, {Manager=mark.d', 'Manager') 				-- no closing } - returns NULL 
select sf.sfParamValue('{Department=ALS}, {Manager mark.d}', 'Manager') 			-- no "="				- returns NULL 
------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @start																	smallint												-- starting character position 
		,@end																		smallint												-- ending character position
		,@paramNameLen													smallint												-- length of parameter name
		,@parsedValue														nvarchar(max)										-- parsed parameter value to return	

	if @stringToParse is not null
	begin

		set @paramName = replace(@paramName, ' ', '') + N'='

		set @stringToParse			= replace(@stringToParse, ' ', '')							-- remove spaces for consistent parsing
		set @stringToParse			= replace(@stringToParse, char(13), '')					-- remove carriage returns, line feeds and tabs
		set @stringToParse			= replace(@stringToParse, char(10), '')
		set @stringToParse			= replace(@stringToParse, char(9), '')

		set @start							= charindex(@paramName, @stringToParse)					-- find the parameter name in the string
		set @end								= charindex('}', @stringToParse, @start)				-- find the closing bracket - after the value
		set @paramNameLen				= len(@paramName)																-- add 1 to account for "=" character
		
		if @start > 0 and @end > 0
		begin

			if (@end-1) - (@start + @paramNameLen) >= 1 	
			begin
				set @parsedValue	= substring(@stringToParse, @start + @paramNameLen, @end - @start - @paramNameLen) 
			end

		end

	end

	return(@parsedValue)

end
GO
