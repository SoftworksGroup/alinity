SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fFormatAddressForHTML]
	(
	  @Name           nvarchar(150)					-- addressee name								[any parameter may be passed as null]
	 ,@StreetAddress1 nvarchar(75)	        -- 1st line of street address 
	 ,@StreetAddress2 nvarchar(75)	        -- 2nd line of street address
	 ,@StreetAddress3 nvarchar(75)	        -- 3rd line of street address
	 ,@CityName				nvarchar(30)					-- name of city 
	 ,@StateProvince  nvarchar(30)					-- name or code of state or province
	 ,@PostalCode			varchar(10)						-- postal or zip code
	 ,@CountryName    nvarchar(50)			 		-- name of country
	 )
returns nvarchar(512)
as 
/*********************************************************************************************************************************
Function: Format Address as HTML
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Takes the individual components of an address and formats them into an HTML formatted mailing address block 
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund	| Jan 2014				|	Initial version
----------------------------------------------------------------------------------------------------------------------------------

Comments	
--------
This function accepts all the components of an address and formats them into an address block suitable for HTML rendering. Any 
characters in the address values that require escaping for HTML are replaced.

The function is primarily a wrapper for the sf.fFormatAddress function which returns the same address components formatted as text.
This function adds additional coding to bold face the name, and support line breaks and non-breaking spaces.  

Any parameter may be passed as null and the function will attempt to format the content that is provided according to general 
formatting  rules.  If all parameters are NULL then NULL is returned. See sf.fFormatAddress() for formatting rules and additional
details.

The format returned by the base function for a full address is:

John Jones
Apt 10
123 Any Street
Edmonton, AB  T5R 4T1
Canada

which this function then converts to:  

<strong>John Jones</strong><br/>
Apt 10<br/>
123 Any Street<br/>
Edmonton, AB&nbsp;&nbsp;T5R 4T1<br/>
Canada<br/>

Example:
--------

print (sf.fFormatAddressForHTML 
		(
		'Jon Jones'
		,'Apt 10' 
		,'123 Any Street'
		,null
		,'Edmonton'
		,'AB'
		,'t5r4t1'
		,'Canada'
		))

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare
		 @formattedAddress			nvarchar(512)																	-- return value
		,@CRLF									varchar(10)				= char(13) + char(10)				-- carriage return line feed (constant)

	if @Name is not null set @Name = cast(N'~|' + @name + N'|~' as nvarchar(140)) -- mark name to format in bold AFTER escaping

	set @formattedAddress = cast(sf.fFormatAddress
		(
		@Name          
	 ,@StreetAddress1
	 ,@StreetAddress2
	 ,@StreetAddress3
	 ,@CityName				
	 ,@StateProvince 
	 ,@PostalCode			
	 ,@CountryName   
	 ) as nvarchar(512))

	if @formattedAddress is not null
	begin
		set @formattedAddress = sf.fEscapeForXML(@formattedAddress)																			-- escape special characters
		set @formattedAddress	= replace(@formattedAddress, N'~|', N'<strong>')													-- apply bold mark-up to name component
		set @formattedAddress	= replace(@formattedAddress, N'|~', N'</strong>')
		set @formattedAddress = replace(@formattedAddress, @CRLF, N'<br/>' + @CRLF)											-- insert line breaks (keep CR/LF for source formatting)
		set @formattedAddress = replace(@formattedAddress, N'  ', N'&nbsp;&nbsp;')											-- replace 2 spaces with 2 x escaped spaces
	end

	return(@formattedAddress)

end
GO
