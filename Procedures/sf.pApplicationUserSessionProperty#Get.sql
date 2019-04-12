SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUserSessionProperty#Get]
   @PropertyName                        varchar(100)                      -- property to return (unique with session SID)
	,@ApplicationUserSessionSID						int						= null							-- ID of the user session to retrieve property for 	
as
/*********************************************************************************************************************************
Sproc    : Application User Session Property - Get
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Returns the user Session property value for the requested property name (as a dataset)
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
         : ------------ | ----------- |-------------------------------------------------------------------------------------------
         : Tim Edlund   | Sep		2014	| Initial Version
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------
This procedure returns a user Session property value (not entity) for the use session and property name passed in.  If the 
@ApplicationUserSessionSID parameter is not specified, the procedure looks up the key for the active user session.  "Active"
user sessions are set via sf.pApplicationUserSession#Set. 

If a user is not logged in, an error is returned.  The procedure determines whether a user is logged in by checking for the
application user session value which is stored in the sf.ApplicationUserSession table.  This value is set by the procedure
sf.pApplicationUser#Authorize which is called at start-up of the application to set the "context info" with this value.  To
test this procedure then, you must establish a user session value.  See example syntax below.

If the property specified is not found, an error is raised advising the UI the property was not set. 

Example
-------

<TestHarness>
  <Test Name = "SetProperty" IsDefault ="true" Description="Sets a test property to a simple string cast as XML.">
    <SQLScript>
      <![CDATA[
declare
	 @applicationUserName      varchar(50)
	,@propertyValue							xml = cast(N'<root>This is a test</root>' as xml)

select top (1)
  @applicationUserName = UserName
from
  sf.ApplicationUser
order by
  newid()

exec sf.pApplicationUser#Authorize
  @UserName   = @applicationUserName                                      -- establish a session
 ,@IPAddress = '10.0.0.1'

exec sf.pApplicationUserSessionProperty#Set																-- set a test property
	@PropertyName = 'HelloWorld'
 ,@PropertyValue = @propertyValue
 
exec sf.pApplicationUserSessionProperty#Get																-- retrieve it
  @PropertyName = 'HelloWorld'

    ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
      <Assertion Type="RowCount" ResultSet="2" Value="1" />
      <Assertion Type="ExecutionTime" Value="00:00:03"/>
    </Assertions>
  </Test>
</TestHarness>


-------------------------------------------------------------------------------------------------------------------------------- */
set nocount on

begin

  declare
     @errorNo                           int = 0                           -- 0 no error, <50000 SQL error, else business rule
    ,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
    ,@propertyValue											xml																-- value of the property to return as a dataset

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

		if @ApplicationUserSessionSID is null set @ApplicationUserSessionSID = sf.fApplicationUserSessionSID()

    if @ApplicationUserSessionSID is null
    begin

      exec sf.pMessage#Get
         @MessageSCD  = 'NoActiveSession'
        ,@MessageText = @errorText output
        ,@DefaultText = N'A valid user session has not be established. User authorization must be completed before this process can continue.'

      raiserror(@errorText, 18, 1)

    end

		-- return the property value (or raise error if not found)

    select
      @propertyValue = ausp.PropertyValue
    from
      sf.ApplicationUserSessionProperty ausp
    where
      ausp.ApplicationUserSessionSID = @ApplicationUserSessionSID
    and
      ausp.PropertyName = @PropertyName

		if @propertyValue is null
		begin

      exec sf.pMessage#Get
         @MessageSCD  = 'PropertyNotSet'
        ,@MessageText = @errorText output
        ,@DefaultText = N'A value for property "%1" was not found.  The property was not set.'
				,@Arg1				= @PropertyName

      raiserror(@errorText, 18, 1)

		end

		select
			@propertyValue PropertyValue

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow
  end catch

  return(@errorNo)

end
GO
