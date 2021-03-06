SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.[pSetup$SF#Culture]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup sf.Culture data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates dbo.Culture master table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year	| Change Summary
				 : ------------ | ----------- |-------------------------------------------------------------------------------------------
				 : Tim Edlund		| Jan 2018		| Initial Version
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the sf.Culture table with the settings required by the current version of the application. Where are
a record is missing it is added. Where the record exists, it is set to current values and where a record longer used in the
current version it is deleted from the table. One MERGE statement is used to carryout all operations.

Limitations
-----------
In the scenario where a previously applied record is being deleted, a migration script must take care of re-assigning any
foreign key references to the old record before this script is run.

Example:
--------

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully.">
		<SQLScript>
		<![CDATA[
		
			exec dbo.pSetup$SF#Culture
				 @SetupUser = 'system@alinityapp.com'
				,@Language = 'EN'
				,@Region = 'CA'

			select * from sf.Culture

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$SF#Culture'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo		 int					 = 0	-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)			-- message text (for business rule errors)
	 ,@OFF				 bit					 = cast(0 as bit)
	 ,@ON					 bit					 = cast(1 as bit)
	 ,@sourceCount int								-- count of rows in the source table
	 ,@targetCount int;								-- count of rows in the target table

	declare @setup table
	(
		ID					 int					 identity(1, 1)
	 ,CultureSCD	 varchar(10)	 not null
	 ,CultureLabel nvarchar(150) not null
	 ,IsDefault		 bit					 not null
	 ,IsActive		 bit					 not null
	);

	begin try

		insert
			@setup (CultureSCD, CultureLabel, IsDefault, IsActive)
		values
		  ('EN-CA', N'English (Canada)', @ON, @ON)
		 ,('EN-US', N'English (US)', @OFF, @OFF)
		 ,('FR-CA', N'Français (Canada)', @OFF, @OFF)
		 ,('ES-US', N'Española (US)', @OFF, @OFF);

		merge sf.Culture target
		using (
						select
							x.CultureSCD
						 ,x.CultureLabel
						 ,x.IsDefault
						 ,x.IsActive
						 ,@SetupUser CreateUser
						 ,@SetupUser UpdateUser
						from
							@setup x
					) source
		on target.CultureSCD = source.CultureSCD
		when not matched by target then
			insert
			(
				CultureSCD
			 ,CultureLabel
			 ,IsDefault
			 ,IsActive
			 ,CreateUser
			 ,UpdateUser
			)
			values
			(
				source.CultureSCD
			 ,source.CultureLabel -- this will overwrite client changes on upgrades but is intentional to ensure any change in meaning is explained
			 ,source.IsDefault
			 ,source.IsActive
			 ,@SetupUser
			 ,@SetupUser
			)
		when not matched by source then delete;

		-- check count of @setup table and the target table
		-- target should have at least as many rows as @setup

		select @sourceCount = count(1) from @setup;
		select @targetCount = count(1) from sf.Culture;

		if isnull(@targetCount, 0) <> @sourceCount
		begin

			exec sf.pMessage#Get
				@MessageSCD = 'SetupNotSynchronized'
			 ,@MessageText = @errorText output
			 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
			 ,@Arg1 = @sourceCount
			 ,@Arg2 = 'sf.Culture'
			 ,@Arg3 = @targetCount;

			raiserror(@errorText, 18, 1);
		end;

	end try
	begin catch
		exec @errorNo = sf.pErrorRethrow;
	end catch;

	return (@errorNo);

end;
GO
