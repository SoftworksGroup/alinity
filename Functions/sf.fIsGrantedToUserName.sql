SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sf].[fIsGrantedToUserName]
(
	 @ApplicationGrantSCD			varchar(30)				-- the grant to check
	,@UserName								nvarchar(75)			-- the user name to check grant for
)
returns bit
as
/*********************************************************************************************************************************
ScalarF		: Is Granted To UserName
Notice		: Copyright © 2014 Softworks Group Inc.
Summary		: returns bit indicating whether a specific user passed as @UserName has the grant passed in
History		: Author(s)  	| Month Year	| Change Summary
					: ------------|-------------|-----------------------------------------------------------------------------------------
					: Tim Edlund	| Sep	  2010  |	Initial version
					: Tim Edlund  | June  2012  | Updated logic to allow "SysAdmin" to appear after a module prefix string
					: Tim Edlund  | July  2012  | Update to check to ensure grant is in effect (IsActive in #Ext view)
																				This change was required to enforce terms defined in Effective-Expiry date columns
																				added to the sf.ApplicationUserGrant table.
					: Tim Edlund	| Aug		2014	| Restructured selects to avoid using views.  This reduces the circular references for
																				tools creating schema compares.
					: Tim Edlund	| Jun 2018		| Added support for SGIAdmin user to allow operations by development team.

Comments	
--------
This function is used for displaying grants of users other than the currently logged in use.  To check grants for the current
user, call the sf.IsGranted() function.  

Note that if the user passed in has the "SysAdmin" grant, then the return value is always 1 (ON), since SA's have access to all
functions of the system.  In some configuration the SysAdmin grant is placed into a specific module in order to control where
the grant appears on the user interface. This function checks the last 8 characters for the keyword string "SysAdmin" so that
grants such as "MyModule.SysAdmin" will also return true.

Example
-------

select sf.fIsGrantedToUserName('SomeGrant', 'tim.e@sgi')  IsGranted

------------------------------------------------------------------------------------------------------------------------------- */

begin
	
	declare
		 @isGranted				bit		= 0						-- return value

	if @UserName = 'SGIAdmin'
	begin
		set @isGranted = cast(1 as bit)
	end
	else if exists
	(
	select
		1
	from
		sf.ApplicationUserGrant aug
	join
		sf.ApplicationGrant			ag		on aug.ApplicationGrantSID = ag.ApplicationGrantSID
	join
		sf.ApplicationUser			au		on aug.ApplicationUserSID = au.ApplicationUserSID
	where
		(ag.ApplicationGrantSCD = @ApplicationGrantSCD or right(ag.ApplicationGrantSCD,8) = 'SysAdmin')	-- has the grant or is SA
	and
		au.UserName						= @UserName																																-- for the user name provided
	and
		sf.fIsActive(aug.EffectiveTime, aug.ExpiryTime)  = cast(1 as bit)                               -- ensures grant is currently in effect
	) 
	begin
		set @isGranted = cast(1 as bit)
	end
	else
	begin
		set @isGranted = cast(0 as bit)
	end

	return(@isGranted)

end
GO
