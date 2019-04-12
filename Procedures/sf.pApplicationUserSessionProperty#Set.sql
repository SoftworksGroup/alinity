SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sf].[pApplicationUserSessionProperty#Set]
   @PropertyName                        varchar(100)                      -- property to set (unique with Session SID)
	,@PropertyValue												xml																-- value to set the property to	
	,@ApplicationUserSessionSID						int						= null							-- ID of the user session to set property for 	
as
/*********************************************************************************************************************************
Sproc    : Application User Session Property - Get
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Sets (new or updates) an sf.ApplicationUserSession property value
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
         : ------------ | ----------- |-------------------------------------------------------------------------------------------
         : Tim Edlund   | Sep		2014	| Initial Version
----------------------------------------------------------------------------------------------------------------------------------

Comments
--------
This procedure is used to store JSON, XML or other data structures to the database for the given user session.  Storing these 
structures is required to ensure larger data objects can be persisted through screen refreshes which cannot be easily stored
on the client.

This procedure is a wrapper that calls either pApplicationUserSessionProperty#Insert or #Update depending on whether the 
given PropertyName has already been defined for the session.  

If the @ApplicationUserSessionSID parameter is not specified, the procedure looks up the key for the active user session.  
"Active" user sessions are set via sf.pApplicationUserSession#Set. 

If a user is not logged in, an error is returned.  The procedure determines whether a user is logged in by checking for the
application user session value which is stored in the sf.ApplicationUserSession table.  This value is set by the procedure
sf.pApplicationUser#Authorize which is called at start-up of the application to set the "context info" with this value.  To
test this procedure then, you must establish a user session value.  See example syntax below.

No data set is returned.

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

    ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="RowCount" ResultSet="1" Value="1" />
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
		,@blankParam												nvarchar(100)											-- tests for required parameters
		,@applicationUserSessionPropertySID	int																-- key of property record if already set

  begin try

		if @PropertyValue is null set @blankParam = N'@PropertyValue'
		if @PropertyName	is null set @blankParam = N'@PropertyName'

    if @BlankParam is not null
    begin

      exec sf.pMessage#Get
         @MessageSCD  = 'BlankParameter'
        ,@MessageText = @errorText output
        ,@DefaultText = N'A parameter (%1) required by the database procedure was left blank.'
        ,@Arg1        = @blankParam

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

		-- check for the property 

		select
			@applicationUserSessionPropertySID = ausp.ApplicationUserSessionPropertySID
		from
		  sf.ApplicationUserSessionProperty ausp
	  where
			ausp.ApplicationUserSessionSID = @ApplicationUserSessionSID
		and
			ausp.PropertyName = @PropertyName


		if @applicationUserSessionPropertySID is null
		begin

			exec sf.pApplicationUserSessionProperty#Insert
				 @ApplicationUserSessionSID = @ApplicationUserSessionSID
				,@PropertyName							= @PropertyName
				,@PropertyValue							= @PropertyValue

		end
		else
		begin

			exec sf.pApplicationUserSessionProperty#Update
				 @ApplicationUserSessionPropertySID = @applicationUserSessionPropertySID
				,@ApplicationUserSessionSID					= @ApplicationUserSessionSID
				,@PropertyName											= @PropertyName
				,@PropertyValue											= @PropertyValue

		end

  end try

  begin catch
    exec @errorNo = sf.pErrorRethrow
  end catch

  return(@errorNo)

end
GO
