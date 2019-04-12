SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$SF#Gender]
	 @SetupUser											nvarchar(75)											      -- user assigned to audit columns
	,@Language                      char(2)                                 -- language to install for
	,@Region                        varchar(10)         										-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.Gender data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.Gender master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund 	| Apr	2012			| Initial Version				 
				 : Christian T	| May 2014			| Added test harness
				 : Christian T	| May 2014			| Added 'Unknown' gender.			
				 : Richard K		| April 2015		| Updated to avoid overwriting user changes to GenderLabel
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.Gender table with the settings required by the current version of the application. If
a record is missing it is added. Where the record exists, it is set to current values.One MERGE statement is used to carryout all 
operations.

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up 
	data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			if	not exists (select 1 from sf.Person where GenderSID is not null)
			and not exists (select 1 from dbo.PersonProfileUpdate where GenderSID is not null)
			begin
				delete from sf.Gender
				dbcc checkident( 'sf.Gender', reseed, 1000000) with NO_INFOMSGS
			end

			exec dbo.pSetup$SF#Gender
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.Gender

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#Gender'
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
			,GenderSCD												char(1)				not null
			,GenderLabel											nvarchar(35)	not null
		)

	begin try
	
		insert
			@setup
		(
			 GenderSCD
			,GenderLabel
		)
		values
			('F', N'Female')
		 ,('M', N'Male')
		 ,('T', N'Transgender')
		 ,('U', N'Unspecified')

		merge
			sf.Gender target
		using
		(
			select
				 x.GenderSCD
				,x.GenderLabel
			from
				@setup x
		) source
		on 
			target.GenderSCD = source.GenderSCD
		when not matched by target then
			insert 
			(
				 GenderSCD
				,GenderLabel
				,CreateUser
				,UpdateUser
			) 
			values
			(
				 source.GenderSCD
				,source.GenderLabel
				,@SetupUser
				,@SetupUser
			)
		when not matched by source then
			delete
		;

		-- check count of @setup table and the target table
		-- target should have exactly as many rows as @setup

		select @sourceCount = count(1) from  @setup
		select @targetCount = count(1) from  sf.Gender

		if isnull(@targetCount,0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				 @MessageSCD    = 'SetupNotSynchronized'
				,@MessageText   = @errorText output
				,@DefaultText   = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				,@Arg1          = @sourceCount
				,@Arg2          = 'sf.Gender'
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
