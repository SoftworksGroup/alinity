SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fEmailDomainRoot]
(			
	 @EmailAddress							varchar(150)																-- email address to extract root domain from
)
returns varchar(50)
as
/*********************************************************************************************************************************
ScalarF	: Email Domain Root 
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the root domain in the email address provided - e.g. returns "softworks" for email address "tim.e@softworks.ca"
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Mar		2014	|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function is used primarily to populate the EmailDomainRoot column in sf.Notification.  The function parses the email address
to return the root of the domain.  This is the portion between the "@" sign and the ".".  The domain root is used in throttling 
email so that servers do not become blacklisted by sending too many emails to a domain in a short period of time. 

Example
-------

<TestHarness>
  <Test Name="CheckNotification" IsDefault="true" Description="Selects a sf.Notification record at random to pass its email address 
        to the function then compares to the Email Domain Root stored in the record.">
    <SQLScript>
      <![CDATA[
      
select top (1)
	 n.EmailDomainRoot
	,sf.fEmailDomainRoot(n.EmailAddress)			CalculatedEmailDomainRoot
	,(case when n.EmailDomainRoot = sf.fEmailDomainRoot(n.EmailAddress) then 'OK' else 'ERROR - DOMAIN ROOTS DO NOT AGREE' end) TestResult
from
	sf.Notification n
where
  n.EmailAddress is not null
order by
	newid()
 
]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="3" Value="OK"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fEmailDomainRoot'

------------------------------------------------------------------------------------------------------------------------------- */
begin

		declare
			 @i									int																							-- string parsing position
			,@j									int																							-- string parsing position
			,@emailDomainRoot		varchar(50)																			-- return value

		if @EmailAddress is not null
		begin
			
			set @i = charindex('@', @emailAddress) + 1
			set @j = charindex('.', @EmailAddress, @i) - 1
			if @i > 0 and @j > 0 set @emailDomainRoot = substring(@emailAddress, @i, (@j - @i + 1))

		end

		return(@emailDomainRoot)

end
GO
