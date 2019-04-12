SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#MessageLinkStatus]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
  ,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.MessageLinkStatus data
Notice   : Copyright © 2014 Softworks Group Inc.
Summary  : Updates sf.MessageLinkStatus master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tyson Schulz	| Nov	2014			| Initial Version
				 : Richard K		| April 2015		| Updated to avoid overwriting user changes to MessageLinkStatusLabel, UsageNotes
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.MessageLinkStatus table with the settings required by the current version of the application. If
a record is missing it is added. Where the record exists, it is updated to the column values for the current version of the 
application. MessageLink statuses no longer used are deleted from the table. One MERGE statement is used to carryout all operations.

Example:
--------

<TestHarness>
  <Test Name="SyncMaster" IsDefault="true" Description="Runs the setup procedure and returns a result set containing the master 
	table contents.">
    <SQLScript>
      <![CDATA[
      
exec dbo.pSetup$SF#MessageLinkStatus
	@SetupUser  = 'SysAdmin@AI'
 ,@Language   = 'EN'
 ,@Region     = 'AB'
	
select * from sf.MessageLinkStatus
      ]]>
    </SQLScript>
    <Assertions>
      <Assertion Type="NotEmptyResultSet" ResultSet ="1" />
      <Assertion Type="ExecutionTime" Value="00:00:02" />
    </Assertions>
  </Test>
</TestHarness>

exec sf.pUnitTest#Execute @ObjectName = 'dbo.pSetup$SF#MessageLinkStatus'	-- run test with unit test method

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@OFF																bit = cast(0 as bit)							-- constant for bit = 0
		,@ON																bit = cast(1 as bit)							-- constant for bit = 1
	
	declare
    @setup                             table
    (
			 ID															int							    identity(1,1)
			,MessageLinkStatusSCD						varchar(10)					not null
			,MessageLinkStatusLabel					nvarchar(35)				not null
			,UsageNotes											nvarchar(max)				null
			,IsResendEnabled								bit									not null
			,IsDefault											bit									not null    
		)	

	begin try

		insert 
			@setup
			(
				 MessageLinkStatusSCD	
				,MessageLinkStatusLabel
        ,UsageNotes							
				,IsResendEnabled					
				,IsDefault							
			)
		values
       ('PENDING'		,N'Pending'							,N'This status indicates that the record is awaiting to be confirmed.', @ON, @ON)
      ,('CONFIRMED'	,N'Confirmed'						,N'This status indicates that the record was confirmed and is now no longer pending.', @OFF, @OFF)
      ,('CANCELLED'	,N'Cancelled'						,N'This status indicates that the record has been cancelled, rendering it inactive.', @OFF, @OFF)
      ,('EXPIRED'		,N'Expired'							,N'This status indicates that the record has been pending for over the maximum amount of hours before it could be redeemed, rendering it inactive.', @OFF, @OFF)
	  merge
      sf.MessageLinkStatus target
		using
    (
      select
				 x.MessageLinkStatusSCD	
				,x.MessageLinkStatusLabel
        ,x.UsageNotes    
				,x.IsResendEnabled
				,x.IsDefault			
				,@SetupUser CreateUser
				,@SetupUser	UpdateUser			       
			from 
				@setup x
    ) source
    on 
      target.MessageLinkStatusSCD = source.MessageLinkStatusSCD
  	when not matched by target then
	    insert 
      (
				 MessageLinkStatusSCD	
				,MessageLinkStatusLabel
        ,UsageNotes    
				,IsResendEnabled	
				,IsDefault
				,CreateUser
				,UpdateUser
      ) 
      values
	    (
				 source.MessageLinkStatusSCD	
				,source.MessageLinkStatusLabel
        ,source.UsageNotes    
				,source.IsResendEnabled	
				,source.IsDefault
        ,@SetupUser
        ,@SetupUser
      )
    when matched then
      update 
        set   
				IsResendEnabled					= source.IsResendEnabled
				,IsDefault							= source.IsDefault
				,Usagenotes							= source.UsageNotes
				,UpdateUser							= @SetupUser
    when not matched by source then
      delete
    ;
	
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
