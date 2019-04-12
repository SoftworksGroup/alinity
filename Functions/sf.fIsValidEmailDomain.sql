SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsValidEmailDomain]
	(
	@EmailAddress		varchar(150)
	)
returns bit
as
/*********************************************************************************************************************************
ScalarF : Email address validation
Notice  : Copyright © 2014 Softworks Group Inc.
Summary : Returns 1 (bit) when the email address domain exists in the valid email domain list
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-------------------------------------------------------------------------------------------
				: Cory Ng			| Sep		2013	| Initial version
				: Tim Edlund	| Nov		2014	| Updated function to treat email domain setting of "*" to allow any email domain.

Comments	
--------
This function checks if the email address domain - the part of the email address after the ".' - exists in the list of valid
email domains. The valid email domain list is defined in sf.ConfigParam through the "ValidEmailDomains" configuration parameter. 
The domains are stored as a comma delimited list.

On some systems the configuration parameter "ValidEmailDomains" may not exist. In this case the function assumes the email
domain is valid (always returns 1).

If the @EmailAddress value is null then 1 (valid) is returned from this function so that, if the column is mandatory, a not-null 
error is raised rather than an error about the email domain.

Example
-------
select
	sf.fIsValidEmailDomain(pea.EmailAddress)  IsEmailDomainValid
from
	sf.PersonEmailAddress pea

------------------------------------------------------------------------------------------------------------------------------- */

begin	

	declare
		  @isValid														bit = cast(0 as bit)						-- return value - set to 1 if valid
		 ,@validEmailDomains									nvarchar(max)										-- the valid email domains stored in the configuration parameter
		 ,@ON																	bit = cast(1 as bit)

	if @EmailAddress is null
	begin
		set @isValid = @ON
	end
	else
	begin

		set @validEmailDomains = sf.fConfigParam#Value('ValidEmailDomains')

		if isnull(@validEmailDomains, N'*') = N'*'
		begin
			set @isValid = @ON
		end
		else
		begin
		
			if exists 
			(
				select
					1
				from
					sf.fSplitString(@validEmailDomains, ',') x
				where
					@EmailAddress like isnull('%' + ltrim(rtrim(x.Item)) , '~')
			)
			begin
				set @isValid = @ON 
			end
			
		end

	end
	
	return(@isValid)
	
end
GO
