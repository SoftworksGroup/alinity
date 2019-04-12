SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsSysAdmin]
(
)
returns bit
as
/*********************************************************************************************************************************
ScalarF		: Is System Administrator
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: returns bit indicating whether current user has the "SysAdmin" grant
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Sep	2010		|	Initial version

Comments	
--------
This function is used to determine if the user currently logged in has the system administrator grant (SysAdmin).  System 
administrators have access to all functions in the application.

The function is essentially a wrapper for fIsGranted which performs the search for the specific grant type. This function 
is provided for convenience.

Example
-------

exec sf.pUserSession#Set						
	 @UserName				= 'tim.e@sgi'
	,@IPAddress				= '10.0.0.1'

select sf.fIsSysAdmin()	IsSysAdmin

------------------------------------------------------------------------------------------------------------------------------- */

begin
	return(sf.fIsGranted('SysAdmin'))
end
GO
