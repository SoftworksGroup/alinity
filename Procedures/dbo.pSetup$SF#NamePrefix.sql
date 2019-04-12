SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#NamePrefix]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.NamePrefix data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.NamePrefix master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund 	| Apr		2012	  | Initial Version				 		
				 : Christian T	| May 2014			| Added test harness
				 : Richard K		| April 2015		| Updated to only add records if the table is empty
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------

This procedure adds name prefixes provided as defaults by the product, but which are missing from the sf.NamePrefix table. Unlike
many pSetup routines, a MERGE is not used to synchronize the target table with the version defined in the procedure. Synchronization
is avoided because sf.NamePrefix is a user maintainable table and synchronization could cause records to be deleted on upgrades.

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			if	not exists (select 1 from sf.Person where NamePrefixSID is not null)
			and not exists (select 1 from dbo.PersonProfileUpdate where NamePrefixSID is not null)
			begin
				delete from sf.NamePrefix
				dbcc checkident( 'sf.NamePrefix', reseed, 1000000) with NO_INFOMSGS
			end

			exec dbo.pSetup$SF#NamePrefix
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.NamePrefix

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#NamePrefix'
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
		@setup															table
		(
			 ID                               int           identity(1,1)
			,NamePrefixLabel									nvarchar(35)   not null
		)
	
	begin try

		if not exists (select top 1 NamePrefixSID from sf.NamePrefix)
		begin
	
			insert
				sf.NamePrefix
			(
				 NamePrefixLabel
				,CreateUser
				,UpdateUser
			) 
			values
				 (N'Dr.',		@SetupUser, @SetupUser)
				,(N'Hon.',	@SetupUser, @SetupUser)
				,(N'M.',		@SetupUser, @SetupUser)
				,(N'Mr.',		@SetupUser, @SetupUser)
				,(N'Mrs.',	@SetupUser, @SetupUser)
				,(N'Ms.',		@SetupUser, @SetupUser)
				,(N'Miss', @SetupUser, @SetupUser)
				,(N'Rev.',	@SetupUser, @SetupUser)
			
		end

	end try

	begin catch
		exec @errorNo = sf.pErrorRethrow
	end catch

	return(@errorNo)

end
GO
