SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pSetup$GLAccount]
	@SetupUser nvarchar(75) -- user assigned to audit columns
 ,@Language	 char(2)			-- language to install for
 ,@Region		 varchar(10)	-- designator for locale to generate data for
as
/*********************************************************************************************************************************
Sproc    : Setup dbo.GLAccount data
Notice   : Copyright © 2012 Softworks Group Inc.
Summary  : updates dbo.GLAccount table with starting values for the application
----------------------------------------------------------------------------------------------------------------------------------
History  : Author(s)    | Month Year    | Change Summary
				 : ------------ | ------------- |-----------------------------------------------------------------------------------------
				 : Richard K	 	| Aug 2015			| Initial Version		
				   Tim Edlund		| Sep 2017			| Updated for new account types		 
----------------------------------------------------------------------------------------------------------------------------------
Comments  
--------
This procedure synchronizes the dbo.GLAccount table with the settings required by the current version of the application. a
record exists it will skip inserting values.

The procedure uses the SQL multi-row constructor syntax to insert values into a temporary table.

<TestHarness>
	<Test Name="Basic" IsDefault="true" Description="Ensures sproc executes successfully. If no child records exist, previous set up 
	data is deleted prior to test.">
		<SQLScript>
		<![CDATA[

		exec dbo.pSetup$GLAccount 
			 @SetupUser = N'system@softworksgroup.com'
			,@Language  = 'en'
			,@Region		= 'can'
	
		select * from dbo.GLAccount

		]]>
		</SQLScript>
		<Assertions>
			<Assertion Type="NotEmptyResultSet" ResultSet="1"/>
			<Assertion Type="ExecutionTime" Value="00:00:05" />
		</Assertions>
	</Test>
</TestHarness>

exec sf.pUnitTest#Execute
	 @ObjectName = 'dbo.pSetup$GLAccount'
	,@DefaultTestOnly = 1

------------------------------------------------------------------------------------------------------------------------------- */

set nocount on;

begin

	declare
		@errorNo		 int					 = 0							-- 0 no error, if < 50000 SQL error, else business rule
	 ,@errorText	 nvarchar(4000)									-- message text (for business rule errors)
	 ,@OFF				 bit					 = cast(0 as bit) -- constant to refer to "false" bit value
	 ,@ON					 bit					 = cast(1 as bit) -- constant to refer to "true" bit value
	 ,@sourceCount int														-- count of rows in the source table
	 ,@targetCount int;														-- count of rows in the target table

	declare @setup table
	(
		ID								 int					identity(1, 1)
	 ,GLAccountCode			 varchar(50)	not null
	 ,GLAccountLabel		 nvarchar(35) not null
	 ,IsRevenueAccount	 bit					not null
	 ,IsBankAccount			 bit					not null
	 ,IsTaxAccount			 bit					not null
	 ,IsUnappliedAccount bit					not null
	);

	begin try

		if not exists (select 1 from	dbo.GLAccount)
		begin

-- SQL Prompt formatting off
			insert
				@setup
			(
				GLAccountCode
				,GLAccountLabel
				,IsRevenueAccount
				,IsBankAccount
				,IsTaxAccount		
				,IsUnappliedAccount	
			)
			values 
			 ('101'	,'Revenue Account'		,@ON	,@OFF	,@OFF, @OFF)
			,('201' ,'Bank Account'				,@OFF	,@ON	,@OFF, @OFF)
			,('301' ,'Tax Account'				,@OFF	,@OFF	,@ON, @OFF)
			,('401' ,'Unapplied payments', @OFF, @OFF, @OFF, @ON)
-- SQL Prompt formatting on

			insert
				dbo.GLAccount
			(
				GLAccountCode
			 ,GLAccountLabel
			 ,IsRevenueAccount
			 ,IsBankAccount
			 ,IsTaxAccount
			 ,IsUnappliedPaymentAccount
			 ,CreateUser
			 ,UpdateUser
			)
				select
					GLAccountCode
				 ,GLAccountLabel
				 ,IsRevenueAccount
				 ,IsBankAccount
				 ,IsTaxAccount
				 ,IsUnappliedAccount
				 ,@SetupUser
				 ,@SetupUser
				from
					@setup;

			-- check count of @setup table and the target table
			-- target should have exactly as many rows as @setup

			select	@sourceCount = count(1) from	@setup;
			select
				@targetCount = count(1)
			from
				dbo.GLAccount;

			if isnull(@targetCount, 0) <> @sourceCount
			begin

				exec sf.pMessage#Get
					@MessageSCD = 'SetupNotSynchronized'
				 ,@MessageText = @errorText output
				 ,@DefaultText = N'Synchronization of setup codes not complete. Source table count is %1 but target table (%2) count is %3.'
				 ,@Arg1 = @sourceCount
				 ,@Arg2 = 'dbo.GLAccount'
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
