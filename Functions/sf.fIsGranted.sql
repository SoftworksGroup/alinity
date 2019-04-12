SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsGranted]
(
	@ApplicationGrantSCD			varchar(30)				-- the grant to check
)
returns bit
as
/*********************************************************************************************************************************
ScalarF		: Is Granted 
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: returns bit indicating whether current user has the grant passed in
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Sep	2010		|	Initial version

Comments	
--------
This function is used to enable/disable various options in the system according to access granted to the user.  Bit columns are 
typically configured onto the entity based on calls to this function.  The UI, in turn, binds the bit to enable/disable controls.

Note that if the current user has the "SysAdmin" grant, then the return value is always 1 (ON), since SA's have access to all
functions of the system.

This procedure is essentially a wrapper for sf.fIsGrantedToUserName.  The lookup logic is modularized into that function for 
all "fIsGranted%" functions in the framework.

Example
-------

exec sf.pUserSession#Set						
	 @UserName				= 'tim.e@sgi'
	,@IPAddress				= '10.0.0.1'

select sf.fIsGranted('SomeGrant') IsGranted
------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @userName			nvarchar(75) = sf.fApplicationUserSession#UserName()	-- the user name to check grant for

	return( sf.fIsGrantedToUserName(@ApplicationGrantSCD, @userName) )

end
GO
