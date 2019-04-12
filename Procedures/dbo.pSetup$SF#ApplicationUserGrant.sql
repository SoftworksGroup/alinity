SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#ApplicationUserGrant]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
  ,@Language                      char(2)                                 -- language to install for
  ,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.ApplicationUserGrant data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.ApplicationUserGrant master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Christian T	| April		2012  | Initial Version
         : Tim Edlund   | July    2012  | Added support for ChangeAudit column
				 : Christian T	| May			2014	| Added test harness
				 : Tim Edlund		| Oct			2016	| Changed selection of primary sys-admin grant to "ADMIN.SYSADMIN".  This requires that all
																					products using the framework include this grant code in sf.ApplicationGrant.  
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the dbo.ApplicationUserGrant table with the settings required by the current version of the 
application. If a record is missing it is added. Changes to existing user grants are not made. One MERGE statement is used to 
carryout all operations.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#ApplicationUserGrant
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.ApplicationUserGrant

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#ApplicationUserGrant'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table
	
	declare
    @setup                             table
    (
       ID																int           identity(1,1)
			,ApplicationUserSID								int						not null
			,ApplicationGrantSID							int						not null
      ,ChangeAudit                      nvarchar(max) not null
			,EffectiveTime										datetime			not null
			,ExpiryTime												datetime			null
    )

	begin try

			insert 
				@setup
			(
				 ApplicationUserSID
				,ApplicationGrantSID
        ,ChangeAudit
				,EffectiveTime
				,ExpiryTime
			) 
			values 
			(
				 (select min(x.ApplicationUserSID) from sf.ApplicationUser x)
				,(select x.ApplicationGrantSID from sf.ApplicationGrant x where x.ApplicationGrantSCD = 'ADMIN.SYSADMIN')
        ,cast(sf.fNow() as nvarchar(19)) + ' Assigned by: ' + @SetupUser
				,sf.fNow()
				,null
			)
			,(
				 (select x.ApplicationUserSID from sf.ApplicationUser x where x.UserName = N'JobExec')
				,(select x.ApplicationGrantSID from sf.ApplicationGrant x where x.ApplicationGrantSCD = 'ADMIN.SYSADMIN')
        ,cast(sf.fNow() as nvarchar(19)) + ' Assigned by: ' + @SetupUser
				,sf.fNow()
				,null
			)
			,(
				 (select x.ApplicationUserSID from sf.ApplicationUser x where x.UserName = N'admin@helpdesk')
				,(select x.ApplicationGrantSID from sf.ApplicationGrant x where x.ApplicationGrantSCD = 'ADMIN.SYSADMIN')
        ,cast(sf.fNow() as nvarchar(19)) + ' Assigned by: ' + @SetupUser
				,sf.fNow()
				,sf.fNow()
			)

	  merge
      sf.ApplicationUserGrant target
    using
    (
      select
				 x.ApplicationUserSID
				,x.ApplicationGrantSID
        ,x.ChangeAudit
				,x.EffectiveTime
				,x.ExpiryTime
				,@SetupUser CreateUser
				,@SetupUser	UpdateUser			       
			from 
				@setup x
    ) source
    on 
      target.ApplicationUserSID = source.ApplicationUserSID
  	when not matched by target then
	    insert 
      (
				 ApplicationUserSID
				,ApplicationGrantSID
        ,ChangeAudit
				,EffectiveTime
				,ExpiryTime
				,CreateUser
				,UpdateUser
      ) 
      values
	    (
				 source.ApplicationUserSID
				,source.ApplicationGrantSID
        ,source.ChangeAudit
				,source.EffectiveTime
				,source.ExpiryTime
        ,@SetupUser
        ,@SetupUser
      )
			;
		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from  @setup            
		select @targetCount = count(1) from  sf.ApplicationUserGrant

		if isnull(@targetCount,0) < @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupCountTooLow'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Insert of some setup records failed. Source table count is %1 but target table (%2) count is only %3. Check "JOIN" conditions.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'sf.ApplicationUserGrant'
				,@Arg3          = @targetCount

			raiserror(@errorText, 18, 1)
		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
