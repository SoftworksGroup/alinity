SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#Person]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
  ,@Language                      char(2)                                 -- language to install for
  ,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.Person data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.Person master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| March	2012	  | Initial Version
				 : Christian T	| May 2014			| Added test harness
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure populates the sf.Person table with starting values required by the application. The procedure inserts values 
using a hardcoded script - below.  See framework calling procedure "sf.pSetup" for additional details. 

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			if	not exists (select 1 from sf.ApplicationUser where PersonSID is not null)		
			and not exists (select 1 from sf.Notification where PersonSID is not null)
			and not exists (select 1 from dbo.PersonGroupMember where PersonSID is not null)
			begin
				delete from sf.Person
				dbcc checkident( 'sf.Person', reseed, 1000000) with NO_INFOMSGS
			end

			exec dbo.pSetup$SF#Person
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.Person

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#Person'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on
																																																																			
begin  

	declare
		 @errorNo                           int = 0                           -- 0 no error, if < 50000 SQL error, else business rule
		,@errorText                         nvarchar(4000)                    -- message text (for business rule errors)
		,@ON																bit							= cast(1 as bit)	-- used for logical true
		,@OFF																bit							= cast(0 as bit)	-- used for logical false
		,@sourceCount                       int                               -- count of rows in the source table
    ,@targetCount                       int                               -- count of rows in the target table
		,@i																	int							= 1								-- loop iteration buffer
		,@maxRows														int																-- loop iteration limit
		,@genderSID													int																-- gender sid to use for setup users
		,@namePrefixSID											int																-- name prefix sid to use for all the users
		,@firstName													nvarchar(30)											-- stores firstName for loop into API sproc
		,@lastName													nvarchar(35)											-- stores lastName for loop into API sproc
		,@personSID													int																-- stores newly created person sid
		
	declare
    @setup															table
    (
      ID																int           identity(1,1)
			,GenderSID												int						not null
			,NamePrefixSID										int						null
			,FirstName												nvarchar(30)	not null			
			,LastName													nvarchar(35)	not null
    )
	begin try

		
		if 
			not exists(select 1 from sf.Person where FirstName = N'System' and LastName = N'Administrator')	
		and
			not exists(select 1 from sf.vApplicationUser where IsSysAdmin = cast(1 as bit))
			insert 
				sf.Person
			(
				 GenderSID
				,FirstName
				,LastName
				,CreateUser
				,UpdateUser
			) 
			values 
			(
				 (select x.GenderSID			from sf.Gender      x where x.GenderSCD = 'U')
				,N'System'
				,N'Administrator'
				,@SetupUser
				,@SetupUser
			)
	
		if not exists(select 1 from sf.Person where FirstName = N'Job' and LastName = N'Executor')	
			insert 
				sf.Person
			(
				 GenderSID
				,FirstName
				,LastName
				,CreateUser
				,UpdateUser
			) 
			values 
			(
				 (select x.GenderSID			from sf.Gender      x where x.GenderSCD = 'U')
				,N'Job'
				,N'Executor'
				,@SetupUser
				,@SetupUser
			)

		if not exists(select 1 from sf.Person where FirstName = N'Help' and LastName = N'Desk')	
			insert 
				sf.Person
			(
				 GenderSID
				,FirstName
				,LastName
				,CreateUser
				,UpdateUser
			) 
			values 
			(
				 (select x.GenderSID			from sf.Gender      x where x.GenderSCD = 'U')
				,N'Help'
				,N'Desk'
				,@SetupUser
				,@SetupUser
			)

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
