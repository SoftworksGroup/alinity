SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsValidEmail]
	(
	@EmailAddress		varchar(150)
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : Email address validation
Notice  : Copyright © 2014 Softworks Group Inc.
Summary : Returns 1 (bit) when the email address passed in is valid
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Sep		2011  |	Initial version

Comments	
--------
This function checks email address values for valid format.  The method does not use REGEX but rather checks for specific 
requirements and invalid formatting as follows:

 + no embedded spaces
 + '@' can't be the first character of an email address
 + '.' can't be the last character of an email address
 + must be a '.' somewhere after '@'
 + the '@' sign is allowed
 + domain name should end with at least 2 character extension
 + can't have patterns like '.@' and '..'

If the @EmailAddress value is null then 1 (valid) is returned.  If the column is mandatory, a not-null constraint will raise
an error on it.

Example
-------
select
	sf.fIsValidEmail(au.EmailAddress)  IsEmailValid
from
	sf.ApplicationUser au

------------------------------------------------------------------------------------------------------------------------------- */

begin	

	declare
		 @isValid														bit = cast(0 as bit)							-- return value - set to 1 if valid

	if @EmailAddress is null
	begin
		set @isValid = cast(1 as bit)
	end
	else
	begin

		if 
			( 
			charindex(' ',ltrim(rtrim(@EmailAddress))) = 0  
			and left(ltrim(@EmailAddress),1) <> '@'  
			and right(rtrim(@EmailAddress),1) <> '.'  
			and charindex('.',@EmailAddress ,charindex('@',@EmailAddress)) - charindex('@',@EmailAddress ) > 1  
			and len(ltrim(rtrim(@EmailAddress ))) - len(replace(ltrim(rtrim(@EmailAddress)),'@','')) = 1  
			and charindex('.',reverse(ltrim(rtrim(@EmailAddress)))) >= 3  
			and (charindex('.@',@EmailAddress ) = 0 and charindex('..',@EmailAddress ) = 0) 
			) 
		begin
			set @isValid = 1
		end

	end
	
	return(@isValid)
	
end
GO
