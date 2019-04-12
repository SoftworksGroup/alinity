SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fApplicationUserSession#UserName] 
(			
)
returns nvarchar(75)
as
/*********************************************************************************************************************************
Function: User Session UserName
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the application username for the current connection
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|---------------------------------------------------------------------------------------------
				: Tim Edlund  | Apr 2010    |	Initial Version
				:	Tim Edlund	|	May	2014		| Updated to return the user name in UPPERCASE when the user is a database user. Previously
																			the return value was always lower case but this change makes it more clear when changes
																			are being made by a database ID versus an application user ID. 
				: Tim Edlund	| Apr	2015		| Removed reference to EF views.  By passed select when no session key is in context.
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function returns the application user name (rather than database user name) on the current connection.  The function is only 
successful returning when the current session has been set with the primary key value.  See the procedure: sf.pUserSession#Set.  
If the context has not been set, then the current database user name is returned.

Example
-------

<TestHarness>
	<Test Name="AuthorizedUser" IsDefault="true" Description="Finds a user with authorization on the application at
	random and establishes a session with that ID and checks to ensure the function returns the matching user name.
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
		when sf.fApplicationUserSession#UserName() = @userName 
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
	@ObjectName = 'sf.fApplicationUserSession#UserName'

------------------------------------------------------------------------------------------------------------------------------- */

begin

	declare 
		 @userName 													nvarchar(75)											-- the application user name to return
		,@applicationUserSessionSID					int																-- pk of current UserSession record

	set @applicationUserSessionSID	= convert(int, context_info())				  -- the pk of ApplicationUserSession row must be in context_info!

	if @applicationUserSessionSID is not null
	begin
		
		select
			@userName = au.UserName
		from
			sf.ApplicationUserSession aus
		join
			sf.ApplicationUser				au		on aus.ApplicationUserSID = au.ApplicationUserSID
		where
			aus.ApplicationUserSessionSID = @applicationUserSessionSID
		and
			aus.IsActive = cast(1 as bit)																				-- only 1 active session allowed (see sf.pApplicationUser#Authorize)	

	end
	
	if @userName is null set @userName = upper(suser_sname())								-- if context not set, return the db USER in uppercase
	
	return(@userName)
	 
end
GO
