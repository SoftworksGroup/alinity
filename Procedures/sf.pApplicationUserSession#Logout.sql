SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUserSession#Logout]
   @ApplicationUserSessionGUID uniqueidentifier				= null													-- GUID of the session record to set inactive
as
/*********************************************************************************************************************************
Sproc		: Application User Session  - Logout
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: Marks the current user session as inactive
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year	| Change Summary
				: ------------|-------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| Nov		2012	|	Initial version
				: Tim Edlund	| Jun		2018	|	Removed logic that copied values of previous user profile properties to the current 
																			session.  The original logic to the copying was implemented in September 2014.
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure is called when the user presses the logout button. It marks the user session record inactive and deletes any
property records that might have been created during the session.  If session properties are not deleted they are attached
to a new session the next time the same user logs in. This does not generally cause a problem, however, in order to minimize
table size and clean-up properties no longer used due to upgrades, they are deleted when the logout option is called.

Note that if no GUID is passed to identify the user's current session, then the current session of the active user will be closed.  
If there happen to be multiple sessions opened, all are closed.

Example
-------

<TestHarness>
  <Test Name = "CleanUp" IsDefault ="true" Description="Logs in an active user at random, sets a property then logs out ensuring 
        user session is inactive and no property records remain.">
    <SQLScript>
      <![CDATA[
declare
	 @userName							nvarchar(75)
	,@applicationUserSID		int
	,@propertyValue					xml = cast(N'<root>This is a test</root>' as xml)

select top (1)
	 @userName						= au.UserName												              -- select active user at random
	,@applicationUserSID	= au.ApplicationUserSID
from
	sf.ApplicationUser au		
where
	au.IsActive = 1
order by
	newid()

delete 
	sf.ApplicationUserSession 
where
	ApplicationUserSID = @applicationUserSID									              -- remove past login history to simplify result sets

exec sf.pApplicationUser#Authorize													              -- login (produces first record set)
	 @UserName				= @userName
	,@IPAddress				= '10.0.0.1'
	
exec sf.pApplicationUserSessionProperty#Set																-- set a test property
	@PropertyName = 'HelloWorld'
 ,@PropertyValue = @propertyValue

exec sf.pApplicationUserSession#Logout																		-- logout
	
select
	 aus.UserName
	,aus.IsActive
from
	sf.vApplicationUserSession aus
where
	aus.UserName = @userName																								-- IsActive should be 0

select                                                                    -- ensure no properties remain (blank record set)
	 ausp.PropertyName
	,ausp.PropertyValue
from 
	sf.ApplicationUserSession					aus
join
	sf.ApplicationUserSessionProperty ausp on aus.ApplicationUserSessionSID = ausp.ApplicationUserSessionSID
where
	aus.ApplicationUserSID = @applicationUserSID

    ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
      <Assertion Type="ScalarValue" ResultSet="2" Row="1" Column="2" Value="0"/>
      <Assertion Type="EmptyResultSet" ResultSet="3"/>
      <Assertion Type="ExecutionTime" Value="00:00:05"/>
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute 
	@ObjectName = 'sf.pApplicationUserSession#Logout'

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on

begin

	declare
		 @errorNo 													int = 0														-- 0 no error, if < 50000 SQL error, else business rule
		,@ON																bit = cast(1 as bit)							-- constants to reduce repetitive casting syntax
		,@OFF																bit = cast(0 as bit)	
		,@applicationUserSID								int																-- key of user session logging out

	begin try

		if @ApplicationUserSessionGUID is null 
		begin
			set @applicationUserSID = sf.fApplicationUserSessionUserSID()
		end
		else
		begin
			
			select
				@applicationUserSID = aus.ApplicationUserSID
			from
				sf.ApplicationUserSession aus
			where
				aus.RowGUID = @ApplicationUserSessionGUID													-- if record is not found, no error is raised

		end

		if @applicationUserSID is not null
		begin
			
			update
				sf.ApplicationUserSession
			set
				 IsActive			= @OFF																							-- mark the session inactive
				,UpdateTime   = sysdatetimeoffset()
			where
				ApplicationUserSID = @applicationUserSID
			and
				IsActive = @ON																										

		end

	end try
	
	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch
	
	return(@errorNo)
	
end
GO
