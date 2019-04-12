SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#ApplicationUser]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
	,@SysAdminUserName							nvarchar(75)														-- user name of base "System Administrator" for new installs
as
/*********************************************************************************************************************************
Sproc    : Setup sf.ApplicationUser data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates dbo.ApplicationUser master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year  | Change Summary
				 : ------------ | ------------|-------------------------------------------------------------------------------------------
				 : Christian T	| Apr	2012		| Initial Version
				 : Christian T	| May 2014		| Added test harness
				 : Tim Edlund		| Jul 2014		| Minor updates for standards
				 : Tim Edlund		| Feb	2015		|	Updated to include AuthenticationAuthority column
				 : Christian T	| June 2015		| Updated to include a fake appPasword in order for business rules to pass 
				 : Cory Ng			| Dec 2016		| Removed add of registrant record and removed password as they are stored in TS.
----------------------------------------------------------------------------------------------------------------------------------

Comments  
--------
This procedure ensures the base accounts required by the application are created (e.g. "SysAdmin", job executor, etc.).  If a
required record is not found it is added. No existing records are deleted. 

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures setup procedure executes successfully. Prior data is not deleted.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#ApplicationUser
				 @SetupUser					= 'system@alinityapp.com'
				,@Language					= 'EN'
				,@Region						= 'CA'
				,@SysAdminUserName	= 'system@alinityapp.com'

			select * from sf.ApplicationUser

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:02" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#ApplicationUser'
	,@DefaultTestOnly = 1
------------------------------------------------------------------------------------------------------------------------------- */
																																																																		
begin  

	set nocount on

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@personSID													int																-- PK of person record that parents the SysAdmin account
		,@authenticationAuthoritySID				int																-- key of default authentication method (email.ts)
		,@cultureSID												int																-- the culture to assign to all users
		,@ON																bit = cast(1 as bit)							-- constant for boolean comparisons
	
	begin try

		-- lookup default authentication authority key

		select
			@authenticationAuthoritySID = aa.AuthenticationAuthoritySID
		from
			sf.AuthenticationAuthority aa
		where
			aa.IsDefault = cast(1 as bit)

		select
			@cultureSID = c.CultureSID
		from
			sf.Culture c
		where
			c.IsDefault = cast(1 as bit)

		-- lookup key for the initial SA account

		select 
			@personSID = p.PersonSID
		from 
			sf.Person p
		where 
			p.FirstName = N'System' 
		and 
			p.LastName = N'Administrator'

		if @@rowcount = 1 and	not exists
		(
			select
				1
			from
				sf.vApplicationUser au
			where
				au.UserName = @SysAdminUserName
			or 
				au.IsSysAdmin = @ON
			or
				au.PersonSID = @personSID
		)
		begin

			insert 
				sf.ApplicationUser
			(
				 PersonSID
				,CultureSID
				,AuthenticationAuthoritySID
				,UserName
				,ChangeAudit
				,Comments		
				,CreateUser
				,UpdateUser
			) 
			select
				 @personSID
				,@cultureSID
				,@authenticationAuthoritySID
				,@SysAdminUserName
				,sf.fChangeAudit#Active(cast(1 as bit), null, null)
				,N'This is the initial System Administrator account. The account is given the top-level "SysAdmin" grant when created which provide access to ALL options in the system. This account is required to setup other system administrators, however, may be inactivated after setup.'
				,@SetupUser
				,@SetupUser

		end

		-- update for pwd (requires GUID)
		update
			sf.ApplicationUser
		set
			GlassBreakPassword = sf.fHashString(cast(RowGUID as nvarchar(50)), 'sgi@2.00')
		where
			UserName = @SysAdminUserName

		select 
			@personSID = p.PersonSID
		from 
			sf.Person p
		where 
			p.FirstName = N'Job' 
		and 
			p.LastName = N'Executor'

		if @@rowcount = 1 and	not exists		
		(
			select
				1
			from
				sf.ApplicationUser au
			where
				au.UserName = 'JobExec'
			or 
				au.PersonSID = @personSID
		)
		begin

			insert 
				sf.ApplicationUser
			(
				 PersonSID
				,CultureSID
				,AuthenticationAuthoritySID
				,UserName
				,AuthenticationSystemID
				,ChangeAudit
				,Comments		
				,CreateUser
				,UpdateUser
			) 
			select
				 @personSID
				,@cultureSID
				,@authenticationAuthoritySID
				,'JobExec'
				,'JobExec'
				,sf.fChangeAudit#Active(cast(0 as bit), null, null)
				,N'This is a system user used to run background database processes. Editing or deleting this user is not allowed.'
				,@SetupUser
				,@SetupUser

		end

		select 
			@personSID = p.PersonSID
		from 
			sf.Person p
		where 
			p.FirstName = N'Help' 
		and 
			p.LastName = N'Desk'

		if @@rowcount = 1 and	not exists
		(
			select
				1
			from
				sf.ApplicationUser au
			where
				au.UserName = 'admin@helpdesk'
			or 
				au.PersonSID = @personSID 
		)
		begin

			insert 
				sf.ApplicationUser
			(
				 PersonSID
				,CultureSID
				,AuthenticationAuthoritySID
				,UserName
				,ChangeAudit
				,Comments		
				,CreateUser
				,UpdateUser
			) 
			select
				 @personSID
				,@cultureSID
				,@authenticationAuthoritySID
				,'admin@helpdesk'
				,sf.fChangeAudit#Active(cast(0 as bit), null, null)
				,N'This is a system user used to allow the help desk to access you system when you explicitly grant access to the help desk. Editing or deleting this user is not allowed.'
				,@SetupUser
				,@SetupUser

		end
	
	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
