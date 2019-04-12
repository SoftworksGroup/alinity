SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsGrantedToUserSID]
(
	 @ApplicationGrantSCD			varchar(30)				-- the grant to check
	,@ApplicationUserSID			int								-- the user system ID to check grant for
)
returns bit
as
/*********************************************************************************************************************************
ScalarF		: Is Granted To UserSID
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: returns bit indicating whether a specific user passed as @ApplicationUserSID has the grant passed in
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Sep	2010		|	Initial version

Comments	
--------
This function is used for displaying grants of users other than the currently logged in use.  To check grants for the current
user, call the sf.IsGranted() function.  

Note that if the user passed in has the "SysAdmin" grant, then the return value is always 1 (ON), since SA's have access to all
functions of the system.

This procedure is essentially a wrapper for sf.fIsGrantedToUserName.  The lookup logic is modularized into that function for 
all "fIsGranted%" functions in the framework.

Example
-------

select sf.fIsGrantedToUserSID('SomeGrant', 1000001)  IsGranted

------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @userName			nvarchar(75)			-- the user name to check grant for

	select
		@userName = au.UserName
	from
		sf.ApplicationUser au
	where
		au.ApplicationUserSID = @ApplicationUserSID

	return( sf.fIsGrantedToUserName(@ApplicationGrantSCD, @userName) )

end
GO
