SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fParamValue]
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
				:							|								|
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This is a general parameter parsing function.  A specific parameter-value pairs passed in the @stringToParse will be extracted 
and returned.  The parameter name is provided in @paramName.  The parameter is always returned as a string. 

The function is useful where comment or description columns are being used to carry additional columns for which no permanent column
exists in the data structure.  In general use of specific columns (especially those of type "sparse") is preferred however, where the
data structure cannot be modified, use of text columns to store column-like information may be required.

The parameter provided in the @stringToParse must follow a specific format (example shown):

				{Department=ALS}												-- a business unit code value
				{Manager=mark.d}												-- a manager's user code value

White space before or after the {} brackets and the = sign is ignored.

If the @paramName is not found in the string passed in then NULL is returned.

Example
-------

select sf.sParamValue('this is some preamble {Department=ALS}, {Manager=mark.d} and something else', 'manager')
select sf.sParamValue('this is some preamble {Department=ALS}, {  Manager=  mark.d} and something else', 'manager') 	
select sf.sParamValue('this is some preamble {Department  =  ALS   }, {Manager=mark.d} and something else', 'dEparTment') 	 
select sf.sParamValue('{Department=ALS   }','dEparTment') 	 
select sf.sParamValue('{Department=ALS}, {Manager=mark.d}', 'BadParamName') 	-- returns NULL 	
select sf.sParamValue('{Department=ALS}, Manager=mark.d}', 'Manager') 				-- no opening { - returns NULL 
select sf.sParamValue('{Department=ALS}, {Manager=mark.d', 'Manager') 				-- no closing } - returns NULL 
select sf.sParamValue('{Department=ALS}, {Manager mark.d}', 'Manager') 			-- no "="				- returns NULL 
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
