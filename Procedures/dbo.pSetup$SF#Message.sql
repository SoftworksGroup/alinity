SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#Message]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.Message data
Notice   : Copyright © 2015 Softworks Group Inc.
Summary  : Updates sf.Message master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Russ Poirier | Feb 2017			| Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure adds and/or updates messages in the sf.Message table. Out-of-the-box messages are generated through sf.pMessage#Get
at the bottom of the procedure. If a record is missing it is added. Where the record exists, it is set to current values. One 
MERGE statement is used to carryout all operations.

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table.

Example:
--------

exec dbo.pSetup$SF#Message
	@SetupUser = 'system@softworksgroup.com'
	,@Language = 'EN'
	,@Region = null

select * from sf.Message

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@sourceCount                       int                               -- count of rows in the source table
		,@targetCount                       int                               -- count of rows in the target table

	declare
		@setup															table
		(
			 ID                               int             identity(1,1)
			,MessageSCD										    varchar(128)		null
			,MessageName									    nvarchar(100)	  not null
			,DefaultText								      nvarchar(1000)	not null
		)

	begin try

		insert
			@setup
		(
			 MessageSCD						
			,MessageName		
			,DefaultText
		)
		values
		   ('Report.ApplicationUserRoles.Title'   , N'Report - Application User Roles - Title'  , 'Application User Roles')
      ,('Report.AssignedUserLcenses.Title'    , N'Report - Assigned User Registrations - Title'  , 'Assigned User Licenses')
      ,('Report.SecurityRoleMembership.Title' , N'Report - Securty Role Membership - Title' , 'Security Role Membership')

		merge
			sf.[Message] target
		using
		(
			select
				 x.MessageSCD
				,x.MessageName
				,x.DefaultText
			from
				@setup x
		) source
		on 
			target.MessageSCD = source.MessageSCD
		when not matched by target then
			insert 
			(
				 MessageSCD		
				,MessageName
        ,DefaultText
				,CreateUser
				,UpdateUser
			) 
			values
			(
				 source.MessageSCD
				,source.MessageName
				,source.DefaultText
				,@SetupUser
				,@SetupUser
			)
		when matched then
			update 
				set 
				 MessageName					= source.MessageName
        ,DefaultText          = source.DefaultText
				,UpdateUser						= @SetupUser
				,UpdateTime						= sysdatetimeoffset()
		;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from  @setup
		select @targetCount = count(1) from  sf.[Message]

		if isnull(@targetCount,0) < @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupNotSynchronized'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'sf.MessageLink'
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
