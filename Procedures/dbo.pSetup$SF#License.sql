SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[pSetup$SF#License]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.License data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates sf.License master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Tim Edlund		| March	2012	  | Initial Version
				 : Christian T	| May 2014			| Added test harness
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure populates the sf.License table with starting values required by the application. The procedure inserts values 
using a hard coded script - below.  See framework calling procedure "sf.pSetup" for additional details. 

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set 
	up data is deleted prior to test.">
		<SQLScript>
		<![CDATA[
		
			delete from sf.License
			dbcc checkident( 'sf.License', reseed, 1000000) with NO_INFOMSGS

			exec dbo.pSetup$SF#License
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.License

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#License'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

begin

	set nocount on;

	declare
		@errorNo		 int = 0				-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000) -- message text (for business rule errors)
	 ,@sourceCount int						-- count of rows in the source table
	 ,@targetCount int;						-- count of rows in the target table

	declare @sample table (ID int identity(1, 1), License xml not null);

	-- DO NOT modify the content of the xml including spacing, tabs, line-breaks etc
	-- if any part of the content does not match exactly what was provided to the registration
	-- generator login will fail

	begin try
		if not exists (select 1 from sf .License) or db_name() = 'devV6'
		begin
			insert
				@sample (License)
			values
			(
				convert(
								 xml
								,N'<License Registration="College of Licensed Professionals (DEMO)" ProductName="Alinity" Version="6">
  <Item Code="ULIC.ADMIN" Name="Administrator Portal" Quantity="5" />
  <Item Code="ULIC.EXTERNAL" Name="Member Portal" Quantity="50000" />
  <Item Code="ULIC.COMPETENCE" Name="Continuing Education" Enabled="true" />
  <Item Code="ULIC.COMPLAINT" Name="Complaint Management" Enabled="true" />
  <Item Code="ULIC.TASK" Name="Task Management" Enabled="true" />
  <Item Code="ULIC.DBMANAGEMENT" Name="Database Management" Enabled="true" />
</License>'
							 )
			);

			insert
				sf.License (License, CreateUser, UpdateUser)
			select x .License, @SetupUser, @SetupUser from @sample x ;

			-- check count of @sample table and the target table
			-- target should have at least as many rows as @sample

			select @sourceCount	 = count(1) from @sample ;
			select @targetCount	 = count(1) from sf .License;

			if isnull(@targetCount, 0) < @sourceCount
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'SampleTooSmall'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'Insert of some sample records failed. Source table count is %1 but target table (%2) count is only %3. Check "JOIN" conditions.'
				 ,@Arg1 = @sourceCount
				 ,@Arg2 = 'sf.License'
				 ,@Arg3 = @targetCount;

				raiserror(@errorText, 18, 1);
			end;
		end;
	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
