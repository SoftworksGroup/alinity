SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFormatPostalCode]
(
	 @PostalCode	      varchar(10)																					-- postal code string to format
)
returns varchar(10)
as
/*********************************************************************************************************************************
ScalarF		: Format Postal Code
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: Returns postal code formatted to match Softworks standard
History		: Author(s)  	| Month Year		| Change Summary
					: ------------|---------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Nov	2012	    |	Initial version

Comments	
--------
This function is used for formatting postal codes for display in the UI and for storage in the database.  The function should be
called between the <PreInsert> and <PreUpdate> tags of table #Insert and #Update procedures to format postal codes before
they are inserted or updated into the database - e.g.

		--! <PreInsert>
		-- Tim Edlund | Nov 2012
		-- Format the postal code to match the system standard.

		set @PostalCode	= sf.fFormatPostalCode(@PostalCode)
		--! </PreInsert>

Once the value is saved it should be redisplayed to the UI to show the user the revised format. 

DB MODELLING REQUIREMENT
-----------------------
This function is designed to work with a column data type of "varchar(10)" only!  You must set the postal code columns to
this type and length to use this function.  

Formatting Standard
-------------------
The formatting standard supported by this function uses a space between the first 3 and last 3 characters of 6 character
postal codes.  If the code contains 5 character positions, it is assumed to be a zip and no spaces are introduced. If the
string has 9 character positions, it is assumed to be a 5 + 4 zip and is formatted accordingly.  Any other format is 
returned as provided. Return results are always uppercase.

If NULL is passed in, NULL is returned.

The best way to understand the formatting standard is through examples.  See the Example block below for details.

Example
-------
select sf.fFormatPostalCode('t5t1c7')
select sf.fFormatPostalCode('54123')
select sf.fFormatPostalCode('54321 1234')
select sf.fFormatPostalCode('5432!11234')
select sf.fFormatPostalCode('54321-1234')
select sf.fFormatPostalCode('t5.-t1c7')

------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @postalCodeOut                          varchar(25)									-- return value
		,@i																				int													-- index counter
		,@maxLen																	int													-- loop limit - length of string
		,@nextChar																varchar(1)									-- next character to process

	if @PostalCode is not null
	begin

		-- remove all characters that are not letters or digits

		set @postalCodeOut = ''	
		set @maxLen = len(@PostalCode)
		set @i			= 0

		while @i < @maxLen
		begin
			set @i += 1
			set @nextChar = substring(@PostalCode, @i, 1)
			if charindex(@nextChar, '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ') > 0 set @postalCodeOut = cast(@postalCodeOut + @nextChar as varchar(10))
		end

		if len(@postalCodeOut) = 9
		begin
			set @postalCodeOut = left(@postalCodeOut, 5) + '-' + substring(@postalCodeOut, 6, 4)
		end
		else if len(@postalCodeOut) = 6
		begin
			set @postalCodeOut = left(@postalCodeOut, 3) + ' ' + substring(@postalCodeOut, 4, 3)
		end
		else
		begin
			set @postalCodeOut = @PostalCode
		end

	end

	return(upper(@postalCodeOut))

end
GO
