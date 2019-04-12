SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fApplicationUserSessionSID] 
(			
)
returns int
as
/*********************************************************************************************************************************
Function: User Session System ID
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: returns the primary key value (ApplicationUserSessionSID) of the active user session
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund  | April 2010    |	Initial Version
				:	Adam Panter	|	June 2014			| Updating test to use an isnull
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This function returns the SID of the sf.ApplicationUserSession record associated with the current database connection.  The 
function will return NULL unless the current session context has been set (see the procedure "sf.pUserSession#Set").  

Example
-------
select																																		-- retrieve SID - context is not set
	sf.fApplicationUserSessionSID()

exec sf.pUserSession#Set																									-- set the context
	 @userName							= 'SAMPLE.COM\c.brown'
	,@ipAddress							= '10.0.0.1'
	
select																																		-- now retrieve the SID using this function
	sf.fApplicationUserSessionSID()

<TestHarness>
  <Test Name="ApplicationUserSessionSIDTest" IsDefault="true" Description="Confirms that ApplicationUserSessionSID is functioning 
	as expected.">
    <SQLScript>
      <![CDATA[

				select 					 
					case when (IsNUll(sf.fApplicationUserSessionSID(), 0)	= convert(int, IsNull(context_info(), 0))	) then 1 else 0 end
			]]>
    </SQLScript>
    <Assertions>      
      <Assertion Type="ScalarValue" ResultSet="1" Row="1" Column="1" Value="1"/>
      <Assertion Type="ExecutionTime" Value="00:00:01" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Extract
	@ObjectName = 'sf.fApplicationUserSessionSID'
------------------------------------------------------------------------------------------------------------------------------- */
begin

	declare 
		 @applicationUserSessionSID			int											              -- pk of current UserSession record

	set @applicationUserSessionSID	= convert(int, context_info())					-- the value must be in context_info!
		
	return(@applicationUserSessionSID)
	 
end
GO
