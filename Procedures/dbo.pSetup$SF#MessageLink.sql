SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#MessageLink]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.MessageLink data
Notice   : Copyright © 2015 Softworks Group Inc.
Summary  : Updates sf.MessageLink master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Jun 2015			| Initial Version
				 : Richard K		| Aug 2015			| Added Password reset link
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.MessageLink table with the settings required by the current version of the application. If
a record is missing it is added. Where the record exists, it is set to current values and records dropped from the product are
deleted from the table. One MERGE statement is used to carryout all operations.

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table.

Example:
--------

delete from sf.MessageLink																	-- delete only succeeds if no FK rows!
dbcc checkident( 'sf.MessageLink', reseed, 1000000) with NO_INFOMSGS

exec dbo.pSetup$SF#MessageLink 
	@SetupUser = 'system@softworksgroup.com'
	,@Language = 'EN'
	,@Region = null

select * from sf.MessageLink

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
			 ID                               int           identity(1,1)
			,MessageLinkSCD										varchar(30)		null
			,MessageLinkLabel									nvarchar(35)	not null
			,UsageNotes												nvarchar(max)	not null
			,ApplicationPageSID								int						not null
		)

	begin try

		insert
			@setup
		(
			 MessageLinkLabel						
			,MessageLinkSCD		
			,UsageNotes
			,ApplicationPageSID
		)
		values
			 (N'Complete user registration'					,'USER.REGISTRATION'			,N'Links to a page for new users to confirm their email address and establish a basic user profile.'																													,(select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI = 'UserConfirmation'))
			,(N'Confirm password reset'							,'PASSWORD.RESET'					,N'Links to a page for users to confirm reset of their password.'																																															,(select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI = 'PasswordReset'))
			,(N'Client application portal'					,'CLIENT.APP.PORTAL'			,N'Links to the client applications portal where applicants can apply for registrations or administrators can verify employment.'																	,(select ApplicationPageSID from sf.ApplicationPage where ApplicationPageURI = 'ClientApplicationPortal'))

		merge
			sf.MessageLink target
		using
		(
			select
				 x.MessageLinkLabel
				,x.MessageLinkSCD
				,x.UsageNotes
				,x.ApplicationPageSID
			from
				@setup x
		) source
		on 
			target.MessageLinkSCD = source.MessageLinkSCD
		when not matched by target then
			insert 
			(
				 MessageLinkLabel						
				,MessageLinkSCD		
				,UsageNotes
				,ApplicationPageSID
				,CreateUser
				,UpdateUser
			) 
			values
			(
				 source.MessageLinkLabel
				,source.MessageLinkSCD
				,source.UsageNotes
				,source.ApplicationPageSID
				,@SetupUser
				,@SetupUser
			)
		when matched then
			update 
				set 
				 MessageLinkLabel				= source.MessageLinkLabel
				,UsageNotes						= source.UsageNotes
				,ApplicationPageSID		= source.ApplicationPageSID
				,UpdateUser						= @SetupUser
				,UpdateTime						= sysdatetimeoffset()
		when not matched by source then
			delete
		;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from  @setup
		select @targetCount = count(1) from  sf.MessageLink

		if isnull(@targetCount,0) <> @sourceCount
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
