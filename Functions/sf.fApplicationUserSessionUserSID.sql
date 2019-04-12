SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fApplicationUserSessionUserSID]
(			
)
returns int
as
/*********************************************************************************************************************************
Function: User Session User SID
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the application user SID for the current connection
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Sep 2011		|	Initial Version
				: Tim Edlund	| Apr	2015		| Removed reference to EF views.  By passed select when no session key is in context.
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function returns the application user SID (rather than application user name) on the current connection.  The function is 
only successful returning when the current session has been set with the primary key value. See the procedure: sf.pUserSession#Set.  
If the context has not been set, then NULL is returned.

Example
-------
<TestHarness>
	<Test Name="AuthorizedUser" IsDefault="true" Description="Finds a user with authorization on the application at
	random and establishes a session with that ID and checks to ensure the function returns the matching ID value.
	This test is dependent on sample data having provided at least one authorized user in the database.">
		<SQLScript>
			<![CDATA[

declare
	 @rowGUID							uniqueidentifier
	,@applicationUserSID	int 
	,@userName						nvarchar(75)

select top (1) 
	 @applicationUserSID	= aug.ApplicationUserSID 
	,@userName						= aug.UserName
from
	sf.vApplicationUserGrant aug
where
	aug.ApplicationUserIsActive = cast(1 as bit)
order by 
	newid()

exec sf.pApplicationUser#Authorize
	@UserName   = @userName
 ,@IPAddress = '10.0.0.1'
	
select																																		-- now retrieve the user name using this function
	case
		when sf.fApplicationUserSessionUserSID() = @applicationUserSID
		then 'OK' 
		else 'FAILED'
	end																																			TestResult
from
	sf.ApplicationUser				au
join
	sf.vApplicationUserSession	aus on au.ApplicationUserSID = aus.ApplicationUserSID
where 
	au.UserName = @UserName
and
	aus.IsActive = 1

			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="RowCount" ResultSet="1" Value="1"/>
			<Assertion Type="RowCount" ResultSet="2" Value="1"/>
			<Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="1" Value="OK"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness> 

exec sf.pUnitTest#Execute
	@ObjectName = 'sf.fApplicationUserSessionUserSID'
------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare 
		 @applicationUserSID													int										  -- the application user SID to return
		,@applicationUserSessionSID										int											-- pk of current UserSession record

	set @applicationUserSessionSID	= convert(int, context_info())					-- the pk of UserSession row must be in context_info!

	if @applicationUserSessionSID is not null
	begin
		
		select
			@applicationUserSID = au.ApplicationUserSID
		from
			sf.ApplicationUserSession aus
		join
			sf.ApplicationUser				au		on aus.ApplicationUserSID = au.ApplicationUserSID
		where
			aus.ApplicationUserSessionSID = @applicationUserSessionSID
		and
			aus.IsActive = cast(1 as bit)																				-- only 1 active session allowed (see sf.pApplicationUser#Authorize)	

	end
																		
	return(@applicationUserSID)
	 
end
GO
