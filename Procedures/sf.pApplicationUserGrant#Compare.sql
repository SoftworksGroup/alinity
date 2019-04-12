SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUserGrant#Compare]
(
    @SourceApplicationUserSID  int                                        -- source application user to return grant information for
   ,@TargetApplicationUserSID  int                                        -- target application user to return grant information for
)   
as
/*********************************************************************************************************************************
Procedure : Application User Grants- Compare
Notice    : Copyright © 2014 Softworks Group Inc.
Summary   : Returns XML of all application grants for the given users and the status of each (granted or not), organized by module
History   : Author(s)			| Month Year  | Change Summary
          : --------------|-------------|-----------------------------------------------------------------------------------------
          : Cory Ng				| Oct		2012	| Initial version
					: Tim Edlund		|	Dec		2012	| Updated to reflect change from date types for effective/expiry to datetimeoffset
 
Comments  
--------
This procedure is used to display the differences in application grants between two users.  The procedure returns an XML document 
including all grants available in the system and the status of whether or not that grant is currently in effect for the users. A 
radio button/on-off style UI can then be provided displaying the differences in the users grant assignments. The IsEqual bit is 
used to indicate on the UI if the users share the same grant assignment.

The XML returned is hierarchical so that each grant appears within the module it applies to.

Example:

declare                                                                   -- select an application users at random
   @sourceApplicationUserSID	int
  ,@targetApplicationUserSID	int

select top (1)
  @sourceApplicationUserSID = au.ApplicationUserSID
from
  sf.ApplicationUser au
order by 
  newid()

select top (1)
  @targetApplicationUserSID = au.ApplicationUserSID
from
  sf.ApplicationUser au
where
	au.ApplicationUserSID <> @sourceApplicationUserSID
order by 
  newid()
 
exec sf.pApplicationUserGrant#Compare
  @SourceApplicationUserSID = @sourceApplicationUserSID
 ,@TargetApplicationUserSID = @targetApplicationUserSID
  
-------------------------------------------------------------------------------------------------------------------------------- */
 
set nocount on

begin
 
  declare
     @errorNo											int = 0                             -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                   nvarchar(4000)                      -- message text (for business rule errors)    
		,@blankParm										varchar(50)													-- tracks if any required parameters are not provided     
    ,@ON                          bit = cast(1 as bit)                -- used on bit comparisons to avoid multiple casts
    ,@OFF                         bit = cast(0 as bit)                -- used on bit comparisons to avoid multiple casts 
    
  begin try
  
		-- check parameters

    if @SourceApplicationUserSID  is null set @blankParm = 'SourceApplicationUserSID'
    if @TargetApplicationUserSID  is null set @blankParm = 'TargetApplicationUserSID'

		if @blankParm is not null
		begin

			exec sf.pMessage#Get
				 @MessageSCD  	= 'BlankParameter'
				,@MessageText 	= @errorText output
				,@DefaultText 	= N'A parameter (%1) required by the database procedure was left blank.'
				,@Arg1					= @blankParm

			raiserror(@errorText, 18, 1)
		
		end   
    
    if not exists( select 1 from sf.ApplicationUser where ApplicationUserSID = @SourceApplicationUserSID )
    begin

      exec sf.pMessage#Get
         @MessageSCD  = 'RecordNotFound'
        ,@MessageText = @errorText output
        ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
        ,@Arg1        = 'sf.ApplicationUser'
        ,@Arg2        = @SourceApplicationUserSID

			raiserror(@errorText, 18, 1)

    end
    
    if not exists( select 1 from sf.ApplicationUser where ApplicationUserSID = @TargetApplicationUserSID )
    begin

      exec sf.pMessage#Get
         @MessageSCD  = 'RecordNotFound'
        ,@MessageText = @errorText output
        ,@DefaultText = N'The %1 record was not found. Record ID = "%2". The record may have been deleted or the identifier is invalid.'
        ,@Arg1        = 'sf.ApplicationUser'
        ,@Arg2        = @TargetApplicationUserSID

			raiserror(@errorText, 18, 1)

    end
    
    -- return the data as XML

     select
      (
        select
           Module.ModuleName 
          ,isnull(sau.DisplayName, '')				SourceDisplayName																			-- isnull is applied so the display name is nested within the Module in the XML
          ,isnull(tau.DisplayName, '')				TargetDisplayName
          ,ApplicationGrant.ApplicationGrantName
          ,ApplicationGrant.ApplicationGrantSID       
          ,ApplicationGrant.ApplicationGrantSCD      
          ,ApplicationGrant.UsageNotes
          ,isnull(saug.IsActive, @OFF)																													SourceUserIsActive   
          ,isnull(taug.IsActive, @OFF)																													TargetUserIsActive
          ,case 
						when isnull(saug.IsActive, @OFF) = isnull(taug.IsActive, @OFF) then @ON 
						else @OFF 
					 end																																									IsEqual
        from
          sf.vApplicationUser        sau
        cross join
          sf.vApplicationGrant       ApplicationGrant																								-- XML element names are named after table alias
        join
          sf.vLicense#Module         Module  on ApplicationGrant.ModuleSCD = Module.ModuleSCD				-- XML element names are named after table alias
        left outer join
					sf.vApplicationUserGrant saug on ApplicationGrant.ApplicationGrantSID = saug.ApplicationGrantSID and saug.ApplicationUserSID = @SourceApplicationUserSID
				join
					sf.vApplicationUser				tau on 1=1
				left outer join
					sf.vApplicationUserGrant taug on ApplicationGrant.ApplicationGrantSID = taug.ApplicationGrantSID and taug.ApplicationUserSID = @TargetApplicationUserSID
        where
          sau.ApplicationUserSID = @SourceApplicationUserSID
        and
					tau.ApplicationUserSID = @TargetApplicationUserSID
        order by 
					 Module.ModuleName  
          ,ApplicationGrant.ApplicationGrantName
        for xml auto, type, elements, root('ApplicationGrants')
      )																																													ApplicationGrants
  end try
 
  begin catch
    exec @errorNo = sf.pErrorRethrow                                      -- catch the error, rollback if pending, and re-throw
  end catch
 
  return(@errorNo)
 
end
GO
