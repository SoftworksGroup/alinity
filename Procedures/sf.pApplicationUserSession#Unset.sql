SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUserSession#Unset]
as
/*********************************************************************************************************************************
Sproc		: Application User Session Un-Set
Notice  : Copyright © 2014 Softworks Group Inc.
Summary	: removes the user context setting for the current connection
----------------------------------------------------------------------------------------------------------------------------------
History	: Author(s)  	| Month Year		| Change Summary
				: ------------|---------------|-------------------------------------------------------------------------------------------
				: Tim Edlund	| April 2010		|	Initial version
				:	Tim Edlund	|	March	2011		|	Updated documentation
----------------------------------------------------------------------------------------------------------------------------------
Comments	
--------
This procedure is called primarily from testing routines that need to evaluate procedures called with the user context set and un-set.  
For details about session context and its impact, see sf.pApplicationUserSession#Set.

Example
-------

exec sf.pApplicationUserSession#Set																									-- set context
	 @UserName				= 'c.brown@sample.com'
	,@IPAddress				= '10.0.0.1'
	
select sf.fApplicationUserSession#UserName()																					-- see the application user name

exec sf.pApplicationUserSession#Unset																								-- unset context
	
select sf.fApplicationUserSession#UserName()																					-- see the database user name

------------------------------------------------------------------------------------------------------------------------------- */
set nocount on

begin

	declare
		 @errorNo 													int = 0														-- 0 no error, if < 50000 SQL error, else business rule
		,@contextInfo												binary(128)	= 0										-- to clear context

	begin try
		set context_info @contextInfo
	end try
	
	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch
	
	return(@errorNo)
	
end
GO
