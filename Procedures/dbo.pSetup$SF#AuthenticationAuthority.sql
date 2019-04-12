SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#AuthenticationAuthority]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.AuthenticationAuthority data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : Updates sf.AuthenticationAuthority master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| Feb 2015			| Initial Version
				 : Richard K		| April 2015		| Updated to avoid overwriting user changes to AuthenticationAuthorityLabel, UsageNotes
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.AuthenticationAuthority table with the settings required by the current version of the 
application. If a record is missing it is added. Authentication Authorities no longer used are deleted from the table. 

One MERGE statement is used to carryout all operations.

Example:
--------

<TestHarness>
	<Test Name="SyncMaster" IsDefault="true" Description="Runs the setup procedure and returns a result set containing the master 
	table contents.">
		<SQLScript>
			<![CDATA[
			
exec dbo.pSetup$SF#AuthenticationAuthority
	@SetupUser  = 'system@softworksgroup.com'
 ,@Language   = 'EN'
 ,@Region     = 'AB'
	
select * from sf.AuthenticationAuthority
			]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet ="1" />
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute @ObjectName = 'dbo.pSetup$SF#AuthenticationAuthority'	-- run test with unit test method

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@ON																bit = cast(1 as bit)							-- constant for boolean comparisons
		,@OFF																bit = cast(0 as bit)							-- constant for boolean comparisons
	
	declare
		@setup															table
		(
			 ID																int							    identity(1,1)
			,AuthenticationAuthoritySCD				varchar(10)					not null
			,AuthenticationAuthorityLabel			nvarchar(35)				not null
			,UsageNotes												nvarchar(max)				null
			,IsDefault												bit									not null    
			,IsActive													bit									not null    
		)	

	begin try

		insert 
			@setup
			(
				 AuthenticationAuthoritySCD	
				,AuthenticationAuthorityLabel
				,UsageNotes							
				,IsDefault							
				,IsActive																													-- NOTE: some methods are inserted but set inactive as they are not
			)																																		-- yet supported! Change IsActive setting when upgraded.
		values
			 ('EMAIL.TS'	,N'Email (tenant services)'	,N'This method authenticates the user with an email address username and a password stored in the Tenant Services database.', @ON, @ON)
			,('LDAP.AD'		,N'Active Directory (LDAP)'	,N'The user logs in using the local Active Directory repository. This option is only available for on-premise and private-cloud installations.', @OFF, @ON)
			,('GOOGLE'		,N'Google account'					,N'The user logs in using their Google account.', @OFF, @OFF)
			,('MSACCOUNT'	,N'Microsoft account'				,N'The user logs in using their Microsoft account (formerly known as "Windows Live account".', @OFF, @OFF)
		merge
			sf.AuthenticationAuthority target
		using
		(
			select
				 x.AuthenticationAuthoritySCD	
				,x.AuthenticationAuthorityLabel
				,x.UsageNotes    
				,x.IsDefault	
				,x.IsActive		
				,@SetupUser CreateUser
				,@SetupUser	UpdateUser			       
			from 
				@setup x
		) source
		on 
			target.AuthenticationAuthoritySCD = source.AuthenticationAuthoritySCD
		when not matched by target then
			insert 
			(
				 AuthenticationAuthoritySCD	
				,AuthenticationAuthorityLabel
				,UsageNotes    
				,IsDefault
				,IsActive
				,CreateUser
				,UpdateUser
			) 
			values
			(
				 source.AuthenticationAuthoritySCD	
				,source.AuthenticationAuthorityLabel
				,source.UsageNotes    
				,source.IsDefault
				,source.IsActive
				,@SetupUser
				,@SetupUser
			)
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
