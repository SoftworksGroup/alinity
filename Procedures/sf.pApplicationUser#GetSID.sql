SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUser#GetSID]
(			
	@UserName																			nvarchar(75)							-- login of user to return key value for
)
as
/*********************************************************************************************************************************
Function: User Session UserName
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the application username for the current connection
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Sep 2015		|	Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure returns the key (ApplicationUserSID) of the application user table in a single row, single column data set.  The 
procedure is NOT dependent on the user having been logged in (this function does not involve session).  The procedure is useful 
for determining whether a profile exists for a given user name.

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

exec sf.pApplicationUser#GetSID
	@UserName = @userName

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02"/>
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'sf.pApplicationUser#GetSID'
	,@DefaultTestOnly = 1 

------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)

	begin try

		if @UserName is null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  = 'BlankParameter'
				,@MessageText = @errorText output
				,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1        = '@UserName'
 
			raiserror(@errorText, 18, 1)

		end

		select au.ApplicationUserSID from sf.ApplicationUser au where au.UserName = @UserName

	end try
 
	begin catch
		exec @errorNo  = sf.pErrorRethrow
	end catch
 
	return(@errorNo)
 
 end
GO
