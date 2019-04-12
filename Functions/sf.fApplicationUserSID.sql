SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fApplicationUserSID]
(			
	@UserName																			nvarchar(75)							-- login of user to return key value for
)
returns int
as
/*********************************************************************************************************************************
Function: User SID
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Returns the key of the sf.ApplicationUser record for the given user name
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Sep 2015		|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function returns the key (ApplicationUserSID) of the application user table.  The function is NOT dependent on the user
having been logged in (this function does not involve session).  The function is useful for determining whether a profile 
exists for a given user name.

Example
-------

<TestHarness>
	<Test Name = "UserName" IsDefault ="true" Description="Passes valid user name for lookup.">
		<SQLScript>
			<![CDATA[
declare                                                                   
	 @userName															nvarchar(75)

select top (1)
	 @userName	= au.UserName
from
	sf.ApplicationUser au
order by
	newid()

select 
	sf.fApplicationUserSID(@userName) ApplicationUserSID

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.fApplicationUserSID'
	,@DefaultTestOnly = 1 

------------------------------------------------------------------------------------------------------------------------------- */

begin
	return(select au.ApplicationUserSID from sf.ApplicationUser au where au.UserName = @UserName)
end
GO
