SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUserProfileProperty#Get]
   @PropertyName                        varchar(100)                      -- property to return (unique with UserName)
as
/*********************************************************************************************************************************
Sproc    : Application User Profile Property - Get
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Returns the user profile property entity for the requested property name - if it exists or a default is available
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year   | Change Summary
         : ------------ | ------------ |-------------------------------------------------------------------------------------------
         : Tim Edlund   | April   2010 | Initial Version
         : Tim Edlund   | July    2012 | Added documentation.  Updated to current coding standards. Added error checking.
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------
This procedure returns a user profile property entity (row) for the currently logged in user and given @PropertyName.

If a user is not logged in, an error is returned.  The procedure determines whether a user is logged in by checking for the
application user SID value which is stored in the sf.ApplicationUserSession table.  This value is set by the procedure
sf.pApplicationUser#Authorize which is called at start-up of the application to set the "context info" with this value.  To
test this procedure then, you must establish a user session value.  See example syntax below.

The property returned also matches the criteria for @PropertyName. If the current user session does not have this property defined
a row is created for it as long as a default for this property name is defined in the sf.ConfigParam table.  If no default
is defined and there is no definition of the given property name for the current session, then an error is returned.  Since
the sf.ApplicationUserProfileProperty table does not allow NULL property values, a default must be defined for new properties.

Example
-------

declare
  @applicationUserName      varchar(50)

select top (1)
  @applicationUserName = UserName
from
  sf.ApplicationUser
order by
  newid()

exec sf.pApplicationUser#Authorize
  @UserName   = @applicationUserName                                      -- establish a session
 ,@IPAddress = '10.0.0.1'

exec sf.pApplicationUserProfileProperty#Get
  @PropertyName = 'MainDashboard'

-------------------------------------------------------------------------------------------------------------------------------- */
set nocount on

begin

  declare
     @errorNo                           int = 0                           -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
    ,@applicationUserSID                int                               -- currently logged in user - used to search for profile
    ,@userName                          nvarchar(75)                      -- currently logged in user name for error message

  begin try

    if @PropertyName is null
    begin

      exec sf.pMessage#Get
         @MessageSCD  = 'BlankParameter'
        ,@MessageText = @errorText output
        ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
        ,@Arg1        = '@PropertyName'

      raiserror(@errorText, 18, 1)

    end

    set @applicationUserSID = sf.fApplicationUserSessionUserSID()

    if @applicationUserSID is null
    begin

      exec sf.pMessage#Get
         @MessageSCD  = 'NoActiveSession'
        ,@MessageText = @errorText output
        ,@DefaultText = N'A valid user session has not be established. User authorization must be completed before this process can continue.'

      raiserror(@errorText, 18, 1)

    end

    if not exists
    (
      select
        1
      from
        sf.ApplicationUserProfileProperty aupp
      where
        aupp.ApplicationUserSID = @applicationUserSID
      and
        aupp.PropertyName = @PropertyName
    )
    begin

      -- the property doesn't exist for this user so create one from
      -- a default if a configuration parameter is defined for it

      insert into
        sf.ApplicationUserProfileProperty
      (
         ApplicationUserSID
        ,PropertyName
        ,PropertyValue
      ) select
           @applicationUserSID
          ,@PropertyName
          ,isnull(cp.ParamValue, cp.DefaultParamValue)
        from
          sf.ConfigParam  cp
        where
          cp.ConfigParamSCD = @PropertyName

        if @@rowcount <> 1
        begin

          select
            @userName = au.UserName
          from
            sf.ApplicationUser au
          where
            au.ApplicationUserSID = @applicationUserSID

          exec sf.pMessage#Get
             @MessageSCD  = 'PropertyNotDefined'
            ,@MessageText = @errorText output
            ,@DefaultText = N'The requested user profile property "%1" has not been established for "%2". A default may need to be established for the property to avoid future errors.'
            ,@Arg1        = @PropertyName
            ,@Arg2        = @userName

          raiserror(@errorText, 18, 1)

        end

      end

      -- now return the result from the entity view

      select
        --!<ColumnList DataSource="sf.vApplicationUserProfileProperty" Alias="aupp">
         aupp.ApplicationUserProfilePropertySID
        ,aupp.ApplicationUserSID
        ,aupp.PropertyName
        ,aupp.PropertyValue
        ,aupp.UserDefinedColumns
        ,aupp.ApplicationUserProfilePropertyXID
        ,aupp.LegacyKey
        ,aupp.IsDeleted
        ,aupp.CreateUser
        ,aupp.CreateTime
        ,aupp.UpdateUser
        ,aupp.UpdateTime
        ,aupp.RowGUID
        ,aupp.RowStamp
        ,aupp.PersonSID
        ,aupp.CultureSID
        ,aupp.AuthenticationAuthoritySID
        ,aupp.UserName
        ,aupp.LastReviewTime
        ,aupp.LastReviewUser
        ,aupp.IsPotentialDuplicate
        ,aupp.IsTemplate
        ,aupp.GlassBreakPassword
        ,aupp.LastGlassBreakPasswordChangeTime
        ,aupp.ApplicationUserIsActive
        ,aupp.AuthenticationSystemID
        ,aupp.ApplicationUserRowGUID
        ,aupp.IsDeleteEnabled
        ,aupp.IsReselected
        ,aupp.IsNullApplied
        ,aupp.zContext
        --!</ColumnList>
      from
        sf.vApplicationUserProfileProperty aupp
      where
        aupp.ApplicationUserSID = @applicationUserSID
        and
        aupp.PropertyName = @PropertyName

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow
  end catch

  return(@errorNo)

end
GO
