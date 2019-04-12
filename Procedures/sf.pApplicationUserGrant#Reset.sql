SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUserGrant#Reset]
	 @DeleteCount                         int   = null     output           -- count of grants deleted
	,@ReturnAsSelect											bit		= 0													-- when 1, @DeleteCount returned as data set
as
/*********************************************************************************************************************************
Sproc    : Application User Grant Reset - WARNING: REMOVES ALL GRANTS EXCEPT FOR ORIGINAL "System Administrator" !!!!
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : this procedure removes all application user grants from the system except for the base SA grant
-----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)   | Month Year    | Change Summary
				 : ------------|---------------|-------------------------------------------------------------------------------------------
				 : Tim Edlund  | May-2010      | Initial Version
         : Tim Edlund  | June  2012    | Updated logic to allow "SysAdmin" to appear after a module prefix string
-----------------------------------------------------------------------------------------------------------------------------------
Comments
--------
This is a utility procedure to be used only in circumstances where application grants exceed limits allowed by the application 
license.  These situations will not occur when the user interface of Synoptec is used for assigning grants.  Grant mismatches with 
the license limit can be created by direct updates in the back-end (tampering) or by installing a license file into a database 
where grants were originally created for a different license file.  The procedure can be used to put the system back into a state 
where login is again allowed and grants can be applied again by the SA.  

This procedure DELETEs all grants in the database except for the "base" system administrator grant.  The base SA grant is the 
first (lowest PK value) SA grant record. In some configuration the SysAdmin grant is placed into a specific module in order to 
control where the grant appears on the user interface. This function checks the last 8 characters for the keyword string 
"SysAdmin" so that grants such as "MyModule.SysAdmin" will also be found.

This procedure does not delete application user accounts.

Ensure the procedure is implemented with a explanatory confirmation screen when implemented in the UI so that accidental grant 
deletion does not occur.  While CDC tracks these deletions, there is no support for recovering deleted grants!
 
Example
-------
select * into #grants from sf.ApplicationUserGrant												-- backup grants to temp table
	 
exec sf.pApplicationUserGrantReset																				-- BE SURE you have script to re-insert grants!!
	@ReturnAsSelect = 1

select * from sf.vApplicationUserGrant

set identity_insert sf.ApplicationUserGrant on

insert
	sf.ApplicationUserGrant
	(
		 ApplicationUserGrantSID
		,E1
		,E2
		,RowGUID
		,CreateUser
		,CreateTime
		,UpdateUser
		,UpdateTime
	)	
select
	*
from
	#grants
where
	ApplicationUserGrantSID not in (select ApplicationUserGrantSID from sf.ApplicationUserGrant)

set identity_insert sf.ApplicationUserGrant off

select * from sf.vApplicationUserGrant

drop table #grants

-------------------------------------------------------------------------------------------------------------------------------- */
set nocount on

begin
 
	declare
		 @errorNo                           int = 0                           -- 0 no error, <50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@errorCode                         varchar(75)                       -- code to identify error Program (logged)
		,@baseGrantSID											int																-- pk value of first SA grant record (remains in table)
	
	set @DeleteCount = 0                                                     -- initialize output parameter
	
	begin try

		select 
			@baseGrantSID = min(aug.ApplicationUserGrantSID) 
		from 
			sf.vApplicationUserGrant aug
		where
			right(aug.ApplicationGrantSCD,8) = 'SysAdmin'

		if @baseGrantSID is null
		begin
		
			exec sf.pMessage#Get
				 @MessageSCD  	= 'SysAdminGrantNotFound'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'No System Administrator grant was located.  A base (SysAdmin) grant is required in order to reset the grant system.'
			
			raiserror(@errorText, 17, 1)
		end

		-- remove all but the base SysAdmin record

		begin transaction

		update																												-- update audit columns first for CDC tracking
			sf.ApplicationUserGrant
		set
			 IsDeleted		= cast(1 as bit)
			,UpdateUser		= sf.fApplicationUserSession#UserName()
			,UpdateTime		= sysdatetimeoffset()
		where
			ApplicationUserGrantSID in
			(
			select
				ApplicationUserGrantSID
			from
				sf.vApplicationUserGrant
			where
				ApplicationUserGrantSID <> @baseGrantSID
			)

		-- and then execute the deletion
		
	  delete 
			sf.ApplicationUserGrant
		where
			ApplicationUserGrantSID in
			(
			select
				ApplicationUserGrantSID
			from
				sf.vApplicationUserGrant
			where
				ApplicationUserGrantSID <> @baseGrantSID
			)

		set @DeleteCount = @@rowcount

		commit
		
	end try
	
	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	if @ReturnAsSelect = 1 select @DeleteCount DeleteCount
	
	return(@errorNo)
	
end
GO
